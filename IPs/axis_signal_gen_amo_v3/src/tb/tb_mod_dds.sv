module tb();


// Number of bits of t.
parameter BT = 16;

// Reset and clock.
reg 				rstn		;
reg 				clk			;

// Memory output with parameters.
wire	[255:0]		mem_dout	;

// Time base.
reg 	[BT-1:0]	t_in		;

// Output data.
wire 	[15:0]		dout		;

// Registers.
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

assign mem_dout =	{	CTRL_r		,
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

// mod_dds.
mod_dds
	#(
		// Number of bits of t.
		.BT(BT)
	)
	DUT
	(
		// Reset and clock.
		.rstn		,
		.clk		,

		// Memory output with parameters.
		.mem_dout	,

		// Time base.
		.t_in		,

		// Output data.
		.dout
	);

// Main TB.
initial begin
	rstn		<= 0;
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
	#300;
	rstn		<= 1;
end

always begin
	t_in <= 0;
	#10000;

	while(1) begin
		@(posedge clk);
		t_in <= t_in + 1;
	end
end

always begin
	clk <= 0;
	#1;
	clk <= 1;
	#1;
end  

endmodule

