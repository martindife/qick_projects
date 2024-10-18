// This block computes the linear function:
// 
// y = c0 + c1 * t
// 
// which can be further used to implement polynomial evaluation.
module mac
	#(
		// Number of bits of c0 and c1.
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

		// Input data.
		input 	wire [BC-1:0]	c0		,
		input 	wire [BC-1:0]	c1		,
		input 	wire [BT-1:0]	t_in	,

		// Output data.
		output 	wire [BT-1:0]	t_out	,
		output 	wire [BY-1:0]	y
	);

/*************/
/* Internals */
/*************/
// Number of bits of product.
localparam BP = BC + BT;

// Signed inputs.
wire signed	[BC-1:0]	c0_s		;
wire signed	[BC-1:0]	c1_s		;
wire signed	[BT-1:0]	t_s			;

// Sign-extended c0 for addition.
wire signed	[BY-1:0]	c0_se		;

// Pipeline registers.
reg			[BT-1:0]	t_r1		;
reg			[BT-1:0]	t_r2		;
reg	 signed	[BY-1:0]	prod_q_r1	;
reg			[BY-1:0]	acc_r1		;

// Product.
wire signed	[BP-1:0]	prod		;
wire signed	[BY-1:0]	prod_q		;

// Accumulator.
wire signed	[BY-1:0]	acc			;

/****************/
/* Architecture */
/****************/

// Signed inputs.
assign c0_s		= c0;
assign c1_s		= c1;
assign t_s		= t_in;

// Sign-extended c0 for addition.
generate
	if ( BY <= BC) begin: GEN_c0
		assign c0_se = c0_s;
	end
	else begin
		assign c0_se = {c0_s,{(BY-BC){1'b0}}};
	end
endgenerate

// Product.
assign prod		= c1_s*t_s;
assign prod_q	= prod [BP-2 -: BY];

// Accumulator.
assign acc		= prod_q_r1 + c0_se;

// Registers.
always @(posedge clk) begin
	if (~rstn) begin
		// Pipeline registers.
		t_r1		<= 0;
		t_r2		<= 0;
		prod_q_r1	<= 0;
		acc_r1		<= 0;
	end
	else begin
		// Pipeline registers.
		t_r1		<= t_in		;
		t_r2		<= t_r1		;
		prod_q_r1	<= prod_q	;
		acc_r1		<= acc		;
	end
end 


// Assign outputs.
assign t_out = t_r2		;
assign y 	 = acc_r1	;

endmodule

