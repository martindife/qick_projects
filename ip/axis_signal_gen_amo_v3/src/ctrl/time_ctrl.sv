module time_ctrl
	#(
		parameter B = 8
	)
	(
		// Reset and clock.
		input 	wire 			rstn	,
		input 	wire 			clk		,
	
		// Start/busy flags.
		input 	wire			start	,
		output	wire			busy	,

		// Phase sync output.
		output	wire			sync	,

		// Output time.
		output	wire			valid	,
		output 	wire [B-1:0]	t_out	,

		// Registers.
		input	wire [B-1:0]	WAIT_REG
	);

/*************/
/* Internals */
/*************/
localparam CNT_MAX = 2**(B-1) -1;

// States.
typedef enum	{	INIT_ST	,
					SYNC_ST	,
					CNT_ST	,
					WAIT_ST	,
					END_ST
				} state_t;

// State register.
(* fsm_encoding = "one_hot" *) state_t state;

reg		init_state			;
reg		sync_state			;
reg		cnt_state			;
reg		wait_state			;
reg		end_state			;

// Registers.
reg		[B-1:0]	WAIT_REG_r	;

// Counter.
reg	    [B-1:0]	cnt			;
reg		[B-1:0]	cnt_r		;

// Wait counter.
reg		[B-1:0]	wcnt		;

// Output mux.
wire	[B-1:0]	cnt_mux		;
reg		[B-1:0]	cnt_mux_r1	;

// Busy flag.
wire			busy_i		;
reg				busy_r1		;

// Sync register.
reg				sync_r1		;
reg				sync_r2		;

// Output valid.
wire			valid_i		;
reg				valid_r1	;

/****************/
/* Architecture */
/****************/

// Registers.
always @(posedge clk) begin
	if (rstn == 1'b0) begin
		// State register.
		state 		<= INIT_ST;

		// Registers.
		WAIT_REG_r	<= 0;

		// Counter.
		cnt			<= 0;
		cnt_r		<= 0;

		// Wait counter.
		wcnt		<= 0;

		// Output mux.
		cnt_mux_r1	<= 0;

		// Busy flag.
		busy_r1		<= 0;

		// Sync register.
		sync_r1		<= 0;
		sync_r2		<= 0;

		// Output valid.
		valid_r1	<= 0;
	end
	else begin
		// State register.
		case (state)
			INIT_ST:
				if (start == 1'b1)
					state <= SYNC_ST;

			SYNC_ST:
				state <= CNT_ST;

			CNT_ST:
				if (cnt == CNT_MAX)
					state <= END_ST;
				else if (WAIT_REG_r != '0)
					state <= WAIT_ST;

			WAIT_ST:
				if (wcnt == WAIT_REG_r-1)
					state <= CNT_ST;

			END_ST:
				if (start == 1'b0)
					state <= INIT_ST;
		endcase

		// Registers.
		WAIT_REG_r	<= WAIT_REG	;

		// Counter.
		if ( init_state == 1'b1 || end_state == 1'b1 ) begin
			cnt	<= 0;
		end
		else if ( cnt_state == 1'b1) begin
			cnt <= cnt + 1;
		end
	
		if (cnt_state == 1'b1)
			cnt_r <= cnt;

		// Wait counter.
		if ( wait_state == 1'b1 ) begin
			wcnt <= wcnt + 1;
		end
		else begin
			wcnt <= 0;
		end

		// Output mux.
		cnt_mux_r1	<= cnt_mux;

		// Busy flag.
		busy_r1		<= busy_i;

		// Sync register.
		sync_r1		<= sync_state;
		sync_r2		<= sync_r1;

		// Output valid.
		valid_r1	<= valid_i;
	end
end

// Output mux.
assign cnt_mux 	= (cnt_state == 1'b1)? cnt : cnt_r;

// Busy flag.
assign busy_i	= sync_state | cnt_state | wait_state;

// Output.
assign valid_i	= cnt_state | wait_state;

// FSM outputs.
always_comb	begin
	// Default.
	init_state	= 0;
	sync_state 	= 0;
	cnt_state	= 0;
	wait_state	= 0;
	end_state	= 0;

	case (state)
		INIT_ST:
			init_state 	= 1'b1;

		SYNC_ST:
			sync_state	= 1'b1;

		CNT_ST:
			cnt_state 	= 1'b1;

		WAIT_ST:
			wait_state	= 1'b1;

		END_ST:
			end_state	= 1'b1;
	endcase
end

// Assign outputs.
assign busy		= busy_r1		;
assign sync		= sync_r2		;
assign valid	= valid_r1		;
assign t_out	= cnt_mux_r1	;

endmodule

