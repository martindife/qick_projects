// This block writes memories using DMA as input.
//
// Register 0 	 : always used for memory address.
// Register 1-14 : memory parameter fields (see below).
//
// Memory parameters fields:
// |------------|------------|------------|------------|------------|------------|------------|------------|-----------|----------|----------|----------|----------|---------|
// | 231 .. 224 | 223 .. 206 | 205 .. 190 | 189 .. 174 | 173 .. 158 | 157 .. 142 | 141 .. 126 | 125 .. 108 | 107 .. 90 | 89 .. 72 | 71 .. 54 | 53 .. 36 | 35 .. 18 | 17 .. 0 |
// |------------|------------|------------|------------|------------|------------|------------|------------|-----------|----------|----------|----------|----------|---------|
// |       CTRL |       POFF |     AMOD_G |    AMOD_C3 |    AMOD_C2 |    AMOD_C1 |    AMOD_C0 |     FMOD_G |   FMOD_C5 |  FMOD_C4 |  FMOD_C3 |  FMOD_C2 |  FMOD_C1 | FMOD_C0 |
// |------------|------------|------------|------------|------------|------------|------------|------------|-----------|----------|----------|----------|----------|---------|
module mem_writer
	(
		// Reset and clock.
		input 	wire 			rstn			,
		input 	wire 			clk				,

		// AXIS for data input.
		input	wire			s_axis_tvalid	,
		output	wire			s_axis_tready	,
		input	wire	[31:0]	s_axis_tdata	,
		input	wire			s_axis_tlast	,
	
		// Memory interface.
		output	wire	[15:0]	mem_addr		,
		output	wire	[255:0]	mem_din			,
		output	wire	[31:0]	mem_we			,
		
		// Registers.
		input	wire			START_REG
	);

/*************/
/* Internals */
/*************/
// Number of registers (address + fields).
localparam NREG 	= 15;

// Maximum number of blocks.
localparam NB 		= 32;
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

// Address register.
reg		[NB_LOG2-1:0]	addr_r				;

// Register array.
reg		[31:0]			regs_r [NREG]		;

// Memory fields.
wire	[17:0]			mem_fmod_c0			;
wire	[17:0]			mem_fmod_c1			;
wire	[17:0]			mem_fmod_c2			;
wire	[17:0]			mem_fmod_c3			;
wire	[17:0]			mem_fmod_c4			;
wire	[17:0]			mem_fmod_c5			;
wire	[17:0]			mem_fmod_g			;
wire	[15:0]			mem_amod_c0			;
wire	[15:0]			mem_amod_c1			;
wire	[15:0]			mem_amod_c2			;
wire	[15:0]			mem_amod_c3			;
wire	[15:0]			mem_amod_g			;
wire	[17:0]			mem_poff			;
wire	[7:0]			mem_ctrl			;

// Memory interface.
wire	[15:0]			mem_addr_i			;
wire	[255:0]			mem_din_i			;
wire	[31:0]			mem_we_i			;

reg		[15:0]			mem_addr_r1			;
reg		[255:0]			mem_din_r1			;
reg		[31:0]			mem_we_r1			;

// START_REG_resync.
wire					START_REG_resync	;


/****************/
/* Architecture */
/****************/

// Memory fields.
assign mem_fmod_c0	= regs_r [1];
assign mem_fmod_c1	= regs_r [2];
assign mem_fmod_c2	= regs_r [3];
assign mem_fmod_c3	= regs_r [4];
assign mem_fmod_c4	= regs_r [5];
assign mem_fmod_c5	= regs_r [6];
assign mem_fmod_g	= regs_r [7];
assign mem_amod_c0	= regs_r [8];
assign mem_amod_c1	= regs_r [9];
assign mem_amod_c2	= regs_r [10];
assign mem_amod_c3	= regs_r [11];
assign mem_amod_g	= regs_r [12];
assign mem_poff		= regs_r [13];
assign mem_ctrl		= regs_r [14];

// Memory interface.
assign mem_addr_i	= regs_r[0];
assign mem_din_i	= 	{	mem_ctrl	,
							mem_poff	,
							mem_amod_g	,
							mem_amod_c3	,
							mem_amod_c2	,
							mem_amod_c1	,
							mem_amod_c0	,
							mem_fmod_g	,
							mem_fmod_c5	,
							mem_fmod_c4	,
							mem_fmod_c3	,
							mem_fmod_c2	,
							mem_fmod_c1	,
							mem_fmod_c0	};

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
		assign mem_we_i[i] = (addr_r == i)? write_state : 1'b0;
	end
endgenerate

// Registers.
always @(posedge clk) begin
	if (rstn == 1'b0) begin
		// State register.
		state 		<= START_ST;

		// Counter.
		cnt			<= 0;

		// Address register.
		addr_r		<= 0;

		// Memory interface.
		mem_addr_r1	<= 0;
		mem_din_r1	<= 0;
		mem_we_r1	<= 0;
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
				state <= READ_ADDR_ST;

			WRITE_LAST_ST:
				state <= END_ST;

			END_ST:
				if (START_REG_resync == 1'b0)
					state <= START_ST;
		endcase


		// Counter.
		if ( s_axis_tvalid == 1'b1)
			if ( read_regs_state == 1'b1 )
				cnt <= cnt + 1;
			else
				cnt <= 0;

		// Address register.
		if ( read_addr_state == 1'b1 )
			addr_r	<= s_axis_tdata;

		// Memory interface.
		mem_addr_r1	<= mem_addr_i;
		mem_din_r1	<= mem_din_i;
		mem_we_r1	<= mem_we_i;
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

assign mem_addr			= mem_addr_r1;
assign mem_din			= mem_din_r1;
assign mem_we			= mem_we_r1;

endmodule

