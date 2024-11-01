
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


# The design that will be created by this Tcl script contains the following 
# module references:
# vect2bits_16

# Please add the sources of those modules before sourcing this Tcl script.

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
user.org:user:axis_set_reg:1.0\
user.org:user:axis_sg_int4_v1:1.0\
user.org:user:axis_sg_mux8_v1:1.0\
user.org:user:axis_signal_gen_v6:1.0\
user.org:user:axis_terminator:1.0\
user.org:user:axis_tmux_v1:1.0\
user.org:user:axis_tproc64x32_x8:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:axi_dma:7.1\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:axis_clock_converter:1.1\
xilinx.com:ip:axis_register_slice:1.1\
xilinx.com:ip:axis_switch:1.1\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:usp_rf_data_converter:2.6\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:zynq_ultra_ps_e:3.5\
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

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
vect2bits_16\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
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
  set_property CONFIG.FULLSPEED_OUTPUT {false} $axis_readout_v2_0


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


  # Create instance: axis_set_reg_0, and set properties
  set axis_set_reg_0 [ create_bd_cell -type ip -vlnv user.org:user:axis_set_reg:1.0 axis_set_reg_0 ]
  set_property CONFIG.DATA_WIDTH {160} $axis_set_reg_0


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


  # Create instance: axis_tmux_v1_0, and set properties
  set axis_tmux_v1_0 [ create_bd_cell -type ip -vlnv user.org:user:axis_tmux_v1:1.0 axis_tmux_v1_0 ]
  set_property -dict [list \
    CONFIG.B {160} \
    CONFIG.N {4} \
  ] $axis_tmux_v1_0


  # Create instance: axis_tmux_v1_1, and set properties
  set axis_tmux_v1_1 [ create_bd_cell -type ip -vlnv user.org:user:axis_tmux_v1:1.0 axis_tmux_v1_1 ]
  set_property -dict [list \
    CONFIG.B {160} \
    CONFIG.N {4} \
  ] $axis_tmux_v1_1


  # Create instance: axis_tmux_v1_2, and set properties
  set axis_tmux_v1_2 [ create_bd_cell -type ip -vlnv user.org:user:axis_tmux_v1:1.0 axis_tmux_v1_2 ]
  set_property CONFIG.B {160} $axis_tmux_v1_2


  # Create instance: axis_tmux_v1_3, and set properties
  set axis_tmux_v1_3 [ create_bd_cell -type ip -vlnv user.org:user:axis_tmux_v1:1.0 axis_tmux_v1_3 ]
  set_property CONFIG.B {160} $axis_tmux_v1_3


  # Create instance: axis_tmux_v1_4, and set properties
  set axis_tmux_v1_4 [ create_bd_cell -type ip -vlnv user.org:user:axis_tmux_v1:1.0 axis_tmux_v1_4 ]
  set_property CONFIG.B {160} $axis_tmux_v1_4


  # Create instance: axis_tproc64x32_x8_0, and set properties
  set axis_tproc64x32_x8_0 [ create_bd_cell -type ip -vlnv user.org:user:axis_tproc64x32_x8:1.0 axis_tproc64x32_x8_0 ]
  set_property -dict [list \
    CONFIG.DMEM_N {12} \
    CONFIG.PMEM_N {24} \
  ] $axis_tproc64x32_x8_0


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

  # Create instance: rst_tproc, and set properties
  set rst_tproc [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_tproc ]

  # Create instance: vect2bits_16_0, and set properties
  set block_name vect2bits_16
  set block_cell_name vect2bits_16_0
  if { [catch {set vect2bits_16_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $vect2bits_16_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {64} \
    CONFIG.SINGLE_PORT_BRAM {1} \
  ] $axi_bram_ctrl_0


  # Create instance: axi_bram_ctrl_0_bram, and set properties
  set axi_bram_ctrl_0_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 axi_bram_ctrl_0_bram ]
  set_property -dict [list \
    CONFIG.EN_SAFETY_CKT {false} \
    CONFIG.Enable_B {Use_ENB_Pin} \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.Port_B_Clock {100} \
    CONFIG.Port_B_Enable_Rate {100} \
    CONFIG.Port_B_Write_Rate {50} \
    CONFIG.Read_Width_B {64} \
    CONFIG.Use_RSTB_Pin {true} \
    CONFIG.Write_Width_B {64} \
  ] $axi_bram_ctrl_0_bram


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
    CONFIG.c_sg_length_width {26} \
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


  # Create instance: clk_tproc, and set properties
  set clk_tproc [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_tproc ]
  set_property -dict [list \
    CONFIG.CLKOUT1_JITTER {110.870} \
    CONFIG.CLKOUT1_PHASE_ERROR {153.875} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {350} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {23.625} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {3.375} \
    CONFIG.MMCM_DIVCLK_DIVIDE {2} \
    CONFIG.OPTIMIZE_CLOCKING_STRUCTURE_EN {false} \
    CONFIG.PRIM_SOURCE {Global_buffer} \
  ] $clk_tproc


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


  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {64} \
  ] $xlconstant_0


  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {1} \
    CONFIG.CONST_WIDTH {1} \
  ] $xlconstant_1


  # Create instance: xlconstant_2, and set properties
  set xlconstant_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_2 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {1} \
  ] $xlconstant_2


  # Create instance: xlconstant_3, and set properties
  set xlconstant_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_3 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {8} \
  ] $xlconstant_3


  # Create instance: xlconstant_5, and set properties
  set xlconstant_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_5 ]
  set_property CONFIG.CONST_VAL {0} $xlconstant_5


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


  # Create interface connections
  connect_bd_intf_net -intf_net adc2_clk_1 [get_bd_intf_ports adc2_clk] [get_bd_intf_pins usp_rf_data_converter_0/adc2_clk]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins axi_dma_gen/M_AXIS_MM2S] [get_bd_intf_pins axis_switch_gen/S00_AXIS]
  connect_bd_intf_net -intf_net axi_dma_avg_M_AXI_S2MM [get_bd_intf_pins axi_dma_avg/M_AXI_S2MM] [get_bd_intf_pins axi_smc_3/S00_AXI]
  connect_bd_intf_net -intf_net axi_dma_buf_M_AXI_S2MM [get_bd_intf_pins axi_dma_buf/M_AXI_S2MM] [get_bd_intf_pins axi_smc_3/S01_AXI]
  connect_bd_intf_net -intf_net axi_dma_gen_M_AXI_MM2S [get_bd_intf_pins axi_dma_gen/M_AXI_MM2S] [get_bd_intf_pins axi_smc_3/S02_AXI]
  connect_bd_intf_net -intf_net axi_dma_tproc_M_AXIS_MM2S [get_bd_intf_pins axi_dma_tproc/M_AXIS_MM2S] [get_bd_intf_pins axis_tproc64x32_x8_0/s0_axis]
  connect_bd_intf_net -intf_net axi_dma_tproc_M_AXI_MM2S [get_bd_intf_pins axi_dma_tproc/M_AXI_MM2S] [get_bd_intf_pins axi_smc_4/S00_AXI]
  connect_bd_intf_net -intf_net axi_dma_tproc_M_AXI_S2MM [get_bd_intf_pins axi_dma_tproc/M_AXI_S2MM] [get_bd_intf_pins axi_smc_4/S01_AXI]
  connect_bd_intf_net -intf_net axi_smc_0_M00_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins axi_smc_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_smc_0_M01_AXI [get_bd_intf_pins axi_dma_avg/S_AXI_LITE] [get_bd_intf_pins axi_smc_0/M01_AXI]
  connect_bd_intf_net -intf_net axi_smc_0_M02_AXI [get_bd_intf_pins axi_dma_buf/S_AXI_LITE] [get_bd_intf_pins axi_smc_0/M02_AXI]
  connect_bd_intf_net -intf_net axi_smc_0_M03_AXI [get_bd_intf_pins axi_dma_gen/S_AXI_LITE] [get_bd_intf_pins axi_smc_0/M03_AXI]
  connect_bd_intf_net -intf_net axi_smc_0_M04_AXI [get_bd_intf_pins axi_dma_tproc/S_AXI_LITE] [get_bd_intf_pins axi_smc_0/M04_AXI]
  connect_bd_intf_net -intf_net axi_smc_0_M05_AXI [get_bd_intf_pins axi_smc_0/M05_AXI] [get_bd_intf_pins axis_tproc64x32_x8_0/s_axi]
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
  connect_bd_intf_net -intf_net axis_cc_avg_0_M_AXIS [get_bd_intf_pins axis_cc_avg_0/M_AXIS] [get_bd_intf_pins axis_tproc64x32_x8_0/s1_axis]
  connect_bd_intf_net -intf_net axis_cc_avg_1_M_AXIS [get_bd_intf_pins axis_cc_avg_1/M_AXIS] [get_bd_intf_pins axis_tproc64x32_x8_0/s2_axis]
  connect_bd_intf_net -intf_net axis_cc_avg_2_M_AXIS [get_bd_intf_pins axis_cc_avg_2/M_AXIS] [get_bd_intf_pins axis_tproc64x32_x8_0/s3_axis]
  connect_bd_intf_net -intf_net axis_cc_avg_3_M_AXIS [get_bd_intf_pins axis_cc_avg_3/M_AXIS] [get_bd_intf_pins axis_tproc64x32_x8_0/s4_axis]
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
  connect_bd_intf_net -intf_net axis_tmux_v1_0_m0_axis [get_bd_intf_pins axis_clock_converter_8/S_AXIS] [get_bd_intf_pins axis_tmux_v1_0/m0_axis]
  connect_bd_intf_net -intf_net axis_tmux_v1_0_m1_axis [get_bd_intf_pins axis_clock_converter_9/S_AXIS] [get_bd_intf_pins axis_tmux_v1_0/m1_axis]
  connect_bd_intf_net -intf_net axis_tmux_v1_0_m2_axis [get_bd_intf_pins axis_clock_converter_10/S_AXIS] [get_bd_intf_pins axis_tmux_v1_0/m2_axis]
  connect_bd_intf_net -intf_net axis_tmux_v1_0_m3_axis [get_bd_intf_pins axis_clock_converter_11/S_AXIS] [get_bd_intf_pins axis_tmux_v1_0/m3_axis]
  connect_bd_intf_net -intf_net axis_tmux_v1_1_m0_axis [get_bd_intf_pins axis_clock_converter_0/S_AXIS] [get_bd_intf_pins axis_tmux_v1_1/m0_axis]
  connect_bd_intf_net -intf_net axis_tmux_v1_1_m1_axis [get_bd_intf_pins axis_clock_converter_1/S_AXIS] [get_bd_intf_pins axis_tmux_v1_1/m1_axis]
  connect_bd_intf_net -intf_net axis_tmux_v1_1_m2_axis [get_bd_intf_pins axis_clock_converter_2/S_AXIS] [get_bd_intf_pins axis_tmux_v1_1/m2_axis]
  connect_bd_intf_net -intf_net axis_tmux_v1_1_m3_axis [get_bd_intf_pins axis_clock_converter_3/S_AXIS] [get_bd_intf_pins axis_tmux_v1_1/m3_axis]
  connect_bd_intf_net -intf_net axis_tmux_v1_2_m0_axis [get_bd_intf_pins axis_clock_converter_4/S_AXIS] [get_bd_intf_pins axis_tmux_v1_2/m0_axis]
  connect_bd_intf_net -intf_net axis_tmux_v1_2_m1_axis [get_bd_intf_pins axis_clock_converter_5/S_AXIS] [get_bd_intf_pins axis_tmux_v1_2/m1_axis]
  connect_bd_intf_net -intf_net axis_tmux_v1_3_m0_axis [get_bd_intf_pins axis_clock_converter_6/S_AXIS] [get_bd_intf_pins axis_tmux_v1_3/m0_axis]
  connect_bd_intf_net -intf_net axis_tmux_v1_3_m1_axis [get_bd_intf_pins axis_clock_converter_7/S_AXIS] [get_bd_intf_pins axis_tmux_v1_3/m1_axis]
  connect_bd_intf_net -intf_net axis_tmux_v1_4_m0_axis [get_bd_intf_pins axis_clock_converter_15/S_AXIS] [get_bd_intf_pins axis_tmux_v1_4/m0_axis]
  connect_bd_intf_net -intf_net axis_tmux_v1_4_m1_axis [get_bd_intf_pins axis_clock_converter_14/S_AXIS] [get_bd_intf_pins axis_tmux_v1_4/m1_axis]
  connect_bd_intf_net -intf_net axis_tproc64x32_x8_0_m0_axis [get_bd_intf_pins axi_dma_tproc/S_AXIS_S2MM] [get_bd_intf_pins axis_tproc64x32_x8_0/m0_axis]
  connect_bd_intf_net -intf_net axis_tproc64x32_x8_0_m1_axis [get_bd_intf_pins axis_tmux_v1_0/s_axis] [get_bd_intf_pins axis_tproc64x32_x8_0/m1_axis]
  connect_bd_intf_net -intf_net axis_tproc64x32_x8_0_m2_axis [get_bd_intf_pins axis_tmux_v1_1/s_axis] [get_bd_intf_pins axis_tproc64x32_x8_0/m2_axis]
  connect_bd_intf_net -intf_net axis_tproc64x32_x8_0_m3_axis [get_bd_intf_pins axis_tmux_v1_2/s_axis] [get_bd_intf_pins axis_tproc64x32_x8_0/m3_axis]
  connect_bd_intf_net -intf_net axis_tproc64x32_x8_0_m4_axis [get_bd_intf_pins axis_tmux_v1_3/s_axis] [get_bd_intf_pins axis_tproc64x32_x8_0/m4_axis]
  connect_bd_intf_net -intf_net axis_tproc64x32_x8_0_m5_axis [get_bd_intf_pins axis_tmux_v1_4/s_axis] [get_bd_intf_pins axis_tproc64x32_x8_0/m5_axis]
  connect_bd_intf_net -intf_net axis_tproc64x32_x8_0_m6_axis [get_bd_intf_pins axis_clock_converter_13/S_AXIS] [get_bd_intf_pins axis_tproc64x32_x8_0/m6_axis]
  connect_bd_intf_net -intf_net axis_tproc64x32_x8_0_m7_axis [get_bd_intf_pins axis_clock_converter_12/S_AXIS] [get_bd_intf_pins axis_tproc64x32_x8_0/m7_axis]
  connect_bd_intf_net -intf_net axis_tproc64x32_x8_0_m8_axis [get_bd_intf_pins axis_set_reg_0/s_axis] [get_bd_intf_pins axis_tproc64x32_x8_0/m8_axis]
  connect_bd_intf_net -intf_net dac2_clk_1 [get_bd_intf_ports dac2_clk] [get_bd_intf_pins usp_rf_data_converter_0/dac2_clk]
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
  connect_bd_net -net Net2 [get_bd_pins rst_dac1/peripheral_aresetn] [get_bd_pins axis_sg_int4_v1_0/aresetn] [get_bd_pins axis_sg_int4_v1_1/aresetn] [get_bd_pins axis_sg_int4_v1_2/aresetn] [get_bd_pins axis_sg_int4_v1_3/aresetn] [get_bd_pins axis_clock_converter_0/m_axis_aresetn] [get_bd_pins axis_clock_converter_1/m_axis_aresetn] [get_bd_pins axis_clock_converter_2/m_axis_aresetn] [get_bd_pins axis_clock_converter_3/m_axis_aresetn] [get_bd_pins usp_rf_data_converter_0/s1_axis_aresetn]
  connect_bd_net -net Net4 [get_bd_pins usp_rf_data_converter_0/clk_dac1] [get_bd_pins axis_sg_int4_v1_0/aclk] [get_bd_pins axis_sg_int4_v1_1/aclk] [get_bd_pins axis_sg_int4_v1_2/aclk] [get_bd_pins axis_sg_int4_v1_3/aclk] [get_bd_pins rst_dac1/slowest_sync_clk] [get_bd_pins axis_clock_converter_0/m_axis_aclk] [get_bd_pins axis_clock_converter_1/m_axis_aclk] [get_bd_pins axis_clock_converter_2/m_axis_aclk] [get_bd_pins axis_clock_converter_3/m_axis_aclk] [get_bd_pins usp_rf_data_converter_0/s1_axis_aclk]
  connect_bd_net -net Net5 [get_bd_pins rst_dac3/peripheral_aresetn] [get_bd_pins axis_sg_int4_v1_10/aresetn] [get_bd_pins axis_sg_int4_v1_11/aresetn] [get_bd_pins axis_sg_int4_v1_8/aresetn] [get_bd_pins axis_sg_int4_v1_9/aresetn] [get_bd_pins axis_clock_converter_12/m_axis_aresetn] [get_bd_pins axis_clock_converter_13/m_axis_aresetn] [get_bd_pins axis_clock_converter_14/m_axis_aresetn] [get_bd_pins axis_clock_converter_15/m_axis_aresetn] [get_bd_pins usp_rf_data_converter_0/s3_axis_aresetn]
  connect_bd_net -net axi_bram_ctrl_0_bram_doutb [get_bd_pins axi_bram_ctrl_0_bram/doutb] [get_bd_pins axis_tproc64x32_x8_0/pmem_do]
  connect_bd_net -net axis_set_reg_0_dout [get_bd_pins axis_set_reg_0/dout] [get_bd_pins vect2bits_16_0/din]
  connect_bd_net -net axis_tproc64x32_x8_0_pmem_addr [get_bd_pins axis_tproc64x32_x8_0/pmem_addr] [get_bd_pins axi_bram_ctrl_0_bram/addrb]
  connect_bd_net -net clk_tproc_clk_out1 [get_bd_pins clk_tproc/clk_out1] [get_bd_pins axis_set_reg_0/s_axis_aclk] [get_bd_pins axis_tmux_v1_0/aclk] [get_bd_pins axis_tmux_v1_1/aclk] [get_bd_pins axis_tmux_v1_2/aclk] [get_bd_pins axis_tmux_v1_3/aclk] [get_bd_pins axis_tmux_v1_4/aclk] [get_bd_pins axis_tproc64x32_x8_0/aclk] [get_bd_pins rst_tproc/slowest_sync_clk] [get_bd_pins axi_bram_ctrl_0_bram/clkb] [get_bd_pins axis_cc_avg_0/m_axis_aclk] [get_bd_pins axis_cc_avg_1/m_axis_aclk] [get_bd_pins axis_cc_avg_2/m_axis_aclk] [get_bd_pins axis_cc_avg_3/m_axis_aclk] [get_bd_pins axis_clock_converter_0/s_axis_aclk] [get_bd_pins axis_clock_converter_10/s_axis_aclk] [get_bd_pins axis_clock_converter_11/s_axis_aclk] [get_bd_pins axis_clock_converter_12/s_axis_aclk] [get_bd_pins axis_clock_converter_13/s_axis_aclk] [get_bd_pins axis_clock_converter_14/s_axis_aclk] [get_bd_pins axis_clock_converter_15/s_axis_aclk] [get_bd_pins axis_clock_converter_1/s_axis_aclk] [get_bd_pins axis_clock_converter_2/s_axis_aclk] [get_bd_pins axis_clock_converter_3/s_axis_aclk] [get_bd_pins axis_clock_converter_4/s_axis_aclk] [get_bd_pins axis_clock_converter_5/s_axis_aclk] [get_bd_pins axis_clock_converter_6/s_axis_aclk] [get_bd_pins axis_clock_converter_7/s_axis_aclk] [get_bd_pins axis_clock_converter_8/s_axis_aclk] [get_bd_pins axis_clock_converter_9/s_axis_aclk]
  connect_bd_net -net clk_tproc_locked [get_bd_pins clk_tproc/locked] [get_bd_pins rst_tproc/dcm_locked]
  connect_bd_net -net rst_100_peripheral_aresetn [get_bd_pins rst_100/peripheral_aresetn] [get_bd_pins axis_avg_buffer_0/m_axis_aresetn] [get_bd_pins axis_avg_buffer_0/s_axi_aresetn] [get_bd_pins axis_avg_buffer_1/m_axis_aresetn] [get_bd_pins axis_avg_buffer_1/s_axi_aresetn] [get_bd_pins axis_avg_buffer_2/m_axis_aresetn] [get_bd_pins axis_avg_buffer_2/s_axi_aresetn] [get_bd_pins axis_avg_buffer_3/m_axis_aresetn] [get_bd_pins axis_avg_buffer_3/s_axi_aresetn] [get_bd_pins axis_avg_buffer_4/m_axis_aresetn] [get_bd_pins axis_avg_buffer_4/s_axi_aresetn] [get_bd_pins axis_pfb_readout_v3_0/s_axi_aresetn] [get_bd_pins axis_readout_v2_0/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_0/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_0/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_1/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_1/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_10/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_10/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_11/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_11/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_2/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_2/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_3/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_3/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_4/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_4/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_5/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_5/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_6/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_6/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_7/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_7/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_8/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_8/s_axi_aresetn] [get_bd_pins axis_sg_int4_v1_9/s0_axis_aresetn] [get_bd_pins axis_sg_int4_v1_9/s_axi_aresetn] [get_bd_pins axis_sg_mux8_v1_0/s_axi_aresetn] [get_bd_pins axis_signal_gen_v6_10/s0_axis_aresetn] [get_bd_pins axis_signal_gen_v6_10/s_axi_aresetn] [get_bd_pins axis_signal_gen_v6_8/s0_axis_aresetn] [get_bd_pins axis_signal_gen_v6_8/s_axi_aresetn] [get_bd_pins axis_signal_gen_v6_9/s0_axis_aresetn] [get_bd_pins axis_signal_gen_v6_9/s_axi_aresetn] [get_bd_pins axis_terminator_4/s_axis_aresetn] [get_bd_pins axis_tproc64x32_x8_0/m0_axis_aresetn] [get_bd_pins axis_tproc64x32_x8_0/s0_axis_aresetn] [get_bd_pins axis_tproc64x32_x8_0/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_dma_avg/axi_resetn] [get_bd_pins axi_dma_buf/axi_resetn] [get_bd_pins axi_dma_gen/axi_resetn] [get_bd_pins axi_dma_tproc/axi_resetn] [get_bd_pins axi_smc_0/aresetn] [get_bd_pins axi_smc_1/aresetn] [get_bd_pins axi_smc_2/aresetn] [get_bd_pins axi_smc_3/aresetn] [get_bd_pins axi_smc_4/aresetn] [get_bd_pins axis_cc_avg_0/s_axis_aresetn] [get_bd_pins axis_cc_avg_1/s_axis_aresetn] [get_bd_pins axis_cc_avg_2/s_axis_aresetn] [get_bd_pins axis_cc_avg_3/s_axis_aresetn] [get_bd_pins axis_switch_avg/aresetn] [get_bd_pins axis_switch_avg/s_axi_ctrl_aresetn] [get_bd_pins axis_switch_buf/aresetn] [get_bd_pins axis_switch_buf/s_axi_ctrl_aresetn] [get_bd_pins axis_switch_gen/aresetn] [get_bd_pins axis_switch_gen/s_axi_ctrl_aresetn] [get_bd_pins usp_rf_data_converter_0/s_axi_aresetn]
  connect_bd_net -net rst_100_peripheral_reset [get_bd_pins rst_100/peripheral_reset] [get_bd_pins clk_tproc/reset]
  connect_bd_net -net rst_adc2_peripheral_aresetn [get_bd_pins rst_adc2/peripheral_aresetn] [get_bd_pins axis_avg_buffer_0/s_axis_aresetn] [get_bd_pins axis_avg_buffer_1/s_axis_aresetn] [get_bd_pins axis_avg_buffer_2/s_axis_aresetn] [get_bd_pins axis_avg_buffer_3/s_axis_aresetn] [get_bd_pins axis_avg_buffer_4/s_axis_aresetn] [get_bd_pins axis_pfb_readout_v3_0/aresetn] [get_bd_pins axis_readout_v2_0/aresetn] [get_bd_pins usp_rf_data_converter_0/m2_axis_aresetn]
  connect_bd_net -net rst_dac1_peripheral_aresetn [get_bd_pins rst_dac2/peripheral_aresetn] [get_bd_pins axis_sg_int4_v1_4/aresetn] [get_bd_pins axis_sg_int4_v1_5/aresetn] [get_bd_pins axis_sg_int4_v1_6/aresetn] [get_bd_pins axis_sg_int4_v1_7/aresetn] [get_bd_pins axis_clock_converter_4/m_axis_aresetn] [get_bd_pins axis_clock_converter_5/m_axis_aresetn] [get_bd_pins axis_clock_converter_6/m_axis_aresetn] [get_bd_pins axis_clock_converter_7/m_axis_aresetn] [get_bd_pins usp_rf_data_converter_0/s2_axis_aresetn]
  connect_bd_net -net rst_tproc_peripheral_aresetn [get_bd_pins rst_tproc/peripheral_aresetn] [get_bd_pins axis_set_reg_0/s_axis_aresetn] [get_bd_pins axis_tmux_v1_0/aresetn] [get_bd_pins axis_tmux_v1_1/aresetn] [get_bd_pins axis_tmux_v1_2/aresetn] [get_bd_pins axis_tmux_v1_3/aresetn] [get_bd_pins axis_tmux_v1_4/aresetn] [get_bd_pins axis_tproc64x32_x8_0/aresetn] [get_bd_pins axis_cc_avg_0/m_axis_aresetn] [get_bd_pins axis_cc_avg_1/m_axis_aresetn] [get_bd_pins axis_cc_avg_2/m_axis_aresetn] [get_bd_pins axis_cc_avg_3/m_axis_aresetn] [get_bd_pins axis_clock_converter_0/s_axis_aresetn] [get_bd_pins axis_clock_converter_10/s_axis_aresetn] [get_bd_pins axis_clock_converter_11/s_axis_aresetn] [get_bd_pins axis_clock_converter_12/s_axis_aresetn] [get_bd_pins axis_clock_converter_13/s_axis_aresetn] [get_bd_pins axis_clock_converter_14/s_axis_aresetn] [get_bd_pins axis_clock_converter_15/s_axis_aresetn] [get_bd_pins axis_clock_converter_1/s_axis_aresetn] [get_bd_pins axis_clock_converter_2/s_axis_aresetn] [get_bd_pins axis_clock_converter_3/s_axis_aresetn] [get_bd_pins axis_clock_converter_4/s_axis_aresetn] [get_bd_pins axis_clock_converter_5/s_axis_aresetn] [get_bd_pins axis_clock_converter_6/s_axis_aresetn] [get_bd_pins axis_clock_converter_7/s_axis_aresetn] [get_bd_pins axis_clock_converter_8/s_axis_aresetn] [get_bd_pins axis_clock_converter_9/s_axis_aresetn]
  connect_bd_net -net usp_rf_data_converter_0_clk_adc2 [get_bd_pins usp_rf_data_converter_0/clk_adc2] [get_bd_pins axis_avg_buffer_0/s_axis_aclk] [get_bd_pins axis_avg_buffer_1/s_axis_aclk] [get_bd_pins axis_avg_buffer_2/s_axis_aclk] [get_bd_pins axis_avg_buffer_3/s_axis_aclk] [get_bd_pins axis_avg_buffer_4/s_axis_aclk] [get_bd_pins axis_pfb_readout_v3_0/aclk] [get_bd_pins axis_readout_v2_0/aclk] [get_bd_pins rst_adc2/slowest_sync_clk] [get_bd_pins usp_rf_data_converter_0/m2_axis_aclk]
  connect_bd_net -net usp_rf_data_converter_0_clk_dac2 [get_bd_pins usp_rf_data_converter_0/clk_dac2] [get_bd_pins axis_sg_int4_v1_4/aclk] [get_bd_pins axis_sg_int4_v1_5/aclk] [get_bd_pins axis_sg_int4_v1_6/aclk] [get_bd_pins axis_sg_int4_v1_7/aclk] [get_bd_pins rst_dac2/slowest_sync_clk] [get_bd_pins axis_clock_converter_4/m_axis_aclk] [get_bd_pins axis_clock_converter_5/m_axis_aclk] [get_bd_pins axis_clock_converter_6/m_axis_aclk] [get_bd_pins axis_clock_converter_7/m_axis_aclk] [get_bd_pins usp_rf_data_converter_0/s2_axis_aclk]
  connect_bd_net -net usp_rf_data_converter_0_clk_dac3 [get_bd_pins usp_rf_data_converter_0/clk_dac3] [get_bd_pins axis_sg_int4_v1_10/aclk] [get_bd_pins axis_sg_int4_v1_11/aclk] [get_bd_pins axis_sg_int4_v1_8/aclk] [get_bd_pins axis_sg_int4_v1_9/aclk] [get_bd_pins rst_dac3/slowest_sync_clk] [get_bd_pins axis_clock_converter_12/m_axis_aclk] [get_bd_pins axis_clock_converter_13/m_axis_aclk] [get_bd_pins axis_clock_converter_14/m_axis_aclk] [get_bd_pins axis_clock_converter_15/m_axis_aclk] [get_bd_pins usp_rf_data_converter_0/s3_axis_aclk]
  connect_bd_net -net vect2bits_16_0_dout9 [get_bd_pins vect2bits_16_0/dout9] [get_bd_pins axis_avg_buffer_0/trigger]
  connect_bd_net -net vect2bits_16_0_dout10 [get_bd_pins vect2bits_16_0/dout10] [get_bd_pins axis_avg_buffer_1/trigger]
  connect_bd_net -net vect2bits_16_0_dout11 [get_bd_pins vect2bits_16_0/dout11] [get_bd_pins axis_avg_buffer_2/trigger]
  connect_bd_net -net vect2bits_16_0_dout12 [get_bd_pins vect2bits_16_0/dout12] [get_bd_pins axis_avg_buffer_3/trigger]
  connect_bd_net -net vect2bits_16_0_dout13 [get_bd_pins vect2bits_16_0/dout13] [get_bd_pins axis_avg_buffer_4/trigger]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins xlconstant_0/dout] [get_bd_pins axi_bram_ctrl_0_bram/dinb]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins xlconstant_1/dout] [get_bd_pins axi_bram_ctrl_0_bram/enb]
  connect_bd_net -net xlconstant_2_dout [get_bd_pins xlconstant_2/dout] [get_bd_pins axi_bram_ctrl_0_bram/rstb]
  connect_bd_net -net xlconstant_3_dout [get_bd_pins xlconstant_3/dout] [get_bd_pins axi_bram_ctrl_0_bram/web]
  connect_bd_net -net xlconstant_5_dout [get_bd_pins xlconstant_5/dout] [get_bd_pins axis_tproc64x32_x8_0/start]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axis_avg_buffer_0/m_axis_aclk] [get_bd_pins axis_avg_buffer_0/s_axi_aclk] [get_bd_pins axis_avg_buffer_1/m_axis_aclk] [get_bd_pins axis_avg_buffer_1/s_axi_aclk] [get_bd_pins axis_avg_buffer_2/m_axis_aclk] [get_bd_pins axis_avg_buffer_2/s_axi_aclk] [get_bd_pins axis_avg_buffer_3/m_axis_aclk] [get_bd_pins axis_avg_buffer_3/s_axi_aclk] [get_bd_pins axis_avg_buffer_4/m_axis_aclk] [get_bd_pins axis_avg_buffer_4/s_axi_aclk] [get_bd_pins axis_pfb_readout_v3_0/s_axi_aclk] [get_bd_pins axis_readout_v2_0/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_0/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_0/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_1/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_1/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_10/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_10/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_11/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_11/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_2/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_2/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_3/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_3/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_4/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_4/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_5/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_5/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_6/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_6/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_7/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_7/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_8/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_8/s_axi_aclk] [get_bd_pins axis_sg_int4_v1_9/s0_axis_aclk] [get_bd_pins axis_sg_int4_v1_9/s_axi_aclk] [get_bd_pins axis_sg_mux8_v1_0/s_axi_aclk] [get_bd_pins axis_signal_gen_v6_10/s0_axis_aclk] [get_bd_pins axis_signal_gen_v6_10/s_axi_aclk] [get_bd_pins axis_signal_gen_v6_8/s0_axis_aclk] [get_bd_pins axis_signal_gen_v6_8/s_axi_aclk] [get_bd_pins axis_signal_gen_v6_9/s0_axis_aclk] [get_bd_pins axis_signal_gen_v6_9/s_axi_aclk] [get_bd_pins axis_terminator_4/s_axis_aclk] [get_bd_pins axis_tproc64x32_x8_0/m0_axis_aclk] [get_bd_pins axis_tproc64x32_x8_0/s0_axis_aclk] [get_bd_pins axis_tproc64x32_x8_0/s_axi_aclk] [get_bd_pins rst_100/slowest_sync_clk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_dma_avg/s_axi_lite_aclk] [get_bd_pins axi_dma_avg/m_axi_s2mm_aclk] [get_bd_pins axi_dma_buf/s_axi_lite_aclk] [get_bd_pins axi_dma_buf/m_axi_s2mm_aclk] [get_bd_pins axi_dma_gen/s_axi_lite_aclk] [get_bd_pins axi_dma_gen/m_axi_mm2s_aclk] [get_bd_pins axi_dma_tproc/s_axi_lite_aclk] [get_bd_pins axi_dma_tproc/m_axi_mm2s_aclk] [get_bd_pins axi_dma_tproc/m_axi_s2mm_aclk] [get_bd_pins axi_smc_0/aclk] [get_bd_pins axi_smc_1/aclk] [get_bd_pins axi_smc_2/aclk] [get_bd_pins axi_smc_3/aclk] [get_bd_pins axi_smc_4/aclk] [get_bd_pins axis_cc_avg_0/s_axis_aclk] [get_bd_pins axis_cc_avg_1/s_axis_aclk] [get_bd_pins axis_cc_avg_2/s_axis_aclk] [get_bd_pins axis_cc_avg_3/s_axis_aclk] [get_bd_pins axis_switch_avg/aclk] [get_bd_pins axis_switch_avg/s_axi_ctrl_aclk] [get_bd_pins axis_switch_buf/aclk] [get_bd_pins axis_switch_buf/s_axi_ctrl_aclk] [get_bd_pins axis_switch_gen/aclk] [get_bd_pins axis_switch_gen/s_axi_ctrl_aclk] [get_bd_pins clk_tproc/clk_in1] [get_bd_pins usp_rf_data_converter_0/s_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/maxihpm1_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/saxihpc0_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/saxihpc1_fpd_aclk]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_resetn0 [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins rst_100/ext_reset_in] [get_bd_pins rst_adc2/ext_reset_in] [get_bd_pins rst_dac0/ext_reset_in] [get_bd_pins rst_dac1/ext_reset_in] [get_bd_pins rst_dac2/ext_reset_in] [get_bd_pins rst_dac3/ext_reset_in] [get_bd_pins rst_tproc/ext_reset_in]

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
  assign_bd_address -offset 0xA0100000 -range 0x00100000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
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
  assign_bd_address -offset 0x000400000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axis_tproc64x32_x8_0/s_axi/reg0] -force
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
   "Default View_ScaleFactor":"0.0709459",
   "Default View_TopLeft":"-5638,-3439",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.5.8 2022-09-21 7111 VDI=41 GEI=38 GUI=JA:10.0 TLS
#  -string -flagsOSRD
preplace port adc2_clk -pg 1 -lvl 0 -x -520 -y 4900 -defaultsOSRD
preplace port dac2_clk -pg 1 -lvl 0 -x -520 -y 4920 -defaultsOSRD
preplace port sysref_in -pg 1 -lvl 0 -x -520 -y 5060 -defaultsOSRD
preplace port vin20 -pg 1 -lvl 0 -x -520 -y 5020 -defaultsOSRD
preplace port vin22 -pg 1 -lvl 0 -x -520 -y 5040 -defaultsOSRD
preplace port vout00 -pg 1 -lvl 13 -x 6060 -y 4820 -defaultsOSRD
preplace port vout01 -pg 1 -lvl 13 -x 6060 -y 4840 -defaultsOSRD
preplace port vout02 -pg 1 -lvl 13 -x 6060 -y 4860 -defaultsOSRD
preplace port vout03 -pg 1 -lvl 13 -x 6060 -y 4880 -defaultsOSRD
preplace port vout10 -pg 1 -lvl 13 -x 6060 -y 4900 -defaultsOSRD
preplace port vout11 -pg 1 -lvl 13 -x 6060 -y 4920 -defaultsOSRD
preplace port vout12 -pg 1 -lvl 13 -x 6060 -y 4940 -defaultsOSRD
preplace port vout13 -pg 1 -lvl 13 -x 6060 -y 4960 -defaultsOSRD
preplace port vout20 -pg 1 -lvl 13 -x 6060 -y 4980 -defaultsOSRD
preplace port vout21 -pg 1 -lvl 13 -x 6060 -y 5000 -defaultsOSRD
preplace port vout22 -pg 1 -lvl 13 -x 6060 -y 5020 -defaultsOSRD
preplace port vout23 -pg 1 -lvl 13 -x 6060 -y 5040 -defaultsOSRD
preplace port vout30 -pg 1 -lvl 13 -x 6060 -y 5060 -defaultsOSRD
preplace port vout31 -pg 1 -lvl 13 -x 6060 -y 5080 -defaultsOSRD
preplace port vout32 -pg 1 -lvl 13 -x 6060 -y 5100 -defaultsOSRD
preplace port vout33 -pg 1 -lvl 13 -x 6060 -y 5120 -defaultsOSRD
preplace inst axis_avg_buffer_0 -pg 1 -lvl 10 -x 4840 -y 1610 -defaultsOSRD -resize 220 236
preplace inst axis_avg_buffer_1 -pg 1 -lvl 10 -x 4840 -y 1880 -defaultsOSRD
preplace inst axis_avg_buffer_2 -pg 1 -lvl 10 -x 4840 -y 2140 -defaultsOSRD -resize 220 236
preplace inst axis_avg_buffer_3 -pg 1 -lvl 10 -x 4840 -y 2400 -defaultsOSRD -resize 220 236
preplace inst axis_avg_buffer_4 -pg 1 -lvl 10 -x 4840 -y 2660 -defaultsOSRD -resize 220 236
preplace inst axis_pfb_readout_v3_0 -pg 1 -lvl 9 -x 3930 -y 1970 -defaultsOSRD
preplace inst axis_readout_v2_0 -pg 1 -lvl 9 -x 3930 -y 1640 -defaultsOSRD
preplace inst axis_register_slice_0 -pg 1 -lvl 8 -x 3140 -y 3140 -defaultsOSRD
preplace inst axis_register_slice_1 -pg 1 -lvl 8 -x 3140 -y 3400 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_2 -pg 1 -lvl 8 -x 3140 -y 3660 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_3 -pg 1 -lvl 8 -x 3140 -y 3860 -defaultsOSRD -resize 180 116
preplace inst axis_set_reg_0 -pg 1 -lvl 4 -x 1250 -y 3990 -defaultsOSRD
preplace inst axis_sg_int4_v1_0 -pg 1 -lvl 7 -x 2720 -y -230 -defaultsOSRD -resize 220 236
preplace inst axis_sg_int4_v1_1 -pg 1 -lvl 7 -x 2720 -y 50 -defaultsOSRD
preplace inst axis_sg_int4_v1_2 -pg 1 -lvl 7 -x 2720 -y 340 -defaultsOSRD -resize 220 236
preplace inst axis_sg_int4_v1_3 -pg 1 -lvl 7 -x 2720 -y 600 -defaultsOSRD -resize 220 236
preplace inst axis_sg_int4_v1_4 -pg 1 -lvl 7 -x 2720 -y 860 -defaultsOSRD -resize 220 236
preplace inst axis_sg_int4_v1_5 -pg 1 -lvl 7 -x 2720 -y 1150 -defaultsOSRD -resize 220 236
preplace inst axis_sg_int4_v1_6 -pg 1 -lvl 7 -x 2720 -y 1410 -defaultsOSRD -resize 220 236
preplace inst axis_sg_int4_v1_7 -pg 1 -lvl 7 -x 2720 -y 1670 -defaultsOSRD -resize 220 236
preplace inst axis_sg_int4_v1_8 -pg 1 -lvl 7 -x 2720 -y 2800 -defaultsOSRD
preplace inst axis_sg_int4_v1_9 -pg 1 -lvl 7 -x 2720 -y 2020 -defaultsOSRD
preplace inst axis_sg_int4_v1_10 -pg 1 -lvl 7 -x 2720 -y 2540 -defaultsOSRD
preplace inst axis_sg_int4_v1_11 -pg 1 -lvl 7 -x 2720 -y 2280 -defaultsOSRD
preplace inst axis_sg_mux8_v1_0 -pg 1 -lvl 7 -x 2720 -y 3910 -defaultsOSRD
preplace inst axis_signal_gen_v6_8 -pg 1 -lvl 7 -x 2720 -y 3140 -defaultsOSRD
preplace inst axis_signal_gen_v6_9 -pg 1 -lvl 7 -x 2720 -y 3400 -defaultsOSRD -resize 220 236
preplace inst axis_signal_gen_v6_10 -pg 1 -lvl 7 -x 2720 -y 3660 -defaultsOSRD -resize 220 236
preplace inst axis_terminator_4 -pg 1 -lvl 11 -x 5470 -y 1650 -defaultsOSRD -resize 160 116
preplace inst axis_tmux_v1_0 -pg 1 -lvl 3 -x 540 -y -210 -defaultsOSRD
preplace inst axis_tmux_v1_1 -pg 1 -lvl 3 -x 540 -y -20 -defaultsOSRD -resize 180 136
preplace inst axis_tmux_v1_2 -pg 1 -lvl 3 -x 540 -y 150 -defaultsOSRD
preplace inst axis_tmux_v1_3 -pg 1 -lvl 3 -x 540 -y 310 -defaultsOSRD -resize 180 116
preplace inst axis_tmux_v1_4 -pg 1 -lvl 3 -x 540 -y 470 -defaultsOSRD -resize 180 116
preplace inst axis_tproc64x32_x8_0 -pg 1 -lvl 2 -x 140 -y 750 -defaultsOSRD
preplace inst rst_100 -pg 1 -lvl 4 -x 1250 -y -2590 -defaultsOSRD
preplace inst rst_adc2 -pg 1 -lvl 4 -x 1250 -y -2360 -defaultsOSRD -resize 320 156
preplace inst rst_dac0 -pg 1 -lvl 4 -x 1250 -y -2180 -defaultsOSRD -resize 320 156
preplace inst rst_dac1 -pg 1 -lvl 4 -x 1250 -y -2000 -defaultsOSRD -resize 320 156
preplace inst rst_dac2 -pg 1 -lvl 4 -x 1250 -y -1820 -defaultsOSRD -resize 320 156
preplace inst rst_dac3 -pg 1 -lvl 4 -x 1250 -y -1640 -defaultsOSRD
preplace inst rst_tproc -pg 1 -lvl 4 -x 1250 -y -1410 -defaultsOSRD -resize 320 156
preplace inst vect2bits_16_0 -pg 1 -lvl 8 -x 3140 -y 4130 -defaultsOSRD
preplace inst axi_bram_ctrl_0 -pg 1 -lvl 1 -x -280 -y 1010 -defaultsOSRD
preplace inst axi_bram_ctrl_0_bram -pg 1 -lvl 2 -x 140 -y 1180 -defaultsOSRD
preplace inst axi_dma_avg -pg 1 -lvl 12 -x 5850 -y 2910 -defaultsOSRD
preplace inst axi_dma_buf -pg 1 -lvl 12 -x 5850 -y 3330 -defaultsOSRD -resize 320 156
preplace inst axi_dma_gen -pg 1 -lvl 2 -x 140 -y -650 -defaultsOSRD
preplace inst axi_dma_tproc -pg 1 -lvl 2 -x 140 -y -290 -defaultsOSRD
preplace inst axi_smc_0 -pg 1 -lvl 7 -x 2720 -y -3360 -defaultsOSRD
preplace inst axi_smc_1 -pg 1 -lvl 7 -x 2720 -y -2190 -defaultsOSRD -resize 243 388
preplace inst axi_smc_2 -pg 1 -lvl 7 -x 2720 -y -1330 -defaultsOSRD -resize 253 347
preplace inst axi_smc_3 -pg 1 -lvl 3 -x 540 -y -3110 -defaultsOSRD
preplace inst axi_smc_4 -pg 1 -lvl 3 -x 540 -y -2880 -defaultsOSRD
preplace inst axis_cc_avg_0 -pg 1 -lvl 11 -x 5470 -y 1880 -defaultsOSRD -resize 220 156
preplace inst axis_cc_avg_1 -pg 1 -lvl 11 -x 5470 -y 2150 -defaultsOSRD -resize 220 156
preplace inst axis_cc_avg_2 -pg 1 -lvl 11 -x 5470 -y 2360 -defaultsOSRD -resize 220 156
preplace inst axis_cc_avg_3 -pg 1 -lvl 11 -x 5470 -y 2560 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_0 -pg 1 -lvl 4 -x 1250 -y -250 -defaultsOSRD
preplace inst axis_clock_converter_10 -pg 1 -lvl 4 -x 1250 -y 3610 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_11 -pg 1 -lvl 4 -x 1250 -y 3830 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_12 -pg 1 -lvl 4 -x 1250 -y 2620 -defaultsOSRD
preplace inst axis_clock_converter_13 -pg 1 -lvl 4 -x 1250 -y 2440 -defaultsOSRD
preplace inst axis_clock_converter_14 -pg 1 -lvl 4 -x 1250 -y 2260 -defaultsOSRD
preplace inst axis_clock_converter_15 -pg 1 -lvl 4 -x 1250 -y 2080 -defaultsOSRD
preplace inst axis_clock_converter_1 -pg 1 -lvl 4 -x 1250 -y -10 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_2 -pg 1 -lvl 4 -x 1250 -y 270 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_3 -pg 1 -lvl 4 -x 1250 -y 460 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_4 -pg 1 -lvl 4 -x 1250 -y 760 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_5 -pg 1 -lvl 4 -x 1250 -y 1030 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_6 -pg 1 -lvl 4 -x 1250 -y 1320 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_7 -pg 1 -lvl 4 -x 1250 -y 1640 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_8 -pg 1 -lvl 4 -x 1250 -y 3070 -defaultsOSRD -resize 220 156
preplace inst axis_clock_converter_9 -pg 1 -lvl 4 -x 1250 -y 3400 -defaultsOSRD -resize 220 156
preplace inst axis_register_slice_12 -pg 1 -lvl 5 -x 1760 -y 3810 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_13 -pg 1 -lvl 5 -x 1760 -y 3600 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_14 -pg 1 -lvl 5 -x 1760 -y 3400 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_15 -pg 1 -lvl 5 -x 1760 -y 3060 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_16 -pg 1 -lvl 6 -x 2020 -y 3070 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_17 -pg 1 -lvl 6 -x 2020 -y 3410 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_18 -pg 1 -lvl 6 -x 2020 -y 3600 -defaultsOSRD -resize 180 116
preplace inst axis_register_slice_19 -pg 1 -lvl 6 -x 2020 -y 3830 -defaultsOSRD -resize 180 116
preplace inst axis_switch_avg -pg 1 -lvl 11 -x 5470 -y 2890 -defaultsOSRD
preplace inst axis_switch_buf -pg 1 -lvl 11 -x 5470 -y 3310 -defaultsOSRD -resize 240 394
preplace inst axis_switch_gen -pg 1 -lvl 3 -x 540 -y -610 -defaultsOSRD
preplace inst clk_tproc -pg 1 -lvl 4 -x 1250 -y -1260 -defaultsOSRD
preplace inst usp_rf_data_converter_0 -pg 1 -lvl 9 -x 3930 -y 4982 -defaultsOSRD
preplace inst xlconstant_0 -pg 1 -lvl 1 -x -280 -y 1150 -defaultsOSRD
preplace inst xlconstant_1 -pg 1 -lvl 1 -x -280 -y 1260 -defaultsOSRD -resize 140 88
preplace inst xlconstant_2 -pg 1 -lvl 1 -x -280 -y 1400 -defaultsOSRD -resize 140 88
preplace inst xlconstant_3 -pg 1 -lvl 1 -x -280 -y 1510 -defaultsOSRD -resize 140 88
preplace inst xlconstant_5 -pg 1 -lvl 1 -x -280 -y 880 -defaultsOSRD
preplace inst zynq_ultra_ps_e_0 -pg 1 -lvl 4 -x 1250 -y -2890 -defaultsOSRD
preplace netloc Net 1 3 7 890 2970 1610 2980 1890 2990 2230 2990 3000J 3780 3420 4592 4080
preplace netloc Net1 1 3 6 930 2960 1640 3140 1910J 3150 2360 3000 2940 4982 3400
preplace netloc Net2 1 3 6 940 -380 1610 -380 N -380 2310 190 N 190 3530
preplace netloc Net4 1 3 7 900 -150 N -150 N -150 2290 200 N 200 3490 5370 4230
preplace netloc Net5 1 3 6 940 2720 1580 2140 N 2140 2350 2970 N 2970 3440
preplace netloc axi_bram_ctrl_0_bram_doutb 1 1 1 -70 900n
preplace netloc axis_set_reg_0_dout 1 4 4 NJ 3990 NJ 3990 2550J 4020 2900
preplace netloc axis_tproc64x32_x8_0_pmem_addr 1 1 2 -40 960 320
preplace netloc clk_tproc_clk_out1 1 1 10 -60 490 390 70 840 -1180 1590 -1550 N -1550 N -1550 N -1550 N -1550 N -1550 5330
preplace netloc clk_tproc_locked 1 3 2 940 -1190 1560
preplace netloc rst_100_peripheral_aresetn 1 0 12 -420 820 -120 -560 390J -1530 NJ -1530 1570 -1690 N -1690 2280 1880 N 1880 3690J 1510 4640J 1460 5230J 3040 5670
preplace netloc rst_100_peripheral_reset 1 3 2 930 -2490 1560
preplace netloc rst_adc2_peripheral_aresetn 1 4 6 NJ -2320 N -2320 2140 -2430 NJ -2430 3660 1500 4610
preplace netloc rst_dac1_peripheral_aresetn 1 3 6 930 860 1620J 860 NJ 860 2180 1860 N 1860 3480
preplace netloc rst_tproc_peripheral_aresetn 1 1 10 -40 470 370 -120 850 -370 1600 -370 N -370 N -370 N -370 NJ -370 NJ -370 5320
preplace netloc usp_rf_data_converter_0_clk_adc2 1 3 7 880 1810 N 1810 N 1810 N 1810 N 1810 3700 1750 4550
preplace netloc usp_rf_data_converter_0_clk_dac2 1 3 7 910 1470 N 1470 N 1470 2380 1820 N 1820 3470 5380 4130
preplace netloc usp_rf_data_converter_0_clk_dac3 1 3 7 920 2730 N 2730 N 2730 2310 2980 N 2980 3390 5390 4070
preplace netloc vect2bits_16_0_dout9 1 8 2 3510 1520 4680J
preplace netloc vect2bits_16_0_dout10 1 8 2 3550 1850 4650J
preplace netloc vect2bits_16_0_dout11 1 8 2 3580 2140 NJ
preplace netloc vect2bits_16_0_dout12 1 8 2 3600 2400 NJ
preplace netloc vect2bits_16_0_dout13 1 8 2 3630 2660 NJ
preplace netloc xlconstant_0_dout 1 1 1 -140 1150n
preplace netloc xlconstant_1_dout 1 1 1 -140 1220n
preplace netloc xlconstant_2_dout 1 1 1 -110 1240n
preplace netloc xlconstant_3_dout 1 1 1 -60 1260n
preplace netloc xlconstant_5_dout 1 1 1 N 880
preplace netloc zynq_ultra_ps_e_0_pl_clk0 1 0 12 -430 800 -130J -550 330J -2790 850J -2760 1570 -2860 N -2860 2270 1870 N 1870 3680J 1490 4670 1470 5220J 2740 5620J
preplace netloc zynq_ultra_ps_e_0_pl_resetn0 1 3 2 940 -2750 1560
preplace netloc adc2_clk_1 1 0 9 N 4900 N 4900 N 4900 N 4900 N 4900 N 4900 N 4900 2910 4992 N
preplace netloc axi_bram_ctrl_0_BRAM_PORTA 1 1 1 -140 1010n
preplace netloc axi_dma_0_M_AXIS_MM2S 1 2 1 N -660
preplace netloc axi_dma_avg_M_AXI_S2MM 1 2 11 320 -3220 N -3220 N -3220 N -3220 N -3220 N -3220 N -3220 N -3220 N -3220 N -3220 6030
preplace netloc axi_dma_buf_M_AXI_S2MM 1 2 11 400 -3210 NJ -3210 NJ -3210 N -3210 N -3210 NJ -3210 NJ -3210 NJ -3210 NJ -3210 NJ -3210 6040
preplace netloc axi_dma_gen_M_AXI_MM2S 1 2 1 320 -3110n
preplace netloc axi_dma_tproc_M_AXIS_MM2S 1 1 2 -50 -410 320
preplace netloc axi_dma_tproc_M_AXI_MM2S 1 2 1 340J -2910n
preplace netloc axi_dma_tproc_M_AXI_S2MM 1 2 1 380 -2890n
preplace netloc axi_smc_0_M00_AXI 1 0 8 -440 -3250 NJ -3250 NJ -3250 NJ -3250 NJ -3250 N -3250 N -3250 2870
preplace netloc axi_smc_0_M01_AXI 1 7 5 NJ -3390 NJ -3390 NJ -3390 NJ -3390 5670
preplace netloc axi_smc_0_M02_AXI 1 7 5 NJ -3370 NJ -3370 NJ -3370 NJ -3370 5660
preplace netloc axi_smc_0_M03_AXI 1 1 7 -60 -3010 NJ -3010 730J -3020 NJ -3020 N -3020 N -3020 3020
preplace netloc axi_smc_0_M04_AXI 1 1 7 -40 -3000 NJ -3000 820J -3010 NJ -3010 N -3010 N -3010 2880
preplace netloc axi_smc_0_M05_AXI 1 1 7 -110 -2770 N -2770 N -2770 N -2770 N -2770 N -2770 2900
preplace netloc axi_smc_1_M00_AXI 1 3 1 830 -3110n
preplace netloc axi_smc_1_M00_AXI1 1 6 2 2460 -1970 3020
preplace netloc axi_smc_1_M01_AXI 1 6 2 2410 -2420 2870
preplace netloc axi_smc_1_M02_AXI 1 6 2 2440 -2410 3010
preplace netloc axi_smc_1_M03_AXI 1 6 2 2490 -1960 3010
preplace netloc axi_smc_1_M04_AXI 1 6 2 2510 -1950 3000
preplace netloc axi_smc_1_M05_AXI 1 6 2 2520 -1940 2990
preplace netloc axi_smc_1_M06_AXI 1 6 2 2530 -1930 2980
preplace netloc axi_smc_1_M07_AXI 1 6 2 2540 -1920 2970
preplace netloc axi_smc_1_M08_AXI 1 6 2 2550 -1910 2960
preplace netloc axi_smc_1_M09_AXI 1 6 2 2560 -1900 2950
preplace netloc axi_smc_1_M10_AXI 1 6 2 2570 -1890 2940
preplace netloc axi_smc_1_M11_AXI 1 6 2 2420 -1880 2930
preplace netloc axi_smc_1_M12_AXI 1 6 2 2430 -1870 2920
preplace netloc axi_smc_1_M13_AXI 1 6 2 2450 -1860 2910
preplace netloc axi_smc_1_M14_AXI 1 6 2 2480 -1850 2890
preplace netloc axi_smc_1_M15_AXI 1 6 2 2500 -1840 2880
preplace netloc axi_smc_1_M16_AXI 1 7 3 NJ -2119 NJ -2119 4710
preplace netloc axi_smc_1_M17_AXI 1 7 3 NJ -2105 NJ -2105 4700
preplace netloc axi_smc_1_M18_AXI 1 7 3 NJ -2091 NJ -2091 4690
preplace netloc axi_smc_1_M19_AXI 1 7 3 NJ -2077 NJ -2077 4660
preplace netloc axi_smc_1_M20_AXI 1 7 3 NJ -2063 NJ -2063 4620
preplace netloc axi_smc_1_M21_AXI 1 7 2 NJ -2049 3780
preplace netloc axi_smc_1_M22_AXI 1 7 2 NJ -2035 3770
preplace netloc axi_smc_2_M00_AXI 1 3 1 730 -2930n
preplace netloc axi_smc_2_M00_AXI1 1 6 2 2470 -1530 2870
preplace netloc axi_smc_2_M03_AXI 1 7 4 N -1408 N -1408 N -1408 5310
preplace netloc axi_smc_2_M04_AXI 1 7 4 N -1389 N -1389 N -1389 5270
preplace netloc axi_smc_2_M05_AXI 1 2 6 400 -1540 N -1540 N -1540 N -1540 N -1540 2890
preplace netloc axi_smc_2_M06_AXI 1 7 2 N -1351 3760
preplace netloc axis_avg_buffer_0_m0_axis 1 10 1 5300 1590n
preplace netloc axis_avg_buffer_0_m1_axis 1 10 1 5260 1610n
preplace netloc axis_avg_buffer_0_m2_axis 1 10 1 5010 1840n
preplace netloc axis_avg_buffer_1_m0_axis 1 10 1 4990 1860n
preplace netloc axis_avg_buffer_1_m1_axis 1 10 1 5240 1880n
preplace netloc axis_avg_buffer_1_m2_axis 1 10 1 5250 2110n
preplace netloc axis_avg_buffer_2_m0_axis 1 10 1 5280 2120n
preplace netloc axis_avg_buffer_2_m1_axis 1 10 1 5010 2140n
preplace netloc axis_avg_buffer_2_m2_axis 1 10 1 5290 2320n
preplace netloc axis_avg_buffer_3_m0_axis 1 10 1 4980 2380n
preplace netloc axis_avg_buffer_3_m1_axis 1 10 1 5000 2400n
preplace netloc axis_avg_buffer_3_m2_axis 1 10 1 5290 2520n
preplace netloc axis_avg_buffer_4_m0_axis 1 10 1 5020 2640n
preplace netloc axis_avg_buffer_4_m1_axis 1 10 1 4970 2660n
preplace netloc axis_avg_buffer_4_m2_axis 1 10 1 N 1630
preplace netloc axis_cc_avg_0_M_AXIS 1 1 11 -100 -840 NJ -840 NJ -840 NJ -840 N -840 N -840 N -840 NJ -840 N -840 NJ -840 5610
preplace netloc axis_cc_avg_1_M_AXIS 1 1 11 -90 -830 NJ -830 NJ -830 NJ -830 N -830 N -830 N -830 NJ -830 N -830 NJ -830 5620
preplace netloc axis_cc_avg_2_M_AXIS 1 1 11 -80 -820 NJ -820 NJ -820 NJ -820 N -820 N -820 N -820 NJ -820 N -820 NJ -820 5630
preplace netloc axis_cc_avg_3_M_AXIS 1 1 11 -70 -810 NJ -810 NJ -810 NJ -810 N -810 N -810 N -810 NJ -810 N -810 NJ -810 5640
preplace netloc axis_clock_converter_0_M_AXIS 1 4 3 1610 -290 N -290 N
preplace netloc axis_clock_converter_10_M_AXIS 1 4 1 1650 3580n
preplace netloc axis_clock_converter_11_M_AXIS 1 4 1 1560 3790n
preplace netloc axis_clock_converter_12_M_AXIS 1 4 3 N 2620 N 2620 2130
preplace netloc axis_clock_converter_13_M_AXIS 1 4 3 N 2440 N 2440 2130
preplace netloc axis_clock_converter_14_M_AXIS 1 4 3 1610 2220 N 2220 N
preplace netloc axis_clock_converter_15_M_AXIS 1 4 3 1610 1960 N 1960 N
preplace netloc axis_clock_converter_1_M_AXIS 1 4 3 N -10 N -10 N
preplace netloc axis_clock_converter_2_M_AXIS 1 4 3 N 270 N 270 2330
preplace netloc axis_clock_converter_3_M_AXIS 1 4 3 N 460 N 460 2300
preplace netloc axis_clock_converter_4_M_AXIS 1 4 3 N 760 N 760 2260
preplace netloc axis_clock_converter_5_M_AXIS 1 4 3 N 1030 N 1030 2230
preplace netloc axis_clock_converter_6_M_AXIS 1 4 3 N 1320 N 1320 2200
preplace netloc axis_clock_converter_7_M_AXIS 1 4 3 1610 1610 N 1610 N
preplace netloc axis_clock_converter_8_M_AXIS 1 4 1 1650 3040n
preplace netloc axis_clock_converter_9_M_AXIS 1 4 1 1560 3380n
preplace netloc axis_pfb_readout_v3_0_m0_axis 1 9 1 4590 1800n
preplace netloc axis_pfb_readout_v3_0_m1_axis 1 9 1 4630 1960n
preplace netloc axis_pfb_readout_v3_0_m2_axis 1 9 1 4600 1980n
preplace netloc axis_pfb_readout_v3_0_m3_axis 1 9 1 4590 2000n
preplace netloc axis_readout_v2_1_m1_axis 1 9 1 4100 1530n
preplace netloc axis_register_slice_0_m_axis 1 8 1 3640 3140n
preplace netloc axis_register_slice_12_M_AXIS 1 5 1 N 3810
preplace netloc axis_register_slice_13_M_AXIS 1 5 1 1870 3580n
preplace netloc axis_register_slice_14_M_AXIS 1 5 1 1900 3390n
preplace netloc axis_register_slice_15_M_AXIS 1 5 1 1870 3050n
preplace netloc axis_register_slice_16_M_AXIS 1 6 1 2130 3070n
preplace netloc axis_register_slice_17_M_AXIS 1 6 1 2320 3340n
preplace netloc axis_register_slice_18_M_AXIS 1 6 1 N 3600
preplace netloc axis_register_slice_19_M_AXIS 1 6 1 2130 3830n
preplace netloc axis_register_slice_1_m_axis 1 8 1 3610 3400n
preplace netloc axis_register_slice_2_m_axis 1 8 1 3590 3660n
preplace netloc axis_register_slice_3_m_axis 1 8 1 3560 3860n
preplace netloc axis_sg_int4_v1_0_m_axis 1 7 2 N -230 3750
preplace netloc axis_sg_int4_v1_10_m_axis 1 7 2 N 2540 3520
preplace netloc axis_sg_int4_v1_11_m_axis 1 7 2 N 2280 3540
preplace netloc axis_sg_int4_v1_1_m_axis 1 7 2 N 50 3740
preplace netloc axis_sg_int4_v1_2_m_axis 1 7 2 N 340 3730
preplace netloc axis_sg_int4_v1_3_m_axis 1 7 2 N 600 3720
preplace netloc axis_sg_int4_v1_4_m_axis 1 7 2 N 860 3710
preplace netloc axis_sg_int4_v1_5_m_axis 1 7 2 N 1150 3670
preplace netloc axis_sg_int4_v1_6_m_axis 1 7 2 N 1410 3650
preplace netloc axis_sg_int4_v1_7_m_axis 1 7 2 N 1670 3620
preplace netloc axis_sg_int4_v1_8_m_axis 1 7 2 N 2800 3500
preplace netloc axis_sg_int4_v1_9_m_axis 1 7 2 N 2020 3570
preplace netloc axis_sg_mux8_v1_0_m_axis 1 7 1 2980 3840n
preplace netloc axis_signal_gen_v6_10_m_axis 1 7 1 2980 3640n
preplace netloc axis_signal_gen_v6_8_m_axis 1 7 1 2900 3120n
preplace netloc axis_signal_gen_v6_9_m_axis 1 7 1 2880 3380n
preplace netloc axis_switch_avg_M00_AXIS 1 11 1 N 2890
preplace netloc axis_switch_buf_M00_AXIS 1 11 1 N 3310
preplace netloc axis_switch_gen_M00_AXIS 1 3 4 N -750 N -750 N -750 2400
preplace netloc axis_switch_gen_M01_AXIS 1 3 4 N -730 N -730 N -730 2390
preplace netloc axis_switch_gen_M02_AXIS 1 3 4 N -710 N -710 N -710 2380
preplace netloc axis_switch_gen_M03_AXIS 1 3 4 N -690 N -690 N -690 2370
preplace netloc axis_switch_gen_M04_AXIS 1 3 4 N -670 N -670 N -670 2360
preplace netloc axis_switch_gen_M05_AXIS 1 3 4 N -650 N -650 N -650 2350
preplace netloc axis_switch_gen_M06_AXIS 1 3 4 N -630 N -630 N -630 2340
preplace netloc axis_switch_gen_M07_AXIS 1 3 4 N -610 N -610 N -610 2320
preplace netloc axis_switch_gen_M08_AXIS 1 3 4 N -590 N -590 N -590 2210
preplace netloc axis_switch_gen_M09_AXIS 1 3 4 N -570 N -570 N -570 2150
preplace netloc axis_switch_gen_M10_AXIS 1 3 4 N -550 N -550 N -550 2140
preplace netloc axis_switch_gen_M11_AXIS 1 3 4 N -530 N -530 N -530 2250
preplace netloc axis_switch_gen_M12_AXIS 1 3 4 N -510 N -510 N -510 2240
preplace netloc axis_switch_gen_M13_AXIS 1 3 4 N -490 N -490 N -490 2220
preplace netloc axis_switch_gen_M14_AXIS 1 3 4 N -470 N -470 N -470 2190
preplace netloc axis_tmux_v1_0_m0_axis 1 3 1 790 -240n
preplace netloc axis_tmux_v1_0_m1_axis 1 3 1 770 -220n
preplace netloc axis_tmux_v1_0_m2_axis 1 3 1 750 -200n
preplace netloc axis_tmux_v1_0_m3_axis 1 3 1 730 -180n
preplace netloc axis_tmux_v1_1_m0_axis 1 3 1 800 -290n
preplace netloc axis_tmux_v1_1_m1_axis 1 3 1 810 -50n
preplace netloc axis_tmux_v1_1_m2_axis 1 3 1 870 -10n
preplace netloc axis_tmux_v1_1_m3_axis 1 3 1 800 10n
preplace netloc axis_tmux_v1_2_m0_axis 1 3 1 860 140n
preplace netloc axis_tmux_v1_2_m1_axis 1 3 1 780 160n
preplace netloc axis_tmux_v1_3_m0_axis 1 3 1 760 300n
preplace netloc axis_tmux_v1_3_m1_axis 1 3 1 740 320n
preplace netloc axis_tmux_v1_4_m0_axis 1 3 1 720 460n
preplace netloc axis_tmux_v1_4_m1_axis 1 3 1 710 480n
preplace netloc axis_tproc64x32_x8_0_m0_axis 1 1 2 -60 -420 330
preplace netloc axis_tproc64x32_x8_0_m1_axis 1 2 1 340 -230n
preplace netloc axis_tproc64x32_x8_0_m2_axis 1 2 1 350 -40n
preplace netloc axis_tproc64x32_x8_0_m3_axis 1 2 1 360 130n
preplace netloc axis_tproc64x32_x8_0_m4_axis 1 2 1 380 290n
preplace netloc axis_tproc64x32_x8_0_m5_axis 1 2 1 400 450n
preplace netloc axis_tproc64x32_x8_0_m6_axis 1 2 2 N 780 700
preplace netloc axis_tproc64x32_x8_0_m7_axis 1 2 2 N 800 690
preplace netloc axis_tproc64x32_x8_0_m8_axis 1 2 2 NJ 820 680J
preplace netloc dac2_clk_1 1 0 9 N 4920 N 4920 N 4920 N 4920 N 4920 N 4920 N 4920 2880 5002 3460
preplace netloc sysref_in_1 1 0 9 N 5060 N 5060 N 5060 N 5060 N 5060 N 5060 N 5060 N 5060 3410
preplace netloc usp_rf_data_converter_0_m20_axis 1 8 2 3790 1530 4090
preplace netloc usp_rf_data_converter_0_m22_axis 1 8 2 3790 1860 4070
preplace netloc usp_rf_data_converter_0_vout00 1 9 4 4710 4820 N 4820 N 4820 N
preplace netloc usp_rf_data_converter_0_vout01 1 9 4 4700 4840 N 4840 N 4840 N
preplace netloc usp_rf_data_converter_0_vout02 1 9 4 4690 4860 N 4860 N 4860 N
preplace netloc usp_rf_data_converter_0_vout03 1 9 4 4680 4880 N 4880 N 4880 N
preplace netloc usp_rf_data_converter_0_vout10 1 9 4 4670 4900 N 4900 N 4900 N
preplace netloc usp_rf_data_converter_0_vout11 1 9 4 4660 4920 N 4920 N 4920 N
preplace netloc usp_rf_data_converter_0_vout12 1 9 4 4650 4940 N 4940 N 4940 N
preplace netloc usp_rf_data_converter_0_vout13 1 9 4 4640 4960 N 4960 N 4960 N
preplace netloc usp_rf_data_converter_0_vout20 1 9 4 4630 4980 N 4980 N 4980 N
preplace netloc usp_rf_data_converter_0_vout21 1 9 4 4620 5000 N 5000 N 5000 N
preplace netloc usp_rf_data_converter_0_vout22 1 9 4 4610 5020 N 5020 N 5020 N
preplace netloc usp_rf_data_converter_0_vout23 1 9 4 4600 5040 N 5040 N 5040 N
preplace netloc usp_rf_data_converter_0_vout30 1 9 4 4590 5060 N 5060 N 5060 N
preplace netloc usp_rf_data_converter_0_vout31 1 9 4 4580 5080 N 5080 N 5080 N
preplace netloc usp_rf_data_converter_0_vout32 1 9 4 4570 5100 N 5100 N 5100 N
preplace netloc usp_rf_data_converter_0_vout33 1 9 4 4560 5120 N 5120 N 5120 N
preplace netloc vin20_1 1 0 9 N 5020 N 5020 N 5020 N 5020 N 5020 N 5020 N 5020 N 5020 3450
preplace netloc vin22_1 1 0 9 N 5040 N 5040 N 5040 N 5040 N 5040 N 5040 N 5040 N 5040 3430
preplace netloc zynq_ultra_ps_e_0_M_AXI_HPM0_FPD 1 4 3 1560 -3380 N -3380 N
preplace netloc zynq_ultra_ps_e_0_M_AXI_HPM1_FPD 1 4 3 N -2900 N -2900 2400
levelinfo -pg 1 -520 -280 140 540 1250 1760 2020 2720 3140 3930 4840 5470 5850 6060
pagesize -pg 1 -db -bbox -sgen -640 -4330 6160 5780
"
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


common::send_gid_msg -ssname BD::TCL -id 2053 -severity "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."

