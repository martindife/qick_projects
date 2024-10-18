module top
	(
		// Clock.
		input	wire			aclk		,

		// Enable input.
		input	wire			en			,

		// Output data.
		output	wire			dout_valid	,
		output	wire	[71:0]	dout		,

		// Registers.
		input	wire	[31:0]	PINC_REG	,
		input	wire	[31:0]	POFF_REG

	);

/***********/
/* Signals */
/***********/
reg				en_r1			;
reg				en_r2			;

wire			dout_valid_int	;
reg				dout_valid_r1	;
reg				dout_valid_r2	;

wire	[71:0]	dout_int		;
reg		[71:0]	dout_r1			;
reg		[71:0]	dout_r2			;

reg		[31:0]	PINC_REG_r1		;
reg		[31:0]	PINC_REG_r2		;
reg		[31:0]	POFF_REG_r1		;
reg		[31:0]	POFF_REG_r2		;

(* keep_hierarchy="true" *) dds_ctrl dds_ctrl_i
	(
		// Clock.
		.aclk		(aclk			),

		// Enable input.
		.en			(en_r2			),

		// Output data.
		.dout_valid	(dout_valid_int	),
		.dout		(dout_int		),

		// Registers.
		.PINC_REG	(PINC_REG_r2	),
		.POFF_REG	(POFF_REG_r2	)
	);

always @(posedge aclk) begin
	en_r1			<= en ;
	en_r2			<= en_r1 ;
	dout_valid_r1	<= dout_valid_int ;
	dout_valid_r2	<= dout_valid_r1 ;
	
	dout_r1			<= dout_int;
	dout_r2			<= dout_r1;
	
	PINC_REG_r1		<= PINC_REG;
	PINC_REG_r2		<= PINC_REG_r1;
	POFF_REG_r1		<= POFF_REG;
	POFF_REG_r2		<= POFF_REG_r1;
end

assign dout_valid 	= dout_valid_r2;
assign dout			= dout_r2	;

endmodule

