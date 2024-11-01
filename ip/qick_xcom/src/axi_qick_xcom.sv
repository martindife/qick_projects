///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : Martin Di Federico
//  Date           : 2024_10_20
//  Version        : 2
///////////////////////////////////////////////////////////////////////////////
//  QICK PROCESSOR :  Board Communication Peripheral
//////////////////////////////////////////////////////////////////////////////

module axi_qick_xcom # (
   parameter CH           = 2 ,
   parameter SYNC         = 1 ,
   parameter DEBUG        = 1
)(
// CLK & RST
   input  wire             ps_clk        ,
   input  wire             ps_aresetn    ,
   input  wire             c_clk         ,
   input  wire             c_aresetn     ,
   input  wire             t_clk         ,
   input  wire             t_aresetn     ,
   input  wire             x_clk         ,
   input  wire             x_aresetn     ,
// QICK PERIPHERAL INTERFACE (c_clk)
   input  wire             qp_en_i       , 
   input  wire  [4:0]      qp_op_i       , 
   input  wire  [31:0]     qp_dt1_i      , 
   input  wire  [31:0]     qp_dt2_i      , 
   output reg              qp_rdy_o      , 
   output reg   [31:0]     qp_dt1_o      , 
   output reg   [31:0]     qp_dt2_o      , 
   output reg              qp_vld_o      , 
   output reg              qp_flag_o     , 
// Qick CONTROL
   input  wire             pulse_sync_i  ,
   output wire             proc_start_o  ,
   output wire             proc_stop_o   ,
   output wire             time_rst_o    ,
   output wire             time_updt_o   ,
   output wire  [31:0]     time_updt_dt_o,
   output wire             core_start_o  ,
   output wire             core_stop_o   ,
// XCOM 
   output wire  [ 3:0]     xcom_id_o     ,
// IO XCOM (x_clk)
   input  wire  [CH-1:0]   xcom_ck_i     ,
   input  wire  [CH-1:0]   xcom_dt_i     ,
   output wire             xcom_ck_o     ,
   output wire             xcom_dt_o     ,
// AXI-Lite DATA Slave I/F (ps_clk)
   input  wire [5:0]       s_axi_awaddr  ,
   input  wire [2:0]       s_axi_awprot  ,
   input  wire             s_axi_awvalid ,
   output wire             s_axi_awready ,
   input  wire [31:0]      s_axi_wdata   ,
   input  wire [ 3:0]      s_axi_wstrb   ,
   input  wire             s_axi_wvalid  ,
   output wire             s_axi_wready  ,
   output wire [ 1:0]      s_axi_bresp   ,
   output wire             s_axi_bvalid  ,
   input  wire             s_axi_bready  ,
   input  wire [ 5:0]      s_axi_araddr  ,
   input  wire [ 2:0]      s_axi_arprot  ,
   input  wire             s_axi_arvalid ,
   output wire             s_axi_arready ,
   output wire [31:0]      s_axi_rdata   ,
   output wire [ 1:0]      s_axi_rresp   ,
   output wire             s_axi_rvalid  ,
   input  wire             s_axi_rready        
);

// Signal Declaration 
///////////////////////////////////////////////////////////////////////////////

// XCOM Control (From Python and tProc)
wire [ 7:0] cmd_op ;
wire [31:0] cmd_dt ;
wire [ 7:0] cmd_cnt_ds ;

wire [ 5:0] XCOM_CTRL ;
wire [ 2:0] XCOM_CFG ;
wire [31:0] AXI_DT1, AXI_DT2 ;
wire [ 3:0] AXI_ADDR ;



wire [ 5:0] p_ctrl  ; 
wire [31:0] p_dt [2]; 
wire [31:0] c_dt [2]; 

reg [31:0] xcom_mem_dt [15];
wire [31:0] axi_mem_dt;

wire [31:0] xreg_debug;
wire [28:0] xreg_status;
wire [31:0]      xcom_rx_ds ;
wire [31:0]      xcom_tx_ds ;
wire [20:0]      xcom_status_ds ;
wire [31:0]      xcom_debug_ds  ;

assign p_ctrl = XCOM_CTRL;
assign c_dt   = '{qp_dt1_i, qp_dt2_i};
assign p_dt   = '{AXI_DT1  , AXI_DT2};

qick_xcom_cmd QICK_CMD(
   .ps_clk_i      ( ps_clk      ),
   .ps_rst_ni     ( ps_aresetn  ),
   .c_clk_i       ( c_clk       ),
   .c_rst_ni      ( c_aresetn   ),
   .x_clk_i       ( x_clk       ),
   .x_rst_ni      ( x_aresetn   ),
   .c_en_i        ( qp_en_i     ),
   .c_op_i        ( qp_op_i     ),
   .c_dt_i        ( c_dt        ),
   .p_ctrl_i      ( p_ctrl      ),
   .p_dt_i        ( p_dt        ),
   .cmd_loc_req_o ( cmd_loc_req ),
   .cmd_loc_ack_i ( cmd_loc_ack ),
   .cmd_net_req_o ( cmd_net_req ),
   .cmd_net_ack_i ( cmd_net_ack ),
   .cmd_op_o      ( cmd_op      ),
   .cmd_dt_o      ( cmd_dt      ),
   .cmd_cnt_do    ( cmd_cnt_ds     ));

wire [3:0] xcom_cfg;
assign   xcom_cfg = {XCOM_CFG[2:0]+1'b1, 1'b0};

qick_xcom # (
   .CH    ( CH   ),
   .SYNC  ( SYNC )
) XCOM (
   .c_clk_i        ( c_clk          ),
   .c_rst_ni       ( c_aresetn      ),
   .t_clk_i        ( t_clk          ),
   .t_rst_ni       ( t_aresetn      ),
   .x_clk_i        ( x_clk          ),
   .x_rst_ni       ( x_aresetn      ),
   .pulse_sync_i   ( pulse_sync_i   ),
   .cmd_loc_req_i  ( cmd_loc_req    ),
   .cmd_loc_ack_o  ( cmd_loc_ack    ),
   .cmd_net_req_i  ( cmd_net_req    ),
   .cmd_net_ack_o  ( cmd_net_ack    ),
   .cmd_op_i       ( cmd_op         ),
   .cmd_dt_i       ( cmd_dt         ),
   .qp_rdy_o       ( qp_rdy_o       ),
   .qp_vld_o       ( qp_vld_o       ),
   .qp_flag_o      ( qp_flag_o      ),
   .qp_dt1_o       ( qp_dt1_o       ),
   .qp_dt2_o       ( qp_dt2_o       ),
   .p_start_o      ( proc_start_o   ),
   .p_stop_o       ( proc_stop_o    ),
   .t_rst_o        ( time_rst_o     ),
   .t_updt_o       ( time_updt_o    ),
   .t_updt_dt_o    ( time_updt_dt_o ),

   .c_start_o      ( core_start_o   ),
   .c_stop_o       ( core_stop_o    ),
   .xcom_cfg_i     ( xcom_cfg       ),
   .xcom_id_o      ( xcom_id_o      ),
   .xcom_mem_o     ( xcom_mem_dt    ),
   .rx_dt_i        ( xcom_dt_i      ),
   .rx_ck_i        ( xcom_ck_i      ),
   .tx_dt_o        ( tx_dt_s        ),
   .tx_ck_o        ( tx_ck_s        ),
   .xcom_rx_do     ( xcom_rx_ds     ),
   .xcom_tx_do     ( xcom_tx_ds     ),
   .xcom_status_do ( xcom_status_ds ),
   .xcom_debug_do  ( xcom_debug_ds  )
);   





///////////////////////////////////////////////////////////////////////////////
// AXI Registers
///////////////////////////////////////////////////////////////////////////////
axi_slv_xcom XCOM_xREG (
   .aclk        ( ps_clk             ), 
   .aresetn     ( ps_aresetn         ), 
   .awaddr      ( s_axi_awaddr [5:0] ), 
   .awprot      ( s_axi_awprot       ), 
   .awvalid     ( s_axi_awvalid      ), 
   .awready     ( s_axi_awready      ), 
   .wdata       ( s_axi_wdata        ), 
   .wstrb       ( s_axi_wstrb        ), 
   .wvalid      ( s_axi_wvalid       ), 
   .wready      ( s_axi_wready       ), 
   .bresp       ( s_axi_bresp        ), 
   .bvalid      ( s_axi_bvalid       ), 
   .bready      ( s_axi_bready       ), 
   .araddr      ( s_axi_araddr       ), 
   .arprot      ( s_axi_arprot       ), 
   .arvalid     ( s_axi_arvalid      ), 
   .arready     ( s_axi_arready      ), 
   .rdata       ( s_axi_rdata        ), 
   .rresp       ( s_axi_rresp        ), 
   .rvalid      ( s_axi_rvalid       ), 
   .rready      ( s_axi_rready       ), 
   .XCOM_CTRL   ( XCOM_CTRL          ),
   .XCOM_CFG    ( XCOM_CFG           ),
   .AXI_DT1     ( AXI_DT1            ),
   .AXI_DT2     ( AXI_DT2            ),
   .AXI_ADDR    ( AXI_ADDR           ),
   .BOARD_ID    ( xcom_id_o          ),
   .XCOM_FLAG   ( qp_flag_o          ),
   .XCOM_DT_1   ( qp_dt1_o           ),
   .XCOM_DT_2   ( qp_dt2_o           ),
   .XCOM_MEM    ( axi_mem_dt         ),
   .XCOM_RX_DT  ( xcom_rx_ds         ),
   .XCOM_TX_DT  ( xcom_tx_ds         ),
   .XCOM_STATUS ( xreg_status        ),
   .XCOM_DEBUG  ( xreg_debug         ));


// OUTPUTS
///////////////////////////////////////////////////////////////////////////////
assign xcom_dt_o = tx_dt_s;
assign xcom_ck_o = tx_ck_s;
assign axi_mem_dt = xcom_mem_dt[AXI_ADDR];

///////////////////////////////////////////////////////////////////////////////
// DEBUG
///////////////////////////////////////////////////////////////////////////////
assign xreg_status = { cmd_cnt_ds, xcom_status_ds};

generate
   if (DEBUG == 0) begin : DEBUG_NO
      assign xreg_debug  = '{default:'0} ;
   end else if   (DEBUG == 1) begin : DEBUG_YES
      assign xreg_debug  = xcom_debug_ds;
   end
endgenerate

endmodule
