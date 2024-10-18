import axi_vip_pkg::*;
import axi_mst_0_pkg::*;

module tb();

// Number of bits for Time counter.
parameter BT 	= 8;

// Memory length (bits).
parameter NMEM	= 3	;

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

// Reset and clock: s0_axis, s1_axis, m_axis.
reg				aresetn			;
reg				aclk			;

// s0_axis: parameter memory.
reg				s0_axis_tvalid	;
wire			s0_axis_tready	;
reg 	[31:0]	s0_axis_tdata	;
reg				s0_axis_tlast	;

// s1_axis: waveform push.
reg				s1_axis_tvalid	;
wire			s1_axis_tready	;
wire	[79:0]	s1_axis_tdata	;

// m_axis for data output.
wire			m0_axis_tvalid	;
wire	[15:0]	m0_axis_tdata	;

// m1_axis for auxiliary data output.
wire			m1_axis_tvalid	;
wire	[15:0]	m1_axis_tdata	;

xil_axi_prot_t  prot        = 0;
reg[31:0]       data;
xil_axi_resp_t  resp;

parameter NDDS = DUT.NDDS;
parameter NREG = DUT.NREG;
parameter BFREQ= DUT.BFREQ;
parameter BAMP = DUT.BAMP;

// Wave parameters.
reg	[31:0]	wave_addr_r;
reg	[31:0]	wave_wait_r;
reg	[7:0]	wave_ctrl_r;
reg	[7:0]	wave_qsel_r;

// Test bench control.
reg	tb_load_mem			= 0;
reg	tb_load_mem_done 	= 0;
reg	tb_push_wave		= 0;

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
axis_signal_gen_amo_v4
	#(
		// Number of bits for Time counter.
		.BT(BT),

		// Memory length (bits).
		.NMEM(NMEM)
	)
	DUT
	( 	
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

		// Reset and clock: s0_axis, s1_axis, m_axis.
		.aresetn		,
		.aclk			,

		// s0_axis: parameter memory.
		.s0_axis_tvalid	,
		.s0_axis_tready	,
		.s0_axis_tdata	,
		.s0_axis_tlast	,

		// s1_axis: waveform push.
		.s1_axis_tvalid	,
		.s1_axis_tready	,
		.s1_axis_tdata	,

		// m_axis for data output.
		.m0_axis_tvalid	,
		.m0_axis_tdata	,

		// m1_axis for auxiliary data output.
		.m1_axis_tvalid	,
		.m1_axis_tdata
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
	#200;
	s_axi_aresetn 	<= 1;
	aresetn 		<= 1;

	#1000;

	// MEMW_START_REG.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*0, prot, 1, resp);
	#10;

	// Load parameter memory.
	tb_load_mem <= 1;
	wait (tb_load_mem_done);

	// MEMW_START_REG.
	axi_mst_0_agent.AXI4LITE_WRITE_BURST(4*0, prot, 0, resp);
	#10;

	#10000;

	// Push waveforms.
	tb_push_wave <= 1;

end

// Parameter memory.
// This block writes memories using DMA as input.
//
// Register 0 	 : always used for memory address.
// Register 1-14 : memory parameter fields (see below).
//
// Memory parameters fields:
// |------------|------------|------------|------------|------------|------------|------------|------------|-----------|----------|----------|----------|----------|---------|
// | 231 .. 224 | 223 .. 206 | 205 .. 190 | 189 .. 174 | 173 .. 158 | 157 .. 142 | 141 .. 126 | 125 .. 108 | 107 .. 90 | 89 .. 72 | 71 .. 54 | 53 .. 36 | 35 .. 18 | 17 .. 0 |
// |------------|------------|------------|------------|------------|------------|------------|------------|-----------|----------|----------|----------|----------|---------|
// |       CTRL |       POFF |     AMOD_G |    AMOD_C3 |    AMOD_C2 |    AMOD_C1 |    AMOD_C0 |     FMOD_G |   FMOD_C5 |  FMOD_C4 |  FMOD_C3 |  FMOD_C2 |  FMOD_C1 | FMOD_C0 |
// |------------|------------|------------|------------|------------|------------|------------|------------|-----------|----------|----------|----------|----------|---------|
initial begin
    // Fields.
	reg	[15:0]		dds_id_reg		;
	reg	[15:0] 		mem_addr_reg	;
	reg [BFREQ-1:0] mem_fmod_c0_reg	;
	reg [BFREQ-1:0] mem_fmod_c1_reg	;
	reg [BFREQ-1:0] mem_fmod_c2_reg	;
	reg [BFREQ-1:0] mem_fmod_c3_reg	;
	reg [BFREQ-1:0] mem_fmod_c4_reg	;
	reg [BFREQ-1:0] mem_fmod_c5_reg	;
	reg [BFREQ-1:0] mem_fmod_g_reg	;
	reg [BAMP-1:0] 	mem_amod_c0_reg	;
	reg [BAMP-1:0] 	mem_amod_c1_reg	;
	reg [BAMP-1:0] 	mem_amod_c2_reg	;
	reg [BAMP-1:0] 	mem_amod_c3_reg	;
	reg [BAMP-1:0] 	mem_amod_g_reg	;
	reg [BFREQ-1:0] mem_poff_reg	;
	reg	[7:0]		mem_ctrl_reg	;
	
	s0_axis_tvalid 	<= 0;
	s0_axis_tdata	<= 0;
	s0_axis_tlast	<= 0;
	dds_id_reg		<= 0;
	mem_addr_reg	<= 0;
	mem_fmod_c0_reg	<= 655;
	mem_fmod_c1_reg	<= 4211;
	mem_fmod_c2_reg	<= 11850;
	mem_fmod_c3_reg	<= -13047;
	mem_fmod_c4_reg	<= -25139;
	mem_fmod_c5_reg	<= 25139;
	mem_fmod_g_reg	<= 8110;
	mem_amod_c0_reg	<= 164;
	mem_amod_c1_reg	<= -901;
	mem_amod_c2_reg	<= 20890;
	mem_amod_c3_reg	<= 12288;
	mem_amod_g_reg	<= 8110;
	mem_poff_reg	<= 0;
	mem_ctrl_reg	<= 0;
	
	wait (tb_load_mem);

	wait (s0_axis_tready);
	#200;

	// Initialize all memories.
	for (int i=0; i<2**NMEM; i=i+1) begin
		for (int j=0; j<NDDS; j=j+1) begin
			@(posedge aclk);
			wait (s0_axis_tready == 1'b1);
			// dds_id
			@(posedge aclk);
			s0_axis_tvalid 	<= 1;
			s0_axis_tdata	<= j;

			// mem_addr_reg.
			@(posedge aclk);
			s0_axis_tvalid	<= 1;
			s0_axis_tdata	<= i;

			// Remaining registers (NREG-1).
			for (int k=0; k<NREG-1; k=k+1) begin
				@(posedge aclk);
				s0_axis_tvalid	<= 1;
				s0_axis_tdata 	<= 0;
			end

			@(posedge aclk);
			s0_axis_tvalid	<= 0;
		end
	end

	#1000;

	// Configure some DDSs.
	for (int i=0; i<10; i=i+1) begin
		@(posedge aclk);
		// dds_id.
		s0_axis_tvalid 	<= 1;
		s0_axis_tdata	<= i;

		@(posedge aclk);
		s0_axis_tdata	<= 0;	// memory address.
		@(posedge aclk);
		s0_axis_tdata	<= mem_fmod_c0_reg	;
		@(posedge aclk);
		s0_axis_tdata	<= mem_fmod_c1_reg	;
		@(posedge aclk);
		s0_axis_tdata	<= mem_fmod_c2_reg	;
		@(posedge aclk);
		s0_axis_tdata	<= mem_fmod_c3_reg	;
		@(posedge aclk);
		s0_axis_tdata	<= mem_fmod_c4_reg	;
		@(posedge aclk);
		s0_axis_tdata	<= mem_fmod_c5_reg	;
		@(posedge aclk);
		s0_axis_tdata	<= mem_fmod_g_reg	;
		@(posedge aclk);
		s0_axis_tdata	<= mem_amod_c0_reg	;
		@(posedge aclk);
		s0_axis_tdata	<= mem_amod_c1_reg	;
		@(posedge aclk);
		s0_axis_tdata	<= mem_amod_c2_reg	;
		@(posedge aclk);
		s0_axis_tdata	<= mem_amod_c3_reg	;
		@(posedge aclk);
		s0_axis_tdata	<= mem_amod_g_reg	;
		@(posedge aclk);
		s0_axis_tdata	<= mem_poff_reg		;
		@(posedge aclk);
		s0_axis_tdata	<= mem_ctrl_reg		;

		@(posedge aclk);
		s0_axis_tvalid	<= 0;

		#100;
	end

	@(posedge aclk);
	// dds_id.
	s0_axis_tvalid 	<= 1;
	s0_axis_tdata	<= 31;

	@(posedge aclk);
	s0_axis_tdata	<= 0;	// memory address.
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_c0_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_c1_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_c2_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_c3_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_c4_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_c5_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_g_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_amod_c0_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_amod_c1_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_amod_c2_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_amod_c3_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_amod_g_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_poff_reg		;
	@(posedge aclk);
	s0_axis_tdata	<= mem_ctrl_reg		;

	@(posedge aclk);
	s0_axis_tvalid	<= 0;

	#100;

	@(posedge aclk);
	// dds_id.
	s0_axis_tvalid 	<= 1;
	s0_axis_tdata	<= 0;

	@(posedge aclk);
	s0_axis_tdata	<= 1;	// memory address.
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_c0_reg+1	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_c1_reg+1	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_c2_reg+1	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_c3_reg+1	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_c4_reg+1	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_c5_reg+1	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_g_reg+1		;
	@(posedge aclk);
	s0_axis_tdata	<= mem_amod_c0_reg+1	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_amod_c1_reg+1	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_amod_c2_reg+1	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_amod_c3_reg+1	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_amod_g_reg+1		;
	@(posedge aclk);
	s0_axis_tdata	<= mem_poff_reg+1		;
	@(posedge aclk);
	s0_axis_tdata	<= mem_ctrl_reg			;

	@(posedge aclk);
	s0_axis_tvalid	<= 0;

	#100;

	@(posedge aclk);
	// dds_id.
	s0_axis_tvalid 	<= 1;
	s0_axis_tdata	<= 29;

	@(posedge aclk);
	s0_axis_tdata	<= 1;	// memory address.
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_c0_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_c1_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= 0;
	@(posedge aclk);
	s0_axis_tdata	<= 0;
	@(posedge aclk);
	s0_axis_tdata	<= 0;
	@(posedge aclk);
	s0_axis_tdata	<= 0;
	@(posedge aclk);
	s0_axis_tdata	<= mem_fmod_g_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_amod_c0_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_amod_c1_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= 0;
	@(posedge aclk);
	s0_axis_tdata	<= 0;
	@(posedge aclk);
	s0_axis_tdata	<= mem_amod_g_reg	;
	@(posedge aclk);
	s0_axis_tdata	<= 12345	;
	@(posedge aclk);
	s0_axis_tdata	<= mem_ctrl_reg	;

	@(posedge aclk);
	s0_axis_tvalid	<= 0;

	#100;

	@(posedge aclk);
	s0_axis_tvalid	<= 1;
	s0_axis_tlast	<= 1;

	@(posedge aclk);
	s0_axis_tvalid	<= 0;
	s0_axis_tlast	<= 0;

	tb_load_mem_done <= 1;
end

// Push waveforms.
initial begin
	wave_addr_r		<= 0;
	wave_wait_r		<= 0;
	wave_ctrl_r		<= 0;
	wave_qsel_r		<= 0;
	s1_axis_tvalid	<= 0;

	wait (tb_push_wave);

	#10000;

//	////////////////////
//	// Sine Wave test //
//	////////////////////
//
//	@(posedge aclk);
//	s1_axis_tvalid	<= 1;
//	wave_addr_r		<= 0;
//	wave_wait_r		<= 5;
//	wave_ctrl_r		<= 0;
//	wave_qsel_r		<= 2;
//
// 	@(posedge aclk);
// 	s1_axis_tvalid	<= 0;
//
//	#10000;

// 	//////////////////////
// 	// Phase reset test //
// 	//////////////////////
// 
// 	@(posedge aclk);
// 	s1_axis_tvalid	<= 1;
// 	wave_addr_r		<= 0;
// 	wave_wait_r		<= 0;
// 	wave_ctrl_r		<= 1; // reset-phase.
// 	wave_qsel_r		<= 0;
// 
// 	@(posedge aclk);
// 	s1_axis_tvalid	<= 1;
// 	wave_addr_r		<= 0;
// 	wave_wait_r		<= 0;
// 	wave_ctrl_r		<= 1; // reset-phase.
// 	wave_qsel_r		<= 0;
// 
// 	@(posedge aclk);
// 	s1_axis_tvalid	<= 1;
// 	wave_addr_r		<= 0;
// 	wave_wait_r		<= 0;
// 	wave_ctrl_r		<= 0; // don't reset-phase.
// 	wave_qsel_r		<= 0;
// 
// 	@(posedge aclk);
// 	s1_axis_tvalid	<= 1;
// 	wave_addr_r		<= 0;
// 	wave_wait_r		<= 0;
// 	wave_ctrl_r		<= 1; // reset-phase.
// 	wave_qsel_r		<= 0;
// 
// 	@(posedge aclk);
// 	s1_axis_tvalid	<= 0;
//
//	#1000;

	//////////////////////////
	// Waveform memory test //
	//////////////////////////

	// 
	@(posedge aclk);
	s1_axis_tvalid	<= 1;
	wave_addr_r		<= 0;
	wave_wait_r		<= 0;
	wave_ctrl_r		<= 3; // ctrl[2]: enable 31, ctrl[1]: saturate, ctrl[0]: phrst.
	wave_qsel_r		<= 2;

	@(posedge aclk);
	s1_axis_tvalid	<= 0;

	#10000;

	@(posedge aclk);
	s1_axis_tvalid	<= 1;
	wave_addr_r		<= 1;
	wave_wait_r		<= 0;
	wave_ctrl_r		<= 0;
	wave_qsel_r		<= 1;

	@(posedge aclk);
	s1_axis_tvalid	<= 1;
	wave_addr_r		<= 0;
	wave_wait_r		<= 52;
	wave_ctrl_r		<= 6; // ctrl[2]: enable 31, ctrl[1]: saturate, ctrl[0]: phrst.
	wave_qsel_r		<= 2;

	@(posedge aclk);
	s1_axis_tvalid	<= 1;
	wave_addr_r		<= 0;
	wave_wait_r		<= 2;
	wave_ctrl_r		<= 3;
	wave_qsel_r		<= 1;

	@(posedge aclk);
	s1_axis_tvalid	<= 0;
end

assign s1_axis_tdata = {wave_qsel_r,wave_ctrl_r,wave_wait_r,wave_addr_r};

always begin
	s_axi_aclk <= 0;
	#7;
	s_axi_aclk <= 1;
	#7;
end

always begin
	aclk <= 0;
	#5;
	aclk <= 1;
	#5;
end  

endmodule

