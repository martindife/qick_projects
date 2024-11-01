module tb;


// Memory Size.
parameter N	= 8	;

// Bits.
parameter B = 4	;


// Reset and clock.
reg 		aresetn		;
reg 		aclk		;

// Input data.
reg	[B-1:0]	din			;

// Handshake.
reg			write		;
wire		write_ack	;

// Memory interface.
wire		mem_we		;
wire[N-1:0]	mem_addr	;
wire[B-1:0]	mem_di		;

// Registers.
reg			START_REG	;
reg	[N-1:0]	ADDR_REG	;
reg	[N-1:0]	NSAMP_REG	;

// TB control.
reg tb_data;
reg tb_write;

// DUT.
write_mem
	#(
		// Memory Size.
		.N(N),

		// Bits.
		.B(B)
	)
	DUT
	(
		// Reset and clock.
		.aresetn	,
		.aclk		,

		// Input data.
		.din		,

		// Handshake.
		.write		,
		.write_ack	,

		// Memory interface.
		.mem_we		,
		.mem_addr	,
		.mem_di		,

		// Registers.
		.START_REG	,
		.ADDR_REG	,
		.NSAMP_REG
	);

initial begin
	aresetn 	<= 0;
	START_REG	<= 0;
	ADDR_REG	<= 0;
	NSAMP_REG	<= 0;
	tb_data		<= 0;
	tb_write	<= 0;
	#200;
	aresetn		<= 1;

	#100;

	// Program block.
	ADDR_REG	<= 0;
	NSAMP_REG	<= 10;

	#100;

	// Start.
	tb_data		<= 1;
	tb_write	<= 1;
	START_REG	<= 1;

	#3000;

	// Program block.
	ADDR_REG	<= 7;
	NSAMP_REG	<= 5;

	// Stop/start.
	START_REG	<= 0;
	#200;
	START_REG	<= 1;
end

// Input data.
initial begin
	din			<= 0;
	wait(tb_data);

	while(1) begin
		@(posedge aclk);
		din	<= $random;
	end
end

// Write flag.
initial begin
	write		<= 0;
	wait(tb_write);

	#200;

	while(1) begin
		@(posedge aclk);
		write <= 1'b1;
		wait (write_ack == 1'b1);
		@(posedge aclk);
		write <= 1'b0;
		wait (write_ack == 1'b0);
		#80;
	end
end

always begin
	aclk <= 0;
	#5;
	aclk <= 1;
	#5;
end

endmodule

