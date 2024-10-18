///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : mdife
//  Date           : 1-2024
//  Versión        : 2
///////////////////////////////////////////////////////////////////////////////
/*
Description:  Memory User blocks

BRAM_DP_DC     : Bram memory, Dual Port, Dual Clock.
FIFO           : Signle Clock Fifo (First In First Out) 
LIFO           : Single Clock LIFO (Last In First Out)
BRAM_FIFO_DC   : Double clock FIFO implemented with BRAM
URAM_SC        : URAM Memory Single Clock, Read Port and Write Port, Without Enable
URAM_SC_DP     : URAM Memory Single Clock, Dual Port , without Enable
URAM_SC_EN     : URAM Memory Single Clock, Read Port and Write Port, With Enable
   -> When Input Disable, Output not change (dout is LATENCY enabled clocks out)
URAM_SC_DP_EN  : URAM Memory Single Clock, Dual Port , with Enable
   -> When Input Disable, Output change (dout is LATENCY clocks out)

///
Auxiliary modules
gcc         : Gray Code Counter (Used for clock domain change)
*/


//////////////////////////////////////////////////////////////////////////////
module BRAM_DP_DC # ( 
   parameter MEM_AW  = 16 , 
   parameter MEM_DW  = 16 ,
   parameter RAM_OUT = "NO_REG" // Select "NO_REG" or "REG" 
) ( 
   input  wire               clk_a_i   ,
   input  wire               en_a_i    ,
   input  wire               we_a_i    ,
   input  wire [MEM_AW-1:0]  addr_a_i  ,
   input  wire [MEM_DW-1:0]  dt_a_i    ,
   output wire [MEM_DW-1:0]  dt_a_o    ,
   input  wire               clk_b_i   ,
   input  wire               en_b_i    ,
   input  wire               we_b_i    ,
   input  wire [MEM_AW-1:0]  addr_b_i  ,
   input  wire [MEM_DW-1:0]  dt_b_i    ,
   output wire [MEM_DW-1:0]  dt_b_o    );

localparam RAM_SIZE = 2**MEM_AW ;
  
reg [MEM_DW-1:0] mem [RAM_SIZE];
reg [MEM_DW-1:0] mem_dt_a = {MEM_DW{1'b0}};
reg [MEM_DW-1:0] mem_dt_b = {MEM_DW{1'b0}};

always @(posedge clk_a_i)
   if (en_a_i) begin
      mem_dt_a <= mem[addr_a_i] ;
      if (we_a_i)
         mem[addr_a_i] <= dt_a_i;
   end
always @(posedge clk_b_i)
   if (en_b_i)
      if (we_b_i)
         mem[addr_b_i] <= dt_b_i;
      else
         mem_dt_b <= mem[addr_b_i] ;

generate
   if (RAM_OUT == "NO_REG") begin: no_output_register // 1 clock cycle read
      assign dt_a_o = mem_dt_a ;
      assign dt_b_o = mem_dt_b ;
   end else begin: output_register // 2 clock cycle read
      reg [MEM_DW-1:0] mem_dt_a_r = {MEM_DW{1'b0}};
      reg [MEM_DW-1:0] mem_dt_b_r = {MEM_DW{1'b0}};
      always @(posedge clk_a_i) if (en_a_i) mem_dt_a_r <= mem_dt_a;
      always @(posedge clk_b_i) if (en_b_i) mem_dt_b_r <= mem_dt_b;
      assign dt_a_o = mem_dt_a_r ;
      assign dt_b_o = mem_dt_b_r ;
   end
endgenerate

endmodule



//////////////////////////////////////////////////////////////////////////////
module FIFO # (
   parameter FIFO_DW = 16 , 
   parameter FIFO_AW = 8 
) ( 
   input  wire                clk_i    ,
   input  wire                rst_ni   ,
   input  wire                flush_i  ,
   input  wire                push     ,
   input  wire                pop      ,
   input  wire [FIFO_DW-1:0]  data_i   ,
   output wire [FIFO_DW-1:0]  data_o   ,
   output wire                empty_o  ,
   output wire                full_o   );

localparam FIFO_SIZE = 2**FIFO_AW ;

wire [FIFO_AW-1:0]   rd_ptr_p1, wr_ptr_p1;
reg  [FIFO_AW-1:0]   rd_ptr, wr_ptr;
reg  [FIFO_DW-1:0]   fifo_dt [FIFO_SIZE];

assign rd_ptr_p1 = rd_ptr + 1'b1 ;
assign wr_ptr_p1 = wr_ptr + 1'b1 ;

wire [FIFO_DW - 1:0] mem_dt;

// The wr_ptr point to the First Empty Value
// The rd_ptr point to the Last Written Value
wire empty, full;
assign empty   = (rd_ptr == wr_ptr) ;   
assign full    = (rd_ptr == wr_ptr_p1);

wire do_pop, do_push;
assign do_pop  = pop & !empty;
assign do_push = push & !full;

// Pointers
always_ff @(posedge clk_i) begin
   if (!rst_ni | flush_i) begin
      rd_ptr <= 0;
      wr_ptr <= 0;
   end else  begin
      if ( do_push ) wr_ptr <= wr_ptr_p1;
      if ( do_pop  ) rd_ptr <= rd_ptr_p1;
   end
end

// Register
always_ff @(posedge clk_i) begin
   if (!rst_ni)   
      fifo_dt       <= '{default:'0} ;
   else if (do_push )
      fifo_dt[wr_ptr] <= data_i ;
end
   
assign empty_o = empty ;
assign full_o  = full;
assign data_o  = fifo_dt[rd_ptr];

endmodule


//////////////////////////////////////////////////////////////////////////////
module LIFO # (
   parameter FIFO_DW    = 16 , 
   parameter FIFO_DEPTH = 8    // MAX 256
) ( 
   input  wire                clk_i   ,
   input  wire                rst_ni  ,
   input  wire [FIFO_DW-1:0]  data_i  ,
   input  wire                push    ,
   input  wire                pop     ,
   output wire [FIFO_DW-1:0]  data_o  ,
   output wire                empty_o ,
   output wire                full_o  );

wire [7:0]           ptr_p1, ptr_m1 ;
reg  [7:0]           ptr            ;
reg  [FIFO_DW-1:0]   stack [FIFO_DEPTH]  ;

assign ptr_p1 = ptr + 1'b1;
assign ptr_m1 = ptr - 1'b1;

// Pointer
always_ff @(posedge clk_i) begin
   if       ( !rst_ni)           ptr <= 0;
   else if  ( push & !full_o )   ptr <= ptr_p1;
   else if  ( pop  & !empty_o)   ptr <= ptr_m1;
end

// Data
always_ff @(posedge clk_i) begin
   if ( !rst_ni )          stack      <= '{default:'0} ;
   if ( push & !full_o)    stack[ptr] <= data_i ;
end

assign empty_o = !(|ptr)      ;
assign full_o  = (ptr == FIFO_DEPTH) ; // !(|(ptr ^ FIFO_DEPTH));
assign data_o  = stack[ptr_m1];

endmodule

//GRAY CODE COUNTER
//////////////////////////////////////////////////////////////////////////////
module gcc # (
   parameter DW  = 32
)(
   input  wire          clk_i          ,
   input  wire          rst_ni         ,
   input  wire          async_clear_i  ,
   output wire          clear_o  ,
   input  wire          cnt_en_i       ,
   output wire [DW-1:0] count_bin_o    , 
   output wire [DW-1:0] count_gray_o   ,
   output wire [DW-1:0] count_bin_p1_o , 
   output wire [DW-1:0] count_gray_p1_o);
   
reg [DW-1:0] count_bin  ;    // count turned into binary number
wire [DW-1:0] count_bin_p1; // count_bin+1

reg [DW-1:0] count_bin_r, count_gray_r;

integer ind;
always_comb begin
   count_bin[DW-1] = count_gray_r[DW-1];
   for (ind=DW-2 ; ind>=0; ind=ind-1) begin
      count_bin[ind] = count_bin[ind+1]^count_gray_r[ind];
   end
end

reg clear_rcd, clear_r;
always_ff @(posedge clk_i, negedge rst_ni)
   if(!rst_ni) begin
      clear_rcd       <= 0;
      clear_r         <= 0;
   end else begin
      clear_rcd       <= async_clear_i;
      clear_r         <= clear_rcd;
   end
   
assign count_bin_p1 = count_bin + 1 ; 

reg [DW-1:0] count_bin_2r, count_gray_2r;
always_ff @(posedge clk_i, negedge rst_ni)
   if(!rst_ni) begin
      count_gray_r      <= 1;
      count_bin_r       <= 1;
      count_gray_2r     <= 0;
      count_bin_2r      <= 0;
   end else begin
      if (clear_r) begin
         count_gray_r      <= 1;
         count_bin_r       <= 1;
         count_gray_2r     <= 0;
         count_bin_2r      <= 0;
      end else if (cnt_en_i) begin
         count_gray_r   <= count_bin_p1 ^ {1'b0,count_bin_p1[DW-1:1]};
         count_bin_r    <= count_bin_p1;
         count_gray_2r  <= count_gray_r;
         count_bin_2r   <= count_bin_r;
      
      end
  end

assign clear_o          = clear_r ;
assign count_bin_o      = count_bin_2r ;
assign count_gray_o     = count_gray_2r ;
assign count_bin_p1_o   = count_bin_r ;
assign count_gray_p1_o  = count_gray_r ;

endmodule


//////////////////////////////////////////////////////////////////////////////
module BRAM_FIFO_DC # (
   parameter FIFO_DW = 16 , 
   parameter FIFO_AW = 8 
) ( 
   input  wire                   wr_clk_i    ,
   input  wire                   wr_rst_ni   ,
   input  wire                   wr_en_i     ,
   input  wire                   push_i      ,
   input  wire [FIFO_DW - 1:0]   data_i      ,
   input  wire                   rd_clk_i    ,
   input  wire                   rd_rst_ni   ,
   input  wire                   rd_en_i     ,
   input  wire                   pop_i       ,
   output wire  [FIFO_DW - 1:0]  data_o      ,
   input  wire                   flush_i     ,
   output wire                   async_empty_o  ,
   output wire                   async_full_o   );

// The WRITE_POINTER is on the Last Empty Value
// The READ_POINTER is on the Last Value
wire [FIFO_AW-1:0] rd_gptr_p1   ;
wire [FIFO_AW-1:0] wr_gptr_p1   ;
wire [FIFO_AW-1:0] rd_ptr, wr_ptr, rd_gptr, wr_gptr  ;
wire clr_wr, clr_rd;

// Sample Pointers
reg [FIFO_AW-1:0] wr_gptr_rcd, wr_gptr_r, wr_gptr_p1_rcd, wr_gptr_p1_r; 
always_ff @(posedge rd_clk_i) begin
   wr_gptr_rcd      <= wr_gptr;
   wr_gptr_r        <= wr_gptr_rcd;
   wr_gptr_p1_rcd   <= wr_gptr_p1;
   wr_gptr_p1_r     <= wr_gptr_p1_rcd;
end

reg [FIFO_AW-1:0] rd_gptr_rcd, rd_gptr_r; 
always_ff @(posedge wr_clk_i) begin
   rd_gptr_rcd      <= rd_gptr;
   rd_gptr_r        <= rd_gptr_rcd;
end

reg clr_fifo_req, clr_fifo_ack;
always_ff @(posedge wr_clk_i, negedge wr_rst_ni) begin
   if (!wr_rst_ni) begin
      clr_fifo_req <= 0 ;
      clr_fifo_ack <= 0 ;
   end else begin
      if (flush_i) 
         clr_fifo_req <= 1 ;
      else if (clr_fifo_ack )
         clr_fifo_req <= 0 ;

      if (clr_rd & clr_wr) 
          clr_fifo_ack <= 1 ;
      else if (clr_fifo_ack & !clr_rd & !clr_wr)
          clr_fifo_ack <= 0 ;
   end
end

wire busy;
assign busy = clr_fifo_ack | clr_fifo_req ;

wire [FIFO_DW - 1:0] mem_dt;

wire async_empty, async_full;

//SYNC with POP (RD_CLK)
assign async_empty   = (rd_gptr == wr_gptr_r) ;   

//SYNC with PUSH (WR_CLK)
assign async_full    = (rd_gptr_r == wr_gptr_p1) ;

wire do_pop, do_push;
assign do_pop  = pop_i & !async_empty;
assign do_push = push_i & !async_full;

assign async_empty_o = async_empty | busy; // While RESETTING, Shows EMPTY
assign async_full_o  = async_full  | busy;
assign data_o  = mem_dt;

//Gray Code Counters
gcc #(
   .DW	( FIFO_AW )
) gcc_wr_ptr  (
   .clk_i            ( wr_clk_i     ) ,
   .rst_ni           ( wr_rst_ni    ) ,
   .async_clear_i    ( clr_fifo_req ) ,
   .clear_o          ( clr_wr       ) ,
   .cnt_en_i         ( do_push      ) ,
   .count_bin_o      ( wr_ptr       ) ,
   .count_gray_o     ( wr_gptr      ) ,
   .count_bin_p1_o   (     ) ,
   .count_gray_p1_o  ( wr_gptr_p1   ) );

gcc #(
   .DW	( FIFO_AW )
) gcc_rd_ptr (
   .clk_i            ( rd_clk_i     ) ,
   .rst_ni           ( rd_rst_ni    ) ,
   .async_clear_i    ( clr_fifo_req ) ,
   .clear_o          ( clr_rd       ) ,
   .cnt_en_i         ( do_pop       ) ,
   .count_bin_o      ( rd_ptr       ) ,
   .count_gray_o     ( rd_gptr      ) ,
   .count_bin_p1_o   (     ) ,
   .count_gray_p1_o  ( rd_gptr_p1   ) );

// Data
bram_dual_port_dc  # (
   .MEM_AW  ( FIFO_AW     )  , 
   .MEM_DW  ( FIFO_DW     )  ,
   .RAM_OUT ( "NO_REG" ) // Select "NO_REG" or "REG" 
) fifo_mem ( 
   .clk_a_i    ( wr_clk_i  ) ,
   .en_a_i     ( wr_en_i   ) ,
   .we_a_i     ( do_push   ) ,
   .addr_a_i   ( wr_ptr    ) ,
   .dt_a_i     ( data_i    ) ,
   .dt_a_o     ( ) ,
   .clk_b_i    ( rd_clk_i  ) ,
   .en_b_i     ( rd_en_i   ) ,
   .we_b_i     ( 1'b0      ) ,
   .addr_b_i   ( rd_ptr    ) ,
   .dt_b_i     (     ) ,
   .dt_b_o     ( mem_dt    ) );
   
endmodule


//////////////////////////////////////////////////////////////////////////////
// URAM
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
module URAM_SC #(
   parameter   MEM_AW         = 16      ,    // Address Width
   parameter   MEM_DW         = 8       ,    // Data Width
   parameter   MEM_LATENCY    = 3            // Number of pipeline Registers
) (
   input  wire                clk_i     ,
   input  wire                rst_ni    ,
   input  wire                we_i      ,
   input  wire  [MEM_AW-1:0]  w_addr_i  ,
   input  wire  [MEM_DW-1:0]  w_data_i  ,
   input  wire  [MEM_AW-1:0]  r_addr_i  ,
   output reg   [MEM_DW-1:0]  r_data_o   );
   
localparam NBPIPE =     MEM_LATENCY -2;

(* ram_style = "ultra" *)
reg [MEM_DW-1:0] mem       [(1<<MEM_AW)]; // Memory Declaration
reg [MEM_DW-1:0] dt_pipe_r [NBPIPE]    ;  // Pipelines for memory
reg [MEM_DW-1:0] mem_dt_r  ;              // Register Output

integer          i;

// RAM Read / Write
always @ (posedge clk_i) begin
   if(we_i)
      mem[w_addr_i] <= w_data_i;
   else
      mem_dt_r <= mem[r_addr_i];
end

// RAM output pipeline.
always @ (posedge clk_i) begin
   dt_pipe_r[0] <= mem_dt_r;
   for (i = 0; i < NBPIPE-1; i = i+1)
      dt_pipe_r[i+1] <= dt_pipe_r[i];
   r_data_o <= dt_pipe_r[NBPIPE-1];
end

endmodule

//////////////////////////////////////////////////////////////////////////////
module URAM_SC_EN #(
   parameter       MEM_AW         = 16 , // Address Width
   parameter       MEM_DW         = 8  , // Data Width
   parameter       MEM_LATENCY    = 3    // Latency (Minimum 3)
) (
   input  wire                clk_i     ,
   input  wire                rst_ni    ,
   input  wire                en_i  ,
   input  wire                we_i      ,
   input  wire  [MEM_AW-1:0]  w_addr_i  ,
   input  wire  [MEM_DW-1:0]  w_data_i  ,
   input  wire  [MEM_AW-1:0]  r_addr_i  ,
   output wire  [MEM_DW-1:0]  r_data_o   );

localparam NBPIPE =     MEM_LATENCY-3;

(* ram_style = "ultra" *)
reg [MEM_DW-1:0]  mem           [(1<<MEM_AW)]; // Memory Declaration
reg [MEM_DW-1:0]  mem_dt_r;              
reg [MEM_DW-1:0]  mem_dt_pipe_r [ NBPIPE ];    // Pipelines for memory
//reg               mem_en_pipe_r [ NBPIPE+1];   // Pipelines for memory enable  
reg [ NBPIPE:0]             mem_en_pipe_r ;   // Pipelines for memory enable  
reg [MEM_DW-1:0]  r_data;
reg [MEM_DW-1:0]  mem_dt_out_pipe [ NBPIPE+2 ]; // Pipelines for OUT

integer           i;

// RAM : Both READ and WRITE have a latency of one
always @ (posedge clk_i) begin
 if(en_i) begin
   if(we_i)  mem[w_addr_i] <= w_data_i;
   mem_dt_r <= mem[r_addr_i];
  end
end

// The enable of the RAM goes through a pipeline to produce a
// series of pipelined enable signals required to control the data
// pipeline.
always @ (posedge clk_i) begin
   mem_en_pipe_r[0] <= en_i;
   for (i=0; i<NBPIPE; i=i+1)
      mem_en_pipe_r [i+1] <= mem_en_pipe_r[i];
end

// RAM output data goes through a pipeline.
always @ (posedge clk_i ) begin
   if ( mem_en_pipe_r [0]) mem_dt_pipe_r [0] <= mem_dt_r;
   for (i = 0; i < NBPIPE-1; i = i+1)
      if (mem_en_pipe_r[i+1])
         mem_dt_pipe_r [i+1] <= mem_dt_pipe_r[i];
end      

///////////////////////////////////////////////////////////////////////////////
// FIFO TO SYNC OUTPUT ENABLE 
wire [4:0] addr_cnt_p1, addr_cnt_m1 ; // Max 16 
reg [4:0] addr_out_cnt, addr_out_cnt_r, addr_out_cnt_nxt;
wire addr_up, addr_dn ;

assign mem_en_out = mem_en_pipe_r[NBPIPE];
// Pipeline
always @ (posedge clk_i ) begin
   if ( mem_en_pipe_r[NBPIPE] ) begin
      mem_dt_out_pipe [0] <= mem_dt_pipe_r [NBPIPE-1];
      for (i = 0; i < NBPIPE+1; i = i+1)
         mem_dt_out_pipe [i+1] <= mem_dt_out_pipe[i];
   end
end      

assign addr_up = !en_i  & mem_en_out & !addr_cnt_max;;
assign addr_dn = en_i &  !mem_en_out & !addr_cnt_min;
assign addr_cnt_p1 = addr_out_cnt + 1'b1;
assign addr_cnt_m1 = addr_out_cnt - 1'b1;
assign addr_cnt_min = (addr_out_cnt==0);
assign addr_cnt_max = (addr_out_cnt==NBPIPE+1);


always @ (posedge clk_i or negedge rst_ni) begin
   if (!rst_ni) begin
      addr_out_cnt <= NBPIPE+1;
      addr_out_cnt_r <= 0;
   end else begin
      if      ( addr_up )   addr_out_cnt  <= addr_cnt_p1; 
      else if ( addr_dn )   addr_out_cnt  <= addr_cnt_m1;
      addr_out_cnt_r <= addr_out_cnt;
   end
end

always @ (posedge clk_i) begin
   if (en_i) begin
      r_data <= mem_dt_out_pipe[addr_out_cnt];
      end
end 

assign r_data_o = r_data;

endmodule


//////////////////////////////////////////////////////////////////////////////




module URAM_SC_DP #(
   parameter   MEM_AW         = 16      ,    // Address Width
   parameter   MEM_DW         = 8       ,    // Data Width
   parameter   MEM_LATENCY    = 3            // Number of pipeline Registers
) (
   input  wire                clk_i    ,
   input  wire                rst_ni   ,
   input  wire                we_a_i   ,
   input  wire  [MEM_AW-1:0]  addr_a_i ,
   input  wire  [MEM_DW-1:0]  dt_a_i   ,
   output reg  [MEM_DW-1:0]  dt_a_o   ,
   input  wire                we_b_i   ,
   input  wire  [MEM_AW-1:0]  addr_b_i ,
   input  wire  [MEM_DW-1:0]  dt_b_i   ,
   output reg  [MEM_DW-1:0]  dt_b_o   );

localparam NBPIPE =     MEM_LATENCY -2;

(* ram_style = "ultra" *)
reg [MEM_DW-1:0] mem [(1<<MEM_AW)];        // Memory Declaration
reg [MEM_DW-1:0] mem_dt_a_r;              
reg [MEM_DW-1:0] dt_a_pipe_r[NBPIPE];    // Pipelines for memory
reg [MEM_DW-1:0] mem_dt_b_r;              
reg [MEM_DW-1:0] dt_b_pipe_r[NBPIPE];    // Pipelines for memory
integer          i;

// RAM : Both READ and WRITE have a latency of one
always @ (posedge clk_i)
begin
   if(we_a_i)
      mem[addr_a_i] <= dt_a_i;
   else
      mem_dt_a_r <= mem[addr_a_i];
end

// RAM output data goes through a pipeline.
always @ (posedge clk_i) begin
   dt_a_pipe_r[0] <= mem_dt_a_r;
   for (i = 0; i < NBPIPE-1; i = i+1)
      dt_a_pipe_r[i+1] <= dt_a_pipe_r[i];
   dt_a_o <= dt_a_pipe_r[NBPIPE-1];
end      
always @ (posedge clk_i)
begin
   if(we_b_i)
      mem[addr_b_i] <= dt_b_i;
   else
      mem_dt_b_r <= mem[addr_b_i];
end
// RAM output data goes through a pipeline.
always @ (posedge clk_i) begin
   dt_b_pipe_r[0] <= mem_dt_b_r;
   for (i = 0; i < NBPIPE-1; i = i+1)
      dt_b_pipe_r[i+1] <= dt_b_pipe_r[i];
   dt_b_o <= dt_b_pipe_r[NBPIPE-1];
end

endmodule









module URAM_SC_DP_EN #(
   parameter   MEM_AW         = 16      ,    // Address Width
   parameter   MEM_DW         = 8       ,    // Data Width
   parameter   MEM_LATENCY    = 3            // Number of pipeline Registers
) (
   input  wire                clk_i    ,
   input  wire                rst_ni   ,
   input  wire                en_a_i   ,
   input  wire                we_a_i   ,
   input  wire  [MEM_AW-1:0]  addr_a_i ,
   input  wire  [MEM_DW-1:0]  dt_a_i   ,
   output reg   [MEM_DW-1:0]  dt_a_o   ,
   input  wire                en_b_i   ,
   input  wire                we_b_i   ,
   input  wire  [MEM_AW-1:0]  addr_b_i ,
   input  wire  [MEM_DW-1:0]  dt_b_i   ,
   output reg   [MEM_DW-1:0]  dt_b_o   );

localparam NBPIPE =     MEM_LATENCY -2;

(* ram_style = "ultra" *)
reg [MEM_DW-1:0]  mem[(1<<MEM_AW)-1:0];     // Memory Declaration
reg [MEM_DW-1:0]  mem_dt_a_r;              
reg [MEM_DW-1:0]  dt_a_pipe_r [NBPIPE-1:0]; // Pipelines for memory
reg               en_a_pipe_r [NBPIPE:0]  ; // Pipelines for memory enable  
reg [MEM_DW-1:0]  mem_dt_b_r;              
reg [MEM_DW-1:0]  dt_b_pipe_r [NBPIPE-1:0]; // Pipelines for memory
reg               en_b_pipe_r [NBPIPE:0]  ; // Pipelines for memory enable  
integer          i;

// RAM : Both READ and WRITE have a latency of one
always @ (posedge clk_i) begin
   if(en_a_i) 
      if(we_a_i)
         mem[addr_a_i] <= dt_a_i;
      else
         mem_dt_a_r <= mem[addr_a_i];
end

// Enable Pipeline
always @ (posedge clk_i) begin
   en_a_pipe_r[0] <= en_a_i;
   for (i=0; i<NBPIPE; i=i+1)
      en_a_pipe_r[i+1] <= en_a_pipe_r[i];
end

// RAM Pipeline.
always @ (posedge clk_i) begin
   if (en_a_pipe_r[0])
      dt_a_pipe_r[0] <= mem_dt_a_r;
end    

always @ (posedge clk_i) begin
   for (i = 0; i < NBPIPE-1; i = i+1)
      if (en_a_pipe_r[i+1])
         dt_a_pipe_r[i+1] <= dt_a_pipe_r[i];
end      

always @ (posedge clk_i) begin
   if (en_a_pipe_r[NBPIPE])
      dt_a_o <= dt_a_pipe_r[NBPIPE-1];
end

always @ (posedge clk_i) begin
   if(en_b_i) 
      if(we_b_i)
         mem[addr_b_i] <= dt_b_i;
      else
         mem_dt_b_r <= mem[addr_b_i];
end

// Enable B pipeline
always @ (posedge clk_i) begin
   en_b_pipe_r[0] <= en_b_i;
   for (i=0; i<NBPIPE; i=i+1)
      en_b_pipe_r[i+1] <= en_b_pipe_r[i];
end

// RAM output data pipeline.
always @ (posedge clk_i) begin
   if (en_b_pipe_r[0])
      dt_b_pipe_r[0] <= mem_dt_b_r;
end    

always @ (posedge clk_i) begin
   for (i = 0; i < NBPIPE-1; i = i+1)
      if (en_b_pipe_r[i+1])
         dt_b_pipe_r[i+1] <= dt_b_pipe_r[i];
end      

always @ (posedge clk_i) begin
   if (en_b_pipe_r[NBPIPE])
      dt_b_o <= dt_b_pipe_r[NBPIPE-1];
end

endmodule