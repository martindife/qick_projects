module top
	(
		// Clock.
		input	wire			aclk		,

		// Input valid.
		input	wire			din_valid	,

		// Output data.
		output	wire			dout_valid	,
		output	wire	[31:0]	dout		,

		// Registers.
		input	wire	[31:0]	PINC_REG	,
		input	wire	[31:0]	POFF_REG

	);

/***********/
/* Signals */
/***********/
reg				din_valid_r1	;
reg				din_valid_r2	;

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

dds_top dds_top_i
	(
		// Clock.
		.aclk		(aclk			),

		// Input valid.
		.din_valid	(din_valid_r2	),

		// Output data.
		.dout_valid	(dout_valid_int	),
		.dout		(dout_int		),

		// Registers.
		.PINC_REG	(PINC_REG_r2	),
		.POFF_REG	(POFF_REG_r2	)
	);

always @(posedge aclk) begin
	din_valid_r1	<= din_valid 		;
	din_valid_r2	<= din_valid_r1 	;
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

