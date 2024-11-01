module counter
	#(
		parameter BDATA	= 16	,
		parameter BUSER	= 8
	)
	(
		// m_axis_* for output.
		input 	wire 				m_axis_aresetn	,
		input 	wire 				m_axis_aclk		,
		output	wire				m_axis_tvalid	,
		input   wire				m_axis_tready	,
		output	wire [BDATA-1:0]	m_axis_tdata	,
		output	wire [BUSER-1:0]	m_axis_tuser	,

		// Registers.
		input	wire				START_REG		,
		input   wire	[31:0]		NDATA_REG		,
		input   wire	[31:0]		NUSER_REG		,
		input   wire	[31:0]		WAIT_REG
	);

/*************/
/* Internals */
/*************/
// States.
typedef enum	{	INIT_ST	,
					WAIT_ST	,
					RUN_ST
				} state_t;

// State register.
(* fsm_encoding = "one_hot" *) state_t state;

reg					init_state			;
reg					wait_state			;
reg					run_state			;

// Counters.
reg	 [31:0]			cnt_wait			;
reg	 [BDATA-1:0]	cnt_data			;
reg	 [BUSER-1:0]	cnt_user			;

// Re-sync registers.
wire				START_REG_resync	;
reg	 [31:0]			NDATA_REG_r			;
reg	 [31:0]			NUSER_REG_r			;
reg	 [31:0]			WAIT_REG_r			;

/****************/
/* Architecture */
/****************/
// START_REG_resync.
synchronizer_n SYNC_REG_resync_i
	(
		.rstn	    (m_axis_aresetn		),
		.clk 		(m_axis_aclk		),
		.data_in	(START_REG			),
		.data_out	(START_REG_resync	)
	);

// Registers.
always @(posedge m_axis_aclk) begin
	if (~m_axis_aresetn) begin
		// State register.
		state 		<= INIT_ST;

		// Counters.
		cnt_wait	<= 0;
		cnt_data	<= 0;
		cnt_user	<= 0;

		// Re-sync registers.
		NDATA_REG_r	<= 0;
		NUSER_REG_r	<= 0;
		WAIT_REG_r	<= 0;
	end
	else begin
		// State register.
		case (state)
			INIT_ST:
				if (START_REG_resync == 1'b1)
					state <= WAIT_ST;

			WAIT_ST:
				if (cnt_wait == WAIT_REG_r - 1)
					state <= RUN_ST;

			RUN_ST:
				if (START_REG_resync == 1'b0) begin
					state <= INIT_ST;
				end
				else begin
					if (m_axis_tready == 1'b1)
						state <= WAIT_ST;
				end
		endcase

		// Counters.
		if (wait_state == 1'b1) begin
			if (cnt_wait == WAIT_REG_r-1)
				cnt_wait <= 0;
			else
				cnt_wait <= cnt_wait + 1;
		end
		if (run_state == 1'b1 && m_axis_tready == 1'b1) begin
			if (cnt_data == NDATA_REG_r-1)
				cnt_data <= 0;
			else
				cnt_data <= cnt_data + 1;

			if (cnt_user == NUSER_REG_r-1)
				cnt_user <= 0;
			else
				cnt_user <= cnt_user + 1;
		end

		// Re-sync registers.
		if (START_REG_resync == 1'b0)
			NDATA_REG_r	<= NDATA_REG;
			NUSER_REG_r	<= NUSER_REG;
			WAIT_REG_r	<= WAIT_REG;
	end
end 

// FSM outputs.
always_comb	begin
	// Default.
	init_state	= 0;
	wait_state	= 0;
	run_state	= 0;

	case (state)
		INIT_ST:
			init_state 	= 1'b1;

		WAIT_ST:
			wait_state 	= 1'b1;

		RUN_ST:
			run_state 	= 1'b1;
	endcase
end

// Assign outputs.
assign m_axis_tvalid	= run_state;
assign m_axis_tdata		= cnt_data;
assign m_axis_tuser		= cnt_user;

endmodule

