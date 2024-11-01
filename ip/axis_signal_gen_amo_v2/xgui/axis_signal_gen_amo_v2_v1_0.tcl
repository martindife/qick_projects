# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "BT" -parent ${Page_0}


}

proc update_PARAM_VALUE.BAMP { PARAM_VALUE.BAMP } {
	# Procedure called to update BAMP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BAMP { PARAM_VALUE.BAMP } {
	# Procedure called to validate BAMP
	return true
}

proc update_PARAM_VALUE.BFREQ { PARAM_VALUE.BFREQ } {
	# Procedure called to update BFREQ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BFREQ { PARAM_VALUE.BFREQ } {
	# Procedure called to validate BFREQ
	return true
}

proc update_PARAM_VALUE.BT { PARAM_VALUE.BT } {
	# Procedure called to update BT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BT { PARAM_VALUE.BT } {
	# Procedure called to validate BT
	return true
}

proc update_PARAM_VALUE.NDDS { PARAM_VALUE.NDDS } {
	# Procedure called to update NDDS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NDDS { PARAM_VALUE.NDDS } {
	# Procedure called to validate NDDS
	return true
}

proc update_PARAM_VALUE.NREG { PARAM_VALUE.NREG } {
	# Procedure called to update NREG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NREG { PARAM_VALUE.NREG } {
	# Procedure called to validate NREG
	return true
}


proc update_MODELPARAM_VALUE.BT { MODELPARAM_VALUE.BT PARAM_VALUE.BT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BT}] ${MODELPARAM_VALUE.BT}
}

proc update_MODELPARAM_VALUE.NDDS { MODELPARAM_VALUE.NDDS PARAM_VALUE.NDDS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NDDS}] ${MODELPARAM_VALUE.NDDS}
}

proc update_MODELPARAM_VALUE.NREG { MODELPARAM_VALUE.NREG PARAM_VALUE.NREG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NREG}] ${MODELPARAM_VALUE.NREG}
}

proc update_MODELPARAM_VALUE.BFREQ { MODELPARAM_VALUE.BFREQ PARAM_VALUE.BFREQ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BFREQ}] ${MODELPARAM_VALUE.BFREQ}
}

proc update_MODELPARAM_VALUE.BAMP { MODELPARAM_VALUE.BAMP PARAM_VALUE.BAMP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BAMP}] ${MODELPARAM_VALUE.BAMP}
}

