module tb;

parameter B 	= 16;
parameter NIN 	= 12;
parameter NOUT 	= 16;

reg				aresetn			;
reg				aclk			;
reg 			s_axis_tvalid	;
wire 	[191:0]	s_axis_tdata	;
wire			m_axis_tvalid	;
wire	[255:0]	m_axis_tdata	;

// Data input.
reg		[B-1:0]	din_r	[NIN]	;

// Data output.
wire	[B-1:0]	dout_v	[NOUT]	;

genvar i;
generate 
	for (i=0; i<NIN; i=i+1) begin
		assign s_axis_tdata[i*B +: B] = din_r[i];
	end
	for (i=0; i<NOUT; i=i+1) begin
		assign dout_v[i] = m_axis_tdata[B*i +: B];
	end
endgenerate

// DUT.
axis_wconv_v1 DUT
	(
		// Reset and clock.
		.aresetn		,
		.aclk			,

		// S_AXIS for input data.
		.s_axis_tvalid	,
		.s_axis_tdata	,

		// M_AXIS for output data.
		.m_axis_tvalid	,
		.m_axis_tdata
	);

// Main TB.
initial begin
	aresetn			<= 0;
	s_axis_tvalid	<= 0;
	for (int i=0; i<NIN; i=i+1) begin
		din_r[i] <= 0;
	end
	#300;
	aresetn			<= 1;

	#1000;

	for (int i=0; i<100; i=i+1) begin
		@(posedge aclk);
		for (int j=0; j<NIN; j=j+1) begin
			din_r [j] <= NIN*i + j;
		end
	end

end

// s_axis_aclk;
always begin
	aclk <= 0;
	#7;
	aclk <= 1;
	#7;
end

endmodule

