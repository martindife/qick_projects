module tb;

// Delay line length.
parameter DLY = 20;

// Reset and clock.
reg 		aresetn	;
reg 		aclk	;

// Input data.
reg signed [15:0]	din		;

// Delayed data.
wire[15:0]	dout	;

// Comparison flag.
wire		flag	;

// Registers.
reg			MODE_REG;
reg [15:0]	THR_REG	;

// DUT.
comp
	#(
		// Delay line length.
		.DLY(DLY)
	)
	DUT
	(
		// Reset and clock.
		.aresetn	,
		.aclk		,

		// Input data.
		.din		,

		// Delayed data.
		.dout		,

		// Comparison flag.
		.flag		,

		// Registers.
		.MODE_REG	,
		.THR_REG
	);

initial begin
	aresetn 	<= 0;
	din			<= 0;
	MODE_REG	<= 1;
	THR_REG		<= -20000;
	#200;
	aresetn		<= 1;

	#100;

	for (int i=0; i<500; i++) begin
		@(posedge aclk);
		din	<= $random;	
	end
end

always begin
	aclk <= 0;
	#5;
	aclk <= 1;
	#5;
end

endmodule

