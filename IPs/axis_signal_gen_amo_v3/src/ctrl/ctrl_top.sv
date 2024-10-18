module ctrl_top
	#(
		// Number of bits for Time counter.
		parameter BT = 8
	)
	(
		// Reset and clock.
		input	wire			rstn		,
		input	wire			clk			,

		// Fifo interface.
		output	wire			fifo_rd_en	,
		input	wire			fifo_empty	,
		input	wire	[79:0]	fifo_dout	,

		// Phase sync.
		output	wire			phase_sync	,

		// Fifo fields.
		output	wire	[31:0]	addr_o		,
		output	wire	[7:0]	ctrl_o		,
		output	wire	[7:0]	qsel_o		,

		// Output time.
		output	wire			tout_valid	,
		output 	wire 	[BT-1:0]tout
	);

/*************/
/* Internals */
/*************/
// Start/busy flags.
wire			start_i			;
wire			busy_i			;

// Fifo fields.
wire	[31:0]	wait_i			;
wire	[7:0]	ctrl_int		;

// Internal phase sync.
wire			phase_sync_i	;

/****************/
/* Architecture */
/****************/

// Fifo control block.
ctrl ctrl_i
	(
		// Reset and clock.
		.rstn		(rstn		),
		.clk		(clk		),

		// Fifo interface.
		.fifo_rd_en	(fifo_rd_en	),
		.fifo_empty	(fifo_empty	),
		.fifo_dout	(fifo_dout	),

		// Start/busy flags.
		.start		(start_i	),
		.busy		(busy_i		),

		// Fifo fields.
		.addr_o		(addr_o		),
		.wait_o		(wait_i		),
		.ctrl_o		(ctrl_int	),
		.qsel_o		(qsel_o		)
	);

// Time control block.
time_ctrl
	#(
		.B(BT)
	)
	time_ctrl_i
	(
		// Reset and clock.
		.rstn		(rstn			),
		.clk		(clk			),
	
		// Start/busy flags.
		.start		(start_i		),
		.busy		(busy_i			),

		// Phase sync output.
		.sync		(phase_sync_i	),

		// Output time.
		.valid		(tout_valid		),
		.t_out		(tout			),

		// Registers.
		.WAIT_REG	(wait_i			)
	);

// Assign outputs.
assign phase_sync 	= phase_sync_i & ctrl_int[0];
assign ctrl_o		= ctrl_int;

endmodule

