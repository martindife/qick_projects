module axis_signal_gen_amo_v2
	( 	
		// Modulation trigger.
		input 	wire				trigger			,

		// Auxiliary trigger output.
		output	wire				trigger_out		,

		// AXI Slave I/F for configuration.
		input	wire  				s_axi_aclk		,
		input 	wire  				s_axi_aresetn	,

		input 	wire	[7:0]		s_axi_awaddr	,
		input 	wire 	[2:0]		s_axi_awprot	,
		input 	wire  				s_axi_awvalid	,
		output	wire  				s_axi_awready	,

		input 	wire 	[31:0] 		s_axi_wdata		,
		input 	wire 	[3:0]		s_axi_wstrb		,
		input 	wire  				s_axi_wvalid	,
		output 	wire  				s_axi_wready	,

		output 	wire 	[1:0]		s_axi_bresp		,
		output 	wire  				s_axi_bvalid	,
		input 	wire  				s_axi_bready	,

		input 	wire 	[7:0] 		s_axi_araddr	,
		input 	wire 	[2:0] 		s_axi_arprot	,
		input 	wire  				s_axi_arvalid	,
		output 	wire  				s_axi_arready	,

		output 	wire 	[31:0] 		s_axi_rdata		,
		output 	wire 	[1:0]		s_axi_rresp		,
		output 	wire  				s_axi_rvalid	,
		input 	wire  				s_axi_rready	,

		// s_axis for configuration.
		input	wire				s_axis_aresetn	,
		input	wire				s_axis_aclk		,
		input	wire				s_axis_tvalid	,
		output	wire				s_axis_tready	,
		input	wire	[31:0]		s_axis_tdata	,
		input	wire				s_axis_tlast	,

		// m_axis for data output.
		input	wire				m_axis_aresetn	,
		input	wire				m_axis_aclk		,
		output	wire				m_axis_tvalid	,
		output	wire	[15:0]		m_axis_tdata
	);

/********************/
/* Internal signals */
/********************/

// Number of bits of t.
parameter BT    = 8;

// LOCAL: defined in mod_dds_top_i.
parameter NDDS 	= 16;
parameter NREG 	= 11;
parameter BFREQ	= 18;
parameter BAMP 	= 16;

// Registers.
wire			REGW_START_REG	;
wire			TRIGGER_SRC_REG	;
wire			TRIGGER_REG		;
wire	[3:0]	QSEL_REG		;

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
		.REGW_START_REG	(REGW_START_REG	),
		.TRIGGER_SRC_REG(TRIGGER_SRC_REG),
		.TRIGGER_REG	(TRIGGER_REG	),
		.QSEL_REG		(QSEL_REG		)
	);

mod_dds_top
	#(
		// Number of bits of t.
		.BT(BT)
	)
	mod_dds_top_i
	(
		// Trigger.
		.trigger		(trigger		),

		// Auxiliary trigger output.
		.trigger_out	(trigger_out	),

		// s_axis for configuration.
		.s_axis_aresetn	(s_axis_aresetn	),
		.s_axis_aclk	(s_axis_aclk	),
		.s_axis_tvalid	(s_axis_tvalid	),
		.s_axis_tready	(s_axis_tready	),
		.s_axis_tdata	(s_axis_tdata	),
		.s_axis_tlast	(s_axis_tlast	),

		// m_axis for data output.
		.m_axis_aresetn	(m_axis_aresetn	),
		.m_axis_aclk	(m_axis_aclk	),
		.m_axis_tvalid	(m_axis_tvalid	),
		.m_axis_tdata	(m_axis_tdata	),
	
		// Registers.
		.REGW_START_REG	(REGW_START_REG	),
		.TRIGGER_SRC_REG(TRIGGER_SRC_REG),
		.TRIGGER_REG	(TRIGGER_REG	),
		.QSEL_REG		(QSEL_REG		)
	);

endmodule

