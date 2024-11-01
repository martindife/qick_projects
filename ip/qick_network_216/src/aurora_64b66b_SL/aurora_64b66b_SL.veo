// (c) Copyright 1995-2023 Xilinx, Inc. All rights reserved.
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
// DO NOT MODIFY THIS FILE.

// IP VLNV: xilinx.com:ip:aurora_64b66b:12.0
// IP Revision: 9

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
aurora_64b66b_SL your_instance_name (
  .rxp(rxp),                                  // input wire [0 : 0] rxp
  .rxn(rxn),                                  // input wire [0 : 0] rxn
  .reset_pb(reset_pb),                        // input wire reset_pb
  .power_down(power_down),                    // input wire power_down
  .pma_init(pma_init),                        // input wire pma_init
  .rx_hard_err(rx_hard_err),                  // output wire rx_hard_err
  .rx_soft_err(rx_soft_err),                  // output wire rx_soft_err
  .rx_channel_up(rx_channel_up),              // output wire rx_channel_up
  .rx_lane_up(rx_lane_up),                    // output wire [0 : 0] rx_lane_up
  .tx_out_clk(tx_out_clk),                    // output wire tx_out_clk
  .gt_pll_lock(gt_pll_lock),                  // output wire gt_pll_lock
  .m_axi_rx_tdata(m_axi_rx_tdata),            // output wire [0 : 63] m_axi_rx_tdata
  .m_axi_rx_tkeep(m_axi_rx_tkeep),            // output wire [0 : 7] m_axi_rx_tkeep
  .m_axi_rx_tlast(m_axi_rx_tlast),            // output wire m_axi_rx_tlast
  .m_axi_rx_tvalid(m_axi_rx_tvalid),          // output wire m_axi_rx_tvalid
  .mmcm_not_locked_out(mmcm_not_locked_out),  // output wire mmcm_not_locked_out
  .gt0_drpaddr(gt0_drpaddr),                  // input wire [9 : 0] gt0_drpaddr
  .gt0_drpdi(gt0_drpdi),                      // input wire [15 : 0] gt0_drpdi
  .gt0_drprdy(gt0_drprdy),                    // output wire gt0_drprdy
  .gt0_drpwe(gt0_drpwe),                      // input wire gt0_drpwe
  .gt0_drpen(gt0_drpen),                      // input wire gt0_drpen
  .gt0_drpdo(gt0_drpdo),                      // output wire [15 : 0] gt0_drpdo
  .init_clk(init_clk),                        // input wire init_clk
  .link_reset_out(link_reset_out),            // output wire link_reset_out
  .gt_refclk1_p(gt_refclk1_p),                // input wire gt_refclk1_p
  .gt_refclk1_n(gt_refclk1_n),                // input wire gt_refclk1_n
  .user_clk_out(user_clk_out),                // output wire user_clk_out
  .gt_rxcdrovrden_in(gt_rxcdrovrden_in),      // input wire gt_rxcdrovrden_in
  .gt_rxusrclk_out(gt_rxusrclk_out),          // output wire gt_rxusrclk_out
  .reset2fc(reset2fc),                        // output wire reset2fc
  .sys_reset_out(sys_reset_out),              // output wire sys_reset_out
  .gt_reset_out(gt_reset_out),                // output wire gt_reset_out
  .gt_refclk1_out(gt_refclk1_out),            // output wire gt_refclk1_out
  .gt_qplllock(gt_qplllock),                  // output wire [0 : 0] gt_qplllock
  .gt_eyescanreset(gt_eyescanreset),          // input wire [0 : 0] gt_eyescanreset
  .gt_eyescandataerror(gt_eyescandataerror),  // output wire [0 : 0] gt_eyescandataerror
  .gt_rxlpmen(gt_rxlpmen),                    // input wire [0 : 0] gt_rxlpmen
  .gt_eyescantrigger(gt_eyescantrigger),      // input wire [0 : 0] gt_eyescantrigger
  .gt_rxcdrhold(gt_rxcdrhold),                // input wire [0 : 0] gt_rxcdrhold
  .gt_rxdfelpmreset(gt_rxdfelpmreset),        // input wire [0 : 0] gt_rxdfelpmreset
  .gt_rxpmareset(gt_rxpmareset),              // input wire [0 : 0] gt_rxpmareset
  .gt_rxpcsreset(gt_rxpcsreset),              // input wire [0 : 0] gt_rxpcsreset
  .gt_rxbufreset(gt_rxbufreset),              // input wire [0 : 0] gt_rxbufreset
  .gt_rxpmaresetdone(gt_rxpmaresetdone),      // output wire [0 : 0] gt_rxpmaresetdone
  .gt_rxprbssel(gt_rxprbssel),                // input wire [3 : 0] gt_rxprbssel
  .gt_rxprbserr(gt_rxprbserr),                // output wire [0 : 0] gt_rxprbserr
  .gt_rxprbscntreset(gt_rxprbscntreset),      // input wire [0 : 0] gt_rxprbscntreset
  .gt_rxresetdone(gt_rxresetdone),            // output wire [0 : 0] gt_rxresetdone
  .gt_rxbufstatus(gt_rxbufstatus),            // output wire [2 : 0] gt_rxbufstatus
  .gt_powergood(gt_powergood),                // output wire [0 : 0] gt_powergood
  .gt_pcsrsvdin(gt_pcsrsvdin),                // input wire [15 : 0] gt_pcsrsvdin
  .gt_dmonitorout(gt_dmonitorout),            // output wire [15 : 0] gt_dmonitorout
  .gt_cplllock(gt_cplllock),                  // output wire [0 : 0] gt_cplllock
  .gt_rxrate(gt_rxrate)                      // input wire [2 : 0] gt_rxrate
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file aurora_64b66b_SL.v when simulating
// the core, aurora_64b66b_SL. When compiling the wrapper file, be sure to
// reference the Verilog simulation library.

