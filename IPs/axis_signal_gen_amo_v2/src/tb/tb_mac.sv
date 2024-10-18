module tb();


// Number of bits of c0 and c1.
parameter BC = 8;

// Number of bits of t.
parameter BT = 8;

// Number of bits of y.
parameter BY = 10;

// Reset and clock.
reg 			rstn	;
reg 			clk		;

// Input data.
reg  [BC-1:0]	c0		;
reg  [BC-1:0]	c1		;
reg  [BT-1:0]	t_in	;

// Output data.
wire [BT-1:0]	t_out	;
wire [BY-1:0]	y		;

// DUT.
mac
	#(
		// Number of bits of c0 and c1.
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

		// Input data.
		.c0		,
		.c1		,
		.t_in	,

		// Output data.
		.t_out	,
		.y
	);

// Main TB.
initial begin
	rstn	<= 0;
	c0		<= 12;
	c1		<= 6;
	t_in	<= 0;
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

