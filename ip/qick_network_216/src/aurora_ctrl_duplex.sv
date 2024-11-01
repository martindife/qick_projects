module aurora_ctrl_duplex # (
   parameter SIM_LEVEL = 1
)( 
// Core, Time and AXI CLK & RST.
   input  wire             gt_refclk1_p     ,
   input  wire             gt_refclk1_n     ,
   input  wire             t_clk_i          ,
   input  wire             t_rst_ni         ,
   input  wire             ps_clk_i         , //99.999001
   input  wire             ps_rst_ni        ,
// Data 
   input  wire  [6 :0]     ID_i             ,
   input  wire  [6 :0]     NN_i             ,
// Transmittion 
   input  wire             tx_req_i         ,
   input  wire             tx_ch_i          ,
   input  wire [63 :0]     tx_header_i      ,
   input  wire [31 :0]     tx_data_i [2]       ,
   output reg              tx_ack_o        ,
   output wire             link_A_rdy_01       ,
   output wire             link_B_rdy_01       ,
   output wire             link_A_rdy_cc       ,
   output wire             link_B_rdy_cc       ,
   output reg [31:0]       qnet_LINK_o     ,
// Command Processing  
   output reg              cmd_net_o       ,
   output reg              cmd_ch_o        ,
   output reg  [63:0]      cmd_o[2]        ,
   output reg              ready_o         ,
///////////////// SIMULATION    
   input  wire             rxn_A_i        ,
   input  wire             rxp_A_i        ,
   output wire             txn_A_o        ,
   output  wire            txp_A_o        ,
   input  wire             rxn_B_i        ,
   input  wire             rxp_B_i        ,
   output wire             txn_B_o        ,
   output  wire            txp_B_o        ,
// A and B DUPLEX CONNECTION
////////////////   CHANNEL A LINK
   input  wire             axi_rx_tvalid_A_RX_i  ,
   input  wire  [63:0]     axi_rx_tdata_A_RX_i   ,
   input  wire             axi_rx_tlast_A_RX_i   ,
   output reg   [63:0]     axi_tx_tdata_A_TX_o   ,
   output reg              axi_tx_tvalid_A_TX_o  ,
   output reg              axi_tx_tlast_A_TX_o   ,
   input  wire             axi_tx_tready_A_TX_i  ,
////////////////   CHANNEL B LINK
   input  wire             axi_rx_tvalid_B_RX_i  ,
   input  wire  [63:0]     axi_rx_tdata_B_RX_i   ,
   input  wire             axi_rx_tlast_B_RX_i   ,
   output reg   [63:0]     axi_tx_tdata_B_TX_o   ,
   output reg              axi_tx_tvalid_B_TX_o  ,
   output reg              axi_tx_tlast_B_TX_o   ,
   input  wire             axi_tx_tready_B_TX_i  ,
// DEBUGGING
   output wire [3:0]       aurora_do        ,
   output wire             channel_A_up   ,
   output wire             channel_B_up   ,
   output reg  [7:0]       pack_cnt_do     ,
   output reg  [3:0]       last_op_do      ,
   output reg  [2:0]       state_do        );

////////////////////////////////////////////////
// SIGNALS 

//PHY CONNECTION SIGNALS
reg             reset_pb           ;
reg             pma_init           ;


// A and B DUPLEX CONNECTION
wire             axi_rx_tvalid_A_RX, axi_rx_tlast_A_RX, axi_rx_tkeep_A_RX ;
wire  [63:0]     axi_rx_tdata_A_RX   ;
wire             axi_tx_tready_A_TX ;
reg              axi_tx_tvalid_A_TX, axi_tx_tlast_A_TX ;
reg  [63:0]      axi_tx_tdata_A_TX   ;
reg  [7 :0]      axi_tx_tkeep_A_TX   ;

wire             axi_rx_tvalid_B_RX, axi_rx_tlast_B_RX, axi_rx_tkeep_B_RX ;
wire  [63:0]     axi_rx_tdata_B_RX   ;
wire             axi_tx_tready_B_TX ;
reg              axi_tx_tvalid_B_TX, axi_tx_tlast_B_TX ;
reg  [63:0]      axi_tx_tdata_B_TX   ;
reg  [7 :0]      axi_tx_tkeep_B_TX   ;

assign axi_tx_tkeep_A_TX = {8{axi_tx_tlast_A_TX}};
assign axi_tx_tkeep_B_TX = {8{axi_tx_tlast_B_TX}};

reg cmd_req;

wire init_clk;

//OUTPUTS
always_ff @ (posedge init_clk, negedge ps_rst_ni) begin
   if (!ps_rst_ni) begin         
      pma_init   <= 1'b1 ;
      reset_pb   <= 1'b1 ;
   end else begin
      pma_init   <= 1'b0 ;
      reset_pb   <= pma_init;
   end
end
wire user_clk, mmcm_not_locked;

generate
/////////////////////////////////////////////////
   if (SIM_LEVEL == 1) begin : SIM_NO_AURORA
         assign txn_A_o             = 0 ;
         assign txp_A_o             = 0 ;
         assign txn_B_o             = 0 ;
         assign txp_B_o             = 0 ;
      assign aurora_do = 0;

      assign user_clk          = ps_clk_i   ;
      assign mmcm_not_locked   = ~ps_rst_ni ;
      assign init_clk          = 1;
      assign channel_A_up    = 1;
      assign channel_B_up    = 1;

// A and B DUPLEX CONNECTION
// Channel A=0 B=1
      assign axi_rx_tvalid_A_RX   = axi_rx_tvalid_A_RX_i;
      assign axi_rx_tdata_A_RX    = axi_rx_tdata_A_RX_i ;
      assign axi_rx_tlast_A_RX    = axi_rx_tlast_A_RX_i ;

      assign axi_tx_tvalid_A_TX_o = axi_tx_tvalid_A_TX  ;
      assign axi_tx_tdata_A_TX_o  = axi_tx_tdata_A_TX   ;
      assign axi_tx_tlast_A_TX_o  = axi_tx_tlast_A_TX   ;
      assign axi_tx_tready_A_TX   = axi_tx_tready_A_TX_i;

      assign axi_rx_tvalid_B_RX   = axi_rx_tvalid_B_RX_i;
      assign axi_rx_tdata_B_RX    = axi_rx_tdata_B_RX_i ;
      assign axi_rx_tlast_B_RX    = axi_rx_tlast_B_RX_i ;

      assign axi_tx_tvalid_B_TX_o = axi_tx_tvalid_B_TX  ;
      assign axi_tx_tdata_B_TX_o  = axi_tx_tdata_B_TX   ;
      assign axi_tx_tlast_B_TX_o  = axi_tx_tlast_B_TX   ;
      assign axi_tx_tready_B_TX   = axi_tx_tready_B_TX_i;

   end else begin 
      if (SIM_LEVEL == 2) begin : SIM_YES_AURORA
         assign axi_tx_tdata_TX_o   = 0 ;
         assign axi_tx_tvalid_TX_o  = 0 ;
         assign axi_tx_tlast_TX_o   = 0 ;
      end else begin : SYNT_AURORA
         assign txn_o = 0 ;
         assign txp_o = 0 ;
      end
      /////// INIT CLK
      clk_wiz_0 CLK_AURORA (
         .clk_out1      ( init_clk    ), // 14.99985
         .resetn        ( ps_rst_ni  ), // input reset
         .locked        ( locked      ), // output locked
         .clk_in1       ( ps_clk_i      )); // input clk_in1

  
  
// A and B DUPLEX CONNECTION
/////// LINK A
       aurora_A_Duplex_SL link_A (
      .rxp                 ( rxn_A_i              ),  // input wire [0 : 0] rxp
      .rxn                 ( rxp_A_i              ),  // input wire [0 : 0] rxn
      .txp                 ( txp_A_o              ),  // output wire [0 : 0] txp
      .txn                 ( txn_A_o              ),  // output wire [0 : 0] txn
      .gt_refclk1_p        ( gt_refclk1_p         ),  // input wire gt_refclk1_p
      .gt_refclk1_n        ( gt_refclk1_n         ),  // input wire gt_refclk1_n
      .init_clk            ( init_clk             ),  // input wire init_clk
      .reset_pb            ( reset_pb             ),  // input wire reset_pb
      .pma_init            ( pma_init             ),  // input wire pma_init
      .s_axi_tx_tvalid     ( axi_tx_tvalid_A_TX   ) , // input wire s_axi_tx_tvalid
      .s_axi_tx_tdata      ( axi_tx_tdata_A_TX    ) , // input wire [0 : 63] s_axi_tx_tdata
      .s_axi_tx_tlast      ( axi_tx_tlast_A_TX    ) , // input wire s_axi_tx_tlast
      .s_axi_tx_tkeep      ( axi_tx_tkeep_A_TX    ) , // input wire [0 : 7] s_axi_tx_tkeep
      .s_axi_tx_tready     ( axi_tx_tready_A_TX   ) , // output wire s_axi_tx_tready
      .m_axi_rx_tvalid     ( axi_rx_tvalid_A_RX   ) , // output wire m_axi_rx_tvalid
      .m_axi_rx_tdata      ( axi_rx_tdata_A_RX    ) , // output wire [0 : 63] m_axi_rx_tdata
      .m_axi_rx_tlast      ( axi_rx_tlast_A_RX    ) , // output wire m_axi_rx_tlast
      .m_axi_rx_tkeep      ( axi_rx_tkeep_A_RX    ) , // output wire [0 : 7] m_axi_rx_tkeep
      .power_down          ( 1'b0                 ) , // input wire power_down
      .loopback            ( 3'b000               ) , // input wire [2 : 0] loopback
      .gt_rxcdrovrden_in   ( 1'b0                 ) , // input wire gt_rxcdrovrden_in
      .gt_refclk1_out      ( gt_refclk1           ) , // output wire gt_refclk1_out
      .user_clk_out        ( user_clk             ) , // output wire user_clk_out
      .mmcm_not_locked_out ( mmcm_not_locked      ) , // output wire mmcm_not_locked_out
      .hard_err            (                      ) , // output wire hard_err
      .soft_err            (                      ) , // output wire soft_err
      .channel_up          ( channel_A_up         ) , // output wire channel_up
      .lane_up             ( lane_A_up            ) , // output wire [0 : 0] lane_up
      .tx_out_clk          (                      ) , // output wire tx_out_clk
      .gt_pll_lock         ( gt_pll_lock          ) , // output wire gt_pll_lock
      .gt0_drpaddr         ( 10'd0                ) , // input wire [9 : 0] gt0_drpaddr
      .gt0_drpdi           ( 16'd0                ) , // input wire [15 : 0] gt0_drpdi
      .gt0_drprdy          (                      ) , // output wire gt0_drprdy
      .gt0_drpwe           ( 1'b0                 ) , // input wire gt0_drpwe
      .gt0_drpen           ( 1'b0                 ) , // input wire gt0_drpen
      .gt0_drpdo           (                      ) , // output wire [15 : 0] gt0_drpdo
      .link_reset_out      (                      ) , // output wire link_reset_out
      .sys_reset_out       ( sys_resetA           ) , // output wire sys_reset_out
      .gt_reset_out        ( gt_resetA            ) , // output wire gt_reset_out
      .sync_clk_out        (                      ) , // output wire sync_clk_out
      .gt_powergood        (                      )   // output wire [1 : 0] gt_powergood
      );

/////// LINK B     
      aurora_B_Duplex_NSL link_B (
      .rxp                 ( rxn_B_i              ),  // input wire [0 : 0] rxp
      .rxn                 ( rxp_B_i              ),  // input wire [0 : 0] rxn
      .txp                 ( txp_B_o              ),  // output wire [0 : 0] txp
      .txn                 ( txn_B_o              ),  // output wire [0 : 0] txn
      .init_clk            ( init_clk             ),  // input wire init_clk
      .reset_pb            ( reset_pb             ),  // input wire reset_pb
      .pma_init            ( pma_init             ),  // input wire pma_init
      .s_axi_tx_tvalid     ( axi_tx_tvalid_B_TX   ) , // input wire s_axi_tx_tvalid
      .s_axi_tx_tdata      ( axi_tx_tdata_B_TX    ) , // input wire [0 : 63] s_axi_tx_tdata
      .s_axi_tx_tlast      ( axi_tx_tlast_B_TX    ) , // input wire s_axi_tx_tlast
      .s_axi_tx_tkeep      ( axi_tx_tkeep_B_TX    ) , // input wire [0 : 7] s_axi_tx_tkeep
      .s_axi_tx_tready     ( axi_tx_tready_B_TX   ) , // output wire s_axi_tx_tready
      .m_axi_rx_tvalid     ( axi_rx_tvalid_B_RX   ) , // output wire m_axi_rx_tvalid
      .m_axi_rx_tdata      ( axi_rx_tdata_B_RX    ) , // output wire [0 : 63] m_axi_rx_tdata
      .m_axi_rx_tlast      ( axi_rx_tlast_B_RX    ) , // output wire m_axi_rx_tlast
      .m_axi_rx_tkeep      ( axi_rx_tkeep_B_RX    ) , // output wire [0 : 7] m_axi_rx_tkeep
      .power_down          ( 1'b0                 ) , // input wire power_down
      .loopback            ( 3'b000               ) , // input wire [2 : 0] loopback
      .gt_rxcdrovrden_in   ( 1'b0                 ) , // input wire gt_rxcdrovrden_in
      .hard_err            (                      ) , // output wire hard_err
      .soft_err            (                      ) , // output wire soft_err
      .channel_up          ( channel_B_up         ) , // output wire channel_up
      .lane_up             ( lane_B_up            ) , // output wire [0 : 0] lane_up
      .gt_pll_lock         ( gt_pll_lockB         ) , // output wire gt_pll_lock
      .gt0_drpaddr         ( 10'd0                ) , // input wire [9 : 0] gt0_drpaddr
      .gt0_drpdi           ( 16'd0                ) , // input wire [15 : 0] gt0_drpdi
      .gt0_drprdy          (                      ) , // output wire gt0_drprdy
      .gt0_drpwe           ( 1'b0                 ) , // input wire gt0_drpwe
      .gt0_drpen           ( 1'b0                 ) , // input wire gt0_drpen
      .gt0_drpdo           (                      ) , // output wire [15 : 0] gt0_drpdo
      .link_reset_out      (                      ) , // output wire link_reset_out
      .sys_reset_out       ( sys_resetB           ) , // output wire sys_reset_out
      .mmcm_not_locked     ( mmcm_not_locked      ), // input wire mmcm_not_locked
      .refclk1_in          ( gt_refclk1           ), // input wire refclk1_in
      .user_clk            ( user_clk             ), // input wire user_clk
      .tx_out_clk          ( tx_out_clk           ), // output wire tx_out_clk
      .bufg_gt_clr_out     ( bufg_gt_clr_out      ), // output wire bufg_gt_clr_out
      .sync_clk            ( sync_clk             ), // input wire sync_clk
      .gt_powergood        (                      )   // output wire [1 : 0] gt_powergood
     );


      assign aurora_do[0] = ~mmcm_not_locked;
      assign aurora_do[1] = gt_pll_lock ;
      assign aurora_do[2] = channel_A_up ; 
      assign aurora_do[3] = channel_B_up ;
      
   end

endgenerate








reg TX_ack, cmd_req_set;
reg idle_ing;
/////////////////////////////////////////////////
// RECEIVE
reg         RX_A_req, RX_B_req;
reg [63:0]  RX_A_h_buff, RX_B_h_buff;
reg [63:0]  RX_A_dt_buff, RX_B_dt_buff;
reg [ 7:0]  RX_A_cnt, RX_B_cnt;

reg RX_A_ack, RX_B_ack ;
reg RX_A_ack_set, RX_B_ack_set ;
reg [2:0] RX_A_dt_cnt;
wire user_rst;
assign user_rst = mmcm_not_locked;
reg RX_A_wfh;
// In hte Future Size of PACKET A can be MORE than 2
// B is always 2 (ANSWER) 
// Capture Data From Channels_RX
always_ff @ (posedge user_clk, posedge user_rst) begin
   if (user_rst) begin
      RX_A_wfh      <= 1'b1;
      RX_A_req      <= 1'b0;
      RX_A_cnt      <= 8'd0;
      RX_A_h_buff   <= 63'd0 ;
      RX_A_dt_buff  <= '{default:'0};
      RX_B_req      <= 1'b0;
      RX_B_cnt      <= 8'd0;
      RX_B_h_buff   <= 63'd0 ;
      RX_B_dt_buff  <= 63'd0 ;
   end else begin
// CHANNEL A
      if (axi_rx_tvalid_A_RX)
         if (RX_A_wfh) begin
            // First Data (HEADER)
            RX_A_h_buff   <= axi_rx_tdata_A_RX ;
            RX_A_wfh     <= 0;
         end else begin
            if (axi_rx_tlast_A_RX) begin
               RX_A_dt_buff    <= axi_rx_tdata_A_RX ;
               RX_A_wfh        <= 1'b1;
               RX_A_req        <= 1'b1; 
            end
         end
      if (RX_A_ack_set) begin
         RX_A_ack    <= 1;
         RX_A_req    <= 0;
      end else if (idle_ing)
         RX_A_ack    <= 0;

// CHANNEL B
      if (axi_rx_tvalid_B_RX)
         if (axi_rx_tlast_B_RX) begin
            RX_B_req    <= 1; 
            RX_B_dt_buff  <= axi_rx_tdata_B_RX ;
            RX_B_cnt      <= RX_B_cnt + 1'b1;
         end else
            RX_B_h_buff   <= axi_rx_tdata_B_RX ;
      else if (RX_B_ack)
         RX_B_req    <= 0;
      if (RX_B_ack_set) begin
         RX_B_ack    <= 1;
         RX_B_req    <= 0;
      end else if (idle_ing)
         RX_B_ack    <= 0;
   end
end

// DECODING INCOMING TRANSMISSION
wire [63:0] h_buff, dt_buff;
wire [ 9:0] h_dst, h_src, h_step, h_step_new;
wire [ 5:0] h_flags;

assign  h_buff          = RX_B_ack ? RX_B_h_buff  : RX_A_h_buff;
assign  dt_buff         = RX_B_ack ? RX_B_dt_buff : RX_A_dt_buff;

assign  h_flags         = h_buff[55:50];
assign  h_dst           = h_buff[49:40];
assign  h_src           = h_buff[39:30];
assign  h_step          = h_buff[29:20];
assign  h_step_new      = h_step + 1'b1;

reg msg_ok;
reg net_id_ok, net_dst_ones, net_dst_own, net_src_own; 
reg net_sync, net_process, net_propagate ;
always_comb begin
  net_sync        = h_flags[5];
  net_id_ok       = |ID_i ;
  net_dst_ones    = &h_dst ; //Send to ALL
  net_dst_own     = net_id_ok & (h_dst == ID_i);
  net_src_own     =             (h_src == ID_i);
  net_process     = msg_ok & ( net_dst_own | net_src_own | net_dst_ones) ;
  net_propagate   = msg_ok & ( ~net_process ) ;
end





// Detect Edge on TREADY
reg m_axi_ready_A_TX_r, m_axi_ready_A_TX_r2, m_axi_ready_A_TX_r3;
reg m_axi_ready_B_TX_r, m_axi_ready_B_TX_r2, m_axi_ready_B_TX_r3;

always_ff @ (posedge user_clk, posedge user_rst) begin
   if (user_rst) begin
      m_axi_ready_A_TX_r    <= 0;
      m_axi_ready_A_TX_r2   <= 0;
      m_axi_ready_A_TX_r3   <= 0;
      m_axi_ready_B_TX_r    <= 0;
      m_axi_ready_B_TX_r2   <= 0;
      m_axi_ready_B_TX_r3   <= 0;
   end else begin
      m_axi_ready_A_TX_r     <= axi_tx_tready_A_TX;
      m_axi_ready_A_TX_r2    <= m_axi_ready_A_TX_r;
      m_axi_ready_A_TX_r3    <= m_axi_ready_A_TX_r2;
      m_axi_ready_B_TX_r     <= axi_tx_tready_B_TX;
      m_axi_ready_B_TX_r2    <= m_axi_ready_B_TX_r;
      m_axi_ready_B_TX_r3    <= m_axi_ready_B_TX_r2;
   end
end
wire m_axi_ready_A_TX_000, m_axi_ready_B_TX_000;
assign m_axi_ready_A_TX_000    = !m_axi_ready_A_TX_r3 & !m_axi_ready_A_TX_r2 & !m_axi_ready_A_TX_r;
assign m_axi_ready_B_TX_000    = !m_axi_ready_B_TX_r3 & !m_axi_ready_B_TX_r2 & !m_axi_ready_B_TX_r;

reg link_A_rdy_r, link_A_rdy_r2 ;
reg link_A_rdy_000_r, link_A_rdy_000_r2;
wire link_A_rdy_10, link_A_rdy_cc;
(* ASYNC_REG = "TRUE" *) reg link_A_rdy_cdc, link_A_rdy_000_cdc;
always_ff @(posedge t_clk_i)
   if (!t_rst_ni) begin
      link_A_rdy_cdc   <= 0;
      link_A_rdy_r     <= 0;
      link_A_rdy_r2    <= 0;
   end else begin
      link_A_rdy_cdc     <= axi_tx_tready_A_TX;
      link_A_rdy_r       <= link_A_rdy_cdc;
      link_A_rdy_r2      <= link_A_rdy_r;
   end
assign link_A_rdy_01  = !link_A_rdy_r2     &  link_A_rdy_r ;
assign link_A_rdy_10  =  link_A_rdy_r2     & !link_A_rdy_r ;
assign link_A_rdy_cc  = link_A_rdy_01 & m_axi_ready_A_TX_000 ;


reg link_B_rdy_r, link_B_rdy_r2 ;
reg link_B_rdy_000_r, link_B_rdy_000_r2;
wire link_B_rdy_10, link_B_rdy_cc;
(* ASYNC_REG = "TRUE" *) reg link_B_rdy_cdc, link_B_rdy_000_cdc;
always_ff @(posedge t_clk_i)
   if (!t_rst_ni) begin
      link_B_rdy_cdc   <= 0;
      link_B_rdy_r     <= 0;
      link_B_rdy_r2    <= 0;
   end else begin
      link_B_rdy_cdc     <= axi_tx_tready_B_TX;
      link_B_rdy_r       <= link_B_rdy_cdc;
      link_B_rdy_r2      <= link_B_rdy_r;
   end
assign link_B_rdy_01  = !link_B_rdy_r2     &  link_B_rdy_r ;
assign link_B_rdy_10  =  link_B_rdy_r2     & !link_B_rdy_r ;
assign link_B_rdy_cc  =  link_B_rdy_01 & m_axi_ready_B_TX_000 ;


/////////////////////////////////////////////////
// CHECK TRANSMIT
/////////////////////////////////////////////////
// TRANSMIT
wire TX_req_loc ;
reg TX_req_net ;
sync_reg # (
   .DW ( 1 )
) sync_tx_i (
   .dt_i      ( {tx_req_i } ) ,
   .clk_i     ( user_clk       ) ,
   .rst_ni    ( ~user_rst       ) ,
   .dt_o      ( {TX_req_loc}    ) );

reg          TX_req, TX_ch ;
reg [63:0 ]   TX_h_buff, TX_dt_buff      ;

always_ff @ (posedge user_clk, posedge user_rst) begin
   if (user_rst) begin
      TX_req     <= 1'b0;
      TX_ch      <= 1'b0 ;
      TX_h_buff  <= 63'd0 ;
      TX_dt_buff <= 63'd0;
   end else begin
      if (TX_req_loc) begin
         TX_req     <= 1'b1;
         TX_ch      <= tx_ch_i;
         TX_h_buff  <= tx_header_i ;
         TX_dt_buff <= {tx_data_i[1],tx_data_i[0]} ;
       end else if (TX_req_net) begin
         TX_req     <= 1'b1;
         TX_ch      <= 1'b0 ;
         TX_h_buff  <= { h_buff[63:30], h_step_new, h_buff[19:0] } ;
         TX_dt_buff <= dt_buff;
         TX_h_buff  <= tx_header_i ;
         TX_dt_buff <= {tx_data_i[1],tx_data_i[0]} ;
         TX_ch      <= RX_B_ack;
      end
      if (TX_req & TX_ack) 
         if (!TX_req_loc & !TX_req_net)
            TX_req    <= 0;
   end
end

// PACKET STPES
always_comb begin
   msg_ok = 1'b1;
   if (|ID_i & &h_step) msg_ok = 1'b0;
end

// TIMEOUT
reg [9:0] time_cnt;
reg time_cnt_msb;
always_ff @ (posedge user_clk, posedge user_rst) begin
   if (user_rst) begin
      time_cnt      <= 1 ;
      time_cnt_msb  <= 0 ;
   end else begin
      if (idle_ing | ~ready_o)   time_cnt  <= 0;
      else            time_cnt      <= time_cnt + 1'b1;
      time_cnt_msb  <= time_cnt[9];
   end
end
assign time_out = time_cnt[9] & ~time_cnt_msb;

enum {NOT_RDY, IDLE, RX_A, RX_B, PROCESS, PROPAGATE, TX_H, TX_D, WAIT_nREQ } tnet_st_nxt, tnet_st;

always_ff @(posedge user_clk)
   if (user_rst)     tnet_st  <= NOT_RDY;
   else              tnet_st  <= tnet_st_nxt;

assign channel_ok = channel_A_up & channel_B_up;


always_comb begin
   tnet_st_nxt          = tnet_st; //Stay current state
   RX_A_ack_set   = 1'b0;
   RX_B_ack_set   = 1'b0;
   TX_req_net     = 1'b0;
   TX_ack         = 1'b0 ;
   idle_ing             = 1'b0;
   cmd_req_set         = 1'b0;
   ready_o              = 1'b1;
   axi_tx_tvalid_A_TX   = 1'b0;
   axi_tx_tdata_A_TX    = 63'd0;
   axi_tx_tlast_A_TX    = 1'b0;
   axi_tx_tvalid_B_TX   = 1'b0;
   axi_tx_tdata_B_TX    = 63'd0;
   axi_tx_tlast_B_TX    = 1'b0;



   case (tnet_st)
      NOT_RDY: begin
         ready_o = 1'b0;
         if ( channel_ok       )    tnet_st_nxt = IDLE;
      end
      IDLE: begin
         idle_ing  = 1;
         if       ( RX_A_req )  tnet_st_nxt = RX_A;
         else if  ( RX_B_req )  tnet_st_nxt = RX_B;
         else if  ( TX_req   )  tnet_st_nxt = TX_H;
      end
      RX_A: begin
         RX_A_ack_set = 1'b1 ;
         if       ( net_process        )  tnet_st_nxt = PROCESS   ;
         else if  ( net_propagate      )  tnet_st_nxt = PROPAGATE ;
      end
      RX_B: begin
         RX_B_ack_set = 1'b1 ;
         if       ( net_process        )  tnet_st_nxt = PROCESS   ;
         else if  ( net_propagate      )  tnet_st_nxt = PROPAGATE ;
      end
      PROCESS: begin
         cmd_req_set     = 1'b1;
         if (cmd_req) tnet_st_nxt    = IDLE ;
      end
      PROPAGATE: begin
         TX_req_net = 1'b1 ;
         if ( !net_sync )
            tnet_st_nxt = TX_H ;
         else if ( (RX_A_ack & !axi_tx_tready_B_TX) | (RX_B_ack & !axi_tx_tready_A_TX) ) 
           tnet_st_nxt = TX_H;
      end
      TX_H: begin
         TX_ack = 1'b1 ;
         if (!TX_ch & axi_tx_tready_A_TX) begin
            axi_tx_tvalid_A_TX   = 1'b1;
            axi_tx_tdata_A_TX    = TX_h_buff;
            tnet_st_nxt          = TX_D;
         end
         if (TX_ch & axi_tx_tready_B_TX) begin
            axi_tx_tvalid_B_TX   = 1'b1;
            axi_tx_tdata_B_TX    = TX_h_buff;
            tnet_st_nxt          = TX_D;
         end
      end
      TX_D: begin
         TX_ack = 1'b1 ;
         if (!TX_ch & axi_tx_tready_A_TX) begin
            axi_tx_tvalid_A_TX   = 1'b1;
            axi_tx_tdata_A_TX    = TX_dt_buff;
            axi_tx_tlast_A_TX    = 1'b1;
            tnet_st_nxt          = WAIT_nREQ;
         end
         if (TX_ch & axi_tx_tready_B_TX) begin
            axi_tx_tvalid_B_TX   = 1'b1;
            axi_tx_tdata_B_TX    = TX_dt_buff;
            axi_tx_tlast_B_TX    = 1'b1;
            tnet_st_nxt          = WAIT_nREQ;
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


   
   

// OUTPUTS
assign sync_tx_A  = link_A_rdy_01 & !m_axi_ready_A_TX_000 ;
assign sync_tx_B  = link_B_rdy_01 & !m_axi_ready_B_TX_000 ;
assign sync_cc_A  = link_A_rdy_01 &  m_axi_ready_A_TX_000 ;
assign sync_cc_B  = link_B_rdy_01 &  m_axi_ready_B_TX_000 ;



always_ff @(posedge user_clk)
   if (user_rst)   begin
      cmd_req <= 1'b0;
      cmd_ch_o  <= 1'b0;
   end else begin
      if ( cmd_req_set) begin
          cmd_ch_o <= RX_B_ack;
         if ( net_sync )  
            if ( RX_A_ack & link_A_rdy_10) cmd_req  <= 1'b1;
            else if ( RX_B_ack & link_B_rdy_10) cmd_req  <= 1'b1;
         else 
            cmd_req  <= 1'b1;
      end else 
            cmd_req  <= 1'b0;
   end

reg cmd_req_r, cmd_req_r2;
(* ASYNC_REG = "TRUE" *) reg cmd_req_cdc;
always_ff @(posedge t_clk_i)
   if (!t_rst_ni) begin
      cmd_req_cdc   <= 0;
      cmd_req_r     <= 0;
      cmd_req_r2    <= 0;
   end else begin
      cmd_req_cdc     <= cmd_req;
      cmd_req_r       <= cmd_req_cdc;
      cmd_req_r2      <= cmd_req_r;
   end

assign cmd_net_o  = !cmd_req_r2     &  cmd_req_r ;

assign cmd_o       = {h_buff, dt_buff} ;
assign pack_cnt_do = RX_A_cnt ;
assign last_op_do  = h_buff[59:56] ;
assign state_do    = tnet_st[2:0] ;
 
 
  
enum {MEAS_IDLE, MEAS_LINK, MEAS_TSTART, MEAS_TEND} meas_net_st_nxt, meas_net_st;


always_ff @(posedge t_clk_i)
   if (!t_rst_ni)     meas_net_st  <= MEAS_IDLE;
   else              meas_net_st  <= meas_net_st_nxt;

reg cnt_LINK_rst, cnt_LINK_en, update_LINK;

always_comb begin
meas_net_st_nxt = meas_net_st;
   cnt_LINK_rst = 1'b0;
   cnt_LINK_en  = 1'b0;
   update_LINK  = 1'b0;
   case (meas_net_st)
      MEAS_IDLE: begin
         if ( sync_cc_A       )    meas_net_st_nxt = MEAS_LINK;
      end
      MEAS_LINK: begin
         cnt_LINK_rst = 1'b1;
         if ( sync_tx_A       )    meas_net_st_nxt = MEAS_TSTART;
      end
      MEAS_TSTART: begin
         cnt_LINK_en = 1'b1;
         if      ( sync_tx_A       )    meas_net_st_nxt = MEAS_TEND;
         else if ( sync_cc_A       )    meas_net_st_nxt = MEAS_LINK;
      end
      MEAS_TEND: begin
         update_LINK  = 1'b1;
         meas_net_st_nxt   = MEAS_IDLE;
      end
   endcase
end

reg [31:0] cnt_LINK ;
/// Capture Reception Time
always_ff @(posedge t_clk_i) begin
   if       ( cnt_LINK_rst )  cnt_LINK <= 32'd0;
   else if  ( cnt_LINK_en  )  cnt_LINK <= cnt_LINK + 1'b1;
   else if  ( update_LINK  )  qnet_LINK_o <= cnt_LINK; 
end
     
assign tx_ack_o = TX_ack ;
      
endmodule
