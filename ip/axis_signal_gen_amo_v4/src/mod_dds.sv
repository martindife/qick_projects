// DDS: 
// * 18-bit for pinc/poff.
// * 16-bit for output.
//
// FMOD_Cx_REG, POFF_REG: pinc/poff word length.
// AMOD_Cx_REG: dds output word length.
//
// Memory parameters fields:
// |------------|------------|------------|------------|------------|------------|------------|------------|-----------|----------|----------|----------|----------|---------|
// | 231 .. 224 | 223 .. 206 | 195 .. 190 | 189 .. 174 | 173 .. 158 | 157 .. 142 | 141 .. 126 | 125 .. 108 | 107 .. 90 | 89 .. 72 | 71 .. 54 | 53 .. 36 | 35 .. 18 | 17 .. 0 |
// |------------|------------|------------|------------|------------|------------|------------|------------|-----------|----------|----------|----------|----------|---------|
// |       CTRL |       POFF |     AMOD_G |    AMOD_C3 |    AMOD_C2 |    AMOD_C1 |    AMOD_C0 |     FMOD_G |   FMOD_C5 |  FMOD_C4 |  FMOD_C3 |  FMOD_C2 |  FMOD_C1 | FMOD_C0 |
// |------------|------------|------------|------------|------------|------------|------------|------------|-----------|----------|----------|----------|----------|---------|
module mod_dds
	#(
		// Number of bits of t.
		parameter BT = 8
	)
	(
		// Reset and clock.
		input 	wire 				rstn		,
		input 	wire 				clk			,

		// Memory output with parameters.
		input	wire	[255:0]		mem_dout	,

		// Control bits.
		input	wire	[7:0]		ctrl		,

		// Phase sync.
		input	wire				sync		,

		// Time base.
		input	wire				t_in_valid	,
		input	wire	[BT-1:0]	t_in		,
	
		// Output data.
		output	wire				dout_valid	,
		output	wire 	[15:0]		dout		,
		output	wire 	[15:0]		dout_aux
	);

/*************/
/* Internals */
/*************/
// Frequency modulation.
wire signed	[17:0]		fmod_out		;
wire					fmod_valid		;

// Frequency modulation gain.
wire signed	[35:0]		fmod_g			;
wire signed	[17:0]		fmod_gq			;
reg	 signed [17:0]		fmod_gq_r		;

// Amplitude modulation.
wire		[15:0]		amod_out		;
wire					amod_valid		;

// Amplitude modulation gain.
wire signed	[31:0]		amod_g			;
wire signed	[15:0]		amod_gq			;
wire signed [15:0]		amod_gq_la		;
reg	 signed [15:0]		amod_r1			;
reg	 signed [15:0]		amod_r2			;

// DDS.
wire		[55:0]		dds_din			;
wire signed	[15:0]		dds_dout		;

// Amplitude modulation product.
wire signed [31:0]		prod			;
wire		[15:0]		prod_q			;
reg			[15:0]		prod_r			;

// Parameters.
wire 		[17:0]		FMOD_C0_int		;
wire 		[17:0]		FMOD_C1_int		;
wire 		[17:0]		FMOD_C2_int		;
wire 		[17:0]		FMOD_C3_int		;
wire 		[17:0]		FMOD_C4_int		;
wire 		[17:0]		FMOD_C5_int		;
wire signed	[17:0]		FMOD_G_int		;
wire 		[15:0]		AMOD_C0_int		;
wire 		[15:0]		AMOD_C1_int		;
wire 		[15:0]		AMOD_C2_int		;
wire 		[15:0]		AMOD_C3_int		;
wire signed	[15:0]		AMOD_G_int		;
wire 		[17:0]		POFF_int		;
wire		[7:0]		CTRL_int		;

// sync latency.
wire					sync_la			;

// FMOD_G latency.
wire signed	[17:0]		FMOD_G_la		;

// AMOD_G latency.
wire signed	[15:0]		AMOD_G_la		;

// POFF latency.
wire		[17:0]		POFF_la			;

// t_in_valid latency.
wire					fmod_valid_la	;
wire					amod_valid_la	;
wire					valid_la		;

/****************/
/* Architecture */
/****************/

// Parameters.
assign FMOD_C0_int	= mem_dout[0	+: 18];
assign FMOD_C1_int	= mem_dout[18	+: 18];
assign FMOD_C2_int	= mem_dout[36	+: 18];
assign FMOD_C3_int	= mem_dout[54	+: 18];
assign FMOD_C4_int	= mem_dout[72 	+: 18];
assign FMOD_C5_int	= mem_dout[90 	+: 18];
assign FMOD_G_int	= mem_dout[108	+: 18];
assign AMOD_C0_int	= mem_dout[126	+: 16];
assign AMOD_C1_int	= mem_dout[142	+: 16];
assign AMOD_C2_int	= mem_dout[158	+: 16];
assign AMOD_C3_int	= mem_dout[174	+: 16];
assign AMOD_G_int	= mem_dout[190	+: 16];
assign POFF_int		= mem_dout[206	+: 18];
assign CTRL_int		= mem_dout[224	+:  8];

// MAC that implements 5th order polynomial.
// Latency: 16.
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
		.t_in		(t_in			),
		.c0_in		(FMOD_C0_int	),
		.c1_in		(FMOD_C1_int	),
		.c2_in		(FMOD_C2_int	),
		.c3_in		(FMOD_C3_int	),
		.c4_in		(FMOD_C4_int	),
		.c5_in		(FMOD_C5_int	),

		// Output data.
		.y_out		(fmod_out		),
		.y_valid	(fmod_valid		)
	);

// Frequency modulation gain.
// fmod_out can be Q1.x - Q5.x.
// FMOD_G_REG will be the opposite of fmod_out (coefficients).
// fmod_g will always be Q6.x.
// fmod_gq will always be Q1.x.
assign fmod_g 	= fmod_out*FMOD_G_la;
assign fmod_gq	= fmod_g[36-6 -: 18];

// MAC that implements 3rd order polynomial.
// Latency: 10.
mac_3
	#(
		// Number of bits of coefficients.
		.BC(16),

		// Number of bits of t.
		.BT(BT),

		// Number of bits of y.
		.BY(16)
	)
	mac_3_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Coefficients.
		.t_in		(t_in			),
		.c0_in		(AMOD_C0_int	),
		.c1_in		(AMOD_C1_int	),
		.c2_in		(AMOD_C2_int	),
		.c3_in		(AMOD_C3_int	),

		// Output data.
		.y_out		(amod_out		),
		.y_valid	(amod_valid		)
	);

// Amplitude modulation gain.
// amod_out can be Q1.x - Q3.x.
// AMOD_G_REG will be the opposite of amod_out (coefficients).
// amod_g will always be Q4.x.
// amod_gq will always be Q1.x.
assign amod_g 	= amod_out*AMOD_G_la;
assign amod_gq	= amod_g[32-4 -: 16];

// amod_gq latency.
// Latency: 16+1 from fmod - 10 from amod + 8 from dds - 1 from extra register.
latency_reg
	#(
		// Latency.
		.N(16+1-10+8-1),

		// Data width.
		.B(16)
	)
	amod_gq_la_i
	(
		// Reset and clock.
		.rstn	(rstn		),
		.clk	(clk		),

		// Data input.
		.din	(amod_gq	),

		// Data output.
		.dout	(amod_gq_la	)
	);

// sync latency.
latency_reg
	#(
		// Latency.
		.N(17),

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

// FMOD_G latency.
latency_reg
	#(
		// Latency.
		.N(16),

		// Data width.
		.B(18)
	)
	FMOD_G_la_i
	(
		// Reset and clock.
		.rstn	(rstn		),
		.clk	(clk		),

		// Data input.
		.din	(FMOD_G_int	),

		// Data output.
		.dout	(FMOD_G_la	)
	);

// AMOD_G latency.
latency_reg
	#(
		// Latency.
		.N(10),

		// Data width.
		.B(16)
	)
	AMOD_G_la_i
	(
		// Reset and clock.
		.rstn	(rstn		),
		.clk	(clk		),

		// Data input.
		.din	(AMOD_G_int	),

		// Data output.
		.dout	(AMOD_G_la	)
	);

// POFF latency.
latency_reg
	#(
		// Latency.
		.N(17),

		// Data width.
		.B(18)
	)
	POFF_la_i
	(
		// Reset and clock.
		.rstn	(rstn		),
		.clk	(clk		),

		// Data input.
		.din	(POFF_int	),

		// Data output.
		.dout	(POFF_la	)
	);

// fmod_valid latency.
// Latency: 16 from fmod.
latency_reg
	#(
		// Latency.
		.N(16),

		// Data width.
		.B(1)
	)
	fmod_valid_la_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Data input.
		.din	(t_in_valid		),

		// Data output.
		.dout	(fmod_valid_la	)
	);

// amod_valid latency.
// Latency: 16+1 from fmod + 8 from dds - 1 from extra register.
latency_reg
	#(
		// Latency.
		.N(16+1+8-1),

		// Data width.
		.B(1)
	)
	amod_valid_la_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Data input.
		.din	(t_in_valid		),

		// Data output.
		.dout	(amod_valid_la	)
	);

// valid latency.
// Latency: 16+1 from fmod + 8 from dds + 1 from extra register.
latency_reg
	#(
		// Latency.
		.N(16+1+8+1),

		// Data width.
		.B(1)
	)
	valid_la_i
	(
		// Reset and clock.
		.rstn	(rstn			),
		.clk	(clk			),

		// Data input.
		.din	(t_in_valid		),

		// Data output.
		.dout	(valid_la		)
	);

// DDS Control Input.
assign dds_din = {	{7{1'b0}}	, // 55 .. 49: xxx
					sync_la		, //       48: sync
					{6{1'b0}}	, // 47 .. 42: xxx
					POFF_la		, // 41 .. 24: poff
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
assign prod 	= dds_dout*amod_r1;
assign prod_q	= prod[30 -: 16];

// Registers.
always @(posedge clk) begin
	if (~rstn) begin
		// Frequency modulation gain.
		fmod_gq_r		<= 0;

		// Amplitude modulation.
		amod_r1			<= 0;
		amod_r2			<= 0;
		
		// Amplitude modulation product.
		prod_r			<= 0;
	end
	else begin
		// Frequency modulation gain.
		if (fmod_valid_la == 1'b1)
			fmod_gq_r <= fmod_gq;

		// Amplitude modulation.
		if (amod_valid_la == 1'b1)
			amod_r1 <= amod_gq_la;
		amod_r2 <= amod_r1;

		// Amplitude modulation product.
		prod_r <= prod_q;
	end
end 

// Assign outputs.
assign dout_valid	= valid_la;
assign dout 		= prod_r;
assign dout_aux		= amod_r2;

endmodule

