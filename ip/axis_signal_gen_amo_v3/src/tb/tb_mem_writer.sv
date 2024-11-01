module tb();

// Reset and clock.
reg 		rstn			;
reg 		clk				;

// AXIS for data input.
reg			s_axis_tvalid	;
wire		s_axis_tready	;
reg	[31:0]	s_axis_tdata	;
reg			s_axis_tlast	;

// Memory interface.
wire[15:0]	mem_addr		;
wire[255:0]	mem_din			;
wire[31:0]	mem_we			;

// Registers.
reg			START_REG		;

// Number of register blocks (max is 32).
parameter 	NB = 16;

// Number of registers.
parameter	NREG = 12;

reg	tb_data_start = 0;

// DUT.
mem_writer DUT
	(
		// Reset and clock.
		.rstn			,
		.clk			,

		// AXIS for data input.
		.s_axis_tvalid	,
		.s_axis_tready	,
		.s_axis_tdata	,
		.s_axis_tlast	,
	
		// Memory interface.
		.mem_addr		,
		.mem_din		,
		.mem_we			,
		
		// Registers.
		.START_REG
	);

// Main TB.
initial begin
	rstn		<= 0;
	START_REG	<= 0;
	#300;
	rstn		<= 1;

	#500;

	START_REG <= 1;
	
	#200;
	
	tb_data_start <= 1;

end

// Data writing.
initial begin
	s_axis_tvalid 	<= 0;
	s_axis_tdata	<= 0;
	s_axis_tlast	<= 0;

	//wait(tb_data_start);

	// First NB-1 blocks.
	for (int i=0; i<NB-1; i=i+1) begin
		@(posedge clk);
		wait (s_axis_tready == 1'b1);
		// Address.
		@(posedge clk);
		s_axis_tvalid 	<= 1;
		s_axis_tdata	<= i;

		// Registers.
		for (int j=0; j<NREG; j=j+1) begin
			@(posedge clk);
			s_axis_tvalid	<= 1;
			s_axis_tdata 	<= NREG*i + j;	
		end
	end

	@(posedge clk);
	wait (s_axis_tready == 1'b1);
	// Address.
	@(posedge clk);
	s_axis_tvalid 	<= 1;
	s_axis_tdata	<= NB-1;

	// Registers.
	for (int j=0; j<NREG-1; j=j+1) begin
		@(posedge clk);
		s_axis_tvalid	<= 1;
		s_axis_tdata 	<= NREG*(NB-1) + j;	
	end

	// Last.
	@(posedge clk);
	s_axis_tvalid	<= 1;
	s_axis_tdata 	<= NREG*(NB-1) + NREG-1;	
	s_axis_tlast	<= 1;
end

always begin
	clk <= 0;
	#5;
	clk <= 1;
	#5;
end  

endmodule

