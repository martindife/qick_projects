module tb();


// Number of bits of t.
parameter BT = 16;

// Reset and clock.
reg 			rstn		;
reg 			clk			;

// Trigger.
reg				trigger		;

// Output data.
wire 	[15:0]	dout		;

// Registers.
reg 	[BT-1:0]WAIT_REG	;
reg 	[17:0]	FMOD_C0_REG	;
reg 	[17:0]	FMOD_C1_REG	;
reg 	[17:0]	FMOD_C2_REG	;
reg 	[17:0]	FMOD_C3_REG	;
reg 	[17:0]	FMOD_C4_REG	;
reg 	[17:0]	FMOD_C5_REG	;
reg 	[17:0]	FMOD_G_REG	;
reg 	[15:0]	AMOD_C0_REG	;
reg 	[15:0]	AMOD_C1_REG	;
reg		[17:0]	POFF_REG	;
reg				WE_REG		;

// mod_dds.
mod_dds
	#(
		// Number of bits of t.
		.BT(BT)
	)
	DUT
	(
		// Reset and clock.
		.rstn			,
		.clk			,
	
		// Trigger.
		.trigger		,

		// Output data.
		.dout			,

		// Registers.
		.WAIT_REG		,
		.FMOD_C0_REG	,
		.FMOD_C1_REG	,
		.FMOD_C2_REG	,
		.FMOD_C3_REG	,
		.FMOD_C4_REG	,
		.FMOD_C5_REG	,
		.FMOD_G_REG		,
		.AMOD_C0_REG	,
		.AMOD_C1_REG	,
		.POFF_REG		,
		.WE_REG
	);

// Main TB.
initial begin
	rstn		<= 0;
	trigger		<= 0;
	WAIT_REG	<= 0;
	FMOD_C0_REG	<= 0;
	FMOD_C1_REG	<= -1365;
	FMOD_C2_REG	<= 102400;
	FMOD_C3_REG	<= -68267;
	FMOD_C4_REG	<= 0;
	FMOD_C5_REG	<= 0;
	FMOD_G_REG	<= 32440;
	AMOD_C0_REG	<= 232440;
	AMOD_C1_REG	<= -16056;
	POFF_REG	<= 0;
	WE_REG		<= 0;
	#300;
	rstn		<= 1;

	#500;

	WE_REG	<= 1;

	#100;

	WE_REG	<= 0;

	#300;

	trigger <= 1;
	
	#90000;
	
	trigger <= 0;
	
	#2000;
	
	trigger <= 1;

end

always begin
	clk <= 0;
	#1;
	clk <= 1;
	#1;
end  

endmodule

