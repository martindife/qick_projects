# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "SIM_LEVEL" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SIMPLEX" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "GEN_SYNC" -parent ${Page_0} -layout horizontal
  ipgui::add_param $IPINST -name "DEBUG" -parent ${Page_0} -layout horizontal


}

proc update_PARAM_VALUE.DEBUG { PARAM_VALUE.DEBUG } {
	# Procedure called to update DEBUG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEBUG { PARAM_VALUE.DEBUG } {
	# Procedure called to validate DEBUG
	return true
}

proc update_PARAM_VALUE.GEN_SYNC { PARAM_VALUE.GEN_SYNC } {
	# Procedure called to update GEN_SYNC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.GEN_SYNC { PARAM_VALUE.GEN_SYNC } {
	# Procedure called to validate GEN_SYNC
	return true
}

proc update_PARAM_VALUE.SIMPLEX { PARAM_VALUE.SIMPLEX } {
	# Procedure called to update SIMPLEX when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SIMPLEX { PARAM_VALUE.SIMPLEX } {
	# Procedure called to validate SIMPLEX
	return true
}

proc update_PARAM_VALUE.SIM_LEVEL { PARAM_VALUE.SIM_LEVEL } {
	# Procedure called to update SIM_LEVEL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SIM_LEVEL { PARAM_VALUE.SIM_LEVEL } {
	# Procedure called to validate SIM_LEVEL
	return true
}


proc update_MODELPARAM_VALUE.SIM_LEVEL { MODELPARAM_VALUE.SIM_LEVEL PARAM_VALUE.SIM_LEVEL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SIM_LEVEL}] ${MODELPARAM_VALUE.SIM_LEVEL}
}

proc update_MODELPARAM_VALUE.SIMPLEX { MODELPARAM_VALUE.SIMPLEX PARAM_VALUE.SIMPLEX } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SIMPLEX}] ${MODELPARAM_VALUE.SIMPLEX}
}

proc update_MODELPARAM_VALUE.GEN_SYNC { MODELPARAM_VALUE.GEN_SYNC PARAM_VALUE.GEN_SYNC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.GEN_SYNC}] ${MODELPARAM_VALUE.GEN_SYNC}
}

proc update_MODELPARAM_VALUE.DEBUG { MODELPARAM_VALUE.DEBUG PARAM_VALUE.DEBUG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEBUG}] ${MODELPARAM_VALUE.DEBUG}
}

