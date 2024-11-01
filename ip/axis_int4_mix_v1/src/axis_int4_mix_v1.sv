module axis_int4_mix_v1
	( 
		// AXI Slave I/F for configuration.
		s_axi_aclk		,
		s_axi_aresetn	,

		s_axi_awaddr	,
		s_axi_awprot	,
		s_axi_awvalid	,
		s_axi_awready	,

		s_axi_wdata		,
		s_axi_wstrb		,
		s_axi_wvalid	,
		s_axi_wready	,

		s_axi_bresp		,
		s_axi_bvalid	,
		s_axi_bready	,

		s_axi_araddr	,
		s_axi_arprot	,
		s_axi_arvalid	,
		s_axi_arready	,

		s_axi_rdata		,
		s_axi_rresp		,
		s_axi_rvalid	,
		s_axi_rready	,
		
		// s_axis and m_axis clock.
		aclk			,
		aresetn			,

    	// AXIS slave for input data.
		s_axis_tdata	,
		s_axis_tvalid	,
		s_axis_tready	,

		// AXIS master for output data.
		m_axis_tvalid	,
		m_axis_tdata
	);

/**************/
/* Parameters */
/**************/

/*********/
/* Ports */
/*********/
input					s_axi_aclk;
input					s_axi_aresetn;

input	[7:0]			s_axi_awaddr;
input	[2:0]			s_axi_awprot;
input					s_axi_awvalid;
output					s_axi_awready;

input	[31:0]			s_axi_wdata;
input	[3:0]			s_axi_wstrb;
input					s_axi_wvalid;
output					s_axi_wready;

output	[1:0]			s_axi_bresp;
output					s_axi_bvalid;
input					s_axi_bready;

input	[7:0]			s_axi_araddr;
input	[2:0]			s_axi_arprot;
input					s_axi_arvalid;
output					s_axi_arready;

output	[31:0]			s_axi_rdata;
output	[1:0]			s_axi_rresp;
output					s_axi_rvalid;
input					s_axi_rready;

input					aresetn;
input					aclk;

input 	[4*32-1:0]		s_axis_tdata;
input					s_axis_tvalid;
output					s_axis_tready;

output					m_axis_tvalid;
output	[16*16-1:0]		m_axis_tdata;

/********************/
/* Internal signals */
/********************/
// Registers.
wire	[1:0]	MIXER_MODE_REG;

/**********************/
/* Begin Architecture */
/**********************/
// AXI Slave.
axi_slv axi_slv_i
	(
		.s_axi_aclk		(s_axi_aclk	 	),
		.s_axi_aresetn	(s_axi_aresetn	),

		// Write Address Channel.
		.s_axi_awaddr	(s_axi_awaddr 	),
		.s_axi_awprot	(s_axi_awprot 	),
		.s_axi_awvalid	(s_axi_awvalid	),
		.s_axi_awready	(s_axi_awready	),

		// Write Data Channel.
		.s_axi_wdata	(s_axi_wdata	),
		.s_axi_wstrb	(s_axi_wstrb	),
		.s_axi_wvalid	(s_axi_wvalid   ),
		.s_axi_wready	(s_axi_wready	),

		// Write Response Channel.
		.s_axi_bresp	(s_axi_bresp	),
		.s_axi_bvalid	(s_axi_bvalid	),
		.s_axi_bready	(s_axi_bready	),

		// Read Address Channel.
		.s_axi_araddr	(s_axi_araddr 	),
		.s_axi_arprot	(s_axi_arprot 	),
		.s_axi_arvalid	(s_axi_arvalid	),
		.s_axi_arready	(s_axi_arready	),

		// Read Data Channel.
		.s_axi_rdata	(s_axi_rdata	),
		.s_axi_rresp	(s_axi_rresp	),
		.s_axi_rvalid	(s_axi_rvalid	),
		.s_axi_rready	(s_axi_rready	),

		// Registers.
		.MIXER_MODE_REG	(MIXER_MODE_REG	)
	);

// x4 interpolation + mixer.
mixer_top mixer_top_i (
	// Clock.
	.clk		(aclk			),

	// Input.
	.din		(s_axis_tdata	),

	// Output.
	.dout		(m_axis_tdata	),

	// Registers.
	.MODE_REG	(MIXER_MODE_REG	)
	);

assign s_axis_tready = 1'b1;
assign m_axis_tvalid = 1'b1;

endmodule

