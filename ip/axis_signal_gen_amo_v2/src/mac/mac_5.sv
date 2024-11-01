// This module implements the following polynomial function:
// 
// y_out = c0 + (c1 + (c2 + (c3 + (c4 + c5*t)*t)*t)*t)*t
//
module mac_5
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
		input 	wire [BC-1:0]	c4_in	,
		input 	wire [BC-1:0]	c5_in	,

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
// Stages = 5, extra bits 3.
localparam BGUARD 	= 3;
localparam BADD 	= BC + BGUARD;

// Sign-extended coefficients.
wire signed	[BADD-1:0]	c0	;
wire signed	[BADD-1:0]	c1	;
wire signed	[BADD-1:0]	c2	;
wire signed	[BADD-1:0]	c3	;
wire signed	[BADD-1:0]	c4	;
wire signed	[BADD-1:0]	c5	;

// MAC0.
wire 		[BT-1:0]	t0	;
wire 		[BADD-1:0]	y0	;

// MAC1.
wire 		[BT-1:0]	t1	;
wire 		[BADD-1:0]	y1	;

// MAC2.
wire 		[BT-1:0]	t2	;
wire 		[BADD-1:0]	y2	;

// MAC3.
wire 		[BT-1:0]	t3	;
wire 		[BADD-1:0]	y3	;

// MAC4.
wire 		[BT-1:0]	t4	;
wire 		[BADD-1:0]	y4	;

// Quantized addition.
wire		[BY-1:0]	yq	;
reg			[BY-1:0]	yq_r;

// Valid.
reg                     valid_r;

/****************/
/* Architecture */
/****************/
// Sign-extended coefficients.
assign c0	= {{BGUARD{c0_in[BC-1]}},c0_in};
assign c1	= {{BGUARD{c1_in[BC-1]}},c1_in};
assign c2	= {{BGUARD{c2_in[BC-1]}},c2_in};
assign c3	= {{BGUARD{c3_in[BC-1]}},c3_in};
assign c4	= {{BGUARD{c4_in[BC-1]}},c4_in};
assign c5	= {{BGUARD{c5_in[BC-1]}},c5_in};

// MAC0.
// Latency: 2.
// y0 = c4 + c5*t.
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
		.c0		(c4		),
		.c1		(c5		),
		.t_in	(t_in	),

		// Output data.
		.t_out	(t0		),
		.y		(y0		)
	);

// MAC1.
// Latency: 2.
// y1 = c3 + y0*t.
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
		.c0		(c3		),
		.c1		(y0		),
		.t_in	(t0		),

		// Output data.
		.t_out	(t1		),
		.y		(y1		)
	);

// MAC2.
// Latency: 2.
// y2 = c2 + y1*t.
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
		.c0		(c2		),
		.c1		(y1		),
		.t_in	(t1		),

		// Output data.
		.t_out	(t2		),
		.y		(y2		)
	);

// MAC3.
// Latency: 2.
// y3 = c1 + y2*t.
mac
	#(
		// Number of bits of c0 and c1.
		.BC(BADD),

		// Number of bits of t.
		.BT(BT),

		// Number of bits of y.
		.BY(BADD)
	)
	mac_3_i
	(
		// Reset and clock.
		.rstn	(rstn	),
		.clk	(clk	),

		// Input data.
		.c0		(c1		),
		.c1		(y2		),
		.t_in	(t2		),

		// Output data.
		.t_out	(t3		),
		.y		(y3		)
	);

// MAC4.
// Latency: 2.
// y4 = c0 + y3*t.
mac
	#(
		// Number of bits of c0 and c1.
		.BC(BADD),

		// Number of bits of t.
		.BT(BT),

		// Number of bits of y.
		.BY(BADD)
	)
	mac_4_i
	(
		// Reset and clock.
		.rstn	(rstn	),
		.clk	(clk	),

		// Input data.
		.c0		(c0		),
		.c1		(y3		),
		.t_in	(t3		),

		// Output data.
		.t_out	(t4		),
		.y		(y4		)
	);

// Quantized addition: eliminate the extra BGUARD bits.
assign yq = y4 [BADD-BGUARD-1 -: BY];

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
