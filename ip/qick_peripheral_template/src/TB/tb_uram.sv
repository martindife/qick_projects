///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : mdife
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

`define T_CLK         3 

module tb_uram();

localparam AW      = 8  ;
localparam DW      = 32 ;
localparam LATENCY = 5  ;

//////////////////////////////////////////////////////////////////////////
//  CLK Generation
reg clk_i;
reg rst_ni;
initial begin
  clk_i = 1'b0;
  forever # (`T_CLK) clk_i = ~clk_i;
end

reg            mem_en_i      ;
reg            mem_wr_i      ;
reg  [AW-1:0]  mem_w_addr_i, mem_r_addr_i ;
reg  [DW-1:0]  mem_w_dt_i ;
wire [DW-1:0]  mem_r_dt_1, mem_r_dt_2 ;
wire [DW-1:0]  mem_r_dt_3, mem_r_dt_4, mem_r_dt_5, mem_r_dt_6 ;
   
URAM_SC #(
   .MEM_AW        ( AW ) ,    // Address Width
   .MEM_DW        ( DW ) ,    // Data Width
   .MEM_LATENCY   ( LATENCY )      // Number of pipeline Registers
) URAM_SC (
   .clk_i      ( clk_i         ) ,
   .rst_ni     ( rst_ni        ) ,
   .we_i       ( mem_wr_i      ) ,
   .w_addr_i   ( mem_w_addr_i  ) ,
   .w_data_i   ( mem_w_dt_i    ) ,
   .r_addr_i   ( mem_r_addr_i  ) ,
   .r_data_o   ( mem_r_dt_1    ) );

URAM_SC_EN #(
   .MEM_AW        ( AW ) ,    // Address Width
   .MEM_DW        ( DW ) ,    // Data Width
   .MEM_LATENCY   ( LATENCY )      // Number of pipeline Registers
) URAM_SC_EN (
   .clk_i      ( clk_i       ) ,
   .rst_ni     ( rst_ni       ) ,
   .en_i       ( mem_en_i     ) ,
   .we_i       ( mem_wr_i     ) ,
   .w_addr_i   ( mem_w_addr_i  ) ,
   .w_data_i   ( mem_w_dt_i    ) ,
   .r_addr_i   ( mem_r_addr_i  ) ,
   .r_data_o   ( mem_r_dt_2    ) );


URAM_SC_DP #(
   .MEM_AW        ( AW ) ,    // Address Width
   .MEM_DW        ( DW ) ,    // Data Width
   .MEM_LATENCY   ( LATENCY )      // Number of pipeline Registers
) URAM_SC_DP (
   .clk_i      ( clk_i        ) ,
   .rst_ni     ( rst_ni       ) ,
   .we_a_i     ( mem_wr_i     ) ,
   .addr_a_i   ( mem_w_addr_i   ) ,
   .dt_a_i     ( mem_w_dt_i   ) ,
   .dt_a_o     ( mem_r_dt_3   ) ,
   .we_b_i     ( 0     ) ,
   .addr_b_i   ( mem_r_addr_i   ) ,
   .dt_b_i     ( mem_w_dt_i   ) ,
   .dt_b_o     ( mem_r_dt_4   ) );

URAM_SC_DP_EN #(
   .MEM_AW        ( AW ) ,    // Address Width
   .MEM_DW        ( DW ) ,    // Data Width
   .MEM_LATENCY   ( LATENCY )      // Number of pipeline Registers
) URAM_SC_DP_EN (
   .clk_i      ( clk_i        ) ,
   .rst_ni     ( rst_ni       ) ,
   .en_a_i     ( mem_en_i     ) ,
   .we_a_i     ( mem_wr_i     ) ,
   .addr_a_i   ( mem_w_addr_i   ) ,
   .dt_a_i     ( mem_w_dt_i   ) ,
   .dt_a_o     ( mem_r_dt_5   ) ,
   .en_b_i     ( mem_en_i     ) ,
   .we_b_i     ( 0     ) ,
   .addr_b_i   ( mem_r_addr_i   ) ,
   .dt_b_i     ( mem_w_dt_i   ) ,
   .dt_b_o     ( mem_r_dt_6   ) );


initial begin
   START_SIMULATION();
   TEST_MEM();
end

integer cnt;


task START_SIMULATION (); begin
   $display("START SIMULATION");
   for ( cnt = 0 ; cnt  < 256; cnt=cnt+1) begin
      URAM_SC.mem[cnt] = cnt;
      URAM_SC_EN.mem[cnt] = cnt;
      URAM_SC_DP.mem[cnt] = cnt;
      URAM_SC_DP_EN.mem[cnt] = cnt;
   end

   rst_ni   = 1'b0;

   mem_en_i    = 0 ;
   mem_wr_i    = 0 ;
   mem_w_addr_i  = 0 ;
   mem_w_dt_i  = 0 ;
   mem_r_addr_i  = 0 ;

   #50;
   @ (posedge clk_i); #0.1;
   rst_ni            = 1'b1;

   end
endtask

task TEST_MEM (); begin
   $display("-----Writting URAM MEMORY");
   mem_en_i  = 1'b1 ;
   for ( cnt = 0 ; cnt  < 16; cnt=cnt+1) begin
      @ (posedge clk_i); #0.1;
      mem_w_addr_i = cnt[DW-1:0]   ;
      mem_w_dt_i   = cnt[DW-1:0]+1 ;
   end

   @ (posedge clk_i); #0.1;
   mem_en_i  = 1'b0 ;
   mem_r_addr_i = 5;
   #  (LATENCY*2*`T_CLK)  
   @ (posedge clk_i); #0.1;
   mem_en_i  = 1'b1 ;

   $display("-----Reading ");
   for ( cnt = 0 ; cnt  < 16; cnt=cnt+1) begin
      @ (posedge clk_i); #0.1;
      mem_r_addr_i = cnt[DW-1:0];
   end

   @ (posedge clk_i); #0.1;
   mem_en_i  = 1'b0 ;
   mem_r_addr_i = 5;
   #  (LATENCY*2*`T_CLK)  
   @ (posedge clk_i); #0.1;

   $display("-----Reading 1");
   for ( cnt = 0 ; cnt  < 16; cnt=cnt+1) begin
      @ (posedge clk_i); #0.1;
      mem_en_i     = cnt[0] ;
      mem_r_addr_i = cnt[DW:1];
   end

   @ (posedge clk_i); #0.1;
   mem_en_i  = 1'b0 ;
   mem_r_addr_i = 5;
   #  (LATENCY*2*`T_CLK)  
   @ (posedge clk_i); #0.1;
   mem_en_i  = 1'b1 ;
   @ (posedge clk_i); #0.1;
   mem_en_i  = 1'b0 ;
   mem_r_addr_i = 6;
   #  (LATENCY*2*`T_CLK)  
   @ (posedge clk_i); #0.1;

   $display("-----Reading 1");
   for ( cnt = 0 ; cnt  < 16; cnt=cnt+1) begin
      @ (posedge clk_i); #0.1;
      mem_en_i     = ~cnt[0] ;
      mem_r_addr_i = cnt[DW:1];
   end

   $display("-----FINISHED ");
end
endtask

endmodule




