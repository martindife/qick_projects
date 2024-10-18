///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : Martin Di Federico
//  Date           : 1-2024
//  Version        : 1
///////////////////////////////////////////////////////////////////////////////
//  QICK DMA DRIVERS : 
/* Description: 
    DMA write and read controller
*/
//////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// DMA WRITE
///////////////////////////////////////////////////////////////////////////////
module dma_mem_wr # (
   parameter   MEM_AW      = 8 , // Memory Address Width
   parameter   MEM_DW      = 8 , // Memory Data Width
   parameter   DMA_DW      = 64  // DMA   Data Width
) (
   input    wire                 clk_i             ,
   input    wire                 rst_ni            ,
   input    wire                 dma_req_i         ,
   output   wire                 dma_ack_o         ,
   input    wire  [MEM_AW-1:0]   dma_addr_i        ,
   output   wire                 mem_en_o          ,
   output   wire                 mem_wr_o          ,
   output   wire  [MEM_AW-1:0]   mem_addr_o        ,
   output   wire  [MEM_DW-1:0]   mem_dt_o          ,
   output   wire                 s_axis_tready_o   ,
   input    wire                 s_axis_tvalid_i   ,
   input    wire  [DMA_DW-1:0]   s_axis_tdata_i    ,
   input    wire                 s_axis_tlast_i    );

///// Signals
///////////////////////////////////////////////////////////////////////////////
reg  [MEM_AW-1:0] addr_cnt       ;
reg               addr_cnt_en, addr_cnt_load ;
reg  [MEM_DW-1:0] mem_dt_r    ;
reg  [MEM_AW-1:0] mem_addr_r  ;
reg               mem_en, mem_wr, mem_en_r, mem_wr_r ;
reg               dma_wr_ack;

assign last_wr_addr	= s_axis_tlast_i & s_axis_tvalid_i;

///// DMA STATE
///////////////////////////////////////////////////////////////////////////////
typedef enum { ST_IDLE, ST_INIT, ST_WR_MEM, ST_END } TYPE_DMA_WR_ST;
(* fsm_encoding = "one_hot" *) TYPE_DMA_WR_ST dma_wr_st;
TYPE_DMA_WR_ST dma_wr_st_nxt;

always_ff @ (posedge clk_i, negedge rst_ni) begin
   if    ( !rst_ni   )  dma_wr_st  <= ST_IDLE;
   else                 dma_wr_st  <= dma_wr_st_nxt;
end

always_comb begin
   dma_wr_st_nxt  = dma_wr_st;
   dma_wr_ack     = 1'b1;
   addr_cnt_en    = 1'b0; 
   addr_cnt_load  = 1'b0;   
   mem_wr         = 1'b0;
   mem_en         = 1'b0;
   case (dma_wr_st)
      ST_IDLE: begin
         dma_wr_ack     = 1'b0;
         if (dma_req_i) dma_wr_st_nxt = ST_INIT;
      end
      ST_INIT: begin
         addr_cnt_load  = 1'b1;   
         dma_wr_st_nxt  = ST_WR_MEM;
      end
      ST_WR_MEM: begin
         addr_cnt_en    = s_axis_tvalid_i;   
         mem_wr         = s_axis_tvalid_i;
         mem_en         = 1'b1;
         if (last_wr_addr ) 
            dma_wr_st_nxt = ST_END;
      end
      ST_END : begin
         if (!dma_req_i)   dma_wr_st_nxt = ST_IDLE;
      end
      
   endcase
end

always_ff @(posedge clk_i) begin
	if (~rst_ni) begin
		addr_cnt	   <= 0;
		mem_addr_r	<= 0;
		mem_dt_r		<= 0;
		mem_wr_r		<= 0;
	end else begin
		if (addr_cnt_load)
			addr_cnt	<= dma_addr_i;
		else if (addr_cnt_en)
			addr_cnt	<= addr_cnt + 1;

		mem_addr_r	<= addr_cnt;
		mem_dt_r		<= s_axis_tdata_i[MEM_DW-1:0];
		mem_wr_r	   <= mem_wr;
		mem_en_r	   <= mem_en;
	end
end 

// Assign outputs.
assign mem_en_o         = mem_en_r       ;
assign mem_addr_o       = mem_addr_r	;
assign mem_dt_o         = mem_dt_r	   ;
assign mem_wr_o         = mem_wr_r     ;
assign s_axis_tready_o  = 1'b1    ;
assign dma_ack_o        = dma_wr_ack   ;

endmodule


///////////////////////////////////////////////////////////////////////////////
// DMA READ
///////////////////////////////////////////////////////////////////////////////
// THe DMA LENGHT SHOULD BE LARGER THAN THE LATENCY
module dma_mem_rd # (
   parameter   MEM_AW      = 16  ,  // Memory Address Width
   parameter   MEM_DW      = 8   ,  // Memory Data Width
   parameter   MEM_LATENCY = 3   ,  // Memory Pipeline Latency
   parameter   DMA_DW      = 8      // DMA   Data Width
) (
   input    wire                 clk_i             ,
   input    wire                 rst_ni            ,
   input    wire                 dma_req_i         ,
   output   wire                 dma_ack_o         ,
   input    wire  [MEM_AW-1:0]   dma_addr_i        ,
   input    wire  [MEM_AW-1:0]   dma_len_i         ,
   output   wire  [MEM_AW-1:0]   mem_addr_o        ,
   output   wire                 mem_en_o          ,
   input    wire  [MEM_DW-1:0]   mem_dt_i          ,
   input    wire                 m_axis_tready_i   ,
   output   wire  [DMA_DW-1:0]   m_axis_tdata_o    ,
   output   wire                 m_axis_tvalid_o   ,
   output   wire                 m_axis_tlast_o    );


///// Signals
///////////////////////////////////////////////////////////////////////////////

reg  [MEM_AW-1:0] addr_cnt    ;
reg               addr_cnt_rst;
reg  [MEM_AW-1:0] len_cnt     ;
wire [MEM_AW-1:0] len_cnt_p1;
reg  [       3:0] mem_pipe_cnt;
reg               dma_rd_ack  ;

reg            pipe_tx_in_waiting, transmitting , pipe_tx_out_waiting ;


assign mem_en           = (pipe_tx_in_waiting | transmitting) & m_axis_tready_i ;
assign addr_cnt_en      =  mem_en & !pipe_tx_out_waiting ;
assign mem_pipe_cnt_en  = (pipe_tx_in_waiting | pipe_tx_out_waiting) & m_axis_tready_i ;
assign mem_pipe_last    = (MEM_LATENCY-1 == mem_pipe_cnt ) ;
assign mem_pipe_cnt_rst =  mem_pipe_last  & ( pipe_tx_in_waiting | pipe_tx_out_waiting) & m_axis_tready_i ;
assign len_cnt_last     = (len_cnt_p1 == dma_len_i) & m_axis_tready_i;
assign last_rd_addr     =  m_axis_tready_i & mem_pipe_last &  pipe_tx_out_waiting;


///// DMA STATE
///////////////////////////////////////////////////////////////////////////////
typedef enum { ST_IDLE, ST_TX_PIPE_IN, ST_TXING, ST_TX_PIPE_OUT, ST_END } TYPE_DMA_RD_ST;
(* fsm_encoding = "one_hot" *) TYPE_DMA_RD_ST dma_rd_st;
TYPE_DMA_RD_ST dma_rd_st_nxt;

always_ff @ (posedge clk_i, negedge rst_ni) begin
   if    ( !rst_ni   )  dma_rd_st  <= ST_IDLE;
   else                 dma_rd_st  <= dma_rd_st_nxt;
end

always_comb begin
   dma_rd_st_nxt        = dma_rd_st;
   dma_rd_ack           = 1'b1;
   addr_cnt_rst         = 1'b0; 
   pipe_tx_in_waiting   = 1'b0;
   pipe_tx_out_waiting  = 1'b0;
   transmitting         = 1'b0;
   case (dma_rd_st)
      ST_IDLE: begin
         dma_rd_ack     = 1'b0;
         addr_cnt_rst   = 1'b1; 
         if (dma_req_i) dma_rd_st_nxt = ST_TX_PIPE_IN;
      end
      ST_TX_PIPE_IN : begin
         pipe_tx_in_waiting   = 1'b1;
         if       ( mem_pipe_cnt_rst ) dma_rd_st_nxt = ST_TXING;
         else if  ( len_cnt_last     ) dma_rd_st_nxt = ST_END; // LENGHT IS SMALLER THAN PIPE
      end
      ST_TXING : begin
         transmitting = 1'b1;
         if (len_cnt_last)      dma_rd_st_nxt = ST_TX_PIPE_OUT;
      end
      ST_TX_PIPE_OUT : begin
         transmitting = 1'b1;
         pipe_tx_out_waiting  = 1'b1;
         if (last_rd_addr)   dma_rd_st_nxt = ST_IDLE;
      end
      ST_END : begin
         if (!dma_req_i)   dma_rd_st_nxt = ST_IDLE;
      end
   endcase
end

assign len_cnt_p1 = len_cnt + 1'b1;

always_ff @ (posedge clk_i, negedge rst_ni) begin
   if    ( !rst_ni   ) begin
      len_cnt        <= 0;
      addr_cnt       <= 0;
      mem_pipe_cnt   <= 0; 
   end else begin
      if ( addr_cnt_rst ) begin
         len_cnt        <= 0;
         addr_cnt       <= dma_addr_i;
      end else if ( addr_cnt_en ) begin
         len_cnt  = len_cnt_p1;
         addr_cnt = addr_cnt + 1'b1;
      end
      if  ( mem_pipe_cnt_rst ) begin
         mem_pipe_cnt   <= 0; 
      end else if  ( mem_pipe_cnt_en ) begin
         mem_pipe_cnt   <= mem_pipe_cnt + 1'b1;
      end
   end
end

// Assign outputs.
localparam ZFD = DMA_DW - MEM_DW; // Zero Fill for DMA

assign mem_en_o         = mem_en       ;
assign mem_addr_o       = addr_cnt		;
assign m_axis_tvalid_o  = transmitting	;
//assign m_axis_tdata_o   = { {ZFD{1'b0}} , mem_dt_i };
assign m_axis_tdata_o   = mem_dt_i;
assign m_axis_tlast_o   = last_rd_addr ;
assign dma_ack_o        = dma_rd_ack   ;
endmodule

