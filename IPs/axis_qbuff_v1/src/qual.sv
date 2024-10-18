module qual
	#(
		// Number of inputs.
		parameter L	= 4
	)
	(
		// Reset and clock.
		input 	wire 			aresetn		,
		input 	wire 			aclk		,

		// Start.
		input	wire			start		,

		// Input triggers.
		input	wire [L-1:0]	din			,

		// Handshake with memory writer.
		output	wire			write		,
		input	wire			write_ack
	);

/*************/
/* Internals */
/*************/

// States.
typedef enum	{	INIT_ST		,
					TRIGGER_ST	,
					WRITE_ST	,
					WRITE_ACK_ST
				} state_t;

// State register.
(* fsm_encoding = "one_hot" *) state_t state;

reg			write_state;

// Internal trigger signal.
wire		trigger_i;

/****************/
/* Architecture */
/****************/
// Simplest trigger (or all inputs).
assign trigger_i = |din;

// Registers.
always @(posedge aclk) begin
	if (~aresetn) begin
		// State register.
		state 		<= INIT_ST;
	end
	else begin
		// State register.
		case (state)
			INIT_ST:
				if (start == 1'b1)
					state <= TRIGGER_ST;

			TRIGGER_ST:
				if (start == 1'b1) begin
					if (trigger_i == 1'b1)
						state <= WRITE_ST;
				end
				else begin
					state <= INIT_ST;
				end

			WRITE_ST:
				if (write_ack == 1'b1)
					state <= WRITE_ACK_ST;

			WRITE_ACK_ST:
				if (write_ack == 1'b0)
					state <= TRIGGER_ST;
		endcase
	end
end 

// FSM outputs.
always_comb	begin
	// Default.
	write_state	= 0;

	case (state)
		//INIT_ST:

		//TRIGGER_ST:

		WRITE_ST:
			write_state	= 1'b1;

		//WRITE_ACK_ST:

	endcase
end

// Assign outputs.
assign write	= write_state;

endmodule

