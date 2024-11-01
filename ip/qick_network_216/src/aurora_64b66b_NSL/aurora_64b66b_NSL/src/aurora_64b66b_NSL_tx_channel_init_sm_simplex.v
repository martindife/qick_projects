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
 //  SIMPLEX TX CHANNEL INIT SM
 //
 //
 //  Description: the CHANNEL_INIT_SM module is a state machine for managing channel
 //               bonding.
 //
 //               The channel init state machine is reset until the lane up signals
 //               of all the lanes that constitute the channel are asserted.  It then
 //               requests channel bonding until the lanes have been bonded.Channel 
 //               bonding is skipped if there is only one lane in the channel.  
 //               If bonding is unsuccessful, the lanes are reset.
 //
 //               After CHANNEL_UP goes high, the state machine is quiescent, and will
 //               reset only if one of the lanes goes down, a hard error is detected, or
 //               a general reset is requested.
 //
 //               SIMPLEX_TIMER_VALUE parameter is the time out counter btw either ends of a simplex Aurora 64B66B design
 //
 ///////////////////////////////////////////////////////////////////////////////
 
 `timescale 1 ns / 10 ps
 
(* DowngradeIPIdentifiedWarnings="yes" *)
 module aurora_64b66b_NSL_SIMPLEX_TX_CHANNEL_INIT_SM #
 (
     parameter SIMPLEX_TIMER_VALUE = 12
 )
 (
     // Aurora Lane Interface
     GEN_NA_IDLES,
     RESET_LANES,
     
     // System Interface
     USER_CLK,
     RESET,
     TX_LANE_UP,
     TX_CHANNEL_UP
 
 );
 
 `define DLY #1
 
 
 
 //***********************************Port Declarations*******************************
 
     // Aurora Lane Interface
       output  reg             GEN_NA_IDLES = 1'b1; 
       output                  RESET_LANES; 
     
     // System Interface
       input                    USER_CLK; 
       input                    RESET; 
       input                   TX_LANE_UP; 
       output                   TX_CHANNEL_UP; 
 
 
 //***************************Internal Register Declarations***************************
     // State registers
     reg   [0:SIMPLEX_TIMER_VALUE-1]  counter2_r = {SIMPLEX_TIMER_VALUE{1'b1}};
 
 //*********************************Wire Declarations**********************************
 
       wire                     reset_lanes_c; 
 
     // Next state signals
 
 //*********************************Main Body of Code**********************************
 
   always @(posedge USER_CLK)
       if(RESET)
           GEN_NA_IDLES <= `DLY 1'b1;
       else if(&TX_LANE_UP)
           GEN_NA_IDLES <= `DLY 1'b0;
       else
           GEN_NA_IDLES <= `DLY 1'b1;

     //________________Main state machine________________
     // State registers
     // Core of the counter.
     always @(posedge USER_CLK)
       if(RESET | ! (&TX_LANE_UP))   
               counter2_r   <=  `DLY   {SIMPLEX_TIMER_VALUE{1'b1}};
       else if(counter2_r == {SIMPLEX_TIMER_VALUE{1'b0}})
               counter2_r   <=  `DLY   counter2_r;
       else if(&TX_LANE_UP)  
               counter2_r   <=  `DLY   counter2_r - 1'b1;
 
     // Channel up is high as long as the Global Logic is in the ready state.
     assign  TX_CHANNEL_UP          = (counter2_r == {SIMPLEX_TIMER_VALUE{1'b0}});
 
     //__________________________Channel Reset _________________________________
 
     // Some problems during channel bonding require the lanes to
     // be reset.  When this happens, we assert the Reset Lanes signal, which gets
     // sent to all Aurora Lanes.  When the Aurora Lanes reset, their TX_LANE_UP signals
     // go down.  This causes the Channel Error Detector to assert the Reset Channel
     // signal.
     assign reset_lanes_c = (!(&TX_LANE_UP))| RESET;
 
 
     FD #(
         .INIT(1'b1)
     ) reset_lanes_flop_0_i (
         .D(reset_lanes_c),
         .C(USER_CLK),
         .Q(RESET_LANES)
     );
 
 endmodule
