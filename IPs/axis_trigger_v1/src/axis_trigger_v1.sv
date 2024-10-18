module axis_trigger_v1
	( 	
		// AXI Slave I/F for configuration.
		input wire  				s_axi_aclk		,
		input wire  				s_axi_aresetn	,

		input wire [7:0]			s_axi_awaddr	,
		input wire [2:0]			s_axi_awprot	,
		input wire  				s_axi_awvalid	,
		output wire  				s_axi_awready	,

		input wire [31:0] 			s_axi_wdata		,
		input wire [3:0]			s_axi_wstrb		,
		input wire  				s_axi_wvalid	,
		output wire  				s_axi_wready	,

		output wire [1:0]			s_axi_bresp		,
		output wire  				s_axi_bvalid	,
		input wire  				s_axi_bready	,

		input wire [7:0] 			s_axi_araddr	,
		input wire [2:0] 			s_axi_arprot	,
		input wire  				s_axi_arvalid	,
		output wire  				s_axi_arready	,

		output wire [31:0] 			s_axi_rdata		,
		output wire [1:0]			s_axi_rresp		,
		output wire  				s_axi_rvalid	,
		input wire  				s_axi_rready	,

		// Reset and clock for axis_*
		input 	wire 				aresetn			,
		input 	wire 				aclk			,

		// Start output.
		output wire					start			,

		// Trigger output.
		output wire					trigger

	);

/********************/
/* Internal signals */
/********************/
// Registers.
wire		START_REG	;
wire [15:0]	WIDTH0_REG	;
wire [15:0]	WIDTH1_REG	;

// Internal signals.
wire		start_int	;
wire		trigger_int	;

/**********************/
/* Begin Architecture */
/**********************/
// AXI Slave.
axi_slv axi_slv_i
	(
		.s_axi_aclk		(s_axi_aclk	  	),
		.s_axi_aresetn	(s_axi_aresetn	),

		// Write Address Channel.
		.s_axi_awaddr	(s_axi_awaddr	),
		.s_axi_awprot	(s_axi_awprot	),
		.s_axi_awvalid	(s_axi_awvalid	),
		.s_axi_awready	(s_axi_awready	),

		// Write Data Channel.
		.s_axi_wdata	(s_axi_wdata	),
		.s_axi_wstrb	(s_axi_wstrb	),
		.s_axi_wvalid	(s_axi_wvalid	),
		.s_axi_wready	(s_axi_wready	),

		// Write Response Channel.
		.s_axi_bresp	(s_axi_bresp	),
		.s_axi_bvalid	(s_axi_bvalid	),
		.s_axi_bready	(s_axi_bready	),

		// Read Address Channel.
		.s_axi_araddr	(s_axi_araddr	),
		.s_axi_arprot	(s_axi_arprot	),
		.s_axi_arvalid	(s_axi_arvalid	),
		.s_axi_arready	(s_axi_arready	),

		// Read Data Channel.
		.s_axi_rdata	(s_axi_rdata	),
		.s_axi_rresp	(s_axi_rresp	),
		.s_axi_rvalid	(s_axi_rvalid	),
		.s_axi_rready	(s_axi_rready	),

		// Registers.
		.START_REG		(START_REG		),
		.WIDTH0_REG		(WIDTH0_REG		),
		.WIDTH1_REG		(WIDTH1_REG		)
	);

// Start block.
start
	start_i
	(
		// Reset and clock.
		.aresetn		(aresetn		),
		.aclk			(aclk			),

		// Start output.
		.start			(start_int		),

		// Registers.
		.START_REG		(START_REG		)
	);

// Periodic trigger block.
trigger_per
	trigger_per_i
	(
		// Reset and clock.
		.aresetn		(aresetn		),
		.aclk			(aclk			),

		// Start Input.
		.start			(start_int		),

		// Trigger output.
		.trigger		(trigger_int	),

		// Registers.
		.WIDTH0_REG		(WIDTH0_REG		),
		.WIDTH1_REG		(WIDTH1_REG		)
	);

// Start output latency to ease timing.
latency_reg
	#(
		// Latency.
		.N(3),

		// Data width.
		.B(1)
	)
	latency_reg_start_i
	(
		// Reset and clock.
		.rstn	(aresetn	),
		.clk	(aclk		),

		// Data input.
		.din	(start_int	),

		// Data output.
		.dout	(start		)
	);

// Trigger output latency to ease timing.
latency_reg
	#(
		// Latency.
		.N(2),

		// Data width.
		.B(1)
	)
	latency_reg_trigger_i
	(
		// Reset and clock.
		.rstn	(aresetn	),
		.clk	(aclk		),

		// Data input.
		.din	(trigger_int),

		// Data output.
		.dout	(trigger	)
	);
endmodule

