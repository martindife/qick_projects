module axis_counter_v1
	#(
		parameter BDATA	= 16	,
		parameter BUSER	= 8
	)
	( 
		// AXI Slave I/F for configuration.
		input	wire				s_axi_aclk		,
		input	wire				s_axi_aresetn	,
		
		input	wire [5:0]			s_axi_awaddr	,
		input	wire [2:0]			s_axi_awprot	,
		input	wire				s_axi_awvalid	,
		output	wire				s_axi_awready	,
		
		input	wire [31:0]			s_axi_wdata		,
		input	wire [3:0]			s_axi_wstrb		,
		input	wire				s_axi_wvalid	,
		output	wire				s_axi_wready	,
		
		output	wire [1:0]			s_axi_bresp		,
		output	wire				s_axi_bvalid	,
		input	wire				s_axi_bready	,
		
		input	wire [5:0]			s_axi_araddr	,
		input	wire [2:0]			s_axi_arprot	,
		input	wire				s_axi_arvalid	,
		output	wire				s_axi_arready	,
		
		output	wire [31:0]			s_axi_rdata		,
		output	wire [1:0]			s_axi_rresp		,
		output	wire				s_axi_rvalid	,
		input	wire				s_axi_rready	,

		// m_axis_* for output.
		input 	wire 				m_axis_aresetn	,
		input 	wire 				m_axis_aclk		,
		output	wire				m_axis_tvalid	,
		input   wire				m_axis_tready	,
		output	wire [BDATA-1:0]	m_axis_tdata	,
		output	wire [BUSER-1:0]	m_axis_tuser
	);

/********************/
/* Internal signals */
/********************/
// Registers.
wire		START_REG;
wire [31:0]	NDATA_REG;
wire [31:0]	NUSER_REG;
wire [31:0]	WAIT_REG;

/**********************/
/* Begin Architecture */
/**********************/
// AXI Slave.
axi_slv axi_slv_i
	(
		.aclk			(s_axi_aclk	 	),
		.aresetn		(s_axi_aresetn	),

		// Write Address Channel.
		.awaddr			(s_axi_awaddr 	),
		.awprot			(s_axi_awprot 	),
		.awvalid		(s_axi_awvalid	),
		.awready		(s_axi_awready	),

		// Write Data Channel.
		.wdata			(s_axi_wdata	),
		.wstrb			(s_axi_wstrb	),
		.wvalid			(s_axi_wvalid   ),
		.wready			(s_axi_wready	),

		// Write Response Channel.
		.bresp			(s_axi_bresp	),
		.bvalid			(s_axi_bvalid	),
		.bready			(s_axi_bready	),

		// Read Address Channel.
		.araddr			(s_axi_araddr 	),
		.arprot			(s_axi_arprot 	),
		.arvalid		(s_axi_arvalid	),
		.arready		(s_axi_arready	),

		// Read Data Channel.
		.rdata			(s_axi_rdata	),
		.rresp			(s_axi_rresp	),
		.rvalid			(s_axi_rvalid	),
		.rready			(s_axi_rready	),

		// Registers.
		.START_REG		(START_REG		),
		.NDATA_REG		(NDATA_REG		),
		.NUSER_REG		(NUSER_REG		),
		.WAIT_REG		(WAIT_REG		)
	);

// Streamer Block.
counter
	#(
		.BDATA(BDATA),
		.BUSER(BUSER)
	)
	counter_i
	(
		// m_axis_* for output.
		.m_axis_aresetn	(m_axis_aresetn	),
		.m_axis_aclk	(m_axis_aclk	),
		.m_axis_tvalid	(m_axis_tvalid	),
		.m_axis_tready	(m_axis_tready	),
		.m_axis_tdata	(m_axis_tdata	),
		.m_axis_tuser	(m_axis_tuser	),	

		// Registers.
		.START_REG		(START_REG		),
		.NDATA_REG		(NDATA_REG		),
		.NUSER_REG		(NUSER_REG		),
		.WAIT_REG		(WAIT_REG		)
	);

endmodule

