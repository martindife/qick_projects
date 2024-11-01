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
 //  SIMPLEX TX AURORA_LANE
 //
 //
 //  Description: The SIMPLEX TX AURORA_LANE module provides a simplex aurora
 //               lane connection using a single GTX.  The module handles lane
 //               initialization, symbol generation and decoding as well as
 //               error detection.  It also decodes some of the channel bonding
 
 //               indicator signals needed by the Global logic.
 //
 //               * Supports Virtex 5
 //
 ///////////////////////////////////////////////////////////////////////////////
 
 `timescale 1 ns / 10 ps
 
(* DowngradeIPIdentifiedWarnings="yes" *)
 module aurora_64b66b_NSL_SIMPLEX_TX_AURORA_LANE # 
 (
     parameter   EXAMPLE_SIMULATION =   0        // Set to 1 to reduce simulation time
      //pragma translate_off
        | 1
      //pragma translate_on
 )
 (
     // TX LL Interface
 
     TX_PE_DATA,
     TX_PE_DATA_V,
 
     GEN_SEP7,
     GEN_SEP,
     SEP_NB,
 
 
 
     GEN_CC,
     GEN_PERIODIC_CB,
     TX_CHANNEL_UP,
     TX_BUF_ERR,
     TX_HEADER_1,
     TX_HEADER_0,
     TX_DATA,
     TX_RESET,
     TX_RESETDONE_IN,
     
     // Comma Detect Phase Align Interface
     TX_ENA_COMMA_ALIGN,
 
     //GTX Interface
     TXDATAVALID_SYMGEN_IN,
 
     // Global Logic Interface
     GEN_NA_IDLE,
     GEN_CH_BOND,
     TX_LANE_UP,
     TX_HARD_ERR,
     TX_SOFT_ERR,
     
     //System Interface
     USER_CLK,
     SYNC_CLK,
     RESET_LANES,
     GTXRESET_IN,
     RESET
 );
 
 //***********************************Port Declarations*******************************
 
     // TX  Interface
       input     [0:63]     TX_PE_DATA; 
       input                TX_PE_DATA_V; 
 
       input                GEN_SEP7; 
       input                GEN_SEP; 
       input     [0:2]      SEP_NB; 
 
 
 
       input                GEN_CC;  
       input                GEN_PERIODIC_CB;  
       input                TX_CHANNEL_UP;  
 
     // GTX Interface
       input                TX_BUF_ERR;             // Overflow/Underflow of TX buffer detected. 
       output               TX_HEADER_1;       // Bit 1 sync header of block code on TX_DATA. 
       output               TX_HEADER_0;      // Bit 0 sync header of block code on TX_DATA. 
       output    [63:0]     TX_DATA;                // data bus to the GTX. 
       output               TX_RESET;               // Reset TX side of GTX logic. 
       input                TX_RESETDONE_IN;        // Resetdone of GTX. 
 
     // Comma Detect Phase Align Interface
       output               TX_ENA_COMMA_ALIGN;        // Request comma alignment. 
 
     // Global Logic Interface
       input                GEN_NA_IDLE;            // Not-Aligned generation request from Global Logic. 
       input                GEN_CH_BOND;            // Channel Bond block code generation request from Global Logic. 
 
       output               TX_LANE_UP;                // Lane is ready for bonding. 
       output               TX_HARD_ERR;             // Hard error detected. 
       output               TX_SOFT_ERR;             // Soft error detected. 
 
 
     // System Interface
       input                USER_CLK;               // System clock for all non-GTX Aurora Logic. 
       input                SYNC_CLK;               // System clock for all non-GTX Aurora Logic. 
       input                RESET_LANES;                  // Reset the lane. 
       input                GTXRESET_IN;                  // pma_init
       input                RESET;                  // Global Reset . 
       input                TXDATAVALID_SYMGEN_IN; 
 //*********************************Wire Declarations**********************************
 
       wire                 tx_enable_err_detect_i; 
       wire                 tx_ard_err_reset_i; 
     
 //*********************************Main Body of Code**********************************
 
 
     // Lane Initialization state machine
aurora_64b66b_NSL_SIMPLEX_TX_LANE_INIT_SM  #
(
    .EXAMPLE_SIMULATION(EXAMPLE_SIMULATION)
)
simplex_tx_lane_init_sm_i
     (
         // GTX Interface
         .TX_RESET(TX_RESET),
 
         // Comma Detect Phase Alignment Interface
         .TX_ENA_COMMA_ALIGN(TX_ENA_COMMA_ALIGN),
 
         // Error Detection Logic Interface
         .TX_HARD_ERR_RESET(tx_hard_err_reset_i),
 
         .TX_ENABLE_ERR_DETECT(tx_enable_err_detect_i),
         .TX_RESETDONE_IN(TX_RESETDONE_IN),
 
         // Global Logic Interface
         .TX_LANE_UP(TX_LANE_UP),
 
         // System Interface
         .USER_CLK(USER_CLK),
         .SYNC_CLK(SYNC_CLK),
         .RESET_LANES(RESET_LANES),
         .RESET(RESET)
     );
 
     // Symbol Generation module
aurora_64b66b_NSL_SYM_GEN sym_gen_i
     (
         // TX Interface
         .TX_PE_DATA(TX_PE_DATA),
         .TX_PE_DATA_V(TX_PE_DATA_V),
 
         .GEN_SEP7(GEN_SEP7),
         .GEN_SEP(GEN_SEP),
         .SEP_NB(SEP_NB),
 
 
 
         // Clock Correction Interface
         .GEN_CC(GEN_CC),
         .GEN_PERIODIC_CB(GEN_PERIODIC_CB),
 
         // Global Logic Interface
         .GEN_NA_IDLE(GEN_NA_IDLE),
         .GEN_CH_BOND(GEN_CH_BOND),
 
         // GTX Interface
         .TX_HEADER_1(TX_HEADER_1),
         .TX_HEADER_0(TX_HEADER_0),
         .TX_DATA(TX_DATA),
         .TXDATAVALID_SYMGEN_IN(TXDATAVALID_SYMGEN_IN),
 
         .CHANNEL_UP(TX_CHANNEL_UP),
 
         // System Interface
         .USER_CLK(USER_CLK),
         .RESET(GTXRESET_IN)
     );
 
     // Error Detection module
aurora_64b66b_NSL_SIMPLEX_TX_ERR_DETECT simplex_tx_err_detect_i
     (
         // Lane Init SM Interface
         .TX_ENABLE_ERR_DETECT(tx_enable_err_detect_i),
 
         .TX_HARD_ERR_RESET(tx_hard_err_reset_i),
 
         // Global Logic Interface
         .TX_HARD_ERR(TX_HARD_ERR),
         .TX_SOFT_ERR(TX_SOFT_ERR),
 
         // GTX Interface
         .TX_BUF_ERR(TX_BUF_ERR),
 
         // System Interface
         .RESET(RESET),
         .USER_CLK(USER_CLK)
     );
 
 endmodule
