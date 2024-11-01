module tb();


// Number of bits of coefficients.
parameter BC = 16;

// Number of bits of t.
parameter BT = 12;

// Number of bits of y.
parameter BY = 10;

// Reset and clock.
reg 			rstn	;
reg 			clk		;

// Input data.
reg  [BT-1:0]	t_in	;
reg  [BC-1:0]	c0_in	;
reg  [BC-1:0]	c1_in	;
reg  [BC-1:0]	c2_in	;
reg  [BC-1:0]	c3_in	;
reg  [BC-1:0]	c4_in	;
reg  [BC-1:0]	c5_in	;

// Gain.
reg  [BY-1:0]	g_in	;

// Output data.
wire [BY-1:0]	y_out	;
wire			y_valid	;

// DUT.
mac_5
	#(
		// Number of bits of coefficients.
		.BC(BC),

		// Number of bits of t.
		.BT(BT),

		// Number of bits of y.
		.BY(BY)
	)
	DUT
	(
		// Reset and clock.
		.rstn	,
		.clk	,

		// Coefficients.
		.t_in	,
		.c0_in	,
		.c1_in	,
		.c2_in	,
		.c3_in	,
		.c4_in	,
		.c5_in	,

		// Gain.
		.g_in	,

		// Output data.
		.y_out	,
		.y_valid
	);

// Main TB.
initial begin
	rstn	<= 0;
	t_in	<= 0;
	c0_in	<= 0;
	c1_in	<= -626;
	c2_in	<= 16062;
	c3_in	<= -17029;
	c4_in	<= 9481;
	c5_in	<= -3793;
	g_in	<= 2**(BC-1)-1;
	#300;
	rstn		<= 1;

	#500;

	for (int i=0; i<2**(BT-1)-1; i=i+1) begin
		@(posedge clk);
		t_in <= i;
	end

end

always begin
	clk <= 0;
	#5;
	clk <= 1;
	#5;
end  

endmodule

