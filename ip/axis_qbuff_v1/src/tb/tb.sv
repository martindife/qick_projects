import axi_vip_pkg::*;
import axi_mst_0_pkg::*;

module tb();

// Delay line length.
parameter DLY	= 20;

// Bits.
parameter B		= 16;

// Number of lanes.
parameter L		= 8	;

// Memory Size.
parameter N		= 16;

// Start.
reg						start_in		;
wire					start_out		;

reg  					s_axi_aclk		;
reg  					s_axi_aresetn	;

// Write Address Channel.
wire 	[7:0]			s_axi_awaddr	;
wire 	[2:0]			s_axi_awprot	;
wire  					s_axi_awvalid	;
wire  					s_axi_awready	;

// Write Data Channel.
wire 	[31:0] 			s_axi_wdata		;
wire 	[3:0]			s_axi_wstrb		;
wire  					s_axi_wvalid	;
wire  					s_axi_wready	;

// Write Response Channel.
wire 	[1:0]			s_axi_bresp		;
wire  					s_axi_bvalid	;
wire  					s_axi_bready	;

// Read Address Channel.
wire 	[7:0] 			s_axi_araddr	;
wire 	[2:0] 			s_axi_arprot	;
wire  					s_axi_arvalid	;
wire  					s_axi_arready	;

// Read Data Channel.
wire 	[31:0] 			s_axi_rdata		;
wire 	[1:0]			s_axi_rresp		;
wire  					s_axi_rvalid	;
wire  					s_axi_rready	;

// s_axis_* for input.
reg 					s_axis_aresetn	;
reg 					s_axis_aclk		;
reg						s_axis_tvalid	;
wire					s_axis_tready	;
wire 	[L*B-1:0]		s_axis_tdata	;

// m_axis_* for output.
reg 					m_axis_aresetn	;
reg 					m_axis_aclk		;
wire					m_axis_tvalid	;
reg						m_axis_tready	;
wire 	[B-1:0]			m_axis_tdata	;
wire					m_axis_tlast	;

///////////
// Debug //
///////////

// Input data vector.
reg 			aclk_f			;
reg [B-1:0]		din_v [L]		;
reg [B-1:0]		din_f			;

genvar i;
generate
	for (i=0; i<L; i++) begin
		assign s_axis_tdata[i*B +: B] = din_v[i];
	end
endgenerate

xil_axi_prot_t  prot        = 0;
reg[31:0]       data;
xil_axi_resp_t  resp;

// TB Control.
reg tb_data_in 	= 0;
reg tb_data_out	= 0;

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
axis_qbuff_v1
	#(
		// Delay line length.
		.DLY(DLY),

		// Bits.
		.B	(B	),

		// Number of lanes.
		.L	(L	),

		// Memory Size.
		.N	(N	)
	)
	DUT
	( 	
		// Start.
		.start_in		,
		.start_out		,

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

		// s_axis_* for input.
		.s_axis_aresetn	,
		.s_axis_aclk	,
		.s_axis_tvalid	,
		.s_axis_tready	,
		.s_axis_tdata	,

		// m_axis_* for output.
		.m_axis_aresetn	,
		.m_axis_aclk	,
		.m_axis_tvalid	,
		.m_axis_tready	,
		.m_axis_tdata	,
		.m_axis_tlast
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
	s_axi_aresetn 		<= 0;
	s_axis_aresetn 		<= 0;
	m_axis_aresetn 		<= 0;
	m_axis_tready		<= 1;
	start_in			<= 0;
	#500;
	s_axi_aresetn 		<= 1;
	s_axis_aresetn 		<= 1;
	m_axis_aresetn 		<= 1;

	#1000;
	
	$display("################################");
	$display("### Program Qualified Buffer ###");
	$display("################################");
	$display("t = %0t", $time);


	// COMP_MODE_REG
	// 0 : greater than.
	// 1 : smaller than.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*2, prot, 0, resp);
	#10;

	// COMP_THR_REG
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*3, prot, 15000, resp);
	#10;

	// WMEM_NSAMP_REG
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*4, prot, 4, resp);
	#10;
			
	// Start data.
	tb_data_in <= 1;

	// START_SRC_REG
	// 0 : internal.
	// 1 : external.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*1, prot, 1, resp);
	#10;

	#3000;

	// START_REG
	//axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*0, prot, 1, resp);
	//#10;
	@(posedge s_axis_aclk);
	start_in <= 1;

	#4000;

	// START_REG
	//axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*0, prot, 0, resp);
	//#10;

	#2000;

	// Transfer data.
	// RMEM_START_REG
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*5, prot, 1, resp);
	#10;

	tb_data_out	<= 1;

	//// Program block.
	//COMP_MODE_REG	<= 1;
	//COMP_THR_REG	<= -2000;
	//WMEM_ADDR_REG	<= 5;
	//WMEM_NSAMP_REG	<= 59;
	//WMEM_START_REG	<= 0;
	//#100;
	//WMEM_START_REG	<= 1;
end

// Input data generation.
initial begin
	s_axis_tvalid	<= 0;
	for (int i=0; i<L; i++) begin
		din_v[i] <= 0;
	end

	wait(tb_data_in);

	@(posedge s_axis_aclk);
	s_axis_tvalid	<= 1;

	while(1) begin

		for (int j=0; j<10; j++) begin
			@(posedge s_axis_aclk);
			for (int i=0; i<L; i++) begin
				@(posedge aclk_f);
				din_v[i] <= 0;
			end
		end

		@(posedge s_axis_aclk);
		@(posedge aclk_f);
		din_v[0] <= 2500;
		@(posedge aclk_f);
		din_v[1] <= 5500;
		@(posedge aclk_f);
		din_v[2] <= 15500;
		@(posedge aclk_f);
		din_v[3] <= 15000;
		@(posedge aclk_f);
		din_v[4] <= 25000;
		@(posedge aclk_f);
		din_v[5] <= 15500;
		@(posedge aclk_f);
		din_v[6] <= 5500;
		@(posedge aclk_f);
		din_v[7] <= 1500;
		@(posedge s_axis_aclk);
		@(posedge aclk_f);
		din_v[0] <= -2500;
		@(posedge aclk_f);
		din_v[1] <= -2800;
		@(posedge aclk_f);
		din_v[2] <= -2300;
		@(posedge aclk_f);
		din_v[3] <= -1500;
		@(posedge aclk_f);
		din_v[4] <= -2500;
		@(posedge aclk_f);
		din_v[5] <= -2800;
		@(posedge aclk_f);
		din_v[6] <= -2300;
		@(posedge aclk_f);
		din_v[7] <= -1500;

		for (int j=0; j<90; j++) begin
			@(posedge s_axis_aclk);
			for (int i=0; i<L; i++) begin
				@(posedge aclk_f);
				din_v[i] <= 324*i;
			end
		end

		#5000;
	end
end

initial begin
	while(1) begin
		for (int i=0; i<L; i++) begin
			@(posedge aclk_f);
			din_f <= din_v[i];
		end
	end
end

// Output data generation.
initial begin
	m_axis_tready	<= 0;

	wait(tb_data_out);

	while(1) begin
		@(posedge m_axis_aclk);
		m_axis_tready <= 1;
		@(posedge m_axis_aclk);
		m_axis_tready <= 0;
	end
end	

always begin
	s_axi_aclk <= 0;
	#10;
	s_axi_aclk <= 1;
	#10;
end

always begin
	s_axis_aclk <= 0;
	#L;
	s_axis_aclk <= 1;
	#L;
end  

always begin
	m_axis_aclk <= 0;
	#5;
	m_axis_aclk <= 1;
	#5;
end  

always begin
	aclk_f <= 0;
	#1;
	aclk_f <= 1;
	#1;
end

endmodule

