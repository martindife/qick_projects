`include "_tnet_defines.svh"

module qick_net_simplex # (
   parameter SIM_LEVEL = 0 ,
   parameter DEBUG     = 1
   
)(
// Core, Time and AXI CLK & RST.
   input  wire             gt_refclk1_p    ,
   input  wire             gt_refclk1_n    ,
   input  wire             t_clk_i         ,
   input  wire             t_rst_ni        ,
   input  wire             c_clk_i         ,
   input  wire             c_rst_ni        ,
   input  wire             ps_clk_i        ,
   input  wire             ps_rst_ni       ,
   input  wire  [47:0]     t_time_abs      ,
   input  wire             net_sync_i      ,
// TPROC CONTROL
   input  wire             c_cmd_i         ,
   input  wire  [4:0]      c_op_i          ,
   input  wire  [31:0]     c_dt1_i         ,
   input  wire  [31:0]     c_dt2_i         ,
   input  wire  [31:0]     c_dt3_i         ,
   output reg              c_ready_o       ,
   output reg              core_start_o    ,
   output reg              core_stop_o     ,
   output reg              time_rst_o      ,
   output reg              time_init_o     ,
   output reg              time_updt_o     ,
   output wire  [31:0]     time_off_dt_o   ,
   output reg   [31:0]     tnet_dt1_o      ,
   output reg   [31:0]     tnet_dt2_o      ,
///////////////// SIMULATION    
   input  wire             rxn_A_i         ,
   input  wire             rxp_A_i         ,
   output wire             txn_B_o         ,
   output  wire            txp_B_o         ,
////////////////   LINK CHANNEL A
   input  wire             axi_rx_tvalid_A_RX_i   ,
   input  wire  [63:0]     axi_rx_tdata_A_RX_i    ,
   input  wire             axi_rx_tlast_A_RX_i    ,
////////////////   LINK CHANNEL B
   output reg              axi_tx_tvalid_B_TX_o   ,
   output reg   [63:0]     axi_tx_tdata_B_TX_o    ,
   output reg              axi_tx_tlast_B_TX_o    ,
   input  wire             axi_tx_tready_B_TX_i   ,
// AXI-Lite DATA Slave I/F.   
   input  wire  [ 5:0]     s_axi_awaddr         ,
   input  wire  [ 2:0]     s_axi_awprot         ,
   input  wire             s_axi_awvalid        ,
   output wire             s_axi_awready        ,
   input  wire  [31:0]     s_axi_wdata          ,
   input  wire  [ 3:0]     s_axi_wstrb          ,
   input  wire             s_axi_wvalid         ,
   output wire             s_axi_wready         ,
   output wire  [ 1:0]     s_axi_bresp          ,
   output wire             s_axi_bvalid         ,
   input  wire             s_axi_bready         ,
   input  wire  [ 5:0]     s_axi_araddr         ,
   input  wire  [ 2:0]     s_axi_arprot         ,
   input  wire             s_axi_arvalid        ,
   output wire             s_axi_arready        ,
   output wire  [31:0]     s_axi_rdata          ,
   output wire  [ 1:0]     s_axi_rresp          ,
   output wire             s_axi_rvalid         ,
   input  wire             s_axi_rready         ,         
///// DEBUG   
   output wire             user_clk_do           ,
   output wire             axi_rx_tvalid_A_RX_do   ,
   output wire  [63:0]     axi_rx_tdata_A_RX_do    ,
   output wire             axi_rx_tlast_A_RX_do    ,
   output reg              axi_tx_tvalid_B_TX_do   ,
   output reg   [63:0]     axi_tx_tdata_B_TX_do    ,
   output reg              axi_tx_tlast_B_TX_do    ,
   output wire             axi_tx_tready_B_TX_do   ,
   output wire             c_ready_do           ,
   output wire [12:0]      tnet_st_do           ,
   output wire             loc_cmd_req_do       ,
   output wire             loc_cmd_ack_do       ,
   output wire             net_cmd_req_do       ,
   output wire             net_cmd_ack_do       ,
   output wire [63:0]      cmd_header_do        ,
   output wire             tx_ready_01_do       ,
   output wire             aurora_ready_do      
);


///// AXI LITE PORT /////
///////////////////////////////////////////////////////////////////////////////
TYPE_IF_AXI_REG        IF_s_axireg()   ;
assign IF_s_axireg.axi_awaddr  = s_axi_awaddr ;
assign IF_s_axireg.axi_awprot  = s_axi_awprot ;
assign IF_s_axireg.axi_awvalid = s_axi_awvalid;
assign IF_s_axireg.axi_wdata   = s_axi_wdata  ;
assign IF_s_axireg.axi_wstrb   = s_axi_wstrb  ;
assign IF_s_axireg.axi_wvalid  = s_axi_wvalid ;
assign IF_s_axireg.axi_bready  = s_axi_bready ;
assign IF_s_axireg.axi_araddr  = s_axi_araddr ;
assign IF_s_axireg.axi_arprot  = s_axi_arprot ;
assign IF_s_axireg.axi_arvalid = s_axi_arvalid;
assign IF_s_axireg.axi_rready  = s_axi_rready ;
assign s_axi_awready = IF_s_axireg.axi_awready;
assign s_axi_wready  = IF_s_axireg.axi_wready ;
assign s_axi_bresp   = IF_s_axireg.axi_bresp  ;
assign s_axi_bvalid  = IF_s_axireg.axi_bvalid ;
assign s_axi_arready = IF_s_axireg.axi_arready;
assign s_axi_rdata   = IF_s_axireg.axi_rdata  ;
assign s_axi_rresp   = IF_s_axireg.axi_rresp  ;
assign s_axi_rvalid  = IF_s_axireg.axi_rvalid ;


wire [31:0] TNET_CTRL, TNET_CFG, REG_AXI_DT1, REG_AXI_DT2, REG_AXI_DT3;
wire [15:0] TNET_ADDR,TNET_LEN; 
reg  [63 :0]   net_cmd [2]   ;




reg [31:0] tnet_DT [2];






wire        get_time_lcs, get_time_ncr;
wire [63:0] cmd_header_r ;
wire [31:0] cmd_dt_r [2] ;

TYPE_PARAM_WE  param_we;
wire [31:0]    param_32_dt    ;
wire [9 :0]    param_10_dt     ;
wire [31:0]    param_64_dt [2] ;
wire [8:0] cmd_cnt_ds;

tnet_cmd_cod CMD_COD (
   .c_clk_i       ( c_clk_i         ) ,
   .c_rst_ni      ( c_rst_ni        ) ,
   .param_NN      ( param.NN        ) ,
   .param_ID      ( param.ID        ) ,
   .c_cmd_i       ( c_cmd_i         ) ,
   .c_op_i        ( c_op_i          ) ,
   .c_dt_i        ( {c_dt1_i, c_dt2_i, c_dt3_i}  ) ,
   .p_op_i        ( TNET_CTRL[4:0]  ) ,
   .p_dt_i        ( {REG_AXI_DT1, REG_AXI_DT2, REG_AXI_DT3} ) ,
   .net_cmd_i     ( net_cmd_hit     ) ,
   .net_cmd_h_i   ( net_cmd[0]      ) ,
   .net_cmd_dt_i  ( net_cmd[1]      ) ,
   .header_o      ( cmd_header_r    ) ,
   .data_o        ( cmd_dt_r        ) ,
   .loc_cmd_req_o ( loc_cmd_req     ) ,
   .loc_cmd_ack_i ( loc_cmd_ack_s   ) ,
   .net_cmd_req_o ( net_cmd_req     ) ,
   .net_cmd_ack_i ( net_cmd_ack_s   ) ,
   .cmd_cnt_do    ( cmd_cnt_ds   ) 
   
);

wire [63:0]  tx_cmd_header_s ;
wire [31:0]  tx_cmd_dt_s [2] ;
wire tx_req_s, tx_ack_s;

TYPE_CTRL_REQ      ctrl_cmd_req_s ;
TYPE_CTRL_OP       ctrl_cmd_op_s  ;
wire [47:0]        ctrl_cmd_dt_s  ;

wire [31:0]    error_hist_ds;  
wire [ 7:0]    error_cnt_ds, ready_cnt_ds;
wire [ 3:0]    error_id_ds ;
wire [12:0]    tnet_st_ds ;
wire [14:0]    cmd_ds;
wire [99:0]    cmd_st_hist_ds     ;     



tnet_cmd_proc CMD_PROC (
   .c_clk_i         ( c_clk_i         ) ,
   .c_rst_ni        ( c_rst_ni        ) ,
   .ctrl_rst_i      ( 1'b0            ) ,
   .aurora_ready_i  ( aurora_ready    ) ,
   .tx_ready_t01    ( tx_ready_01     ) ,
   .net_sync_i      ( net_sync_i    ) ,
   .param_i         ( param           ) ,
   .tnet_dt_i       ( tnet_DT         ) ,
   .t_time_abs      ( t_time_abs[31:0]   ) ,
   .c_ready_o       ( c_ready_o       ) ,
   .loc_cmd_req_i   ( loc_cmd_req     ) ,
   .net_cmd_req_i   ( net_cmd_req     ) ,
   .cmd_header_i    ( cmd_header_r    ) ,
   .cmd_dt_i        ( cmd_dt_r        ) ,
   .loc_cmd_ack_o   ( loc_cmd_ack_s   ) ,
   .net_cmd_ack_o   ( net_cmd_ack_s   ) ,
   .tx_req_set_o    ( get_time_lcs    ) ,
   .param_we        ( param_we        ) ,
   .param_64_dt     ( param_64_dt     ) ,
   .param_32_dt     ( param_32_dt     ) ,
   .param_10_dt     ( param_10_dt     ) ,
   .tx_req_o        ( tx_req_s        ) ,
   .tx_cmd_header_o ( tx_cmd_header_s ) ,
   .tx_cmd_dt_o     ( tx_cmd_dt_s     ) ,
   .tx_ack_i        ( tx_ack_s        ) ,
   .ctrl_cmd_req_o  ( ctrl_cmd_req_s  ) ,
   .ctrl_cmd_op_o   ( ctrl_cmd_op_s   ) ,
   .ctrl_cmd_dt_o   ( ctrl_cmd_dt_s   ) ,
   .ctrl_cmd_ok_i   ( ctrl_cmd_ok_s ),
   .ctrl_cmd_ack_i  ( ctrl_cmd_ack_s ),   
   .tnet_st_do      ( tnet_st_ds      ) ,
   .error_cnt_do    ( error_cnt_ds    ) ,
   .ready_cnt_do    ( ready_cnt_ds    ) ,
   .error_id_do     ( error_id_ds     ) ,
   .error_hist_do   ( error_hist_ds   ) ,
   .cmd_do          ( cmd_ds          ) ,
   .cmd_st_hist_do  ( cmd_st_hist_ds  ) );

wire [2:0] ctrl_st_ds;
tnet_qick_cmd TPROC_CTRL (
   .c_clk_i        ( c_clk_i        ) ,
   .c_rst_ni       ( c_rst_ni       ) ,
   .t_clk_i        ( t_clk_i        ) ,
   .t_rst_ni       ( t_rst_ni       ) ,
   .net_sync_i     ( net_sync_i     ) ,
   .RTD_i          ( param.RTD      ) ,
   .t_time_abs     ( t_time_abs     ) ,
   .ctrl_cmd_req_i ( ctrl_cmd_req_s ) ,
   .ctrl_cmd_op_i  ( ctrl_cmd_op_s  ) ,
   .ctrl_cmd_dt_i  ( ctrl_cmd_dt_s  ) ,
   .ctrl_cmd_ok_o  ( ctrl_cmd_ok_s  ),
   .ctrl_cmd_ack_o ( ctrl_cmd_ack_s ),
   .core_start_o   ( core_start_o   ) ,
   .core_stop_o    ( core_stop_o    ) ,
   .time_reset_o   ( time_rst_o     ) ,
   .time_init_o    ( time_init_o    ) ,
   .time_updt_o    ( time_updt_o    ) ,    
   .time_off_dt_o  ( time_off_dt_o  ) ,
   .ctrl_st_do     ( ctrl_st_ds)
);





wire [31:0]       rx_status_ds, tx_status_ds, pr_status_ds, ex_status_ds;

wire [8:0]       aurora_ds;

aurora_ctrl_simplex # (
   .SIM_LEVEL ( SIM_LEVEL )
) TNET_LINK_INST (
   .gt_refclk1_p         ( gt_refclk1_p         ),      
   .gt_refclk1_n         ( gt_refclk1_n         ),
   .c_clk_i              ( c_clk_i             ),
   .c_rst_ni             ( c_rst_ni            ),
   .ps_clk_i             ( ps_clk_i             ),
   .ps_rst_ni            ( ps_rst_ni            ),
   .ID_i                 ( param.ID             ),
   .NN_i                 ( param.NN             ),
   .tx_req_i             ( tx_req_s             ),
   .tx_header_i          ( tx_cmd_header_s      ),
   .tx_data_i            ( tx_cmd_dt_s          ),
   .tx_ack_o             ( tx_ack_s             ),
   .tx_ready_01          ( tx_ready_01          ),
   .cmd_req_set_o        ( net_cmd_hit          ),
   .cmd_dt_o             ( net_cmd              ),
   .ready_o              ( aurora_ready         ),
   .rxn_A_i              ( rxn_A_i              ),
   .rxp_A_i              ( rxp_A_i              ),
   .txn_B_o              ( txn_B_o              ),
   .txp_B_o              ( txp_B_o              ),
// Simulation Channel A
   .axi_rx_tvalid_A_RX_i ( axi_rx_tvalid_A_RX_i ),
   .axi_rx_tdata_A_RX_i  ( axi_rx_tdata_A_RX_i  ),
   .axi_rx_tlast_A_RX_i  ( axi_rx_tlast_A_RX_i  ),
// Sumulation Channel B

   .axi_tx_tvalid_B_TX_o ( axi_tx_tvalid_B_TX_o ),
   .axi_tx_tdata_B_TX_o  ( axi_tx_tdata_B_TX_o  ),
   .axi_tx_tlast_B_TX_o  ( axi_tx_tlast_B_TX_o  ),
   .axi_tx_tready_B_TX_i ( axi_tx_tready_B_TX_i ),
// DEBUG 
   .user_clk_do            ( user_clk_do           ),
   .axi_rx_tvalid_A_RX_do  ( axi_rx_tvalid_A_RX_do ),
   .axi_rx_tdata_A_RX_do   ( axi_rx_tdata_A_RX_do  ),
   .axi_rx_tlast_A_RX_do   ( axi_rx_tlast_A_RX_do  ),
   .axi_tx_tvalid_B_TX_do  ( axi_tx_tvalid_B_TX_do ),
   .axi_tx_tdata_B_TX_do   ( axi_tx_tdata_B_TX_do  ),
   .axi_tx_tlast_B_TX_do   ( axi_tx_tlast_B_TX_do  ),
   .axi_tx_tready_B_TX_do  ( axi_tx_tready_B_TX_do ),
   .rx_status_do           ( rx_status_ds          ),
   .tx_status_do           ( tx_status_ds          ),
   .pr_status_do           ( pr_status_ds          ),
   .ex_status_do           ( ex_status_ds          ),
   .link_st_do             ( link_st_ds            ),
   .aurora_do              ( aurora_ds             )
   );

wire [2:0] link_st_ds;
   

   
 
// AXI Slave.
tnet_axi_reg TNET_xREG (
   .ps_aclk        ( ps_clk_i       ) , 
   .ps_aresetn     ( ps_rst_ni      ) , 
   .IF_s_axireg    ( IF_s_axireg    ) ,
   .TNET_CTRL      ( TNET_CTRL      ) ,
   .TNET_CFG       ( TNET_CFG       ) ,
   .TNET_ADDR      ( TNET_ADDR      ) ,
   .TNET_LEN       ( TNET_LEN       ) ,
   .RAXI_DT1       ( REG_AXI_DT1    ) ,
   .RAXI_DT2       ( REG_AXI_DT2    ) ,
   .RAXI_DT3       ( REG_AXI_DT3    ) ,
   .NN_ID          ( {param.NN, param.ID}     ) ,
   .RTD            ( param.RTD      ) ,
   .TNET_W_DT1     ( tnet_DT[0]     ) ,
   .TNET_W_DT2     ( tnet_DT[1]     ) ,
   .RX_STATUS      ( rx_status_ds       ) ,
   .TX_STATUS      ( tx_status_ds       ) ,
   .TNET_STATUS    ( TNET_STATUS    ) ,
   .TNET_DEBUG     ( TNET_DEBUG     ) ,
   .TNET_HIST      ( TNET_HIST     ) );

   

///////////////////////////////////////////////////////////////////////////////
// AXI_REG

wire  [31:0] TNET_STATUS;
assign TNET_STATUS[31:17]  = cmd_ds;
assign TNET_STATUS[16]     = c_ready_o ;
assign TNET_STATUS[15:13]  = 3'd0;
assign TNET_STATUS[12:9]   = error_id_ds ;
assign TNET_STATUS[8: 0]   = aurora_ds;

wire  [31:0] TNET_DEBUG;
wire [31:0] debug_st, debug_cnt;
reg [31:0] debug_ds ;
assign debug_st[31:23]  = 0;
assign debug_st[22]  = net_cmd_ack_s;
assign debug_st[21]  = net_cmd_req;
assign debug_st[20]  = loc_cmd_ack_s;
assign debug_st[19]  = loc_cmd_req;
assign debug_st[18:16]  = link_st_ds;
assign debug_st[15:13]  = ctrl_st_ds;
assign debug_st[12: 0]  = tnet_st_ds;

assign debug_cnt[31:25]  = 0;
assign debug_cnt[24:17]  = ready_cnt_ds;
assign debug_cnt[16:9]  = error_cnt_ds;
assign debug_cnt[ 8: 0]  = cmd_cnt_ds;

always_comb  
   case (TNET_CFG[2:0])
      3'b000: debug_ds = debug_st;
      3'b001: debug_ds = debug_cnt;
      3'b010: debug_ds = pr_status_ds;
      3'b011: debug_ds = ex_status_ds;
      3'b100: debug_ds = error_hist_ds;
      3'b101: debug_ds = cmd_st_hist_ds[49:25];
      3'b110: debug_ds = cmd_st_hist_ds[74:50];
      3'b111: debug_ds = cmd_st_hist_ds[99:75];
      default: debug_ds = TNET_CFG;
   endcase
assign TNET_DEBUG = debug_ds ;

wire  [31:0] TNET_HIST;
assign TNET_HIST[31:25]  = 7'd0 ;
assign TNET_HIST[24: 0]  = cmd_st_hist_ds[24:0] ;


// Processing-Wait Time
///////////////////////////////////////////////////////////////////////////////

assign get_time_ncr = net_cmd_hit ; //Single Pulse net_req


TYPE_QPARAM param ;
    
// Parameters
always_ff @(posedge c_clk_i, negedge c_rst_ni) begin
   if (!c_rst_ni) begin
      param    <= '{default:'0};
      tnet_DT  <= '{default:'0};
   end else begin
      if ( param_we.DT  )  tnet_DT      <= param_64_dt; 
      if ( param_we.OFF )  param.OFF    <= param_32_dt;
      if ( param_we.RTD )  param.RTD    <= param_32_dt; 
      if ( param_we.NN  )  param.NN     <= param_10_dt; 
      if ( param_we.ID  )  param.ID     <= param_10_dt; 
      if ( get_time_ncr )  param.T_NCR  <= t_time_abs[31:0];
      if ( get_time_lcs )  param.T_LCS  <= t_time_abs[31:0];
   end
end

assign  tnet_st_do = tnet_st_ds ;  
assign  c_ready_do      = c_ready_o     ;
assign  loc_cmd_req_do  = loc_cmd_req   ;
assign  loc_cmd_ack_do  = loc_cmd_ack_s ;
assign  net_cmd_req_do  = net_cmd_req   ;
assign  net_cmd_ack_do  = net_cmd_ack_s ;
assign  cmd_header_do   = cmd_header_r  ;
assign  tx_ready_01_do  = tx_ready_01   ;
assign  aurora_ready_do = aurora_ready  ;

///// OUTPUTS
assign time_off_dt_o = param.OFF;
assign tnet_dt1_o = tnet_DT[0];
assign tnet_dt2_o = tnet_DT[1];



endmodule

