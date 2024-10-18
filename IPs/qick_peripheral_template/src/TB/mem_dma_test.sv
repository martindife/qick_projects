///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : mdife
///////////////////////////////////////////////////////////////////////////////

module mem_dma_test # (
   parameter DW = 144,
   parameter AW = 12
) (
   input    wire           ps_clk         ,
   input    wire           rst_ni         ,
   input    wire           mem_en_i       ,
   input    wire           mem_wr_i       ,
   input    wire [AW-1:0]  mem_addr_i     ,
   input    wire [DW-1:0]  mem_w_dt_i     ,
   output   wire [DW-1:0]  bmem_r_dt_o    ,
   output   wire [DW-1:0]  umem_r_dt_o    ,
   input    wire           bdma_rd_req    ,
   output   wire           bdma_rd_ack    ,
   input    wire [AW-1:0]  bdma_r_addr    ,
   input    wire [AW-1:0]  bdma_r_len     ,
   input    wire           bdma_wr_req    ,
   output   wire           bdma_wr_ack    ,
   input    wire [AW-1:0]  bdma_w_addr    ,
   input    wire           udma_rd_req    ,
   output   wire           udma_rd_ack    ,
   input    wire [AW-1:0]  udma_r_addr    ,
   input    wire [AW-1:0]  udma_r_len     ,
   input    wire           udma_wr_req    ,
   output   wire           udma_wr_ack    ,
   input    wire [AW-1:0]  udma_w_addr    ,
   output   wire [DW-1:0]  m_axis_tdata_ob    ,
   output   wire           m_axis_tvalid_ob   ,
   output   wire           m_axis_tlast_ob    ,   
   output   wire [DW-1:0]  m_axis_tdata_ou    ,
   output   wire           m_axis_tvalid_ou   ,
   output   wire           m_axis_tlast_ou    );   



wire  [AW-1:0]    bmem_w_addr, bmem_r_addr, umem_w_addr, umem_r_addr ;
wire  [DW-1:0]    bmem_w_dt,  umem_w_dt;

wire [AW-1:0] bmem_b_addr;
wire [DW-1:0] bmem_r_dt, umem_r_dt;

BRAM_DP_DC # ( 
   .MEM_AW     ( AW ) , 
   .MEM_DW     ( DW ) ,
   .RAM_OUT    ( "REGISTERED" ) // Select "NO_REGISTERED" or "REGISTERED" 
) BRAM ( 
   .clk_a_i    ( ps_clk       ) ,
   .en_a_i     ( mem_en_i     ) ,
   .we_a_i     ( mem_wr_i     ) ,
   .addr_a_i   ( mem_addr_i   ) ,
   .dt_a_i     ( mem_w_dt_i   ) ,
   .dt_a_o     ( bmem_r_dt_o  ) ,
   .clk_b_i    ( ps_clk       ) ,
   .en_b_i     ( bmem_w_en | bmem_r_en ) ,
   .we_b_i     ( bmem_w_wr    ) ,
   .addr_b_i   ( bmem_b_addr  ) ,
   .dt_b_i     ( bmem_w_dt    ) ,
   .dt_b_o     ( bmem_r_dt    ) );

// DMA
assign bmem_b_addr = bmem_w_wr ? bmem_w_addr  : bmem_r_addr ;
   
dma_mem_rd # (
   .AW ( AW ) , // Address map of each memory.
   .DW ( DW ) ,  // Data width.
   .LATENCY ( 1 )   // Data width.
) BRAM_DMA_RD (
   .clk_i           ( ps_clk           ) ,
   .rst_ni          ( rst_ni           ) ,
   .dma_req_i       ( bdma_rd_req      ) ,
   .dma_ack_o       ( bdma_rd_ack      ) ,
   .dma_addr_i      ( bdma_r_addr      ) ,
   .dma_len_i       ( bdma_r_len       ) ,
   .mem_addr_o      ( bmem_r_addr      ) ,
   .mem_en_o        ( bmem_r_en        ) ,
   .mem_dt_i        ( bmem_r_dt        ) ,
   .m_axis_tvalid_o ( m_axis_tvalid_ob )  ,
   .m_axis_tready_i ( m_axis_tready_ib )  ,
   .m_axis_tdata_o  ( m_axis_tdata_ob  )  ,
   .m_axis_tlast_o  ( m_axis_tlast_ob  ) );   
dma_mem_wr # (
   .AW      ( AW )  , // Address map of each memory.
   .DW      ( DW )    // Data width.
) BRAM_DMA_WR (
   .clk_i            ( ps_clk           ) ,
   .rst_ni           ( rst_ni           ) ,
   .dma_req_i        ( bdma_wr_req      ) ,
   .dma_ack_o        ( bdma_wr_ack      ) ,
   .dma_addr_i       ( bdma_w_addr      ) ,
   .mem_addr_o       ( bmem_w_addr      ) ,
   .mem_dt_o         ( bmem_w_dt        ) ,
   .mem_en_o         ( bmem_w_en        ) ,
   .mem_wr_o         ( bmem_w_wr        ) ,
   .s_axis_tready_o  ( m_axis_tready_iu  ) ,
   .s_axis_tvalid_i  ( m_axis_tvalid_ou ) ,
   .s_axis_tdata_i   ( m_axis_tdata_ou  ) ,
   .s_axis_tlast_i   ( m_axis_tlast_ou  ) );


///////////////////////////////////////////////////////////////////////////////
// URAM
///////////////////////////////////////////////////////////////////////////////
wire [AW-1:0] umem_b_addr;
   
URAM_DP_SC #(
   .MEM_AW        ( AW ) ,    // Address Width
   .MEM_DW        ( DW ) ,    // Data Width
   .MEM_LATENCY   ( 5 )      // Number of pipeline Registers
) URAM (
   .clk_i      ( ps_clk       ) ,
   .rst_ni     ( rst_ni       ) ,
   .en_a_i     ( mem_en_i     ) ,
   .we_a_i     ( mem_wr_i     ) ,
   .addr_a_i   ( mem_addr_i   ) ,
   .dt_a_i     ( mem_w_dt_i   ) ,
   .dt_a_o     ( umem_r_dt_o  ) ,
   .en_b_i     ( umem_w_en |  umem_r_en ) ,
   .we_b_i     ( umem_w_wr    ) ,
   .addr_b_i   ( umem_b_addr  ) ,
   .dt_b_i     ( umem_w_dt    ) ,
   .dt_b_o     ( umem_r_dt    ) );
dma_mem_rd # (
   .AW ( AW ) , // Address map of each memory.
   .DW ( DW ) ,  // Data width.
   .LATENCY ( 5 )   // Data width.
) URAM_DMA_RD (
   .clk_i           ( ps_clk           ) ,
   .rst_ni          ( rst_ni           ) ,
   .dma_req_i       ( udma_rd_req      ) ,
   .dma_ack_o       ( udma_rd_ack      ) ,
   .dma_addr_i      ( udma_r_addr      ) ,
   .dma_len_i       ( udma_r_len       ) ,
   .mem_addr_o      ( umem_r_addr      ) ,
   .mem_en_o        ( umem_r_en        ) ,
   .mem_dt_i        ( umem_r_dt        ) ,
   .m_axis_tvalid_o ( m_axis_tvalid_ou ) ,
   .m_axis_tready_i ( m_axis_tready_iu ) ,
   .m_axis_tdata_o  ( m_axis_tdata_ou  ) ,
   .m_axis_tlast_o  ( m_axis_tlast_ou  ) );
dma_mem_wr # (
   .AW      ( AW )  , // Address map of each memory.
   .DW      ( DW )    // Data width.
) URAM_DMA_WR (
   .clk_i            ( ps_clk           ) ,
   .rst_ni           ( rst_ni           ) ,
   .dma_req_i        ( udma_wr_req      ) ,
   .dma_ack_o        ( udma_wr_ack      ) ,
   .dma_addr_i       ( udma_w_addr      ) ,
   .mem_addr_o       ( umem_w_addr      ) ,
   .mem_dt_o         ( umem_w_dt        ) ,
   .mem_en_o         ( umem_w_en        ) ,
   .mem_wr_o         ( umem_w_wr        ) ,
   .s_axis_tready_o  ( m_axis_tready_ib ) ,
   .s_axis_tvalid_i  ( m_axis_tvalid_ob ) ,
   .s_axis_tdata_i   ( m_axis_tdata_ob  ) ,
   .s_axis_tlast_i   ( m_axis_tlast_ob  ) );

// DMA
assign umem_b_addr = umem_w_wr ? umem_w_addr  : umem_r_addr ;


reg [7:0] mem_r_dt;
// Register TEST
always_ff @ (posedge ps_clk, negedge rst_ni) begin
   if    ( !rst_ni   )  
      mem_r_dt  <= 0;
   else if (m_axis_tvalid_ou & m_axis_tready_iu)
      mem_r_dt  <= m_axis_tdata_ou;
end


endmodule




