module punct
	#(
		parameter B		= 16	,
		parameter NT	= 256
	)
	(
		// Reset and clock.
		input 	wire 			aresetn			,
		input 	wire 			aclk			,

    	// S_AXIS for data input.
		input	wire			s_axis_tvalid	,
		input	wire			s_axis_tlast	,
		input	wire	[B-1:0]	s_axis_tdata	,

		// M_AXIS for data output.
		output	wire			m_axis_tvalid	,
		output	wire	[B-1:0]	m_axis_tdata	,
		output	wire	[15:0]	m_axis_tuser	,

		// Registers.
		input	wire			START_REG		,
		input	wire	[31:0]	PUNCT_REG
	);

/*************/
/* Internals */
/*************/

localparam NT_LOG2 = $clog2(NT);

// States.
typedef enum	{	INIT_ST	,
					SYNC_ST	,
					RUN_ST
				} state_t;

// State register.
(* fsm_encoding = "one_hot" *) state_t state;

reg					init_state	;
reg					sync_state	;
reg					run_state	;

// Pipeline registers.
reg					tvalid_r1	;
reg	[B-1:0]			tdata_r1	;

// Transaction counter.
reg	[NT_LOG2-1:0]	cnt_ntran	;
reg	[NT_LOG2-1:0]	cnt_ntran_r1;

// Punct register.
reg	[31:0]			PUNCT_REG_r	;

// Selection bit.
wire				sel			;

// Re-sync registers.
wire		START_REG_resync;

/****************/
/* Architecture */
/****************/
// START_REG_resync.
synchronizer_n START_REG_resync_i
	(
		.rstn	    (aresetn			),
		.clk 		(aclk				),
		.data_in	(START_REG			),
		.data_out	(START_REG_resync	)
	);

// Selection bit.
assign sel	= PUNCT_REG_r[cnt_ntran_r1];

// Registers.
always @(posedge aclk) begin
	if (~aresetn) begin
		// State register.
		state 		<= INIT_ST;

		// Pipeline registers.
		tvalid_r1	<= 0;
		tdata_r1	<= 0;

		// Transaction counter.
		cnt_ntran	<= 0;
		cnt_ntran_r1<= 0;
		
		// Punct register.
		PUNCT_REG_r	<= 0;
	end
	else begin
		// State register.
		case (state)
			INIT_ST:
				if (START_REG_resync == 1'b1)
					state <= SYNC_ST;

			SYNC_ST:
				if (s_axis_tvalid == 1'b1 && s_axis_tlast == 1'b1)
					state <= RUN_ST;

			RUN_ST:
				if (START_REG_resync == 1'b0)
					state <= INIT_ST;
				else if (s_axis_tvalid == 1'b1 && s_axis_tlast == 1'b1 && cnt_ntran != NT-1)
					state <= SYNC_ST;
		endcase

		// Pipeline registers.
		tvalid_r1	<= s_axis_tvalid;
		tdata_r1	<= s_axis_tdata;

		// Transaction counter.
		if (sync_state == 1'b1)
			cnt_ntran <= 0;
		if (run_state == 1'b1 && s_axis_tvalid == 1'b1)
			if (cnt_ntran < NT-1)
				cnt_ntran	<= cnt_ntran + 1;
			else
				cnt_ntran	<= 0;

		cnt_ntran_r1 <= cnt_ntran;
		
		// Punct register.
		if (init_state == 1'b1)
			PUNCT_REG_r	<= PUNCT_REG;
	end
end 

// FSM outputs.
always_comb	begin
	// Default.
	init_state	= 0;
	sync_state	= 0;
	run_state	= 0;

	case (state)
		INIT_ST:
			init_state 	= 1'b1;

		SYNC_ST:
			sync_state	= 1'b1;

		RUN_ST:
			run_state	= 1'b1;
	endcase
end

assign m_axis_tvalid	= tvalid_r1 & sel;
assign m_axis_tdata		= tdata_r1;
assign m_axis_tuser		= cnt_ntran_r1;

endmodule

