// This block implements a simple mixer.
// Input is I,Q. Output is real.
//
// Mixer modes are:
// 0 : no mixer, 0 frequency.
// 1 : mix by pi/2 (1,-1,1,-1,...)
// 2 : mix by pi/4 (1,i,-1,-i,1,i,...)
module mixer (
	// Clock.
	input	wire				clk		,

	// Input.
	input	wire	[16*32-1:0]	din		,

	// Output.
	output	wire	[16*16-1:0]	dout	,

	// Registers.
	input	wire	[1:0]		MODE_REG
	);

/********************/
/* Internal signals */
/********************/
// Pipeline registers.
reg		[16*32-1:0]	din_r			;
reg		[16*16-1:0]	dout_r			;

// Real/Imatinary input vector.
wire	[15:0]		din_iv	[16]	;
wire	[15:0]		din_qv	[16]	;

// Mixer.
wire	[15:0]		dmux_v	[16]	;

// Output.
wire	[16*16-1:0]	dmux			;

/****************/
/* Architecture */
/****************/
genvar i;
generate
	for (i=0; i<16; i=i+1) begin
		// Real/Imatinary input vector.
		assign din_iv [i] = din_r [32*i		+: 16];
		assign din_qv [i] = din_r [32*i+16	+: 16];

		// Output.
		assign dmux [16*i +: 16] = dmux_v[i];
	end

	for (i=0; i<4; i=i+1) begin
		// Mixer.
		assign dmux_v [0+4*i]	= 	din_iv [0+4*i];
		assign dmux_v [1+4*i]	=	(MODE_REG == 1)? -din_iv[1+4*i] :
									(MODE_REG == 2)? -din_qv[1+4*i] : din_iv[1+4*i];
		assign dmux_v [2+4*i] 	= 	(MODE_REG == 2)? -din_iv[2+4*i] : din_iv[2+4*i];
		assign dmux_v [3+4*i] 	= 	(MODE_REG == 1)? -din_iv[3+4*i] :
									(MODE_REG == 2)?  din_qv[3+4*i] : din_iv[3+4*i];

	end
endgenerate


// Registers.
always @(posedge clk) begin
	// Pipeline registers.
	din_r	<= din	;
	dout_r	<= dmux	;
end

/***********/
/* Outputs */
/***********/
assign dout	= dout_r;

endmodule

