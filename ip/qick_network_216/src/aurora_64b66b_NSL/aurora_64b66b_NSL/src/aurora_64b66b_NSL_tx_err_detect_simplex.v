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
 //  SIMPLEX TX ERR_DETECT
 //
 //
 //  Description: The ERR_DETECT module monitors the GTX to detect hard
 //                errors. All errors are reported to the Global Logic Interface.
 ///////////////////////////////////////////////////////////////////////////////
 
 `timescale 1 ns / 10 ps
 
(* DowngradeIPIdentifiedWarnings="yes" *)
 module aurora_64b66b_NSL_SIMPLEX_TX_ERR_DETECT
 (
     // Lane Init SM Interface
     TX_ENABLE_ERR_DETECT,
     TX_HARD_ERR_RESET,
 
     // Global Logic Interface
     TX_HARD_ERR,
     TX_SOFT_ERR,
 
     // GTX Interface
     TX_BUF_ERR,
 
     // System Interface
     RESET,
     USER_CLK
 );
 
 
 `define DLY #1
 
 //***********************************Port Declarations*******************************
 
     // Lane Init SM Interface
       input                TX_ENABLE_ERR_DETECT; 
       output               TX_HARD_ERR_RESET; 
 
     // GTX Interface
       input                TX_BUF_ERR; 
 
     // System Interface
       input                RESET; 
       input                USER_CLK; 
 
     // Global Logic Interface
       output               TX_HARD_ERR; 
       output               TX_SOFT_ERR; 
 
 //**************************External Register Declarations****************************
 
       reg                  TX_HARD_ERR; 
       reg                  TX_SOFT_ERR; 
 
 
 //*********************************Main Body of Code**********************************
 
 
     //____________________________ Error Processing _________________________________
 
     // Detect Soft Errors
     always @(posedge USER_CLK)
         if(TX_ENABLE_ERR_DETECT)
         begin
             TX_SOFT_ERR         <=  `DLY 1'b0;
         end
         else
         begin
             TX_SOFT_ERR          <=  `DLY    1'b0;
         end
     // Detect Hard Errors
     always @(posedge USER_CLK)
         if(RESET)
         begin
             TX_HARD_ERR          <=  `DLY    1'b0;
         end
         else
         begin
             TX_HARD_ERR         <=  `DLY (TX_BUF_ERR);
         end
 
     // Assert hard error reset when there is a hard error.  This assignment
     // just renames the two fanout branches of the hard error signal.
 
     assign TX_HARD_ERR_RESET =   TX_HARD_ERR;
 
 
 
 endmodule
