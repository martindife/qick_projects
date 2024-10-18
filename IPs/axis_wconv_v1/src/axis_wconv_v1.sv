module axis_wconv_v1
	(
		// Reset and clock.
		input	wire			aresetn			,
		input	wire			aclk			,

		// S_AXIS for input data.
		input	wire 			s_axis_tvalid	,
		input	wire 	[191:0]	s_axis_tdata	,

		// M_AXIS for output data.
		output	wire			m_axis_tvalid	,
		output	wire	[255:0]	m_axis_tdata
	);

/**********************/
/* Begin Architecture */
/**********************/
wconv wconv_i
	(
		// Reset and clock.
		.aresetn		(aresetn		),
		.aclk			(aclk			),

		// S_AXIS for input data.
		.s_axis_tvalid	(s_axis_tvalid	),
		.s_axis_tdata	(s_axis_tdata	),

		// M_AXIS for output data.
		.m_axis_tvalid	(m_axis_tvalid	),
		.m_axis_tdata	(m_axis_tdata	)
	);

endmodule

