module data_reader
	#(
		// Number of memories.
		parameter NM	= 8	,

		// Address map of each memory.
		parameter N		= 8	,

		// Data width.
		parameter B		= 8
	)
	(
		// Reset and clock.
		input 	wire 				aresetn			,
		input 	wire 				aclk			,

        // Memory I/F.
        output	wire	[N-1:0]		mem_addr		,
        input	wire	[NM*B-1:0]	mem_dout		,
        
        // m_axis_* for data out.
		output	wire				m_axis_tvalid	,
		input	wire				m_axis_tready	,
		output	wire	[B-1:0]		m_axis_tdata	,
		output	wire				m_axis_tlast	,
		
        // Registers.
		input	wire				START_REG
	);

/*************/
/* Internals */
/*************/

localparam NM_LOG2 	= $clog2(NM);
localparam NPOW		= 2**N		;

// States.
typedef enum	{	INIT_ST		,
					READ_ST		,
					WRITE_ST	,
					END_ST
				} state_t;

// State register.
(* fsm_encoding = "one_hot" *) state_t state;

reg 					init_state			;
reg 					read_state			;
reg 					write_state			;

// Counter for memory address.
reg		[N-1:0]			cnt_addr			;
reg		[N-1:0]			cnt_addr_r			;

// Counter for memory selection.
reg		[NM_LOG2-1:0]	cnt_nm				;

// Data register.
reg		[NM*B-1:0]		mem_dout_r1			;

// Muxed data.
wire	[B-1:0]			dout_mux			;

// Tlast.
wire					last_addr			;
wire					last_nm				;
wire					tlast_i				;

// Re-synced registers.
wire					START_REG_resync	;

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

// Muxed data.
assign dout_mux	= mem_dout_r1[cnt_nm*B +: B];

// Tlast.
assign last_addr	= (cnt_addr_r	== '1);
assign last_nm		= (cnt_nm		== '1);
assign tlast_i		= last_addr & last_nm;

// Registers.
always @(posedge aclk) begin
	if (~aresetn) begin
		// State register.
		state 		<= INIT_ST;

		// Counter for memory address.
		cnt_addr	<= 0;
		cnt_addr_r	<= 0;
		
		// Counter for memory selection.
		cnt_nm		<= 0;
		
		// Data register.
		mem_dout_r1	<= 0;
	end
	else begin
		// State register.
		case (state)
			INIT_ST:
				if (START_REG_resync == 1'b1)
					state <= READ_ST;

			READ_ST:
				state <= WRITE_ST;

			WRITE_ST:
				if (m_axis_tready == 1'b1) begin
					if (cnt_nm == '1) begin
						if (cnt_addr_r == '1) begin
							state <= END_ST;
						end
						else begin
							state <= READ_ST;
						end
					end
				end

			END_ST:
				if (START_REG_resync == 1'b0)
					state <= INIT_ST;
		endcase

		// Counter for memory address.
		if (init_state == 1'b1) begin
			cnt_addr <= 0;
		end
		else if (read_state == 1'b1) begin
			cnt_addr 	<= cnt_addr + 1;
			cnt_addr_r	<= cnt_addr;
		end
		
		// Counter for memory selection.
		if (read_state == 1'b1)
			cnt_nm	<= 0;
		else if (write_state == 1'b1 && m_axis_tready == 1'b1)
			cnt_nm	<= cnt_nm + 1;
		
		// Data register.
		if (read_state == 1'b1)
			mem_dout_r1	<= mem_dout;
	end
end 

// FSM outputs.
always_comb	begin
	// Default.
	init_state	= 1'b0;
	read_state	= 1'b0;
	write_state	= 1'b0;

	case (state)
		INIT_ST:
			init_state	= 1'b1;

		READ_ST:
			read_state	= 1'b1;

		WRITE_ST:
			write_state	= 1'b1;

		//END_ST:

	endcase
end

// Assign outputs.
assign mem_addr			= cnt_addr		;
assign m_axis_tvalid	= write_state	;
assign m_axis_tdata		= dout_mux		;
assign m_axis_tlast		= tlast_i		;

endmodule

