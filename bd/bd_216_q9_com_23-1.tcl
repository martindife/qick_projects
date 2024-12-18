
################################################################
# This is a generated script based on design: d_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2023.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source d_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu49dr-ffvf1760-2-e
   set_property BOARD_PART xilinx.com:zcu216:part0:2.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name d_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
user.org:user:axis_avg_buffer:1.0\
user.org:user:axis_pfb_readout_v3:1.0\
user.org:user:axis_readout_v2:1.0\
user.org:user:axis_register_slice_nb:1.0\
user.org:user:axis_sg_int4_v1:1.0\
user.org:user:axis_sg_mux8_v1:1.0\
user.org:user:axis_signal_gen_v6:1.0\
user.org:user:axis_terminator:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:axi_dma:7.1\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:axis_clock_converter:1.1\
xilinx.com:ip:axis_register_slice:1.1\
xilinx.com:ip:axis_switch:1.1\
xilinx.com:ip:usp_rf_data_converter:2.6\
xilinx.com:ip:zynq_ultra_ps_e:3.5\
Fermi:user:qick_processor:2.0\
FERMI:user:qick_vec2bit:1.0\
user.org:user:sg_translator:1.0\
Fermi:user:qick_com:1.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set adc2_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 adc2_clk ]

  set dac2_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 dac2_clk ]

  set sysref_in [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_usp_rf_data_converter:diff_pins_rtl:1.0 sysref_in ]

  set vin20 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vin20 ]

  set vin22 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vin22 ]

  set vout00 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout00 ]

  set vout01 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout01 ]

  set vout02 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout02 ]

  set vout03 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout03 ]

  set vout10 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout10 ]

  set vout11 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout11 ]

  set vout12 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout12 ]

  set vout13 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout13 ]

  set vout20 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout20 ]

  set vout21 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout21 ]

  set vout22 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout22 ]

  set vout23 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout23 ]

  set vout30 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout30 ]

  set vout31 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout31 ]

  set vout32 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout32 ]

  set vout33 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout33 ]


  # Create ports
  set trig_0_o [ create_bd_port -dir O trig_0_o ]
  set trig_1_o [ create_bd_port -dir O trig_1_o ]
  set sync_i [ create_bd_port -dir I sync_i ]
  set pmod_i [ create_bd_port -dir I -from 3 -to 0 pmod_i ]
  set pmod_o [ create_bd_port -dir O -from 3 -to 0 pmod_o ]
  set sync_o [ create_bd_port -dir O sync_o ]

  # Create instance: axis_avg_buffer_0, and set properties
  set axis_avg_buffer_0 [ create_bd_cell -type ip -vlnv user.org:user:axis_avg_buffer:1.0 axis_avg_buffer_0 ]
  set_property -dict [list \
    CONFIG.N_AVG {13} \
    CONFIG.N_BUF {10} \
  ] $axis_avg_buffer_0


  # Create instance: axis_avg_buffer_1, and set properties
  set axis_avg_buffer_1 [ create_bd_cell -type ip -vlnv user.org:user:axis_avg_buffer:1.0 axis_avg_buffer_1 ]
  set_property -dict [list \
    CONFIG.N_AVG {13} \
    CONFIG.N_BUF {10} \
  ] $axis_avg_buffer_1


  # Create instance: axis_avg_buffer_2, and set properties
  set axis_avg_buffer_2 [ create_bd_cell -type ip -vlnv user.org:user:axis_avg_buffer:1.0 axis_avg_buffer_2 ]
  set_property -dict [list \
    CONFIG.N_AVG {13} \
    CONFIG.N_BUF {10} \
  ] $axis_avg_buffer_2


  # Create instance: axis_avg_buffer_3, and set properties
  set axis_avg_buffer_3 [ create_bd_cell -type ip -vlnv user.org:user:axis_avg_buffer:1.0 axis_avg_buffer_3 ]
  set_property -dict [list \
    CONFIG.N_AVG {13} \
    CONFIG.N_BUF {10} \
  ] $axis_avg_buffer_3


  # Create instance: axis_avg_buffer_4, and set properties
  set axis_avg_buffer_4 [ create_bd_cell -type ip -vlnv user.org:user:axis_avg_buffer:1.0 axis_avg_buffer_4 ]
  set_property -dict [list \
    CONFIG.N_AVG {13} \
    CONFIG.N_BUF {10} \
  ] $axis_avg_buffer_4


  # Create instance: axis_pfb_readout_v3_0, and set properties
  set axis_pfb_readout_v3_0 [ create_bd_cell -type ip -vlnv user.org:user:axis_pfb_readout_v3:1.0 axis_pfb_readout_v3_0 ]

  # Create instance: axis_readout_v2_0, and set properties
  set axis_readout_v2_0 [ create_bd_cell -type ip -vlnv user.org:user:axis_readout_v2:1.0 axis_readout_v2_0 ]

  # Create instance: axis_register_slice_0, and set properties
  set axis_register_slice_0 [ create_bd_cell -type ip -vlnv user.org:user:axis_register_slice_nb:1.0 axis_register_slice_0 ]
  set_property -dict [list \
    CONFIG.B {256} \
    CONFIG.N {6} \
  ] $axis_register_slice_0


  # Create instance: axis_register_slice_1, and set properties
  set axis_register_slice_1 [ create_bd_cell -type ip -vlnv user.org:user:axis_register_slice_nb:1.0 axis_register_slice_1 ]
  set_property -dict [list \
    CONFIG.B {256} \
    CONFIG.N {6} \
  ] $axis_register_slice_1


  # Create instance: axis_register_slice_2, and set properties
  set axis_register_slice_2 [ create_bd_cell -type ip -vlnv user.org:user:axis_register_slice_nb:1.0 axis_register_slice_2 ]
  set_property -dict [list \
    CONFIG.B {256} \
    CONFIG.N {6} \
  ] $axis_register_slice_2


  # Create instance: axis_register_slice_3, and set properties
  set axis_register_slice_3 [ create_bd_cell -type ip -vlnv user.org:user:axis_register_slice_nb:1.0 axis_register_slice_3 ]
  set_property -dict [list \
    CONFIG.B {256} \
    CONFIG.N {6} \
  ] $axis_register_slice_3


  # Create instance: axis_sg_int4_v1_0, and set properties
  set axis_sg_int4_v1_0 [ create_bd_cell -type ip -vlnv user.org:user:axis_sg_int4_v1:1.0 axis_sg_int4_v1_0 ]
  set_property CONFIG.N {12} $axis_sg_int4_v1_0


  # Create instance: axis_sg_int4_v1_1, and set properties
  set axis_sg_int4_v1_1 [ create_bd_cell -type ip -vlnv user.org:user:axis_sg_int4_v1:1.0 axis_sg_int4_v1_1 ]
  set_property CONFIG.N {12} $axis_sg_int4_v1_1


  # Create instance: axis_sg_int4_v1_2, and set properties
  set axis_sg_int4_v1_2 [ create_bd_cell -type ip -vlnv user.org:user:axis_sg_int4_v1:1.0 axis_sg_int4_v1_2 ]
  set_property CONFIG.N {12} $axis_sg_int4_v1_2


  # Create instance: axis_sg_int4_v1_3, and set properties
  set axis_sg_int4_v1_3 [ create_bd_cell -type ip -vlnv user.org:user:axis_sg_int4_v1:1.0 axis_sg_int4_v1_3 ]
  set_property CONFIG.N {12} $axis_sg_int4_v1_3


  # Create instance: axis_sg_int4_v1_4, and set properties
  set axis_sg_int4_v1_4 [ create_bd_cell -type ip -vlnv user.org:user:axis_sg_int4_v1:1.0 axis_sg_int4_v1_4 ]
  set_property CONFIG.N {12} $axis_sg_int4_v1_4


  # Create instance: axis_sg_int4_v1_5, and set properties
  set axis_sg_int4_v1_5 [ create_bd_cell -type ip -vlnv user.org:user:axis_sg_int4_v1:1.0 axis_sg_int4_v1_5 ]
  set_property CONFIG.N {12} $axis_sg_int4_v1_5


  # Create instance: axis_sg_int4_v1_6, and set properties
  set axis_sg_int4_v1_6 [ create_bd_cell -type ip -vlnv user.org:user:axis_sg_int4_v1:1.0 axis_sg_int4_v1_6 ]
  set_property CONFIG.N {12} $axis_sg_int4_v1_6


  # Create instance: axis_sg_int4_v1_7, and set properties
  set axis_sg_int4_v1_7 [ create_bd_cell -type ip -vlnv user.org:user:axis_sg_int4_v1:1.0 axis_sg_int4_v1_7 ]
  set_property CONFIG.N {12} $axis_sg_int4_v1_7


  # Create instance: axis_sg_int4_v1_8, and set properties
  set axis_sg_int4_v1_8 [ create_bd_cell -type ip -vlnv user.org:user:axis_sg_int4_v1:1.0 axis_sg_int4_v1_8 ]
  set_property CONFIG.N {12} $axis_sg_int4_v1_8


  # Create instance: axis_sg_int4_v1_9, and set properties
  set axis_sg_int4_v1_9 [ create_bd_cell -type ip -vlnv user.org:user:axis_sg_int4_v1:1.0 axis_sg_int4_v1_9 ]
  set_property CONFIG.N {12} $axis_sg_int4_v1_9


  # Create instance: axis_sg_int4_v1_10, and set properties
  set axis_sg_int4_v1_10 [ create_bd_cell -type ip -vlnv user.org:user:axis_sg_int4_v1:1.0 axis_sg_int4_v1_10 ]
  set_property CONFIG.N {12} $axis_sg_int4_v1_10


  # Create instance: axis_sg_int4_v1_11, and set properties
  set axis_sg_int4_v1_11 [ create_bd_cell -type ip -vlnv user.org:user:axis_sg_int4_v1:1.0 axis_sg_int4_v1_11 ]
  set_property CONFIG.N {12} $axis_sg_int4_v1_11


  # Create instance: axis_sg_mux8_v1_0, and set properties
  set axis_sg_mux8_v1_0 [ create_bd_cell -type ip -vlnv user.org:user:axis_sg_mux8_v1:1.0 axis_sg_mux8_v1_0 ]
  set_property CONFIG.N_DDS {16} $axis_sg_mux8_v1_0


  # Create instance: axis_signal_gen_v6_8, and set properties
  set axis_signal_gen_v6_8 [ create_bd_cell -type ip -vlnv user.org:user:axis_signal_gen_v6:1.0 axis_signal_gen_v6_8 ]
  set_property CONFIG.N {12} $axis_signal_gen_v6_8


  # Create instance: axis_signal_gen_v6_9, and set properties
  set axis_signal_gen_v6_9 [ create_bd_cell -type ip -vlnv user.org:user:axis_signal_gen_v6:1.0 axis_signal_gen_v6_9 ]
  set_property CONFIG.N {12} $axis_signal_gen_v6_9


  # Create instance: axis_signal_gen_v6_10, and set properties
  set axis_signal_gen_v6_10 [ create_bd_cell -type ip -vlnv user.org:user:axis_signal_gen_v6:1.0 axis_signal_gen_v6_10 ]
  set_property CONFIG.N {12} $axis_signal_gen_v6_10


  # Create instance: axis_terminator_4, and set properties
  set axis_terminator_4 [ create_bd_cell -type ip -vlnv user.org:user:axis_terminator:1.0 axis_terminator_4 ]
  set_property CONFIG.DATA_WIDTH {64} $axis_terminator_4


  # Create instance: rst_100, and set properties
  set rst_100 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_100 ]

  # Create instance: rst_adc2, and set properties
  set rst_adc2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_adc2 ]

  # Create instance: rst_dac0, and set properties
  set rst_dac0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_dac0 ]

  # Create instance: rst_dac1, and set properties
  set rst_dac1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_dac1 ]

  # Create instance: rst_dac2, and set properties
  set rst_dac2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_dac2 ]

  # Create instance: rst_dac3, and set properties
  set rst_dac3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_dac3 ]

  # Create instance: axi_dma_avg, and set properties
  set axi_dma_avg [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_avg ]
  set_property -dict [list \
    CONFIG.c_include_mm2s {0} \
    CONFIG.c_include_sg {0} \
    CONFIG.c_sg_length_width {26} \
  ] $axi_dma_avg


  # Create instance: axi_dma_buf, and set properties
  set axi_dma_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_buf ]
  set_property -dict [list \
    CONFIG.c_include_mm2s {0} \
    CONFIG.c_include_sg {0} \
    CONFIG.c_sg_length_width {26} \
  ] $axi_dma_buf


  # Create instance: axi_dma_gen, and set properties
  set axi_dma_gen [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_gen ]
  set_property -dict [list \
    CONFIG.c_include_s2mm {0} \
    CONFIG.c_include_sg {0} \
    CONFIG.c_sg_length_width {26} \
  ] $axi_dma_gen


  # Create instance: axi_dma_tproc, and set properties
  set axi_dma_tproc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_tproc ]
  set_property -dict [list \
    CONFIG.c_include_sg {0} \
    CONFIG.c_m_axi_mm2s_data_width {256} \
    CONFIG.c_m_axis_mm2s_tdata_width {256} \
    CONFIG.c_mm2s_burst_size {16} \
    CONFIG.c_sg_length_width {20} \
  ] $axi_dma_tproc


  # Create instance: axi_smc_0, and set properties
  set axi_smc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc_0 ]
  set_property -dict [list \
    CONFIG.NUM_MI {6} \
    CONFIG.NUM_SI {1} \
  ] $axi_smc_0


  # Create instance: axi_smc_1, and set properties
  set axi_smc_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc_1 ]
  set_property -dict [list \
    CONFIG.NUM_MI {23} \
    CONFIG.NUM_SI {1} \
  ] $axi_smc_1


  # Create instance: axi_smc_2, and set properties
  set axi_smc_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc_2 ]
  set_property -dict [list \
    CONFIG.NUM_MI {15} \
    CONFIG.NUM_SI {1} \
  ] $axi_smc_2


  # Create instance: axi_smc_3, and set properties
  set axi_smc_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc_3 ]
  set_property CONFIG.NUM_SI {3} $axi_smc_3


  # Create instance: axi_smc_4, and set properties
  set axi_smc_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc_4 ]
  set_property CONFIG.NUM_SI {2} $axi_smc_4


  # Create instance: axis_cc_avg_0, and set properties
  set axis_cc_avg_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_cc_avg_0 ]

  # Create instance: axis_cc_avg_1, and set properties
  set axis_cc_avg_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_cc_avg_1 ]

  # Create instance: axis_cc_avg_2, and set properties
  set axis_cc_avg_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_cc_avg_2 ]

  # Create instance: axis_cc_avg_3, and set properties
  set axis_cc_avg_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_cc_avg_3 ]

  # Create instance: axis_clock_converter_0, and set properties
  set axis_clock_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_0 ]

  # Create instance: axis_clock_converter_10, and set properties
  set axis_clock_converter_10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_10 ]

  # Create instance: axis_clock_converter_11, and set properties
  set axis_clock_converter_11 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_11 ]

  # Create instance: axis_clock_converter_12, and set properties
  set axis_clock_converter_12 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_12 ]

  # Create instance: axis_clock_converter_13, and set properties
  set axis_clock_converter_13 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_13 ]

  # Create instance: axis_clock_converter_14, and set properties
  set axis_clock_converter_14 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_14 ]

  # Create instance: axis_clock_converter_15, and set properties
  set axis_clock_converter_15 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_15 ]

  # Create instance: axis_clock_converter_1, and set properties
  set axis_clock_converter_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_1 ]

  # Create instance: axis_clock_converter_2, and set properties
  set axis_clock_converter_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_2 ]

  # Create instance: axis_clock_converter_3, and set properties
  set axis_clock_converter_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_3 ]

  # Create instance: axis_clock_converter_4, and set properties
  set axis_clock_converter_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_4 ]

  # Create instance: axis_clock_converter_5, and set properties
  set axis_clock_converter_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_5 ]

  # Create instance: axis_clock_converter_6, and set properties
  set axis_clock_converter_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_6 ]

  # Create instance: axis_clock_converter_7, and set properties
  set axis_clock_converter_7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_7 ]

  # Create instance: axis_clock_converter_8, and set properties
  set axis_clock_converter_8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_8 ]

  # Create instance: axis_clock_converter_9, and set properties
  set axis_clock_converter_9 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_9 ]

  # Create instance: axis_register_slice_12, and set properties
  set axis_register_slice_12 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice:1.1 axis_register_slice_12 ]
  set_property CONFIG.REG_CONFIG {8} $axis_register_slice_12


  # Create instance: axis_register_slice_13, and set properties
  set axis_register_slice_13 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice:1.1 axis_register_slice_13 ]
  set_property CONFIG.REG_CONFIG {8} $axis_register_slice_13


  # Create instance: axis_register_slice_14, and set properties
  set axis_register_slice_14 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice:1.1 axis_register_slice_14 ]
  set_property CONFIG.REG_CONFIG {8} $axis_register_slice_14


  # Create instance: axis_register_slice_15, and set properties
  set axis_register_slice_15 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice:1.1 axis_register_slice_15 ]
  set_property CONFIG.REG_CONFIG {8} $axis_register_slice_15


  # Create instance: axis_register_slice_16, and set properties
  set axis_register_slice_16 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice:1.1 axis_register_slice_16 ]
  set_property CONFIG.REG_CONFIG {8} $axis_register_slice_16


  # Create instance: axis_register_slice_17, and set properties
  set axis_register_slice_17 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice:1.1 axis_register_slice_17 ]
  set_property CONFIG.REG_CONFIG {8} $axis_register_slice_17


  # Create instance: axis_register_slice_18, and set properties
  set axis_register_slice_18 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice:1.1 axis_register_slice_18 ]
  set_property CONFIG.REG_CONFIG {8} $axis_register_slice_18


  # Create instance: axis_register_slice_19, and set properties
  set axis_register_slice_19 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice:1.1 axis_register_slice_19 ]
  set_property CONFIG.REG_CONFIG {8} $axis_register_slice_19


  # Create instance: axis_switch_avg, and set properties
  set axis_switch_avg [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 axis_switch_avg ]
  set_property -dict [list \
    CONFIG.NUM_SI {5} \
    CONFIG.ROUTING_MODE {1} \
  ] $axis_switch_avg


  # Create instance: axis_switch_buf, and set properties
  set axis_switch_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 axis_switch_buf ]
  set_property -dict [list \
    CONFIG.NUM_SI {5} \
    CONFIG.ROUTING_MODE {1} \
  ] $axis_switch_buf


  # Create instance: axis_switch_gen, and set properties
  set axis_switch_gen [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 axis_switch_gen ]
  set_property -dict [list \
    CONFIG.DECODER_REG {1} \
    CONFIG.NUM_MI {15} \
    CONFIG.NUM_SI {1} \
    CONFIG.ROUTING_MODE {1} \
  ] $axis_switch_gen


  # Create instance: usp_rf_data_converter_0, and set properties
  set usp_rf_data_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:usp_rf_data_converter:2.6 usp_rf_data_converter_0 ]
  set_property -dict [list \
    CONFIG.ADC2_Clock_Dist {0} \
    CONFIG.ADC2_Outclk_Freq {276.480} \
    CONFIG.ADC2_PLL_Enable {true} \
    CONFIG.ADC2_Refclk_Freq {245.760} \
    CONFIG.ADC2_Sampling_Rate {2.21184} \
    CONFIG.ADC_Coarse_Mixer_Freq20 {3} \
    CONFIG.ADC_Coarse_Mixer_Freq22 {2} \
    CONFIG.ADC_Data_Type20 {0} \
    CONFIG.ADC_Data_Type22 {1} \
    CONFIG.ADC_Data_Width20 {8} \
    CONFIG.ADC_Data_Width22 {8} \
    CONFIG.ADC_Decimation_Mode20 {1} \
    CONFIG.ADC_Decimation_Mode22 {2} \
    CONFIG.ADC_Mixer_Mode20 {2} \
    CONFIG.ADC_Mixer_Mode22 {0} \
    CONFIG.ADC_Mixer_Type20 {1} \
    CONFIG.ADC_Mixer_Type22 {1} \
    CONFIG.ADC_OBS22 {false} \
    CONFIG.ADC_Slice00_Enable {false} \
    CONFIG.ADC_Slice10_Enable {false} \
    CONFIG.ADC_Slice11_Enable {false} \
    CONFIG.ADC_Slice12_Enable {false} \
    CONFIG.ADC_Slice13_Enable {false} \
    CONFIG.ADC_Slice20_Enable {true} \
    CONFIG.ADC_Slice21_Enable {false} \
    CONFIG.ADC_Slice22_Enable {true} \
    CONFIG.ADC_Slice23_Enable {false} \
    CONFIG.ADC_Slice30_Enable {false} \
    CONFIG.ADC_Slice31_Enable {false} \
    CONFIG.ADC_Slice32_Enable {false} \
    CONFIG.ADC_Slice33_Enable {false} \
    CONFIG.DAC0_Clock_Dist {0} \
    CONFIG.DAC0_Clock_Source {6} \
    CONFIG.DAC0_Outclk_Freq {614.400} \
    CONFIG.DAC0_PLL_Enable {true} \
    CONFIG.DAC0_Refclk_Freq {245.760} \
    CONFIG.DAC0_Sampling_Rate {9.8304} \
    CONFIG.DAC1_Clock_Source {6} \
    CONFIG.DAC1_Outclk_Freq {430.080} \
    CONFIG.DAC1_PLL_Enable {true} \
    CONFIG.DAC1_Refclk_Freq {245.760} \
    CONFIG.DAC1_Sampling_Rate {6.88128} \
    CONFIG.DAC2_Clock_Dist {1} \
    CONFIG.DAC2_Clock_Source {6} \
    CONFIG.DAC2_Outclk_Freq {430.080} \
    CONFIG.DAC2_PLL_Enable {true} \
    CONFIG.DAC2_Refclk_Freq {245.760} \
    CONFIG.DAC2_Sampling_Rate {6.88128} \
    CONFIG.DAC3_Clock_Source {6} \
    CONFIG.DAC3_Outclk_Freq {430.080} \
    CONFIG.DAC3_PLL_Enable {true} \
    CONFIG.DAC3_Refclk_Freq {245.760} \
    CONFIG.DAC3_Sampling_Rate {6.88128} \
    CONFIG.DAC_Coarse_Mixer_Freq00 {3} \
    CONFIG.DAC_Coarse_Mixer_Freq01 {3} \
    CONFIG.DAC_Coarse_Mixer_Freq02 {3} \
    CONFIG.DAC_Coarse_Mixer_Freq03 {3} \
    CONFIG.DAC_Data_Width00 {16} \
    CONFIG.DAC_Data_Width01 {16} \
    CONFIG.DAC_Data_Width02 {16} \
    CONFIG.DAC_Data_Width03 {16} \
    CONFIG.DAC_Data_Width10 {8} \
    CONFIG.DAC_Data_Width11 {8} \
    CONFIG.DAC_Data_Width12 {8} \
    CONFIG.DAC_Data_Width13 {8} \
    CONFIG.DAC_Data_Width20 {8} \
    CONFIG.DAC_Data_Width21 {8} \
    CONFIG.DAC_Data_Width22 {8} \
    CONFIG.DAC_Data_Width23 {8} \
    CONFIG.DAC_Data_Width30 {8} \
    CONFIG.DAC_Data_Width31 {8} \
    CONFIG.DAC_Data_Width32 {8} \
    CONFIG.DAC_Data_Width33 {8} \
    CONFIG.DAC_Interpolation_Mode00 {1} \
    CONFIG.DAC_Interpolation_Mode01 {1} \
    CONFIG.DAC_Interpolation_Mode02 {1} \
    CONFIG.DAC_Interpolation_Mode03 {1} \
    CONFIG.DAC_Interpolation_Mode10 {4} \
    CONFIG.DAC_Interpolation_Mode11 {4} \
    CONFIG.DAC_Interpolation_Mode12 {4} \
    CONFIG.DAC_Interpolation_Mode13 {4} \
    CONFIG.DAC_Interpolation_Mode20 {4} \
    CONFIG.DAC_Interpolation_Mode21 {4} \
    CONFIG.DAC_Interpolation_Mode22 {4} \
    CONFIG.DAC_Interpolation_Mode23 {4} \
    CONFIG.DAC_Interpolation_Mode30 {4} \
    CONFIG.DAC_Interpolation_Mode31 {4} \
    CONFIG.DAC_Interpolation_Mode32 {4} \
    CONFIG.DAC_Interpolation_Mode33 {4} \
    CONFIG.DAC_Mixer_Mode00 {2} \
    CONFIG.DAC_Mixer_Mode01 {2} \
    CONFIG.DAC_Mixer_Mode02 {2} \
    CONFIG.DAC_Mixer_Mode03 {2} \
    CONFIG.DAC_Mixer_Mode10 {0} \
    CONFIG.DAC_Mixer_Mode11 {0} \
    CONFIG.DAC_Mixer_Mode12 {0} \
    CONFIG.DAC_Mixer_Mode13 {0} \
    CONFIG.DAC_Mixer_Mode20 {0} \
    CONFIG.DAC_Mixer_Mode21 {0} \
    CONFIG.DAC_Mixer_Mode22 {0} \
    CONFIG.DAC_Mixer_Mode23 {0} \
    CONFIG.DAC_Mixer_Mode30 {0} \
    CONFIG.DAC_Mixer_Mode31 {0} \
    CONFIG.DAC_Mixer_Mode32 {0} \
    CONFIG.DAC_Mixer_Mode33 {0} \
    CONFIG.DAC_Mixer_Type00 {1} \
    CONFIG.DAC_Mixer_Type01 {1} \
    CONFIG.DAC_Mixer_Type02 {1} \
    CONFIG.DAC_Mixer_Type03 {1} \
    CONFIG.DAC_Mixer_Type10 {2} \
    CONFIG.DAC_Mixer_Type11 {2} \
    CONFIG.DAC_Mixer_Type12 {2} \
    CONFIG.DAC_Mixer_Type13 {2} \
    CONFIG.DAC_Mixer_Type20 {2} \
    CONFIG.DAC_Mixer_Type21 {2} \
    CONFIG.DAC_Mixer_Type22 {2} \
    CONFIG.DAC_Mixer_Type23 {2} \
    CONFIG.DAC_Mixer_Type30 {2} \
    CONFIG.DAC_Mixer_Type31 {2} \
    CONFIG.DAC_Mixer_Type32 {2} \
    CONFIG.DAC_Mixer_Type33 {2} \
    CONFIG.DAC_Mode00 {3} \
    CONFIG.DAC_Mode01 {3} \
    CONFIG.DAC_Mode02 {3} \
    CONFIG.DAC_Mode03 {3} \
    CONFIG.DAC_Mode20 {0} \
    CONFIG.DAC_Mode21 {0} \
    CONFIG.DAC_Mode22 {0} \
    CONFIG.DAC_Mode23 {0} \
    CONFIG.DAC_Mode30 {0} \
    CONFIG.DAC_Mode31 {0} \
    CONFIG.DAC_Mode32 {0} \
    CONFIG.DAC_Mode33 {0} \
    CONFIG.DAC_NCO_Freq10 {0.5} \
    CONFIG.DAC_NCO_Freq11 {0.5} \
    CONFIG.DAC_NCO_Freq12 {0.5} \
    CONFIG.DAC_NCO_Freq13 {0.5} \
    CONFIG.DAC_NCO_Freq20 {0.5} \
    CONFIG.DAC_NCO_Freq21 {0.5} \
    CONFIG.DAC_NCO_Freq22 {0.5} \
    CONFIG.DAC_NCO_Freq23 {0.5} \
    CONFIG.DAC_NCO_Freq30 {0.5} \
    CONFIG.DAC_NCO_Freq31 {0.5} \
    CONFIG.DAC_NCO_Freq32 {0.5} \
    CONFIG.DAC_NCO_Freq33 {0.5} \
    CONFIG.DAC_Slice00_Enable {true} \
    CONFIG.DAC_Slice01_Enable {true} \
    CONFIG.DAC_Slice02_Enable {true} \
    CONFIG.DAC_Slice03_Enable {true} \
    CONFIG.DAC_Slice10_Enable {true} \
    CONFIG.DAC_Slice11_Enable {true} \
    CONFIG.DAC_Slice12_Enable {true} \
    CONFIG.DAC_Slice13_Enable {true} \
    CONFIG.DAC_Slice20_Enable {true} \
    CONFIG.DAC_Slice21_Enable {true} \
    CONFIG.DAC_Slice22_Enable {true} \
    CONFIG.DAC_Slice23_Enable {true} \
    CONFIG.DAC_Slice30_Enable {true} \
    CONFIG.DAC_Slice31_Enable {true} \
    CONFIG.DAC_Slice32_Enable {true} \
    CONFIG.DAC_Slice33_Enable {true} \
  ] $usp_rf_data_converter_0


  # Create instance: zynq_ultra_ps_e_0, and set properties
  set zynq_ultra_ps_e_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.5 zynq_ultra_ps_e_0 ]
  set_property -dict [list \
    CONFIG.CAN0_BOARD_INTERFACE {custom} \
    CONFIG.CAN1_BOARD_INTERFACE {custom} \
    CONFIG.CSU_BOARD_INTERFACE {custom} \
    CONFIG.DP_BOARD_INTERFACE {custom} \
    CONFIG.GEM0_BOARD_INTERFACE {custom} \
    CONFIG.GEM1_BOARD_INTERFACE {custom} \
    CONFIG.GEM2_BOARD_INTERFACE {custom} \
    CONFIG.GEM3_BOARD_INTERFACE {custom} \
    CONFIG.GPIO_BOARD_INTERFACE {custom} \
    CONFIG.IIC0_BOARD_INTERFACE {custom} \
    CONFIG.IIC1_BOARD_INTERFACE {custom} \
    CONFIG.NAND_BOARD_INTERFACE {custom} \
    CONFIG.PCIE_BOARD_INTERFACE {custom} \
    CONFIG.PJTAG_BOARD_INTERFACE {custom} \
    CONFIG.PMU_BOARD_INTERFACE {custom} \
    CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_3_IO_STANDARD {LVCMOS33} \
    CONFIG.PSU_DDR_RAM_HIGHADDR {0xFFFFFFFF} \
    CONFIG.PSU_DDR_RAM_HIGHADDR_OFFSET {0x800000000} \
    CONFIG.PSU_DDR_RAM_LOWADDR_OFFSET {0x80000000} \
    CONFIG.PSU_DYNAMIC_DDR_CONFIG_EN {1} \
    CONFIG.PSU_IMPORT_BOARD_PRESET {} \
    CONFIG.PSU_MIO_0_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_0_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_0_SLEW {fast} \
    CONFIG.PSU_MIO_10_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_10_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_10_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_10_SLEW {fast} \
    CONFIG.PSU_MIO_11_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_11_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_11_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_11_SLEW {fast} \
    CONFIG.PSU_MIO_12_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_12_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_12_SLEW {fast} \
    CONFIG.PSU_MIO_13_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_13_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_13_POLARITY {Default} \
    CONFIG.PSU_MIO_13_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_13_SLEW {fast} \
    CONFIG.PSU_MIO_14_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_14_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_14_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_14_SLEW {fast} \
    CONFIG.PSU_MIO_15_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_15_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_15_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_15_SLEW {fast} \
    CONFIG.PSU_MIO_16_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_16_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_16_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_16_SLEW {fast} \
    CONFIG.PSU_MIO_17_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_17_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_17_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_17_SLEW {fast} \
    CONFIG.PSU_MIO_18_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_18_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_19_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_19_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_19_SLEW {fast} \
    CONFIG.PSU_MIO_1_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_1_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_1_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_1_SLEW {fast} \
    CONFIG.PSU_MIO_20_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_20_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_20_POLARITY {Default} \
    CONFIG.PSU_MIO_20_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_20_SLEW {fast} \
    CONFIG.PSU_MIO_21_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_21_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_21_POLARITY {Default} \
    CONFIG.PSU_MIO_21_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_21_SLEW {fast} \
    CONFIG.PSU_MIO_22_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_22_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_22_POLARITY {Default} \
    CONFIG.PSU_MIO_22_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_22_SLEW {fast} \
    CONFIG.PSU_MIO_23_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_23_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_23_POLARITY {Default} \
    CONFIG.PSU_MIO_23_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_23_SLEW {fast} \
    CONFIG.PSU_MIO_24_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_24_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_24_POLARITY {Default} \
    CONFIG.PSU_MIO_24_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_24_SLEW {fast} \
    CONFIG.PSU_MIO_25_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_25_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_25_POLARITY {Default} \
    CONFIG.PSU_MIO_25_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_25_SLEW {fast} \
    CONFIG.PSU_MIO_26_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_26_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_26_POLARITY {Default} \
    CONFIG.PSU_MIO_26_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_26_SLEW {fast} \
    CONFIG.PSU_MIO_27_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_27_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_27_POLARITY {Default} \
    CONFIG.PSU_MIO_27_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_27_SLEW {fast} \
    CONFIG.PSU_MIO_28_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_28_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_28_POLARITY {Default} \
    CONFIG.PSU_MIO_28_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_28_SLEW {fast} \
    CONFIG.PSU_MIO_29_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_29_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_29_POLARITY {Default} \
    CONFIG.PSU_MIO_29_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_29_SLEW {fast} \
    CONFIG.PSU_MIO_2_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_2_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_2_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_2_SLEW {fast} \
    CONFIG.PSU_MIO_30_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_30_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_30_POLARITY {Default} \
    CONFIG.PSU_MIO_30_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_30_SLEW {fast} \
    CONFIG.PSU_MIO_31_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_31_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_31_POLARITY {Default} \
    CONFIG.PSU_MIO_31_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_31_SLEW {fast} \
    CONFIG.PSU_MIO_32_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_32_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_32_SLEW {fast} \
    CONFIG.PSU_MIO_33_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_33_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_33_SLEW {fast} \
    CONFIG.PSU_MIO_34_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_34_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_34_SLEW {fast} \
    CONFIG.PSU_MIO_35_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_35_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_35_SLEW {fast} \
    CONFIG.PSU_MIO_36_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_36_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_36_SLEW {fast} \
    CONFIG.PSU_MIO_37_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_37_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_37_SLEW {fast} \
    CONFIG.PSU_MIO_38_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_38_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_38_POLARITY {Default} \
    CONFIG.PSU_MIO_38_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_38_SLEW {fast} \
    CONFIG.PSU_MIO_39_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_39_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_39_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_39_SLEW {fast} \
    CONFIG.PSU_MIO_3_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_3_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_3_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_3_SLEW {fast} \
    CONFIG.PSU_MIO_40_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_40_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_40_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_40_SLEW {fast} \
    CONFIG.PSU_MIO_41_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_41_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_41_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_41_SLEW {fast} \
    CONFIG.PSU_MIO_42_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_42_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_42_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_42_SLEW {fast} \
    CONFIG.PSU_MIO_43_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_43_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_43_POLARITY {Default} \
    CONFIG.PSU_MIO_43_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_43_SLEW {fast} \
    CONFIG.PSU_MIO_44_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_44_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_44_POLARITY {Default} \
    CONFIG.PSU_MIO_44_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_44_SLEW {fast} \
    CONFIG.PSU_MIO_45_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_45_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_46_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_46_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_46_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_46_SLEW {fast} \
    CONFIG.PSU_MIO_47_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_47_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_47_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_47_SLEW {fast} \
    CONFIG.PSU_MIO_48_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_48_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_48_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_48_SLEW {fast} \
    CONFIG.PSU_MIO_49_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_49_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_49_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_49_SLEW {fast} \
    CONFIG.PSU_MIO_4_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_4_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_4_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_4_SLEW {fast} \
    CONFIG.PSU_MIO_50_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_50_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_50_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_50_SLEW {fast} \
    CONFIG.PSU_MIO_51_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_51_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_51_SLEW {fast} \
    CONFIG.PSU_MIO_52_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_52_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_53_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_53_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_54_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_54_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_54_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_54_SLEW {fast} \
    CONFIG.PSU_MIO_55_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_55_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_56_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_56_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_56_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_56_SLEW {fast} \
    CONFIG.PSU_MIO_57_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_57_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_57_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_57_SLEW {fast} \
    CONFIG.PSU_MIO_58_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_58_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_58_SLEW {fast} \
    CONFIG.PSU_MIO_59_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_59_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_59_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_59_SLEW {fast} \
    CONFIG.PSU_MIO_5_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_5_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_5_SLEW {fast} \
    CONFIG.PSU_MIO_60_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_60_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_60_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_60_SLEW {fast} \
    CONFIG.PSU_MIO_61_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_61_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_61_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_61_SLEW {fast} \
    CONFIG.PSU_MIO_62_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_62_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_62_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_62_SLEW {fast} \
    CONFIG.PSU_MIO_63_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_63_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_63_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_63_SLEW {fast} \
    CONFIG.PSU_MIO_64_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_64_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_64_SLEW {fast} \
    CONFIG.PSU_MIO_65_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_65_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_65_SLEW {fast} \
    CONFIG.PSU_MIO_66_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_66_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_66_SLEW {fast} \
    CONFIG.PSU_MIO_67_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_67_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_67_SLEW {fast} \
    CONFIG.PSU_MIO_68_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_68_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_68_SLEW {fast} \
    CONFIG.PSU_MIO_69_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_69_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_69_SLEW {fast} \
    CONFIG.PSU_MIO_6_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_6_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_6_SLEW {fast} \
    CONFIG.PSU_MIO_70_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_70_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_71_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_71_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_72_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_72_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_73_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_73_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_74_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_74_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_75_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_75_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_76_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_76_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_76_SLEW {fast} \
    CONFIG.PSU_MIO_77_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_77_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_77_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_77_SLEW {fast} \
    CONFIG.PSU_MIO_7_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_7_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_7_SLEW {fast} \
    CONFIG.PSU_MIO_8_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_8_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_8_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_8_SLEW {fast} \
    CONFIG.PSU_MIO_9_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_9_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_9_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_9_SLEW {fast} \
    CONFIG.PSU_MIO_TREE_PERIPHERALS {Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Feedback Clk#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad\
SPI Flash#Quad SPI Flash#GPIO0 MIO#I2C 0#I2C 0#I2C 1#I2C 1#UART 0#UART 0#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#PMU GPO\
0#PMU GPO 1#PMU GPO 2#PMU GPO 3#PMU GPO 4#PMU GPO 5#GPIO1 MIO#SD 1#SD 1#SD 1#SD 1#GPIO1 MIO#GPIO1 MIO#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB\
0#USB 0#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#MDIO 3#MDIO 3} \
    CONFIG.PSU_MIO_TREE_SIGNALS {sclk_out#miso_mo1#mo2#mo3#mosi_mi0#n_ss_out#clk_for_lpbk#n_ss_out_upper#mo_upper[0]#mo_upper[1]#mo_upper[2]#mo_upper[3]#sclk_out_upper#gpio0[13]#scl_out#sda_out#scl_out#sda_out#rxd#txd#gpio0[20]#gpio0[21]#gpio0[22]#gpio0[23]#gpio0[24]#gpio0[25]#gpio1[26]#gpio1[27]#gpio1[28]#gpio1[29]#gpio1[30]#gpio1[31]#gpo[0]#gpo[1]#gpo[2]#gpo[3]#gpo[4]#gpo[5]#gpio1[38]#sdio1_data_out[4]#sdio1_data_out[5]#sdio1_data_out[6]#sdio1_data_out[7]#gpio1[43]#gpio1[44]#sdio1_cd_n#sdio1_data_out[0]#sdio1_data_out[1]#sdio1_data_out[2]#sdio1_data_out[3]#sdio1_cmd_out#sdio1_clk_out#ulpi_clk_in#ulpi_dir#ulpi_tx_data[2]#ulpi_nxt#ulpi_tx_data[0]#ulpi_tx_data[1]#ulpi_stp#ulpi_tx_data[3]#ulpi_tx_data[4]#ulpi_tx_data[5]#ulpi_tx_data[6]#ulpi_tx_data[7]#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#gem3_mdc#gem3_mdio_out}\
\
    CONFIG.PSU_PERIPHERAL_BOARD_PRESET {} \
    CONFIG.PSU_SD0_INTERNAL_BUS_WIDTH {8} \
    CONFIG.PSU_SD1_INTERNAL_BUS_WIDTH {8} \
    CONFIG.PSU_SMC_CYCLE_T0 {NA} \
    CONFIG.PSU_SMC_CYCLE_T1 {NA} \
    CONFIG.PSU_SMC_CYCLE_T2 {NA} \
    CONFIG.PSU_SMC_CYCLE_T3 {NA} \
    CONFIG.PSU_SMC_CYCLE_T4 {NA} \
    CONFIG.PSU_SMC_CYCLE_T5 {NA} \
    CONFIG.PSU_SMC_CYCLE_T6 {NA} \
    CONFIG.PSU_USB3__DUAL_CLOCK_ENABLE {1} \
    CONFIG.PSU_VALUE_SILVERSION {3} \
    CONFIG.PSU__ACPU0__POWER__ON {1} \
    CONFIG.PSU__ACPU1__POWER__ON {1} \
    CONFIG.PSU__ACPU2__POWER__ON {1} \
    CONFIG.PSU__ACPU3__POWER__ON {1} \
    CONFIG.PSU__ACTUAL__IP {1} \
    CONFIG.PSU__ACT_DDR_FREQ_MHZ {1049.989502} \
    CONFIG.PSU__AFI0_COHERENCY {0} \
    CONFIG.PSU__AFI1_COHERENCY {0} \
    CONFIG.PSU__AUX_REF_CLK__FREQMHZ {33.333} \
    CONFIG.PSU__CAN0_LOOP_CAN1__ENABLE {0} \
    CONFIG.PSU__CAN0__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__CAN1__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__ACT_FREQMHZ {1199.988037} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__FREQMHZ {1200} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__ACPU__FRAC_ENABLED {0} \
    CONFIG.PSU__CRF_APB__AFI0_REF_CTRL__ACT_FREQMHZ {667} \
    CONFIG.PSU__CRF_APB__AFI0_REF_CTRL__DIVISOR0 {2} \
    CONFIG.PSU__CRF_APB__AFI0_REF_CTRL__FREQMHZ {667} \
    CONFIG.PSU__CRF_APB__AFI0_REF_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__AFI0_REF__ENABLE {0} \
    CONFIG.PSU__CRF_APB__AFI1_REF_CTRL__ACT_FREQMHZ {667} \
    CONFIG.PSU__CRF_APB__AFI1_REF_CTRL__DIVISOR0 {2} \
    CONFIG.PSU__CRF_APB__AFI1_REF_CTRL__FREQMHZ {667} \
    CONFIG.PSU__CRF_APB__AFI1_REF_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__AFI1_REF__ENABLE {0} \
    CONFIG.PSU__CRF_APB__AFI2_REF_CTRL__ACT_FREQMHZ {667} \
    CONFIG.PSU__CRF_APB__AFI2_REF_CTRL__DIVISOR0 {2} \
    CONFIG.PSU__CRF_APB__AFI2_REF_CTRL__FREQMHZ {667} \
    CONFIG.PSU__CRF_APB__AFI2_REF_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__AFI2_REF__ENABLE {0} \
    CONFIG.PSU__CRF_APB__AFI3_REF_CTRL__ACT_FREQMHZ {667} \
    CONFIG.PSU__CRF_APB__AFI3_REF_CTRL__DIVISOR0 {2} \
    CONFIG.PSU__CRF_APB__AFI3_REF_CTRL__FREQMHZ {667} \
    CONFIG.PSU__CRF_APB__AFI3_REF_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__AFI3_REF__ENABLE {0} \
    CONFIG.PSU__CRF_APB__AFI4_REF_CTRL__ACT_FREQMHZ {667} \
    CONFIG.PSU__CRF_APB__AFI4_REF_CTRL__DIVISOR0 {2} \
    CONFIG.PSU__CRF_APB__AFI4_REF_CTRL__FREQMHZ {667} \
    CONFIG.PSU__CRF_APB__AFI4_REF_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__AFI4_REF__ENABLE {0} \
    CONFIG.PSU__CRF_APB__AFI5_REF_CTRL__ACT_FREQMHZ {667} \
    CONFIG.PSU__CRF_APB__AFI5_REF_CTRL__DIVISOR0 {2} \
    CONFIG.PSU__CRF_APB__AFI5_REF_CTRL__FREQMHZ {667} \
    CONFIG.PSU__CRF_APB__AFI5_REF_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__AFI5_REF__ENABLE {0} \
    CONFIG.PSU__CRF_APB__APLL_CTRL__FRACFREQ {27.138} \
    CONFIG.PSU__CRF_APB__APLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRF_APB__APM_CTRL__ACT_FREQMHZ {1} \
    CONFIG.PSU__CRF_APB__APM_CTRL__DIVISOR0 {1} \
    CONFIG.PSU__CRF_APB__APM_CTRL__FREQMHZ {1} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__ACT_FREQMHZ {249.997498} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__ACT_FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__ACT_FREQMHZ {249.997498} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__ACT_FREQMHZ {524.994751} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {1066} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__ACT_FREQMHZ {599.994019} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__FREQMHZ {600} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__DPLL_CTRL__FRACFREQ {27.138} \
    CONFIG.PSU__CRF_APB__DPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__ACT_FREQMHZ {25} \
    CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__FREQMHZ {25} \
    CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__ACT_FREQMHZ {27} \
    CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__FREQMHZ {27} \
    CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__ACT_FREQMHZ {320} \
    CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__FREQMHZ {300} \
    CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__SRCSEL {VPLL} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__ACT_FREQMHZ {599.994019} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__FREQMHZ {600} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__ACT_FREQMHZ {0} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__GTGREF0_REF_CTRL__ACT_FREQMHZ {-1} \
    CONFIG.PSU__CRF_APB__GTGREF0_REF_CTRL__DIVISOR0 {-1} \
    CONFIG.PSU__CRF_APB__GTGREF0_REF_CTRL__FREQMHZ {-1} \
    CONFIG.PSU__CRF_APB__GTGREF0_REF_CTRL__SRCSEL {NA} \
    CONFIG.PSU__CRF_APB__GTGREF0__ENABLE {NA} \
    CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__ACT_FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__SATA_REF_CTRL__ACT_FREQMHZ {249.997498} \
    CONFIG.PSU__CRF_APB__SATA_REF_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__SATA_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__ACT_FREQMHZ {524.994751} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__FREQMHZ {533.33} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__VPLL_CTRL__FRACFREQ {27.138} \
    CONFIG.PSU__CRF_APB__VPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__ACT_FREQMHZ {499.994995} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__AFI6_REF_CTRL__ACT_FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__AFI6_REF_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__AFI6_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__AFI6__ENABLE {0} \
    CONFIG.PSU__CRL_APB__AMS_REF_CTRL__ACT_FREQMHZ {49.999500} \
    CONFIG.PSU__CRL_APB__AMS_REF_CTRL__FREQMHZ {50} \
    CONFIG.PSU__CRL_APB__AMS_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__ACT_FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__ACT_FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__ACT_FREQMHZ {499.994995} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__CSU_PLL_CTRL__ACT_FREQMHZ {180} \
    CONFIG.PSU__CRL_APB__CSU_PLL_CTRL__DIVISOR0 {3} \
    CONFIG.PSU__CRL_APB__CSU_PLL_CTRL__SRCSEL {SysOsc} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__ACT_FREQMHZ {249.997498} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__DEBUG_R5_ATCLK_CTRL__ACT_FREQMHZ {1000} \
    CONFIG.PSU__CRL_APB__DEBUG_R5_ATCLK_CTRL__DIVISOR0 {6} \
    CONFIG.PSU__CRL_APB__DEBUG_R5_ATCLK_CTRL__FREQMHZ {1000} \
    CONFIG.PSU__CRL_APB__DEBUG_R5_ATCLK_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRL_APB__DLL_REF_CTRL__ACT_FREQMHZ {1499.984985} \
    CONFIG.PSU__CRL_APB__DLL_REF_CTRL__FREQMHZ {1500} \
    CONFIG.PSU__CRL_APB__DLL_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__ACT_FREQMHZ {125} \
    CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__FREQMHZ {125} \
    CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__ACT_FREQMHZ {125} \
    CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__FREQMHZ {125} \
    CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__ACT_FREQMHZ {125} \
    CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__FREQMHZ {125} \
    CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__ACT_FREQMHZ {124.998749} \
    CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__FREQMHZ {125} \
    CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__ACT_FREQMHZ {249.997498} \
    CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__IOPLL_CTRL__FRACFREQ {27.138} \
    CONFIG.PSU__CRL_APB__IOPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__ACT_FREQMHZ {249.997498} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__ACT_FREQMHZ {499.994995} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__NAND_REF_CTRL__ACT_FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__NAND_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__NAND_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__OCM_MAIN_CTRL__ACT_FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__OCM_MAIN_CTRL__DIVISOR0 {3} \
    CONFIG.PSU__CRL_APB__OCM_MAIN_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__OCM_MAIN_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__ACT_FREQMHZ {187.498123} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__FREQMHZ {200} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PL1_REF_CTRL__ACT_FREQMHZ {1.999980} \
    CONFIG.PSU__CRL_APB__PL2_REF_CTRL__ACT_FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__PL3_REF_CTRL__ACT_FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__ACT_FREQMHZ {124.998749} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__FREQMHZ {125} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__RPLL_CTRL__FRACFREQ {27.138} \
    CONFIG.PSU__CRL_APB__RPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__ACT_FREQMHZ {200} \
    CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__FREQMHZ {200} \
    CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__ACT_FREQMHZ {187.498123} \
    CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__FREQMHZ {200} \
    CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__ACT_FREQMHZ {214} \
    CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__FREQMHZ {200} \
    CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__ACT_FREQMHZ {214} \
    CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__FREQMHZ {200} \
    CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__UART0_REF_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__UART0_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__UART0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__UART1_REF_CTRL__ACT_FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__UART1_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__UART1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__ACT_FREQMHZ {249.997498} \
    CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__ACT_FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__ACT_FREQMHZ {19.999800} \
    CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__FREQMHZ {20} \
    CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__USB3__ENABLE {1} \
    CONFIG.PSU__CSUPMU__PERIPHERAL__VALID {1} \
    CONFIG.PSU__CSU__CSU_TAMPER_0__ENABLE {0} \
    CONFIG.PSU__CSU__CSU_TAMPER_10__ENABLE {0} \
    CONFIG.PSU__CSU__CSU_TAMPER_11__ENABLE {0} \
    CONFIG.PSU__CSU__CSU_TAMPER_12__ENABLE {0} \
    CONFIG.PSU__CSU__CSU_TAMPER_1__ENABLE {0} \
    CONFIG.PSU__CSU__CSU_TAMPER_2__ENABLE {0} \
    CONFIG.PSU__CSU__CSU_TAMPER_3__ENABLE {0} \
    CONFIG.PSU__CSU__CSU_TAMPER_4__ENABLE {0} \
    CONFIG.PSU__CSU__CSU_TAMPER_5__ENABLE {0} \
    CONFIG.PSU__CSU__CSU_TAMPER_6__ENABLE {0} \
    CONFIG.PSU__CSU__CSU_TAMPER_7__ENABLE {0} \
    CONFIG.PSU__CSU__CSU_TAMPER_8__ENABLE {0} \
    CONFIG.PSU__CSU__CSU_TAMPER_9__ENABLE {0} \
    CONFIG.PSU__CSU__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__DDRC__AL {0} \
    CONFIG.PSU__DDRC__BG_ADDR_COUNT {1} \
    CONFIG.PSU__DDRC__BRC_MAPPING {ROW_BANK_COL} \
    CONFIG.PSU__DDRC__BUS_WIDTH {64 Bit} \
    CONFIG.PSU__DDRC__CL {15} \
    CONFIG.PSU__DDRC__CLOCK_STOP_EN {0} \
    CONFIG.PSU__DDRC__COMPONENTS {UDIMM} \
    CONFIG.PSU__DDRC__CWL {11} \
    CONFIG.PSU__DDRC__DDR4_ADDR_MAPPING {0} \
    CONFIG.PSU__DDRC__DDR4_CAL_MODE_ENABLE {0} \
    CONFIG.PSU__DDRC__DDR4_CRC_CONTROL {0} \
    CONFIG.PSU__DDRC__DDR4_MAXPWR_SAVING_EN {0} \
    CONFIG.PSU__DDRC__DDR4_T_REF_MODE {0} \
    CONFIG.PSU__DDRC__DDR4_T_REF_RANGE {Normal (0-85)} \
    CONFIG.PSU__DDRC__DEVICE_CAPACITY {8192 MBits} \
    CONFIG.PSU__DDRC__DM_DBI {DM_NO_DBI} \
    CONFIG.PSU__DDRC__DRAM_WIDTH {16 Bits} \
    CONFIG.PSU__DDRC__ECC {Disabled} \
    CONFIG.PSU__DDRC__ECC_SCRUB {0} \
    CONFIG.PSU__DDRC__ENABLE {1} \
    CONFIG.PSU__DDRC__ENABLE_2T_TIMING {0} \
    CONFIG.PSU__DDRC__ENABLE_DP_SWITCH {0} \
    CONFIG.PSU__DDRC__EN_2ND_CLK {0} \
    CONFIG.PSU__DDRC__FGRM {1X} \
    CONFIG.PSU__DDRC__FREQ_MHZ {1} \
    CONFIG.PSU__DDRC__LPDDR3_DUALRANK_SDP {0} \
    CONFIG.PSU__DDRC__LP_ASR {manual normal} \
    CONFIG.PSU__DDRC__MEMORY_TYPE {DDR 4} \
    CONFIG.PSU__DDRC__PARITY_ENABLE {0} \
    CONFIG.PSU__DDRC__PER_BANK_REFRESH {0} \
    CONFIG.PSU__DDRC__PHY_DBI_MODE {0} \
    CONFIG.PSU__DDRC__PLL_BYPASS {0} \
    CONFIG.PSU__DDRC__PWR_DOWN_EN {0} \
    CONFIG.PSU__DDRC__RANK_ADDR_COUNT {0} \
    CONFIG.PSU__DDRC__RD_DQS_CENTER {0} \
    CONFIG.PSU__DDRC__ROW_ADDR_COUNT {16} \
    CONFIG.PSU__DDRC__SELF_REF_ABORT {0} \
    CONFIG.PSU__DDRC__SPEED_BIN {DDR4_2133P} \
    CONFIG.PSU__DDRC__STATIC_RD_MODE {0} \
    CONFIG.PSU__DDRC__TRAIN_DATA_EYE {1} \
    CONFIG.PSU__DDRC__TRAIN_READ_GATE {1} \
    CONFIG.PSU__DDRC__TRAIN_WRITE_LEVEL {1} \
    CONFIG.PSU__DDRC__T_FAW {30.0} \
    CONFIG.PSU__DDRC__T_RAS_MIN {33} \
    CONFIG.PSU__DDRC__T_RC {46.5} \
    CONFIG.PSU__DDRC__T_RCD {15} \
    CONFIG.PSU__DDRC__T_RP {15} \
    CONFIG.PSU__DDRC__VIDEO_BUFFER_SIZE {0} \
    CONFIG.PSU__DDRC__VREF {1} \
    CONFIG.PSU__DDR_HIGH_ADDRESS_GUI_ENABLE {1} \
    CONFIG.PSU__DDR_QOS_ENABLE {0} \
    CONFIG.PSU__DDR_QOS_HP0_RDQOS {} \
    CONFIG.PSU__DDR_QOS_HP0_WRQOS {} \
    CONFIG.PSU__DDR_QOS_HP1_RDQOS {} \
    CONFIG.PSU__DDR_QOS_HP1_WRQOS {} \
    CONFIG.PSU__DDR_QOS_HP2_RDQOS {} \
    CONFIG.PSU__DDR_QOS_HP2_WRQOS {} \
    CONFIG.PSU__DDR_QOS_HP3_RDQOS {} \
    CONFIG.PSU__DDR_QOS_HP3_WRQOS {} \
    CONFIG.PSU__DDR_SW_REFRESH_ENABLED {1} \
    CONFIG.PSU__DDR__INTERFACE__FREQMHZ {533.000} \
    CONFIG.PSU__DEVICE_TYPE {RFSOC} \
    CONFIG.PSU__DISPLAYPORT__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__DLL__ISUSED {1} \
    CONFIG.PSU__ENABLE__DDR__REFRESH__SIGNALS {0} \
    CONFIG.PSU__ENET0__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__ENET1__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__ENET2__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__ENET3__FIFO__ENABLE {0} \
    CONFIG.PSU__ENET3__GRP_MDIO__ENABLE {1} \
    CONFIG.PSU__ENET3__GRP_MDIO__IO {MIO 76 .. 77} \
    CONFIG.PSU__ENET3__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__ENET3__PERIPHERAL__IO {MIO 64 .. 75} \
    CONFIG.PSU__ENET3__PTP__ENABLE {0} \
    CONFIG.PSU__ENET3__TSU__ENABLE {0} \
    CONFIG.PSU__EN_AXI_STATUS_PORTS {0} \
    CONFIG.PSU__EN_EMIO_TRACE {0} \
    CONFIG.PSU__EP__IP {0} \
    CONFIG.PSU__EXPAND__CORESIGHT {0} \
    CONFIG.PSU__EXPAND__FPD_SLAVES {0} \
    CONFIG.PSU__EXPAND__GIC {0} \
    CONFIG.PSU__EXPAND__LOWER_LPS_SLAVES {0} \
    CONFIG.PSU__EXPAND__UPPER_LPS_SLAVES {0} \
    CONFIG.PSU__FPDMASTERS_COHERENCY {0} \
    CONFIG.PSU__FPD_SLCR__WDT1__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__FPGA_PL0_ENABLE {1} \
    CONFIG.PSU__FPGA_PL1_ENABLE {0} \
    CONFIG.PSU__FPGA_PL2_ENABLE {0} \
    CONFIG.PSU__FPGA_PL3_ENABLE {0} \
    CONFIG.PSU__FP__POWER__ON {1} \
    CONFIG.PSU__FTM__CTI_IN_0 {0} \
    CONFIG.PSU__FTM__CTI_IN_1 {0} \
    CONFIG.PSU__FTM__CTI_IN_2 {0} \
    CONFIG.PSU__FTM__CTI_IN_3 {0} \
    CONFIG.PSU__FTM__CTI_OUT_0 {0} \
    CONFIG.PSU__FTM__CTI_OUT_1 {0} \
    CONFIG.PSU__FTM__CTI_OUT_2 {0} \
    CONFIG.PSU__FTM__CTI_OUT_3 {0} \
    CONFIG.PSU__FTM__GPI {0} \
    CONFIG.PSU__FTM__GPO {0} \
    CONFIG.PSU__GEM3_COHERENCY {0} \
    CONFIG.PSU__GEM3_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__GEM__TSU__ENABLE {0} \
    CONFIG.PSU__GEN_IPI_0__MASTER {APU} \
    CONFIG.PSU__GEN_IPI_10__MASTER {NONE} \
    CONFIG.PSU__GEN_IPI_1__MASTER {RPU0} \
    CONFIG.PSU__GEN_IPI_2__MASTER {RPU1} \
    CONFIG.PSU__GEN_IPI_3__MASTER {PMU} \
    CONFIG.PSU__GEN_IPI_4__MASTER {PMU} \
    CONFIG.PSU__GEN_IPI_5__MASTER {PMU} \
    CONFIG.PSU__GEN_IPI_6__MASTER {PMU} \
    CONFIG.PSU__GEN_IPI_7__MASTER {NONE} \
    CONFIG.PSU__GEN_IPI_8__MASTER {NONE} \
    CONFIG.PSU__GEN_IPI_9__MASTER {NONE} \
    CONFIG.PSU__GPIO0_MIO__IO {MIO 0 .. 25} \
    CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__GPIO1_MIO__IO {MIO 26 .. 51} \
    CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__GPIO2_MIO__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__GPIO_EMIO_WIDTH {1} \
    CONFIG.PSU__GPIO_EMIO__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__GPIO_EMIO__WIDTH {[94:0]} \
    CONFIG.PSU__GPU_PP0__POWER__ON {0} \
    CONFIG.PSU__GPU_PP1__POWER__ON {0} \
    CONFIG.PSU__GT_REF_CLK__FREQMHZ {33.333} \
    CONFIG.PSU__HPM0_FPD__NUM_READ_THREADS {4} \
    CONFIG.PSU__HPM0_FPD__NUM_WRITE_THREADS {4} \
    CONFIG.PSU__HPM0_LPD__NUM_READ_THREADS {4} \
    CONFIG.PSU__HPM0_LPD__NUM_WRITE_THREADS {4} \
    CONFIG.PSU__HPM1_FPD__NUM_READ_THREADS {4} \
    CONFIG.PSU__HPM1_FPD__NUM_WRITE_THREADS {4} \
    CONFIG.PSU__I2C0_LOOP_I2C1__ENABLE {0} \
    CONFIG.PSU__I2C0__GRP_INT__ENABLE {0} \
    CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__I2C0__PERIPHERAL__IO {MIO 14 .. 15} \
    CONFIG.PSU__I2C1__GRP_INT__ENABLE {0} \
    CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__I2C1__PERIPHERAL__IO {MIO 16 .. 17} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC0_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC1_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC2_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC3_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__TTC0__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC1__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC2__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC3__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__WDT0__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__IRQ_P2F_ADMA_CHAN__INT {0} \
    CONFIG.PSU__IRQ_P2F_AIB_AXI__INT {0} \
    CONFIG.PSU__IRQ_P2F_AMS__INT {0} \
    CONFIG.PSU__IRQ_P2F_APM_FPD__INT {0} \
    CONFIG.PSU__IRQ_P2F_APU_COMM__INT {0} \
    CONFIG.PSU__IRQ_P2F_APU_CPUMNT__INT {0} \
    CONFIG.PSU__IRQ_P2F_APU_CTI__INT {0} \
    CONFIG.PSU__IRQ_P2F_APU_EXTERR__INT {0} \
    CONFIG.PSU__IRQ_P2F_APU_IPI__INT {0} \
    CONFIG.PSU__IRQ_P2F_APU_L2ERR__INT {0} \
    CONFIG.PSU__IRQ_P2F_APU_PMU__INT {0} \
    CONFIG.PSU__IRQ_P2F_APU_REGS__INT {0} \
    CONFIG.PSU__IRQ_P2F_ATB_LPD__INT {0} \
    CONFIG.PSU__IRQ_P2F_CLKMON__INT {0} \
    CONFIG.PSU__IRQ_P2F_CSUPMU_WDT__INT {0} \
    CONFIG.PSU__IRQ_P2F_DDR_SS__INT {0} \
    CONFIG.PSU__IRQ_P2F_DPDMA__INT {0} \
    CONFIG.PSU__IRQ_P2F_EFUSE__INT {0} \
    CONFIG.PSU__IRQ_P2F_ENT3_WAKEUP__INT {0} \
    CONFIG.PSU__IRQ_P2F_ENT3__INT {0} \
    CONFIG.PSU__IRQ_P2F_FPD_APB__INT {0} \
    CONFIG.PSU__IRQ_P2F_FPD_ATB_ERR__INT {0} \
    CONFIG.PSU__IRQ_P2F_FP_WDT__INT {0} \
    CONFIG.PSU__IRQ_P2F_GDMA_CHAN__INT {0} \
    CONFIG.PSU__IRQ_P2F_GPIO__INT {0} \
    CONFIG.PSU__IRQ_P2F_GPU__INT {0} \
    CONFIG.PSU__IRQ_P2F_I2C0__INT {0} \
    CONFIG.PSU__IRQ_P2F_I2C1__INT {0} \
    CONFIG.PSU__IRQ_P2F_LPD_APB__INT {0} \
    CONFIG.PSU__IRQ_P2F_LPD_APM__INT {0} \
    CONFIG.PSU__IRQ_P2F_LP_WDT__INT {0} \
    CONFIG.PSU__IRQ_P2F_OCM_ERR__INT {0} \
    CONFIG.PSU__IRQ_P2F_PCIE_DMA__INT {0} \
    CONFIG.PSU__IRQ_P2F_PCIE_LEGACY__INT {0} \
    CONFIG.PSU__IRQ_P2F_PCIE_MSC__INT {0} \
    CONFIG.PSU__IRQ_P2F_PCIE_MSI__INT {0} \
    CONFIG.PSU__IRQ_P2F_PL_IPI__INT {0} \
    CONFIG.PSU__IRQ_P2F_QSPI__INT {0} \
    CONFIG.PSU__IRQ_P2F_R5_CORE0_ECC_ERR__INT {0} \
    CONFIG.PSU__IRQ_P2F_R5_CORE1_ECC_ERR__INT {0} \
    CONFIG.PSU__IRQ_P2F_RPU_IPI__INT {0} \
    CONFIG.PSU__IRQ_P2F_RPU_PERMON__INT {0} \
    CONFIG.PSU__IRQ_P2F_RTC_ALARM__INT {0} \
    CONFIG.PSU__IRQ_P2F_RTC_SECONDS__INT {0} \
    CONFIG.PSU__IRQ_P2F_SATA__INT {0} \
    CONFIG.PSU__IRQ_P2F_SDIO1_WAKE__INT {0} \
    CONFIG.PSU__IRQ_P2F_SDIO1__INT {0} \
    CONFIG.PSU__IRQ_P2F_TTC0__INT0 {0} \
    CONFIG.PSU__IRQ_P2F_TTC0__INT1 {0} \
    CONFIG.PSU__IRQ_P2F_TTC0__INT2 {0} \
    CONFIG.PSU__IRQ_P2F_TTC1__INT0 {0} \
    CONFIG.PSU__IRQ_P2F_TTC1__INT1 {0} \
    CONFIG.PSU__IRQ_P2F_TTC1__INT2 {0} \
    CONFIG.PSU__IRQ_P2F_TTC2__INT0 {0} \
    CONFIG.PSU__IRQ_P2F_TTC2__INT1 {0} \
    CONFIG.PSU__IRQ_P2F_TTC2__INT2 {0} \
    CONFIG.PSU__IRQ_P2F_TTC3__INT0 {0} \
    CONFIG.PSU__IRQ_P2F_TTC3__INT1 {0} \
    CONFIG.PSU__IRQ_P2F_TTC3__INT2 {0} \
    CONFIG.PSU__IRQ_P2F_UART0__INT {0} \
    CONFIG.PSU__IRQ_P2F_USB3_ENDPOINT__INT0 {0} \
    CONFIG.PSU__IRQ_P2F_USB3_ENDPOINT__INT1 {0} \
    CONFIG.PSU__IRQ_P2F_USB3_OTG__INT0 {0} \
    CONFIG.PSU__IRQ_P2F_USB3_OTG__INT1 {0} \
    CONFIG.PSU__IRQ_P2F_USB3_PMU_WAKEUP__INT {0} \
    CONFIG.PSU__IRQ_P2F_XMPU_FPD__INT {0} \
    CONFIG.PSU__IRQ_P2F_XMPU_LPD__INT {0} \
    CONFIG.PSU__IRQ_P2F__INTF_FPD_SMMU__INT {0} \
    CONFIG.PSU__IRQ_P2F__INTF_PPD_CCI__INT {0} \
    CONFIG.PSU__L2_BANK0__POWER__ON {1} \
    CONFIG.PSU__LPDMA0_COHERENCY {0} \
    CONFIG.PSU__LPDMA1_COHERENCY {0} \
    CONFIG.PSU__LPDMA2_COHERENCY {0} \
    CONFIG.PSU__LPDMA3_COHERENCY {0} \
    CONFIG.PSU__LPDMA4_COHERENCY {0} \
    CONFIG.PSU__LPDMA5_COHERENCY {0} \
    CONFIG.PSU__LPDMA6_COHERENCY {0} \
    CONFIG.PSU__LPDMA7_COHERENCY {0} \
    CONFIG.PSU__LPD_SLCR__CSUPMU_WDT_CLK_SEL__SELECT {APB} \
    CONFIG.PSU__LPD_SLCR__CSUPMU__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__MAXIGP0__DATA_WIDTH {128} \
    CONFIG.PSU__MAXIGP1__DATA_WIDTH {128} \
    CONFIG.PSU__M_AXI_GP0_SUPPORTS_NARROW_BURST {1} \
    CONFIG.PSU__M_AXI_GP1_SUPPORTS_NARROW_BURST {1} \
    CONFIG.PSU__M_AXI_GP2_SUPPORTS_NARROW_BURST {1} \
    CONFIG.PSU__NAND__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__NAND__READY_BUSY__ENABLE {0} \
    CONFIG.PSU__NUM_FABRIC_RESETS {1} \
    CONFIG.PSU__OCM_BANK0__POWER__ON {1} \
    CONFIG.PSU__OCM_BANK1__POWER__ON {1} \
    CONFIG.PSU__OCM_BANK2__POWER__ON {1} \
    CONFIG.PSU__OCM_BANK3__POWER__ON {1} \
    CONFIG.PSU__OVERRIDE_HPX_QOS {0} \
    CONFIG.PSU__OVERRIDE__BASIC_CLOCK {0} \
    CONFIG.PSU__PCIE__ACS_VIOLAION {0} \
    CONFIG.PSU__PCIE__AER_CAPABILITY {0} \
    CONFIG.PSU__PCIE__CLASS_CODE_BASE {} \
    CONFIG.PSU__PCIE__CLASS_CODE_INTERFACE {} \
    CONFIG.PSU__PCIE__CLASS_CODE_SUB {} \
    CONFIG.PSU__PCIE__DEVICE_ID {} \
    CONFIG.PSU__PCIE__INTX_GENERATION {0} \
    CONFIG.PSU__PCIE__MSIX_CAPABILITY {0} \
    CONFIG.PSU__PCIE__MSI_CAPABILITY {0} \
    CONFIG.PSU__PCIE__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__PCIE__PERIPHERAL__ENDPOINT_ENABLE {1} \
    CONFIG.PSU__PCIE__PERIPHERAL__ROOTPORT_ENABLE {0} \
    CONFIG.PSU__PCIE__RESET__POLARITY {Active Low} \
    CONFIG.PSU__PCIE__REVISION_ID {} \
    CONFIG.PSU__PCIE__SUBSYSTEM_ID {} \
    CONFIG.PSU__PCIE__SUBSYSTEM_VENDOR_ID {} \
    CONFIG.PSU__PCIE__VENDOR_ID {} \
    CONFIG.PSU__PJTAG__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__PL_CLK0_BUF {TRUE} \
    CONFIG.PSU__PL__POWER__ON {1} \
    CONFIG.PSU__PMU_COHERENCY {0} \
    CONFIG.PSU__PMU__AIBACK__ENABLE {0} \
    CONFIG.PSU__PMU__EMIO_GPI__ENABLE {0} \
    CONFIG.PSU__PMU__EMIO_GPO__ENABLE {0} \
    CONFIG.PSU__PMU__GPI0__ENABLE {0} \
    CONFIG.PSU__PMU__GPI1__ENABLE {0} \
    CONFIG.PSU__PMU__GPI2__ENABLE {0} \
    CONFIG.PSU__PMU__GPI3__ENABLE {0} \
    CONFIG.PSU__PMU__GPI4__ENABLE {0} \
    CONFIG.PSU__PMU__GPI5__ENABLE {0} \
    CONFIG.PSU__PMU__GPO0__ENABLE {1} \
    CONFIG.PSU__PMU__GPO0__IO {MIO 32} \
    CONFIG.PSU__PMU__GPO1__ENABLE {1} \
    CONFIG.PSU__PMU__GPO1__IO {MIO 33} \
    CONFIG.PSU__PMU__GPO2__ENABLE {1} \
    CONFIG.PSU__PMU__GPO2__IO {MIO 34} \
    CONFIG.PSU__PMU__GPO2__POLARITY {low} \
    CONFIG.PSU__PMU__GPO3__ENABLE {1} \
    CONFIG.PSU__PMU__GPO3__IO {MIO 35} \
    CONFIG.PSU__PMU__GPO3__POLARITY {low} \
    CONFIG.PSU__PMU__GPO4__ENABLE {1} \
    CONFIG.PSU__PMU__GPO4__IO {MIO 36} \
    CONFIG.PSU__PMU__GPO4__POLARITY {low} \
    CONFIG.PSU__PMU__GPO5__ENABLE {1} \
    CONFIG.PSU__PMU__GPO5__IO {MIO 37} \
    CONFIG.PSU__PMU__GPO5__POLARITY {low} \
    CONFIG.PSU__PMU__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__PMU__PLERROR__ENABLE {0} \
    CONFIG.PSU__PRESET_APPLIED {1} \
    CONFIG.PSU__PROTECTION__DDR_SEGMENTS {NONE} \
    CONFIG.PSU__PROTECTION__ENABLE {0} \
    CONFIG.PSU__PROTECTION__FPD_SEGMENTS {SA:0xFD1A0000; SIZE:1280; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware  |   SA:0xFD000000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware  |   SA:0xFD010000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware  |   SA:0xFD020000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware  |   SA:0xFD030000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware  |   SA:0xFD040000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware  |   SA:0xFD050000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware  |   SA:0xFD610000; SIZE:512; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware  |   SA:0xFD5D0000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware  |  SA:0xFD1A0000 ; SIZE:1280; UNIT:KB; RegionTZ:Secure ; WrAllowed:Read/Write;\
subsystemId:Secure Subsystem} \
    CONFIG.PSU__PROTECTION__LPD_SEGMENTS {SA:0xFF980000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF5E0000; SIZE:2560; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware| SA:0xFFCC0000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF180000; SIZE:768; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU\
Firmware| SA:0xFF410000; SIZE:640; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFFA70000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware|\
SA:0xFF9A0000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware|SA:0xFF5E0000 ; SIZE:2560; UNIT:KB; RegionTZ:Secure ; WrAllowed:Read/Write; subsystemId:Secure Subsystem|SA:0xFFCC0000\
; SIZE:64; UNIT:KB; RegionTZ:Secure ; WrAllowed:Read/Write; subsystemId:Secure Subsystem|SA:0xFF180000 ; SIZE:768; UNIT:KB; RegionTZ:Secure ; WrAllowed:Read/Write; subsystemId:Secure Subsystem|SA:0xFF9A0000\
; SIZE:64; UNIT:KB; RegionTZ:Secure ; WrAllowed:Read/Write; subsystemId:Secure Subsystem} \
    CONFIG.PSU__PROTECTION__MASTERS {USB1:NonSecure;0|USB0:NonSecure;1|S_AXI_LPD:NA;0|S_AXI_HPC1_FPD:NA;1|S_AXI_HPC0_FPD:NA;1|S_AXI_HP3_FPD:NA;0|S_AXI_HP2_FPD:NA;0|S_AXI_HP1_FPD:NA;0|S_AXI_HP0_FPD:NA;0|S_AXI_ACP:NA;0|S_AXI_ACE:NA;0|SD1:NonSecure;1|SD0:NonSecure;0|SATA1:NonSecure;1|SATA0:NonSecure;1|RPU1:Secure;1|RPU0:Secure;1|QSPI:NonSecure;1|PMU:NA;1|PCIe:NonSecure;0|NAND:NonSecure;0|LDMA:NonSecure;1|GPU:NonSecure;1|GEM3:NonSecure;1|GEM2:NonSecure;0|GEM1:NonSecure;0|GEM0:NonSecure;0|FDMA:NonSecure;1|DP:NonSecure;0|DAP:NA;1|Coresight:NA;1|CSU:NA;1|APU:NA;1}\
\
    CONFIG.PSU__PROTECTION__MASTERS_TZ {GEM0:NonSecure|SD1:NonSecure|GEM2:NonSecure|GEM1:NonSecure|GEM3:NonSecure|PCIe:NonSecure|DP:NonSecure|NAND:NonSecure|GPU:NonSecure|USB1:NonSecure|USB0:NonSecure|LDMA:NonSecure|FDMA:NonSecure|QSPI:NonSecure|SD0:NonSecure}\
\
    CONFIG.PSU__PROTECTION__OCM_SEGMENTS {NONE} \
    CONFIG.PSU__PROTECTION__PRESUBSYSTEMS {NONE} \
    CONFIG.PSU__PROTECTION__SLAVES {LPD;USB3_1_XHCI;FE300000;FE3FFFFF;0|LPD;USB3_1;FF9E0000;FF9EFFFF;0|LPD;USB3_0_XHCI;FE200000;FE2FFFFF;1|LPD;USB3_0;FF9D0000;FF9DFFFF;1|LPD;UART1;FF010000;FF01FFFF;0|LPD;UART0;FF000000;FF00FFFF;1|LPD;TTC3;FF140000;FF14FFFF;1|LPD;TTC2;FF130000;FF13FFFF;1|LPD;TTC1;FF120000;FF12FFFF;1|LPD;TTC0;FF110000;FF11FFFF;1|FPD;SWDT1;FD4D0000;FD4DFFFF;1|LPD;SWDT0;FF150000;FF15FFFF;1|LPD;SPI1;FF050000;FF05FFFF;0|LPD;SPI0;FF040000;FF04FFFF;0|FPD;SMMU_REG;FD5F0000;FD5FFFFF;1|FPD;SMMU;FD800000;FDFFFFFF;1|FPD;SIOU;FD3D0000;FD3DFFFF;1|FPD;SERDES;FD400000;FD47FFFF;1|LPD;SD1;FF170000;FF17FFFF;1|LPD;SD0;FF160000;FF16FFFF;0|FPD;SATA;FD0C0000;FD0CFFFF;1|LPD;RTC;FFA60000;FFA6FFFF;1|LPD;RSA_CORE;FFCE0000;FFCEFFFF;1|LPD;RPU;FF9A0000;FF9AFFFF;1|LPD;R5_TCM_RAM_GLOBAL;FFE00000;FFE3FFFF;1|LPD;R5_1_Instruction_Cache;FFEC0000;FFECFFFF;1|LPD;R5_1_Data_Cache;FFED0000;FFEDFFFF;1|LPD;R5_1_BTCM_GLOBAL;FFEB0000;FFEBFFFF;1|LPD;R5_1_ATCM_GLOBAL;FFE90000;FFE9FFFF;1|LPD;R5_0_Instruction_Cache;FFE40000;FFE4FFFF;1|LPD;R5_0_Data_Cache;FFE50000;FFE5FFFF;1|LPD;R5_0_BTCM_GLOBAL;FFE20000;FFE2FFFF;1|LPD;R5_0_ATCM_GLOBAL;FFE00000;FFE0FFFF;1|LPD;QSPI_Linear_Address;C0000000;DFFFFFFF;1|LPD;QSPI;FF0F0000;FF0FFFFF;1|LPD;PMU_RAM;FFDC0000;FFDDFFFF;1|LPD;PMU_GLOBAL;FFD80000;FFDBFFFF;1|FPD;PCIE_MAIN;FD0E0000;FD0EFFFF;0|FPD;PCIE_LOW;E0000000;EFFFFFFF;0|FPD;PCIE_HIGH2;8000000000;BFFFFFFFFF;0|FPD;PCIE_HIGH1;600000000;7FFFFFFFF;0|FPD;PCIE_DMA;FD0F0000;FD0FFFFF;0|FPD;PCIE_ATTRIB;FD480000;FD48FFFF;0|LPD;OCM_XMPU_CFG;FFA70000;FFA7FFFF;1|LPD;OCM_SLCR;FF960000;FF96FFFF;1|OCM;OCM;FFFC0000;FFFFFFFF;1|LPD;NAND;FF100000;FF10FFFF;0|LPD;MBISTJTAG;FFCF0000;FFCFFFFF;1|LPD;LPD_XPPU_SINK;FF9C0000;FF9CFFFF;1|LPD;LPD_XPPU;FF980000;FF98FFFF;1|LPD;LPD_SLCR_SECURE;FF4B0000;FF4DFFFF;1|LPD;LPD_SLCR;FF410000;FF4AFFFF;1|LPD;LPD_GPV;FE100000;FE1FFFFF;1|LPD;LPD_DMA_7;FFAF0000;FFAFFFFF;1|LPD;LPD_DMA_6;FFAE0000;FFAEFFFF;1|LPD;LPD_DMA_5;FFAD0000;FFADFFFF;1|LPD;LPD_DMA_4;FFAC0000;FFACFFFF;1|LPD;LPD_DMA_3;FFAB0000;FFABFFFF;1|LPD;LPD_DMA_2;FFAA0000;FFAAFFFF;1|LPD;LPD_DMA_1;FFA90000;FFA9FFFF;1|LPD;LPD_DMA_0;FFA80000;FFA8FFFF;1|LPD;IPI_CTRL;FF380000;FF3FFFFF;1|LPD;IOU_SLCR;FF180000;FF23FFFF;1|LPD;IOU_SECURE_SLCR;FF240000;FF24FFFF;1|LPD;IOU_SCNTRS;FF260000;FF26FFFF;1|LPD;IOU_SCNTR;FF250000;FF25FFFF;1|LPD;IOU_GPV;FE000000;FE0FFFFF;1|LPD;I2C1;FF030000;FF03FFFF;1|LPD;I2C0;FF020000;FF02FFFF;1|FPD;GPU;FD4B0000;FD4BFFFF;0|LPD;GPIO;FF0A0000;FF0AFFFF;1|LPD;GEM3;FF0E0000;FF0EFFFF;1|LPD;GEM2;FF0D0000;FF0DFFFF;0|LPD;GEM1;FF0C0000;FF0CFFFF;0|LPD;GEM0;FF0B0000;FF0BFFFF;0|FPD;FPD_XMPU_SINK;FD4F0000;FD4FFFFF;1|FPD;FPD_XMPU_CFG;FD5D0000;FD5DFFFF;1|FPD;FPD_SLCR_SECURE;FD690000;FD6CFFFF;1|FPD;FPD_SLCR;FD610000;FD68FFFF;1|FPD;FPD_DMA_CH7;FD570000;FD57FFFF;1|FPD;FPD_DMA_CH6;FD560000;FD56FFFF;1|FPD;FPD_DMA_CH5;FD550000;FD55FFFF;1|FPD;FPD_DMA_CH4;FD540000;FD54FFFF;1|FPD;FPD_DMA_CH3;FD530000;FD53FFFF;1|FPD;FPD_DMA_CH2;FD520000;FD52FFFF;1|FPD;FPD_DMA_CH1;FD510000;FD51FFFF;1|FPD;FPD_DMA_CH0;FD500000;FD50FFFF;1|LPD;EFUSE;FFCC0000;FFCCFFFF;1|FPD;Display\
Port;FD4A0000;FD4AFFFF;0|FPD;DPDMA;FD4C0000;FD4CFFFF;0|FPD;DDR_XMPU5_CFG;FD050000;FD05FFFF;1|FPD;DDR_XMPU4_CFG;FD040000;FD04FFFF;1|FPD;DDR_XMPU3_CFG;FD030000;FD03FFFF;1|FPD;DDR_XMPU2_CFG;FD020000;FD02FFFF;1|FPD;DDR_XMPU1_CFG;FD010000;FD01FFFF;1|FPD;DDR_XMPU0_CFG;FD000000;FD00FFFF;1|FPD;DDR_QOS_CTRL;FD090000;FD09FFFF;1|FPD;DDR_PHY;FD080000;FD08FFFF;1|DDR;DDR_LOW;0;7FFFFFFF;1|DDR;DDR_HIGH;800000000;87FFFFFFF;1|FPD;DDDR_CTRL;FD070000;FD070FFF;1|LPD;Coresight;FE800000;FEFFFFFF;1|LPD;CSU_DMA;FFC80000;FFC9FFFF;1|LPD;CSU;FFCA0000;FFCAFFFF;1|LPD;CRL_APB;FF5E0000;FF85FFFF;1|FPD;CRF_APB;FD1A0000;FD2DFFFF;1|FPD;CCI_REG;FD5E0000;FD5EFFFF;1|LPD;CAN1;FF070000;FF07FFFF;0|LPD;CAN0;FF060000;FF06FFFF;0|FPD;APU;FD5C0000;FD5CFFFF;1|LPD;APM_INTC_IOU;FFA20000;FFA2FFFF;1|LPD;APM_FPD_LPD;FFA30000;FFA3FFFF;1|FPD;APM_5;FD490000;FD49FFFF;1|FPD;APM_0;FD0B0000;FD0BFFFF;1|LPD;APM2;FFA10000;FFA1FFFF;1|LPD;APM1;FFA00000;FFA0FFFF;1|LPD;AMS;FFA50000;FFA5FFFF;1|FPD;AFI_5;FD3B0000;FD3BFFFF;1|FPD;AFI_4;FD3A0000;FD3AFFFF;1|FPD;AFI_3;FD390000;FD39FFFF;1|FPD;AFI_2;FD380000;FD38FFFF;1|FPD;AFI_1;FD370000;FD37FFFF;1|FPD;AFI_0;FD360000;FD36FFFF;1|LPD;AFIFM6;FF9B0000;FF9BFFFF;1|FPD;ACPU_GIC;F9010000;F907FFFF;1}\
\
    CONFIG.PSU__PROTECTION__SUBSYSTEMS {PMU Firmware:PMU|Secure Subsystem:} \
    CONFIG.PSU__PSS_ALT_REF_CLK__ENABLE {0} \
    CONFIG.PSU__PSS_ALT_REF_CLK__FREQMHZ {33.333} \
    CONFIG.PSU__PSS_REF_CLK__FREQMHZ {33.333} \
    CONFIG.PSU__QSPI_COHERENCY {0} \
    CONFIG.PSU__QSPI_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__QSPI__GRP_FBCLK__ENABLE {1} \
    CONFIG.PSU__QSPI__GRP_FBCLK__IO {MIO 6} \
    CONFIG.PSU__QSPI__PERIPHERAL__DATA_MODE {x4} \
    CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__QSPI__PERIPHERAL__IO {MIO 0 .. 12} \
    CONFIG.PSU__QSPI__PERIPHERAL__MODE {Dual Parallel} \
    CONFIG.PSU__REPORT__DBGLOG {0} \
    CONFIG.PSU__RPU_COHERENCY {0} \
    CONFIG.PSU__RPU__POWER__ON {1} \
    CONFIG.PSU__SATA__LANE0__ENABLE {0} \
    CONFIG.PSU__SATA__LANE1__IO {GT Lane3} \
    CONFIG.PSU__SATA__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SATA__REF_CLK_FREQ {125} \
    CONFIG.PSU__SATA__REF_CLK_SEL {Ref Clk3} \
    CONFIG.PSU__SAXIGP0__DATA_WIDTH {128} \
    CONFIG.PSU__SAXIGP1__DATA_WIDTH {128} \
    CONFIG.PSU__SD0__CLK_100_SDR_OTAP_DLY {0x3} \
    CONFIG.PSU__SD0__CLK_200_SDR_OTAP_DLY {0x3} \
    CONFIG.PSU__SD0__CLK_50_DDR_ITAP_DLY {0x3D} \
    CONFIG.PSU__SD0__CLK_50_DDR_OTAP_DLY {0x4} \
    CONFIG.PSU__SD0__CLK_50_SDR_ITAP_DLY {0x15} \
    CONFIG.PSU__SD0__CLK_50_SDR_OTAP_DLY {0x5} \
    CONFIG.PSU__SD0__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__SD0__RESET__ENABLE {0} \
    CONFIG.PSU__SD1_COHERENCY {0} \
    CONFIG.PSU__SD1_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__SD1__CLK_100_SDR_OTAP_DLY {0x3} \
    CONFIG.PSU__SD1__CLK_200_SDR_OTAP_DLY {0x3} \
    CONFIG.PSU__SD1__CLK_50_DDR_ITAP_DLY {0x3D} \
    CONFIG.PSU__SD1__CLK_50_DDR_OTAP_DLY {0x4} \
    CONFIG.PSU__SD1__CLK_50_SDR_ITAP_DLY {0x15} \
    CONFIG.PSU__SD1__CLK_50_SDR_OTAP_DLY {0x5} \
    CONFIG.PSU__SD1__DATA_TRANSFER_MODE {8Bit} \
    CONFIG.PSU__SD1__GRP_CD__ENABLE {1} \
    CONFIG.PSU__SD1__GRP_CD__IO {MIO 45} \
    CONFIG.PSU__SD1__GRP_POW__ENABLE {0} \
    CONFIG.PSU__SD1__GRP_WP__ENABLE {0} \
    CONFIG.PSU__SD1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SD1__PERIPHERAL__IO {MIO 39 .. 51} \
    CONFIG.PSU__SD1__SLOT_TYPE {SD 3.0} \
    CONFIG.PSU__SPI0_LOOP_SPI1__ENABLE {0} \
    CONFIG.PSU__SPI0__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__SPI1__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__SWDT0__CLOCK__ENABLE {0} \
    CONFIG.PSU__SWDT0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SWDT0__PERIPHERAL__IO {NA} \
    CONFIG.PSU__SWDT0__RESET__ENABLE {0} \
    CONFIG.PSU__SWDT1__CLOCK__ENABLE {0} \
    CONFIG.PSU__SWDT1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SWDT1__PERIPHERAL__IO {NA} \
    CONFIG.PSU__SWDT1__RESET__ENABLE {0} \
    CONFIG.PSU__TCM0A__POWER__ON {1} \
    CONFIG.PSU__TCM0B__POWER__ON {1} \
    CONFIG.PSU__TCM1A__POWER__ON {1} \
    CONFIG.PSU__TCM1B__POWER__ON {1} \
    CONFIG.PSU__TESTSCAN__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__TRACE__INTERNAL_WIDTH {32} \
    CONFIG.PSU__TRACE__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__TRISTATE__INVERTED {1} \
    CONFIG.PSU__TSU__BUFG_PORT_PAIR {0} \
    CONFIG.PSU__TTC0__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC0__PERIPHERAL__IO {NA} \
    CONFIG.PSU__TTC0__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC1__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC1__PERIPHERAL__IO {NA} \
    CONFIG.PSU__TTC1__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC2__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC2__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC2__PERIPHERAL__IO {NA} \
    CONFIG.PSU__TTC2__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC3__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC3__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC3__PERIPHERAL__IO {NA} \
    CONFIG.PSU__TTC3__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__UART0_LOOP_UART1__ENABLE {0} \
    CONFIG.PSU__UART0__BAUD_RATE {115200} \
    CONFIG.PSU__UART0__MODEM__ENABLE {0} \
    CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 18 .. 19} \
    CONFIG.PSU__UART1__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__USB0_COHERENCY {0} \
    CONFIG.PSU__USB0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__USB0__PERIPHERAL__IO {MIO 52 .. 63} \
    CONFIG.PSU__USB0__REF_CLK_FREQ {26} \
    CONFIG.PSU__USB0__REF_CLK_SEL {Ref Clk2} \
    CONFIG.PSU__USB1__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__USB2_0__EMIO__ENABLE {0} \
    CONFIG.PSU__USB3_0__EMIO__ENABLE {0} \
    CONFIG.PSU__USB3_0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__USB3_0__PERIPHERAL__IO {GT Lane2} \
    CONFIG.PSU__USB__RESET__MODE {Boot Pin} \
    CONFIG.PSU__USB__RESET__POLARITY {Active Low} \
    CONFIG.PSU__USE_DIFF_RW_CLK_GP0 {0} \
    CONFIG.PSU__USE_DIFF_RW_CLK_GP1 {0} \
    CONFIG.PSU__USE__ADMA {0} \
    CONFIG.PSU__USE__APU_LEGACY_INTERRUPT {0} \
    CONFIG.PSU__USE__AUDIO {0} \
    CONFIG.PSU__USE__CLK {0} \
    CONFIG.PSU__USE__CLK0 {0} \
    CONFIG.PSU__USE__CLK1 {0} \
    CONFIG.PSU__USE__CLK2 {0} \
    CONFIG.PSU__USE__CLK3 {0} \
    CONFIG.PSU__USE__CROSS_TRIGGER {0} \
    CONFIG.PSU__USE__DDR_INTF_REQUESTED {0} \
    CONFIG.PSU__USE__DEBUG__TEST {0} \
    CONFIG.PSU__USE__EVENT_RPU {0} \
    CONFIG.PSU__USE__FABRIC__RST {1} \
    CONFIG.PSU__USE__FTM {0} \
    CONFIG.PSU__USE__GDMA {0} \
    CONFIG.PSU__USE__IRQ {0} \
    CONFIG.PSU__USE__IRQ0 {1} \
    CONFIG.PSU__USE__IRQ1 {0} \
    CONFIG.PSU__USE__M_AXI_GP0 {1} \
    CONFIG.PSU__USE__M_AXI_GP1 {1} \
    CONFIG.PSU__USE__M_AXI_GP2 {0} \
    CONFIG.PSU__USE__PROC_EVENT_BUS {0} \
    CONFIG.PSU__USE__RPU_LEGACY_INTERRUPT {0} \
    CONFIG.PSU__USE__RST0 {0} \
    CONFIG.PSU__USE__RST1 {0} \
    CONFIG.PSU__USE__RST2 {0} \
    CONFIG.PSU__USE__RST3 {0} \
    CONFIG.PSU__USE__RTC {0} \
    CONFIG.PSU__USE__STM {0} \
    CONFIG.PSU__USE__S_AXI_ACE {0} \
    CONFIG.PSU__USE__S_AXI_ACP {0} \
    CONFIG.PSU__USE__S_AXI_GP0 {1} \
    CONFIG.PSU__USE__S_AXI_GP1 {1} \
    CONFIG.PSU__USE__S_AXI_GP2 {0} \
    CONFIG.PSU__USE__S_AXI_GP3 {0} \
    CONFIG.PSU__USE__S_AXI_GP4 {0} \
    CONFIG.PSU__USE__S_AXI_GP5 {0} \
    CONFIG.PSU__USE__S_AXI_GP6 {0} \
    CONFIG.PSU__USE__USB3_0_HUB {0} \
    CONFIG.PSU__USE__USB3_1_HUB {0} \
    CONFIG.PSU__USE__VIDEO {0} \
    CONFIG.PSU__VIDEO_REF_CLK__ENABLE {0} \
    CONFIG.PSU__VIDEO_REF_CLK__FREQMHZ {33.333} \
    CONFIG.QSPI_BOARD_INTERFACE {custom} \
    CONFIG.SATA_BOARD_INTERFACE {custom} \
    CONFIG.SD0_BOARD_INTERFACE {custom} \
    CONFIG.SD1_BOARD_INTERFACE {custom} \
    CONFIG.SPI0_BOARD_INTERFACE {custom} \
    CONFIG.SPI1_BOARD_INTERFACE {custom} \
    CONFIG.SUBPRESET1 {Custom} \
    CONFIG.SUBPRESET2 {Custom} \
    CONFIG.SWDT0_BOARD_INTERFACE {custom} \
    CONFIG.SWDT1_BOARD_INTERFACE {custom} \
    CONFIG.TRACE_BOARD_INTERFACE {custom} \
    CONFIG.TTC0_BOARD_INTERFACE {custom} \
    CONFIG.TTC1_BOARD_INTERFACE {custom} \
    CONFIG.TTC2_BOARD_INTERFACE {custom} \
    CONFIG.TTC3_BOARD_INTERFACE {custom} \
    CONFIG.UART0_BOARD_INTERFACE {custom} \
    CONFIG.UART1_BOARD_INTERFACE {custom} \
    CONFIG.USB0_BOARD_INTERFACE {custom} \
    CONFIG.USB1_BOARD_INTERFACE {custom} \
  ] $zynq_ultra_ps_e_0


  # Create instance: qick_processor_0, and set properties
  set qick_processor_0 [ create_bd_cell -type ip -vlnv Fermi:user:qick_processor:2.0 qick_processor_0 ]
  set_property -dict [list \
    CONFIG.GEN_SYNC {1} \
    CONFIG.IN_PORT_QTY {4} \
    CONFIG.OUT_DPORT_DW {5} \
    CONFIG.OUT_WPORT_QTY {16} \
    CONFIG.QCOM {1} \
  ] $qick_processor_0


  # Create instance: qick_vec2bit_0, and set properties
  set qick_vec2bit_0 [ create_bd_cell -type ip -vlnv FERMI:user:qick_vec2bit:1.0 qick_vec2bit_0 ]
  set_property -dict [list \
    CONFIG.IN_DW {5} \
    CONFIG.OUT_QTY {5} \
  ] $qick_vec2bit_0


  # Create instance: sg_translator_0, and set properties
  set sg_translator_0 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_0 ]
  set_property CONFIG.OUT_TYPE {1} $sg_translator_0


  # Create instance: sg_translator_1, and set properties
  set sg_translator_1 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_1 ]
  set_property CONFIG.OUT_TYPE {1} $sg_translator_1


  # Create instance: sg_translator_2, and set properties
  set sg_translator_2 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_2 ]
  set_property CONFIG.OUT_TYPE {1} $sg_translator_2


  # Create instance: sg_translator_3, and set properties
  set sg_translator_3 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_3 ]
  set_property CONFIG.OUT_TYPE {1} $sg_translator_3


  # Create instance: sg_translator_4, and set properties
  set sg_translator_4 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_4 ]
  set_property CONFIG.OUT_TYPE {1} $sg_translator_4


  # Create instance: sg_translator_5, and set properties
  set sg_translator_5 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_5 ]
  set_property CONFIG.OUT_TYPE {1} $sg_translator_5


  # Create instance: sg_translator_6, and set properties
  set sg_translator_6 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_6 ]
  set_property CONFIG.OUT_TYPE {1} $sg_translator_6


  # Create instance: sg_translator_7, and set properties
  set sg_translator_7 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_7 ]
  set_property CONFIG.OUT_TYPE {1} $sg_translator_7


  # Create instance: sg_translator_8, and set properties
  set sg_translator_8 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_8 ]
  set_property CONFIG.OUT_TYPE {1} $sg_translator_8


  # Create instance: sg_translator_9, and set properties
  set sg_translator_9 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_9 ]
  set_property CONFIG.OUT_TYPE {1} $sg_translator_9


  # Create instance: sg_translator_10, and set properties
  set sg_translator_10 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_10 ]
  set_property CONFIG.OUT_TYPE {1} $sg_translator_10


  # Create instance: sg_translator_11, and set properties
  set sg_translator_11 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_11 ]
  set_property CONFIG.OUT_TYPE {1} $sg_translator_11


  # Create instance: sg_translator_12, and set properties
  set sg_translator_12 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_12 ]
  set_property CONFIG.OUT_TYPE {0} $sg_translator_12


  # Create instance: sg_translator_13, and set properties
  set sg_translator_13 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_13 ]
  set_property CONFIG.OUT_TYPE {0} $sg_translator_13


  # Create instance: sg_translator_14, and set properties
  set sg_translator_14 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_14 ]
  set_property CONFIG.OUT_TYPE {0} $sg_translator_14


  # Create instance: sg_translator_15, and set properties
  set sg_translator_15 [ create_bd_cell -type ip -vlnv user.org:user:sg_translator:1.0 sg_translator_15 ]
  set_property CONFIG.OUT_TYPE {2} $sg_translator_15


  # Create instance: qick_com_0, and set properties
  set qick_com_0 [ create_bd_cell -type ip -vlnv Fermi:user:qick_com:1.0 qick_com_0 ]
  set_property CONFIG.SYNC {1} $qick_com_0


  # Create interface connections
  connect_bd_intf_net -intf_net adc2_clk_1 [get_bd_intf_ports adc2_clk] [get_bd_intf_pins usp_rf_data_converter_0/adc2_clk]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins axi_dma_gen/M_AXIS_MM2S] [get_bd_intf_pins axis_switch_gen/S00_AXIS]
  connect_bd_intf_net -intf_net axi_dma_avg_M_AXI_S2MM [get_bd_intf_pins axi_dma_avg/M_AXI_S2MM] [get_bd_intf_pins axi_smc_3/S00_AXI]
  connect_bd_intf_net -intf_net axi_dma_buf_M_AXI_S2MM [get_bd_intf_pins axi_dma_buf/M_AXI_S2MM] [get_bd_intf_pins axi_smc_3/S01_AXI]
  connect_bd_intf_net -intf_net axi_dma_gen_M_AXI_MM2S [get_bd_intf_pins axi_dma_gen/M_AXI_MM2S] [get_bd_intf_pins axi_smc_3/S02_AXI]
  connect_bd_intf_net -intf_net axi_dma_tproc_M_AXIS_MM2S [get_bd_intf_pins axi_dma_tproc/M_AXIS_MM2S] [get_bd_intf_pins qick_processor_0/s_dma_axis_i]
  connect_bd_intf_net -intf_net axi_dma_tproc_M_AXI_MM2S [get_bd_intf_pins axi_dma_tproc/M_AXI_MM2S] [get_bd_intf_pins axi_smc_4/S00_AXI]
  connect_bd_intf_net -intf_net axi_dma_tproc_M_AXI_S2MM [get_bd_intf_pins axi_dma_tproc/M_AXI_S2MM] [get_bd_intf_pins axi_smc_4/S01_AXI]
  connect_bd_intf_net -intf_net axi_smc_0_M00_AXI [get_bd_intf_pins axi_smc_0/M00_AXI] [get_bd_intf_pins qick_processor_0/s_axi]
  connect_bd_intf_net -intf_net axi_smc_0_M01_AXI [get_bd_intf_pins axi_dma_avg/S_AXI_LITE] [get_bd_intf_pins axi_smc_0/M01_AXI]
  connect_bd_intf_net -intf_net axi_smc_0_M02_AXI [get_bd_intf_pins axi_dma_buf/S_AXI_LITE] [get_bd_intf_pins axi_smc_0/M02_AXI]
  connect_bd_intf_net -intf_net axi_smc_0_M03_AXI [get_bd_intf_pins axi_dma_gen/S_AXI_LITE] [get_bd_intf_pins axi_smc_0/M03_AXI]
  connect_bd_intf_net -intf_net axi_smc_0_M04_AXI [get_bd_intf_pins axi_dma_tproc/S_AXI_LITE] [get_bd_intf_pins axi_smc_0/M04_AXI]
  connect_bd_intf_net -intf_net axi_smc_0_M05_AXI [get_bd_intf_pins axi_smc_0/M05_AXI] [get_bd_intf_pins qick_com_0/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M00_AXI [get_bd_intf_pins axi_smc_3/M00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HPC0_FPD]
  connect_bd_intf_net -intf_net axi_smc_1_M00_AXI1 [get_bd_intf_pins axi_smc_1/M00_AXI] [get_bd_intf_pins axi_smc_2/S00_AXI]
  connect_bd_intf_net -intf_net axi_smc_1_M01_AXI [get_bd_intf_pins axi_smc_1/M01_AXI] [get_bd_intf_pins axis_sg_mux8_v1_0/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M02_AXI [get_bd_intf_pins axi_smc_1/M02_AXI] [get_bd_intf_pins axis_sg_int4_v1_1/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M03_AXI [get_bd_intf_pins axi_smc_1/M03_AXI] [get_bd_intf_pins axis_sg_int4_v1_2/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M04_AXI [get_bd_intf_pins axi_smc_1/M04_AXI] [get_bd_intf_pins axis_sg_int4_v1_3/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M05_AXI [get_bd_intf_pins axi_smc_1/M05_AXI] [get_bd_intf_pins axis_sg_int4_v1_4/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M06_AXI [get_bd_intf_pins axi_smc_1/M06_AXI] [get_bd_intf_pins axis_sg_int4_v1_5/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M07_AXI [get_bd_intf_pins axi_smc_1/M07_AXI] [get_bd_intf_pins axis_sg_int4_v1_6/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M08_AXI [get_bd_intf_pins axi_smc_1/M08_AXI] [get_bd_intf_pins axis_sg_int4_v1_7/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M09_AXI [get_bd_intf_pins axi_smc_1/M09_AXI] [get_bd_intf_pins axis_sg_int4_v1_9/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M10_AXI [get_bd_intf_pins axi_smc_1/M10_AXI] [get_bd_intf_pins axis_sg_int4_v1_0/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M11_AXI [get_bd_intf_pins axi_smc_1/M11_AXI] [get_bd_intf_pins axis_signal_gen_v6_8/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M12_AXI [get_bd_intf_pins axi_smc_1/M12_AXI] [get_bd_intf_pins axis_signal_gen_v6_9/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M13_AXI [get_bd_intf_pins axi_smc_1/M13_AXI] [get_bd_intf_pins axis_signal_gen_v6_10/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M14_AXI [get_bd_intf_pins axi_smc_1/M14_AXI] [get_bd_intf_pins axis_sg_int4_v1_11/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M15_AXI [get_bd_intf_pins axi_smc_1/M15_AXI] [get_bd_intf_pins axis_sg_int4_v1_10/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M16_AXI [get_bd_intf_pins axi_smc_1/M16_AXI] [get_bd_intf_pins axis_avg_buffer_0/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M17_AXI [get_bd_intf_pins axi_smc_1/M17_AXI] [get_bd_intf_pins axis_avg_buffer_1/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M18_AXI [get_bd_intf_pins axi_smc_1/M18_AXI] [get_bd_intf_pins axis_avg_buffer_2/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M19_AXI [get_bd_intf_pins axi_smc_1/M19_AXI] [get_bd_intf_pins axis_avg_buffer_3/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M20_AXI [get_bd_intf_pins axi_smc_1/M20_AXI] [get_bd_intf_pins axis_avg_buffer_4/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M21_AXI [get_bd_intf_pins axi_smc_1/M21_AXI] [get_bd_intf_pins axis_pfb_readout_v3_0/s_axi]
  connect_bd_intf_net -intf_net axi_smc_1_M22_AXI [get_bd_intf_pins axi_smc_1/M22_AXI] [get_bd_intf_pins axis_readout_v2_0/s_axi]
  connect_bd_intf_net -intf_net axi_smc_2_M00_AXI [get_bd_intf_pins axi_smc_4/M00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HPC1_FPD]
  connect_bd_intf_net -intf_net axi_smc_2_M00_AXI1 [get_bd_intf_pins axi_smc_2/M00_AXI] [get_bd_intf_pins axis_sg_int4_v1_8/s_axi]
  connect_bd_intf_net -intf_net axi_smc_2_M03_AXI [get_bd_intf_pins axi_smc_2/M03_AXI] [get_bd_intf_pins axis_switch_avg/S_AXI_CTRL]
  connect_bd_intf_net -intf_net axi_smc_2_M04_AXI [get_bd_intf_pins axi_smc_2/M04_AXI] [get_bd_intf_pins axis_switch_buf/S_AXI_CTRL]
  connect_bd_intf_net -intf_net axi_smc_2_M05_AXI [get_bd_intf_pins axi_smc_2/M05_AXI] [get_bd_intf_pins axis_switch_gen/S_AXI_CTRL]
  connect_bd_intf_net -intf_net axi_smc_2_M06_AXI [get_bd_intf_pins axi_smc_2/M06_AXI] [get_bd_intf_pins usp_rf_data_converter_0/s_axi]
  connect_bd_intf_net -intf_net axis_avg_buffer_0_m0_axis [get_bd_intf_pins axis_avg_buffer_0/m0_axis] [get_bd_intf_pins axis_switch_avg/S00_AXIS]
  connect_bd_intf_net -intf_net axis_avg_buffer_0_m1_axis [get_bd_intf_pins axis_avg_buffer_0/m1_axis] [get_bd_intf_pins axis_switch_buf/S00_AXIS]
  connect_bd_intf_net -intf_net axis_avg_buffer_0_m2_axis [get_bd_intf_pins axis_avg_buffer_1/m2_axis] [get_bd_intf_pins axis_cc_avg_0/S_AXIS]
  connect_bd_intf_net -intf_net axis_avg_buffer_1_m0_axis [get_bd_intf_pins axis_avg_buffer_1/m0_axis] [get_bd_intf_pins axis_switch_avg/S01_AXIS]
  connect_bd_intf_net -intf_net axis_avg_buffer_1_m1_axis [get_bd_intf_pins axis_avg_buffer_1/m1_axis] [get_bd_intf_pins axis_switch_buf/S01_AXIS]
  connect_bd_intf_net -intf_net axis_avg_buffer_1_m2_axis [get_bd_intf_pins axis_avg_buffer_2/m2_axis] [get_bd_intf_pins axis_cc_avg_1/S_AXIS]
  connect_bd_intf_net -intf_net axis_avg_buffer_2_m0_axis [get_bd_intf_pins axis_avg_buffer_2/m0_axis] [get_bd_intf_pins axis_switch_avg/S02_AXIS]
  connect_bd_intf_net -intf_net axis_avg_buffer_2_m1_axis [get_bd_intf_pins axis_avg_buffer_2/m1_axis] [get_bd_intf_pins axis_switch_buf/S02_AXIS]
  connect_bd_intf_net -intf_net axis_avg_buffer_2_m2_axis [get_bd_intf_pins axis_avg_buffer_3/m2_axis] [get_bd_intf_pins axis_cc_avg_2/S_AXIS]
  connect_bd_intf_net -intf_net axis_avg_buffer_3_m0_axis [get_bd_intf_pins axis_avg_buffer_3/m0_axis] [get_bd_intf_pins axis_switch_avg/S03_AXIS]
  connect_bd_intf_net -intf_net axis_avg_buffer_3_m1_axis [get_bd_intf_pins axis_avg_buffer_3/m1_axis] [get_bd_intf_pins axis_switch_buf/S03_AXIS]
  connect_bd_intf_net -intf_net axis_avg_buffer_3_m2_axis [get_bd_intf_pins axis_avg_buffer_4/m2_axis] [get_bd_intf_pins axis_cc_avg_3/S_AXIS]
  connect_bd_intf_net -intf_net axis_avg_buffer_4_m0_axis [get_bd_intf_pins axis_avg_buffer_4/m0_axis] [get_bd_intf_pins axis_switch_avg/S04_AXIS]
  connect_bd_intf_net -intf_net axis_avg_buffer_4_m1_axis [get_bd_intf_pins axis_avg_buffer_4/m1_axis] [get_bd_intf_pins axis_switch_buf/S04_AXIS]
  connect_bd_intf_net -intf_net axis_avg_buffer_4_m2_axis [get_bd_intf_pins axis_avg_buffer_0/m2_axis] [get_bd_intf_pins axis_terminator_4/s_axis]
  connect_bd_intf_net -intf_net axis_cc_avg_0_M_AXIS [get_bd_intf_pins axis_cc_avg_0/M_AXIS] [get_bd_intf_pins qick_processor_0/s0_axis]
  connect_bd_intf_net -intf_net axis_cc_avg_1_M_AXIS [get_bd_intf_pins axis_cc_avg_1/M_AXIS] [get_bd_intf_pins qick_processor_0/s1_axis]
  connect_bd_intf_net -intf_net axis_cc_avg_2_M_AXIS [get_bd_intf_pins axis_cc_avg_2/M_AXIS] [get_bd_intf_pins qick_processor_0/s2_axis]
  connect_bd_intf_net -intf_net axis_cc_avg_3_M_AXIS [get_bd_intf_pins axis_cc_avg_3/M_AXIS] [get_bd_intf_pins qick_processor_0/s3_axis]
  connect_bd_intf_net -intf_net axis_clock_converter_0_M_AXIS [get_bd_intf_pins axis_clock_converter_0/M_AXIS] [get_bd_intf_pins axis_sg_int4_v1_0/s1_axis]
  connect_bd_intf_net -intf_net axis_clock_converter_10_M_AXIS [get_bd_intf_pins axis_clock_converter_10/M_AXIS] [get_bd_intf_pins axis_register_slice_13/S_AXIS]
  connect_bd_intf_net -intf_net axis_clock_converter_11_M_AXIS [get_bd_intf_pins axis_clock_converter_11/M_AXIS] [get_bd_intf_pins axis_register_slice_12/S_AXIS]
  connect_bd_intf_net -intf_net axis_clock_converter_12_M_AXIS [get_bd_intf_pins axis_clock_converter_12/M_AXIS] [get_bd_intf_pins axis_sg_int4_v1_8/s1_axis]
  connect_bd_intf_net -intf_net axis_clock_converter_13_M_AXIS [get_bd_intf_pins axis_clock_converter_13/M_AXIS] [get_bd_intf_pins axis_sg_int4_v1_10/s1_axis]
  connect_bd_intf_net -intf_net axis_clock_converter_14_M_AXIS [get_bd_intf_pins axis_clock_converter_14/M_AXIS] [get_bd_intf_pins axis_sg_int4_v1_11/s1_axis]
  connect_bd_intf_net -intf_net axis_clock_converter_15_M_AXIS [get_bd_intf_pins axis_clock_converter_15/M_AXIS] [get_bd_intf_pins axis_sg_int4_v1_9/s1_axis]
  connect_bd_intf_net -intf_net axis_clock_converter_1_M_AXIS [get_bd_intf_pins axis_clock_converter_1/M_AXIS] [get_bd_intf_pins axis_sg_int4_v1_1/s1_axis]
  connect_bd_intf_net -intf_net axis_clock_converter_2_M_AXIS [get_bd_intf_pins axis_clock_converter_2/M_AXIS] [get_bd_intf_pins axis_sg_int4_v1_2/s1_axis]
  connect_bd_intf_net -intf_net axis_clock_converter_3_M_AXIS [get_bd_intf_pins axis_clock_converter_3/M_AXIS] [get_bd_intf_pins axis_sg_int4_v1_3/s1_axis]
  connect_bd_intf_net -intf_net axis_clock_converter_4_M_AXIS [get_bd_intf_pins axis_clock_converter_4/M_AXIS] [get_bd_intf_pins axis_sg_int4_v1_4/s1_axis]
  connect_bd_intf_net -intf_net axis_clock_converter_5_M_AXIS [get_bd_intf_pins axis_clock_converter_5/M_AXIS] [get_bd_intf_pins axis_sg_int4_v1_5/s1_axis]
  connect_bd_intf_net -intf_net axis_clock_converter_6_M_AXIS [get_bd_intf_pins axis_clock_converter_6/M_AXIS] [get_bd_intf_pins axis_sg_int4_v1_6/s1_axis]
  connect_bd_intf_net -intf_net axis_clock_converter_7_M_AXIS [get_bd_intf_pins axis_clock_converter_7/M_AXIS] [get_bd_intf_pins axis_sg_int4_v1_7/s1_axis]
  connect_bd_intf_net -intf_net axis_clock_converter_8_M_AXIS [get_bd_intf_pins axis_clock_converter_8/M_AXIS] [get_bd_intf_pins axis_register_slice_15/S_AXIS]
  connect_bd_intf_net -intf_net axis_clock_converter_9_M_AXIS [get_bd_intf_pins axis_clock_converter_9/M_AXIS] [get_bd_intf_pins axis_register_slice_14/S_AXIS]
  connect_bd_intf_net -intf_net axis_pfb_readout_v3_0_m0_axis [get_bd_intf_pins axis_avg_buffer_1/s_axis] [get_bd_intf_pins axis_pfb_readout_v3_0/m0_axis]
  connect_bd_intf_net -intf_net axis_pfb_readout_v3_0_m1_axis [get_bd_intf_pins axis_avg_buffer_2/s_axis] [get_bd_intf_pins axis_pfb_readout_v3_0/m1_axis]
  connect_bd_intf_net -intf_net axis_pfb_readout_v3_0_m2_axis [get_bd_intf_pins axis_avg_buffer_3/s_axis] [get_bd_intf_pins axis_pfb_readout_v3_0/m2_axis]
  connect_bd_intf_net -intf_net axis_pfb_readout_v3_0_m3_axis [get_bd_intf_pins axis_avg_buffer_4/s_axis] [get_bd_intf_pins axis_pfb_readout_v3_0/m3_axis]
  connect_bd_intf_net -intf_net axis_readout_v2_1_m1_axis [get_bd_intf_pins axis_avg_buffer_0/s_axis] [get_bd_intf_pins axis_readout_v2_0/m1_axis]
  connect_bd_intf_net -intf_net axis_register_slice_0_m_axis [get_bd_intf_pins axis_register_slice_0/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s00_axis]
  connect_bd_intf_net -intf_net axis_register_slice_12_M_AXIS [get_bd_intf_pins axis_register_slice_12/M_AXIS] [get_bd_intf_pins axis_register_slice_19/S_AXIS]
  connect_bd_intf_net -intf_net axis_register_slice_13_M_AXIS [get_bd_intf_pins axis_register_slice_13/M_AXIS] [get_bd_intf_pins axis_register_slice_18/S_AXIS]
  connect_bd_intf_net -intf_net axis_register_slice_14_M_AXIS [get_bd_intf_pins axis_register_slice_14/M_AXIS] [get_bd_intf_pins axis_register_slice_17/S_AXIS]
  connect_bd_intf_net -intf_net axis_register_slice_15_M_AXIS [get_bd_intf_pins axis_register_slice_15/M_AXIS] [get_bd_intf_pins axis_register_slice_16/S_AXIS]
  connect_bd_intf_net -intf_net axis_register_slice_16_M_AXIS [get_bd_intf_pins axis_register_slice_16/M_AXIS] [get_bd_intf_pins axis_signal_gen_v6_8/s1_axis]
  connect_bd_intf_net -intf_net axis_register_slice_17_M_AXIS [get_bd_intf_pins axis_register_slice_17/M_AXIS] [get_bd_intf_pins axis_signal_gen_v6_9/s1_axis]
  connect_bd_intf_net -intf_net axis_register_slice_18_M_AXIS [get_bd_intf_pins axis_register_slice_18/M_AXIS] [get_bd_intf_pins axis_signal_gen_v6_10/s1_axis]
  connect_bd_intf_net -intf_net axis_register_slice_19_M_AXIS [get_bd_intf_pins axis_register_slice_19/M_AXIS] [get_bd_intf_pins axis_sg_mux8_v1_0/s_axis]
  connect_bd_intf_net -intf_net axis_register_slice_1_m_axis [get_bd_intf_pins axis_register_slice_1/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s01_axis]
  connect_bd_intf_net -intf_net axis_register_slice_2_m_axis [get_bd_intf_pins axis_register_slice_2/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s02_axis]
  connect_bd_intf_net -intf_net axis_register_slice_3_m_axis [get_bd_intf_pins axis_register_slice_3/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s03_axis]
  connect_bd_intf_net -intf_net axis_sg_int4_v1_0_m_axis [get_bd_intf_pins axis_sg_int4_v1_0/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s10_axis]
  connect_bd_intf_net -intf_net axis_sg_int4_v1_10_m_axis [get_bd_intf_pins axis_sg_int4_v1_10/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s32_axis]
  connect_bd_intf_net -intf_net axis_sg_int4_v1_11_m_axis [get_bd_intf_pins axis_sg_int4_v1_11/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s31_axis]
  connect_bd_intf_net -intf_net axis_sg_int4_v1_1_m_axis [get_bd_intf_pins axis_sg_int4_v1_1/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s11_axis]
  connect_bd_intf_net -intf_net axis_sg_int4_v1_2_m_axis [get_bd_intf_pins axis_sg_int4_v1_2/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s12_axis]
  connect_bd_intf_net -intf_net axis_sg_int4_v1_3_m_axis [get_bd_intf_pins axis_sg_int4_v1_3/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s13_axis]
  connect_bd_intf_net -intf_net axis_sg_int4_v1_4_m_axis [get_bd_intf_pins axis_sg_int4_v1_4/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s20_axis]
  connect_bd_intf_net -intf_net axis_sg_int4_v1_5_m_axis [get_bd_intf_pins axis_sg_int4_v1_5/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s21_axis]
  connect_bd_intf_net -intf_net axis_sg_int4_v1_6_m_axis [get_bd_intf_pins axis_sg_int4_v1_6/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s22_axis]
  connect_bd_intf_net -intf_net axis_sg_int4_v1_7_m_axis [get_bd_intf_pins axis_sg_int4_v1_7/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s23_axis]
  connect_bd_intf_net -intf_net axis_sg_int4_v1_8_m_axis [get_bd_intf_pins axis_sg_int4_v1_8/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s33_axis]
  connect_bd_intf_net -intf_net axis_sg_int4_v1_9_m_axis [get_bd_intf_pins axis_sg_int4_v1_9/m_axis] [get_bd_intf_pins usp_rf_data_converter_0/s30_axis]
  connect_bd_intf_net -intf_net axis_sg_mux8_v1_0_m_axis [get_bd_intf_pins axis_register_slice_3/s_axis] [get_bd_intf_pins axis_sg_mux8_v1_0/m_axis]
  connect_bd_intf_net -intf_net axis_signal_gen_v6_10_m_axis [get_bd_intf_pins axis_register_slice_2/s_axis] [get_bd_intf_pins axis_signal_gen_v6_10/m_axis]
  connect_bd_intf_net -intf_net axis_signal_gen_v6_8_m_axis [get_bd_intf_pins axis_register_slice_0/s_axis] [get_bd_intf_pins axis_signal_gen_v6_8/m_axis]
  connect_bd_intf_net -intf_net axis_signal_gen_v6_9_m_axis [get_bd_intf_pins axis_register_slice_1/s_axis] [get_bd_intf_pins axis_signal_gen_v6_9/m_axis]
  connect_bd_intf_net -intf_net axis_switch_avg_M00_AXIS [get_bd_intf_pins axi_dma_avg/S_AXIS_S2MM] [get_bd_intf_pins axis_switch_avg/M00_AXIS]
  connect_bd_intf_net -intf_net axis_switch_buf_M00_AXIS [get_bd_intf_pins axi_dma_buf/S_AXIS_S2MM] [get_bd_intf_pins axis_switch_buf/M00_AXIS]
  connect_bd_intf_net -intf_net axis_switch_gen_M00_AXIS [get_bd_intf_pins axis_sg_int4_v1_0/s0_axis] [get_bd_intf_pins axis_switch_gen/M00_AXIS]
  connect_bd_intf_net -intf_net axis_switch_gen_M01_AXIS [get_bd_intf_pins axis_sg_int4_v1_1/s0_axis] [get_bd_intf_pins axis_switch_gen/M01_AXIS]
  connect_bd_intf_net -intf_net axis_switch_gen_M02_AXIS [get_bd_intf_pins axis_sg_int4_v1_2/s0_axis] [get_bd_intf_pins axis_switch_gen/M02_AXIS]
  connect_bd_intf_net -intf_net axis_switch_gen_M03_AXIS [get_bd_intf_pins axis_sg_int4_v1_3/s0_axis] [get_bd_intf_pins axis_switch_gen/M03_AXIS]
  connect_bd_intf_net -intf_net axis_switch_gen_M04_AXIS [get_bd_intf_pins axis_sg_int4_v1_4/s0_axis] [get_bd_intf_pins axis_switch_gen/M04_AXIS]
  connect_bd_intf_net -intf_net axis_switch_gen_M05_AXIS [get_bd_intf_pins axis_sg_int4_v1_5/s0_axis] [get_bd_intf_pins axis_switch_gen/M05_AXIS]
  connect_bd_intf_net -intf_net axis_switch_gen_M06_AXIS [get_bd_intf_pins axis_sg_int4_v1_6/s0_axis] [get_bd_intf_pins axis_switch_gen/M06_AXIS]
  connect_bd_intf_net -intf_net axis_switch_gen_M07_AXIS [get_bd_intf_pins axis_sg_int4_v1_7/s0_axis] [get_bd_intf_pins axis_switch_gen/M07_AXIS]
  connect_bd_intf_net -intf_net axis_switch_gen_M08_AXIS [get_bd_intf_pins axis_signal_gen_v6_8/s0_axis] [get_bd_intf_pins axis_switch_gen/M08_AXIS]
  connect_bd_intf_net -intf_net axis_switch_gen_M09_AXIS [get_bd_intf_pins axis_signal_gen_v6_9/s0_axis] [get_bd_intf_pins axis_switch_gen/M09_AXIS]
  connect_bd_intf_net -intf_net axis_switch_gen_M10_AXIS [get_bd_intf_pins axis_signal_gen_v6_10/s0_axis] [get_bd_intf_pins axis_switch_gen/M10_AXIS]
  connect_bd_intf_net -intf_net axis_switch_gen_M11_AXIS [get_bd_intf_pins axis_sg_int4_v1_9/s0_axis] [get_bd_intf_pins axis_switch_gen/M11_AXIS]
  connect_bd_intf_net -intf_net axis_switch_gen_M12_AXIS [get_bd_intf_pins axis_sg_int4_v1_11/s0_axis] [get_bd_intf_pins axis_switch_gen/M12_AXIS]
  connect_bd_intf_net -intf_net axis_switch_gen_M13_AXIS [get_bd_intf_pins axis_sg_int4_v1_10/s0_axis] [get_bd_intf_pins axis_switch_gen/M13_AXIS]
  connect_bd_intf_net -intf_net axis_switch_gen_M14_AXIS [get_bd_intf_pins axis_sg_int4_v1_8/s0_axis] [get_bd_intf_pins axis_switch_gen/M14_AXIS]
  connect_bd_intf_net -intf_net dac2_clk_1 [get_bd_intf_ports dac2_clk] [get_bd_intf_pins usp_rf_data_converter_0/dac2_clk]
  connect_bd_intf_net -intf_net qick_processor_0_QCOM [get_bd_intf_pins qick_com_0/QCOM] [get_bd_intf_pins qick_processor_0/QCOM]
  connect_bd_intf_net -intf_net qick_processor_0_m0_axis [get_bd_intf_pins qick_processor_0/m0_axis] [get_bd_intf_pins sg_translator_0/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m10_axis [get_bd_intf_pins qick_processor_0/m10_axis] [get_bd_intf_pins sg_translator_10/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m11_axis [get_bd_intf_pins qick_processor_0/m11_axis] [get_bd_intf_pins sg_translator_11/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m12_axis [get_bd_intf_pins qick_processor_0/m12_axis] [get_bd_intf_pins sg_translator_12/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m13_axis [get_bd_intf_pins qick_processor_0/m13_axis] [get_bd_intf_pins sg_translator_13/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m14_axis [get_bd_intf_pins qick_processor_0/m14_axis] [get_bd_intf_pins sg_translator_14/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m15_axis [get_bd_intf_pins qick_processor_0/m15_axis] [get_bd_intf_pins sg_translator_15/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m1_axis [get_bd_intf_pins qick_processor_0/m1_axis] [get_bd_intf_pins sg_translator_1/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m2_axis [get_bd_intf_pins qick_processor_0/m2_axis] [get_bd_intf_pins sg_translator_2/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m3_axis [get_bd_intf_pins qick_processor_0/m3_axis] [get_bd_intf_pins sg_translator_3/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m4_axis [get_bd_intf_pins qick_processor_0/m4_axis] [get_bd_intf_pins sg_translator_4/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m5_axis [get_bd_intf_pins qick_processor_0/m5_axis] [get_bd_intf_pins sg_translator_5/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m6_axis [get_bd_intf_pins qick_processor_0/m6_axis] [get_bd_intf_pins sg_translator_6/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m7_axis [get_bd_intf_pins qick_processor_0/m7_axis] [get_bd_intf_pins sg_translator_7/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m8_axis [get_bd_intf_pins qick_processor_0/m8_axis] [get_bd_intf_pins sg_translator_8/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m9_axis [get_bd_intf_pins qick_processor_0/m9_axis] [get_bd_intf_pins sg_translator_9/s_tproc_axis]
  connect_bd_intf_net -intf_net qick_processor_0_m_dma_axis_o [get_bd_intf_pins qick_processor_0/m_dma_axis_o] [get_bd_intf_pins axi_dma_tproc/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net sg_translator_0_m_int4_axis [get_bd_intf_pins sg_translator_0/m_int4_axis] [get_bd_intf_pins axis_clock_converter_0/S_AXIS]
  connect_bd_intf_net -intf_net sg_translator_10_m_int4_axis [get_bd_intf_pins sg_translator_10/m_int4_axis] [get_bd_intf_pins axis_clock_converter_13/S_AXIS]
  connect_bd_intf_net -intf_net sg_translator_11_m_int4_axis [get_bd_intf_pins sg_translator_11/m_int4_axis] [get_bd_intf_pins axis_clock_converter_14/S_AXIS]
  connect_bd_intf_net -intf_net sg_translator_12_m_gen_v6_axis [get_bd_intf_pins sg_translator_12/m_gen_v6_axis] [get_bd_intf_pins axis_clock_converter_8/S_AXIS]
  connect_bd_intf_net -intf_net sg_translator_13_m_gen_v6_axis [get_bd_intf_pins sg_translator_13/m_gen_v6_axis] [get_bd_intf_pins axis_clock_converter_9/S_AXIS]
  connect_bd_intf_net -intf_net sg_translator_14_m_gen_v6_axis [get_bd_intf_pins sg_translator_14/m_gen_v6_axis] [get_bd_intf_pins axis_clock_converter_10/S_AXIS]
  connect_bd_intf_net -intf_net sg_translator_15_m_mux4_axis [get_bd_intf_pins sg_translator_15/m_mux4_axis] [get_bd_intf_pins axis_clock_converter_11/S_AXIS]
  connect_bd_intf_net -intf_net sg_translator_1_m_int4_axis [get_bd_intf_pins sg_translator_1/m_int4_axis] [get_bd_intf_pins axis_clock_converter_1/S_AXIS]
  connect_bd_intf_net -intf_net sg_translator_2_m_int4_axis [get_bd_intf_pins sg_translator_2/m_int4_axis] [get_bd_intf_pins axis_clock_converter_2/S_AXIS]
  connect_bd_intf_net -intf_net sg_translator_3_m_int4_axis [get_bd_intf_pins sg_translator_3/m_int4_axis] [get_bd_intf_pins axis_clock_converter_3/S_AXIS]
  connect_bd_intf_net -intf_net sg_translator_4_m_int4_axis [get_bd_intf_pins sg_translator_4/m_int4_axis] [get_bd_intf_pins axis_clock_converter_4/S_AXIS]
  connect_bd_intf_net -intf_net sg_translator_5_m_int4_axis [get_bd_intf_pins sg_translator_5/m_int4_axis] [get_bd_intf_pins axis_clock_converter_5/S_AXIS]
  connect_bd_intf_net -intf_net sg_translator_6_m_int4_axis [get_bd_intf_pins sg_translator_6/m_int4_axis] [get_bd_intf_pins axis_clock_converter_6/S_AXIS]
  connect_bd_intf_net -intf_net sg_translator_7_m_int4_axis [get_bd_intf_pins sg_translator_7/m_int4_axis] [get_bd_intf_pins axis_clock_converter_7/S_AXIS]
  connect_bd_intf_net -intf_net sg_translator_8_m_int4_axis [get_bd_intf_pins sg_translator_8/m_int4_axis] [get_bd_intf_pins axis_clock_converter_12/S_AXIS]
  connect_bd_intf_net -intf_net sg_translator_9_m_int4_axis [get_bd_intf_pins sg_translator_9/m_int4_axis] [get_bd_intf_pins axis_clock_converter_15/S_AXIS]
  connect_bd_intf_net -intf_net sysref_in_1 [get_bd_intf_ports sysref_in] [get_bd_intf_pins usp_rf_data_converter_0/sysref_in]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_m20_axis [get_bd_intf_pins axis_readout_v2_0/s_axis] [get_bd_intf_pins usp_rf_data_converter_0/m20_axis]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_m22_axis [get_bd_intf_pins axis_pfb_readout_v3_0/s_axis] [get_bd_intf_pins usp_rf_data_converter_0/m22_axis]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout00 [get_bd_intf_ports vout00] [get_bd_intf_pins usp_rf_data_converter_0/vout00]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout01 [get_bd_intf_ports vout01] [get_bd_intf_pins usp_rf_data_converter_0/vout01]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout02 [get_bd_intf_ports vout02] [get_bd_intf_pins usp_rf_data_converter_0/vout02]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout03 [get_bd_intf_ports vout03] [get_bd_intf_pins usp_rf_data_converter_0/vout03]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout10 [get_bd_intf_ports vout10] [get_bd_intf_pins usp_rf_data_converter_0/vout10]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout11 [get_bd_intf_ports vout11] [get_bd_intf_pins usp_rf_data_converter_0/vout11]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout12 [get_bd_intf_ports vout12] [get_bd_intf_pins usp_rf_data_converter_0/vout12]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout13 [get_bd_intf_ports vout13] [get_bd_intf_pins usp_rf_data_converter_0/vout13]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout20 [get_bd_intf_ports vout20] [get_bd_intf_pins usp_rf_data_converter_0/vout20]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout21 [get_bd_intf_ports vout21] [get_bd_intf_pins usp_rf_data_converter_0/vout21]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout22 [get_bd_intf_ports vout22] [get_bd_intf_pins usp_rf_data_converter_0/vout22]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout23 [get_bd_intf_ports vout23] [get_bd_intf_pins usp_rf_data_converter_0/vout23]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout30 [get_bd_intf_ports vout30] [get_bd_intf_pins usp_rf_data_converter_0/vout30]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout31 [get_bd_intf_ports vout31] [get_bd_intf_pins usp_rf_data_converter_0/vout31]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout32 [get_bd_intf_ports vout32] [get_bd_intf_pins usp_rf_data_converter_0/vout32]
  connect_bd_intf_net -intf_net usp_rf_data_converter_0_vout33 [get_bd_intf_ports vout33] [get_bd_intf_pins usp_rf_data_converter_0/vout33]
  connect_bd_intf_net -intf_net vin20_1 [get_bd_intf_ports vin20] [get_bd_intf_pins usp_rf_data_converter_0/vin20]
  connect_bd_intf_net -intf_net vin22_1 [get_bd_intf_ports vin22] [get_bd_intf_pins usp_rf_data_converter_0/vin22]
  connect_bd_intf_net -intf_net zynq_ultra_ps_e_0_M_AXI_HPM0_FPD [get_bd_intf_pins axi_smc_0/S00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD]
  connect_bd_intf_net -intf_net zynq_ultra_ps_e_0_M_AXI_HPM1_FPD [get_bd_intf_pins axi_smc_1/S00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM1_FPD]

  # Create port connections
  connect_bd_net -net Net [get_bd_pins usp_rf_data_converter_0/clk_dac0] [get_bd_pins axis_register_slice_0/aclk] [get_bd_pins axis_register_slice_1/aclk] [get_bd_pins axis_register_slice_2/aclk] [get_bd_pins axis_register_slice_3/aclk] [get_bd_pins axis_sg_mux8_v1_0/aclk] [get_bd_pins axis_signal_gen_v6_10/aclk] [get_bd_pins axis_signal_gen_v6_8/aclk] [get_bd_pins axis_signal_gen_v6_9/aclk] [get_bd_pins rst_dac0/slowest_sync_clk] [get_bd_pins axis_clock_converter_10/m_axis_aclk] [get_bd_pins axis_clock_converter_11/m_axis_aclk] [get_bd_pins axis_clock_converter_8/m_axis_aclk] [get_bd_pins axis_clock_converter_9/m_axis_aclk] [get_bd_pins axis_register_slice_12/aclk] [get_bd_pins axis_register_slice_13/aclk] [get_bd_pins axis_register_slice_14/aclk] [get_bd_pins axis_register_slice_15/aclk] [get_bd_pins axis_register_slice_16/aclk] [get_bd_pins axis_register_slice_17/aclk] [get_bd_pins axis_register_slice_18/aclk] [get_bd_pins axis_register_slice_19/aclk] [get_bd_pins usp_rf_data_converter_0/s0_axis_aclk]
  connect_bd_net -net Net1 [get_bd_pins rst_dac0/peripheral_aresetn] [get_bd_pins axis_register_slice_0/aresetn] [get_bd_pins axis_register_slice_1/aresetn] [get_bd_pins axis_register_slice_2/aresetn] [get_bd_pins axis_register_slice_3/aresetn] [get_bd_pins axis_sg_mux8_v1_0/aresetn] [get_bd_pins axis_signal_gen_v6_10/aresetn] [get_bd_pins axis_signal_gen_v6_8/aresetn] [get_bd_pins axis_signal_gen_v6_9/aresetn] [get_bd_pins axis_clock_converter_10/m_axis_aresetn] [get_bd_pins axis_clock_converter_11/m_axis_aresetn] [get_bd_pins axis_clock_converter_8/m_axis_aresetn] [get_bd_pins axis_clock_converter_9/m_axis_aresetn] [get_bd_pins axis_register_slice_12/aresetn] [get_bd_pins axis_register_slice_13/aresetn] [get_bd_pins axis_register_slice_14/aresetn] [get_bd_pins axis_register_slice_15/aresetn] [get_bd_pins axis_register_slice_16/aresetn] [get_bd_pins axis_register_slice_17/aresetn] [get_bd_pins axis_register_slice_18/aresetn] [get_bd_pins axis_register_slice_19/aresetn] [get_bd_pins usp_rf_data_converter_0/s0_axis_aresetn]
  connect_bd_net -net Net2 [get_bd_pins rst_dac1/peripheral_aresetn] [get_bd_pins axis_sg_int4_v1_0/aresetn] [get_bd_pins axis_sg_int4_v1_1/aresetn] [get_bd_pins axis_sg_int4_v1_2/aresetn] [get_bd_pins axis_sg_int4_v1_3/aresetn] [get_bd_pins axis_clock_converter_0/m_axis_aresetn] [get_bd_pins axis_clock_converter_1/m_axis_aresetn] [get_bd_pins axis_clock_converter_2/m_axis_aresetn] [get_bd_pins axis_clock_converter_3/m_axis_aresetn] [get_bd_pins usp_rf_data_converter_0/s1_axis_aresetn] [get_bd_pins sg_translator_0/aresetn] [get_bd_pins sg_translator_1/aresetn] [get_bd_pins sg_translator_2/aresetn] [get_bd_pins sg_translator_3/aresetn] [get_bd_pins sg_translator_4/aresetn] [get_bd_pins sg_translator_5/aresetn] [get_bd_pins sg_translator_6/aresetn] [get_bd_pins sg_translator_7/aresetn] [get_bd_pins sg_translator_8/aresetn] [get_bd_pins sg_translator_9/aresetn] [get_bd_pins sg_translator_10/aresetn] [get_bd_pins sg_translator_11/aresetn] [get_bd_pins sg_translator_12/aresetn] [get_bd_pins sg_translator_13/aresetn] [get_bd_pins sg_translator_14/aresetn] [get_bd_pins sg_translator_15/aresetn] [get_bd_pins axis_clock_converter_0/s_axis_aresetn] [get_bd_pins axis_clock_converter_10/s_axis_aresetn] [get_bd_pins axis_clock_converter_11/s_axis_aresetn] [get_bd_pins axis_clock_converter_12/s_axis_aresetn] [get_bd_pins axis_clock_converter_13/s_axis_aresetn] [get_bd_pins axis_clock_converter_14/s_axis_aresetn] [get_bd_pins axis_clock_converter_15/s_axis_aresetn] [get_bd_pins axis_clock_converter_1/s_axis_aresetn] [get_bd_pins axis_clock_converter_2/s_axis_aresetn] [get_bd_pins axis_clock_converter_3/s_axis_aresetn] [get_bd_pins axis_clock_converter_4/s_axis_aresetn] [get_bd_pins axis_clock_converter_5/s_axis_aresetn] [get_bd_pins axis_clock_converter_6/s_axis_aresetn] [get_bd_pins axis_clock_converter_7/s_axis_aresetn] [get_bd_pins axis_clock_converter_8/s_axis_aresetn] [get_bd_pins axis_clock_converter_9/s_axis_aresetn] [get_bd_pins qick_processor_0/t_resetn] [get_bd_pins qick_com_0/t_aresetn]
  connect_bd_net -net Net4 [get_bd_pins usp_rf_data_converter_0/clk_dac1] [get_bd_pins axis_sg_int4_v1_0/aclk] [get_bd_pins axis_sg_int4_v1_1/aclk] [get_bd_pins axis_sg_int4_v1_2/aclk] [get_bd_pins axis_sg_int4_v1_3/aclk] [get_bd_pins rst_dac1/slowest_sync_clk] [get_bd_pins axis_clock_converter_0/m_axis_aclk] [get_bd_pins axis_clock_converter_1/m_axis_aclk] [get_bd_pins axis_clock_converter_2/m_axis_aclk] [get_bd_pins axis_clock_converter_3/m_axis_aclk] [get_bd_pins usp_rf_data_converter_0/s1_axis_aclk] [get_bd_pins sg_translator_0/aclk] [get_bd_pins sg_translator_1/aclk] [get_bd_pins sg_translator_2/aclk] [get_bd_pins sg_translator_3/aclk] [get_bd_pins sg_translator_4/aclk] [get_bd_pins sg_translator_5/aclk] [get_bd_pins sg_translator_6/aclk] [get_bd_pins sg_translator_7/aclk] [get_bd_pins sg_translator_8/aclk] [get_bd_pins sg_translator_9/aclk] [get_bd_pins sg_translator_10/aclk] [get_bd_pins sg_translator_11/aclk] [get_bd_pins sg_translator_12/aclk] [get_bd_pins sg_translator_13/aclk] [get_bd_pins sg_translator_14/aclk] [get_bd_pins sg_translator_15/aclk] [get_bd_pins axis_clock_converter_0/s_axis_aclk] [get_bd_pins axis_clock_converter_10/s_axis_aclk] [get_bd_pins axis_clock_converter_11/s_axis_aclk] [get_bd_pins axis_clock_converter_12/s_axis_aclk] [get_bd_pins axis_clock_converter_13/s_axis_aclk] [get_bd_pins axis_clock_converter_14/s_axis_aclk] [get_bd_pins axis_clock_converter_15/s_axis_aclk] [get_bd_pins axis_clock_converter_1/s_axis_aclk] [get_bd_pins axis_clock_converter_2/s_axis_aclk] [get_bd_pins axis_clock_converter_3/s_axis_aclk] [get_bd_pins axis_clock_converter_4/s_axis_aclk] [get_bd_pins axis_clock_converter_5/s_axis_aclk] [get_bd_pins axis_clock_converter_6/s_axis_aclk] [get_bd_pins axis_clock_converter_7/s_axis_aclk] [get_bd_pins axis_clock_converter_8/s_axis_aclk] [get_bd_pins axis_clock_converter_9/s_axis_aclk] [get_bd_pins qick_processor_0/t_clk_i] [get_bd_pins qick_com_0/t_clk]
  connect_bd_net -net Net5 [get_bd_pins rst_dac3/peripheral_aresetn] [get_bd_pins axis_sg_int4_v1_10/aresetn] [get_bd_pins axis_sg_int4_v1_11/aresetn] [get_bd_pins axis_sg_int4_v1_8/aresetn] [get_bd_pins axis_sg_int4_v1_9/aresetn] [get_bd_pins axis_clock_converter_12/m_axis_aresetn] [get_bd_pins axis_clock_converter_13/m_axis_aresetn] [get_bd_pins axis_clock_converter_14/m_axis_aresetn] [get_bd_pins axis_clock_converter_15/m_axis_aresetn] [get_bd_pins usp_rf_data_converter_0/s3_axis_aresetn]
  connect_bd_net -net pmod_i_0_1 [get_bd_ports pmod_i] [get_bd_pins qick_com_0/pmod_i]
  connect_bd_net -net qick_com_0_pmod_o [get_bd_pins qick_com_0/pmod_o] [get_bd_ports pmod_o]
  connect_bd_net -net qick_com_0_qproc_start_o [get_bd_pins qick_com_0/qproc_start_o] [get_bd_pins qick_processor_0/proc_start_i]
  connect_bd_net -net qick_processor_0_port_0_dt_o [get_bd_pins qick_processor_0/port_0_dt_o] [get_bd_pins qick_vec2bit_0/din]
  connect_bd_net -net qick_processor_0_pulse_sync_o [get_bd_pins qick_processor_0/pulse_sync_o] [get_bd_ports sync_o]
  connect_bd_net -net qick_processor_0_trig_0_o [get_bd_pins qick_processor_0/trig_0_o] [get_bd_ports trig_0_o]
  connect_bd_net -net qick_processor_0_trig_1_o [get_bd_pins qick_processor_0/trig_1_o] [get_bd_ports trig_1_o]
  connect_bd_net -net qick_vec2bit_0_dout0 [get_bd_pins qick_vec2bit_0/dout0] [get_bd_pins axis_avg_buffer_0/trigger]
  connect_bd_net -net qick_vec2bit_0_dout1 [get_bd_pins qick_vec2bit_0/dout1] [get_bd_pins axis_avg_buffer_1/trigger]
  connect_bd_net -net qick_vec2bit_0_dout2 [get_bd_pins qick_vec2bit_0/dout2] [get_bd_pins axis_avg_buffer_2/trigger]
  connect_bd_net -net qick_vec2bit_0_dout3 [get_bd_pins qick_vec2bit_0/dout3] [get_bd_pins axis_avg_buffer_3/trigger]
  connect_bd_net -net qick_vec2bit_0_dout4 [get_bd_pins qick_vec2bit_0/dout4] [get_bd_pins axis_avg_buffer_4/trigger]
  connect_bd_net -net rst_100_peripheral_aresetn [get_bd_pins rst_100/peripheral_aresetn] [get_bd_pins axis_avg_buffer_0/m_axis_aresetn] [get_bd_pins axis_avg_buffer_0/s_axi_aresetn] [get_bd_pins axis_avg_buffer_1/m_axis_aresetn] [get_bd_pins axis_avg_buffer_1/s_axi_aresetn] [get_bd_pins axis_avg_buffer_2/m_axis_aresetn] [get_bd_pins axis_avg_buffer_2/s_axi_aresetn] [get_bd_pins axis_avg_buffer_3/m_axis_aresetn] [get_bd_pins axis_avg_buffer_3/s_axi_aresetn] [get_bd_pins axis_avg_buffer_4/m_axis_aresetn] [get_bd_pins axis_avg_buffer_4/s_axi_aresetn] [get_bd_pins axis_pfb_readout_v3_0/s_axi_aresetn] [get_bd_pins axis_readout_v2_0/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_0/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_0/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_1/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_1/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_10/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_10/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_11/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_11/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_2/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_2/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_3/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_3/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_4/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_4/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_5/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_5/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_6/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_6/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_7/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_7/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_8/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_8/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_9/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_9/s_axi_aresetn] [get_bd_pins axis_sg_mux8_v1_0/s_axi_aresetn] [get_bd_pins axis_signal_gen_v6_10/s0_axis_aresetn] [get_bd_pins axis_signal_gen_v6_10/s_axi_aresetn] [get_bd_pins axis_signal_gen_v6_8/s0_axis_aresetn] [get_bd_pins axis_signal_gen_v6_8/s_axi_aresetn] [get_bd_pins axis_signal_gen_v6_9/s0_axis_aresetn] [get_bd_pins axis_signal_gen_v6_9/s_axi_aresetn] [get_bd_pins axis_terminator_4/s_axis_aresetn] [get_bd_pins axi_dma_avg/axi_resetn] [get_bd_pins axi_dma_buf/axi_resetn] [get_bd_pins axi_dma_gen/axi_resetn] [get_bd_pins axi_dma_tproc/axi_resetn] [get_bd_pins axi_smc_0/aresetn] [get_bd_pins axi_smc_1/aresetn] [get_bd_pins axi_smc_2/aresetn] [get_bd_pins axi_smc_3/aresetn] [get_bd_pins axi_smc_4/aresetn] [get_bd_pins axis_cc_avg_0/s_axis_aresetn] [get_bd_pins axis_cc_avg_1/s_axis_aresetn] [get_bd_pins axis_cc_avg_2/s_axis_aresetn] [get_bd_pins axis_cc_avg_3/s_axis_aresetn] [get_bd_pins axis_switch_avg/aresetn] [get_bd_pins axis_switch_avg/s_axi_ctrl_aresetn] [get_bd_pins axis_switch_buf/aresetn] [get_bd_pins axis_switch_buf/s_axi_ctrl_aresetn] [get_bd_pins axis_switch_gen/aresetn] [get_bd_pins axis_switch_gen/s_axi_ctrl_aresetn] [get_bd_pins usp_rf_data_converter_0/s_axi_aresetn] [get_bd_pins qick_processor_0/ps_resetn] [get_bd_pins qick_com_0/ps_aresetn]
  connect_bd_net -net rst_adc2_peripheral_aresetn [get_bd_pins rst_adc2/peripheral_aresetn] [get_bd_pins axis_avg_buffer_0/s_axis_aresetn] [get_bd_pins axis_avg_buffer_1/s_axis_aresetn] [get_bd_pins axis_avg_buffer_2/s_axis_aresetn] [get_bd_pins axis_avg_buffer_3/s_axis_aresetn] [get_bd_pins axis_avg_buffer_4/s_axis_aresetn] [get_bd_pins axis_pfb_readout_v3_0/aresetn] [get_bd_pins axis_readout_v2_0/aresetn] [get_bd_pins usp_rf_data_converter_0/m2_axis_aresetn] [get_bd_pins qick_processor_0/c_resetn] [get_bd_pins axis_cc_avg_0/m_axis_aresetn] [get_bd_pins axis_cc_avg_1/m_axis_aresetn] [get_bd_pins axis_cc_avg_2/m_axis_aresetn] [get_bd_pins axis_cc_avg_3/m_axis_aresetn] [get_bd_pins qick_com_0/c_aresetn]
  connect_bd_net -net rst_dac1_peripheral_aresetn [get_bd_pins rst_dac2/peripheral_aresetn] [get_bd_pins axis_sg_int4_v1_4/aresetn] [get_bd_pins axis_sg_int4_v1_5/aresetn] [get_bd_pins axis_sg_int4_v1_6/aresetn] [get_bd_pins axis_sg_int4_v1_7/aresetn] [get_bd_pins axis_clock_converter_4/m_axis_aresetn] [get_bd_pins axis_clock_converter_5/m_axis_aresetn] [get_bd_pins axis_clock_converter_6/m_axis_aresetn] [get_bd_pins axis_clock_converter_7/m_axis_aresetn] [get_bd_pins usp_rf_data_converter_0/s2_axis_aresetn]
  connect_bd_net -net sync_i_0_1 [get_bd_ports sync_i] [get_bd_pins qick_com_0/sync_i]
  connect_bd_net -net usp_rf_data_converter_0_clk_adc2 [get_bd_pins usp_rf_data_converter_0/clk_adc2] [get_bd_pins axis_avg_buffer_0/s_axis_aclk] [get_bd_pins axis_avg_buffer_1/s_axis_aclk] [get_bd_pins axis_avg_buffer_2/s_axis_aclk] [get_bd_pins axis_avg_buffer_3/s_axis_aclk] [get_bd_pins axis_avg_buffer_4/s_axis_aclk] [get_bd_pins axis_pfb_readout_v3_0/aclk] [get_bd_pins axis_readout_v2_0/aclk] [get_bd_pins rst_adc2/slowest_sync_clk] [get_bd_pins usp_rf_data_converter_0/m2_axis_aclk] [get_bd_pins qick_processor_0/c_clk_i] [get_bd_pins axis_cc_avg_0/m_axis_aclk] [get_bd_pins axis_cc_avg_1/m_axis_aclk] [get_bd_pins axis_cc_avg_2/m_axis_aclk] [get_bd_pins axis_cc_avg_3/m_axis_aclk] [get_bd_pins qick_com_0/c_clk]
  connect_bd_net -net usp_rf_data_converter_0_clk_dac2 [get_bd_pins usp_rf_data_converter_0/clk_dac2] [get_bd_pins axis_sg_int4_v1_4/aclk] [get_bd_pins axis_sg_int4_v1_5/aclk] [get_bd_pins axis_sg_int4_v1_6/aclk] [get_bd_pins axis_sg_int4_v1_7/aclk] [get_bd_pins rst_dac2/slowest_sync_clk] [get_bd_pins axis_clock_converter_4/m_axis_aclk] [get_bd_pins axis_clock_converter_5/m_axis_aclk] [get_bd_pins axis_clock_converter_6/m_axis_aclk] [get_bd_pins axis_clock_converter_7/m_axis_aclk] [get_bd_pins usp_rf_data_converter_0/s2_axis_aclk]
  connect_bd_net -net usp_rf_data_converter_0_clk_dac3 [get_bd_pins usp_rf_data_converter_0/clk_dac3] [get_bd_pins axis_sg_int4_v1_10/aclk] [get_bd_pins axis_sg_int4_v1_11/aclk] [get_bd_pins axis_sg_int4_v1_8/aclk] [get_bd_pins axis_sg_int4_v1_9/aclk] [get_bd_pins rst_dac3/slowest_sync_clk] [get_bd_pins axis_clock_converter_12/m_axis_aclk] [get_bd_pins axis_clock_converter_13/m_axis_aclk] [get_bd_pins axis_clock_converter_14/m_axis_aclk] [get_bd_pins axis_clock_converter_15/m_axis_aclk] [get_bd_pins usp_rf_data_converter_0/s3_axis_aclk]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axis_avg_buffer_0/m_axis_aclk] [get_bd_pins axis_avg_buffer_0/s_axi_aclk] [get_bd_pins axis_avg_buffer_1/m_axis_aclk] [get_bd_pins axis_avg_buffer_1/s_axi_aclk] [get_bd_pins axis_avg_buffer_2/m_axis_aclk] [get_bd_pins axis_avg_buffer_2/s_axi_aclk] [get_bd_pins axis_avg_buffer_3/m_axis_aclk] [get_bd_pins axis_avg_buffer_3/s_axi_aclk] [get_bd_pins axis_avg_buffer_4/m_axis_aclk] [get_bd_pins axis_avg_buffer_4/s_axi_aclk] [get_bd_pins axis_pfb_readout_v3_0/s_axi_aclk] [get_bd_pins axis_readout_v2_0/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_0/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_0/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_1/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_1/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_10/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_10/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_11/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_11/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_2/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_2/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_3/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_3/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_4/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_4/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_5/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_5/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_6/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_6/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_7/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_7/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_8/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_8/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_9/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_9/s_axi_aclk] [get_bd_pins axis_sg_mux8_v1_0/s_axi_aclk] [get_bd_pins axis_signal_gen_v6_10/s0_axis_aclk] [get_bd_pins axis_signal_gen_v6_10/s_axi_aclk] [get_bd_pins axis_signal_gen_v6_8/s0_axis_aclk] [get_bd_pins axis_signal_gen_v6_8/s_axi_aclk] [get_bd_pins axis_signal_gen_v6_9/s0_axis_aclk] [get_bd_pins axis_signal_gen_v6_9/s_axi_aclk] [get_bd_pins axis_terminator_4/s_axis_aclk] [get_bd_pins rst_100/slowest_sync_clk] [get_bd_pins axi_dma_avg/s_axi_lite_aclk] [get_bd_pins axi_dma_avg/m_axi_s2mm_aclk] [get_bd_pins axi_dma_buf/s_axi_lite_aclk] [get_bd_pins axi_dma_buf/m_axi_s2mm_aclk] [get_bd_pins axi_dma_gen/s_axi_lite_aclk] [get_bd_pins axi_dma_gen/m_axi_mm2s_aclk] [get_bd_pins axi_dma_tproc/s_axi_lite_aclk] [get_bd_pins axi_dma_tproc/m_axi_mm2s_aclk] [get_bd_pins axi_dma_tproc/m_axi_s2mm_aclk] [get_bd_pins axi_smc_0/aclk] [get_bd_pins axi_smc_1/aclk] [get_bd_pins axi_smc_2/aclk] [get_bd_pins axi_smc_3/aclk] [get_bd_pins axi_smc_4/aclk] [get_bd_pins axis_cc_avg_0/s_axis_aclk] [get_bd_pins axis_cc_avg_1/s_axis_aclk] [get_bd_pins axis_cc_avg_2/s_axis_aclk] [get_bd_pins axis_cc_avg_3/s_axis_aclk] [get_bd_pins axis_switch_avg/aclk] [get_bd_pins axis_switch_avg/s_axi_ctrl_aclk] [get_bd_pins axis_switch_buf/aclk] [get_bd_pins axis_switch_buf/s_axi_ctrl_aclk] [get_bd_pins axis_switch_gen/aclk] [get_bd_pins axis_switch_gen/s_axi_ctrl_aclk] [get_bd_pins usp_rf_data_converter_0/s_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/maxihpm1_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/saxihpc0_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/saxihpc1_fpd_aclk] [get_bd_pins qick_processor_0/ps_clk_i] [get_bd_pins qick_com_0/ps_clk]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_resetn0 [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins rst_100/ext_reset_in] [get_bd_pins rst_adc2/ext_reset_in] [get_bd_pins rst_dac0/ext_reset_in] [get_bd_pins rst_dac1/ext_reset_in] [get_bd_pins rst_dac2/ext_reset_in] [get_bd_pins rst_dac3/ext_reset_in]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_avg/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_LOW] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_dma_avg/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_QSPI] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_buf/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_LOW] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_dma_buf/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_QSPI] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_gen/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_LOW] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_dma_gen/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_QSPI] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_tproc/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP1/HPC1_DDR_LOW] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_dma_tproc/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP1/HPC1_QSPI] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_tproc/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP1/HPC1_DDR_LOW] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_dma_tproc/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP1/HPC1_QSPI] -force
  assign_bd_address -offset 0xA0000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_dma_avg/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0xA0010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_dma_buf/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0xA0020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_dma_gen/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0xA0030000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_dma_tproc/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0xB0020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_avg_buffer_0/s_axi/reg0] -force
  assign_bd_address -offset 0xB0110000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_avg_buffer_1/s_axi/reg0] -force
  assign_bd_address -offset 0xB0120000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_avg_buffer_2/s_axi/reg0] -force
  assign_bd_address -offset 0xB0130000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_avg_buffer_3/s_axi/reg0] -force
  assign_bd_address -offset 0xB0140000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_avg_buffer_4/s_axi/reg0] -force
  assign_bd_address -offset 0xB0001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_pfb_readout_v3_0/s_axi/reg0] -force
  assign_bd_address -offset 0xB0150000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_readout_v2_0/s_axi/reg0] -force
  assign_bd_address -offset 0xB00A0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_sg_int4_v1_0/s_axi/reg0] -force
  assign_bd_address -offset 0xB0170000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_sg_int4_v1_10/s_axi/reg0] -force
  assign_bd_address -offset 0xB01C0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_sg_int4_v1_11/s_axi/reg0] -force
  assign_bd_address -offset 0xB0030000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_sg_int4_v1_1/s_axi/reg0] -force
  assign_bd_address -offset 0xB0040000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_sg_int4_v1_2/s_axi/reg0] -force
  assign_bd_address -offset 0xB0080000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_sg_int4_v1_3/s_axi/reg0] -force
  assign_bd_address -offset 0xB0090000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_sg_int4_v1_4/s_axi/reg0] -force
  assign_bd_address -offset 0xB0180000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_sg_int4_v1_5/s_axi/reg0] -force
  assign_bd_address -offset 0xB0190000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_sg_int4_v1_6/s_axi/reg0] -force
  assign_bd_address -offset 0xB01A0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_sg_int4_v1_7/s_axi/reg0] -force
  assign_bd_address -offset 0xB0010000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_sg_int4_v1_8/s_axi/reg0] -force
  assign_bd_address -offset 0xB0160000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_sg_int4_v1_9/s_axi/reg0] -force
  assign_bd_address -offset 0xB0000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_sg_mux8_v1_0/s_axi/reg0] -force
  assign_bd_address -offset 0xB01B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_signal_gen_v6_10/s_axi/reg0] -force
  assign_bd_address -offset 0xB00B0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_signal_gen_v6_8/s_axi/reg0] -force
  assign_bd_address -offset 0xB0100000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_signal_gen_v6_9/s_axi/reg0] -force
  assign_bd_address -offset 0xB0050000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_switch_avg/S_AXI_CTRL/Reg] -force
  assign_bd_address -offset 0xB0060000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_switch_buf/S_AXI_CTRL/Reg] -force
  assign_bd_address -offset 0xB0070000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_switch_gen/S_AXI_CTRL/Reg] -force
  assign_bd_address -offset 0xA0001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs qick_com_0/s_axi/reg0] -force
  assign_bd_address -offset 0xA0040000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs qick_processor_0/s_axi/reg0] -force
  assign_bd_address -offset 0xB00C0000 -range 0x00040000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs usp_rf_data_converter_0/s_axi/Reg] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -offset 0x000800000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces axi_dma_avg/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_HIGH]
  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces axi_dma_avg/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_LPS_OCM]
  exclude_bd_addr_seg -offset 0x000800000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces axi_dma_buf/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_HIGH]
  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces axi_dma_buf/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_LPS_OCM]
  exclude_bd_addr_seg -offset 0x000800000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces axi_dma_gen/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_HIGH]
  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces axi_dma_gen/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_LPS_OCM]
  exclude_bd_addr_seg -offset 0x000800000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces axi_dma_tproc/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP1/HPC1_DDR_HIGH]
  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces axi_dma_tproc/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP1/HPC1_LPS_OCM]
  exclude_bd_addr_seg -offset 0x000800000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces axi_dma_tproc/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP1/HPC1_DDR_HIGH]
  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces axi_dma_tproc/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP1/HPC1_LPS_OCM]

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"0.0784978",
   "Default View_TopLeft":"-6752,-2752",
   "ExpandedHierarchyInLayout":"",
   "PinnedBlocks":"/axis_sg_int4_v1_0|/axis_sg_int4_v1_1|/axis_sg_int4_v1_2|/axis_sg_int4_v1_3|/axis_sg_int4_v1_4|/axis_sg_int4_v1_5|/axis_sg_int4_v1_6|/axis_sg_int4_v1_7|/axis_sg_int4_v1_8|/axis_sg_int4_v1_9|/axis_sg_int4_v1_10|/axis_sg_int4_v1_11|/axis_sg_mux8_v1_0|/axis_signal_gen_v6_8|/axis_signal_gen_v6_9|/axis_signal_gen_v6_10|/axis_register_slice_0|/axis_register_slice_1|/axis_register_slice_2|/axis_register_slice_3|/axis_register_slice_16|/axis_register_slice_17|/axis_register_slice_14|/axis_register_slice_15|/axis_clock_converter_12|/axis_clock_converter_0|/axis_clock_converter_1|/axis_clock_converter_2|/axis_clock_converter_3|/axis_clock_converter_4|/axis_clock_converter_5|/axis_clock_converter_6|/axis_clock_converter_7|/axis_clock_converter_8|/axis_clock_converter_9|/axis_clock_converter_10|/axis_clock_converter_11|/axis_clock_converter_13|/axis_clock_converter_14|/axis_clock_converter_15|/axis_pfb_readout_v3_0|/axis_terminator_4|/axis_avg_buffer_0|/axis_avg_buffer_1|/axis_cc_avg_0|/axis_avg_buffer_2|/axis_avg_buffer_3|/axis_cc_avg_1|/axis_cc_avg_2|/axis_avg_buffer_4|/axis_readout_v2_0|/axis_cc_avg_3|/qick_vec2bit_0|/rst_100|/rst_adc2|/rst_dac0|/rst_dac1|/rst_dac2|/rst_dac3|/zynq_ultra_ps_e_0|/sg_translator_3|/sg_translator_2|/axi_dma_avg|/axi_dma_buf|/axi_dma_gen|/axi_dma_tproc|/axi_smc_0|/axi_smc_1|/axi_smc_2|/axi_smc_3|/axi_smc_4|/axis_register_slice_12|/axis_register_slice_13|/axis_register_slice_18|/axis_register_slice_19|/axis_switch_avg|/axis_switch_buf|/axis_switch_gen|/usp_rf_data_converter_0|/qick_processor_0|/sg_translator_0|/sg_translator_1|/sg_translator_4|/sg_translator_5|/sg_translator_6|/sg_translator_7|/sg_translator_8|/sg_translator_9|/sg_translator_10|/sg_translator_11|",
   "PinnedPorts":"adc2_clk|dac2_clk|sysref_in|vin20|vin22|vout00|vout01|vout02|vout03|vout10|vout11|vout12|vout13|vout20|vout21|vout22|vout23|vout30|vout31|vout32|vout33|",
   "guistr":"# # String gsaved with Nlview 7.5.8 2022-09-21 7111 VDI=41 GEI=38 GUI=JA:10.0 TLS
#  -string -flagsOSRD
preplace port adc2_clk -pg 1 -lvl 13 -x 4740 -y -380 -defaultsOSRD -right
preplace port dac2_clk -pg 1 -lvl 13 -x 4740 -y -360 -defaultsOSRD -right
preplace port sysref_in -pg 1 -lvl 13 -x 4740 -y -300 -defaultsOSRD -right
preplace port vin20 -pg 1 -lvl 13 -x 4740 -y -340 -defaultsOSRD -right
preplace port vin22 -pg 1 -lvl 13 -x 4740 -y -320 -defaultsOSRD -right
preplace port vout00 -pg 1 -lvl 13 -x 4740 -y -1220 -defaultsOSRD
preplace port vout01 -pg 1 -lvl 13 -x 4740 -y -1200 -defaultsOSRD
preplace port vout02 -pg 1 -lvl 13 -x 4740 -y -1180 -defaultsOSRD
preplace port vout03 -pg 1 -lvl 13 -x 4740 -y -1160 -defaultsOSRD
preplace port vout10 -pg 1 -lvl 13 -x 4740 -y -1140 -defaultsOSRD
preplace port vout11 -pg 1 -lvl 13 -x 4740 -y -1120 -defaultsOSRD
preplace port vout12 -pg 1 -lvl 13 -x 4740 -y -1100 -defaultsOSRD
preplace port vout13 -pg 1 -lvl 13 -x 4740 -y -1080 -defaultsOSRD
preplace port vout20 -pg 1 -lvl 13 -x 4740 -y -1060 -defaultsOSRD
preplace port vout21 -pg 1 -lvl 13 -x 4740 -y -1040 -defaultsOSRD
preplace port vout22 -pg 1 -lvl 13 -x 4740 -y -1020 -defaultsOSRD
preplace port vout23 -pg 1 -lvl 13 -x 4740 -y -1000 -defaultsOSRD
preplace port vout30 -pg 1 -lvl 13 -x 4740 -y -980 -defaultsOSRD
preplace port vout31 -pg 1 -lvl 13 -x 4740 -y -960 -defaultsOSRD
preplace port vout32 -pg 1 -lvl 13 -x 4740 -y -940 -defaultsOSRD
preplace port vout33 -pg 1 -lvl 13 -x 4740 -y -920 -defaultsOSRD
preplace inst axis_avg_buffer_0 -pg 1 -lvl 2 -x -2130 -y 1740 -defaultsOSRD -resize 220 236
preplace inst axis_avg_buffer_1 -pg 1 -lvl 2 -x -2130 -y 2000 -defaultsOSRD
preplace inst axis_avg_buffer_2 -pg 1 -lvl 2 -x -2130 -y 2260 -defaultsOSRD -resize 220 236
preplace inst axis_avg_buffer_3 -pg 1 -lvl 2 -x -2130 -y 2520 -defaultsOSRD -resize 220 236
preplace inst axis_avg_buffer_4 -pg 1 -lvl 2 -x -2130 -y 2780 -defaultsOSRD -resize 220 236
preplace inst axis_pfb_readout_v3_0 -pg 1 -lvl 1 -x -2590 -y 1950 -defaultsOSRD
preplace inst axis_readout_v2_0 -pg 1 -lvl 1 -x -2590 -y 1650 -defaultsOSRD
preplace inst axis_register_slice_0 -pg 1 -lvl 11 -x 4070 -y 2830 -defaultsOSRD
preplace inst axis_register_slice_1 -pg 1 -lvl 11 -x 4070 -y 3090 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_2 -pg 1 -lvl 11 -x 4070 -y 3350 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_3 -pg 1 -lvl 11 -x 4070 -y 3580 -defaultsOSRD -resize 180 116
preplace inst axis_sg_int4_v1_0 -pg 1 -lvl 10 -x 3550 -y -460 -defaultsOSRD -resize 220 236
preplace inst axis_sg_int4_v1_1 -pg 1 -lvl 10 -x 3550 -y -190 -defaultsOSRD
preplace inst axis_sg_int4_v1_2 -pg 1 -lvl 10 -x 3550 -y 80 -defaultsOSRD -resize 220 236
preplace inst axis_sg_int4_v1_3 -pg 1 -lvl 10 -x 3550 -y 350 -defaultsOSRD -resize 220 236
preplace inst axis_sg_int4_v1_4 -pg 1 -lvl 10 -x 3550 -y 620 -defaultsOSRD -resize 220 236
preplace inst axis_sg_int4_v1_5 -pg 1 -lvl 10 -x 3550 -y 890 -defaultsOSRD -resize 220 236
preplace inst axis_sg_int4_v1_6 -pg 1 -lvl 10 -x 3550 -y 1160 -defaultsOSRD -resize 220 236
preplace inst axis_sg_int4_v1_7 -pg 1 -lvl 10 -x 3550 -y 1430 -defaultsOSRD -resize 220 236
preplace inst axis_sg_int4_v1_8 -pg 1 -lvl 10 -x 3550 -y 1700 -defaultsOSRD
preplace inst axis_sg_int4_v1_9 -pg 1 -lvl 10 -x 3550 -y 1970 -defaultsOSRD
preplace inst axis_sg_int4_v1_10 -pg 1 -lvl 10 -x 3550 -y 2230 -defaultsOSRD
preplace inst axis_sg_int4_v1_11 -pg 1 -lvl 10 -x 3550 -y 2500 -defaultsOSRD
preplace inst axis_sg_mux8_v1_0 -pg 1 -lvl 10 -x 3550 -y 3520 -defaultsOSRD
preplace inst axis_signal_gen_v6_8 -pg 1 -lvl 10 -x 3550 -y 2770 -defaultsOSRD
preplace inst axis_signal_gen_v6_9 -pg 1 -lvl 10 -x 3550 -y 3030 -defaultsOSRD -resize 220 236
preplace inst axis_signal_gen_v6_10 -pg 1 -lvl 10 -x 3550 -y 3290 -defaultsOSRD -resize 220 236
preplace inst axis_terminator_4 -pg 1 -lvl 3 -x -1480 -y 1780 -defaultsOSRD -resize 160 116
preplace inst rst_100 -pg 1 -lvl 6 -x 1200 -y -2370 -defaultsOSRD
preplace inst rst_adc2 -pg 1 -lvl 6 -x 1200 -y -2190 -defaultsOSRD -resize 320 156
preplace inst rst_dac0 -pg 1 -lvl 6 -x 1200 -y -2010 -defaultsOSRD -resize 320 156
preplace inst rst_dac1 -pg 1 -lvl 6 -x 1200 -y -1830 -defaultsOSRD -resize 320 156
preplace inst rst_dac2 -pg 1 -lvl 6 -x 1200 -y -1650 -defaultsOSRD -resize 320 156
preplace inst rst_dac3 -pg 1 -lvl 6 -x 1200 -y -1470 -defaultsOSRD
preplace inst axi_dma_avg -pg 1 -lvl 4 -x -940 -y -530 -defaultsOSRD
preplace inst axi_dma_buf -pg 1 -lvl 4 -x -940 -y -350 -defaultsOSRD -resize 320 156
preplace inst axi_dma_gen -pg 1 -lvl 7 -x 1980 -y -1770 -defaultsOSRD
preplace inst axi_dma_tproc -pg 1 -lvl 4 -x -940 -y -150 -defaultsOSRD
preplace inst axi_smc_0 -pg 1 -lvl 10 -x 3550 -y -2470 -defaultsOSRD
preplace inst axi_smc_1 -pg 1 -lvl 10 -x 3550 -y -2160 -defaultsOSRD -resize 243 388
preplace inst axi_smc_2 -pg 1 -lvl 10 -x 3550 -y -1760 -defaultsOSRD -resize 253 347
preplace inst axi_smc_3 -pg 1 -lvl 5 -x -200 -y -2630 -defaultsOSRD
preplace inst axi_smc_4 -pg 1 -lvl 5 -x -200 -y -2460 -defaultsOSRD
preplace inst axis_cc_avg_0 -pg 1 -lvl 3 -x -1480 -y 2060 -defaultsOSRD -resize 220 156
preplace inst axis_cc_avg_1 -pg 1 -lvl 3 -x -1480 -y 2320 -defaultsOSRD -resize 220 156
preplace inst axis_cc_avg_2 -pg 1 -lvl 3 -x -1480 -y 2580 -defaultsOSRD -resize 220 156
preplace inst axis_cc_avg_3 -pg 1 -lvl 3 -x -1480 -y 2840 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_0 -pg 1 -lvl 7 -x 1980 -y -500 -defaultsOSRD
preplace inst axis_clock_converter_10 -pg 1 -lvl 7 -x 1980 -y 3100 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_11 -pg 1 -lvl 7 -x 1980 -y 3420 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_12 -pg 1 -lvl 7 -x 1980 -y 1580 -defaultsOSRD
preplace inst axis_clock_converter_13 -pg 1 -lvl 7 -x 1980 -y 2100 -defaultsOSRD
preplace inst axis_clock_converter_14 -pg 1 -lvl 7 -x 1980 -y 2360 -defaultsOSRD
preplace inst axis_clock_converter_15 -pg 1 -lvl 7 -x 1980 -y 1840 -defaultsOSRD
preplace inst axis_clock_converter_1 -pg 1 -lvl 7 -x 1980 -y -230 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_2 -pg 1 -lvl 7 -x 1980 -y 20 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_3 -pg 1 -lvl 7 -x 1980 -y 280 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_4 -pg 1 -lvl 7 -x 1980 -y 540 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_5 -pg 1 -lvl 7 -x 1980 -y 800 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_6 -pg 1 -lvl 7 -x 1980 -y 1060 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_7 -pg 1 -lvl 7 -x 1980 -y 1320 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_8 -pg 1 -lvl 7 -x 1980 -y 2580 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_9 -pg 1 -lvl 7 -x 1980 -y 2840 -defaultsOSRD -resize 220 156
preplace inst axis_register_slice_12 -pg 1 -lvl 8 -x 2410 -y 3360 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_13 -pg 1 -lvl 8 -x 2410 -y 3120 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_14 -pg 1 -lvl 8 -x 2410 -y 2860 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_15 -pg 1 -lvl 8 -x 2410 -y 2600 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_16 -pg 1 -lvl 9 -x 2760 -y 2620 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_17 -pg 1 -lvl 9 -x 2760 -y 2880 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_18 -pg 1 -lvl 9 -x 2760 -y 3140 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_19 -pg 1 -lvl 9 -x 2760 -y 3380 -defaultsOSRD -resize 180 116
preplace inst axis_switch_avg -pg 1 -lvl 3 -x -1480 -y 1530 -defaultsOSRD
preplace inst axis_switch_buf -pg 1 -lvl 3 -x -1480 -y 1150 -defaultsOSRD -resize 240 394
preplace inst axis_switch_gen -pg 1 -lvl 8 -x 2410 -y -1730 -defaultsOSRD
preplace inst usp_rf_data_converter_0 -pg 1 -lvl 12 -x 4520 -y -1030 -defaultsOSRD
preplace inst zynq_ultra_ps_e_0 -pg 1 -lvl 6 -x 1200 -y -2570 -defaultsOSRD
preplace inst qick_processor_0 -pg 1 -lvl 5 -x -200 -y 3150 -defaultsOSRD
preplace inst qick_vec2bit_0 -pg 1 -lvl 1 -x -2590 -y 3070 -defaultsOSRD
preplace inst sg_translator_0 -pg 1 -lvl 6 -x 1200 -y -540 -defaultsOSRD
preplace inst sg_translator_1 -pg 1 -lvl 6 -x 1200 -y -280 -defaultsOSRD -resize 240 116
preplace inst sg_translator_2 -pg 1 -lvl 6 -x 1200 -y -20 -defaultsOSRD -resize 240 116
preplace inst sg_translator_3 -pg 1 -lvl 6 -x 1200 -y 240 -defaultsOSRD -resize 240 116
preplace inst sg_translator_4 -pg 1 -lvl 6 -x 1200 -y 500 -defaultsOSRD -resize 240 116
preplace inst sg_translator_5 -pg 1 -lvl 6 -x 1200 -y 760 -defaultsOSRD -resize 240 116
preplace inst sg_translator_6 -pg 1 -lvl 6 -x 1200 -y 1020 -defaultsOSRD -resize 240 116
preplace inst sg_translator_7 -pg 1 -lvl 6 -x 1200 -y 1280 -defaultsOSRD -resize 240 116
preplace inst sg_translator_8 -pg 1 -lvl 6 -x 1200 -y 1540 -defaultsOSRD -resize 240 116
preplace inst sg_translator_9 -pg 1 -lvl 6 -x 1200 -y 1800 -defaultsOSRD -resize 240 116
preplace inst sg_translator_10 -pg 1 -lvl 6 -x 1200 -y 2060 -defaultsOSRD -resize 240 116
preplace inst sg_translator_11 -pg 1 -lvl 6 -x 1200 -y 2380 -defaultsOSRD -resize 240 116
preplace inst sg_translator_12 -pg 1 -lvl 6 -x 1200 -y 2540 -defaultsOSRD -resize 240 116
preplace inst sg_translator_13 -pg 1 -lvl 6 -x 1200 -y 2800 -defaultsOSRD -resize 240 116
preplace inst sg_translator_14 -pg 1 -lvl 6 -x 1200 -y 3060 -defaultsOSRD -resize 240 116
preplace inst sg_translator_15 -pg 1 -lvl 6 -x 1200 -y 3380 -defaultsOSRD -resize 240 116
preplace inst qick_com_0 -pg 1 -lvl 5 -x -200 -y 3600 -defaultsOSRD
preplace netloc Net 1 5 8 860 2620 1780 2680 2240 2680 2640 2800 2900 3630 3960J -620 4300 -620 4700
preplace netloc Net1 1 6 6 1760 2690 2250 2690 2650J 2790 2910 3640 3950 -840 N
preplace netloc Net2 1 4 8 -350 2900 810 -460 1750 -800 N -800 N -800 3200 -800 N -800 N
preplace netloc Net4 1 4 9 -370 2890 780 -450 1790 -80 N -80 N -80 3230 -610 N -610 4320 -610 4690
preplace netloc Net5 1 6 6 1740 -720 N -720 N -720 3100 -720 N -720 N
preplace netloc qick_processor_0_port_0_dt_o 1 0 6 -2710 2940 N 2940 -1620 2740 N 2740 N 2740 -50
preplace netloc qick_vec2bit_0_dout0 1 1 1 -2470 1740n
preplace netloc qick_vec2bit_0_dout1 1 1 1 -2350 2000n
preplace netloc qick_vec2bit_0_dout2 1 1 1 -2330 2260n
preplace netloc qick_vec2bit_0_dout3 1 1 1 -2280 2520n
preplace netloc qick_vec2bit_0_dout4 1 1 1 -2270 2780n
preplace netloc rst_100_peripheral_aresetn 1 0 12 -2760 1770 -2310 1600 -1750 -20 -1160 -20 -420 -1210 N -1210 1510J -1670 2260 -1510 N -1510 3030 -900 N -900 NJ
preplace netloc rst_adc2_peripheral_aresetn 1 0 12 -2750 1780 -2370 2920 -1640 2690 N 2690 -390 -880 N -880 1520 -880 NJ -880 N -880 N -880 NJ -880 N
preplace netloc rst_dac1_peripheral_aresetn 1 6 6 1780 -760 NJ -760 NJ -760 3150 -760 N -760 N
preplace netloc usp_rf_data_converter_0_clk_adc2 1 0 13 -2740 1760 -2360 2930 -1630 2680 N 2680 -380 -860 710 -860 N -860 N -860 N -860 N -860 N -860 4280 -640 4680
preplace netloc usp_rf_data_converter_0_clk_dac2 1 5 8 890 -100 1800 -100 N -100 N -100 3220 -630 N -630 4310 -630 4660
preplace netloc usp_rf_data_converter_0_clk_dac3 1 5 8 880 1620 1780 1680 N 1680 N 1680 2910 -600 N -600 4330 -600 4670
preplace netloc zynq_ultra_ps_e_0_pl_clk0 1 0 12 -2770 1540 -2320 1540 -1690 -30 -1180 -30 -450 -2730 860 -2700 1780J -1680 2250 -1500 N -1500 3020 -920 N -920 NJ
preplace netloc zynq_ultra_ps_e_0_pl_resetn0 1 5 2 870 -2690 1510
preplace netloc adc2_clk_1 1 11 2 4380 -380 N
preplace netloc axi_dma_0_M_AXIS_MM2S 1 7 1 N -1780
preplace netloc axi_dma_avg_M_AXI_S2MM 1 4 1 -710 -2670n
preplace netloc axi_dma_buf_M_AXI_S2MM 1 4 1 -700 -2650n
preplace netloc axi_dma_gen_M_AXI_MM2S 1 4 4 -360 -1370 N -1370 N -1370 2160
preplace netloc axi_dma_tproc_M_AXIS_MM2S 1 4 1 -430 -170n
preplace netloc axi_dma_tproc_M_AXI_MM2S 1 4 1 -430 -2490n
preplace netloc axi_dma_tproc_M_AXI_S2MM 1 4 1 -410 -2470n
preplace netloc axi_smc_0_M00_AXI 1 4 7 -360 -1360 NJ -1360 NJ -1360 NJ -1360 NJ -1360 2970J -1530 3920
preplace netloc axi_smc_0_M01_AXI 1 3 8 -1140 -1310 -760 -1350 N -1350 N -1350 N -1350 N -1350 3000 -1520 3900J
preplace netloc axi_smc_0_M02_AXI 1 3 8 -1130 -1300 -750 -1340 N -1340 N -1340 N -1340 N -1340 3040 -1510 3890J
preplace netloc axi_smc_0_M03_AXI 1 6 5 1800J -1530 NJ -1530 N -1530 2890 -1560 3800
preplace netloc axi_smc_0_M04_AXI 1 3 8 -1120 -1290 -740 -1330 N -1330 NJ -1330 NJ -1330 N -1330 3060 -1500 3880
preplace netloc axi_smc_1_M00_AXI 1 5 1 N -2630
preplace netloc axi_smc_1_M00_AXI1 1 9 2 3340 -2640 3700
preplace netloc axi_smc_1_M01_AXI 1 9 2 3350 -2630 3760
preplace netloc axi_smc_1_M02_AXI 1 9 2 3360 -2620 3790
preplace netloc axi_smc_1_M03_AXI 1 9 2 3370 -2610 3810
preplace netloc axi_smc_1_M04_AXI 1 9 2 3380 -2600 3820
preplace netloc axi_smc_1_M05_AXI 1 9 2 3390 -2590 3830
preplace netloc axi_smc_1_M06_AXI 1 9 2 3270 -2710 3710
preplace netloc axi_smc_1_M07_AXI 1 9 2 3280 -2700 3730
preplace netloc axi_smc_1_M08_AXI 1 9 2 3290 -2690 3770
preplace netloc axi_smc_1_M09_AXI 1 9 2 3300 -2680 3850
preplace netloc axi_smc_1_M10_AXI 1 9 2 3310 -2670 3870
preplace netloc axi_smc_1_M11_AXI 1 9 2 3240 -2740 3720
preplace netloc axi_smc_1_M12_AXI 1 9 2 3250 -2730 3860
preplace netloc axi_smc_1_M13_AXI 1 9 2 3260 -2720 3910
preplace netloc axi_smc_1_M14_AXI 1 9 2 3320 -2660 3740
preplace netloc axi_smc_1_M15_AXI 1 9 2 3330 -2650 3750
preplace netloc axi_smc_1_M16_AXI 1 1 10 -2270 -1320 N -1320 N -1320 N -1320 N -1320 N -1320 N -1320 N -1320 3080 -1490 3870J
preplace netloc axi_smc_1_M17_AXI 1 1 10 -2290 -1270 N -1270 N -1270 -730 -1310 N -1310 N -1310 N -1310 N -1310 3090 -1480 3830J
preplace netloc axi_smc_1_M18_AXI 1 1 10 -2300 -1280 N -1280 N -1280 -720 -1300 N -1300 N -1300 N -1300 N -1300 3100 -1470 3820J
preplace netloc axi_smc_1_M19_AXI 1 1 10 -2280 -1260 N -1260 N -1260 -690 -1290 N -1290 N -1290 N -1290 N -1290 3110 -1460 3810J
preplace netloc axi_smc_1_M20_AXI 1 1 10 -2260 -1250 N -1250 N -1250 -440 -1280 N -1280 N -1280 N -1280 N -1280 3120 -1450 3790J
preplace netloc axi_smc_1_M21_AXI 1 0 11 -2780 -1240 N -1240 N -1240 N -1240 -720 -1270 N -1270 N -1270 N -1270 N -1270 3140 -1440 3750J
preplace netloc axi_smc_1_M22_AXI 1 0 11 -2730 -1230 N -1230 N -1230 N -1230 -400 -1260 N -1260 N -1260 N -1260 N -1260 3150 -1430 3700J
preplace netloc axi_smc_2_M00_AXI 1 5 1 40 -2610n
preplace netloc axi_smc_2_M00_AXI1 1 9 2 3400 -2580 3780
preplace netloc axi_smc_2_M03_AXI 1 2 9 -1630 -1220 N -1220 -390 -1250 N -1250 N -1250 N -1250 N -1250 N -1250 3770
preplace netloc axi_smc_2_M04_AXI 1 2 9 -1620 -1210 N -1210 -440 -1240 N -1240 N -1240 N -1240 N -1240 N -1240 3760
preplace netloc axi_smc_2_M05_AXI 1 7 4 2270 -1520 N -1520 2940 -1550 3740
preplace netloc axi_smc_2_M06_AXI 1 10 2 N -1781 4190
preplace netloc axis_avg_buffer_0_m0_axis 1 2 1 -1730 1440n
preplace netloc axis_avg_buffer_0_m1_axis 1 2 1 -2000 1000n
preplace netloc axis_avg_buffer_0_m2_axis 1 2 1 N 2020
preplace netloc axis_avg_buffer_1_m0_axis 1 2 1 -1710 1460n
preplace netloc axis_avg_buffer_1_m1_axis 1 2 1 -1740 1030n
preplace netloc axis_avg_buffer_1_m2_axis 1 2 1 N 2280
preplace netloc axis_avg_buffer_2_m0_axis 1 2 1 -1680 1480n
preplace netloc axis_avg_buffer_2_m1_axis 1 2 1 -1720 1060n
preplace netloc axis_avg_buffer_2_m2_axis 1 2 1 N 2540
preplace netloc axis_avg_buffer_3_m0_axis 1 2 1 -1660 1500n
preplace netloc axis_avg_buffer_3_m1_axis 1 2 1 -1700 1090n
preplace netloc axis_avg_buffer_3_m2_axis 1 2 1 N 2800
preplace netloc axis_avg_buffer_4_m0_axis 1 2 1 -1650 1520n
preplace netloc axis_avg_buffer_4_m1_axis 1 2 1 -1670 1120n
preplace netloc axis_avg_buffer_4_m2_axis 1 2 1 N 1760
preplace netloc axis_cc_avg_0_M_AXIS 1 3 2 N 2060 -400
preplace netloc axis_cc_avg_1_M_AXIS 1 3 2 N 2320 -410
preplace netloc axis_cc_avg_2_M_AXIS 1 3 2 N 2580 -440
preplace netloc axis_cc_avg_3_M_AXIS 1 3 2 N 2840 -760
preplace netloc axis_clock_converter_0_M_AXIS 1 7 3 2190 -520 N -520 N
preplace netloc axis_clock_converter_10_M_AXIS 1 7 1 N 3100
preplace netloc axis_clock_converter_11_M_AXIS 1 7 1 2270 3340n
preplace netloc axis_clock_converter_12_M_AXIS 1 7 3 N 1580 N 1580 2940
preplace netloc axis_clock_converter_13_M_AXIS 1 7 3 N 2100 N 2100 2870
preplace netloc axis_clock_converter_14_M_AXIS 1 7 3 N 2360 N 2360 2870
preplace netloc axis_clock_converter_15_M_AXIS 1 7 3 N 1840 N 1840 2870
preplace netloc axis_clock_converter_1_M_AXIS 1 7 3 2160 -250 N -250 N
preplace netloc axis_clock_converter_2_M_AXIS 1 7 3 N 20 N 20 N
preplace netloc axis_clock_converter_3_M_AXIS 1 7 3 N 280 N 280 3140
preplace netloc axis_clock_converter_4_M_AXIS 1 7 3 N 540 N 540 3080
preplace netloc axis_clock_converter_5_M_AXIS 1 7 3 N 800 N 800 3080
preplace netloc axis_clock_converter_6_M_AXIS 1 7 3 N 1060 N 1060 3060
preplace netloc axis_clock_converter_7_M_AXIS 1 7 3 N 1320 N 1320 3040
preplace netloc axis_clock_converter_8_M_AXIS 1 7 1 N 2580
preplace netloc axis_clock_converter_9_M_AXIS 1 7 1 N 2840
preplace netloc axis_pfb_readout_v3_0_m0_axis 1 1 1 N 1920
preplace netloc axis_pfb_readout_v3_0_m1_axis 1 1 1 -2330 1940n
preplace netloc axis_pfb_readout_v3_0_m2_axis 1 1 1 -2340 1960n
preplace netloc axis_pfb_readout_v3_0_m3_axis 1 1 1 -2460 1980n
preplace netloc axis_readout_v2_1_m1_axis 1 1 1 N 1660
preplace netloc axis_register_slice_0_m_axis 1 11 1 4190 -1340n
preplace netloc axis_register_slice_12_M_AXIS 1 8 1 N 3360
preplace netloc axis_register_slice_13_M_AXIS 1 8 1 N 3120
preplace netloc axis_register_slice_14_M_AXIS 1 8 1 N 2860
preplace netloc axis_register_slice_15_M_AXIS 1 8 1 N 2600
preplace netloc axis_register_slice_16_M_AXIS 1 9 1 2870 2620n
preplace netloc axis_register_slice_17_M_AXIS 1 9 1 2920 2880n
preplace netloc axis_register_slice_18_M_AXIS 1 9 1 2920 3140n
preplace netloc axis_register_slice_19_M_AXIS 1 9 1 2870 3380n
preplace netloc axis_register_slice_1_m_axis 1 11 1 4200 -1320n
preplace netloc axis_register_slice_2_m_axis 1 11 1 4210 -1300n
preplace netloc axis_register_slice_3_m_axis 1 11 1 4290 -1280n
preplace netloc axis_sg_int4_v1_0_m_axis 1 10 2 3790 -1260 N
preplace netloc axis_sg_int4_v1_10_m_axis 1 10 2 3900 -1060 N
preplace netloc axis_sg_int4_v1_11_m_axis 1 10 2 3890 -1080 N
preplace netloc axis_sg_int4_v1_1_m_axis 1 10 2 3800 -1240 N
preplace netloc axis_sg_int4_v1_2_m_axis 1 10 2 3810 -1220 N
preplace netloc axis_sg_int4_v1_3_m_axis 1 10 2 3820 -1200 N
preplace netloc axis_sg_int4_v1_4_m_axis 1 10 2 3830 -1180 N
preplace netloc axis_sg_int4_v1_5_m_axis 1 10 2 3840 -1160 N
preplace netloc axis_sg_int4_v1_6_m_axis 1 10 2 3850 -1140 N
preplace netloc axis_sg_int4_v1_7_m_axis 1 10 2 3860 -1120 N
preplace netloc axis_sg_int4_v1_8_m_axis 1 10 2 3880 -1040 N
preplace netloc axis_sg_int4_v1_9_m_axis 1 10 2 3870 -1100 N
preplace netloc axis_sg_mux8_v1_0_m_axis 1 10 1 3740 3520n
preplace netloc axis_signal_gen_v6_10_m_axis 1 10 1 3780 3290n
preplace netloc axis_signal_gen_v6_8_m_axis 1 10 1 3780 2770n
preplace netloc axis_signal_gen_v6_9_m_axis 1 10 1 3740 3030n
preplace netloc axis_switch_avg_M00_AXIS 1 3 1 -1340 -550n
preplace netloc axis_switch_buf_M00_AXIS 1 3 1 -1170 -370n
preplace netloc axis_switch_gen_M00_AXIS 1 8 2 N -1870 3210
preplace netloc axis_switch_gen_M01_AXIS 1 8 2 N -1850 3190
preplace netloc axis_switch_gen_M02_AXIS 1 8 2 N -1830 3180
preplace netloc axis_switch_gen_M03_AXIS 1 8 2 N -1810 3170
preplace netloc axis_switch_gen_M04_AXIS 1 8 2 N -1790 3160
preplace netloc axis_switch_gen_M05_AXIS 1 8 2 N -1770 2880
preplace netloc axis_switch_gen_M06_AXIS 1 8 2 N -1750 2870
preplace netloc axis_switch_gen_M07_AXIS 1 8 2 N -1730 3130
preplace netloc axis_switch_gen_M08_AXIS 1 8 2 N -1710 2990
preplace netloc axis_switch_gen_M09_AXIS 1 8 2 N -1690 2960
preplace netloc axis_switch_gen_M10_AXIS 1 8 2 N -1670 2930
preplace netloc axis_switch_gen_M11_AXIS 1 8 2 N -1650 3070
preplace netloc axis_switch_gen_M12_AXIS 1 8 2 N -1630 2980
preplace netloc axis_switch_gen_M13_AXIS 1 8 2 N -1610 3010
preplace netloc axis_switch_gen_M14_AXIS 1 8 2 N -1590 3050
preplace netloc dac2_clk_1 1 11 2 4370 -360 N
preplace netloc qick_processor_0_m0_axis 1 5 1 -30 -560n
preplace netloc qick_processor_0_m10_axis 1 5 1 830 2040n
preplace netloc qick_processor_0_m11_axis 1 5 1 840 2360n
preplace netloc qick_processor_0_m12_axis 1 5 1 850 2520n
preplace netloc qick_processor_0_m13_axis 1 5 1 860 2780n
preplace netloc qick_processor_0_m14_axis 1 5 1 870 3040n
preplace netloc qick_processor_0_m15_axis 1 5 1 -20 3280n
preplace netloc qick_processor_0_m1_axis 1 5 1 -20 -300n
preplace netloc qick_processor_0_m2_axis 1 5 1 -10 -40n
preplace netloc qick_processor_0_m3_axis 1 5 1 0 220n
preplace netloc qick_processor_0_m4_axis 1 5 1 10 480n
preplace netloc qick_processor_0_m5_axis 1 5 1 20 740n
preplace netloc qick_processor_0_m6_axis 1 5 1 30 1000n
preplace netloc qick_processor_0_m7_axis 1 5 1 790 1260n
preplace netloc qick_processor_0_m8_axis 1 5 1 800 1520n
preplace netloc qick_processor_0_m9_axis 1 5 1 820 1780n
preplace netloc qick_processor_0_m_dma_axis_o 1 3 3 -1150 -1380 N -1380 -40
preplace netloc sg_translator_0_m_int4_axis 1 6 1 N -540
preplace netloc sg_translator_10_m_int4_axis 1 6 1 N 2060
preplace netloc sg_translator_11_m_int4_axis 1 6 1 1770 2320n
preplace netloc sg_translator_12_m_gen_v6_axis 1 6 1 N 2540
preplace netloc sg_translator_13_m_gen_v6_axis 1 6 1 N 2800
preplace netloc sg_translator_14_m_gen_v6_axis 1 6 1 N 3060
preplace netloc sg_translator_15_m_mux4_axis 1 6 1 N 3380
preplace netloc sg_translator_1_m_int4_axis 1 6 1 1770 -280n
preplace netloc sg_translator_2_m_int4_axis 1 6 1 N -20
preplace netloc sg_translator_3_m_int4_axis 1 6 1 N 240
preplace netloc sg_translator_4_m_int4_axis 1 6 1 N 500
preplace netloc sg_translator_5_m_int4_axis 1 6 1 N 760
preplace netloc sg_translator_6_m_int4_axis 1 6 1 N 1020
preplace netloc sg_translator_7_m_int4_axis 1 6 1 N 1280
preplace netloc sg_translator_8_m_int4_axis 1 6 1 N 1540
preplace netloc sg_translator_9_m_int4_axis 1 6 1 N 1800
preplace netloc sysref_in_1 1 11 2 4340 -300 N
preplace netloc usp_rf_data_converter_0_m20_axis 1 0 13 -2720 -1200 N -1200 N -1200 N -1200 -380 -1230 N -1230 N -1230 N -1230 N -1230 N -1230 N -1230 4180 -1420 4670
preplace netloc usp_rf_data_converter_0_m22_axis 1 0 13 -2710 -1190 N -1190 N -1190 N -1190 -370 -1220 N -1220 1770 -1490 N -1490 N -1490 2950 -1540 N -1540 N -1540 4700
preplace netloc usp_rf_data_converter_0_vout00 1 12 1 N -1220
preplace netloc usp_rf_data_converter_0_vout01 1 12 1 N -1200
preplace netloc usp_rf_data_converter_0_vout02 1 12 1 N -1180
preplace netloc usp_rf_data_converter_0_vout03 1 12 1 N -1160
preplace netloc usp_rf_data_converter_0_vout10 1 12 1 N -1140
preplace netloc usp_rf_data_converter_0_vout11 1 12 1 N -1120
preplace netloc usp_rf_data_converter_0_vout12 1 12 1 N -1100
preplace netloc usp_rf_data_converter_0_vout13 1 12 1 N -1080
preplace netloc usp_rf_data_converter_0_vout20 1 12 1 N -1060
preplace netloc usp_rf_data_converter_0_vout21 1 12 1 N -1040
preplace netloc usp_rf_data_converter_0_vout22 1 12 1 N -1020
preplace netloc usp_rf_data_converter_0_vout23 1 12 1 N -1000
preplace netloc usp_rf_data_converter_0_vout30 1 12 1 N -980
preplace netloc usp_rf_data_converter_0_vout31 1 12 1 N -960
preplace netloc usp_rf_data_converter_0_vout32 1 12 1 N -940
preplace netloc usp_rf_data_converter_0_vout33 1 12 1 N -920
preplace netloc vin20_1 1 11 2 4360 -340 N
preplace netloc vin22_1 1 11 2 4350 -320 N
preplace netloc zynq_ultra_ps_e_0_M_AXI_HPM0_FPD 1 6 4 N -2600 N -2600 N -2600 3210
preplace netloc zynq_ultra_ps_e_0_M_AXI_HPM1_FPD 1 6 4 N -2580 N -2580 N -2580 3190
levelinfo -pg 1 -3040 -2590 -2130 -1480 -940 -200 1200 1980 2410 2760 3550 4070 4520 4740
pagesize -pg 1 -db -bbox -sgen -3110 -4390 6370 5780
"
}

  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


