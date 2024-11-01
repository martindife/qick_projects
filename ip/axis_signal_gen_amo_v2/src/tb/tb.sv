import axi_vip_pkg::*;
import axi_mst_0_pkg::*;

module tb();

// Number of bits of t.
parameter BT = 10;

// Modulation trigger.
reg				trigger			;

// AXI Slave I/F for configuration.
reg  			s_axi_aclk		;
reg  			s_axi_aresetn	;

wire [7:0]		s_axi_awaddr	;
wire [2:0]		s_axi_awprot	;
wire  			s_axi_awvalid	;
wire  			s_axi_awready	;

wire [31:0] 	s_axi_wdata		;
wire [3:0]		s_axi_wstrb		;
wire  			s_axi_wvalid	;
wire  			s_axi_wready	;

wire [1:0]		s_axi_bresp		;
wire  			s_axi_bvalid	;
wire  			s_axi_bready	;

wire [7:0] 		s_axi_araddr	;
wire [2:0] 		s_axi_arprot	;
wire  			s_axi_arvalid	;
wire  			s_axi_arready	;

wire [31:0] 	s_axi_rdata		;
wire [1:0]		s_axi_rresp		;
wire  			s_axi_rvalid	;
wire  		    s_axi_rready	;

// s_axis for configuration.
reg				s_axis_aresetn	;
reg				s_axis_aclk		;
reg				s_axis_tvalid	;
wire			s_axis_tready	;
reg	[31:0]		s_axis_tdata	;
reg				s_axis_tlast	;

// m_axis for data output.
reg				m_axis_aresetn	;
reg				m_axis_aclk		;
wire			m_axis_tvalid	;
wire[15:0]		m_axis_tdata	;

xil_axi_prot_t  prot        = 0;
reg[31:0]       data;
xil_axi_resp_t  resp;

parameter NDDS = DUT.mod_dds_top_i.NDDS;
parameter NREG = DUT.mod_dds_top_i.NREG;
parameter BFREQ= DUT.mod_dds_top_i.BFREQ;
parameter BAMP = DUT.mod_dds_top_i.BAMP;

// AXI Master.
axi_mst_0 axi_mst_0_i
	(
		.aclk			(s_axi_aclk		),
		.aresetn		(s_axi_aresetn	),
		.m_axi_araddr	(s_axi_araddr	),
		.m_axi_arprot	(s_axi_arprot	),
		.m_axi_arready	(s_axi_arready	),
		.m_axi_arvalid	(s_axi_arvalid	),
		.m_axi_awaddr	(s_axi_awaddr	),
		.m_axi_awprot	(s_axi_awprot	),
		.m_axi_awready	(s_axi_awready	),
		.m_axi_awvalid	(s_axi_awvalid	),
		.m_axi_bready	(s_axi_bready	),
		.m_axi_bresp	(s_axi_bresp	),
		.m_axi_bvalid	(s_axi_bvalid	),
		.m_axi_rdata	(s_axi_rdata	),
		.m_axi_rready	(s_axi_rready	),
		.m_axi_rresp	(s_axi_rresp	),
		.m_axi_rvalid	(s_axi_rvalid	),
		.m_axi_wdata	(s_axi_wdata	),
		.m_axi_wready	(s_axi_wready	),
		.m_axi_wstrb	(s_axi_wstrb	),
		.m_axi_wvalid	(s_axi_wvalid	)
	);

// DUT.
axis_signal_gen_amo_v2
	#(
		// Number of bits of t.
		.BT(BT)
	)
	DUT
	( 	
		// Modulation trigger.
		.trigger		,

		// AXI Slave I/F for configuration.
		.s_axi_aclk		,
		.s_axi_aresetn	,

		.s_axi_awaddr	,
		.s_axi_awprot	,
		.s_axi_awvalid	,
		.s_axi_awready	,

		.s_axi_wdata	,
		.s_axi_wstrb	,
		.s_axi_wvalid	,
		.s_axi_wready	,

		.s_axi_bresp	,
		.s_axi_bvalid	,
		.s_axi_bready	,

		.s_axi_araddr	,
		.s_axi_arprot	,
		.s_axi_arvalid	,
		.s_axi_arready	,

		.s_axi_rdata	,
		.s_axi_rresp	,
		.s_axi_rvalid	,
		.s_axi_rready	,

		// s_axis for configuration.
		.s_axis_aresetn	,
		.s_axis_aclk	,
		.s_axis_tvalid	,
		.s_axis_tready	,
		.s_axis_tdata	,
		.s_axis_tlast	,

		// m_axis for data output.
		.m_axis_aresetn	,
		.m_axis_aclk	,
		.m_axis_tvalid	,
		.m_axis_tdata
	);

// VIP Agents
axi_mst_0_mst_t 	axi_mst_0_agent;

// Main TB.
initial begin
	// Create agents.
	axi_mst_0_agent 	= new("axi_mst_0 VIP Agent",tb.axi_mst_0_i.inst.IF);

	// Set tag for agents.
	axi_mst_0_agent.set_agent_tag("axi_mst_0 VIP");

	// Start agents.
	axi_mst_0_agent.start_master();

	// Reset sequence.
	s_axi_aresetn 	<= 0;
	s_axis_aresetn 	<= 0;
	m_axis_aresetn 	<= 0;
	trigger			<= 0;
	#200;
	s_axi_aresetn 	<= 1;
	s_axis_aresetn 	<= 1;
	m_axis_aresetn 	<= 1;

	#1000;

	// QSEL_REG.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*3, prot, 0, resp);

	// Configure DDSs.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*0, prot, 1, resp);

	#5000;

	// Software Trigger.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*2, prot, 1, resp);

	#20000;

	// Software Trigger.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*2, prot, 0, resp);
	
	#5000;

	// Software Trigger.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*2, prot, 1, resp);

end

// Configuration (single DDS).
initial begin
	reg	[5:0]  		ADDR_REG	;
	reg [BFREQ-1:0] WAIT_REG	;
	reg [BFREQ-1:0] FMOD_C0_REG	;
	reg [BFREQ-1:0] FMOD_C1_REG	;
	reg [BFREQ-1:0] FMOD_C2_REG	;
	reg [BFREQ-1:0] FMOD_C3_REG	;
	reg [BFREQ-1:0] FMOD_C4_REG	;
	reg [BFREQ-1:0] FMOD_C5_REG	;
	reg [BFREQ-1:0] FMOD_G_REG	;
	reg [BAMP-1:0] 	AMOD_C0_REG	;
	reg [BAMP-1:0] 	AMOD_C1_REG	;
	reg [BFREQ-1:0] POFF_REG	;

	s_axis_tvalid 	<= 0;
	s_axis_tdata	<= 0;
	s_axis_tlast	<= 0;
	ADDR_REG		<= 0;
	WAIT_REG		<= 0;
	FMOD_C0_REG		<= 655;
	FMOD_C1_REG		<= 4211;
	FMOD_C2_REG		<= 11850;
	FMOD_C3_REG		<= -13047;
	FMOD_C4_REG		<= -25139;
	FMOD_C5_REG		<= 25139;
	FMOD_G_REG		<= 8110;
	AMOD_C0_REG		<= 32440;
	AMOD_C1_REG		<= -16056;
	POFF_REG		<= 0;

	wait (s_axis_tready);
	#200;

	// Configure some DDSs.
	for (int i=0; i<1; i=i+1) begin
		@(posedge s_axis_aclk);
		s_axis_tvalid 	<= 1;
		s_axis_tdata	<= ADDR_REG + i	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= WAIT_REG		;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= FMOD_C0_REG	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= FMOD_C1_REG	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= FMOD_C2_REG	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= FMOD_C3_REG	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= FMOD_C4_REG	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= FMOD_C5_REG	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= FMOD_G_REG	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= AMOD_C0_REG	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= AMOD_C1_REG	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= i*POFF_REG	;

		@(posedge s_axis_aclk);
		s_axis_tvalid 	<= 0;

		#200;
	end

	#10000;

	// Configure some DDSs.
	for (int i=0; i<1; i=i+1) begin
		@(posedge s_axis_aclk);
		s_axis_tvalid 	<= 1;
		s_axis_tdata	<= ADDR_REG + i	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= WAIT_REG		;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= FMOD_C0_REG/2	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= 0	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= 0	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= 0	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= 0	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= 0	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= FMOD_G_REG	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= AMOD_C0_REG	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= AMOD_C1_REG	;
		@(posedge s_axis_aclk);
		s_axis_tdata	<= i*POFF_REG	;

		@(posedge s_axis_aclk);
		s_axis_tvalid 	<= 0;

		#200;
	end
end

always begin
	s_axi_aclk <= 0;
	#7;
	s_axi_aclk <= 1;
	#7;
end

always begin
	s_axis_aclk <= 0;
	#5;
	s_axis_aclk <= 1;
	#5;
end  

always begin
	m_axis_aclk <= 0;
	#1;
	m_axis_aclk <= 1;
	#1;
end  

endmodule

