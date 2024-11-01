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
 //  SIMPLEX RX AURORA_LANE
 //
 //
 //  Description: The AURORA_LANE module provides a full duplex  aurora
 //               lane connection using a single MGT.  The module handles lane
 //               initialization, symbol generation and decoding as well as
 //               error detection.  It also decodes some of the channel bonding
 
 //               indicator signals needed by the Global logic.
 //
 //
 ///////////////////////////////////////////////////////////////////////////////
 
 `timescale 1 ns / 10 ps
 
(* DowngradeIPIdentifiedWarnings="yes" *)
 module aurora_64b66b_SL_SIMPLEX_RX_AURORA_LANE
 (
 
    //----------------- Receive Ports - Polarity Determination Ports ----------
     IN_POLARITY,            
     HLD_POLARITY,             
     POLARITY_VAL,           
    // RX Frame Interface
 
     RX_PE_DATA,
     RX_PE_DATA_V,
 
     RX_CHANNEL_UP,
 
     RX_SEP7,
     RX_SEP,
     RX_SEP_NB,
 
 
 
     // MGT Interface
     RX_DATA,
     RX_HEADER_1,
     RX_HEADER_0,
     RX_HEADER_ERR,
     RX_BUF_ERR,
     CHECK_POLARITY,
     RX_NEG,
     RX_POLARITY,
     RX_RESET,
     RX_LOSSOFSYNC,
     RXDATAVALID_IN,
     
     // Global Logic Interface
     RX_LANE_UP,
     RX_HARD_ERR,
     RX_SOFT_ERR,
     RXDATAVALID_TO_LL,
     GOT_CC,
     REMOTE_READY,
     GOT_CB,
     GOT_NA_IDLE,
     GOT_IDLE,
     
     //System Interface
     USER_CLK,
     RESET_LANES,
     RESET2FC,
     RESET
 );
 
 //***********************************Port Declarations*******************************
 
    //----------------- Receive Ports - Polarity Determination Ports ----------
       output               IN_POLARITY;         // informing in polarity     
       input                HLD_POLARITY;        // holding polarity state      
       input                POLARITY_VAL;        // polarity determined       

  
     // RX  Interface
       output    [0:63]     RX_PE_DATA; 
       output               RX_PE_DATA_V; 
 
       input                RX_CHANNEL_UP; 
 
       output               RX_SEP7; 
       output               RX_SEP; 
       output    [0:2]      RX_SEP_NB; 
 
 
     // MGT Interface
       input     [63:0]     RX_DATA;               // 8-byte data bus from the MGT. 
       input                RX_HEADER_1 ;           // Bit 0 sync header of block code on RX_DATA. 
       input                RX_HEADER_0 ;          // Bit 1 sync header of block code on RX_DATA. 
       input                RX_HEADER_ERR ;          
       input                RX_LOSSOFSYNC;          // Alignment status from block lock state machine in mgt 
       input                RX_BUF_ERR;             // Overflow/Underflow of RX buffer detected. 
       output               CHECK_POLARITY;         // Controls interpreted polarity of serial data inputs. 
       input                RX_NEG;                 // Controls interpreted polarity of serial data inputs. 
       output               RX_POLARITY;            // Controls interpreted polarity of serial data inputs. 
       output               RX_RESET;               // Reset RX side of MGT logic. 
       input                RXDATAVALID_IN; 
 
     // Global Logic Interface
       output               RX_LANE_UP;             // Lane is ready for bonding and verification. 
       output               RX_HARD_ERR;          // Hard error detected. 
       output               RX_SOFT_ERR;          // Soft error detected. 
       output               GOT_NA_IDLE;            // Not-Aligned Idle symbols received. 
       output               RXDATAVALID_TO_LL;      // RXDATAVALID_TO_LL received. 
       output               GOT_CC;                 // Not-Aligned Idle symbols received. 
       output               REMOTE_READY;           // Remote Ready signal for channel init sm. 
       output               GOT_CB;                 // Not-Aligned Idle symbols received. 
       output               GOT_IDLE;               // Aligned Idle symbols received. 
 
 
     // System Interface
       input                USER_CLK;               // System clock for all non-MGT Aurora Logic. 
       input                RESET_LANES;            // Reset the lane. 
       output              RESET2FC; 
       input                RESET;                  // Global Reset . 
 
 //*********************************Wire Declarations**********************************
 
       wire                  rx_enable_err_detect_i; 
       wire                  rx_hard_err_reset_i; 
       wire                  illegal_btf_i; 
 
 //*********************************Main Body of Code**********************************
 
 
     // Lane Initialization state machine
aurora_64b66b_SL_SIMPLEX_RX_LANE_INIT_SM simplex_rx_lane_init_sm_i
     (
    //----------------- Receive Ports - Polarity Determination Ports ----------
         .IN_POLARITY   (IN_POLARITY),          
         .HLD_POLARITY  (HLD_POLARITY),           
         .POLARITY_VAL  (POLARITY_VAL),         

         // MGT Interface
         .RX_LOSSOFSYNC(RX_LOSSOFSYNC),
 
         .RX_RESET(RX_RESET),
         .RX_POLARITY(RX_POLARITY),
         .CHECK_POLARITY(CHECK_POLARITY),
 
          // Symbol Decoder Interface
         .RX_NEG(RX_NEG),
 
         // Error Detection Logic Interface
         .RX_HARD_ERR_RESET(rx_hard_err_reset_i),
 
         .RX_ENABLE_ERR_DETECT(rx_enable_err_detect_i),
 
         // Global Logic Interface
         .RX_LANE_UP(RX_LANE_UP),
         .RX_CHANNEL_UP(RX_CHANNEL_UP),
 
         // System Interface
         .USER_CLK(USER_CLK),
         .RESET_LANES(RESET_LANES),
         .RESET(RESET)
     );
 
     // Symbol Decode module
aurora_64b66b_SL_SYM_DEC sym_dec_i
     (
         // Lane Init SM Interface
         .LANE_UP(RX_LANE_UP),
         .RX_NA_IDLE(GOT_NA_IDLE),
         .RXDATAVALID_TO_LL(RXDATAVALID_TO_LL),
         .RX_CC(GOT_CC),
         .REMOTE_READY(REMOTE_READY),
         .RX_CB(GOT_CB),
         .RX_IDLE(GOT_IDLE),
 
         // RX  Interface
         .RX_PE_DATA(RX_PE_DATA),
         .RX_PE_DATA_V(RX_PE_DATA_V),
         .RX_SEP7(RX_SEP7),
         .RX_SEP(RX_SEP),
         .RX_SEP_NB(RX_SEP_NB),
 
 
 
         //Error Detect Interface
         .ILLEGAL_BTF(illegal_btf_i),
 
         // MGT Interface
         .RX_DATA(RX_DATA),
 
         .RX_HEADER_1(RX_HEADER_1),
         .RX_HEADER_0(RX_HEADER_0),
         .RXDATAVALID_IN(RXDATAVALID_IN),
 
         // System Interface
         .USER_CLK(USER_CLK),
         .RESET2FC(RESET2FC),
         .RESET(RESET)
     );
 
     // Error Detection module
aurora_64b66b_SL_SIMPLEX_RX_ERR_DETECT simplex_rx_err_detect_i
     (
         // Lane Init SM Interface
         .RX_ENABLE_ERR_DETECT(rx_enable_err_detect_i),
 
         .RX_HARD_ERR_RESET(rx_hard_err_reset_i),
 
         // Global Logic Interface
         .RX_HARD_ERR(RX_HARD_ERR),
         .RX_SOFT_ERR(RX_SOFT_ERR),
 
         //Sym decoder interface
         .ILLEGAL_BTF(illegal_btf_i),
   
         // MGT Interface
         .RX_BUF_ERR(RX_BUF_ERR),
         .RX_HEADER_1(RX_HEADER_1),
         .RX_HEADER_0(RX_HEADER_0),
         .RX_HEADER_ERR(RX_HEADER_ERR),
         .RXDATAVALID_IN(RXDATAVALID_IN),
 
         // System Interface
         .USER_CLK(USER_CLK)
     );
 
 endmodule
