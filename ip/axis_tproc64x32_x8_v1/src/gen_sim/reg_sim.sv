// Simplified Signal Generator Simulator.
// The block reads from the queue and implements the periodic
// and non-periodic mode, using the lower 16 bits for the number
// of samples and the next bit for mode.
module reg_sim
	(
		input  wire			clk				,
		input  wire			rstn			,
		input  wire	[159:0]	s_axis_tdata	,
		input  wire			s_axis_tvalid	,
		output wire			s_axis_tready	,
		output wire	[159:0]	dout
	);

// Registered output.
reg	[159:0]	data_r;

// Registers.
always @(posedge clk) begin
	if (~rstn) begin
		// Registered output.
		data_r <= 0;
	end
	else begin
		if (s_axis_tvalid == 1'b1)
			data_r <= s_axis_tdata;
	end
end

// Assign outputs.
assign s_axis_tready	= 1'b1;
assign dout				= data_r;

endmodule

