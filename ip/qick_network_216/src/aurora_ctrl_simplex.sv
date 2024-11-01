module aurora_ctrl_simplex # (
   parameter SIM_LEVEL = 0 ,
   parameter DEBUG = 1
   
)( 
// Core, Time and AXI CLK & RST.
   input  wire             gt_refclk1_p     ,
   input  wire             gt_refclk1_n     ,
   input  wire             c_clk_i         ,
   input  wire             c_rst_ni        ,
   input  wire             ps_clk_i         , //99.999001
   input  wire             ps_rst_ni        ,
// Data 
   input  wire  [9 :0]     ID_i             ,
   input  wire  [9 :0]     NN_i             ,
// Transmittion 
   input  wire             tx_req_i         ,
   input  wire [63 :0]     tx_header_i      ,
   input  wire [31 :0]     tx_data_i [2]       ,
   output reg              tx_ack_o        ,
   output wire             tx_ready_01         ,
// Command Processing  
   output reg              cmd_req_set_o       ,
   output reg  [63:0]      cmd_dt_o[2]        ,
   output reg              ready_o         ,
///////////////// SIMULATION    
   input  wire             rxn_A_i        ,
   input  wire             rxp_A_i        ,
   output wire             txn_B_o        ,
   output  wire            txp_B_o        ,
////////////////   LINK CHANNEL A
   input  wire             axi_rx_tvalid_A_RX_i ,
   input  wire  [63:0]     axi_rx_tdata_A_RX_i  ,
   input  wire             axi_rx_tlast_A_RX_i  ,
////////////////   LINK CHANNEL B
   output reg              axi_tx_tvalid_B_TX_o ,
   output reg  [63:0]      axi_tx_tdata_B_TX_o  ,
   output reg              axi_tx_tlast_B_TX_o  ,
   input  wire             axi_tx_tready_B_TX_i ,
// DEBUGGING
   output wire             user_clk_do           ,
   output  wire             axi_rx_tvalid_A_RX_do   ,
   output  wire  [63:0]     axi_rx_tdata_A_RX_do    ,
   output  wire             axi_rx_tlast_A_RX_do    ,
   output reg               axi_tx_tvalid_B_TX_do   ,
   output reg   [63:0]      axi_tx_tdata_B_TX_do    ,
   output reg               axi_tx_tlast_B_TX_do    ,
   output  wire             axi_tx_tready_B_TX_do   ,
   output wire [31:0]       rx_status_do        ,
   output wire [31:0]       tx_status_do        ,
   output wire [31:0]       pr_status_do        ,
   output wire [31:0]       ex_status_do        ,
   output wire [ 2:0]       link_st_do        ,
   
   
   output wire [8:0]       aurora_do           );


////////////////////////////////////////////////
// SIGNALS 
wire          channel_TX_up, channel_RX_up ;

//PHY CONNECTION SIGNALS
reg             reset_pb           ;
reg             pma_init           ;
wire init_clk;

// A RX and B TX CONNECTION
wire             axi_rx_tvalid_RX, axi_rx_tlast_RX   ;
wire  [63:0]     axi_rx_tdata_RX    ;
wire             axi_tx_tready_TX ;
reg              axi_tx_tvalid_TX, axi_tx_tlast_TX ;
reg  [63:0]      axi_tx_tdata_TX    ;
wire  [7 :0]     axi_tx_tkeep_TX ;





// NETWORK LINK MEASURES
///////////////////////////////////////////////////////////////////////////////
reg tx_rdy_r, tx_rdy_r2 ;
(* ASYNC_REG = "TRUE" *) reg tx_rdy_cdc;
always_ff @(posedge c_clk_i)
   if (!c_rst_ni) begin
      tx_rdy_cdc     <= 0;
      tx_rdy_r       <= 0;
      tx_rdy_r2      <= 0;
   end else begin
      tx_rdy_cdc     <= axi_tx_tready_TX;
      tx_rdy_r       <= tx_rdy_cdc;
      tx_rdy_r2      <= tx_rdy_r;
   end

assign tx_ready_01  = !tx_rdy_r2     &  tx_rdy_r ;




///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// LINK CONNECTION 
///////////////////////////////////////////////////////////////////////////////
wire user_clk, mmcm_not_locked;
wire user_rst;
wire lane_TX_up, lane_RX_up;
wire [6:0] aurora_ds ;

generate
/////////////////////////////////////////////////
   if (SIM_LEVEL == 1) begin : SIM_NO_AURORA
      assign txn_B_o          = 0 ;
      assign txp_B_o          = 0 ;
      assign init_clk         = 1;
      assign user_clk         = ps_clk_i   ;
      assign mmcm_not_locked  = ~ps_rst_ni ;
      assign channel_RX_up    = 1;
      assign channel_TX_up    = 1;
      assign aurora_ds        = 0;
      assign lane_TX_up       = 0;
      assign lane_RX_up       = 0;
   // A RX and B TX CONNECTION
      assign axi_rx_tvalid_RX     = axi_rx_tvalid_A_RX_i;
      assign axi_rx_tdata_RX      = axi_rx_tdata_A_RX_i ;
      assign axi_rx_tlast_RX      = axi_rx_tlast_A_RX_i ;
      assign axi_tx_tvalid_B_TX_o = axi_tx_tvalid_TX  ;
      assign axi_tx_tdata_B_TX_o  = axi_tx_tdata_TX   ;
      assign axi_tx_tlast_B_TX_o  = axi_tx_tlast_TX   ;
      assign axi_tx_tready_TX     = axi_tx_tready_B_TX_i;

 end else begin 
      if (SIM_LEVEL == 2) begin : SIM_YES_AURORA
         assign axi_tx_tvalid_B_TX_o  = axi_rx_tvalid_RX ;
         assign axi_tx_tdata_B_TX_o   = axi_rx_tdata_RX ;
         assign axi_tx_tlast_B_TX_o   = axi_rx_tlast_RX ;
      end 
      /////// INIT CLK
      clk_wiz_0 CLK_AURORA (
         .clk_out1      ( init_clk    ), // 14.99985
         .resetn        ( ps_rst_ni   ), // input reset
         .locked        ( locked      ), // output locked
         .clk_in1       ( ps_clk_i    )); // input clk_in1

///// RX PORT (A)
   aurora_64b66b_SL AURORA_RX  (
     .rxn                  ( rxn_A_i ),
     .rxp                  ( rxp_A_i ),
     .gt_refclk1_p         ( gt_refclk1_p       ), // input wire gt_refclk1_p
     .gt_refclk1_n         ( gt_refclk1_n       ), // input wire gt_refclk1_n
     .init_clk             ( init_clk           ), // input wire init_clk
     .reset_pb             ( reset_pb           ), // input wire reset_pb
     .pma_init             ( pma_init           ), // input wire pma_init
     .m_axi_rx_tvalid      ( axi_rx_tvalid_RX  ), // output wire m_axi_rx_tvalid
     .m_axi_rx_tdata       ( axi_rx_tdata_RX   ), // output wire [0 : 63] m_axi_rx_tdata
     .m_axi_rx_tkeep       (                   ), // output wire [0 : 7] m_axi_rx_tkeep
     .m_axi_rx_tlast       ( axi_rx_tlast_RX   ), // output wire m_axi_rx_tlast
     .power_down           ( 1'b0               ), // input wire power_down
     .gt_rxcdrovrden_in    ( 1'b0               ), // input wire gt_rxcdrovrden_in
     .gt_refclk1_out       ( gt_refclk1         ), // output wire gt_refclk1_out
     .user_clk_out         ( user_clk           ), // output wire user_clk_out
     .mmcm_not_locked_out  ( mmcm_not_locked    ), // output wire mmcm_not_locked_out
     .reset2fc             (                    ), // output wire reset2fc
     .rx_channel_up        ( channel_RX_up      ), // output wire channel_up
     .rx_lane_up           ( lane_RX_up         ), // output wire lane_up
     .rx_hard_err          (                    ), // output wire hard_err
     .rx_soft_err          (                    ), // output wire soft_err
     .tx_out_clk           (                    ), // output wire tx_out_clk
     .gt_pll_lock          ( gt_pll_lock        ), // output wire gt_pll_lock
     .gt0_drpaddr          ( 10'd0              ), // input wire [9 : 0] gt0_drpaddr
     .gt0_drpdi            ( 16'd0              ), // input wire [15 : 0] gt0_drpdi
     .gt0_drprdy           (                    ), // output wire gt0_drprdy
     .gt0_drpwe            ( 1'b0               ), // input wire gt0_drpwe
     .gt0_drpen            ( 1'b0               ), // input wire gt0_drpen
     .gt0_drpdo            (                    ), // output wire [15 : 0] gt0_drpdo
     .link_reset_out       (                    ), // output wire link_reset_out
     .sys_reset_out        ( sys_reset          ), // output wire sys_reset_out
     .gt_reset_out         ( gt_reset           ), // output wire gt_reset_out
     .gt_powergood         (                    )  // output wire [1 : 0] gt_powergood
   );
///// TX PORT (B)
   aurora_64b66b_NSL AURORA_TX  (
   // FOR SIMULATIONS
      .txn                 ( txn_B_o ),
      .txp                 ( txp_B_o ),
      .init_clk            ( init_clk           ), // input wire init_clk
   // QPLL CONTROL
      .mmcm_not_locked     ( mmcm_not_locked  ), // input wire mmcm_not_locked
      .refclk1_in          ( gt_refclk1       ), // input wire refclk1_in
      .user_clk            ( user_clk         ), // input wire user_clk
      .sync_clk            (          ), // input wire sync_clk
      .reset_pb            ( sys_reset        ), // input wire reset_pb
      .pma_init            ( gt_reset         ), // input wire pma_init
      .s_axi_tx_tvalid     ( axi_tx_tvalid_TX  ), // input wire s_axi_tx_tvalid
      .s_axi_tx_tdata      ( axi_tx_tdata_TX   ), // input wire [0 : 127] s_axi_tx_tdata
      .s_axi_tx_tkeep      ( axi_tx_tkeep_TX   ), // input wire [0 : 15] s_axi_tx_tkeep
      .s_axi_tx_tlast      ( axi_tx_tlast_TX   ), // input wire s_axi_tx_tlast
      .s_axi_tx_tready     ( axi_tx_tready_TX  ), // output wire s_axi_tx_tready
      .tx_channel_up       ( channel_TX_up     ), // output wire channel_up
      .tx_lane_up          ( lane_TX_up        ), // output wire [0 : 1] lane
      .power_down          ( 1'b0             ), // input wire power_down
      .gt_rxcdrovrden_in   ( 1'b0             ), // input wire gt_rxcdrovrden_in
      .gt0_drpaddr         ( 10'd0 ),// input wire [9 : 0] gt0_drpaddr
      .gt0_drpdi           ( 16'd0 ),// input wire [15 : 0] gt0_drpdi
      .gt0_drpwe           ( 1'b0  ),// input wire gt0_drpwe
      .gt0_drpen           ( 1'b0  ),// input wire gt0_drpen
      .tx_hard_err         (  ), 
      .tx_soft_err         (  ), 
      .tx_out_clk          (  ), 
      .bufg_gt_clr_out     (  ), 
      .gt_pll_lock         (  ), 
      .gt0_drprdy          (  ), 
      .gt0_drpdo           (  ), 
      .link_reset_out      (  ), 
      .reset2fg            (  ), 
      .sys_reset_out       (  ), 
      .gt_powergood        (  )
      );
   
      assign aurora_ds[0] = ~mmcm_not_locked;
      assign aurora_ds[1] = gt_pll_lock ;
      assign aurora_ds[2] = channel_RX_up ; 
      assign aurora_ds[3] = 1'b0 ; 
      assign aurora_ds[4] = 1'b0 ; ;
      assign aurora_ds[5] = channel_TX_up ; 
      assign aurora_ds[6] = ready_o ; 
   end

endgenerate

always_ff @ (posedge init_clk, negedge ps_rst_ni) begin
   if (!ps_rst_ni) begin         
      pma_init   <= 1'b1 ;
      reset_pb   <= 1'b1 ;
   end else begin
      pma_init   <= 1'b0 ;
      reset_pb   <= pma_init;
   end
end

assign axi_tx_tkeep_TX = {8{axi_tx_tlast_TX}};
assign user_rst = mmcm_not_locked;

// RECEIVE
///////////////////////////////////////////////////////////////////////////////
reg [63:0]  RX_h_buff, RX_dt_buff;
reg [ 5:0]  RX_cnt;
reg         RX_req;

// Capture Data From RX
always_ff @ (posedge user_clk) begin
   if (user_rst) begin
      RX_cnt      <= 8'd0;
      RX_h_buff   <= 63'd0 ;
      RX_dt_buff  <= '{default:'0};
   end else begin
      if (axi_rx_tvalid_RX)
         if (axi_rx_tlast_RX) begin
            RX_dt_buff  <= axi_rx_tdata_RX ;
            RX_cnt      <= RX_cnt + 1'b1;
         end else
            RX_h_buff   <= axi_rx_tdata_RX ;
   end
end


// DECODING INCOMING TRANSMISSION
wire [ 1:0] cmd_type;
wire [ 4:0] cmd_id;
wire [ 2:0] cmd_flg;
wire [ 9:0] cmd_dst, cmd_src, cmd_step, cmd_step_p1;
wire [23:0] cmd_hdt;
wire last_step;

assign cmd_type = RX_h_buff[63:62];
assign cmd_id   = RX_h_buff[61:57];
assign cmd_flg  = RX_h_buff[56:54];
assign cmd_dst  = RX_h_buff[53:44];
assign cmd_src  = RX_h_buff[43:34];
assign cmd_step = RX_h_buff[33:24];
assign cmd_hdt  = RX_h_buff[23: 0];
assign cmd_step_p1   = cmd_step + 1'b1;
assign last_step     = &cmd_step ;

reg net_id_ok, net_dst_ones, net_dst_own, net_src_own; 
reg net_sync, net_process, net_propagate ;

always_comb begin
  net_sync        = cmd_flg[2];
  net_id_ok       = |ID_i ;
  net_dst_ones    = &cmd_dst ; //Send to ALL
  net_dst_own     = net_id_ok & (cmd_dst == ID_i);
  net_src_own     =             (cmd_src == ID_i);
  net_process     = !last_step & ( net_dst_own | net_src_own | net_dst_ones) ;
  net_propagate   = !last_step & ( ~net_process ) ;
end


// TRANSMIT
///////////////////////////////////////////////////////////////////////////////
wire TX_req_loc ;
reg TX_req_net ;
reg TX_ack, cmd_req_set;

sync_reg # (
   .DW ( 1 )
) sync_tx_i (
   .dt_i      ( {tx_req_i } ) ,
   .clk_i     ( user_clk       ) ,
   .rst_ni    ( ~user_rst       ) ,
   .dt_o      ( {TX_req_loc}    ) );

reg          TX_req ;
reg [63:0]   TX_h_buff, TX_dt_buff      ;
reg [ 5:0]   TX_cnt;


always_ff @ (posedge user_clk, posedge user_rst) begin
   if (user_rst) begin
      TX_cnt     <= 0;
      TX_req     <= 1'b0;
      TX_h_buff  <= 63'd0 ;
      TX_dt_buff <= 63'd0;
   end else begin
      if (TX_req_loc) begin
         TX_req     <= 1'b1;
         TX_h_buff  <= tx_header_i ;
         TX_dt_buff <= {tx_data_i[1],tx_data_i[0]} ;
       end else if (TX_req_net) begin
         TX_req     <= 1'b1;
         TX_h_buff  <= { RX_h_buff[63:34], cmd_step_p1, RX_h_buff[23:0] } ;
         TX_dt_buff <= RX_dt_buff;
      end
      if (TX_req & TX_ack) 
         if (!TX_req_loc & !TX_req_net) begin
            TX_req    <= 0;
            TX_cnt      <= TX_cnt + 1'b1;
         end
   end
end

reg idle_ing;

// TIMEOUT
reg [9:0] time_cnt;
reg time_cnt_msb;
always_ff @ (posedge user_clk ) begin
   if (user_rst) begin
      time_cnt      <= 1 ;
      time_cnt_msb  <= 0 ;
   end else begin
      if (idle_ing | ~ready)   time_cnt  <= 0;
      else                       time_cnt  <= time_cnt + 1'b1;
      time_cnt_msb  <= time_cnt[9];
   end
end
assign time_out = time_cnt[9] & ~time_cnt_msb;




enum {NOT_RDY, IDLE, RX, PROCESS, PROPAGATE, TX_H, TX_D, WAIT_nREQ } tnet_st_nxt, tnet_st;

always_ff @(posedge user_clk)
   if (user_rst)     tnet_st  <= NOT_RDY;
   else              tnet_st  <= tnet_st_nxt;

assign channel_ok = channel_RX_up & channel_TX_up;

reg cmd_req, ready ;
reg exec_cnt_en, proc_cnt_en ;
always_comb begin
   tnet_st_nxt      = tnet_st; //Stay current state
   TX_req_net       = 1'b0;
   TX_ack           = 1'b0 ;
   idle_ing         = 1'b0;
   cmd_req_set      = 1'b0;
   ready            = 1'b1;
   axi_tx_tvalid_TX = 1'b0;
   axi_tx_tdata_TX  = 63'd0;
   axi_tx_tlast_TX  = 1'b0;
   cmd_req          = 1'b0;
   exec_cnt_en      = 1'b0;
   proc_cnt_en      = 1'b0;
   case (tnet_st)
      NOT_RDY: begin
         ready   = 1'b0;
         if ( channel_ok       )    tnet_st_nxt = IDLE;
      end
      IDLE: begin
         idle_ing  = 1;
         if       ( axi_rx_tlast_RX )  tnet_st_nxt = RX;
         else if  ( TX_req          )  tnet_st_nxt = TX_H;
      end
      RX: begin
         if       ( net_process        )  tnet_st_nxt = PROCESS   ;
         else if  ( net_propagate      )  tnet_st_nxt = PROPAGATE ;
      end
      PROCESS: begin
         cmd_req  = 1'b1;
         tnet_st_nxt    = IDLE ;
         exec_cnt_en = 1'b1;
      end
      PROPAGATE: begin
         TX_req_net = 1'b1 ;
         if ( !net_sync ) begin
            tnet_st_nxt = TX_H ;
            proc_cnt_en = 1'b1;

         end else if ( !axi_tx_tready_TX ) begin 
           tnet_st_nxt = TX_H;
           proc_cnt_en = 1'b1;
        end
      end
      TX_H: begin
         TX_ack = 1'b1 ;
         if  ( axi_tx_tready_TX ) begin
            axi_tx_tvalid_TX   = 1'b1;
            axi_tx_tdata_TX    = TX_h_buff;
            tnet_st_nxt        = TX_D;
         end
      end
      TX_D: begin
         TX_ack = 1'b1 ;
         if  ( axi_tx_tready_TX ) begin
            axi_tx_tvalid_TX   = 1'b1;
            axi_tx_tlast_TX    = 1'b1;
            axi_tx_tdata_TX    = TX_dt_buff;
            tnet_st_nxt        = WAIT_nREQ;
         end
      end
      WAIT_nREQ: begin
         TX_ack = 1'b1 ;
         if  ( !TX_req )  tnet_st_nxt = IDLE;
      end
   endcase
   // IF TIMEOUT OR CHANNEL NOT READY
   if ( !channel_ok | time_out )     tnet_st_nxt = NOT_RDY;
end

reg usr_ready_r;
// Register Output
always_ff @(posedge user_clk)
   if (user_rst) begin
      usr_ready_r  <= 1'b0;
   
   end else begin
      usr_ready_r  <= ready;
   end








///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DEBUG
///////////////////////////////////////////////////////////////////////////////
      reg [3:0] EX_cnt;
      reg [3:0] PR_cnt;
      reg [31:0]   pr_status_ds, ex_status_ds;
generate
   if (DEBUG) begin : DEBUG_BLOCK
      always_ff @(posedge user_clk)
         if (user_rst) begin
            EX_cnt    <= 0;
            PR_cnt    <= 0;
            pr_status_ds    <= 0;
            ex_status_ds    <= 0;
            
         end else begin
            if ( proc_cnt_en )  begin
               PR_cnt    <= PR_cnt+1'b1;
      pr_status_ds  = {net_src_own, net_dst_own, net_dst_ones, TX_h_buff[53:34], TX_h_buff[61:57], PR_cnt[3:0] } ;
            end
            if ( exec_cnt_en    )  begin
               EX_cnt      <= EX_cnt+1'b1;
      ex_status_ds  = {net_src_own, net_dst_own, net_dst_ones, RX_h_buff[53:34], RX_h_buff[61:57], EX_cnt[3:0] } ;
            end
         end
   end else begin
      always_comb begin
         PR_cnt     = 1'b0 ;
         pr_status_ds  = 1'd0 ;
         EX_cnt     = 1'b0 ;
         ex_status_ds  = 64'd0 ;
      end
   end
endgenerate




wire [5:0] rx_buff_d, tx_buff_d ;
assign rx_buff_d = {RX_h_buff[45:44], RX_h_buff[35:34], RX_h_buff[25:24] }  ;
assign tx_buff_d = {TX_h_buff[45:44], TX_h_buff[35:34], TX_h_buff[25:24] }  ;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// OUTPUTS
///////////////////////////////////////////////////////////////////////////////

   
reg tx_ack_r, cmd_req_r, cmd_req_r2, ready_r;
 

(* ASYNC_REG = "TRUE" *) reg tx_ack_cdc, cmd_req_cdc, ready_cdc;
always_ff @(posedge c_clk_i)
   if (!c_rst_ni) begin
      ready_cdc    <= 0;
      ready_r      <= 0;
      tx_ack_cdc   <= 0;
      tx_ack_r     <= 0;
      cmd_req_cdc  <= 0;
      cmd_req_r    <= 0;
      cmd_req_r2   <= 0;
   end else begin
      ready_cdc     <= usr_ready_r;
      ready_r       <= ready_cdc;
      tx_ack_cdc     <= TX_ack;
      tx_ack_r       <= tx_ack_cdc;
      cmd_req_cdc     <= cmd_req;
      cmd_req_r       <= cmd_req_cdc;
      cmd_req_r2      <= cmd_req_r;
   end

assign tx_ack_o      = tx_ack_r ;
assign cmd_req_set_o = !cmd_req_r2  & cmd_req_r ;
assign cmd_dt_o         = {RX_h_buff, RX_dt_buff} ;
assign ready_o       = ready_r;

///// DEBUG
assign axi_rx_tvalid_A_RX_do  = axi_rx_tvalid_RX ;
assign axi_rx_tdata_A_RX_do   = axi_rx_tdata_RX  ;
assign axi_rx_tlast_A_RX_do   = axi_rx_tlast_RX  ;
assign axi_tx_tvalid_B_TX_do  = axi_tx_tvalid_TX ;
assign axi_tx_tdata_B_TX_do   = axi_tx_tdata_TX  ;
assign axi_tx_tlast_B_TX_do   = axi_tx_tlast_TX  ;
assign axi_tx_tready_B_TX_do  = axi_tx_tready_TX ;

assign user_clk_do   = user_clk;
assign rx_status_do  = {RX_h_buff[3:0], RX_h_buff[29:24], RX_h_buff[37:34], RX_h_buff[47:44], RX_h_buff[61:54], RX_cnt[5:0] } ;
assign tx_status_do  = {TX_h_buff[3:0], TX_h_buff[29:24], TX_h_buff[37:34], TX_h_buff[47:44], TX_h_buff[61:54], TX_cnt[5:0] } ;
assign pr_status_do  = pr_status_ds;
assign ex_status_do  = ex_status_ds;
assign aurora_do   = { TX_ack, tx_req_i, aurora_ds } ;
assign link_st_do  = tnet_st[2:0] ;

endmodule
