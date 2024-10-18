module axis_signal_gen_amo_v3
	( 	
		// AXI Slave I/F for configuration.
		input	wire  			s_axi_aclk		,
		input 	wire  			s_axi_aresetn	,

		input 	wire	[7:0]	s_axi_awaddr	,
		input 	wire 	[2:0]	s_axi_awprot	,
		input 	wire  			s_axi_awvalid	,
		output	wire  			s_axi_awready	,

		input 	wire 	[31:0] 	s_axi_wdata		,
		input 	wire 	[3:0]	s_axi_wstrb		,
		input 	wire  			s_axi_wvalid	,
		output 	wire  			s_axi_wready	,

		output 	wire 	[1:0]	s_axi_bresp		,
		output 	wire  			s_axi_bvalid	,
		input 	wire  			s_axi_bready	,

		input 	wire 	[7:0] 	s_axi_araddr	,
		input 	wire 	[2:0] 	s_axi_arprot	,
		input 	wire  			s_axi_arvalid	,
		output 	wire  			s_axi_arready	,

		output 	wire 	[31:0] 	s_axi_rdata		,
		output 	wire 	[1:0]	s_axi_rresp		,
		output 	wire  			s_axi_rvalid	,
		input 	wire  			s_axi_rready	,

		// Reset and clock: s0_axis, s1_axis, m_axis.
		input	wire			aresetn			,
		input	wire			aclk			,

		// s0_axis: parameter memory.
		input	wire			s0_axis_tvalid	,
		output	wire			s0_axis_tready	,
		input	wire	[31:0]	s0_axis_tdata	,
		input	wire			s0_axis_tlast	,

		// s1_axis: waveform push.
		input	wire			s1_axis_tvalid	,
		output	wire			s1_axis_tready	,
		input	wire	[79:0]	s1_axis_tdata	,

		// m_axis for data output.
		output	wire			m_axis_tvalid	,
		output	wire	[15:0]	m_axis_tdata
	);

// Number of bits for Time counter.
parameter BT 	= 8	;

// Memory length (bits).
parameter NMEM	= 8	;

// LOCAL: do not modify this.
parameter NDDS 	= 32;
parameter NREG 	= 12;
parameter BFREQ	= 18;
parameter BAMP 	= 16;

/********************/
/* Internal signals */
/********************/

// Registers.
wire			MEMW_START_REG	;

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
		.MEMW_START_REG	(MEMW_START_REG	)
	);

// Signal generator top.
signal_gen_top
	#(
		// Number of bits for Time counter.
		.BT		(BT		),

		// Memory length (bits).
		.NMEM	(NMEM	),

		// Number of DDSs (do not edit).
		.NDDS	(NDDS	)
	)
	signal_gen_top_i
	( 	
		// Reset and clock.
		.aresetn		(aresetn		),
		.aclk			(aclk			),

		// s0_axis: parameter memory.
		.s0_axis_tvalid	(s0_axis_tvalid	),
		.s0_axis_tready	(s0_axis_tready	),
		.s0_axis_tdata	(s0_axis_tdata	),
		.s0_axis_tlast	(s0_axis_tlast	),

		// s1_axis: waveform push.
		.s1_axis_tvalid	(s1_axis_tvalid	),
		.s1_axis_tready	(s1_axis_tready	),
		.s1_axis_tdata	(s1_axis_tdata	),

		// m_axis for data output.
		.m_axis_tvalid	(m_axis_tvalid	),
		.m_axis_tdata	(m_axis_tdata	),

		// Registers.
		.MEMW_START_REG	(MEMW_START_REG	)
	);

endmodule

