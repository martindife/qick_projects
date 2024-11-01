module mod_dds_top
	#(
		// Number of bits of t.
		parameter BT = 8
	)
	(
		// Trigger.
		input 	wire			trigger			,

		// Auxiliary trigger output.
		output	wire			trigger_out		,

		// s_axis for configuration.
		input	wire			s_axis_aresetn	,
		input	wire			s_axis_aclk		,
		input	wire			s_axis_tvalid	,
		output	wire			s_axis_tready	,
		input	wire	[31:0]	s_axis_tdata	,
		input	wire			s_axis_tlast	,

		// m_axis for data output.
		input	wire			m_axis_aresetn	,
		input	wire			m_axis_aclk		,
		output	wire			m_axis_tvalid	,
		output	wire	[15:0]	m_axis_tdata	,
	
		// Registers.
		input	wire			REGW_START_REG	,
		input	wire			TRIGGER_SRC_REG	,
		input	wire			TRIGGER_REG		,
		input	wire	[3:0]	QSEL_REG
	);

/*************/
/* Internals */
/*************/
// Number of DDSs.
localparam NDDS 		= 16;
localparam NDDS_LOG2 	= $clog2(NDDS);

// Number of registers per DDS instance.
localparam NREG 		= 11;

// Number of bits of Frequency Modulation.
localparam BFREQ		= 18;

// Number of bits of Amptlitue Modulation.
localparam BAMP			= 16;

// Number of bits for addition.
localparam BA			= BAMP + NDDS_LOG2;

// Write Enable vector.
wire [63:0]				we_int					;

// Registers.
wire [BT-1:0]			WAIT_REG				;
wire [BFREQ-1:0]		FMOD_C0_REG				;
wire [BFREQ-1:0]		FMOD_C1_REG				;
wire [BFREQ-1:0]		FMOD_C2_REG				;
wire [BFREQ-1:0]		FMOD_C3_REG				;
wire [BFREQ-1:0]		FMOD_C4_REG				;
wire [BFREQ-1:0]		FMOD_C5_REG				;
wire [BFREQ-1:0]		FMOD_G_REG				;
wire [BAMP-1:0]			AMOD_C0_REG				;
wire [BAMP-1:0]			AMOD_C1_REG				;
wire [BFREQ-1:0]		POFF_REG				;

// Re-sync.
wire					trigger_resync			;
wire					TRIGGER_SRC_REG_resync	;
wire					TRIGGER_REG_resync		;

// Trigger mux.
wire					trigger_mux				;

// mod_dds outputs.
wire 		[BAMP-1:0]	dds_dout 	[NDDS]		;
reg  		[BAMP-1:0]	dds_dout_r1	[NDDS]		;

// Sign-extended DDS outputs.
wire signed [BA-1:0]	dds_se		[NDDS]		;

// Addition stages.
wire signed [BA-1:0]	sum_0		[NDDS/2]	;
reg  signed [BA-1:0]	sum_0_r1	[NDDS/2]	;
wire signed [BA-1:0]	sum_1		[NDDS/4]	;
reg  signed [BA-1:0]	sum_1_r1	[NDDS/4]	;
wire signed [BA-1:0]	sum_2		[NDDS/8]	;
reg  signed [BA-1:0]	sum_2_r1	[NDDS/8]	;
wire signed [BA-1:0]	sum_3		[NDDS/16]	;
reg  signed [BA-1:0]	sum_3_r1	[NDDS/16]	;

// Quantized addition.
wire 		[BAMP-1:0]	sum_q					;

/****************/
/* Architecture */
/****************/
// trigger_resync.
synchronizer_n trigger_resync_i
	(
		.rstn	    (m_axis_aresetn	),
		.clk 		(m_axis_aclk	),
		.data_in	(trigger		),
		.data_out	(trigger_resync	)
	);

// TRIGGER_SRC_REG_resync.
synchronizer_n TRIGGER_SRC_REG_resync_i
	(
		.rstn	    (m_axis_aresetn			),
		.clk 		(m_axis_aclk			),
		.data_in	(TRIGGER_SRC_REG		),
		.data_out	(TRIGGER_SRC_REG_resync	)
	);

// TRIGGER_REG_resync.
synchronizer_n TRIGGER_REG_resync_i
	(
		.rstn	    (m_axis_aresetn		),
		.clk 		(m_axis_aclk		),
		.data_in	(TRIGGER_REG		),
		.data_out	(TRIGGER_REG_resync	)
	);

// Trigger mux.
// 0 : Internal.
// 1 : External.
assign trigger_mux = (TRIGGER_SRC_REG_resync == 1'b0)? TRIGGER_REG_resync : trigger_resync;

// Register Writer.
reg_writer
	#(
		.NREG(NREG)
	)
	reg_writer_i
	(
		// Reset and clock.
		.rstn			(s_axis_aresetn	),
		.clk			(s_axis_aclk	),

		// AXIS for data input.
		.s_axis_tvalid	(s_axis_tvalid	),
		.s_axis_tready	(s_axis_tready	),
		.s_axis_tdata	(s_axis_tdata	),
		.s_axis_tlast	(s_axis_tlast	),
	
		// Write Enable Vector.
		.we				(we_int			),
		
		// Register outputs.
		.reg00_out		(WAIT_REG		),
		.reg01_out		(FMOD_C0_REG	),
		.reg02_out		(FMOD_C1_REG	),
		.reg03_out		(FMOD_C2_REG	),
		.reg04_out		(FMOD_C3_REG	),
		.reg05_out		(FMOD_C4_REG	),
		.reg06_out		(FMOD_C5_REG	),
		.reg07_out		(FMOD_G_REG		),
		.reg08_out		(AMOD_C0_REG	),
		.reg09_out		(AMOD_C1_REG	),
		.reg10_out		(POFF_REG		),
		.reg11_out		(				),
		.reg12_out		(				),
		.reg13_out		(				),
		.reg14_out		(				),
		.reg15_out		(				),

		// Registers.
		.START_REG		(REGW_START_REG	)
	);

// Registers (generate).
genvar i;
generate
	for (i=0; i<NDDS; i=i+1) begin: GEN_dds
		// Modulated DDS block.
		mod_dds
			#(
				// Number of bits of t.
				.BT(BT)
			)
			mod_dds_i
			(
				// Reset and clock.
				.rstn			(m_axis_aresetn	),
				.clk			(m_axis_aclk	),
			
				// Trigger.
				.trigger		(trigger_mux	),
		
				// Output data.
				.dout			(dds_dout[i]	),
		
				// Registers.
				.WAIT_REG		(WAIT_REG		),
				.FMOD_C0_REG	(FMOD_C0_REG	),
				.FMOD_C1_REG	(FMOD_C1_REG	),
				.FMOD_C2_REG	(FMOD_C2_REG	),
				.FMOD_C3_REG	(FMOD_C3_REG	),
				.FMOD_C4_REG	(FMOD_C4_REG	),
				.FMOD_C5_REG	(FMOD_C5_REG	),
				.FMOD_G_REG		(FMOD_G_REG		),
				.AMOD_C0_REG	(AMOD_C0_REG	),
				.AMOD_C1_REG	(AMOD_C1_REG	),
				.POFF_REG		(POFF_REG		),
				.WE_REG			(we_int[i]		)
			);

		// Sign-extended DDS outputs.
		assign dds_se [i] = {{(BA-BAMP){dds_dout_r1[i][BAMP-1]}},dds_dout_r1[i]};

		// Addition stages.
		if 		( i < NDDS/16 ) begin
			assign sum_0 [i]	= dds_se 	[2*i] + dds_se 		[2*i+1];
			assign sum_1 [i]	= sum_0_r1	[2*i] + sum_0_r1	[2*i+1];
			assign sum_2 [i]	= sum_1_r1	[2*i] + sum_1_r1	[2*i+1];
			assign sum_3 [i]	= sum_2_r1	[2*i] + sum_2_r1	[2*i+1];
		end
		else if	( i < NDDS/8 ) begin
			assign sum_0 [i]	= dds_se 	[2*i] + dds_se 		[2*i+1];
			assign sum_1 [i]	= sum_0_r1	[2*i] + sum_0_r1	[2*i+1];
			assign sum_2 [i]	= sum_1_r1	[2*i] + sum_1_r1	[2*i+1];
		end
		else if ( i < NDDS/4 ) begin
			assign sum_0 [i]	= dds_se 	[2*i] + dds_se 		[2*i+1];
			assign sum_1 [i]	= sum_0_r1	[2*i] + sum_0_r1	[2*i+1];
		end
		else if ( i < NDDS/2 ) begin
			assign sum_0 [i]	= dds_se 	[2*i] + dds_se 		[2*i+1];
		end

		// Registers.
		always @(posedge m_axis_aclk) begin
			if ( ~m_axis_aresetn ) begin
				// mod_dds outputs.
				dds_dout_r1	[i] <= 0;

				// Addition stages.
				if 		( i < NDDS/16 ) begin
					sum_0_r1 [i]	<= 0;
					sum_1_r1 [i]	<= 0;
					sum_2_r1 [i]	<= 0;
					sum_3_r1 [i]	<= 0;
				end
				else if	( i < NDDS/8 ) begin
					sum_0_r1 [i]	<= 0;
					sum_1_r1 [i]	<= 0;
					sum_2_r1 [i]	<= 0;
				end
				else if ( i < NDDS/4 ) begin
					sum_0_r1 [i]	<= 0;
					sum_1_r1 [i]	<= 0;
				end
				else if ( i < NDDS/2 ) begin
					sum_0_r1 [i]	<= 0;
				end
			end
			else begin
				// mod_dds outputs.
				dds_dout_r1	[i] <= dds_dout [i];

				// Addition stages.
				if 		( i < NDDS/16 ) begin
					sum_0_r1 [i]	<= sum_0 [i];
					sum_1_r1 [i]	<= sum_1 [i];
					sum_2_r1 [i]	<= sum_2 [i];
					sum_3_r1 [i]	<= sum_3 [i];
				end
				else if	( i < NDDS/8 ) begin
					sum_0_r1 [i]	<= sum_0 [i];
					sum_1_r1 [i]	<= sum_1 [i];
					sum_2_r1 [i]	<= sum_2 [i];
				end
				else if ( i < NDDS/4 ) begin
					sum_0_r1 [i]	<= sum_0 [i];
					sum_1_r1 [i]	<= sum_1 [i];
				end
				else if ( i < NDDS/2 ) begin
					sum_0_r1 [i]	<= sum_0 [i];
				end

			end
		end

	end
endgenerate

// Quantized addition.
assign sum_q = sum_3_r1[0] [QSEL_REG +: BAMP];

// Assign outputs.
assign trigger_out	 = trigger_mux;
assign m_axis_tvalid = 1'b1;
assign m_axis_tdata	 = sum_q;

endmodule

