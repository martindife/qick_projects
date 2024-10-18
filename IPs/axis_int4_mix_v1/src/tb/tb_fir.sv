module tb();

reg 				clk		;
reg		[4*32-1:0]	din		;
wire	[16*32-1:0]	dout	;

// Fast data for debugging.
reg 			clk_x4;
reg		[15:0]	din_real_r	;
reg		[15:0]	din_imag_r	;
reg 			clk_x16;
reg		[15:0]	dout_real_r	;
reg		[15:0]	dout_imag_r	;

// Interpolation.
fir fir_i (
	.clk	(clk	),
	.din	(din	),
	.dout	(dout	)
);

// Main TB.
initial begin
	real w0;
	int n;
	din <= 0;

	#500;

	w0 = 0.01*2*3.1415;

	n = 0;
	while(1) begin
		@(posedge clk);
		for (int i=0; i<4; i=i+1) begin
			din[32*i	+: 16] <= 0.8*(2**15)*$cos(w0*n);
			din[32*i+16	+: 16] <= 0.8*(2**15)*$sin(w0*n);
			n = n+1;
		end
	end
end

initial begin
	while(1) begin
		@(posedge clk);
		for (int i=0; i<4; i=i+1) begin
			@(posedge clk_x4);
			din_real_r <= din[32*i		+: 16];
			din_imag_r <= din[32*i+16	+: 16];
		end
	end
end

initial begin
	while(1) begin
		@(posedge clk);
		for (int i=0; i<16; i=i+1) begin
			@(posedge clk_x16);
			dout_real_r <= dout[32*i	+: 16];
			dout_imag_r <= dout[32*i+16	+: 16];
		end
	end
end

// clk.
always begin
	clk <= 0;
	#16;
	clk <= 1;
	#16;
end

// fclk_x4.
always begin
	clk_x4 <= 0;
	#4;
	clk_x4 <= 1;
	#4;
end

// fclk_x16.
always begin
	clk_x16 <= 0;
	#1;
	clk_x16 <= 1;
	#1;
end

endmodule

