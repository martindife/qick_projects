import axi_vip_pkg::*;
import axi_mst_0_pkg::*;

module tb();

// DUT generics.
parameter B = 8;
parameter N = 16;

reg				s_axi_aclk		;
reg				s_axi_aresetn	;

wire 	[5:0]	s_axi_araddr	;
wire 	[2:0]	s_axi_arprot	;
wire			s_axi_arready	;
wire			s_axi_arvalid	;

wire 	[5:0]	s_axi_awaddr	;
wire 	[2:0]	s_axi_awprot	;
wire			s_axi_awready	;
wire			s_axi_awvalid	;

wire			s_axi_bready	;
wire 	[1:0]	s_axi_bresp		;
wire			s_axi_bvalid	;

wire 	[31:0]	s_axi_rdata		;
wire			s_axi_rready	;
wire 	[1:0]	s_axi_rresp		;
wire			s_axi_rvalid	;

wire 	[31:0]	s_axi_wdata		;
wire			s_axi_wready	;
wire 	[3:0]	s_axi_wstrb		;
wire			s_axi_wvalid	;

// Reset and Clock for s/m axis.
reg 			aresetn			;
reg 			aclk			;

// s_axis_* for input.
reg				s_axis_tvalid	;
wire			s_axis_tready	;
reg 	[B-1:0]	s_axis_tdata	;

// mx_axis_* for output.
wire			m00_axis_tvalid	;
wire 	[B-1:0]	m00_axis_tdata	;
wire			m01_axis_tvalid	;
wire 	[B-1:0]	m01_axis_tdata	;
wire			m02_axis_tvalid	;
wire 	[B-1:0]	m02_axis_tdata	;
wire			m03_axis_tvalid	;
wire 	[B-1:0]	m03_axis_tdata	;
wire			m04_axis_tvalid	;
wire 	[B-1:0]	m04_axis_tdata	;
wire			m05_axis_tvalid	;
wire 	[B-1:0]	m05_axis_tdata	;
wire			m06_axis_tvalid	;
wire 	[B-1:0]	m06_axis_tdata	;
wire			m07_axis_tvalid	;
wire 	[B-1:0]	m07_axis_tdata	;
wire			m08_axis_tvalid	;
wire 	[B-1:0]	m08_axis_tdata	;
wire			m09_axis_tvalid	;
wire 	[B-1:0]	m09_axis_tdata	;
wire			m10_axis_tvalid	;
wire 	[B-1:0]	m10_axis_tdata	;
wire			m11_axis_tvalid	;
wire 	[B-1:0]	m11_axis_tdata	;
wire			m12_axis_tvalid	;
wire 	[B-1:0]	m12_axis_tdata	;
wire			m13_axis_tvalid	;
wire 	[B-1:0]	m13_axis_tdata	;
wire			m14_axis_tvalid	;
wire 	[B-1:0]	m14_axis_tdata	;
wire			m15_axis_tvalid	;
wire 	[B-1:0]	m15_axis_tdata	;

xil_axi_prot_t  prot        = 0;
reg[31:0]       data;
xil_axi_resp_t  resp;

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

axis_switch_v1
	#(
		.B(B),
		.N(N)
	)
	DUT
	( 
		// AXI Slave I/F for configuration.
		.s_axi_aclk			,
		.s_axi_aresetn		,
		
		.s_axi_awaddr		,
		.s_axi_awprot		,
		.s_axi_awvalid		,
		.s_axi_awready		,
		
		.s_axi_wdata		,
		.s_axi_wstrb		,
		.s_axi_wvalid		,
		.s_axi_wready		,
		
		.s_axi_bresp		,
		.s_axi_bvalid		,
		.s_axi_bready		,
		
		.s_axi_araddr		,
		.s_axi_arprot		,
		.s_axi_arvalid		,
		.s_axi_arready		,
		
		.s_axi_rdata		,
		.s_axi_rresp		,
		.s_axi_rvalid		,
		.s_axi_rready		,

		// Reset and Clock for s/m axis.
		.aresetn			,
		.aclk				,

		// s_axis_* for input.
		.s_axis_tvalid		,
		.s_axis_tready		,
		.s_axis_tdata		,

		// mx_axis_* for output.
		.m00_axis_tvalid	,
		.m00_axis_tdata		,
		.m01_axis_tvalid	,
		.m01_axis_tdata		,
		.m02_axis_tvalid	,
		.m02_axis_tdata		,
		.m03_axis_tvalid	,
		.m03_axis_tdata		,
		.m04_axis_tvalid	,
		.m04_axis_tdata		,
		.m05_axis_tvalid	,
		.m05_axis_tdata		,
		.m06_axis_tvalid	,
		.m06_axis_tdata		,
		.m07_axis_tvalid	,
		.m07_axis_tdata		,
		.m08_axis_tvalid	,
		.m08_axis_tdata		,
		.m09_axis_tvalid	,
		.m09_axis_tdata		,
		.m10_axis_tvalid	,
		.m10_axis_tdata		,
		.m11_axis_tvalid	,
		.m11_axis_tdata		,
		.m12_axis_tvalid	,
		.m12_axis_tdata		,
		.m13_axis_tvalid	,
		.m13_axis_tdata		,
		.m14_axis_tvalid	,
		.m14_axis_tdata		,
		.m15_axis_tvalid	,
		.m15_axis_tdata
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
	aresetn 		<= 0;
	#500;
	s_axi_aresetn 	<= 1;
	aresetn 		<= 1;

	#1000;
	
	// CHANNEL_REG.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*0, prot, 1, resp);

	#2000;	

	// CHANNEL_REG.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*0, prot, 10, resp);
end

initial begin
	s_axis_tvalid	<= 0;
	s_axis_tdata	<= 0;

	#1000;

	for (int i=0; i<10000; i = i+1) begin
		@(posedge aclk);
		s_axis_tvalid 	<= 1;
		s_axis_tdata	<= $random;
	end
end

always begin
	s_axi_aclk <= 0;
	#10;
	s_axi_aclk <= 1;
	#10;
end

always begin
	aclk <= 0;
	#7;
	aclk <= 1;
	#7;
end  

endmodule

