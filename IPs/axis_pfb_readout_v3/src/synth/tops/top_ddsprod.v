module top
	(
		// Clock.
		input	wire			aclk			,

		// S_AXIS for input data.
		input	wire			s_axis_tvalid	,
		input	wire	[31:0]	s_axis_tdata	,

		// M_AXIS for output data.
		output	wire			m_axis_tvalid	,
		output	wire	[31:0]	m_axis_tdata	,

		// Registers.
		input	wire	[31:0]	PINC_REG		,
		input	wire	[31:0]	POFF_REG

	);

/***********/
/* Signals */
/***********/
reg				din_valid_r1	;
reg				din_valid_r2	;
reg		[31:0]	din_r1			;
reg		[31:0]	din_r2			;

wire			dout_valid_int	;
reg				dout_valid_r1	;
reg				dout_valid_r2	;

wire	[31:0]	dout_int		;
reg		[31:0]	dout_r1			;
reg		[31:0]	dout_r2			;

reg		[31:0]	PINC_REG_r1		;
reg		[31:0]	PINC_REG_r2		;
reg		[31:0]	POFF_REG_r1		;
reg		[31:0]	POFF_REG_r2		;

ddsprod ddsprod_i
	(
		// Clock.
		.aclk			(aclk			),

		// S_AXIS for input data.
		.s_axis_tvalid	(din_valid_r2	),
		.s_axis_tdata	(din_r2			),

		// Output data.
		.m_axis_tvalid	(dout_valid_int	),
		.m_axis_tdata	(dout_int		),

		// Registers.
		.PINC_REG		(PINC_REG_r2	),
		.POFF_REG		(POFF_REG_r2	)
	);

always @(posedge aclk) begin
	din_valid_r1	<= s_axis_tvalid	;
	din_valid_r2	<= din_valid_r1 	;
	din_r1			<= s_axis_tdata		;
	din_r2			<= din_r1			;

	dout_valid_r1	<= dout_valid_int 	;
	dout_valid_r2	<= dout_valid_r1 	;
	dout_r1			<= dout_int			;
	dout_r2			<= dout_r1			;
	
	PINC_REG_r1		<= PINC_REG			;
	PINC_REG_r2		<= PINC_REG_r1		;
	POFF_REG_r1		<= POFF_REG			;
	POFF_REG_r2		<= POFF_REG_r1		;
end

assign dout_valid 	= dout_valid_r2	;
assign dout			= dout_r2		;

endmodule

