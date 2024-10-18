module tb;

// Delay line length.
parameter DLY	= 20	;

// Bits.
parameter B		= 16	;

// Number of lanes.
parameter L		= 4		;

// Memory Size.
parameter N		= 10	;

// Reset and clock.
reg 			aresetn			;
reg 			aclk			;

// Input data.
wire [L*B-1:0]	din				;

// Active window.
reg				trigger			;

// Memory interface.
wire			mem_we			;
wire [N-1:0]	mem_addr		;
wire [L*B-1:0]	mem_di			;

// Registers.
reg				COMP_MODE_REG	;
reg [B-1:0]		COMP_THR_REG	;
reg				WMEM_START_REG	;
reg [N-1:0]		WMEM_ADDR_REG	;
reg [N-1:0]		WMEM_NSAMP_REG	;

// Input data vector.
reg 			aclk_f			;
reg [B-1:0]		din_v [L]		;
reg [B-1:0]		din_f			;


genvar i;
generate
	for (i=0; i<L; i++) begin
		assign din[i*B +: B] = din_v[i];
	end
endgenerate

// TB control.
reg tb_data;

// DUT.
qbuff
	#(
		// Delay line length.
		.DLY(DLY),

		// Bits.
		.B(B),

		// Number of lanes.
		.L(L),

		// Memory Size.
		.N(N)
	)
	DUT
	(
		// Reset and clock.
		.aresetn		,
		.aclk			,

		// Input data.
		.din			,

		// Active window.
		.trigger		,

		// Memory interface.
		.mem_we			,
		.mem_addr		,
		.mem_di			,

		// Registers.
		.COMP_MODE_REG	,
		.COMP_THR_REG	,
		.WMEM_START_REG	,
		.WMEM_ADDR_REG	,
		.WMEM_NSAMP_REG
	);


initial begin
	aresetn 		<= 0;
	trigger			<= 0;
	COMP_MODE_REG	<= 0;
	COMP_THR_REG	<= 0;
	WMEM_START_REG	<= 0;
	WMEM_ADDR_REG	<= 0;
	WMEM_NSAMP_REG	<= 0;
	tb_data			<= 0;
	#200;
	aresetn			<= 1;

	#100;

	// Program block.
	COMP_MODE_REG	<= 0;
	COMP_THR_REG	<= 15000;
	WMEM_ADDR_REG	<= 0;
	WMEM_NSAMP_REG	<= 39;

	#100;

	// Start.
	tb_data		    <= 1;
	WMEM_START_REG	<= 1;

	#3000;

	// Start window.
	@(posedge aclk);
	trigger <= 1;
	#4000;
	@(posedge aclk);
	trigger <= 0;

	// Program block.
	COMP_MODE_REG	<= 1;
	COMP_THR_REG	<= -2000;
	WMEM_ADDR_REG	<= 5;
	WMEM_NSAMP_REG	<= 59;
	WMEM_START_REG	<= 0;
	#100;
	WMEM_START_REG	<= 1;

	#2000;

	// Start window.
	@(posedge aclk);
	trigger <= 1;
	#6000;
	@(posedge aclk);
	trigger <= 0;
end

// Input data.
initial begin
	for (int i=0; i<L; i++) begin
		din_v[i] <= 0;
	end

	wait(tb_data);

	while(1) begin

		for (int j=0; j<10; j++) begin
			@(posedge aclk);
			for (int i=0; i<L; i++) begin
				@(posedge aclk_f);
				din_v[i] <= 0;
			end
		end

		@(posedge aclk);
		@(posedge aclk_f);
		din_v[0] <= 2500;
		@(posedge aclk_f);
		din_v[1] <= 5500;
		@(posedge aclk_f);
		din_v[2] <= 15500;
		@(posedge aclk_f);
		din_v[3] <= 1500;
		@(posedge aclk);
		@(posedge aclk_f);
		din_v[0] <= -2500;
		@(posedge aclk_f);
		din_v[1] <= -2800;
		@(posedge aclk_f);
		din_v[2] <= -2300;
		@(posedge aclk_f);
		din_v[3] <= -1500;

		for (int j=0; j<90; j++) begin
			@(posedge aclk);
			for (int i=0; i<L; i++) begin
				@(posedge aclk_f);
				din_v[i] <= 324*i;
			end
		end
	end
end

initial begin
	while(1) begin
		for (int i=0; i<L; i++) begin
			@(posedge aclk_f);
			din_f <= din_v[i];
		end
	end
end

always begin
	aclk <= 0;
	#L;
	aclk <= 1;
	#L;
end

always begin
	aclk_f <= 0;
	#1;
	aclk_f <= 1;
	#1;
end

endmodule

