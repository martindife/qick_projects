module trigger_per
	(
		// Reset and clock.
		input 	wire				aresetn			,
		input	wire				aclk			,

		// Start Input.
		input 	wire				start			,

		// Trigger output.
		output	wire				trigger			,

		// Registers.
		input	wire [15:0]			WIDTH0_REG		,
		input	wire [15:0]			WIDTH1_REG
	);

/*************/
/* Internals */
/*************/
// States.
typedef enum	{	INIT_ST		,
					WIDTH0_ST	,
					WIDTH1_ST
				} state_t;

// State register.
(* fsm_encoding = "one_hot" *) state_t state;

reg				init_state	;
reg				width0_state;
reg				width1_state;

// Re-sync registers.
reg	    [15:0]	width0_r	;
reg	    [15:0]	width1_r	;

// Width 0 counter.
reg		[15:0]	cnt_width0	;

// Width 1 counter.
reg		[15:0]	cnt_width1	;

/****************/
/* Architecture */
/****************/

// Registers.
always @(posedge aclk) begin
	if (~aresetn) begin
		// State register.
		state 		<= INIT_ST;

		// Re-sync registers.
		width0_r	<= 0;
		width1_r	<= 0;

		// Width 0 counter.
		cnt_width0	<= 0;
		
		// Width 1 counter.
		cnt_width1	<= 0;
	end
	else begin
		// State register.
		case (state)
			INIT_ST:
				if (start == 1'b1)
					state <= WIDTH0_ST;

			WIDTH0_ST:
				if (start == 1'b1) begin
					if (cnt_width0 == width0_r)
						state <= WIDTH1_ST;
				end
				else begin
					state <= INIT_ST;
				end

			WIDTH1_ST:
				if (start == 1'b1) begin
					if (cnt_width1 == width1_r)
						state <= WIDTH0_ST;
				end
				else begin
					state <= INIT_ST;
				end
		endcase

		// Re-sync registers.
		if (init_state == 1'b1) begin
			width0_r	<= WIDTH0_REG;
			width1_r	<= WIDTH1_REG;
		end

		// Width 0 counter.
		if (width0_state == 1'b1) begin
			if ( cnt_width0 == width0_r)
				cnt_width0 <= 0;
			else
				cnt_width0 <= cnt_width0 + 1;
		end
		else begin
			cnt_width0 <= 0;
		end

		// Width 1 counter.
		if (width1_state == 1'b1) begin
			if ( cnt_width1 == width1_r)
				cnt_width1 <= 0;
			else
				cnt_width1 <= cnt_width1 + 1;
		end
		else begin
			cnt_width1 <= 0;
		end
	end
end

// FSM outputs.
always_comb	begin
	// Default.
	init_state		= 0;
	width0_state	= 0;
	width1_state	= 0;

	case (state)
		INIT_ST:
			init_state	= 1'b1;

		WIDTH0_ST:
			width0_state= 1'b1;

		WIDTH1_ST:
			width1_state= 1'b1;
	endcase
end

// Assign outputs.
assign trigger = width0_state;

endmodule

