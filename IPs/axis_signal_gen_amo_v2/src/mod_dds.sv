// DDS: 
// * 18-bit for pinc/poff.
// * 16-bit for output.
//
// FMOD_Cx_REG, POFF_REG: pinc/poff word length.
// AMOD_Cx_REG: dds output word length.
module mod_dds
	#(
		// Number of bits of t.
		parameter BT = 8
	)
	(
		// Reset and clock.
		input 	wire 			rstn		,
		input 	wire 			clk			,
	
		// Trigger.
		input 	wire			trigger		,

		// Output data.
		output	wire [15:0]		dout		,

		// Registers.
		input	wire [BT-1:0]	WAIT_REG	,
		input 	wire [17:0]		FMOD_C0_REG	,
		input 	wire [17:0]		FMOD_C1_REG	,
		input 	wire [17:0]		FMOD_C2_REG	,
		input 	wire [17:0]		FMOD_C3_REG	,
		input 	wire [17:0]		FMOD_C4_REG	,
		input 	wire [17:0]		FMOD_C5_REG	,
		input	wire [17:0]		FMOD_G_REG	,
		input	wire [15:0]		AMOD_C0_REG	,
		input	wire [15:0]		AMOD_C1_REG	,
		input	wire [17:0]		POFF_REG	,
		input	wire			WE_REG
	);

/*************/
/* Internals */
/*************/
// Time Control.
wire					sync			;
wire					sync_la			;
wire					en				;
wire					en_la_fmod		;
wire					en_la_amod		;
wire		[BT-1:0]	t_out			;

// Frequency modulation.
wire signed	[17:0]		fmod_out		;
wire					fmod_valid		;

// Frequency modulation gain.
wire signed	[35:0]		fmod_g			;
wire signed	[17:0]		fmod_gq			;
reg	 signed [17:0]		fmod_gq_r		;

// Amplitude modulation.
wire		[15:0]		amod_out		;
wire 		[15:0]		amod_out_la		;
reg	signed	[15:0]		amod_r			;

// DDS.
wire		[55:0]		dds_din			;
wire signed	[15:0]		dds_dout		;

// Amplitude modulation product.
wire signed [31:0]		prod			;
wire		[15:0]		prod_q			;
reg			[15:0]		prod_r			;

// Registers.
reg 		[BT-1:0]	WAIT_REG_r		;
reg 		[17:0]		FMOD_C0_REG_r	;
reg 		[17:0]		FMOD_C1_REG_r	;
reg 		[17:0]		FMOD_C2_REG_r	;
reg 		[17:0]		FMOD_C3_REG_r	;
reg 		[17:0]		FMOD_C4_REG_r	;
reg 		[17:0]		FMOD_C5_REG_r	;
reg signed	[17:0]		FMOD_G_REG_r	;
reg 		[15:0]		AMOD_C0_REG_r	;
reg 		[15:0]		AMOD_C1_REG_r	;
reg 		[17:0]		POFF_REG_r		;
wire					WE_REG_resync	;


/****************/
/* Architecture */
/****************/

// WE_REG_resync.
synchronizer_n WE_REG_resync_i
	(
		.rstn	    (rstn			),
		.clk 		(clk			),
		.data_in	(WE_REG			),
		.data_out	(WE_REG_resync	)
	);

// Time Control.
time_ctrl
	#(
		.B(BT)
	)
	time_ctrl_i
	(
		// Reset and clock.
		.rstn		(rstn		),
		.clk		(clk		),
	
		// Trigger.
		.trigger	(trigger	),

		// Phase sync output.
		.sync		(sync		),

		// Output enable.
		.en			(en			),

		// Time output.
		.t_out		(t_out		),

		// Registers.
		.WAIT_REG	(WAIT_REG_r	)
	);

// MAC that implements 5th order polynomial.
// Latency: 11.
mac_5
	#(
		// Number of bits of coefficients.
		.BC(18),

		// Number of bits of t.
		.BT(BT),

		// Number of bits of y.
		.BY(18)
	)
	mac_5_i
	(
		// Reset and clock.
		.rstn		(rstn			),
		.clk		(clk			),

		// Coefficients.
		.t_in		(t_out			),
		.c0_in		(FMOD_C0_REG_r	),
		.c1_in		(FMOD_C1_REG_r	),
		.c2_in		(FMOD_C2_REG_r	),
		.c3_in		(FMOD_C3_REG_r	),
		.c4_in		(FMOD_C4_REG_r	),
		.c5_in		(FMOD_C5_REG_r	),

		// Output data.
		.y_out		(fmod_out		),
		.y_valid	(fmod_valid		)
	);

// Frequency modulation gain.
// fmod_out can be Q1.x - Q5.x.
// FMOD_G_REG will be the opposite of fmod_out (coefficients).
// fmod_g will always be Q6.x.
// fmod_gq will always be Q1.x.
assign fmod_g 	= fmod_out*FMOD_G_REG_r;
assign fmod_gq	= fmod_g[36-6 -: 18];

// MAC that implements 1st order polynomial.
// Latency: 2.
mac
	#(
		// Number of bits of c0 and c1.
		.BC(16),

		// Number of bits of t.
		.BT(BT),

		// Number of bits of y.
		.BY(16)
	)
	mac_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Input data.
		.c0		(AMOD_C0_REG_r	),
		.c1		(AMOD_C1_REG_r	),
		.t_in	(t_out			),

		// Output data.
		.t_out	(				),
		.y		(amod_out		)
	);

// amod latency.
// Latency: 12 from fmod - 2 from amod + 8 from dds - 1 from extra register.
latency_reg
	#(
		// Latency.
		.N(12-2+8-1),

		// Data width.
		.B(16)
	)
	amod_out_la_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Data input.
		.din	(amod_out		),

		// Data output.
		.dout	(amod_out_la	)
	);

// sync latency.
latency_reg
	#(
		// Latency.
		.N(12),

		// Data width.
		.B(1)
	)
	sync_la_i
	(
		// Reset and clock.
		.rstn	(rstn		),
		.clk	(clk		),

		// Data input.
		.din	(sync		),

		// Data output.
		.dout	(sync_la	)
	);

// en latency for fmod.
// Latency: that of frequency modulation (5th order).
latency_reg
	#(
		// Latency.
		.N(11),

		// Data width.
		.B(1)
	)
	en_la_fmod_i
	(
		// Reset and clock.
		.rstn	(rstn		),
		.clk	(clk		),

		// Data input.
		.din	(en			),

		// Data output.
		.dout	(en_la_fmod	)
	);

// en latency.
// Latency: 12 from fmod + 8 from dds - 1 from extra register.
latency_reg
	#(
		// Latency.
		.N(12+8-1),

		// Data width.
		.B(1)
	)
	en_la_amod_i
	(
		// Reset and clock.
		.rstn	(rstn		),
		.clk	(clk		),

		// Data input.
		.din	(en			),

		// Data output.
		.dout	(en_la_amod	)
	);

// DDS Control Input.
assign dds_din = {	{7{1'b0}}	, // 55 .. 49: xxx
					sync_la		, //       48: sync
					{6{1'b0}}	, // 47 .. 42: xxx
					POFF_REG_r	, // 41 .. 24: poff
					{6{1'b0}}	, // 23 .. 18: xxx
					fmod_gq_r	  // 17 ..  0: pinc
				};

// DDS.
// Latency: 8.
// DDS format:
// |----------|------|----------|----------|----------|---------|
// | 55 .. 49 | 48   | 47 .. 42 | 41 .. 24 | 23 .. 18 | 17 .. 0 |
// |----------|------|----------|----------|----------|---------|
// | xxx      | sync | xxx      | poff     | xxx      | pinc    |
// |----------|------|----------|----------|----------|---------|
dds_0
	dds_i
	(
  		.aclk					(clk		),
  		.s_axis_phase_tvalid	(fmod_valid	),
  		.s_axis_phase_tdata		(dds_din	),
  		.m_axis_data_tvalid		(			),
  		.m_axis_data_tdata		(dds_dout	)
	);

// Amplitude modulation product.
assign prod 	= dds_dout*amod_r;
assign prod_q	= prod[30 -: 16];

// Registers.
always @(posedge clk) begin
	if (~rstn) begin
		// Frequency modulation gain.
		fmod_gq_r		<= 0;

		// Amplitude modulation.
		amod_r			<= 0;
		
		// Amplitude modulation product.
		prod_r			<= 0;

		// Registers.
		WAIT_REG_r		<= 0;
		FMOD_C0_REG_r	<= 0;
		FMOD_C1_REG_r	<= 0;
		FMOD_C2_REG_r	<= 0;
		FMOD_C3_REG_r	<= 0;
		FMOD_C4_REG_r	<= 0;
		FMOD_C5_REG_r	<= 0;
		FMOD_G_REG_r	<= 0;
		AMOD_C0_REG_r	<= 0;
		AMOD_C1_REG_r	<= 0;
		POFF_REG_r		<= 0;
	end
	else begin
		// Frequency modulation gain.
		if (en_la_fmod == 1'b1)
			fmod_gq_r <= fmod_gq;

		// Amplitude modulation.
		if (en_la_amod == 1'b1)
			amod_r <= amod_out_la;

		// Amplitude modulation product.
		prod_r			<= prod_q;

		// Registers.
		if (WE_REG_resync == 1'b1) begin
			WAIT_REG_r		<= WAIT_REG		;
			FMOD_C0_REG_r	<= FMOD_C0_REG	;
			FMOD_C1_REG_r	<= FMOD_C1_REG	;
			FMOD_C2_REG_r	<= FMOD_C2_REG	;
			FMOD_C3_REG_r	<= FMOD_C3_REG	;
			FMOD_C4_REG_r	<= FMOD_C4_REG	;
			FMOD_C5_REG_r	<= FMOD_C5_REG	;
			FMOD_G_REG_r	<= FMOD_G_REG	;
			AMOD_C0_REG_r	<= AMOD_C0_REG	;
			AMOD_C1_REG_r	<= AMOD_C1_REG	;
			POFF_REG_r		<= POFF_REG		;
		end
	end
end 

// Assign outputs.
assign dout = prod_r;

endmodule

