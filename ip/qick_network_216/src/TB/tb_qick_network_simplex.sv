///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : mdife
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

import axi_vip_pkg::*;
import axi_mst_0_pkg::*;

//`define T_TCLK         1.953125  // Half Clock Period for Simulation
`define T_TCLK         1.162574  // Half Clock Period for Simulation
`define T_CCLK         1.66 // Half Clock Period for Simulation
`define T_SCLK         5  // Half Clock Period for Simulation
`define T_ICLK         10  // Half Clock Period for Simulation
`define T_GTCLK         3.2  // Half Clock Period GT CLK 156.25

// 0 SIM_LEVEL -> NO SIMULATION > SYNTH
// 1 SIM_LEVEL -> SIMULATION NO AURORA
// 2 SIM_LEVEL -> SIMULATION YES AURORA

localparam SIM_LEVEL = 1;


module tb_qick_network_simplex ();

///////////////////////////////////////////////////////////////////////////////

// VIP Agent
axi_mst_0_mst_t 	axi_mst_0_agent;
xil_axi_prot_t  prot        = 0;


// Signals
reg   t_clk, c_clk, ps_clk, init_clk, gt_clk;
reg rst_ni, rst_ni_2, rst_ni_3;
reg[31:0]       data_wr     = 32'h12345678;
xil_axi_resp_t  resp;

//AXI-LITE
wire [7:0]             s_axi_awaddr , net_s_axi_awaddr , proc_s_axi_awaddr     ;
wire [2:0]             s_axi_awprot , net_s_axi_awprot , proc_s_axi_awprot     ;
wire                   s_axi_awvalid, net_s_axi_awvalid, proc_s_axi_awvalid    ;
wire                   s_axi_awready, net_s_axi_awready, proc_s_axi_awready    ;
wire [31:0]            s_axi_wdata  , net_s_axi_wdata  , proc_s_axi_wdata      ;
wire [3:0]             s_axi_wstrb  , net_s_axi_wstrb  , proc_s_axi_wstrb      ;
wire                   s_axi_wvalid , net_s_axi_wvalid , proc_s_axi_wvalid     ;
wire                   s_axi_wready , net_s_axi_wready , proc_s_axi_wready     ;
wire  [1:0]            s_axi_bresp  , net_s_axi_bresp  , proc_s_axi_bresp      ;
wire                   s_axi_bvalid , net_s_axi_bvalid , proc_s_axi_bvalid     ;
wire                   s_axi_bready , net_s_axi_bready , proc_s_axi_bready     ;
wire [7:0]             s_axi_araddr , net_s_axi_araddr , proc_s_axi_araddr     ;
wire [2:0]             s_axi_arprot , net_s_axi_arprot , proc_s_axi_arprot     ;
wire                   s_axi_arvalid, net_s_axi_arvalid, proc_s_axi_arvalid    ;
wire                   s_axi_arready, net_s_axi_arready, proc_s_axi_arready    ;
wire  [31:0]           s_axi_rdata  , net_s_axi_rdata  , proc_s_axi_rdata      ;
wire  [1:0]            s_axi_rresp  , net_s_axi_rresp  , proc_s_axi_rresp      ;
wire                   s_axi_rvalid , net_s_axi_rvalid , proc_s_axi_rvalid     ;
wire                   s_axi_rready , net_s_axi_rready , proc_s_axi_rready     ;

//////////////////////////////////////////////////////////////////////////
//  CLK Generation
initial begin
  t_clk = 1'b0;
  forever # (`T_TCLK) t_clk = ~t_clk;
end
initial begin
  c_clk = 1'b0;
  forever # (`T_CCLK) c_clk = ~c_clk;
end
initial begin
  ps_clk = 1'b0;
  forever # (`T_SCLK) ps_clk = ~ps_clk;
end
initial begin
  init_clk = 1'b0;
  forever # (`T_ICLK) init_clk = ~init_clk;
end
initial begin
  gt_clk = 1'b0;
  forever # (`T_GTCLK) gt_clk = ~gt_clk;
end

wire gt_refclk1_p, gt_refclk1_n;

assign gt_refclk1_p = gt_clk;
assign gt_refclk1_n = ~gt_clk;

reg ready;
integer cc;


reg sync_pulse;
initial begin
   sync_pulse = 1'b0;
   forever begin
      #100000 ;
      sync_pulse = 1'b1;
      #100 ;
      sync_pulse = 1'b0;
   end
end

initial begin
   cc = 8;
   forever begin
      ready = 1'b1;
      cc = cc+1;
      #500 ;
      if (cc == 10) begin
         ready = 1'b0;
         @ (posedge ps_clk);
         @ (posedge ps_clk);
         @ (posedge ps_clk);
         @ (posedge ps_clk);
         @ (posedge ps_clk);
         @ (posedge ps_clk);
         @ (posedge ps_clk);
         @ (posedge ps_clk);
         #1;
         ready = 1'b1;
         cc = 0;
      end 
      #500 ;
      ready = 1'b0;
      @ (posedge ps_clk);
      @ (posedge ps_clk);
      #1;
      end
end



wire                periph_en_o   ;
wire  [4 :0]        periph_op_o   ;
wire  [31:0]        periph_a_dt_o ;
wire  [31:0]        periph_b_dt_o ;
wire  [31:0]        periph_c_dt_o ;
wire  [31:0]        periph_d_dt_o ;
reg                periph_rdy_i=0    ;
reg  [31 :0]       periph_dt_i [2] ;

reg [31:0] axi_dt;
reg axi_dest;

// QNET > Register ADDRESS
parameter TNET_CTRL     = 0  * 4 ;
parameter TNET_CFG      = 1  * 4 ;
parameter TNET_ADDR     = 2  * 4 ;
parameter TNET_LEN      = 3  * 4 ;
parameter REG_AXI_DT1   = 4  * 4 ;
parameter REG_AXI_DT2   = 5  * 4 ;
parameter REG_AXI_DT3   = 6  * 4 ;
parameter NN            = 7  * 4 ;
parameter ID            = 8  * 4 ;
parameter CD            = 9  * 4 ;
parameter RTD           = 10  * 4 ;
parameter VERSION       = 11 * 4 ;
parameter TNET_W_DT1    = 12 * 4 ;
parameter TNET_W_DT2    = 13 * 4 ;
parameter TNET_STATUS   = 14 * 4 ;
parameter TNET_DEBUG    = 15 * 4 ;

reg    s0_axis_tvalid ,    s1_axis_tvalid ;
reg [15:0] waves, wtime;

reg         c_cmd_i  ;
reg [4 :0]  c_op_i;
reg [31:0]  c_dt_1_i, c_dt_2_i, c_dt_3_i ;


reg [47:0] t_time_abs1, t_time_abs2, t_time_abs3, t_time_abs4, t_time_abs5;

wire        time_rst_1  , time_rst_2  , time_rst_3  , time_rst_4  , time_rst_5  ;
wire        time_init_1 , time_init_2 , time_init_3 , time_init_4 , time_init_5 ;
wire        time_updt_1 , time_updt_2 , time_updt_3 , time_updt_4 , time_updt_5 ;
wire [31:0] time_off_dt_1   , time_off_dt_2   , time_off_dt_3   , time_off_dt_4   , time_off_dt_5   ;

wire ready_1;
reg  reset_i, start_i, stop_i, init_i;
reg time_updt_i;
wire [63:0] axi_tx_tdata_A_TX_1, axi_tx_tdata_A_TX_2, axi_tx_tdata_A_TX_3;
wire [63:0] axi_tx_tdata_B_TX_1, axi_tx_tdata_B_TX_2, axi_tx_tdata_B_TX_3;
wire txn_A_1, txn_A_2, txn_A_3;
wire txp_A_1, txp_A_2, txp_A_3;
wire txn_B_1, txn_B_2, txn_B_3;
wire txp_B_1, txp_B_2, txp_B_3;


axi_mst_0 axi_mst_0_i
	(
		.aclk			   (ps_clk		),
		.aresetn		   (rst_ni	),
		.m_axi_araddr	(s_axi_araddr	),
		.m_axi_arprot	(s_axi_arprot	),
		.m_axi_arready	(s_axi_arready	),
		.m_axi_arvalid	(s_axi_arvalid	),
		.m_axi_awaddr	(s_axi_awaddr	),
		.m_axi_awprot	(s_axi_awprot	),
		.m_axi_awready	(s_axi_awready	),
		.m_axi_awvalid	(s_axi_awvalid	),
		.m_axi_bready	(s_axi_bready	),
		.m_axi_bresp	(s_axi_bresp	),
		.m_axi_bvalid	(s_axi_bvalid	),
		.m_axi_rdata	(s_axi_rdata	),
		.m_axi_rready	(s_axi_rready	),
		.m_axi_rresp	(s_axi_rresp	),
		.m_axi_rvalid	(s_axi_rvalid	),
		.m_axi_wdata	(s_axi_wdata	),
		.m_axi_wready	(s_axi_wready	),
		.m_axi_wstrb	(s_axi_wstrb	),
		.m_axi_wvalid	(s_axi_wvalid	)
	);


reg [31:0] offset_t1_t2, offset_t1_t3, offset_t1_t4, offset_t1_t5;

   
//Simulate Core 2 and 3
always_ff @(posedge t_clk) 
   if (!rst_ni) begin
      t_time_abs1 <= ($random %1024)+1023;;
      t_time_abs2 <= ($random %1024)+1023;;
      t_time_abs3 <= ($random %1024)+1023;;
      t_time_abs4 <= ($random %1024)+1023;;
      t_time_abs5 <= ($random %1024)+1023;;
   end else begin 
      offset_t1_t2 = t_time_abs2 - t_time_abs1;
      offset_t1_t3 = t_time_abs3 - t_time_abs1;
      offset_t1_t4 = t_time_abs4 - t_time_abs1;
      offset_t1_t5 = t_time_abs5 - t_time_abs1;

      if       ( time_rst_1 )      t_time_abs1   <= 0;
      else if  ( time_init_1)      t_time_abs1   <= time_off_dt_1;
      else if  ( time_updt_1) t_time_abs1   <= t_time_abs1 + time_off_dt_1;
      else                    t_time_abs1   <= t_time_abs1 + 1'b1;

      if       ( time_rst_2 )      t_time_abs2   <= 0;
      else if  ( time_init_2)      t_time_abs2   <= time_off_dt_2;
      else if  ( time_updt_2) t_time_abs2   <= t_time_abs2 + time_off_dt_2;
      else                    t_time_abs2   <= t_time_abs2 + 1'b1;

      if       ( time_rst_3)      t_time_abs3   <= 0;
      else if  ( time_init_3)      t_time_abs3   <= time_off_dt_3;
      else if  ( time_updt_3) t_time_abs3   <= t_time_abs3 + time_off_dt_3;
      else                    t_time_abs3   <= t_time_abs3 + 1'b1;

      if       ( time_rst_4)      t_time_abs4   <= 0;
      else if  ( time_init_4)      t_time_abs4   <= time_off_dt_4;
      else if  ( time_updt_4) t_time_abs4   <= t_time_abs4 + time_off_dt_4;
      else                    t_time_abs4   <= t_time_abs4 + 1'b1;

      if       ( time_rst_5)      t_time_abs5   <= 0;
      else if  ( time_init_5)      t_time_abs5   <= time_off_dt_5;
      else if  ( time_updt_5) t_time_abs5   <= t_time_abs5 + time_off_dt_5;
      else                    t_time_abs5   <= t_time_abs5 + 1'b1;
   end




assign proc_s_axi_awaddr       = axi_dest ? 0 : s_axi_awaddr   ;
assign proc_s_axi_awprot       = axi_dest ? 0 : s_axi_awprot   ;
assign proc_s_axi_awvalid      = axi_dest ? 0 : s_axi_awvalid  ;
assign proc_s_axi_wdata        = axi_dest ? 0 : s_axi_wdata    ;
assign proc_s_axi_wstrb        = axi_dest ? 0 : s_axi_wstrb    ;
assign proc_s_axi_wvalid       = axi_dest ? 0 : s_axi_wvalid   ;
assign proc_s_axi_bready       = axi_dest ? 0 : s_axi_bready   ;
assign proc_s_axi_araddr       = axi_dest ? 0 : s_axi_araddr   ;
assign proc_s_axi_arprot       = axi_dest ? 0 : s_axi_arprot   ;
assign proc_s_axi_arvalid      = axi_dest ? 0 : s_axi_arvalid  ;
assign proc_s_axi_rready       = axi_dest ? 0 : s_axi_rready   ;

assign s_axi_awready           = axi_dest ? net_s_axi_awready : proc_s_axi_awready;
assign s_axi_wready            = axi_dest ? net_s_axi_wready  : proc_s_axi_wready ;
assign s_axi_bresp             = axi_dest ? net_s_axi_bresp   : proc_s_axi_bresp  ;
assign s_axi_bvalid            = axi_dest ? net_s_axi_bvalid  : proc_s_axi_bvalid ;
assign s_axi_arready           = axi_dest ? net_s_axi_arready : proc_s_axi_arready;
assign s_axi_rdata             = axi_dest ? net_s_axi_rdata   : proc_s_axi_rdata  ;
assign s_axi_rresp             = axi_dest ? net_s_axi_rresp   : proc_s_axi_rresp  ;
assign s_axi_rvalid            = axi_dest ? net_s_axi_rvalid  : proc_s_axi_rvalid ;

assign net_s_axi_awaddr        = axi_dest ? s_axi_awaddr  : 0 ;
assign net_s_axi_awprot        = axi_dest ? s_axi_awprot  : 0 ;
assign net_s_axi_awvalid       = axi_dest ? s_axi_awvalid : 0 ;
assign net_s_axi_wdata         = axi_dest ? s_axi_wdata   : 0 ;
assign net_s_axi_wstrb         = axi_dest ? s_axi_wstrb   : 0 ;
assign net_s_axi_wvalid        = axi_dest ? s_axi_wvalid  : 0 ;
assign net_s_axi_bready        = axi_dest ? s_axi_bready  : 0 ;
assign net_s_axi_araddr        = axi_dest ? s_axi_araddr  : 0 ;
assign net_s_axi_arprot        = axi_dest ? s_axi_arprot  : 0 ;
assign net_s_axi_arvalid       = axi_dest ? s_axi_arvalid : 0 ;
assign net_s_axi_rready        = axi_dest ? s_axi_rready  : 0 ;

wire [31:0] tnet_dt1_1, tnet_dt2_1;
wire [31:0] tnet_dt1_2, tnet_dt2_2;
wire [31:0] tnet_dt1_3, tnet_dt2_3;

axis_qick_network # ( 
   .SIMPLEX   ( 1 ) ,
   .SIM_LEVEL ( SIM_LEVEL )
) TNET_1 (
   .gt_refclk1_p        ( gt_refclk1_p         ) ,
   .gt_refclk1_n        ( gt_refclk1_n         ) ,
   .t_clk               ( t_clk              ) ,
   .t_aresetn           ( rst_ni             ) ,
   .c_clk               ( c_clk              ) ,
   .c_aresetn           ( rst_ni             ) ,
   .ps_clk              ( ps_clk             ) ,
   .ps_aresetn          ( rst_ni             ) ,
   .t_time_abs          ( t_time_abs1        ) ,
   .net_sync_i            ( sync_pulse         ) ,
   .net_sync_o            (          ) ,
//CONTROL
   .c_cmd_i             ( c_cmd_i              ) ,
   .c_op_i              ( c_op_i               ) ,
   .c_dt1_i             ( c_dt_1_i              ) ,
   .c_dt2_i             ( c_dt_2_i              ) ,
   .c_dt3_i             ( c_dt_3_i              ) ,
   .c_ready_o           ( ready_1            ) ,
   .core_start_o        ( core_start_1         ) ,
   .core_stop_o         ( core_stop_1          ) ,
   .time_rst_o          ( time_rst_1           ) ,
   .time_init_o         ( time_init_1          ) ,
   .time_updt_o         ( time_updt_1          ) ,
   .time_off_dt_o       ( time_off_dt_1        ) ,
   .tnet_dt1_o          ( tnet_dt1_1           ) ,
   .tnet_dt2_o          ( tnet_dt2_1           ) ,
// SIMULATION
   .rxn_A_i              ( txn_B_3              ) ,
   .rxp_A_i              ( txp_B_3              ) ,
   .txn_B_o              ( txn_B_1              ) ,
   .txp_B_o              ( txp_B_1              ) ,
//LINK CHANNEL A
   .axi_rx_tdata_A_RX_i  ( axi_tx_tdata_B_TX_3  ) ,
   .axi_rx_tvalid_A_RX_i ( axi_tx_tvalid_B_TX_3 ) ,
   .axi_rx_tlast_A_RX_i  ( axi_tx_tlast_B_TX_3  ) ,
//LINK CHANNEL B
   .axi_tx_tdata_B_TX_o  ( axi_tx_tdata_B_TX_1  ) ,
   .axi_tx_tvalid_B_TX_o ( axi_tx_tvalid_B_TX_1 ) ,
   .axi_tx_tlast_B_TX_o  ( axi_tx_tlast_B_TX_1  ) ,
   .axi_tx_tready_B_TX_i ( ready ) ,
//AXI   
   .s_axi_awaddr       (  net_s_axi_awaddr        ) ,
   .s_axi_awprot       (  net_s_axi_awprot        ) ,
   .s_axi_awvalid      (  net_s_axi_awvalid       ) ,
   .s_axi_awready      (  net_s_axi_awready       ) ,
   .s_axi_wdata        (  net_s_axi_wdata         ) ,
   .s_axi_wstrb        (  net_s_axi_wstrb         ) ,
   .s_axi_wvalid       (  net_s_axi_wvalid        ) ,
   .s_axi_wready       (  net_s_axi_wready        ) ,
   .s_axi_bresp        (  net_s_axi_bresp         ) ,
   .s_axi_bvalid       (  net_s_axi_bvalid        ) ,
   .s_axi_bready       (  net_s_axi_bready        ) ,
   .s_axi_araddr       (  net_s_axi_araddr        ) ,
   .s_axi_arprot       (  net_s_axi_arprot        ) ,
   .s_axi_arvalid      (  net_s_axi_arvalid       ) ,
   .s_axi_arready      (  net_s_axi_arready       ) ,
   .s_axi_rdata        (  net_s_axi_rdata         ) ,
   .s_axi_rresp        (  net_s_axi_rresp         ) ,
   .s_axi_rvalid       (  net_s_axi_rvalid        ) ,
   .s_axi_rready       (  net_s_axi_rready        ) );


axis_qick_network  # ( 
   .SIMPLEX   ( 1 ) , 
   .SIM_LEVEL ( SIM_LEVEL ) 
) TNET_2 (
   .gt_refclk1_p        ( gt_refclk1_p         ) ,
   .gt_refclk1_n        ( gt_refclk1_n         ) ,
   .t_clk             ( t_clk              ) ,
   .t_aresetn            ( rst_ni_2             ) ,
   .c_clk             ( c_clk              ) ,
   .c_aresetn            ( rst_ni_2             ) ,
   .ps_clk            ( ps_clk             ) ,
   .ps_aresetn           ( rst_ni_2            ) ,
   .t_time_abs          ( t_time_abs2           ) ,
   .net_sync_i            ( sync_pulse         ) ,
   .net_sync_o            (          ) ,
//CONTROL
   .c_cmd_i             ( c_cmd_i              ) ,
   .c_op_i              ( c_op_i               ) ,
   .c_dt1_i             ( c_dt_1_i              ) ,
   .c_dt2_i             ( c_dt_2_i              ) ,
   .c_dt3_i             ( c_dt_3_i              ) ,
   .c_ready_o           ( ready_2            ) ,
   .core_start_o        ( core_start_2         ) ,
   .core_stop_o         ( core_stop_2          ) ,
   .time_rst_o          ( time_rst_2           ) ,
   .time_init_o         ( time_init_2          ) ,
   .time_updt_o         ( time_updt_2          ) ,
   .time_off_dt_o       ( time_off_dt_2        ) ,
   .tnet_dt1_o          ( tnet_dt1_2           ) ,
   .tnet_dt2_o          ( tnet_dt2_2           ) ,
// SIMULATION
   .rxn_A_i              ( txn_B_1              ) ,
   .rxp_A_i              ( txp_B_1              ) ,
   .txn_B_o              ( txn_B_2              ) ,
   .txp_B_o              ( txp_B_2              ) ,
//LINK CHANNEL A
   .axi_rx_tdata_A_RX_i  ( axi_tx_tdata_B_TX_1  ) ,
   .axi_rx_tvalid_A_RX_i ( axi_tx_tvalid_B_TX_1 ) ,
   .axi_rx_tlast_A_RX_i  ( axi_tx_tlast_B_TX_1  ) ,
//LINK CHANNEL B
   .axi_tx_tdata_B_TX_o  ( axi_tx_tdata_B_TX_2  ) ,
   .axi_tx_tvalid_B_TX_o ( axi_tx_tvalid_B_TX_2 ) ,
   .axi_tx_tlast_B_TX_o  ( axi_tx_tlast_B_TX_2  ) ,
   .axi_tx_tready_B_TX_i ( ready ) ,
//AXI   
   .s_axi_awaddr         ( 0 ) ,
   .s_axi_awprot         ( 0 ) ,
   .s_axi_awvalid        ( 0 ) ,
   .s_axi_awready        (   ) ,
   .s_axi_wdata          ( 0 ) ,
   .s_axi_wstrb          ( 0 ) ,
   .s_axi_wvalid         ( 0 ) ,
   .s_axi_wready         (   ) ,
   .s_axi_bresp          (   ) ,
   .s_axi_bvalid         (   ) ,
   .s_axi_bready         ( 0 ) ,
   .s_axi_araddr         ( 0 ) ,
   .s_axi_arprot         ( 0 ) ,
   .s_axi_arvalid        ( 0 ) ,
   .s_axi_arready        (   ) ,
   .s_axi_rdata          (   ) ,
   .s_axi_rresp          (   ) ,
   .s_axi_rvalid         (   ) ,
   .s_axi_rready         (   ) );


      
axis_qick_network  # ( 
   .SIMPLEX   ( 1 ) , 
   .SIM_LEVEL ( SIM_LEVEL ) 
) TNET_3 (
   .gt_refclk1_p        ( gt_refclk1_p         ) ,
   .gt_refclk1_n        ( gt_refclk1_n         ) ,
   .t_clk             ( t_clk              ) ,
   .t_aresetn            ( rst_ni_3             ) ,
   .c_clk             ( c_clk              ) ,
   .c_aresetn            ( rst_ni_3             ) ,
   .ps_clk            ( ps_clk             ) ,
   .ps_aresetn           ( rst_ni_3            ) ,
   .t_time_abs          ( t_time_abs3           ) ,
   .net_sync_i            ( sync_pulse         ) ,
   .net_sync_o            (          ) ,
//CONTROL
   .c_cmd_i             ( c_cmd_i              ) ,
   .c_op_i              ( c_op_i               ) ,
   .c_dt1_i             ( c_dt_1_i              ) ,
   .c_dt2_i             ( c_dt_2_i              ) ,
   .c_dt3_i             ( c_dt_3_i              ) ,
   .c_ready_o           ( ready_3            ) ,
   .core_start_o        ( core_start_3         ) ,
   .core_stop_o         ( core_stop_3          ) ,
   .time_rst_o          ( time_rst_3           ) ,
   .time_init_o         ( time_init_3          ) ,
   .time_updt_o         ( time_updt_3          ) ,
   .time_off_dt_o       ( time_off_dt_3        ) ,
   .tnet_dt1_o          ( tnet_dt1_3           ) ,
   .tnet_dt2_o          ( tnet_dt2_3           ) ,
// SIMULATION
   .rxn_A_i              ( txn_B_2              ) ,
   .rxp_A_i              ( txp_B_2              ) ,
   .txn_B_o              ( txn_B_3              ) ,
   .txp_B_o              ( txp_B_3              ) ,
//LINK CHANNEL A
   .axi_rx_tdata_A_RX_i  ( axi_tx_tdata_B_TX_2  ) ,
   .axi_rx_tvalid_A_RX_i ( axi_tx_tvalid_B_TX_2 ) ,
   .axi_rx_tlast_A_RX_i  ( axi_tx_tlast_B_TX_2  ) ,
//LINK CHANNEL B
   .axi_tx_tdata_B_TX_o  ( axi_tx_tdata_B_TX_3  ) ,
   .axi_tx_tvalid_B_TX_o ( axi_tx_tvalid_B_TX_3 ) ,
   .axi_tx_tlast_B_TX_o  ( axi_tx_tlast_B_TX_3  ) ,
   .axi_tx_tready_B_TX_i ( ready ) ,
//AXI   
   .s_axi_awaddr         ( 0 ) ,
   .s_axi_awprot         ( 0 ) ,
   .s_axi_awvalid        ( 0 ) ,
   .s_axi_awready        (   ) ,
   .s_axi_wdata          ( 0 ) ,
   .s_axi_wstrb          ( 0 ) ,
   .s_axi_wvalid         ( 0 ) ,
   .s_axi_wready         (   ) ,
   .s_axi_bresp          (   ) ,
   .s_axi_bvalid         (   ) ,
   .s_axi_bready         ( 0 ) ,
   .s_axi_araddr         ( 0 ) ,
   .s_axi_arprot         ( 0 ) ,
   .s_axi_arvalid        ( 0 ) ,
   .s_axi_arready        (   ) ,
   .s_axi_rdata          (   ) ,
   .s_axi_rresp          (   ) ,
   .s_axi_rvalid         (   ) ,
   .s_axi_rready         (   ) );

assign axi_rx_tready_RX   = 1;
reg start_delay_1, start_delay_2;

assign rst_ni_2   = start_delay_1 ? 0 : rst_ni;
assign rst_ni_3   = start_delay_2 ? 0 : rst_ni;



reg [ 2:0] h_type  ;
reg [ 5:0] h_cmd   ;
reg [ 4:0] h_flags ;
reg [8:0] h_src  ;
reg [8:0] h_dst  ;


initial begin
   $display("START SIMULATION");

  	// Create agents.
	axi_mst_0_agent 	= new("axi_mst_0 VIP Agent",tb_qick_network_simplex.axi_mst_0_i.inst.IF);
	// Set tag for agents.
	axi_mst_0_agent.set_agent_tag	("axi_mst_0 VIP");
	// Start agents.
	axi_mst_0_agent.start_master();

   start_delay_1 = 1'b1;
   start_delay_2 = 1'b1;
   
   h_type   = 3'd0 ;
   h_cmd    = 6'd0 ;
   h_flags  = 5'd0 ;
   h_src    = 9'd0 ;
   h_dst    = 9'd0 ;
   rst_ni            = 1'b0;
   axi_dt            = 0 ;
   axi_dest          = 1'b1 ;
   time_updt_i       =  1'b0 ;
c_cmd_i  = 1'b0 ;
c_op_i   = 4'd0;
c_dt_1_i = 0;
c_dt_2_i = 0;
c_dt_3_i = 0;


   #10 ;

   @ (posedge ps_clk); #0.1;
   rst_ni            = 1'b1;
   #10 ;

#10000;
start_delay_1 = 1'b0;
#5000;
start_delay_2 = 1'b0;

   WRITE_AXI( REG_AXI_DT1 , 1);
   WRITE_AXI( REG_AXI_DT2 , 2);
   WRITE_AXI( REG_AXI_DT3 , {16'd0, 16'd2});

   //GET NET
   wait (ready_1==1'b1);
   WRITE_AXI( TNET_CTRL, 1); 
   #100;
   //SET NET
   #1000;
   wait (ready_1==1'b1);
   WRITE_AXI( TNET_CTRL, 2);  
   //SYNC_1
   #1000;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT1 , 7); // DATA1
   WRITE_AXI( REG_AXI_DT2 , 127); // DATA2
   WRITE_AXI( REG_AXI_DT3 , {14'd1460, 10'd0}); // SYNC TIME
   WRITE_AXI( TNET_CTRL, 3);  
   //SYNC_2
   #1000;
   wait (ready_1==1'b1);
   WRITE_AXI( TNET_CTRL, 4);  
   //SYNC_3
   #1000;
   wait (ready_1==1'b1);
   WRITE_AXI( TNET_CTRL, 5);  
   //SYNC_4
   #1000;
   wait (ready_1==1'b1);
   WRITE_AXI( TNET_CTRL, 6);  


   // GET_OFFSET
   #100;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT3    , {16'd0, 16'd2}); // NODE
   WRITE_AXI( TNET_CTRL, 7); 

   //UPDF_OFF
   #100;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT1 , 4); // DATA
   WRITE_AXI( REG_AXI_DT3    , {16'd0, 16'd2}); // NODE
   WRITE_AXI( TNET_CTRL, 8); // UPDT_OFFSET (NODE - DATA) 


   //SET_DT
   #5000;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT1 , 7); // DATA1
   WRITE_AXI( REG_AXI_DT2 , 127); // DATA2
   WRITE_AXI( REG_AXI_DT3 , {16'd0, 16'd2}); // NODE
   WRITE_AXI( TNET_CTRL, 9); // SET_DT (NODE - DATA)

   //GET_DT
   #500;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT3    , {16'd0, 16'd2}); // NODE
   WRITE_AXI( TNET_CTRL, 10); // GET_DT (NODE - DATA)









   @ (posedge ps_clk); #0.1;
   wait (ready_1==1'b1);
   WRITE_AXI( TNET_CTRL, 1); // GET_NET (NO PARAMETER)
   #200;
   @ (posedge ps_clk); #0.1;
   wait (ready_1==1'b1);
   WRITE_AXI( TNET_CTRL, 1); // GET_NET (NO PARAMETER)
   #300;
   @ (posedge ps_clk); #0.1;

   //SET NET
   #1000;
   wait (ready_1==1'b1);
   WRITE_AXI( TNET_CTRL, 2); // SET_NET  (NO PARAMETER / Automatic > RTD - CD - NN - ID) 

   #5000;
   wait (ready_1==1'b1);
   #1000;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT3    , {16'd0, 16'd3}); // NODE
   WRITE_AXI( TNET_CTRL, 5); // GET_OFFSET
   wait (ready_1==1'b1);
   #2000;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT3    , {16'd0, 16'd3}); // NODE
   WRITE_AXI( TNET_CTRL, 5); // GET_OFFSET
   wait (ready_1==1'b1);
   #3000;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT3    , {16'd0, 16'd3}); // NODE
   WRITE_AXI( TNET_CTRL, 5); // GET_OFFSET
   wait (ready_1==1'b1);

  // SYNC_NET
   #10000;
   wait (ready_1==1'b1);
   WRITE_AXI( TNET_CTRL, 8); // SYNC_NET (NO PARAMETER / Automatic > Delay, TimeWait)


   #1000;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT3    , {16'd0, 16'd2}); // NODE
   WRITE_AXI( TNET_CTRL, 5); // GET_OFFSET
   wait (ready_1==1'b1);
   #1000;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT3    , {16'd0, 16'd2}); // NODE
   WRITE_AXI( TNET_CTRL, 5); // GET_OFFSET
   wait (ready_1==1'b1);
   #2000;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT3    , {16'd0, 16'd3}); // NODE
   WRITE_AXI( TNET_CTRL, 5); // GET_OFFSET
   wait (ready_1==1'b1);
   #1000;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT3    , {16'd0, 16'd3}); // NODE
   WRITE_AXI( TNET_CTRL, 5); // GET_OFFSET
   wait (ready_1==1'b1);
   #3000;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT3    , {16'd0, 16'd4}); // NODE
   WRITE_AXI( TNET_CTRL, 5); // GET_OFFSET
   #1000;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT3    , {16'd0, 16'd4}); // NODE
   WRITE_AXI( TNET_CTRL, 5); // GET_OFFSET
   wait (ready_1==1'b1);

   #800;
     
   //SET NET
   #1000;
   wait (ready_1==1'b1);
   #10000;
   WRITE_AXI( TNET_CTRL, 2); // SET_NET  (NO PARAMETER / Automatic > RTD - CD - NN - ID) 



   //UPDF_OFF
   #100;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT1 , 4); // DATA
   WRITE_AXI( REG_AXI_DT3    , {16'd0, 16'd2}); // NODE
   WRITE_AXI( TNET_CTRL, 9); // UPDT_OFFSET (NODE - DATA)

//UPDF_OFF
   #100;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT1 , 2); // DATA
   WRITE_AXI( REG_AXI_DT3    , {16'd2, 16'd3}); // NODE
   WRITE_AXI( TNET_CTRL, 9); // UPDT_OFFSET (NODE - DATA)

//UPDF_OFF
   #100;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT1 , -2); // DATA
   WRITE_AXI( REG_AXI_DT3    , {16'd0, 16'd3}); // NODE
   WRITE_AXI( TNET_CTRL, 9); // UPDT_OFFSET (NODE - DATA)


   //SET_DT
   #100;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT1 , 15); // DATA1
   WRITE_AXI( REG_AXI_DT2 , 255); // DATA2
   WRITE_AXI( REG_AXI_DT3    , {16'd2, 16'd0}); // NODE
   WRITE_AXI( TNET_CTRL, 10); // SET_DT (NODE - DATA)

   //SET_DT
   #100;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT1 , 15); // DATA1
   WRITE_AXI( REG_AXI_DT2 , 255); // DATA2
   WRITE_AXI( TNET_CTRL, 10); // SET_DT (NODE - DATA)

   //SET_DT
   #100;
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT1 , 7); // DATA1
   WRITE_AXI( REG_AXI_DT2 , 127); // DATA2
   WRITE_AXI( REG_AXI_DT3    , {16'd3, 16'd0}); // NODE
   WRITE_AXI( TNET_CTRL, 10); // SET_DT (NODE - DATA)

   //GET_DT
   wait (ready_1==1'b1);
   WRITE_AXI( REG_AXI_DT3    , {16'd2, 16'd0}); // NODE
   WRITE_AXI( TNET_CTRL, 11); // GET_DT (NODE - DATA)

  #1000;
   //GET NET
   #1000;
   wait (ready_1==1'b1);
   WRITE_AXI( TNET_CTRL, 1); // GET_NET (NO PARAMETER)
   //SET NET
   #1000;
   wait (ready_1==1'b1);
   #10000;
   WRITE_AXI( TNET_CTRL, 2); // SET_NET  (NO PARAMETER / Automatic > RTD - CD - NN - ID) 
   // SYNC_NET
   #100;
   wait (ready_1==1'b1);
   WRITE_AXI( TNET_CTRL, 8); // SYNC_NET (NO PARAMETER / Automatic > Delay, TimeWait)
   


end


integer DATA_RD;

task WRITE_AXI(integer PORT_AXI, DATA_AXI); begin
   //$display("Write to AXI");
   //$display("PORT %d",  PORT_AXI);
   //$display("DATA %d",  DATA_AXI);
   @ (posedge ps_clk); #0.1;
   axi_mst_0_agent.AXI4LITE_WRITE_BURST(PORT_AXI, prot, DATA_AXI, resp);
   end
endtask

task READ_AXI(integer ADDR_AXI); begin
   @ (posedge ps_clk); #0.1;
   axi_mst_0_agent.AXI4LITE_READ_BURST(ADDR_AXI, 0, DATA_RD, resp);
      $display("READ AXI_DATA %d",  DATA_RD);
   end
endtask

integer cnt ;
integer axi_addr ;
integer num;

task TEST_AXI (); begin
   $display("-----Writting RANDOM AXI Address");
   for ( cnt = 0 ; cnt  < 16; cnt=cnt+1) begin
      axi_addr = cnt*4;
      axi_dt = cnt+1 ;
      //num = ($random %64)+31;
      //num = ($random %32)+31;
      //num = ($random %16)+15;
      //axi_addr = num*4;
      //axi_dt = num+1 ;
      #100
      $display("WRITE AXI_DATA %d",  axi_dt);
      WRITE_AXI( axi_addr, axi_dt); //SET
   end
   /*
   $display("-----Reading ALL AXI Address");
   for ( cnt = 0 ; cnt  <= 64; cnt=cnt+1) begin
      axi_addr = cnt*4;
      $display("READ AXI_ADDR %d",  axi_addr);
      READ_AXI( axi_addr);
      $display("READ AXI_DATA %d",  DATA_RD);
   end
   $display("-----FINISHED ");
   */
end
endtask


endmodule




