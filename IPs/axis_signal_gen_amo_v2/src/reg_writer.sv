module reg_writer
	#(
		parameter NREG = 8
	)
	(
		// Reset and clock.
		input 	wire 			rstn			,
		input 	wire 			clk				,

		// AXIS for data input.
		input	wire			s_axis_tvalid	,
		output	wire			s_axis_tready	,
		input	wire	[31:0]	s_axis_tdata	,
		input	wire			s_axis_tlast	,
	
		// Write Enable Vector.
		output	wire	[63:0]	we				,
		
		// Register outputs.
		output 	wire 	[31:0]	reg00_out		,
		output 	wire 	[31:0]	reg01_out		,
		output 	wire 	[31:0]	reg02_out		,
		output 	wire 	[31:0]	reg03_out		,
		output 	wire 	[31:0]	reg04_out		,
		output 	wire 	[31:0]	reg05_out		,
		output 	wire 	[31:0]	reg06_out		,
		output 	wire 	[31:0]	reg07_out		,
		output 	wire 	[31:0]	reg08_out		,
		output 	wire 	[31:0]	reg09_out		,
		output 	wire 	[31:0]	reg10_out		,
		output 	wire 	[31:0]	reg11_out		,
		output 	wire 	[31:0]	reg12_out		,
		output 	wire 	[31:0]	reg13_out		,
		output 	wire 	[31:0]	reg14_out		,
		output 	wire 	[31:0]	reg15_out		,

		// Registers.
		input	wire			START_REG
	);

/*************/
/* Internals */
/*************/
// Maximum number of blocks.
localparam NB 		= 64;
localparam NB_LOG2 	= $clog2(NB);

// States.
typedef enum	{	START_ST		,
					READ_ADDR_ST	,
					READ_REGS_ST	,
					WRITE_ST		,
					WRITE_LAST_ST	,
					END_ST
				} state_t;

// State register.
(* fsm_encoding = "one_hot" *) state_t state;

reg						start_state			;
reg						read_addr_state		;
reg						read_regs_state		;
reg						write_state			;
reg						end_state			;

// Counter.
reg	    [4:0]			cnt					;

// Counter for write state.
reg	    [2:0]			cnt_wr				;

// Address register.
reg		[NB_LOG2-1:0]	addr_r				;

// Register array.
reg		[31:0]			regs_r [NREG]		;


// Internal write enable.
wire	[15:0]			we_i				;


// START_REG_resync.
wire					START_REG_resync	;


/****************/
/* Architecture */
/****************/

// START_REG_resync.
synchronizer_n START_REG_resync_i
	(
		.rstn	    (rstn				),
		.clk 		(clk				),
		.data_in	(START_REG			),
		.data_out	(START_REG_resync	)
	);

// Registers (generate).
genvar i;
generate
	for (i=0; i<NREG; i=i+1) begin: GEN_regs
		// Registers.
		always @(posedge clk) begin
			if (rstn == 1'b0) begin
				// Register array.
				regs_r [i]	<= 0;
			end
			else begin
				// Register array.
				if (read_regs_state == 1'b1 && cnt == i && s_axis_tvalid == 1'b1)
					regs_r [i]	<= s_axis_tdata;
			end
		end
	end
endgenerate

// we (generate).
generate
	for (i=0; i<NB; i=i+1) begin: GEN_we
	  // Internal write enable.
		assign we_i[i] = (addr_r == i)? write_state : 1'b0;
	end
endgenerate

// Registers.
always @(posedge clk) begin
	if (rstn == 1'b0) begin
		// State register.
		state 		<= START_ST;

		// Counter.
		cnt			<= 0;

		// Counter for write state.
		cnt_wr		<= 0;

		// Address register.
		addr_r		<= 0;
	end
	else begin
		// State register.
		case (state)
			START_ST:
				if (START_REG_resync == 1'b1)
					state <= READ_ADDR_ST;

			READ_ADDR_ST:
				if (s_axis_tvalid == 1'b1)
					// tlast = 1: non-completed transaction.
					if (s_axis_tlast == 1'b1)
						state <= END_ST;

					// tlast = 0: keep going...
					else
						state <= READ_REGS_ST;

			READ_REGS_ST:
				if (s_axis_tvalid == 1'b1) begin
					// tlast = 1.
					if (s_axis_tlast == 1'b1) begin
						// Last (completed) sample.
						if (cnt == NREG-1) begin
							state <= WRITE_LAST_ST;
						end
						// Last (non-completed) sample.
						else begin
							state <= END_ST;
						end
					end

					// tlast = 0.
					else begin
						// Last (completed) sample.
						if (cnt == NREG-1)
							state <= WRITE_ST;
					end
				end

			WRITE_ST:
				if ( cnt_wr == '1 )
					state <= READ_ADDR_ST;

			WRITE_LAST_ST:
				if ( cnt_wr == '1 )
					state <= END_ST;

			END_ST:
				if (START_REG_resync == 1'b0)
					state <= START_ST;
		endcase


		// Counter.
		if ( read_regs_state == 1'b1)
			cnt <= cnt + 1;
		else
			cnt <= 0;

		// Counter for write state.
		if ( write_state == 1'b1 )
			cnt_wr	<= cnt_wr + 1;
		else
			cnt_wr <= 0;

		// Address register.
		if ( read_addr_state == 1'b1 )
			addr_r	<= s_axis_tdata;
	end
end

// FSM outputs.
always_comb	begin
	// Default.
	start_state		= 0;
	read_addr_state	= 0;
	read_regs_state	= 0;
	write_state		= 0;
	end_state		= 0;

	case (state)
		START_ST:
			start_state 	= 1'b1;

		READ_ADDR_ST:
			read_addr_state	= 1'b1;

		READ_REGS_ST:
			read_regs_state	= 1'b1;

		WRITE_ST:
			write_state		= 1'b1;

		WRITE_LAST_ST:
			write_state		= 1'b1;

		END_ST:
			end_state	= 1'b1;
	endcase
end

// Assign outputs.
assign s_axis_tready	= read_addr_state | read_regs_state;

assign we				= we_i;

assign reg00_out		= regs_r[0];
assign reg01_out		= regs_r[1];
assign reg02_out		= regs_r[2];
assign reg03_out		= regs_r[3];
assign reg04_out		= regs_r[4];
assign reg05_out		= regs_r[5];
assign reg06_out		= regs_r[6];
assign reg07_out		= regs_r[7];
assign reg08_out		= regs_r[8];
assign reg09_out		= regs_r[9];
assign reg10_out		= regs_r[10];
assign reg11_out		= regs_r[11];
assign reg12_out		= regs_r[12];
assign reg13_out		= regs_r[13];
assign reg14_out		= regs_r[14];
assign reg15_out		= regs_r[15];

endmodule

