module tb();

// Number of registers.
parameter NREG = 10;


// Reset and clock.
reg 		rstn			;
reg 		clk				;

// AXIS for data input.
reg			s_axis_tvalid	;
wire		s_axis_tready	;
reg	[31:0]	s_axis_tdata	;
reg			s_axis_tlast	;

// Write Enable Vector.
wire[63:0]	we				;

// Register outputs.
wire[31:0]	reg00_out		;
wire[31:0]	reg01_out		;
wire[31:0]	reg02_out		;
wire[31:0]	reg03_out		;
wire[31:0]	reg04_out		;
wire[31:0]	reg05_out		;
wire[31:0]	reg06_out		;
wire[31:0]	reg07_out		;
wire[31:0]	reg08_out		;
wire[31:0]	reg09_out		;
wire[31:0]	reg10_out		;
wire[31:0]	reg11_out		;
wire[31:0]	reg12_out		;
wire[31:0]	reg13_out		;
wire[31:0]	reg14_out		;
wire[31:0]	reg15_out		;

// Registers.
reg			START_REG		;

// Number of register blocks (max is 64).
parameter 	NB = 16;

reg	tb_data_start = 0;

// reg_writer.
reg_writer
	#(
		.NREG(NREG)
	)
	reg_writer_i
	(
		// Reset and clock.
		.rstn			,
		.clk			,

		// AXIS for data input.
		.s_axis_tvalid	,
		.s_axis_tready	,
		.s_axis_tdata	,
		.s_axis_tlast	,
	
		// Write Enable Vector.
		.we				,
		
		// Register outputs.
		.reg00_out		,
		.reg01_out		,
		.reg02_out		,
		.reg03_out		,
		.reg04_out		,
		.reg05_out		,
		.reg06_out		,
		.reg07_out		,
		.reg08_out		,
		.reg09_out		,
		.reg10_out		,
		.reg11_out		,
		.reg12_out		,
		.reg13_out		,
		.reg14_out		,
		.reg15_out		,

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

