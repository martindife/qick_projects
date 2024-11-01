 ///////////////////////////////////////////////////////////////////////////////
 //
 // Project:  Aurora 64B66B 
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
 //  SIMPLEX TX GLOBAL LOGIC
 //
 //  Description: The GLOBAL_LOGIC module handles channel bonding, channel error manangement 
 //               and channel bond block code generation.
 //
 //
 ///////////////////////////////////////////////////////////////////////////////
 
 `timescale 1 ns / 10 ps
 
(* DowngradeIPIdentifiedWarnings="yes" *)
 module aurora_64b66b_NSL_SIMPLEX_TX_GLOBAL_LOGIC #
 (
    parameter  INTER_CB_GAP = 5'd15,
    parameter  PERIODIC_CB_COUNT = 20'd2500,
    parameter SIMPLEX_TIMER_VALUE = 12
 )
 (
     // GTX Interface
 
     // Aurora Lane Interface
     TX_LANE_UP,
     TX_HARD_ERR,
 
     GEN_NA_IDLES,
     GEN_CH_BOND,
     PERIODIC_CB_TO_LL,
     PERIODIC_CB_SEQ,
     RESET_LANES,
      
     // System Interface
     USER_CLK,
     RESET,
     RESET2FG,
     DO_CC,
     TX_CHANNEL_UP,
     TX_CHANNEL_HARD_ERR,
     TXDATAVALID_IN
 
 );
 
 `define DLY #1
 
 //***********************************Port Declarations*******************************
 
     // Aurora Lane Interface
       input                  TX_LANE_UP; 
       input                  TX_HARD_ERR; 
       output                 GEN_NA_IDLES; 
       output                 GEN_CH_BOND; 
       output                 PERIODIC_CB_TO_LL; 
       output                 PERIODIC_CB_SEQ; 
       output                 RESET2FG; 
       output                 RESET_LANES; 
 
     // System Interface
       input                  USER_CLK; 
       input                  RESET; 
       input                  DO_CC; 
       output                 TX_CHANNEL_UP; 
       output                 TX_CHANNEL_HARD_ERR; 
       input                  TXDATAVALID_IN; 
 
 //*********************************Wire Declarations**********************************
 
       wire                   reset_channel_i; 
 
 
 //*********************************Main Body of Code**********************************
 
 
     // State Machine for channel bonding and channel ready.
aurora_64b66b_NSL_SIMPLEX_TX_CHANNEL_INIT_SM #
     (
         .SIMPLEX_TIMER_VALUE(SIMPLEX_TIMER_VALUE)
     )
     simplex_tx_channel_init_sm_i
     (
         // Aurora Lane Interface
         .GEN_NA_IDLES(GEN_NA_IDLES),
         .RESET_LANES(RESET_LANES),
 
         // System Interface
         .USER_CLK(USER_CLK),
         .RESET(RESET),
         .TX_LANE_UP(TX_LANE_UP),
         .TX_CHANNEL_UP(TX_CHANNEL_UP)
 
     );
 
     // Idle sequence generator module.
aurora_64b66b_NSL_SIMPLEX_TX_CH_BOND_CODE_GEN #
     (
       .INTER_CB_GAP(INTER_CB_GAP),
       .PERIODIC_CB_COUNT(PERIODIC_CB_COUNT)
     ) simplex_tx_ch_bond_code_gen_i
     (
         // Channel Init SM Interface
         .TX_CHANNEL_UP(TX_CHANNEL_UP),
 
         // Aurora Lane Interface
         .GEN_CH_BOND(GEN_CH_BOND),
         .PERIODIC_CB_TO_LL(PERIODIC_CB_TO_LL),
         .PERIODIC_CB_SEQ(PERIODIC_CB_SEQ),
 
         // System Interface
         .USER_CLK(USER_CLK),
         .RESET(RESET),
         .RESET2FG(RESET2FG),
         .DO_CC(DO_CC),
         .TXDATAVALID_IN(TXDATAVALID_IN)
     );
 
     // Channel Error Management module.
aurora_64b66b_NSL_SIMPLEX_TX_CHANNEL_ERR_DETECT simplex_tx_channel_err_detect_i
     (
         // Aurora Lane Interface
         .TX_HARD_ERR(TX_HARD_ERR),
         .TX_LANE_UP(TX_LANE_UP),
 
         // System Interface
         .USER_CLK(USER_CLK),
         .TX_CHANNEL_HARD_ERR(TX_CHANNEL_HARD_ERR)
 
     );
 
 endmodule
