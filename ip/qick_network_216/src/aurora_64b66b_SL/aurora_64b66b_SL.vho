-- (c) Copyright 1995-2023 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.
-- IP VLNV: xilinx.com:ip:aurora_64b66b:12.0
-- IP Revision: 9
-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT aurora_64b66b_SL
  PORT (
    rxp : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxn : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    reset_pb : IN STD_LOGIC;
    power_down : IN STD_LOGIC;
    pma_init : IN STD_LOGIC;
    rx_hard_err : OUT STD_LOGIC;
    rx_soft_err : OUT STD_LOGIC;
    rx_channel_up : OUT STD_LOGIC;
    rx_lane_up : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    tx_out_clk : OUT STD_LOGIC;
    gt_pll_lock : OUT STD_LOGIC;
    m_axi_rx_tdata : OUT STD_LOGIC_VECTOR(0 TO 63);
    m_axi_rx_tkeep : OUT STD_LOGIC_VECTOR(0 TO 7);
    m_axi_rx_tlast : OUT STD_LOGIC;
    m_axi_rx_tvalid : OUT STD_LOGIC;
    mmcm_not_locked_out : OUT STD_LOGIC;
    gt0_drpaddr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    gt0_drpdi : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    gt0_drprdy : OUT STD_LOGIC;
    gt0_drpwe : IN STD_LOGIC;
    gt0_drpen : IN STD_LOGIC;
    gt0_drpdo : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    init_clk : IN STD_LOGIC;
    link_reset_out : OUT STD_LOGIC;
    gt_refclk1_p : IN STD_LOGIC;
    gt_refclk1_n : IN STD_LOGIC;
    user_clk_out : OUT STD_LOGIC;
    gt_rxcdrovrden_in : IN STD_LOGIC;
    gt_rxusrclk_out : OUT STD_LOGIC;
    reset2fc : OUT STD_LOGIC;
    sys_reset_out : OUT STD_LOGIC;
    gt_reset_out : OUT STD_LOGIC;
    gt_refclk1_out : OUT STD_LOGIC;
    gt_qplllock : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_eyescanreset : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_eyescandataerror : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_rxlpmen : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_eyescantrigger : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_rxcdrhold : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_rxdfelpmreset : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_rxpmareset : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_rxpcsreset : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_rxbufreset : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_rxpmaresetdone : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_rxprbssel : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt_rxprbserr : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_rxprbscntreset : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_rxresetdone : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_rxbufstatus : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    gt_powergood : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_pcsrsvdin : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    gt_dmonitorout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    gt_cplllock : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gt_rxrate : IN STD_LOGIC_VECTOR(2 DOWNTO 0) 
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : aurora_64b66b_SL
  PORT MAP (
    rxp => rxp,
    rxn => rxn,
    reset_pb => reset_pb,
    power_down => power_down,
    pma_init => pma_init,
    rx_hard_err => rx_hard_err,
    rx_soft_err => rx_soft_err,
    rx_channel_up => rx_channel_up,
    rx_lane_up => rx_lane_up,
    tx_out_clk => tx_out_clk,
    gt_pll_lock => gt_pll_lock,
    m_axi_rx_tdata => m_axi_rx_tdata,
    m_axi_rx_tkeep => m_axi_rx_tkeep,
    m_axi_rx_tlast => m_axi_rx_tlast,
    m_axi_rx_tvalid => m_axi_rx_tvalid,
    mmcm_not_locked_out => mmcm_not_locked_out,
    gt0_drpaddr => gt0_drpaddr,
    gt0_drpdi => gt0_drpdi,
    gt0_drprdy => gt0_drprdy,
    gt0_drpwe => gt0_drpwe,
    gt0_drpen => gt0_drpen,
    gt0_drpdo => gt0_drpdo,
    init_clk => init_clk,
    link_reset_out => link_reset_out,
    gt_refclk1_p => gt_refclk1_p,
    gt_refclk1_n => gt_refclk1_n,
    user_clk_out => user_clk_out,
    gt_rxcdrovrden_in => gt_rxcdrovrden_in,
    gt_rxusrclk_out => gt_rxusrclk_out,
    reset2fc => reset2fc,
    sys_reset_out => sys_reset_out,
    gt_reset_out => gt_reset_out,
    gt_refclk1_out => gt_refclk1_out,
    gt_qplllock => gt_qplllock,
    gt_eyescanreset => gt_eyescanreset,
    gt_eyescandataerror => gt_eyescandataerror,
    gt_rxlpmen => gt_rxlpmen,
    gt_eyescantrigger => gt_eyescantrigger,
    gt_rxcdrhold => gt_rxcdrhold,
    gt_rxdfelpmreset => gt_rxdfelpmreset,
    gt_rxpmareset => gt_rxpmareset,
    gt_rxpcsreset => gt_rxpcsreset,
    gt_rxbufreset => gt_rxbufreset,
    gt_rxpmaresetdone => gt_rxpmaresetdone,
    gt_rxprbssel => gt_rxprbssel,
    gt_rxprbserr => gt_rxprbserr,
    gt_rxprbscntreset => gt_rxprbscntreset,
    gt_rxresetdone => gt_rxresetdone,
    gt_rxbufstatus => gt_rxbufstatus,
    gt_powergood => gt_powergood,
    gt_pcsrsvdin => gt_pcsrsvdin,
    gt_dmonitorout => gt_dmonitorout,
    gt_cplllock => gt_cplllock,
    gt_rxrate => gt_rxrate
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

-- You must compile the wrapper file aurora_64b66b_SL.vhd when simulating
-- the core, aurora_64b66b_SL. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.



