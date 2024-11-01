// Width converter for ADC/DAC on RFSoC 4x2.
//
// B = 16 bits.
//
// Number of input samples is fixed = 12 (max allowed by ADC) : 192-bits.
// Number of output samples is fixed = 16 (max allowed by DAC): 256-bits.
//
// The block captures 4 blocks (48 samples), and then outputs 3 blocks.
//
// Input should be always valid.
//
module wconv
	(
		// Reset and clock.
		input	wire			aresetn			,
		input	wire			aclk			,

		// S_AXIS for input data.
		input	wire 			s_axis_tvalid	,
		input	wire 	[191:0]	s_axis_tdata	,

		// M_AXIS for output data.
		output	wire			m_axis_tvalid	,
		output	wire	[255:0]	m_axis_tdata
	);

/********************/
/* Internal signals */
/********************/
// Pipeline registers.
reg		[191:0]	din_r1		;
reg		[191:0]	din0_r		;
reg		[191:0]	din1_r		;
reg		[191:0]	din2_r		;

// Combined 48 samples (16, 16, 16).
wire	[255:0]	dcomb0		;
wire	[255:0]	dcomb1		;
wire	[255:0]	dcomb2		;

// Output registers.
reg		[255:0]	dcomb0_r		;
reg		[255:0]	dcomb1_r		;
reg		[255:0]	dcomb2_r		;

// Output mux.
wire	[255:0]	dout_mux	;

// Counter.
reg		[1:0]	cnt			;
reg		[1:0]	cnt_r1		;
reg		[1:0]	cnt_r2		;

/**********************/
/* Begin Architecture */
/**********************/
// Combined 48 samples.
assign dcomb0 = {din_r1[0 +: 64]	, din0_r			}; // 192 bits from din0, 64 bits from din.
assign dcomb1 = {din_r1[0 +: 128]	, din1_r[64  +: 128]}; // 128 bits from din1, 128 bits from din.
assign dcomb2 = {din_r1				, din2_r[128 +: 64]	}; // 64 bits from din2, 192 bits from din.

// Output mux.
assign dout_mux = 	(cnt_r2 == 0)? dcomb0_r :
					(cnt_r2 == 1)? dcomb1_r : dcomb2_r;

// Registers.
always @(posedge aclk) begin
	if (~aresetn) begin
		cnt	<= 0;
	end
	else begin
		// Pipeline registers.
		din_r1 <= s_axis_tdata;
		if (cnt == 0)
			din0_r <= din_r1;
		if (cnt == 1)
			din1_r <= din_r1;
		if (cnt == 2)
			din2_r <= din_r1;

		// Output registers.
		dcomb0_r <= dcomb0;
		dcomb1_r <= dcomb1;
		dcomb2_r <= dcomb2;

		// Counter.
		cnt 	<= cnt + 1;
		cnt_r1	<= cnt;
		cnt_r2	<= cnt_r1;
	end
end

// Assign outputs.
assign m_axis_tvalid = (cnt_r2 == 3)? 1'b0 : 1'b1;
assign m_axis_tdata	 = dout_mux;

endmodule

