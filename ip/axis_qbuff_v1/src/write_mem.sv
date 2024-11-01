module write_mem
	#(
		// Memory Size.
		parameter N	= 4	,

		// Bits.
		parameter B = 8	,

		// Number of lanes.
		parameter L	= 4
	)
	(
		// Reset and clock.
		input 	wire 				aresetn		,
		input 	wire 				aclk		,

		// Start.
		input	wire				start		,

		// Input data.
		input 	wire	[L*B-1:0]	din			,

		// Time-tag.
		input	wire	[2*B-1:0]	ttag		,

		// Handshake.
		input	wire				write		,
		output	wire				write_ack	,

		// Memory interface.
		output	wire				mem_we		,
		output	wire	[N-1:0]		mem_addr	,
		output	wire	[L*B-1:0]	mem_di		,

		// Registers.
		input	wire	[N-1:0]		NSAMP_REG
	);

/*************/
/* Internals */
/*************/

localparam BZ = (L-2)*B;

// States.
typedef enum	{	INIT_ST		,
					WRITE_ST	,
					MEMW_ST		,
					TTAGW_ST	,
					WRITE_ACK_ST
				} state_t;

// State register.
(* fsm_encoding = "one_hot" *) state_t state;

reg				init_state		;
reg 			write_state		;
reg 			memw_state		;
reg				ttagw_state		;
reg 			write_ack_state	;

// Counter for memory address.
reg	[N:0]		cnt_addr		;

// Counter for number of samples.
reg	[N-1:0]		cnt				;

// Time-tag.
wire[L*B-1:0] 	ttag_i			;

// Re-synced registers.
reg	[N-1:0]		NSAMP_REG_r		;

/****************/
/* Architecture */
/****************/

// Time-tag.
assign ttag_i = {{BZ{1'b0}},ttag};

// Registers.
always @(posedge aclk) begin
	if (~aresetn) begin
		// State register.
		state 		<= INIT_ST;

		// Counter for memory address.
		cnt_addr	<= 0;

		// Counter for number of samples.
		cnt			<= 0;

		// Re-synced registers.
		NSAMP_REG_r	<= 0;
	end
	else begin
		// State register.
		case (state)
			INIT_ST:
				if (start == 1'b1)
					state <= WRITE_ST;

			WRITE_ST:
				if (start == 1'b1) begin
					if (write == 1'b1)
						if (cnt_addr[N] == 1'b0)
							state <= MEMW_ST;
						else
							state <= WRITE_ACK_ST;
				end
				else begin
					state <= INIT_ST;
				end

			MEMW_ST:
				if (cnt >= NSAMP_REG_r - 1)
					state <= TTAGW_ST;

			TTAGW_ST:
				state <= WRITE_ACK_ST;

			WRITE_ACK_ST:
				if (write == 1'b0)
					state <= WRITE_ST;
		endcase

		// Counter for memory address.
		if (init_state == 1'b1)
			cnt_addr <= 0;
		else if (memw_state == 1'b1 || ttagw_state == 1'b1)
			cnt_addr <= cnt_addr + 1;

		// Counter for number of samples.
		if (write_state == 1'b1)
			cnt	<= 0;
		else if (memw_state == 1'b1)
			cnt <= cnt + 1;

		// Re-synced registers.
		if (init_state == 1'b1)
			NSAMP_REG_r	<= NSAMP_REG;
	end
end 

// FSM outputs.
always_comb	begin
	// Default.
	init_state		= 0;
	write_state		= 0;
	memw_state		= 0;
	ttagw_state		= 0;
	write_ack_state	= 0;

	case (state)
		INIT_ST:
			init_state		= 1'b1;

		WRITE_ST:
			write_state		= 1'b1;

		MEMW_ST:
			memw_state		= 1'b1;

		TTAGW_ST:
			ttagw_state		= 1'b1;

		WRITE_ACK_ST:
			write_ack_state	= 1'b1;
	endcase
end

// Assign outputs.
assign write_ack	= write_ack_state;
assign mem_we		= (memw_state | ttagw_state) & ~cnt_addr[N];
assign mem_addr		= cnt_addr[N-1:0];
assign mem_di		= (ttagw_state == 1'b1)? ttag_i : din;

endmodule

