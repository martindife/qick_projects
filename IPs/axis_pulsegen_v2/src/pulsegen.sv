// Pulse Generation Block:
// 32 samples are specified, to cover 2 AXIS transaction for the DAC.
// WAIT_REG can be used to specify the repetition time between outputs.
//
// start input should be synchronous to aclk, it is not re-synced.
module pulsegen
	(
		// Reset and clock.
		input 	wire				aresetn			,
		input	wire				aclk			,

		// m_axis_* for output.
		output	wire				m_axis_tvalid	,
		output	wire [16*16-1:0]	m_axis_tdata	,

		// Start.
		input 	wire				start			,

		// Registers.
		input   wire [15:0]			SAMP0_REG		,
		input   wire [15:0]			SAMP1_REG		,
		input   wire [15:0]			SAMP2_REG		,
		input   wire [15:0]			SAMP3_REG		,
		input   wire [15:0]			SAMP4_REG		,
		input   wire [15:0]			SAMP5_REG		,
		input   wire [15:0]			SAMP6_REG		,
		input   wire [15:0]			SAMP7_REG		,
		input   wire [15:0]			SAMP8_REG		,
		input   wire [15:0]			SAMP9_REG		,
		input   wire [15:0]			SAMP10_REG		,
		input   wire [15:0]			SAMP11_REG		,
		input   wire [15:0]			SAMP12_REG		,
		input   wire [15:0]			SAMP13_REG		,
		input   wire [15:0]			SAMP14_REG		,
		input   wire [15:0]			SAMP15_REG		,
		input   wire [15:0]			SAMP16_REG		,
		input   wire [15:0]			SAMP17_REG		,
		input   wire [15:0]			SAMP18_REG		,
		input   wire [15:0]			SAMP19_REG		,
		input   wire [15:0]			SAMP20_REG		,
		input   wire [15:0]			SAMP21_REG		,
		input   wire [15:0]			SAMP22_REG		,
		input   wire [15:0]			SAMP23_REG		,
		input   wire [15:0]			SAMP24_REG		,
		input   wire [15:0]			SAMP25_REG		,
		input   wire [15:0]			SAMP26_REG		,
		input   wire [15:0]			SAMP27_REG		,
		input   wire [15:0]			SAMP28_REG		,
		input   wire [15:0]			SAMP29_REG		,
		input   wire [15:0]			SAMP30_REG		,
		input   wire [15:0]			SAMP31_REG		,
		input	wire				START_REG		,
		input	wire				START_SRC_REG	,
		input	wire				MODE_REG		,
		input	wire [31:0]			WAIT_REG
	);

/*************/
/* Internals */
/*************/
// Number of parallel samples on output.
localparam N = 16;

// States.
typedef enum	{	INIT_ST		,
					REGS_ST		,
					DUMMY0_ST	,
					DUMMY1_ST	,
					OUT0_ST		,
					OUT1_ST		,
					WAIT_ST
				} state_t;

// State register.
(* fsm_encoding = "one_hot" *) state_t state;

reg					init_state			;
reg					regs_state			;
reg					out0_state			;
reg					out1_state			;
reg					wait_state			;

// Counter.
reg	 	[31:0]		cnt					;

// Muxed start: start input not synced, as it is synchronous to aclk.
wire				start_mux			;

// Samples.
wire 	[15:0]		samp0_v	[N]			;
reg		[15:0]		samp0_r1[N]			;
reg 	[15:0]		samp0_r2[N]			;
wire	[N*16-1:0]	samp0				;
wire	[15:0]		samp1_v	[N]			;
reg		[15:0]		samp1_r1[N]			;
reg 	[15:0]		samp1_r2[N]			;
wire	[N*16-1:0]	samp1				;

// Muxed output.
wire	[N*16-1:0]	dout_mux			;
reg		[N*16-1:0]	dout_mux_r1			;
reg		[N*16-1:0]	dout_mux_r2			;

// Re-sync registers.
wire				START_REG_resync	;
wire				START_SRC_REG_resync;
reg					MODE_REG_r1			;	// 0 : 16 samples. 1 : 32 samples.
reg					MODE_REG_r2			;	// 0 : 16 samples. 1 : 32 samples.
reg [31:0]			wait_r1				;
reg [31:0]			wait_r2				;

// Flag for 0 wait time.
wire				flag_zero			;

// selecion for output mux.
wire [1:0]			sel					;

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

// START_SRC_REG_resync.
synchronizer_n START_SRC_REG_resync_i
	(
		.rstn	    (aresetn				),
		.clk 		(aclk					),
		.data_in	(START_SRC_REG			),
		.data_out	(START_SRC_REG_resync	)
	);

// Muxed start.
assign start_mux = (START_SRC_REG_resync == 1'b1)? start : START_REG_resync;

// Samples.
assign samp0_v [0] 	= SAMP0_REG;
assign samp0_v [1] 	= SAMP1_REG;
assign samp0_v [2] 	= SAMP2_REG;
assign samp0_v [3] 	= SAMP3_REG;
assign samp0_v [4] 	= SAMP4_REG;
assign samp0_v [5] 	= SAMP5_REG;
assign samp0_v [6] 	= SAMP6_REG;
assign samp0_v [7] 	= SAMP7_REG;
assign samp0_v [8] 	= SAMP8_REG;
assign samp0_v [9] 	= SAMP9_REG;
assign samp0_v [10]	= SAMP10_REG;
assign samp0_v [11]	= SAMP11_REG;
assign samp0_v [12]	= SAMP12_REG;
assign samp0_v [13]	= SAMP13_REG;
assign samp0_v [14]	= SAMP14_REG;
assign samp0_v [15]	= SAMP15_REG;
assign samp1_v [0] 	= SAMP16_REG;
assign samp1_v [1] 	= SAMP17_REG;
assign samp1_v [2] 	= SAMP18_REG;
assign samp1_v [3] 	= SAMP19_REG;
assign samp1_v [4] 	= SAMP20_REG;
assign samp1_v [5] 	= SAMP21_REG;
assign samp1_v [6] 	= SAMP22_REG;
assign samp1_v [7] 	= SAMP23_REG;
assign samp1_v [8] 	= SAMP24_REG;
assign samp1_v [9] 	= SAMP25_REG;
assign samp1_v [10]	= SAMP26_REG;
assign samp1_v [11]	= SAMP27_REG;
assign samp1_v [12]	= SAMP28_REG;
assign samp1_v [13]	= SAMP29_REG;
assign samp1_v [14]	= SAMP30_REG;
assign samp1_v [15]	= SAMP31_REG;

// Muxed output.
assign dout_mux	=	(sel == 0)? samp0 :
					(sel == 1)? samp1 : 0;

// Flag for 0 wait time.
assign flag_zero= (wait_r2 == 0);

// Selecion for output mux.
assign sel 		= 	(out0_state == 1'b1)? 0 :
					(out1_state == 1'b1)? 1 : 2;	

genvar i;
generate
	for (i=0; i<N; i++) begin
		// Registers.
		always @(posedge aclk) begin
			if (~aresetn) begin
				// Samples.
				samp0_r1 [i]	<= 0;
				samp0_r2 [i]	<= 0;
				samp1_r1 [i]	<= 0;
				samp1_r2 [i]	<= 0;

			end
			else begin
				// Samples.
				if (regs_state == 1'b1) begin
					samp0_r1 [i]	<= samp0_v [i];
					samp1_r1 [i]	<= samp1_v [i];
				end

				samp0_r2 [i] <= samp0_r1 [i];
				samp1_r2 [i] <= samp1_r1 [i];

			end
		end 

		// Samples.
		assign samp0 [i*16 +: 16] 	= samp0_r2[i];
		assign samp1 [i*16 +: 16] 	= samp1_r2[i];
	end
endgenerate

// Registers.
always @(posedge aclk) begin
	if (~aresetn) begin
		// State register.
		state 		<= INIT_ST;

		// Counter.
		cnt			<= 0;

		// Muxed output.
		dout_mux_r1	<= 0;
		dout_mux_r2	<= 0;

		// Re-sync registers.
		MODE_REG_r1	<= 0;
		MODE_REG_r2	<= 0;
		wait_r1		<= 0;
		wait_r2		<= 0;
	end
	else begin
		// State register.
		case (state)
			INIT_ST:
				if (start_mux == 1'b1)
					state <= REGS_ST;

			REGS_ST:
					state <= DUMMY0_ST;

			DUMMY0_ST:
					state <= DUMMY1_ST;

			DUMMY1_ST:
					state <= OUT0_ST;

			OUT0_ST:
				if (start_mux == 1'b0)
					state <= INIT_ST;
				else if (MODE_REG_r2 == 1'b1)
					state <= OUT1_ST;
				else if (flag_zero == 1'b0)
					state <= WAIT_ST;

			OUT1_ST:
				if (flag_zero == 1'b0)
					state <= WAIT_ST;
				else
					state <= OUT0_ST;

			WAIT_ST:
				if (cnt == wait_r2)
					state <= OUT0_ST;
		endcase

		// Counter.
		if (wait_state == 1'b1)
			cnt <= cnt + 1;
		else
			cnt <= 0;

		// Muxed output.
		dout_mux_r1		<= dout_mux;
		dout_mux_r2		<= dout_mux_r1;

		// Re-sync registers.
		if (regs_state == 1'b1) begin
			MODE_REG_r1	<= MODE_REG;
			wait_r1		<= WAIT_REG;
		end

		MODE_REG_r2	<= MODE_REG_r1;
		wait_r2		<= wait_r1;
	end
end 

// FSM outputs.
always_comb	begin
	// Default.
	init_state	= 1'b0;
	regs_state	= 1'b0;
	out0_state	= 1'b0;
	out1_state	= 1'b0;
	wait_state	= 1'b0;

	case (state)
		INIT_ST:
			init_state 	= 1'b1;

		REGS_ST:
			regs_state 	= 1'b1;

		//DUMMY0_ST:

		//DUMMY1_ST:

		OUT0_ST:
			out0_state	= 1'b1;

		OUT1_ST:
			out1_state	= 1'b1;

		WAIT_ST:
			wait_state	= 1'b1;
	endcase
end

// Assign outputs.
assign m_axis_tvalid	= 1'b1;
assign m_axis_tdata		= dout_mux_r2;

endmodule

