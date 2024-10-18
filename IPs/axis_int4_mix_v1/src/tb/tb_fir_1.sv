module tb();

reg 			aclk				;
reg 			s_axis_data_tvalid	;
wire 			s_axis_data_tready	;
reg [255 : 0] 	s_axis_data_tdata	;
wire 			m_axis_data_tvalid	;
wire [767 : 0] 	m_axis_data_tdata	;

reg 			aclk_x8				;
reg		[15:0]	din_real_r			;
reg		[15:0]	din_imag_r			;

reg 			aclk_x16			;
reg		[17:0]	dout_real_r			;
reg		[17:0]	dout_imag_r			;
wire	[15:0]	dout_real_q			;
wire	[15:0]	dout_imag_q			;

assign dout_real_q = dout_real_r[1 +: 16];
assign dout_imag_q = dout_imag_r[1 +: 16];

// DUT.
fir_1 DUT (
	.aclk				,
	.s_axis_data_tvalid	,
	.s_axis_data_tready	,
	.s_axis_data_tdata	,
	.m_axis_data_tvalid	,
	.m_axis_data_tdata
);

// Main TB.
initial begin
	real w0;
	int n;
	s_axis_data_tvalid	<= 1;
	s_axis_data_tdata	<= 0;

	#500;

	w0 = 0.01*2*3.1415;

	n = 0;
	while(1) begin
		@(posedge aclk);
		for (int i=0; i<8; i=i+1) begin
			s_axis_data_tdata[32*i		+: 16] <= 0.8*(2**15)*$cos(w0*n);
			s_axis_data_tdata[32*i+16	+: 16] <= 0.8*(2**15)*$sin(w0*n);
			n = n+1;
		end
	end
end

initial begin
	while(1) begin
		@(posedge aclk);
		for (int i=0; i<8; i=i+1) begin
			@(posedge aclk_x8);
			din_real_r <= s_axis_data_tdata[32*i 	+: 16];
			din_imag_r <= s_axis_data_tdata[32*i+16 +: 16];
		end
	end
end

initial begin
	while(1) begin
		@(posedge aclk);
		for (int i=0; i<16; i=i+1) begin
			@(posedge aclk_x16);
			dout_real_r <= m_axis_data_tdata[48*i 		+: 18];
			dout_imag_r <= m_axis_data_tdata[48*i+24 	+: 18];
		end
	end
end

// aclk.
always begin
	aclk <= 0;
	#16;
	aclk <= 1;
	#16;
end

// aclk_x8.
always begin
	aclk_x8 <= 0;
	#2;
	aclk_x8 <= 1;
	#2;
end

// aclk_x16.
always begin
	aclk_x16 <= 0;
	#1;
	aclk_x16 <= 1;
	#1;
end


endmodule

