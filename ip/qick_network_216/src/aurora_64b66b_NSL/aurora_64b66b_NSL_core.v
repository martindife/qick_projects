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
 //aurora_64b66b_NSL
 //
 //
 //
 //  Description: This is the top level interface module 
 //               aurora_top_simplex_64b66b
 //
 ///////////////////////////////////////////////////////////////////////////////
 
 `timescale 1 ns / 10 ps
 
   (* core_generation_info = "aurora_64b66b_NSL,aurora_64b66b_v12_0_9,{c_aurora_lanes=1,c_column_used=left,c_gt_clock_1=GTYQ0,c_gt_clock_2=None,c_gt_loc_1=1,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=X,c_gt_loc_16=X,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=4,c_line_rate=1.25,c_gt_type=GTYE4,c_qpll=false,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=156.25,c_simplex=true,c_simplex_mode=TX,c_stream=false,c_ufc=false,c_user_k=false,flow_mode=None,interface_mode=Framing,dataflow_config=TX-only_Simplex}" *) 
(* DowngradeIPIdentifiedWarnings="yes" *) 
 module aurora_64b66b_NSL_core #
 (
      parameter   SIM_GTXRESET_SPEEDUP=   0,  // Set to 1 to speed up sim reset
     parameter   PERIODIC_CB_COUNT =   20'd163839,       // CB SEQ COUNT
 
// Its highly RECOMMENDED that the PERIODIC_CB_COUNT value be NOT changed. 
// The minimum value is set when the C_EXAMPLE_SIMULATION user parameter is enabled.
// The maximum value is set when the C_EXAMPLE_SIMULATION user parameter is disabled.
// Its RECOMMENDED that the value (163839) be not changed.
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
     // AXI TX Interface
     s_axi_tx_tdata,
     s_axi_tx_tvalid,
     s_axi_tx_tready,
     s_axi_tx_tkeep,
     s_axi_tx_tlast,
 
 
 
 
 
     // GTX Serial I/O
     txp,
     txn,
 
    // GTX Reference Clock Interface
     gt_refclk1,
                                                                                 
     // Status Interface
     tx_hard_err,
     tx_soft_err,
     tx_channel_up,
     tx_lane_up,
 
     // System Interface
mmcm_not_locked,
     user_clk,
     sync_clk,
     reset2fg,
     sysreset_to_core,
     gt_rxcdrovrden_in,
     power_down,
     pma_init,


    //---------------------- GT DRP Ports ----------------------
       gt0_drpaddr,
       gt0_drpdi,
       gt0_drpdo, 
       gt0_drprdy, 
       gt0_drpen, 
       gt0_drpwe, 
     init_clk,
     link_reset_out,


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
 
     // TX AXI Interface 
       input  [0:63]     s_axi_tx_tdata; 
       input  [0:7]      s_axi_tx_tkeep; 
       input             s_axi_tx_tlast; 
       input             s_axi_tx_tvalid; 
       output            s_axi_tx_tready; 
   
 
 
 
     // GTX Serial I/O
       output             txp; 
       output             txn; 
     // GTX Reference Clock Interface
       input              gt_refclk1; 
 
     // Status Interface
       output            tx_hard_err; 
       output            tx_soft_err; 
       output             tx_channel_up; 
       output             tx_lane_up; 
 
     // System Interface
       input               mmcm_not_locked; 
       input               user_clk; 
       input               sync_clk; 
       output              reset2fg; 
       input               sysreset_to_core; 
       input               gt_rxcdrovrden_in; 
       input               power_down; 
       input               pma_init; 
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


       output [0:0]           gt_powergood;



       input              init_clk; 
       output             link_reset_out; 
 
 //*********************************Wire Declarations**********************************
 
       wire                drp_clk;
       wire                rst_drp;
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
 
       wire    [0:63]     tx_d_i; 
       wire               tx_src_rdy_n_i; 
       wire               tx_dst_rdy_n_i; 
       wire    [0:2]      tx_rem_i; 
       wire               tx_sof_n_i; 
       wire               tx_eof_n_i; 
 
 
 
 
       wire                system_reset_c; 
       wire               gt_pll_lock_i; 
       wire               gt_pll_lock_ii; 
       wire               raw_tx_out_clk_i; 
       wire    [0:63]     tx_data_i; 
       wire    [0:63]     tx_pe_data_i; 
       wire               tx_pe_data_v_i; 
       wire               tx_channel_up_i; 
       wire               tx_buf_err_i; 
       wire               tx_header_1_i; 
       wire               tx_header_0_i; 
       wire               tx_ena_comma_align_i; 
       wire               tx_reset_i; 
       wire               tx_hard_err_i; 
       wire               tx_soft_err_i; 
       wire               tx_lane_up_i; 
       wire               gen_na_idles_i; 
       wire               reset_lanes_i; 
       wire               gen_sep_i; 
       wire               gen_sep7_i; 
       wire    [0:2]      sep_nb_i; 
 
 
 
       wire               gen_ch_bond_i; 
       wire               gen_cc_i; 
 
 
 
     
     //Datavalid signal is routed to Local Link
       wire               txdatavalid_i; 
       wire               txdatavalid_symgen_i;
       wire               periodic_cb_to_ll; 
       wire               periodic_cb_seq; 
       wire               gen_periodic_cb_i; 
 
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

       wire               do_cc_i;
 
       reg                tx_soft_err; 
  
       wire               reset; 
 
 
      wire sysreset_to_core_sync;
      wire             pma_init_sync; 

 
 //*********************************Main Body of Code**********************************
     // BYTE SWAP LOGIC 
 
      assign reset    = sys_reset_out;

     // Connect top level logic
     assign          tx_channel_up  = tx_channel_up_i;
    
     always @(posedge user_clk)
       if(reset)
               tx_soft_err  <= `DLY 1'b0;
       else  
               tx_soft_err  <= `DLY (|tx_soft_err_i) & tx_channel_up_i;
 
 
     // Connect the TXOUTCLK of lane 0 to TX_OUT_CLK
 
       assign  tx_out_clk  =   raw_tx_out_clk_i; 
  
       assign  gt_pll_lock =   gt_pll_lock_i;
 

    aurora_64b66b_NSL_rst_sync #
    (
        .c_mtbf_stages (5)
    )reset_pb_sync
    (
        .prmry_in     (sysreset_to_core),
        .scndry_aclk  (user_clk),
        .scndry_out   (sysreset_to_core_sync)
    );

    aurora_64b66b_NSL_rst_sync #
    (
        .c_mtbf_stages (5)
    )gt_reset_sync
    (
        .prmry_in     (pma_init),
        .scndry_aclk  (init_clk),
        .scndry_out   (pma_init_sync)
    );

    // RESET_LOGIC instance
    aurora_64b66b_NSL_RESET_LOGIC core_reset_logic_i
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
       assign         tx_lane_up =   tx_lane_up_i; 
 
 
aurora_64b66b_NSL_SIMPLEX_TX_AURORA_LANE # 
(
  .EXAMPLE_SIMULATION(EXAMPLE_SIMULATION)    
)
simplex_tx_aurora_lane_0_i
     (
         // TX LL 
         .TX_PE_DATA(tx_pe_data_i[0:63]),
         .TX_PE_DATA_V(tx_pe_data_v_i), 
         .GEN_SEP7(gen_sep7_i), 
         .GEN_SEP(gen_sep_i), 
         .SEP_NB(sep_nb_i[0:2]),
 
 
 
 
         .TX_CHANNEL_UP(tx_channel_up_i),
         .GEN_CC(gen_cc_i), 
         .GEN_PERIODIC_CB(gen_periodic_cb_i),
 
         // GTX Interface
         .TX_BUF_ERR(|tx_buf_err_i),
         .TX_HEADER_1(tx_header_1_i), 
         .TX_HEADER_0(tx_header_0_i), 
         .TX_DATA(tx_data_i[0:63]),
         .TX_RESET(tx_reset_i), 
         .TX_RESETDONE_IN(fsm_resetdone),
         
         // Comma Detect Phase Align Interface
         .TX_ENA_COMMA_ALIGN(tx_ena_comma_align_i), 
 
         // Global Logic Interface
         .GEN_NA_IDLE(gen_na_idles_i),
         .GEN_CH_BOND(gen_ch_bond_i), 
         .TX_LANE_UP(tx_lane_up_i), 
         .TX_HARD_ERR(tx_hard_err_i), 
         .TX_SOFT_ERR(tx_soft_err_i), 
 
         // System Interface
         .USER_CLK(user_clk),
         .SYNC_CLK(sync_clk),
         .RESET_LANES(reset_lanes_i),
         .TXDATAVALID_SYMGEN_IN(txdatavalid_symgen_i),
         .GTXRESET_IN(pma_init_sync),
         .RESET(reset)
     );
 
 
 
 
     //_________________________Instantiate GTX Wrapper ______________________________
 
aurora_64b66b_NSL_WRAPPER  #
     (
         .INTER_CB_GAP(INTER_CB_GAP),
         .wait_for_fifo_wr_rst_busy_value   (wait_for_fifo_wr_rst_busy_value),
         .BACKWARD_COMP_MODE1(BACKWARD_COMP_MODE1),
         .BACKWARD_COMP_MODE2(BACKWARD_COMP_MODE2),
         .BACKWARD_COMP_MODE3(BACKWARD_COMP_MODE3),
          .EXAMPLE_SIMULATION(EXAMPLE_SIMULATION)
     )
aurora_64b66b_NSL_wrapper_i
     (



    //----------- GT POWERGOOD STATUS Port -----------
          .gt_powergood                   (gt_powergood),


         .GT_RXCDROVRDEN_IN(gt_rxcdrovrden_in),

         .TXDATA_IN(tx_data_i[0:63]),
         .TXRESET_IN(tx_reset_i),         
         .TXBUFERR_OUT(tx_buf_err_i),               
         
         // Serial IO
         .TX1N_OUT(txn),        
         .TX1P_OUT(txp), 
         .TXHEADER_IN({tx_header_1_i,tx_header_0_i}), 
         .TXDATAVALID_OUT(txdatavalid_i),
         .TXDATAVALID_SYMGEN_OUT        (txdatavalid_symgen_i),

         // Clocks and Clock Status
         .TXUSRCLK_IN			(sync_clk),
         .TXUSRCLK2_IN			(user_clk),
         .REFCLK1_IN(gt_refclk1),
         .TXOUTCLK1_OUT(raw_tx_out_clk_i), 
         .PLLLKDET_OUT(gt_pll_lock_i), 
         .FSM_RESETDONE(fsm_resetdone),  
         // System Interface
         .GTXRESET_IN(pma_init_sync),
         .LOOPBACK_IN(3'b000),
         .POWERDOWN_IN(power_down),
         .CHANNEL_UP_RX_IF(tx_channel_up_i),
         .CHANNEL_UP_TX_IF(tx_channel_up_i),
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

     assign mmcm_not_locked_i = !mmcm_not_locked;

 
 
     //__________Instantiate Global Logic to combine Lanes into a Channel______
 
aurora_64b66b_NSL_SIMPLEX_TX_GLOBAL_LOGIC #
     (
         .INTER_CB_GAP(INTER_CB_GAP),
         .PERIODIC_CB_COUNT(PERIODIC_CB_COUNT),
         .SIMPLEX_TIMER_VALUE(SIMPLEX_TIMER_VALUE)
     )
     simplex_tx_global_logic_i
     (
         // Aurora Lane Interface
         .TX_LANE_UP(tx_lane_up_i),
         .TX_HARD_ERR(tx_hard_err_i),
         .GEN_NA_IDLES(gen_na_idles_i),
         .GEN_CH_BOND(gen_ch_bond_i),
         .PERIODIC_CB_TO_LL(periodic_cb_to_ll),
         .PERIODIC_CB_SEQ(periodic_cb_seq),
         .RESET_LANES(reset_lanes_i),
 
         // System Interface
         .USER_CLK(user_clk),
         .RESET(reset),
         .RESET2FG(reset2fg),
         .DO_CC(do_cc_i),
         .TX_CHANNEL_UP(tx_channel_up_i),
         .TX_CHANNEL_HARD_ERR(tx_hard_err),
         .TXDATAVALID_IN(txdatavalid_i)
     );
 
 
     //_____________________________ TX AXI SHIM _______________________________
     // Converts input AXI4-Stream signals to LocalLink



 
 
 
 
 
 
    // TX LOCALLINK
aurora_64b66b_NSL_SIMPLEX_TX_LL #
( 
    .INTER_CB_GAP(INTER_CB_GAP)
)
simplex_tx_ll_i
     (
          // S_AXI_TX Interface
         .s_axi_tx_tdata  (s_axi_tx_tdata),
         .s_axi_tx_tkeep  (s_axi_tx_tkeep),
         .s_axi_tx_tlast  (s_axi_tx_tlast),
         .s_axi_tx_tvalid (s_axi_tx_tvalid),
         .s_axi_tx_tready (s_axi_tx_tready),
         // Clock Compenstaion Interface
         .DO_CC(do_cc_i),
         .PERIODIC_CB_TO_LL(periodic_cb_to_ll),
         .PERIODIC_CB_SEQ(periodic_cb_seq),
 

 
 
 
         // Global Logic Interface
         .TX_CHANNEL_UP(tx_channel_up_i),
 
         // Aurora Lane Interface
         .GEN_SEP(gen_sep_i),
         .GEN_SEP7(gen_sep7_i),
         .SEP_NB(sep_nb_i),
 
 
         .TX_PE_DATA_V(tx_pe_data_v_i),
         .TX_PE_DATA(tx_pe_data_i),
         .GEN_CC(gen_cc_i),
         .GEN_PERIODIC_CB(gen_periodic_cb_i),
 
         // System Interface
         .USER_CLK(user_clk),
         .RESET(reset_lanes_i),
         .TXDATAVALID_IN(txdatavalid_i)
    );
     
 
 

      assign rst_drp = pma_init_sync; 

    // Standard CC Module
aurora_64b66b_NSL_STANDARD_CC_MODULE #
(
    .CC_FREQ_FACTOR (CC_FREQ_FACTOR)
)
standard_cc_module_i
    (
         .DO_CC         (do_cc_i),
         .USER_CLK      (user_clk),
         .CHANNEL_UP    (tx_channel_up_i) 
    );


 endmodule

