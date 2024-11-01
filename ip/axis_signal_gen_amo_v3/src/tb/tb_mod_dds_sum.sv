module tb();

// Number of bits of t.
parameter BT 	= 8	;

// Memory length (bits).
parameter NMEM	= 8	;

// Number of DDSs (do not edit).
parameter NDDS 	= 32;

// Reset and clock.
reg					aresetn			;
reg					aclk			;

// Memory write.
reg		[NDDS-1:0]	mem_we			;
reg		[NMEM-1:0]	mem_waddr		;
wire	[255:0]		mem_din			;

// Memory read.
reg		[NMEM-1:0]	mem_raddr		;

// Time base.
reg		[BT-1:0]	t_in			;

// m_axis for data output.
wire				m_axis_tvalid	;
wire	[15:0]		m_axis_tdata	;
	
// Registers.
reg 	[4:0]		QSEL_REG		;

// Memory fields.
reg 	[17:0]	FMOD_C0_r	;
reg 	[17:0]	FMOD_C1_r	;
reg 	[17:0]	FMOD_C2_r	;
reg 	[17:0]	FMOD_C3_r	;
reg 	[17:0]	FMOD_C4_r	;
reg 	[17:0]	FMOD_C5_r	;
reg 	[17:0]	FMOD_G_r	;
reg 	[15:0]	AMOD_C0_r	;
reg 	[15:0]	AMOD_C1_r	;
reg		[17:0]	POFF_r		;
reg		[7:0]	CTRL_r		;

assign mem_din =	{	CTRL_r		,
						POFF_r		,
						AMOD_C1_r	,
						AMOD_C0_r	,
						FMOD_G_r	,
						FMOD_C5_r	,
						FMOD_C4_r	,
						FMOD_C3_r	,
						FMOD_C2_r	,
						FMOD_C1_r	,
						FMOD_C0_r	};

mod_dds_sum
	#(
		// Number of bits of t.
		.BT(BT),

		// Memory length (bits).
		.NMEM(NMEM)
	)
	DUT
	(
		// Reset and clock.
		.aresetn		,
		.aclk			,

		// Memory write.
		.mem_we			,
		.mem_waddr		,
		.mem_din		,

		// Memory read.
		.mem_raddr		,

		// Time base.
		.t_in			,

		// m_axis for data output.
		.m_axis_tvalid	,
		.m_axis_tdata	,
	
		// Registers.
		.QSEL_REG
	);

// Main TB.
initial begin
	aresetn		<= 0;
	mem_we		<= 0;
	mem_waddr	<= 0;
	mem_raddr	<= 0;
	QSEL_REG	<= 5;
	FMOD_C0_r	<= 0;
	FMOD_C1_r	<= 0;
	FMOD_C2_r	<= 0;
	FMOD_C3_r	<= 0;
	FMOD_C4_r	<= 0;
	FMOD_C5_r	<= 0;
	FMOD_G_r	<= 0;
	AMOD_C0_r	<= 0;
	AMOD_C1_r	<= 0;
	POFF_r		<= 0;
	CTRL_r		<= 0;
	#300;
	aresetn		<= 1;

	#1000;

	// Initialize memory.
	for (int i=0; i<2**NMEM; i=i+1) begin
		for (int j=0; j<NDDS; j=j+1) begin
			@(posedge aclk);	
			mem_we		<= 2**j;
			mem_waddr 	<= i;
		end
	end

	@(posedge aclk);
	mem_we <= 0;

	FMOD_C0_r	<= 0;
	FMOD_C1_r	<= -1365;
	FMOD_C2_r	<= 102400;
	FMOD_C3_r	<= -68267;
	FMOD_C4_r	<= 0;
	FMOD_C5_r	<= 0;
	FMOD_G_r	<= 32440;
	AMOD_C0_r	<= 32440;
	AMOD_C1_r	<= -16056;
	POFF_r		<= 0;
	CTRL_r		<= 0;

	// Write memories (1 at a time).
	mem_waddr	<= 0;
	for (int j=0; j<NDDS; j=j+1) begin
		@(posedge aclk);	
		mem_we		<= 2**j;
		@(posedge aclk);	
		mem_we		<= 0;
		#1000;
	end
end

always begin
	t_in <= 0;
	#10000;

	while(1) begin
		@(posedge aclk);
		t_in <= t_in + 1;
	end
end

always begin
	aclk <= 0;
	#1;
	aclk <= 1;
	#1;
end  

endmodule

