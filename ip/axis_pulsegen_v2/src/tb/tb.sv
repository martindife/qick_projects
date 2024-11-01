import axi_vip_pkg::*;
import axi_mst_0_pkg::*;

module tb();

// Start input.
reg					start			;

// AXI Slave I/F for configuration.
reg  				s_axi_aclk		;
reg  				s_axi_aresetn	;

wire [7:0]			s_axi_awaddr	;
wire [2:0]			s_axi_awprot	;
wire  				s_axi_awvalid	;
wire  				s_axi_awready	;

wire [31:0] 		s_axi_wdata		;
wire [3:0]			s_axi_wstrb		;
wire  				s_axi_wvalid	;
wire  				s_axi_wready	;

wire [1:0]			s_axi_bresp		;
wire  				s_axi_bvalid	;
wire  				s_axi_bready	;

wire [7:0] 			s_axi_araddr	;
wire [2:0] 			s_axi_arprot	;
wire  				s_axi_arvalid	;
wire  				s_axi_arready	;

wire [31:0] 		s_axi_rdata		;
wire [1:0]			s_axi_rresp		;
wire  				s_axi_rvalid	;
wire  		        s_axi_rready	;

// Reset and clock for m_axis_*
reg 				aresetn			;
reg 				aclk			;

// m_axis_* for output.
wire				m_axis_tvalid	;
wire [16*16-1:0]	m_axis_tdata	;

// Debug.
wire [15:0]			dout_ii [16]	;
reg [15:0]			dout_f			;
reg					aclk_f			;

genvar i;
generate 
	for (i=0; i<16; i++) begin
		// Output as vector.
		assign dout_ii [i] = m_axis_tdata [16*i +: 16];
	end
endgenerate

initial begin
	while(1) begin
    	@(posedge aclk);
    	for (int i=0; i<16; i++) begin
			@(posedge aclk_f);
    	    dout_f <= m_axis_tdata [i*16 +: 16];
    	end
	end
end


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

axis_pulsegen_v2
	DUT
	( 
		// Start input.
		.start			,

		// AXI Slave I/F.
		.s_axi_aclk		,
		.s_axi_aresetn	,

		// Write Address Channel.
		.s_axi_awaddr	,
		.s_axi_awprot	,
		.s_axi_awvalid	,
		.s_axi_awready	,

		// Write Data Channel.
		.s_axi_wdata	,
		.s_axi_wstrb	,
		.s_axi_wvalid	,
		.s_axi_wready	,

		// Write Response Channel.
		.s_axi_bresp	,
		.s_axi_bvalid	,
		.s_axi_bready	,

		// Read Address Channel.
		.s_axi_araddr	,
		.s_axi_arprot	,
		.s_axi_arvalid	,
		.s_axi_arready	,

		// Read Data Channel.
		.s_axi_rdata	,
		.s_axi_rresp	,
		.s_axi_rvalid	,
		.s_axi_rready	,

		// Reset and clock for m_axis_*
		.aresetn		,
		.aclk			,

		// m_axis_* for output.
		.m_axis_tvalid	,
		.m_axis_tdata
	);

// VIP Agents
axi_mst_0_mst_t 	axi_mst_0_agent;

// Main TB.
initial begin
	real samp_v[16];
	for (int i=0; i<16; i++)
		samp_v[i] = 0;

	// Create agents.
	axi_mst_0_agent 	= new("axi_mst_0 VIP Agent",tb.axi_mst_0_i.inst.IF);

	// Set tag for agents.
	axi_mst_0_agent.set_agent_tag("axi_mst_0 VIP");

	// Start agents.
	axi_mst_0_agent.start_master();

	// Reset sequence.
	s_axi_aresetn 	<= 0;
	aresetn 	    <= 0;
	start			<= 0;
	#500;
	s_axi_aresetn 	<= 1;
	aresetn 	    <= 1;

	#1000;
	
	// MODE_REG.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*34, prot, 1, resp);
	#10;	
	
	// WAIT_REG.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*35, prot, 0, resp);
	#10;

	// Samples.
	samp_v [0] = 30000;
	samp_v [1] = 30000;
	samp_v [4] = 30000;
	samp_v [5] = 30000;

	for (int i=0; i<16; i++) begin
		// SMAPi_REG
		axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*i, prot, samp_v[i], resp);
	#10;

	end

	// START_SRC_REG.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*33, prot, 1, resp);
	#10;

	// START_REG.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*32, prot, 1, resp);
	#10;

	#200;

	@(posedge aclk);
	start <= 1'b1;
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

always begin
	aclk_f <= 0;
	#1;
	aclk_f <= 1;
	#1;
end  

endmodule

