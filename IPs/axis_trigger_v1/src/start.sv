module start
	(
		// Reset and clock.
		input 	wire				aresetn			,
		input	wire				aclk			,

		// Start output.
		output 	wire				start			,

		// Registers.
		input	wire				START_REG
	);

/*************/
/* Internals */
/*************/
// Re-sync registers.
wire				START_REG_resync	;

/****************/
/* Architecture */
/****************/
// START_REG_resync.
synchronizer_n START_REG_resync_i
	(
		.rstn	    (aresetn			),
		.clk 		(aclk				),
		.data_in	(START_REG			),
		.data_out	(START_REG_resync	)
	);

// Assign outputs.
assign start = START_REG_resync;

endmodule

