// VIP: axi_mst_0
// DUT: axis_signal_gen_v2
// 	IF: s_axi -> axi_mst_0

import axi_vip_pkg::*;
import axi_mst_0_pkg::*;

module tb();

// s_axi interfase.
reg						s_axi_aclk;
reg						s_axi_aresetn;
wire 	[7:0]			s_axi_araddr;
wire 	[2:0]			s_axi_arprot;
wire					s_axi_arready;
wire					s_axi_arvalid;
wire 	[7:0]			s_axi_awaddr;
wire 	[2:0]			s_axi_awprot;
wire					s_axi_awready;
wire					s_axi_awvalid;
wire					s_axi_bready;
wire 	[1:0]			s_axi_bresp;
wire					s_axi_bvalid;
wire 	[31:0]			s_axi_rdata;
wire					s_axi_rready;
wire 	[1:0]			s_axi_rresp;
wire					s_axi_rvalid;
wire 	[31:0]			s_axi_wdata;
wire					s_axi_wready;
wire 	[3:0]			s_axi_wstrb;
wire					s_axi_wvalid;

reg						aresetn;
reg						aclk;

// s_axis interfase.
reg 	[4*32-1:0]		s_axis_tdata;
wire					s_axis_tready;
reg						s_axis_tvalid;

// m_axis interfase.
wire	[16*16-1:0]		m_axis_tdata;
wire					m_axis_tvalid;

// Fast data for debugging.
reg 			clk_x4;
reg		[15:0]	din_real_r	;
reg		[15:0]	din_imag_r	;
reg 			clk_x16;
reg		[15:0]	dout_r		;

xil_axi_prot_t  prot        = 0;
reg[31:0]       data_wr     = 32'h12345678;
reg[31:0]       data;
xil_axi_resp_t  resp;

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

axis_int4_mix_v1
	DUT 
	( 
		// AXI Slave I/F for configuration.
		.s_axi_aclk		(s_axi_aclk		),
		.s_axi_aresetn	(s_axi_aresetn	),
		.s_axi_araddr	(s_axi_araddr	),
		.s_axi_arprot	(s_axi_arprot	),
		.s_axi_arready	(s_axi_arready	),
		.s_axi_arvalid	(s_axi_arvalid	),
		.s_axi_awaddr	(s_axi_awaddr	),
		.s_axi_awprot	(s_axi_awprot	),
		.s_axi_awready	(s_axi_awready	),
		.s_axi_awvalid	(s_axi_awvalid	),
		.s_axi_bready	(s_axi_bready	),
		.s_axi_bresp	(s_axi_bresp	),
		.s_axi_bvalid	(s_axi_bvalid	),
		.s_axi_rdata	(s_axi_rdata	),
		.s_axi_rready	(s_axi_rready	),
		.s_axi_rresp	(s_axi_rresp	),
		.s_axi_rvalid	(s_axi_rvalid	),
		.s_axi_wdata	(s_axi_wdata	),
		.s_axi_wready	(s_axi_wready	),
		.s_axi_wstrb	(s_axi_wstrb	),
		.s_axi_wvalid	(s_axi_wvalid	),

		// s1_* and m_* reset/clock.
		.aresetn		(aresetn		),
		.aclk			(aclk	 		),

        // AXIS Slave to load data into memory.
		.s_axis_tdata	(s_axis_tdata 	),
		.s_axis_tvalid	(s_axis_tvalid	),
        .s_axis_tready	(s_axis_tready	),

		// AXIS Master for output data.
		.m_axis_tvalid	(m_axis_tvalid	),
		.m_axis_tdata	(m_axis_tdata 	)
	);

// VIP Agents
axi_mst_0_mst_t 	axi_mst_0_agent;

initial begin
	real w0;
	int n;

	// Create agents.
	axi_mst_0_agent 	= new("axi_mst_0 VIP Agent",tb.axi_mst_0_i.inst.IF);

	// Set tag for agents.
	axi_mst_0_agent.set_agent_tag	("axi_mst_0 VIP");

	// Start agents.
	axi_mst_0_agent.start_master();

	// Reset sequence.
	s_axi_aresetn 		<= 0;
	aresetn 			<= 0;
	s_axis_tdata		<= 0;
	s_axis_tvalid		<= 1;
	#500;
	s_axi_aresetn 		<= 1;
	aresetn 			<= 1;

	#1000;
	
	// MIXER_MODE_REG.
	// 0 : no mix (0 freq).
	// 1 : pi/2.
	// 2 : pi/4.
	data_wr = 2;
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(0, prot, data_wr, resp);
	#10;

	w0 = 0.01*2*3.1415;

	n = 0;
	while(1) begin
		@(posedge aclk);
		for (int i=0; i<4; i=i+1) begin
			s_axis_tdata[32*i		+: 16] <= 0.8*(2**15)*$cos(w0*n);
			s_axis_tdata[32*i+16	+: 16] <= 0.8*(2**15)*$sin(w0*n);
			n = n+1;
		end
	end

end

initial begin
	while(1) begin
		@(posedge aclk);
		for (int i=0; i<4; i=i+1) begin
			@(posedge clk_x4);
			din_real_r <= s_axis_tdata[32*i		+: 16];
			din_imag_r <= s_axis_tdata[32*i+16	+: 16];
		end
	end
end

initial begin
	while(1) begin
		@(posedge aclk);
		for (int i=0; i<16; i=i+1) begin
			@(posedge clk_x16);
			dout_r <= m_axis_tdata[16*i	+: 16];
		end
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
	#16;
	aclk <= 1;
	#16;
end

// fclk_x4.
always begin
	clk_x4 <= 0;
	#4;
	clk_x4 <= 1;
	#4;
end

// fclk_x16.
always begin
	clk_x16 <= 0;
	#1;
	clk_x16 <= 1;
	#1;
end

endmodule

