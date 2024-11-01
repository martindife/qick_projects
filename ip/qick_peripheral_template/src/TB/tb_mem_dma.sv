///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : mdife
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

`define T_C_CLK         3 // 1.66 // Half Clock Period for Simulation
`define T_PS_CLK        10  // Half Clock Period for Simulation


module tb_mem_dma();


localparam AW = 8 ;
localparam DW = 32 ;


// Signals
reg c_clk, ps_clk;
reg rst_ni;
reg[31:0]       data_wr     = 32'h12345678;

//////////////////////////////////////////////////////////////////////////
//  CLK Generation
initial begin
  c_clk = 1'b0;
  forever # (`T_C_CLK) c_clk = ~c_clk;
end
initial begin
  ps_clk = 1'b0;
  forever # (`T_PS_CLK) ps_clk = ~ps_clk;
end

reg ready;
initial begin
  ready = 1'b0;
  forever # (6*`T_PS_CLK) ready = ~ready;
end
reg   mem_en_i      ;
reg   mem_wr_i      ;
reg   [AW-1:0]  mem_addr_i ;
reg  [DW-1:0]  mem_w_dt_i ;
wire [DW-1:0]  bmem_r_dt_o, umem_r_dt_o ;
   
mem_dma_test #(
   .AW ( AW ) ,
   .DW ( DW )
) DUT_MEM_DMA (
   .ps_clk ( ps_clk ) ,
   .rst_ni ( rst_ni ) ,
   .mem_en_i ( mem_en_i ) ,
   .mem_wr_i ( mem_wr_i ) ,
   .mem_addr_i ( mem_addr_i ) ,
   .mem_w_dt_i ( mem_w_dt_i ) ,
   .bmem_r_dt_o ( bmem_r_dt_o ) ,
   .umem_r_dt_o ( umem_r_dt_o ) ,

   .bdma_rd_req ( bdma_rd_req ) ,
   .bdma_rd_ack ( bdma_rd_ack ) ,
   .bdma_r_addr ( bdma_r_addr ) ,
   .bdma_r_len  ( bdma_r_len  ) ,
   .bdma_wr_req ( bdma_wr_req ) ,
   .bdma_wr_ack ( bdma_wr_ack ) ,
   .bdma_w_addr ( bdma_w_addr ) ,
   .udma_rd_req ( udma_rd_req ) ,
   .udma_rd_ack ( udma_rd_ack ) ,
   .udma_r_addr ( udma_r_addr ) ,
   .udma_r_len  ( udma_r_len  ) ,
   .udma_wr_req ( udma_wr_req ) ,
   .udma_wr_ack ( udma_wr_ack ) ,
   .udma_w_addr ( udma_w_addr ) );


reg            bdma_rd_req ;
reg   [AW-1:0] bdma_r_addr, bdma_r_len;
reg            bdma_wr_req ;
reg   [AW-1:0] bdma_w_addr;
reg            udma_wr_req ;
reg   [AW-1:0] udma_w_addr;
reg            udma_rd_req ;
reg   [AW-1:0] udma_r_addr, udma_r_len;

initial begin
   START_SIMULATION();
   // TEST_AXI () ;
   TEST_DMA () ;
   
end

integer cnt;


task START_SIMULATION (); begin
   $display("START SIMULATION");
   for ( cnt = 0 ; cnt  < 256; cnt=cnt+1) begin
      DUT_MEM_DMA.BRAM.mem[cnt] = cnt;
      DUT_MEM_DMA.URAM.mem[cnt] = cnt;
   end

   rst_ni   = 1'b0;

   mem_en_i      =0;
   mem_wr_i     =0;
   mem_addr_i =0;
   mem_w_dt_i   =0;

      // DMA DATA
   bdma_r_addr = 0;
   bdma_r_len  = 10;

   udma_w_addr = 10;

   udma_r_addr = 10;
   udma_r_len  = 10;

   bdma_w_addr = 20;

   bdma_rd_req = 0;
   udma_wr_req = 0;
   udma_rd_req = 0;
   bdma_wr_req = 0;

   @ (posedge ps_clk); #0.1;
   rst_ni            = 1'b1;

   end
endtask

task TEST_DMA (); begin
   $display("-----DMA");
   @ (posedge ps_clk); #0.1;

   bdma_rd_req = 1;
   udma_wr_req = 1;

   wait (udma_wr_ack)
   @ (posedge ps_clk); #0.1;
   udma_wr_req = 0;

   wait (bdma_rd_ack)
   @ (posedge ps_clk); #0.1;
   bdma_rd_req = 0;


   wait (!bdma_rd_ack)
   @ (posedge ps_clk); #0.1;
   udma_rd_req = 1;
   bdma_wr_req = 1;  

   wait (udma_wr_ack)
   @ (posedge ps_clk); #0.1;
   udma_rd_req = 0;
   bdma_wr_req = 0;  


   wait (!udma_wr_ack)
   @ (posedge ps_clk); #0.1;

   
end
endtask


endmodule




