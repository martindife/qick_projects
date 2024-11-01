module tb();

reg 				clk		;
reg		[4*32-1:0]	din		;
wire	[16*16-1:0]	dout	;
reg		[1:0]		MODE_REG;

// Fast data for debugging.
reg 			clk_x4;
reg		[15:0]	din_real_r	;
reg		[15:0]	din_imag_r	;
reg 			clk_x16;
reg		[15:0]	dout_r		;

// DUT.
mixer_top DUT (
	.clk		(clk	),
	.din		(din	),
	.dout		(dout	),
	.MODE_REG	(MODE_REG	)
);

// Main TB.
initial begin
	real w0;
	int n;
	din 		<= 0;
	MODE_REG	<= 2;	// 0: 0, 1: pi/2, 2: pi/4.

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
			dout_r <= dout[16*i	+: 16];
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

