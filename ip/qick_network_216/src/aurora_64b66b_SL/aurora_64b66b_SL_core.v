 ///////////////////////////////////////////////////////////////////////////////
 //
 // Project:  Aurora 64B/66B 
 // Company:  Xilinx
 //
 //
 //
 // (c) Copyright 2008 - 2009 Xilinx, Inc. All rights reserved.
 //
 // This file contains confidential and proprietary information
 // of Xilinx, Inc. and is protected under U.S. and
 // international copyright and other intellectual property
 // laws.
 //
 // DISCLAIMER
 // This disclaimer is not a license and does not grant any
 // rights to the materials distributed herewith. Except as
 // otherwise provided in a valid license issued to you by
 // Xilinx, and to the maximum extent permitted by applicable
 // law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
 // WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
 // AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
 // BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
 // INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
 // (2) Xilinx shall not be liable (whether in contract or tort,
 // including negligence, or under any other theory of
 // liability) for any loss or damage of any kind or nature
 // related to, arising under or in connection with these
 // materials, including for any direct, or any indirect,
 // special, incidental, or consequential loss or damage
 // (including loss of data, profits, goodwill, or any type of
 // loss or damage suffered as a result of any action brought
 // by a third party) even if such damage or loss was
 // reasonably foreseeable or Xilinx had been advised of the
 // possibility of the same.
 //
 // CRITICAL APPLICATIONS
 // Xilinx products are not designed or intended to be fail-
 // safe, or for use in any application requiring fail-safe
 // performance, such as life-support or safety devices or
 // systems, Class III medical devices, nuclear facilities,
 // applications related to the deployment of airbags, or any
 // other applications that could lead to death, personal
 // injury, or severe property or environmental damage
 // (individually and collectively, "Critical
 // Applications"). Customer assumes the sole risk and
 // liability of any use of Xilinx products in Critical
 // Applications, subject only to applicable laws and
 // regulations governing limitations on product liability.
 //
 // THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
 // PART OF THIS FILE AT ALL TIMES.
 
 //
 ///////////////////////////////////////////////////////////////////////////////
 //
 //aurora_64b66b_SL
 //
 //
 //
 //  Description: This is the top level interface module 
 //               aurora_top_simplex_64b66b
 //
 ///////////////////////////////////////////////////////////////////////////////
 
 `timescale 1 ns / 10 ps
 
   (* core_generation_info = "aurora_64b66b_SL,aurora_64b66b_v12_0_9,{c_aurora_lanes=1,c_column_used=left,c_gt_clock_1=GTYQ0,c_gt_clock_2=None,c_gt_loc_1=1,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=X,c_gt_loc_16=X,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=4,c_line_rate=1.25,c_gt_type=GTYE4,c_qpll=false,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=156.25,c_simplex=true,c_simplex_mode=RX,c_stream=false,c_ufc=false,c_user_k=false,flow_mode=None,interface_mode=Framing,dataflow_config=RX-only_Simplex}" *) 
(* DowngradeIPIdentifiedWarnings="yes" *) 
 module aurora_64b66b_SL_core #
 (
      parameter   SIM_GTXRESET_SPEEDUP=   0,  // Set to 1 to speed up sim reset
      parameter   SIMPLEX_TIMER_VALUE = 12,    // Sets simplex channel init counter    
 
      parameter CC_FREQ_FACTOR = 5'd24, // Its highly RECOMMENDED that this value be NOT changed.
                                        // Changing it to a value greater than 24 may result in soft errors.  
                                        // User may reduce to a value lower than 24 if channel needs to be 
                                        // established in noisy environment
                                        // Min value is 4.  
                                        // The current GAP in between two consecutive DO_CC posedge events is 4992 user_clk cycles. 
 
     parameter   EXAMPLE_SIMULATION =   0       // RXCDR lock time
      //pragma translate_off
        | 1
      //pragma translate_on
 )
 (
 
     // AXI RX Interface
     m_axi_rx_tdata,
     m_axi_rx_tvalid,
     m_axi_rx_tkeep,
     m_axi_rx_tlast,
 
 
 
 
     // GTX Serial I/O
     rxp,
     rxn,
 
    // GTX Reference Clock Interface
     gt_refclk1,
                                                                                 
     // Status Interface
     rx_hard_err,
     rx_soft_err,
     rx_channel_up,
     rx_lane_up,
 
     // System Interface
mmcm_not_locked,
     user_clk,
     reset2fc,
     sysreset_to_core,
     gt_rxcdrovrden_in,
     power_down,
     pma_init,
     rst_drp_strt,


    //---------------------- GT DRP Ports ----------------------
       gt0_drpaddr,
       gt0_drpdi,
       gt0_drpdo, 
       gt0_drprdy, 
       gt0_drpen, 
       gt0_drpwe, 
     init_clk,
     link_reset_out,
   gt_rxusrclk_out,
       //------------------------ RX Margin Analysis Ports ------------------------
       gt_eyescandataerror,
       gt_eyescanreset,
       gt_eyescantrigger,
       //------------------- Receive Ports - RX Equalizer Ports -------------------
       gt_rxcdrhold,
       gt_rxdfelpmreset,
       gt_rxlpmen,
       gt_rxpmareset,
       gt_rxpcsreset,
//     gt_rxuserrdy,
       gt_rxrate,
       gt_rxbufreset,
       gt_rxpmaresetdone,
       gt_rxprbssel,    
       gt_rxprbserr, 
       gt_rxprbscntreset,
       gt_rxresetdone,
       gt_rxbufstatus, 
       gt_pcsrsvdin,
       gt_dmonitorout,
       gt_cplllock    ,


       gt_powergood,


       gt_pll_lock,
     sys_reset_out,
     bufg_gt_clr_out,// connect to clk locked port of clock module
     tx_out_clk
 );
 
 `define DLY #1
 localparam wait_for_fifo_wr_rst_busy_value = 6'd32;
 localparam INTER_CB_GAP = 5'd15;
 localparam SEQ_COUNT = 4;
 localparam BACKWARD_COMP_MODE1 = 1'b0; //disable check for interCB gap
 localparam BACKWARD_COMP_MODE2 = 1'b0; //reduce RXCDR lock time, Block Sync SH max count, disable CDR FSM in wrapper
 localparam BACKWARD_COMP_MODE3 = 1'b0; //clear hot-plug counter with any valid btf detected

 
 //***********************************Port Declarations*******************************
 
   
     // RX AXI Interface 
       output [0:63]     m_axi_rx_tdata; 
       output [0:7]      m_axi_rx_tkeep; 
       output             m_axi_rx_tlast; 
       output             m_axi_rx_tvalid; 
 
 
 
     // GTX Serial I/O
       input             rxp; 
       input             rxn; 
     // GTX Reference Clock Interface
       input              gt_refclk1; 
 
     // Status Interface
       output            rx_hard_err; 
       output            rx_soft_err; 
       output             rx_channel_up; 
       output             rx_lane_up; 
 
     // System Interface
       input               mmcm_not_locked; 
       input               user_clk; 
       output              reset2fc; 
       input               sysreset_to_core; 
       input               gt_rxcdrovrden_in; 
       input               power_down; 
       input               pma_init; 
       input               rst_drp_strt;
       output              sys_reset_out; 
//---{


//---}
    //---------------------- GT DRP Ports ----------------------
       input   [9:0]   gt0_drpaddr;
       input   [15:0]  gt0_drpdi;
       output  [15:0]  gt0_drpdo; 
       output          gt0_drprdy; 
       input           gt0_drpen; 
       input           gt0_drpwe; 
       output              gt_pll_lock; 

output bufg_gt_clr_out;



       output              tx_out_clk;
       output gt_rxusrclk_out;
       //------------------------ RX Margin Analysis Ports ------------------------
       output [0:0]         gt_eyescandataerror;
       input  [0:0]         gt_eyescanreset;
       input  [0:0]         gt_eyescantrigger;
       //------------------- Receive Ports - RX Equalizer Ports -------------------
       input  [0:0]         gt_rxcdrhold;
       input  [0:0]         gt_rxdfelpmreset;
       input  [0:0]         gt_rxlpmen;
       input  [0:0]         gt_rxpmareset;
       input  [0:0]         gt_rxpcsreset;
//     input  [0:0]         gt_rxuserrdy;
       input  [2:0]       gt_rxrate;
       input  [0:0]         gt_rxbufreset;
       output [0:0]         gt_rxpmaresetdone;
       input  [3:0]       gt_rxprbssel;    
       input  [0:0]         gt_rxprbscntreset;
       output [0:0]         gt_rxprbserr;
       output [0:0]         gt_rxresetdone;
       output [2:0]       gt_rxbufstatus;
       input  [15:0]  gt_pcsrsvdin;
 
       output [15:0]      gt_dmonitorout;
       output [0:0]         gt_cplllock    ;


       output [0:0]           gt_powergood;



       input              init_clk; 
       output             link_reset_out; 
 
 //*********************************Wire Declarations**********************************
 
       wire                drp_clk;
       wire                reset_neg_pma_init;
       reg                 rst_drp=1'b1;
       reg                 pma_init_r;
       wire    [0:63]     tx_d_i2; 
       wire               tx_src_rdy_n_i2; 
       wire               tx_dst_rdy_n_i2; 
       wire    [0:2]      tx_rem_i2; 
       wire    [0:2]      tx_rem_i3; 
       wire               tx_sof_n_i2; 
       wire               tx_eof_n_i2; 
       wire    [0:63]     rx_d_i2; 
       wire               rx_src_rdy_n_i2; 
       wire    [0:2]      rx_rem_i2; 
       wire    [0:2]      rx_rem_i3; 
       wire               rx_sof_n_i2; 
       wire               rx_eof_n_i2;
 
 
       wire    [0:63]     rx_d_i; 
       wire               rx_src_rdy_n_i; 
       wire    [0:2]      rx_rem_i; 
       wire               rx_sof_n_i; 
       wire               rx_eof_n_i; 
 
 
 
 
       wire                system_reset_c; 
       wire               gt_pll_lock_i; 
       wire               gt_pll_lock_ii; 
       wire               raw_tx_out_clk_i; 
       wire               ch_bond_done_i; 
       wire               rx_channel_up_i; 
       wire    [0:63]     rx_pe_data_i; 
       wire               rx_pe_data_v_i; 
       wire    [0:63]     rx_data_i; 
       wire               rx_lossofsync_i; 
       wire               check_polarity_i; 
       wire               rx_neg_i; 
       wire               rx_polarity_i; 
       wire               rx_hard_err_i; 
       wire               rx_soft_err_i; 
       wire               rx_lane_up_i; 
       wire               rx_buf_err_i; 
       wire               rx_header_1_i; 
       wire               rx_header_0_i; 
       wire               rx_header_err_i;
       wire               rx_reset_i; 
       wire               reset_lanes_i; 
       wire               en_chan_sync_rx; 
       wire               chan_bond_reset_i; 
 
 
 
       wire               got_na_idles_i; 
       wire               got_idles_i; 
       wire               got_cc_i; 
       wire               rxdatavalid_to_ll_i; 
       wire               remote_ready_i; 
       wire               got_cb_i; 
 
       wire               rx_sep_i; 
       wire               rx_sep7_i; 
       wire    [0:2]      rx_sep_nb_i; 
 
 
     
     //Datavalid signal is routed to Local Link
       wire               rxdatavalid_i; 
       wire               rxdatavalid_to_lanes_i; 
 
       wire               drp_clk_i;
       wire    [9:0] drpaddr_in_i;
       wire    [15:0]     drpdi_in_i;
       wire    [15:0]     drpdo_out_i; 
       wire               drprdy_out_i; 
       wire               drpen_in_i; 
       wire               drpwe_in_i; 
       wire               fsm_resetdone; 
       wire               link_reset_i; 
       wire               mmcm_not_locked_i; 

 
       reg                rx_soft_err; 
  
       wire               reset; 
 
       wire    RESET2FC_i;
       reg                RESET2FC_r; 
 
      wire sysreset_to_core_sync;
      wire             pma_init_sync; 

       wire [0:0] in_polarity_i; 
       wire [0:0] hld_polarity_i; 
       wire [0:0] polarity_val_i; 
 
 //*********************************Main Body of Code**********************************
     // BYTE SWAP LOGIC 
 
      assign reset    = sys_reset_out;

     // Connect top level logic
 
     assign          rx_channel_up  = rx_channel_up_i;
 
     always @(posedge user_clk)
       if(reset)
               rx_soft_err  <= `DLY 1'b0;
       else
               rx_soft_err  <= `DLY (|rx_soft_err_i) & rx_channel_up_i;
 
 
 
     // Connect the TXOUTCLK of lane 0 to TX_OUT_CLK
 
       assign  tx_out_clk  =   raw_tx_out_clk_i; 
  
       assign  gt_pll_lock =   gt_pll_lock_i;
 
     assign  rxdatavalid_to_lanes_i = |rxdatavalid_i;

       assign sysreset_to_core_sync = sysreset_to_core;

       assign pma_init_sync = pma_init;

    // RESET_LOGIC instance
    aurora_64b66b_SL_RESET_LOGIC core_reset_logic_i
    (
        .RESET(sysreset_to_core_sync),
        .USER_CLK(user_clk),
        .INIT_CLK(init_clk),
	.FSM_RESETDONE(fsm_resetdone),
	.POWER_DOWN(power_down),
        .LINK_RESET_IN(link_reset_i),
        .SYSTEM_RESET(sys_reset_out)
    );

 
      assign link_reset_out   =  link_reset_i;
 

 
     //_________________________Instantiate Lane 0______________________________
 
       assign         rx_lane_up =   rx_lane_up_i; 
 
 
 
aurora_64b66b_SL_SIMPLEX_RX_AURORA_LANE simplex_rx_aurora_lane_0_i
     (
 
    //----------------- Receive Ports - Polarity Determination Ports ----------
         .IN_POLARITY   (in_polarity_i[0]),          
         .HLD_POLARITY  (hld_polarity_i[0]),           
         .POLARITY_VAL  (polarity_val_i[0]),         
         // RX LL 
         .RX_PE_DATA(rx_pe_data_i[0:63]),
         .RX_PE_DATA_V(rx_pe_data_v_i), 
 
         .RX_CHANNEL_UP(rx_channel_up_i),
 
         .RX_SEP7(rx_sep7_i), 
         .RX_SEP(rx_sep_i), 
         .RX_SEP_NB(rx_sep_nb_i[0:2]),
 
 
 
 
         // GTX Interface
         .RX_DATA(rx_data_i[0:63]),
         .RX_HEADER_1(rx_header_1_i), 
         .RX_HEADER_0(rx_header_0_i), 
           .RX_HEADER_ERR(rx_header_err_i),
         .RX_BUF_ERR(|rx_buf_err_i),
         .CHECK_POLARITY(check_polarity_i), 
         .RX_NEG(rx_neg_i), 
         .RX_POLARITY(rx_polarity_i), 
         .RX_RESET(rx_reset_i), 
         .RX_LOSSOFSYNC(rx_lossofsync_i), 
         
         // Global Logic Interface
         .RX_LANE_UP(rx_lane_up_i), 
         .RX_HARD_ERR(rx_hard_err_i), 
         .RX_SOFT_ERR(rx_soft_err_i), 
         .GOT_NA_IDLE(got_na_idles_i), 
         .RXDATAVALID_TO_LL(rxdatavalid_to_ll_i), 
         .GOT_CC(got_cc_i), 
         .REMOTE_READY(remote_ready_i), 
         .GOT_CB(got_cb_i), 
         .GOT_IDLE(got_idles_i), 

         // System Interface
         .USER_CLK(user_clk),
         .RESET_LANES(reset_lanes_i),
         .RXDATAVALID_IN(rxdatavalid_to_lanes_i),
         .RESET2FC(RESET2FC_i),
         .RESET(reset)
     );
 
 
 
     //_________________________Instantiate GTX Wrapper ______________________________
 
aurora_64b66b_SL_WRAPPER  #
     (
         .INTER_CB_GAP(INTER_CB_GAP),
         .wait_for_fifo_wr_rst_busy_value   (wait_for_fifo_wr_rst_busy_value),
         .BACKWARD_COMP_MODE1(BACKWARD_COMP_MODE1),
         .BACKWARD_COMP_MODE2(BACKWARD_COMP_MODE2),
         .BACKWARD_COMP_MODE3(BACKWARD_COMP_MODE3),
          .EXAMPLE_SIMULATION(EXAMPLE_SIMULATION)
     )
aurora_64b66b_SL_wrapper_i
     (

    //----------------- Receive Ports - Polarity Determination Ports ----------
         .IN_POLARITY   (in_polarity_i),          
         .HLD_POLARITY  (hld_polarity_i),           
         .POLARITY_VAL  (polarity_val_i),         

         .gt_rxusrclk_out (gt_rxusrclk_out),
    //------------------------ RX Margin Analysis Ports ------------------------
         .GT_eyescandataerror             (gt_eyescandataerror    ),
         .GT_eyescanreset                 (gt_eyescanreset   ),
         .GT_eyescantrigger               (gt_eyescantrigger   ),
    //------------------- Receive Ports - RX Equalizer Ports -------------------
         .GT_rxcdrhold                    (gt_rxcdrhold   ),
         .GT_rxdfelpmreset                (gt_rxdfelpmreset   ),
         .GT_rxlpmen                      (gt_rxlpmen   ),
         .gt_RXPMARESET                   (gt_rxpmareset   ),
         .gt_rxpcsreset                   (gt_rxpcsreset    ),
//       .gt_rxuserrdy                    (gt_rxuserrdy   ),
         .gt_rxrate                       (gt_rxrate      ),
         .gt_rxbufreset                   (gt_rxbufreset    ),
         .gt_rxpmaresetdone                (gt_rxpmaresetdone     ),
         .gt_rxprbssel                     (gt_rxprbssel        ),
         .gt_rxprbserr                     (gt_rxprbserr        ),
         .gt_rxprbscntreset                (gt_rxprbscntreset   ),
         .gt_rxresetdone                  (gt_rxresetdone),
         .gt_rxbufstatus                   (gt_rxbufstatus    ), 
        .gt_pcsrsvdin                     (gt_pcsrsvdin   ),
        .gt_dmonitorout                   (gt_dmonitorout        ),
        .gt_cplllock                      (gt_cplllock    ),

    //----------- GT POWERGOOD STATUS Port -----------
          .gt_powergood                   (gt_powergood),


         // Aurora Lane Interface
         .CHECK_POLARITY_IN(check_polarity_i), 
         .RX_NEG_OUT(rx_neg_i), 
         .RXPOLARITY_IN(rx_polarity_i), 
         .RXRESET_IN(rx_reset_i), 
         .RXDATA_OUT(rx_data_i[0:63]),
         .RXBUFERR_OUT(rx_buf_err_i),         
         .CHBONDDONE_OUT(ch_bond_done_i), 
         // Global Logic Interface
         .ENCHANSYNC_IN(en_chan_sync_rx), 
         // Serial IO
         .RX1N_IN(rxn),       
         .RX1P_IN(rxp),      
         .RXLOSSOFSYNC_OUT(rx_lossofsync_i), 
         .RXHEADER_OUT({rx_header_1_i,rx_header_0_i}), 
           .RXHEADER_OUT_ERR({rx_header_err_i}),
         .RXDATAVALID_OUT(rxdatavalid_i), 
 
          // Clocks and Clock Status
         .RXUSRCLK2_IN(user_clk),
         .CHAN_BOND_RESET(chan_bond_reset_i),
         .GT_RXCDROVRDEN_IN(gt_rxcdrovrden_in),

         .REFCLK1_IN(gt_refclk1),
         .TXOUTCLK1_OUT(raw_tx_out_clk_i), 
         .PLLLKDET_OUT(gt_pll_lock_i), 
         .FSM_RESETDONE(fsm_resetdone),  
         // System Interface
         .GTXRESET_IN(pma_init_sync),
         .LOOPBACK_IN(3'b000),
         .POWERDOWN_IN(power_down),
         .CHANNEL_UP_RX_IF(rx_channel_up_i),
         .CHANNEL_UP_TX_IF(rx_channel_up_i),
//---{



//---}
    //---------------------- GT DRP Ports ----------------------
         .DRP_CLK_IN (init_clk), 
         .gt0_drpaddr(gt0_drpaddr),
         .gt0_drpdi(gt0_drpdi),
         .gt0_drpdo(gt0_drpdo), 
         .gt0_drprdy(gt0_drprdy), 
         .gt0_drpen(gt0_drpen), 
         .gt0_drpwe(gt0_drpwe), 
         .INIT_CLK           (init_clk),
         .LINK_RESET_OUT     (link_reset_i),
		 .USER_CLK           (user_clk),
         .bufg_gt_clr_out               (bufg_gt_clr_out),// connect to clk locked port of clock module
         .gtwiz_userclk_tx_active_out   (mmcm_not_locked_i),// connect to clocking module//

         .RESET(reset)
 
     );

     assign mmcm_not_locked_i = mmcm_not_locked;

 
 
 
aurora_64b66b_SL_SIMPLEX_RX_GLOBAL_LOGIC simplex_rx_global_logic_i
     (
         //GTX Interface
         .CH_BOND_DONE(ch_bond_done_i),
         .EN_CHAN_SYNC(en_chan_sync_rx),
         .CHAN_BOND_RESET(chan_bond_reset_i),
 
         // Aurora Lane Interface
         .RX_LANE_UP(rx_lane_up_i),
         .RX_HARD_ERR(rx_hard_err_i),
         .RESET_LANES(reset_lanes_i),
         .GOT_NA_IDLES(got_na_idles_i),
         .GOT_CCS(got_cc_i),
         .REMOTE_READY(remote_ready_i),
         .GOT_CBS(got_cb_i),
         .GOT_IDLES(got_idles_i),
 
         // System Interface
         .USER_CLK(user_clk),
         .RESET(reset),
         .RX_CHANNEL_UP(rx_channel_up_i),
         .RX_CHANNEL_HARD_ERR(rx_hard_err)
 
     );
 
 
 //_____________________________ RX AXI SHIM _______________________________


 
 
     
 
 
     // RX LOCALLINK
aurora_64b66b_SL_SIMPLEX_RX_LL simplex_rx_ll_i
    (
         // LocalLink RX Interface
        //AXI4-Stream Interface
         .m_axi_rx_tdata  (m_axi_rx_tdata),
         .m_axi_rx_tkeep  (m_axi_rx_tkeep),
         .m_axi_rx_tvalid (m_axi_rx_tvalid),
         .m_axi_rx_tlast  (m_axi_rx_tlast),
 
         // Aurora Lane Interface
         .RX_PE_DATA(rx_pe_data_i),
         .RX_PE_DATA_V(rx_pe_data_v_i),
         .RX_SEP(rx_sep_i),
         .RX_SEP7(rx_sep7_i),
         .RX_SEP_NB(rx_sep_nb_i),
 
 
 
 
 
         .RXDATAVALID_TO_LL(rxdatavalid_to_ll_i),
           .RX_CC(got_cc_i), 
           .RX_CB(got_cb_i), 
         .RX_IDLE(got_idles_i),
 
         // Global Logic Interface
         .RX_CHANNEL_UP(rx_channel_up_i),
 
         // System Interface 
         .USER_CLK(user_clk),
         .RESET(reset_lanes_i)
    );
 
 


          assign drp_clk = init_clk;
  
    always @(posedge init_clk)
    begin
        if (rst_drp_strt)
            rst_drp   <= `DLY 1'b1;
        else if (reset_neg_pma_init)
            rst_drp   <= `DLY 1'b0;
    end

    always @(posedge init_clk)
        pma_init_r    <= `DLY pma_init_sync;

    assign reset_neg_pma_init = (!pma_init_sync) & pma_init_r;



         assign  RESET2FC_ii  = RESET2FC_i ;

    always @(posedge user_clk)
         RESET2FC_r <= `DLY RESET2FC_ii;

    assign reset2fc = RESET2FC_r;


 endmodule

