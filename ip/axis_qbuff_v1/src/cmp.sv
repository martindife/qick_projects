// This block compares the input data with a fixed threshold. The output flag
// indicates when the input is greater than or smaller than the given value.
// This is configured by the MODE_REG as follows:
// 
// * 0 : flag = 1 when din > THR_REG
// * 1 : flag = 1 when din < THR_REG
module cmp
	#(
		// Delay line length.
		parameter DLY	= 2	,

		// Bits.
		parameter B		= 8
	)
	(
		// Reset and clock.
		input 	wire 		aresetn		,
		input 	wire 		aclk		,

		// Input data.
		input	wire [B-1:0]din			,

		// Delayed data.
		output	wire [B-1:0]dout		,

		// Comparison flag.
		output	wire		flag		,

		// Registers.
		input	wire		MODE_REG	,
		input	wire [B-1:0]THR_REG
	);

/*************/
/* Internals */
/*************/
// Re-sync registers.
reg					MODE_REG_r;
reg			[B-1:0]	THR_REG_r;

// Input data pipe registers.
reg			[B-1:0]	din_r1;
reg			[B-1:0]	din_r2;

// Delayed data.
wire		[B-1:0]	din_la;

// Signed comparison values.
wire signed	[B-1:0]	din_s;
wire signed	[B-1:0]	thr_s;

// Flags.
wire				ggg;
wire				lll;

/****************/
/* Architecture */
/****************/

// Delayed input data (for non-causal memory write).
latency_reg
	#(
		// Latency.
		.N	(DLY),

		// Data width.
		.B	(B	)
	)
	din_dly
	(
		// Reset and clock.
		.rstn	(aresetn	),
		.clk	(aclk		),

		// Data input.
		.din	(din_r2		),

		// Data output.
		.dout	(din_la		)
	);

// Signed comparison values.
assign din_s = din_r2;
assign thr_s = THR_REG_r;

// Flags.
assign ggg = (din_s > thr_s)? 1'b1 : 1'b0;
assign lll = (din_s < thr_s)? 1'b1 : 1'b0;

// Registers.
always @(posedge aclk) begin
	if (~aresetn) begin
		// Re-sync registers.
		MODE_REG_r	<= 0;
		THR_REG_r	<= 0;

		// Input data pipe registers.
		din_r1		<= 0;
		din_r2		<= 0;
	end
	else begin
		// Re-sync registers.
		MODE_REG_r	<= MODE_REG;
		THR_REG_r	<= THR_REG;

		// Input data pipe registers.
		din_r1		<= din;
		din_r2		<= din_r1;
	end
end 

// Assign outputs.
assign dout	= din_la;
assign flag	= (MODE_REG_r == 1'b1)? lll : ggg;

endmodule

