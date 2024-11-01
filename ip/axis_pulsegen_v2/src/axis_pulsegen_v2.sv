module axis_pulsegen_v2
	( 	
		// Start input.
		input wire					start			,

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

		// Reset and clock for m_axis_*
		input 	wire 				aresetn			,
		input 	wire 				aclk			,

		// m_axis_* for output.
		output	wire				m_axis_tvalid	,
		output	wire [16*16-1:0]	m_axis_tdata
	);

/********************/
/* Internal signals */
/********************/
// Registers.
wire [15:0]		SAMP0_REG		;
wire [15:0]		SAMP1_REG		;
wire [15:0]		SAMP2_REG		;
wire [15:0]		SAMP3_REG		;
wire [15:0]		SAMP4_REG		;
wire [15:0]		SAMP5_REG		;
wire [15:0]		SAMP6_REG		;
wire [15:0]		SAMP7_REG		;
wire [15:0]		SAMP8_REG		;
wire [15:0]		SAMP9_REG		;
wire [15:0]		SAMP10_REG		;
wire [15:0]		SAMP11_REG		;
wire [15:0]		SAMP12_REG		;
wire [15:0]		SAMP13_REG		;
wire [15:0]		SAMP14_REG		;
wire [15:0]		SAMP15_REG		;
wire [15:0]		SAMP16_REG		;
wire [15:0]		SAMP17_REG		;
wire [15:0]		SAMP18_REG		;
wire [15:0]		SAMP19_REG		;
wire [15:0]		SAMP20_REG		;
wire [15:0]		SAMP21_REG		;
wire [15:0]		SAMP22_REG		;
wire [15:0]		SAMP23_REG		;
wire [15:0]		SAMP24_REG		;
wire [15:0]		SAMP25_REG		;
wire [15:0]		SAMP26_REG		;
wire [15:0]		SAMP27_REG		;
wire [15:0]		SAMP28_REG		;
wire [15:0]		SAMP29_REG		;
wire [15:0]		SAMP30_REG		;
wire [15:0]		SAMP31_REG		;
wire			START_REG		;
wire			START_SRC_REG	;
wire			MODE_REG		;
wire [31:0]		WAIT_REG		;

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
		.SAMP0_REG		(SAMP0_REG		),
		.SAMP1_REG		(SAMP1_REG		),
		.SAMP2_REG		(SAMP2_REG		),
		.SAMP3_REG		(SAMP3_REG		),
		.SAMP4_REG		(SAMP4_REG		),
		.SAMP5_REG		(SAMP5_REG		),
		.SAMP6_REG		(SAMP6_REG		),
		.SAMP7_REG		(SAMP7_REG		),
		.SAMP8_REG		(SAMP8_REG		),
		.SAMP9_REG		(SAMP9_REG		),
		.SAMP10_REG		(SAMP10_REG		),
		.SAMP11_REG		(SAMP11_REG		),
		.SAMP12_REG		(SAMP12_REG		),
		.SAMP13_REG		(SAMP13_REG		),
		.SAMP14_REG		(SAMP14_REG		),
		.SAMP15_REG		(SAMP15_REG		),
		.SAMP16_REG		(SAMP16_REG		),
		.SAMP17_REG		(SAMP17_REG		),
		.SAMP18_REG		(SAMP18_REG		),
		.SAMP19_REG		(SAMP19_REG		),
		.SAMP20_REG		(SAMP20_REG		),
		.SAMP21_REG		(SAMP21_REG		),
		.SAMP22_REG		(SAMP22_REG		),
		.SAMP23_REG		(SAMP23_REG		),
		.SAMP24_REG		(SAMP24_REG		),
		.SAMP25_REG		(SAMP25_REG		),
		.SAMP26_REG		(SAMP26_REG		),
		.SAMP27_REG		(SAMP27_REG		),
		.SAMP28_REG		(SAMP28_REG		),
		.SAMP29_REG		(SAMP29_REG		),
		.SAMP30_REG		(SAMP30_REG		),
		.SAMP31_REG		(SAMP31_REG		),
		.START_REG		(START_REG		),
		.START_SRC_REG	(START_SRC_REG	),
		.MODE_REG		(MODE_REG		),
		.WAIT_REG		(WAIT_REG		)
	);

// Streamer Block.
pulsegen
	pulsegen_i
	(
		// Reset and clock.
		.aresetn		(aresetn		),
		.aclk			(aclk			),

		// m_axis_* for output.
		.m_axis_tvalid	(m_axis_tvalid	),
		.m_axis_tdata	(m_axis_tdata	),

		.start			(start			),

		// Registers.
		.SAMP0_REG		(SAMP0_REG		),
		.SAMP1_REG		(SAMP1_REG		),
		.SAMP2_REG		(SAMP2_REG		),
		.SAMP3_REG		(SAMP3_REG		),
		.SAMP4_REG		(SAMP4_REG		),
		.SAMP5_REG		(SAMP5_REG		),
		.SAMP6_REG		(SAMP6_REG		),
		.SAMP7_REG		(SAMP7_REG		),
		.SAMP8_REG		(SAMP8_REG		),
		.SAMP9_REG		(SAMP9_REG		),
		.SAMP10_REG		(SAMP10_REG		),
		.SAMP11_REG		(SAMP11_REG		),
		.SAMP12_REG		(SAMP12_REG		),
		.SAMP13_REG		(SAMP13_REG		),
		.SAMP14_REG		(SAMP14_REG		),
		.SAMP15_REG		(SAMP15_REG		),
		.SAMP16_REG		(SAMP16_REG		),
		.SAMP17_REG		(SAMP17_REG		),
		.SAMP18_REG		(SAMP18_REG		),
		.SAMP19_REG		(SAMP19_REG		),
		.SAMP20_REG		(SAMP20_REG		),
		.SAMP21_REG		(SAMP21_REG		),
		.SAMP22_REG		(SAMP22_REG		),
		.SAMP23_REG		(SAMP23_REG		),
		.SAMP24_REG		(SAMP24_REG		),
		.SAMP25_REG		(SAMP25_REG		),
		.SAMP26_REG		(SAMP26_REG		),
		.SAMP27_REG		(SAMP27_REG		),
		.SAMP28_REG		(SAMP28_REG		),
		.SAMP29_REG		(SAMP29_REG		),
		.SAMP30_REG		(SAMP30_REG		),
		.SAMP31_REG		(SAMP31_REG		),
		.START_REG		(START_REG		),
		.START_SRC_REG	(START_SRC_REG	),
		.MODE_REG		(MODE_REG		),
		.WAIT_REG		(WAIT_REG		)
	);

endmodule

