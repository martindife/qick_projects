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
 //  SIMPLEX TX CH BOND CODE GEN
 //
 //
 //  Description: This module generates the Channel Bond block code every 5 cycles when the 
 //               until the module is done with channel bonding and the remote is also up
 //               and it the CHANNEL_UP is asserted
 //               The GEN_CH_BOND port is used to indicate to the SYM_GEN module to insert the 
 //               Channel bond block code in the lanes.
 //               
 //               * Supports Virtex 5
 //
 ///////////////////////////////////////////////////////////////////////////////
 
 `timescale 1 ns / 10 ps
 
(* DowngradeIPIdentifiedWarnings="yes" *)
 module aurora_64b66b_NSL_SIMPLEX_TX_CH_BOND_CODE_GEN #
 (
    parameter  INTER_CB_GAP = 5'd15,
    parameter  TOTAL_CB_COUNT = 8'd38,
    parameter  PERIODIC_CB_COUNT = 20'd2500,

    parameter  CB_FSM_IDLE  = 2'd1,
    parameter  CB_FSM_CHK  = 2'd0
 )
 (
     // Global Logic Interface
     TX_CHANNEL_UP,
 
     // Lane Logic Interface
     GEN_CH_BOND,
     PERIODIC_CB_TO_LL,
     PERIODIC_CB_SEQ,
     TXDATAVALID_IN,
     DO_CC,
     RESET,
     RESET2FG,
     USER_CLK
 );
 
 `define DLY #1
 
 
 //***********************************Port Declarations*******************************
     // Global Logic Interface
       input                 TX_CHANNEL_UP; 
 
       output                GEN_CH_BOND; 
       output                PERIODIC_CB_TO_LL; 
       output                PERIODIC_CB_SEQ; 
       output                RESET2FG; 
 
     // System Interface
       input                 USER_CLK; 
       input                 TXDATAVALID_IN; 
       input                 DO_CC; 
       input                 RESET; 
 
 //***************************External Register Declarations***************************
 
       reg                   PERIODIC_CB_TO_LL; 
       reg                   PERIODIC_CB_SEQ; 
 
 //*********************************wire Declarations**********************************
       wire                  free_count_done; 
       wire                  count_done_for_periodic_cb; 
 
       wire                  idle4cbCNTR_done; 
 //*********************************reg Declarations**********************************
 
       reg        [0:4]      free_count_r = 5'd0; 
       reg        [0:19]     counter_r; 
       reg                   data_v_r; 

       reg        gen_ch_bond_int;
 
       reg         [1:0]      CB_STATE; 
       reg         [1:0]      NXT_CB_STATE; 
       reg         [7:0]      idle4cbCNTR = 8'd0; 
       reg         [7:0]      countCB = 8'd0; 
       reg         count_done_for_periodic_cb_r = 1'd0; 
       reg         reset_frm_CB = 1'd0; 
       reg         [15:0]     countCC =  'd0; 
       reg         firstCC = 1'd0; 
       reg         do_cc_r = 1'd0; 
 //*********************************Main Body of Code**********************************
 
// warn cc - this will be deprecated
     always @(posedge USER_CLK)
       if(RESET || (!TX_CHANNEL_UP))               
             firstCC   <= `DLY  'b0;
       else if (TX_CHANNEL_UP && DO_CC )
             firstCC   <= `DLY  1'b1;

     always @(posedge USER_CLK)
             do_cc_r   <= `DLY  DO_CC;

     always @(posedge USER_CLK)
       if(RESET || (!TX_CHANNEL_UP))               
             countCC   <= `DLY  16'b0;
       else if (countCC >= 16'd4999)
             countCC   <= `DLY  16'd7;
       else if (firstCC )
             countCC   <= `DLY  countCC + 16'b1;
// warn cc done

     always @(posedge USER_CLK)
             data_v_r <= `DLY TXDATAVALID_IN;
 
     always @(posedge USER_CLK)
       if(RESET)
             free_count_r <= `DLY 5'b0;
       else if(!data_v_r)
             free_count_r <= `DLY free_count_r;
       else if(free_count_done)
               free_count_r <= `DLY 5'b0;
       else
             free_count_r <= `DLY free_count_r+1'b1;
 
     assign free_count_done = (free_count_r==INTER_CB_GAP);
 
     always @(posedge USER_CLK)
       if(RESET || (!TX_CHANNEL_UP))               
             counter_r   <= `DLY  20'b0;
       else if (!TXDATAVALID_IN )
             counter_r   <= `DLY  counter_r;
       else if (counter_r >= PERIODIC_CB_COUNT)
             counter_r   <= `DLY  20'b0;
       else if (counter_r == PERIODIC_CB_COUNT - 1'b1)
            if (countCC > 16'd4384)
              counter_r   <= `DLY  counter_r;
            else
              counter_r   <= `DLY  counter_r + 20'b1;
       else
             counter_r   <= `DLY  counter_r + 20'b1;
 
     assign  count_done_for_periodic_cb   = (counter_r == PERIODIC_CB_COUNT)? 1'b1:1'b0;
 
     //CB seq FSM
 always @(posedge USER_CLK)
 begin
    if (RESET)
      CB_STATE <= `DLY CB_FSM_CHK;
   else
      CB_STATE <= `DLY NXT_CB_STATE;
 end

 always @(*)
 begin
     case(CB_STATE)
         CB_FSM_IDLE:
             if (idle4cbCNTR_done)
                 NXT_CB_STATE = CB_FSM_CHK;
             else
                 NXT_CB_STATE = CB_FSM_IDLE;
         CB_FSM_CHK:
             if ((TX_CHANNEL_UP & count_done_for_periodic_cb) || countCB != 'b0)
                 NXT_CB_STATE = CB_FSM_IDLE;
             else
                 NXT_CB_STATE = CB_FSM_CHK;
         default:
           NXT_CB_STATE = CB_FSM_CHK;
     endcase
 end
     //CB seq FSM done

 // Periodic CB 
 always @(*)
 begin
     if (RESET)
        count_done_for_periodic_cb_r <= `DLY 1'b0;
     else if (CB_STATE == CB_FSM_CHK && NXT_CB_STATE == CB_FSM_IDLE)
        count_done_for_periodic_cb_r <= `DLY 1'b1;
     else 
        count_done_for_periodic_cb_r <= `DLY 1'b0;
 end
 // Periodic CB done
// CB seq CB counter
 always @(posedge USER_CLK)
 begin
     if (TX_CHANNEL_UP & count_done_for_periodic_cb)
         countCB <= `DLY TOTAL_CB_COUNT-1'b1;
     else if (CB_STATE == CB_FSM_CHK && NXT_CB_STATE == CB_FSM_IDLE)
         countCB <= `DLY countCB - 1'b1;
 end
// IDLE accounting
always @(posedge USER_CLK)
begin
    if (RESET)
        idle4cbCNTR <= `DLY 'b0;
    else if (!TXDATAVALID_IN)
        idle4cbCNTR <= `DLY idle4cbCNTR;
    else if (idle4cbCNTR_done)
        idle4cbCNTR <= `DLY 'b0;
    else if ((CB_STATE == CB_FSM_CHK && NXT_CB_STATE == CB_FSM_IDLE) || (CB_STATE == CB_FSM_IDLE))
        idle4cbCNTR <= `DLY idle4cbCNTR + 1'b1;
    else
        idle4cbCNTR <= `DLY 'b0;
end

assign idle4cbCNTR_done = (idle4cbCNTR == INTER_CB_GAP);

// RESET to Frame_GEN
 always @(posedge USER_CLK)
 begin
    if (RESET)
         reset_frm_CB <= `DLY 1'b0;
    else if ((countCB <= 'b1) && count_done_for_periodic_cb_r)
         reset_frm_CB <= `DLY 1'b1;
    else if (idle4cbCNTR_done && (countCB == 0))
         reset_frm_CB <= `DLY 1'b0;
 end

 assign RESET2FG =  reset_frm_CB;

// IDLE accounting done
     always @(posedge USER_CLK)
     begin
          PERIODIC_CB_TO_LL <= `DLY TX_CHANNEL_UP & count_done_for_periodic_cb_r;
     end
 
     always @(posedge USER_CLK)
     begin
          PERIODIC_CB_SEQ <= `DLY TX_CHANNEL_UP & ( countCB > 0 && (countCB < TOTAL_CB_COUNT));
     end
 
 
     // The pulse generaed by the shift register is registered and sent to the SYM_DEC logic
     always @(posedge USER_CLK)
     begin
         gen_ch_bond_int <= `DLY !TX_CHANNEL_UP & free_count_done ;     
     end
   assign  GEN_CH_BOND  = gen_ch_bond_int;
 
     
 endmodule
