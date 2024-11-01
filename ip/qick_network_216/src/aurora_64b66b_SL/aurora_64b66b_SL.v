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
 //  aurora_64b66b_SL
 //
 //
 //
 //  Description: This is the top level module for Aurora 64B66B design
 //
 //
 ///////////////////////////////////////////////////////////////////////////////

 `timescale 1 ns / 10 ps

   (* core_generation_info = "aurora_64b66b_SL,aurora_64b66b_v12_0_9,{c_aurora_lanes=1,c_column_used=left,c_gt_clock_1=GTYQ0,c_gt_clock_2=None,c_gt_loc_1=1,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=X,c_gt_loc_16=X,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=4,c_line_rate=1.25,c_gt_type=GTYE4,c_qpll=false,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=156.25,c_simplex=true,c_simplex_mode=RX,c_stream=false,c_ufc=false,c_user_k=false,flow_mode=None,interface_mode=Framing,dataflow_config=RX-only_Simplex}" *)
(* DowngradeIPIdentifiedWarnings="yes" *)
 module aurora_64b66b_SL
 (
        // RX AXI4-S Interface
         m_axi_rx_tdata,
         m_axi_rx_tlast,
         m_axi_rx_tkeep,
         m_axi_rx_tvalid,





        // GTX Serial I/O
         rxp,
         rxn,

        //GTX Reference Clock Interface
         gt_refclk1_p,
         gt_refclk1_n,
         gt_refclk1_out,
        // Error Detection Interface
         rx_hard_err,
         rx_soft_err,
        // Status
         rx_channel_up,
         rx_lane_up,


        // System Interface
         user_clk_out,
         mmcm_not_locked_out,
       reset2fc, 
         reset_pb,
         gt_rxcdrovrden_in,
         power_down,
         pma_init,
         gt_pll_lock,
//---{
//---}

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
       gt_qplllock,
       gt_powergood,




         sys_reset_out,
         gt_reset_out,


         tx_out_clk
 );

 `define DLY #1
 // synthesis attribute X_CORE_INFO of aurora_64b66b_SL is "aurora_64b66b_v12_0_9, Coregen v14.3_ip3, Number of lanes = 1, Line rate is double1.25Gbps, Reference Clock is double156.25MHz, Interface is Framing, Flow Control is None and is operating in DUPLEX configuration";

 //***********************************Port Declarations*******************************

     // RX AXI Interface
       output [0:63]     m_axi_rx_tdata; 
       output [0:7]      m_axi_rx_tkeep; 
       output            m_axi_rx_tlast;
       output            m_axi_rx_tvalid;




     // GTX Serial I/O
       input    [0:0] rxp;
       input    [0:0] rxn;

     // GTX Reference Clock Interface
        input              gt_refclk1_p;
        input              gt_refclk1_n;
        output             gt_refclk1_out;

     // Error Detection Interface
       output             rx_hard_err;
       output             rx_soft_err;

     // Status
       output             rx_channel_up;
       output      [0:0] rx_lane_up;
     // System Interface
       output             user_clk_out;
       output             mmcm_not_locked_out;
       output              reset2fc; 
       input              reset_pb;
       input              gt_rxcdrovrden_in;
       input              power_down;
       input              pma_init;


//---{
//---}


       output  [15:0]  gt0_drpdo;
       output          gt0_drprdy;

    //---------------------- GT DRP Ports ----------------------
       input   [9:0]   gt0_drpaddr;
       input   [15:0]  gt0_drpdi;
       input           gt0_drpen;
       input           gt0_drpwe;

       input  init_clk;
       output link_reset_out;
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
       output             gt_qplllock                   ;

       output [0:0]           gt_powergood;


       output              gt_pll_lock;
       output              sys_reset_out;
       output              gt_reset_out;
       output              tx_out_clk;



       wire    [0:63]    tied_to_ground_vec;
       wire              tied_to_ground;



 //*********************************Main Body of Code**********************************


      assign tied_to_ground_vec = 64'd0;
      assign tied_to_ground     = 1'd0;

aurora_64b66b_SL_support inst
// this is support instance in the aurora_64b66b.v file
     (
     // RX AXI Interface
       .m_axi_rx_tdata      (m_axi_rx_tdata),
       .m_axi_rx_tkeep      (m_axi_rx_tkeep),
       .m_axi_rx_tlast      (m_axi_rx_tlast),
       .m_axi_rx_tvalid     (m_axi_rx_tvalid),




     // GTX Serial I/O
       .rxp      (rxp[0]),
       .rxn      (rxn[0]),

     // Error Detection Interface
       .rx_hard_err      (rx_hard_err),
       .rx_soft_err      (rx_soft_err),

     // Status
       .rx_channel_up    (rx_channel_up),
       .rx_lane_up       (rx_lane_up[0]),
     // System Interface
       .user_clk_out      (user_clk_out),
         .reset2fc(reset2fc),
       .reset_pb   (reset_pb),
       .gt_rxcdrovrden_in      (gt_rxcdrovrden_in),
       .power_down      (power_down),
       .pma_init      (pma_init),


       .gt0_drpdo    (gt0_drpdo),
       .gt0_drprdy    (gt0_drprdy),

    //---------------------- GT DRP Ports ----------------------
       .gt0_drpaddr  (gt0_drpaddr),
       .gt0_drpdi    (gt0_drpdi),
       .gt0_drpen    (gt0_drpen),
       .gt0_drpwe    (gt0_drpwe),

       .init_clk                     (init_clk),
       .link_reset_out               (link_reset_out),
       .gt_pll_lock      (gt_pll_lock),

     // GTX Reference Clock Interface
       .gt_refclk1_p(gt_refclk1_p),
       .gt_refclk1_n(gt_refclk1_n),
       .gt_refclk1_out(gt_refclk1_out),
         .gt_rxusrclk_out (gt_rxusrclk_out),
    //------------------------ RX Margin Analysis Ports ------------------------
         .gt_eyescandataerror             (gt_eyescandataerror    ),
         .gt_eyescanreset                 (gt_eyescanreset   ),
         .gt_eyescantrigger               (gt_eyescantrigger   ),
    //------------------- Receive Ports - RX Equalizer Ports -------------------
         .gt_rxcdrhold                    (gt_rxcdrhold   ),
         .gt_rxdfelpmreset                (gt_rxdfelpmreset   ),
         .gt_rxlpmen                      (gt_rxlpmen   ),
         .gt_rxpmareset                   (gt_rxpmareset   ),
         .gt_rxpcsreset                   (gt_rxpcsreset    ),
//       .gt_rxuserrdy                    (gt_rxuserrdy   ),
         .gt_rxrate                       (gt_rxrate      ),
         .gt_rxbufreset                   (gt_rxbufreset    ),
         .gt_rxpmaresetdone               (gt_rxpmaresetdone     ),
         .gt_rxprbssel                    (gt_rxprbssel        ),
         .gt_rxprbserr                    (gt_rxprbserr        ),
         .gt_rxprbscntreset               (gt_rxprbscntreset   ),
         .gt_rxresetdone                  (gt_rxresetdone    ),
         .gt_rxbufstatus                  (gt_rxbufstatus    ),
        .gt_pcsrsvdin                     (gt_pcsrsvdin   ),
        .gt_dmonitorout                   (gt_dmonitorout        ),
        .gt_cplllock                      (gt_cplllock    ),
        .gt_qplllock                      (gt_qplllock),

    //----------- GT POWERGOOD STATUS Port -----------
          .gt_powergood                   (gt_powergood),

//----{


//----}
       .sys_reset_out			(sys_reset_out),
       .mmcm_not_locked_out		(),
       .mmcm_not_locked_out2	(mmcm_not_locked_out),
       .gt_reset_out			(gt_reset_out),
       .tx_out_clk			(tx_out_clk)
     );


 endmodule
