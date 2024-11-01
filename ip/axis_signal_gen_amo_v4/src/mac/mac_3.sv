// This module implements the following polynomial function:
// 
// y_out = c0 + (c1 + (c2 + c3*t)*t)*t
//
module mac_3
	#(
		// Number of bits of coefficients.
		parameter BC = 8,

		// Number of bits of t.
		parameter BT = 8,

		// Number of bits of y.
		parameter BY = 8
	)
	(
		// Reset and clock.
		input 	wire 			rstn	,
		input 	wire 			clk		,

		// Coefficients.
		input 	wire [BT-1:0]	t_in	,
		input 	wire [BC-1:0]	c0_in	,
		input 	wire [BC-1:0]	c1_in	,
		input 	wire [BC-1:0]	c2_in	,
		input 	wire [BC-1:0]	c3_in	,

		// Output data.
		output 	wire [BY-1:0]	y_out	,
		output	wire			y_valid
	);

/*************/
/* Internals */
/*************/
// Number of bits of additions.
// Dynamic range at stage outputs can grow. Last stage will get range back to [-1,1].
// I need ceil(log2(stages)) extra integer bits.
// Stages = 3, extra bits 2.
localparam BGUARD 	= 2;
localparam BADD 	= BC + BGUARD;

// Sign-extended coefficients.
wire signed	[BADD-1:0]	c0		;
wire signed	[BADD-1:0]	c1		;
wire signed	[BADD-1:0]	c2		;
wire signed	[BADD-1:0]	c3		;

// Latency for coefficients.
wire signed	[BADD-1:0]	c0_la	;
wire signed	[BADD-1:0]	c1_la	;

// MAC0.
wire 		[BT-1:0]	t0		;
wire 		[BADD-1:0]	y0		;

// MAC1.
wire 		[BT-1:0]	t1		;
wire 		[BADD-1:0]	y1		;

// MAC2.
wire 		[BT-1:0]	t2		;
wire 		[BADD-1:0]	y2		;

// Quantized addition.
wire		[BY-1:0]	yq		;
reg			[BY-1:0]	yq_r	;

// Valid.
reg                     valid_r	;

/****************/
/* Architecture */
/****************/
// Sign-extended coefficients.
assign c0	= {{BGUARD{c0_in[BC-1]}},c0_in};
assign c1	= {{BGUARD{c1_in[BC-1]}},c1_in};
assign c2	= {{BGUARD{c2_in[BC-1]}},c2_in};
assign c3	= {{BGUARD{c3_in[BC-1]}},c3_in};

// c0 latency.
// Latency: 6 from 2 x mac.
latency_reg
	#(
		// Latency.
		.N(6),

		// Data width.
		.B(BADD)
	)
	c0_la_i
	(
		// Reset and clock.
		.rstn	(rstn	),
		.clk	(clk	),

		// Data input.
		.din	(c0		),

		// Data output.
		.dout	(c0_la	)
	);

// c1 latency.
// Latency: 3 from 1 x mac.
latency_reg
	#(
		// Latency.
		.N(3),

		// Data width.
		.B(BADD)
	)
	c1_la_i
	(
		// Reset and clock.
		.rstn	(rstn	),
		.clk	(clk	),

		// Data input.
		.din	(c1		),

		// Data output.
		.dout	(c1_la	)
	);

// MAC0.
// Latency: 3.
// y0 = c2 + c3*t.
mac
	#(
		// Number of bits of c0 and c1.
		.BC(BADD),

		// Number of bits of t.
		.BT(BT),

		// Number of bits of y.
		.BY(BADD)
	)
	mac_0_i
	(
		// Reset and clock.
		.rstn	(rstn	),
		.clk	(clk	),

		// Input data.
		.c0		(c2		),
		.c1		(c3		),
		.t_in	(t_in	),

		// Output data.
		.t_out	(t0		),
		.y		(y0		)
	);

// MAC1.
// Latency: 3.
// y1 = c1 + y0*t.
mac
	#(
		// Number of bits of c0 and c1.
		.BC(BADD),

		// Number of bits of t.
		.BT(BT),

		// Number of bits of y.
		.BY(BADD)
	)
	mac_1_i
	(
		// Reset and clock.
		.rstn	(rstn	),
		.clk	(clk	),

		// Input data.
		.c0		(c1_la	),
		.c1		(y0		),
		.t_in	(t0		),

		// Output data.
		.t_out	(t1		),
		.y		(y1		)
	);

// MAC2.
// Latency: 3.
// y2 = c0 + y1*t.
mac
	#(
		// Number of bits of c0 and c1.
		.BC(BADD),

		// Number of bits of t.
		.BT(BT),

		// Number of bits of y.
		.BY(BADD)
	)
	mac_2_i
	(
		// Reset and clock.
		.rstn	(rstn	),
		.clk	(clk	),

		// Input data.
		.c0		(c0_la	),
		.c1		(y1		),
		.t_in	(t1		),

		// Output data.
		.t_out	(t2		),
		.y		(y2		)
	);

// Quantized addition: eliminate the extra BGUARD bits.
assign yq = y2 [BADD-BGUARD-1 -: BY];

// Registers.
always @(posedge clk) begin
	if (~rstn) begin
		// Registers.
		yq_r	<= 0;

		// Valid.
		valid_r	<= 0;
	end
	else begin
		// Registers.
		yq_r	<= yq	;

		// Valid.
		valid_r	<= 1;
	end
end 

// Assign outputs.
assign y_out 	= yq_r;
assign y_valid	= valid_r;

endmodule

