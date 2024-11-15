# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

puts "###############################################################"
puts "QICK PROCESSOR DESIGN"
puts "###############################################################"
puts "Directory Structure"
puts "/IPs/qick_processor     > Qick IP Block"
puts "/Projects/22.1/IP_design  > Run script and generate Project"
puts "###############################################################"

set ip_path  "$origin_dir/../../../IPs/qick_processor/"
set src_path "$origin_dir/../../../IPs/qick_processor/src/"
set tb_path  "$origin_dir/../../../IPs/qick_processor/src/TB/"


# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

# Set the project name
set _xil_proj_name_ "IP_qick_processor"

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"

# Create project
create_project ${_xil_proj_name_} ./${_xil_proj_name_} -part xczu49dr-ffvf1760-2-e

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]
set_property -name "board_part" -value "xilinx.com:zcu216:part0:2.0" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/${_xil_proj_name_}.cache/ip" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
set_property -name "platform.board_id" -value "zcu216" -objects $obj
set_property -name "sim.central_dir" -value "$proj_dir/${_xil_proj_name_}.ip_user_files" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj


puts "###############################################################"
puts "LOAD SOURCE FILES"
puts "###############################################################"

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]

set header_files [glob -nocomplain -directory ${src_path} *.svh] ;
set sverilog_files [glob -nocomplain -directory ${src_path} *.sv] ;
set verilog_files  [glob -nocomplain -directory ${src_path} *.v] ;
set vhdl_files     [glob -nocomplain -directory ${src_path} *.vhd] ;

if {$header_files   != ""} { add_files -norecurse -fileset $obj $header_files }
if {$sverilog_files != ""} { add_files -norecurse -fileset $obj $sverilog_files }
if {$verilog_files  != ""} { add_files -norecurse -fileset $obj $verilog_files }
if {$vhdl_files     != ""} { add_files -norecurse -fileset $obj $vhdl_files }

puts "###############################################################"
puts "ADD IPS "
puts "###############################################################"
#### DSP
set dsp_file       [glob -nocomplain ${src_path}dsp_macro_0/dsp_macro_0.xci]
add_files -norecurse -fileset $obj $dsp_file

set file_obj [get_files -of_objects [get_filesets sources_1] [list "$dsp_file"]]
set_property -name "generate_files_for_reference" -value "0" -objects $file_obj
if { ![get_property "is_locked" $file_obj] } {
  set_property -name "generate_synth_checkpoint" -value "0" -objects $file_obj
}
set_property -name "registered_with_manager" -value "1" -objects $file_obj


## Component File 
set xml_file       [glob -nocomplain ${ip_path}component.xml] ;
if {$xml_file       != ""} { add_files -norecurse -fileset $obj $xml_file }
set_property file_type IP-XACT [get_files  $xml_file]

puts "###############################################################"
puts "LOAD SIM FILES"
puts "###############################################################"
set obj [get_filesets sim_1]

# Set 'sim_1' fileset object
set sim_files     [glob -nocomplain -directory ${tb_path} *.sv] ;
set bin_files     [glob -nocomplain -directory ${tb_path} *.bin] ;
set wcfg_files    [glob -nocomplain -directory ${tb_path} *.wcfg] ;

if {$sim_files  != ""} { add_files -norecurse -fileset $obj $sim_files }
if {$bin_files  != ""} { add_files -norecurse -fileset $obj $bin_files }
if {$wcfg_files != ""} { add_files -norecurse -fileset $obj $wcfg_files }


set axi_file      [glob -nocomplain "$origin_dir/../../../IPs/_TEST/axi_mst_0/axi_mst_0.xci"]
if {$axi_file   != ""} { add_files -norecurse -fileset $obj $axi_file }

set file_obj [get_files -of_objects [get_filesets sim_1] [list "$axi_file"]]
set_property -name "generate_files_for_reference" -value "0" -objects $file_obj
if { ![get_property "is_locked" $file_obj] } {
  set_property -name "is_locked" -value "1" -objects $file_obj
}
set_property -name "registered_with_manager" -value "1" -objects $file_obj


set_property file_type {Memory File} [get_files  $bin_files]


upgrade_ip [get_ips]
