module tb;


// Number of inputs.
parameter L	= 4;


// Reset and clock.
reg 		aresetn		;
reg 		aclk		;

// Active window.
reg			start		;

// Input triggers.
reg [L-1:0]	din			;

// Handshake with memory writer.
wire		write		;
reg			write_ack	;

// TB control.
reg tb_ack;

// DUT.
qual
	#(
		// Number of inputs.
		.L(L)
	)
	DUT
	(
		// Reset and clock.
		.aresetn	,
		.aclk		,

		// Active window.
		.start		,

		// Input triggers.
		.din		,

		// Handshake with memory writer.
		.write		,
		.write_ack
	);

initial begin
	aresetn 	<= 0;
	start		<= 0;
	din			<= 0;
	write_ack	<= 0;
	tb_ack		<= 0;
	#200;
	aresetn		<= 1;

	#100;

	start	<= 1;
	tb_ack	<= 1;

	for (int i=0; i<100; i++) begin
		#100;
		@(posedge aclk);
		din <= 4'b0011;

		@(posedge aclk);
		din <= 4'b0000;
	end
end

initial begin
	wait(tb_ack);

	while(1) begin
		wait (write == 1'b1);
		@(posedge aclk);
		write_ack <= 1;
		#200;
		wait (write == 1'b0);
		@(posedge aclk);
		write_ack <= 0;
	end
end

always begin
	aclk <= 0;
	#5;
	aclk <= 1;
	#5;
end

endmodule

