module tb;

// Number of stages.
parameter N = 10;

// reset and clock.
reg		aresetn	;
reg		aclk	;

// Input/output.
reg		din		;
wire	dout	;

// DUT.
debouncer
	#(
		// Number of stages.
		.N(N)
	)
	DUT
	(
		// reset and clock.
		.aresetn	,
		.aclk		,

		// Input/output.
		.din		,
		.dout
	);

// Main TB.
initial begin
	aresetn	<= 0;
	din		<= 0;
	#300;
	aresetn	<= 1;

	#1000;
	
	din <= 1;
	
	#200;

	din <= 0;
	
end

// aclk;
always begin
	aclk	<= 0;
	#7;
	aclk	<= 1;
	#7;
end

endmodule

