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
 //  SIMPLEX TX LANE INIT SM
 //
 //
 //  Description: This logic manages the initialization of the GTX for 64B66B.
 //               There is no block sync module as in the of Duplex designs. Lane initialisation is done using a lane init counter.
 ///////////////////////////////////////////////////////////////////////////////
 
 `timescale 1 ns / 10 ps
 
(* DowngradeIPIdentifiedWarnings="yes" *)
 module aurora_64b66b_NSL_SIMPLEX_TX_LANE_INIT_SM #
 (
     parameter   EXAMPLE_SIMULATION =   0        // Set to 1 to reduce simulation time
      //pragma translate_off
        | 1
      //pragma translate_on
 )
 (
     // GTX Interface
     TX_RESET,
     TX_RESETDONE_IN,
 
     // Comma Detect Phase Alignment Interface
     TX_ENA_COMMA_ALIGN,
 
     // Error Detection Logic Interface
     TX_ENABLE_ERR_DETECT,
     TX_HARD_ERR_RESET,
 
     // Global Logic Interface
     TX_LANE_UP,
 
     // System Interface
     USER_CLK,
     SYNC_CLK,
     RESET_LANES,
     RESET
 );
 `define DLY #1
 //***********************************Port Declarations*******************************
 
     // GTX Interface
       output             TX_RESET;            // Reset the TX side of the GTX. 
       input              TX_RESETDONE_IN;     // Resetdone of the TX side of GTX. 
 
     // Comma Detect Phase Alignment Interface
       output              TX_ENA_COMMA_ALIGN;     // Turn on SERDES Alignment in GTX. 
 
     // Error Detection Logic Interface
       input                TX_HARD_ERR_RESET;    // Reset lane due to hard error. 
       output               TX_ENABLE_ERR_DETECT; // Turn on Soft Error detection. 
 
     // Global Logic Interface
       output               TX_LANE_UP;             // Lane is initialized. 
 
     // System Interface
       input                USER_CLK;            // Clock for all non-GTX Aurora logic. 
       input                SYNC_CLK;            // Clock for all non-GTX Aurora logic. 
       input                RESET_LANES;               // Reset Aurora Lane. 
       input                RESET;               // Global Lane. 
 
 //**************************External Register Declarations****************************
 
       reg                  TX_ENABLE_ERR_DETECT; 
 
 //**************************Internal Register Declarations****************************
 
       reg      [0:3]      counter1_r = 4'h1; 
       reg      [0:23]     counter2_r = (EXAMPLE_SIMULATION) ? 24'h7FFFF : {24{1'b1}}; 
 
 //*********************************Wire Declarations**********************************
 
       wire                count_8d_done_r; 
       wire                reset_count_c; 
       wire    tx_resetdone_in_sync3; 
 
 //*********************************Main Body of Code**********************************
 
     //________________Main state machine for managing initialization________________
 
     // Enable comma align when in the ALIGN state.
     assign  TX_ENA_COMMA_ALIGN =   1'b1;
 
     // Hold TX_RESET when in the RST state.
     assign  TX_RESET       =   TX_HARD_ERR_RESET;

 aurora_64b66b_NSL_rst_sync #
 (
     .c_init_val    (1'b1),
     .c_mtbf_stages (5)
 )u_rst_sync_tx_resetdone
 (
     .prmry_in     (TX_RESETDONE_IN),
     .scndry_aclk  (USER_CLK),
     .scndry_out   (tx_resetdone_in_sync3)
 );


 
     //_________Counter 2, for lane init ____________
 
     // Core of the counter.
     always @(posedge USER_CLK)
       if(RESET)  
               counter2_r   <=  `DLY (EXAMPLE_SIMULATION) ? 24'h1FFF : {24{1'b1}}; 
       else if(counter2_r == 24'd0 & tx_resetdone_in_sync3 == 1'b1)
               counter2_r   <=  `DLY   counter2_r;
       else if( tx_resetdone_in_sync3 == 1'b1) 
               counter2_r   <=  `DLY   counter2_r - 24'd1;
       else
               counter2_r   <=  `DLY   counter2_r;
 
     // Assert count_8d_done_r when the 2^3 flop in the register first goes high.
     assign  count_done_for_lane_ready    =   (counter2_r == 24'd0);
 
     // LANE_UP is asserted when in the READY state.
     FDR lane_up_flop_i
     (
         .D(count_done_for_lane_ready),
         .C(USER_CLK),
         .R(RESET),
         .Q(TX_LANE_UP)
     );
 
     // TX_ENABLE_ERR_DETECT is asserted when in the READY states.  Asserting
     // it earlier will result in too many false errors.  After it is asserted,
     // higher level modules can respond to Hard Errors by resetting the Aurora Lane.
     // We register the signal before it leaves the lane_init_sm submodule.
 
     always @(posedge USER_CLK)
           TX_ENABLE_ERR_DETECT <=  `DLY    count_done_for_lane_ready;
 
     //_________Counter 1, for reset cycles, align cycles and realign cycles____________
 
     // Core of the counter.
     always @(posedge USER_CLK)
       if(reset_count_c)    
                counter1_r   <=  `DLY    4'd1;
       else  
                counter1_r   <=  `DLY    counter1_r + 4'd1;
 
     // Assert count_8d_done_r when the 2^3 flop in the register first goes high.
     assign  count_8d_done_r     =   counter1_r[0];
 
 
     // The counter counts only in the rst_r state for 8 cycles 
     assign  reset_count_c = RESET ;
 
 endmodule
