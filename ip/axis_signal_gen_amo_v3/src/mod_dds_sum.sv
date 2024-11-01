module mod_dds_sum
	#(
		// Number of bits of t.
		parameter BT 	= 8	,

		// Memory length (bits).
		parameter NMEM	= 8	,

		// Number of DDSs (do not edit).
		parameter NDDS 	= 32
	)
	(
		// Reset and clock.
		input	wire				aresetn				,
		input	wire				aclk				,

		// Memory write.
		input	wire	[NDDS-1:0]	mem_we				,
		input	wire	[NMEM-1:0]	mem_waddr			,
		input	wire	[255:0]		mem_din				,

		// Memory read.
		input	wire	[NMEM-1:0]	mem_raddr			,

		// Quantization.
		input	wire	[7:0]		qsel				,

		// Control flags.
		input	wire	[7:0]		ctrl				,

		// Phase sync.
		input	wire				sync				,

		// Time base.
		input	wire				t_in_valid			,
		input	wire	[BT-1:0]	t_in				,

		// m_axis for data output.
		output	wire				m_axis_tvalid		,
		output	wire	[15:0]		m_axis_tdata
	);

/*************/
/* Internals */
/*************/
localparam NDDS_LOG2 	= $clog2(NDDS);

// Number of bits of Frequency Modulation.
localparam BFREQ		= 18;

// Number of bits of Amptlitue Modulation.
localparam BAMP			= 16;

// Number of bits for addition.
localparam BA			= BAMP + NDDS_LOG2;

// Control flags.
reg			[7:0]		ctrl_r1						;
reg			[7:0]		ctrl_r2						;
reg			[7:0]		ctrl_r3						;

// Memory data.
wire		[255:0]		mem_dout		[NDDS]		;
reg			[255:0]		mem_dout_r1		[NDDS]		;
reg			[255:0]		mem_dout_r2		[NDDS]		;

// mod_dds outputs.
wire		[NDDS-1:0]	dds_dout_valid				;
wire 		[BAMP-1:0]	dds_dout 		[NDDS]		;
reg  		[BAMP-1:0]	dds_dout_r1		[NDDS]		;

// Or'ed valid.
wire					valid_i						;
wire					valid_la					;

// Valid pipe reg.
reg						valid_r						;

// Sign-extended DDS outputs.
wire signed [BA-1:0]	dds_se			[NDDS]		;

// Addition stages.
wire signed [BA-1:0]	sum_0			[NDDS/2]	;
reg  signed [BA-1:0]	sum_0_r1		[NDDS/2]	;
wire signed [BA-1:0]	sum_1			[NDDS/4]	;
reg  signed [BA-1:0]	sum_1_r1		[NDDS/4]	;
wire signed [BA-1:0]	sum_2			[NDDS/8]	;
reg  signed [BA-1:0]	sum_2_r1		[NDDS/8]	;
wire signed [BA-1:0]	sum_3			[NDDS/16]	;
reg  signed [BA-1:0]	sum_3_r1		[NDDS/16]	;
wire signed [BA-1:0]	sum_4			[NDDS/32]	;
reg  signed [BA-1:0]	sum_4_r1		[NDDS/32]	;

// Quantization.
wire		[7:0]		qsel_la						;
reg			[7:0]		qsel_r						;

// Quantized addition.
wire 		[BAMP-1:0]	sum_q						;

/****************/
/* Architecture */
/****************/
// Registers (generate).
genvar i;
generate
	for (i=0; i<NDDS; i=i+1) begin: GEN_dds
		bram_simple_dp
		    #(
		        // Memory address size.
		        .N(NMEM),
		        // Data width.
		        .B(256)
		    )
			bram_i
		    ( 
		        .clk   	(aclk			),
		        .ena    (1'b1			),
		        .enb    (1'b1			),
		        .wea    (mem_we		[i]	),
		        .addra  (mem_waddr		),
		        .addrb  (mem_raddr		),
		        .dia    (mem_din		),
		        .dob    (mem_dout	[i]	)
		    );

		// Modulated DDS block.
		// Latency: 26.
		mod_dds
			#(
				// Number of bits of t.
				.BT(BT)
			)
			mod_dds_i
			(
				// Reset and clock.
				.rstn		(aresetn			),
				.clk		(aclk				),
		
				// Memory output with parameters.
				.mem_dout	(mem_dout_r2	[i]	),

				// Control bits.
				.ctrl		(ctrl_r3			),

				// Phase sync.
				.sync		(sync				),
		
				// Time base.
				.t_in_valid	(t_in_valid			),
				.t_in		(t_in				),
			
				// Output data.
				.dout_valid	(dds_dout_valid	[i]	),
				.dout		(dds_dout		[i]	)
			);

		// Sign-extended DDS outputs.
		assign dds_se [i] = {{(BA-BAMP){dds_dout_r1[i][BAMP-1]}},dds_dout_r1[i]};

		// Addition stages.
		if 		( i < NDDS/32 ) begin
			assign sum_0 [i]	= dds_se 	[2*i] + dds_se 		[2*i+1];
			assign sum_1 [i]	= sum_0_r1	[2*i] + sum_0_r1	[2*i+1];
			assign sum_2 [i]	= sum_1_r1	[2*i] + sum_1_r1	[2*i+1];
			assign sum_3 [i]	= sum_2_r1	[2*i] + sum_2_r1	[2*i+1];
			assign sum_4 [i]	= sum_3_r1	[2*i] + sum_3_r1	[2*i+1];
		end
		else if	( i < NDDS/16 ) begin
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
		always @(posedge aclk) begin
			if ( ~aresetn ) begin
				// Memory data.
				mem_dout_r1	[i]	<= 0;
				mem_dout_r2	[i]	<= 0;

				// mod_dds outputs.
				dds_dout_r1	[i] <= 0;

				// Addition stages.
				if 		( i < NDDS/32 ) begin
					sum_0_r1 [i]	<= 0;
					sum_1_r1 [i]	<= 0;
					sum_2_r1 [i]	<= 0;
					sum_3_r1 [i]	<= 0;
					sum_4_r1 [i]	<= 0;
				end
				else if ( i < NDDS/16 ) begin
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
				// Memory data.
				mem_dout_r1	[i]	<= mem_dout		[i];
				mem_dout_r2	[i]	<= mem_dout_r1	[i];

				// mod_dds outputs.
				dds_dout_r1	[i] <= dds_dout [i];

				// Addition stages.
				if 		( i < NDDS/32 ) begin
					sum_0_r1 [i]	<= sum_0 [i];
					sum_1_r1 [i]	<= sum_1 [i];
					sum_2_r1 [i]	<= sum_2 [i];
					sum_3_r1 [i]	<= sum_3 [i];
					sum_4_r1 [i]	<= sum_4 [i];
				end
				else if	( i < NDDS/16 ) begin
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

// valid latency.
latency_reg
	#(
		// Latency.
		.N(5),

		// Data width.
		.B(1)
	)
	valid_la_i
	(
		// Reset and clock.
		.rstn	(aresetn	),
		.clk	(aclk		),

		// Data input.
		.din	(valid_i	),

		// Data output.
		.dout	(valid_la	)
	);

// Or'ed valid.
assign valid_i =| dds_dout_valid;

// qsel latency.
latency_reg
	#(
		// Latency.
		.N(31),

		// Data width.
		.B(8)
	)
	qsel_la_i
	(
		// Reset and clock.
		.rstn	(aresetn	),
		.clk	(aclk		),

		// Data input.
		.din	(qsel		),

		// Data output.
		.dout	(qsel_la	)
	);

// Quantized addition.
assign sum_q = sum_4_r1[0] [qsel_r +: BAMP];

// Registers.
always @(posedge aclk) begin
	if ( ~aresetn ) begin
		// Control flags.
		ctrl_r1	<= 0;
		ctrl_r2	<= 0;
		ctrl_r3	<= 0;

		// Valid pipe reg.
		valid_r	<= 0;

		// quantization.
		qsel_r	<= 0;
	end
	else begin
		// Control flags.
		ctrl_r1	<= ctrl;
		ctrl_r2	<= ctrl_r1;
		ctrl_r3	<= ctrl_r2;

		// Valid pipe reg.
		valid_r	<= valid_la;

		// quantization.
		if (valid_la == 1'b1)
			qsel_r	<= qsel_la;
	end
end

// Assign outputs.
assign m_axis_tvalid = valid_r;
assign m_axis_tdata	 = sum_q;

endmodule

