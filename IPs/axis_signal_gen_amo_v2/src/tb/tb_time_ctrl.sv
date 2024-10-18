module tb();


parameter B = 8;

// Reset and clock.
reg 			rstn	;
reg 			clk		;

// Trigger.
reg				trigger	;

// Time output.
wire [B-1:0]	t_out	;

// Registers.
reg  [B-1:0]	WAIT_REG;

// time_ctrl.
time_ctrl
	#(
		.B(B)
	)
	time_ctrl_i
	(
		// Reset and clock.
		.rstn	,
		.clk	,
	
		// Trigger.
		.trigger,

		// Time output.
		.t_out	,

		// Registers.
		.WAIT_REG
	);

// Main TB.
initial begin
	rstn		<= 0;
	trigger		<= 0;
	WAIT_REG	<= 0;
	#300;
	rstn		<= 1;

	#500;

	trigger <= 1;
	
	#4000;
	
	trigger <= 0;
	
	#200;
	
	trigger <= 1;

end

always begin
	clk <= 0;
	#5;
	clk <= 1;
	#5;
end  

endmodule

