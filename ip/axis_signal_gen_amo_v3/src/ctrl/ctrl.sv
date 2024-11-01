//Format of waveform interface:
// |----------|----------|----------|---------|
// | 79 .. 72 | 71 .. 64 | 63 .. 32 | 31 .. 0 |
// |----------|----------|----------|---------|
// |     qsel |     ctrl |     wait |    addr |
// |----------|----------|----------|---------|
// addr 	: 32 bits
// wait 	: 32 bits
// ctrl 	: 8 bits
module ctrl (
	// Reset and clock.
	input	wire			rstn		,
	input	wire			clk			,

	// Fifo interface.
	output	wire			fifo_rd_en	,
	input	wire			fifo_empty	,
	input	wire	[79:0]	fifo_dout	,

	// Start/busy flags.
	output	wire			start		,
	input	wire			busy		,

	// Fifo fields.
	output	wire	[31:0]	addr_o		,
	output	wire	[31:0]	wait_o		,
	output	wire	[7:0]	ctrl_o		,
	output	wire	[7:0]	qsel_o
	);

/*************/
/* Internals */
/*************/

// States.
typedef enum	{	READ_ST	,
					REGS_ST	,
					BUSY_ST	,
					DONE_ST
				} state_t;

// State register.
(* fsm_encoding = "one_hot" *) state_t state;

reg				read_state	;
reg				regs_state	;
reg				busy_state	;

// Fifo dout register.
reg		[79:0]	fifo_dout_r	;

/****************/
/* Architecture */
/****************/

// Registers.
always @(posedge clk) begin
	if (~rstn) begin
		// State register.
		state 		<= READ_ST;

		// Fifo dout register.
		fifo_dout_r	<= 0;
	end
	else begin
		// State register.
		case (state)
			READ_ST:
				if (fifo_empty == 1'b0)
					state <= REGS_ST;

			REGS_ST:
				state <= BUSY_ST;

			BUSY_ST:
				if (busy == 1'b1)
					state <= DONE_ST;

			DONE_ST:
				if (busy == 1'b0)
					state <= READ_ST;
		endcase

		// Fifo dout register.
		if (regs_state)
			fifo_dout_r	<= fifo_dout;
	end
end 

// FSM outputs.
always_comb	begin
	// Default.
	read_state = 1'b0;
	regs_state = 1'b0;
	busy_state = 1'b0;

	case (state)
		READ_ST:
			read_state = 1'b1;

		REGS_ST:
			regs_state = 1'b1;

		BUSY_ST:
			busy_state = 1'b1;

		//DONE_ST:
	endcase
end

// Assign outputs.
assign fifo_rd_en	= read_state;
assign start		= busy_state;
assign addr_o		= fifo_dout_r	[31:0];
assign wait_o		= fifo_dout_r	[63:32];
assign ctrl_o		= fifo_dout_r	[71:64];
assign qsel_o		= fifo_dout_r	[79:72];

endmodule

