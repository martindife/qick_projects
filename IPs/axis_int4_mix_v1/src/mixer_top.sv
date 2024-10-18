module mixer_top (
	// Clock.
	input	wire				clk		,

	// Input.
	input	wire	[4*32-1:0]	din		,

	// Output.
	output	wire	[16*16-1:0]	dout	,

	// Registers.
	input	wire	[1:0]		MODE_REG
	);

/********************/
/* Internal signals */
/********************/

// Fir output/mixer input.
wire	[16*32-1:0]	fir_dout	;

/****************/
/* Architecture */
/****************/

// x4 terpolation + filter.
fir fir_i (
	.clk	(clk		),
	.din	(din		),
	.dout	(fir_dout	)
);

// Mixer.
mixer mixer_i (
	// Clock.
	.clk		(clk		),

	// Input.
	.din		(fir_dout	),

	// Output.
	.dout		(dout		),

	// Registers.
	.MODE_REG	(MODE_REG	)
	);

/***********/
/* Outputs */
/***********/

endmodule

