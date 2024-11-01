# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "TDATA_DW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TDATA_QTY" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TUSER_DW" -parent ${Page_0}


}

proc update_PARAM_VALUE.TDATA_DW { PARAM_VALUE.TDATA_DW } {
	# Procedure called to update TDATA_DW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TDATA_DW { PARAM_VALUE.TDATA_DW } {
	# Procedure called to validate TDATA_DW
	return true
}

proc update_PARAM_VALUE.TDATA_QTY { PARAM_VALUE.TDATA_QTY } {
	# Procedure called to update TDATA_QTY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TDATA_QTY { PARAM_VALUE.TDATA_QTY } {
	# Procedure called to validate TDATA_QTY
	return true
}

proc update_PARAM_VALUE.TUSER_DW { PARAM_VALUE.TUSER_DW } {
	# Procedure called to update TUSER_DW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TUSER_DW { PARAM_VALUE.TUSER_DW } {
	# Procedure called to validate TUSER_DW
	return true
}


proc update_MODELPARAM_VALUE.TDATA_DW { MODELPARAM_VALUE.TDATA_DW PARAM_VALUE.TDATA_DW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TDATA_DW}] ${MODELPARAM_VALUE.TDATA_DW}
}

proc update_MODELPARAM_VALUE.TDATA_QTY { MODELPARAM_VALUE.TDATA_QTY PARAM_VALUE.TDATA_QTY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TDATA_QTY}] ${MODELPARAM_VALUE.TDATA_QTY}
}

proc update_MODELPARAM_VALUE.TUSER_DW { MODELPARAM_VALUE.TUSER_DW PARAM_VALUE.TUSER_DW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TUSER_DW}] ${MODELPARAM_VALUE.TUSER_DW}
}

