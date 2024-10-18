# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AXIS_IN_DW" -parent ${Page_0}


}

proc update_PARAM_VALUE.AXIS_IN_DW { PARAM_VALUE.AXIS_IN_DW } {
	# Procedure called to update AXIS_IN_DW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIS_IN_DW { PARAM_VALUE.AXIS_IN_DW } {
	# Procedure called to validate AXIS_IN_DW
	return true
}


proc update_MODELPARAM_VALUE.AXIS_IN_DW { MODELPARAM_VALUE.AXIS_IN_DW PARAM_VALUE.AXIS_IN_DW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIS_IN_DW}] ${MODELPARAM_VALUE.AXIS_IN_DW}
}

