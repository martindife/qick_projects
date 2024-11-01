// This block instantiates the FIR core that implements
// x4 interpolation. Input is 4 complex samples, and 
// output is 16 complex samples.
//
// Two FIR cores are cascaded: x2 interpolation each.
module fir (
	// Clock.
	input	wire				clk		,

	// Input.
	input	wire	[4*32-1:0]	din		,

	// Output.
	output	wire	[16*32-1:0]	dout
	);

/********************/
/* Internal signals */
/********************/
// Pipeline registers.
reg		[4*32-1:0]	din_r			;
reg		[8*32-1:0]	din_1_r			;
reg		[16*32-1:0]	dout_r			;

// fir_0.
wire	[8*48-1:0]	dout_0			;
wire	[47:0]		dout_0_v	[8]	;
wire	[31:0]		dout_0_vq	[8]	;

// fir_1.
wire	[8*32-1:0]	din_1			;
wire	[16*48-1:0]	dout_1			;
wire	[47:0]		dout_1_v	[16];
wire	[31:0]		dout_1_vq	[16];
wire	[16*32-1:0]	dout_i			;

/****************/
/* Architecture */
/****************/
genvar i;
generate
	for (i=0; i<8; i=i+1) begin
		// fir_0.
		assign dout_0_v [i] = dout_0 [48*i +: 48];
		assign dout_0_vq[i]	= {dout_0_v[i][24+1 +: 16],dout_0_v[i][0+1 +: 16]};

		// fir_1.
		assign din_1 [32*i +: 32] = dout_0_vq[i];
	end
	for (i=0; i<16; i=i+1) begin
		// fir_0.
		assign dout_1_v [i] = dout_1 [48*i +: 48];
		assign dout_1_vq[i]	= {dout_1_v[i][24+1 +: 16],dout_1_v[i][0+1 +: 16]};
		assign dout_i [32*i +: 32] = dout_1_vq[i];
	end
endgenerate

// FIR 0.
fir_0 fir_0_i 
	(
		.aclk				(clk				),
		.s_axis_data_tvalid	(1'b1				),
		.s_axis_data_tready	(					),
		.s_axis_data_tdata	(din_r				),
		.m_axis_data_tvalid	(					),
		.m_axis_data_tdata	(dout_0				)
	);

// FIR 1.
fir_1 fir_1_i 
	(
		.aclk				(clk				),
		.s_axis_data_tvalid	(1'b1				),
		.s_axis_data_tready	(					),
		.s_axis_data_tdata	(din_1_r			),
		.m_axis_data_tvalid	(					),
		.m_axis_data_tdata	(dout_1				)
	);

// Registers.
always @(posedge clk) begin
	// Pipeline registers.
	din_r	<= din		;
	din_1_r	<= din_1	;
	dout_r	<= dout_i	;
end

/***********/
/* Outputs */
/***********/
assign dout	= dout_r;

endmodule

