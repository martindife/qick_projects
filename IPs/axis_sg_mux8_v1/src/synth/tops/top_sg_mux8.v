module top
	#(
		// Number of parallel dds blocks.
		parameter N_DDS = 16
	)
	(
		input	wire					aresetn			,
		input	wire					aclk			,
		
		input	wire	[39:0]			s_axis_tdata_i	,
		input	wire					s_axis_tvalid_i	,
		output	wire					s_axis_tready_o	,
		
		input	wire					m_axis_tready_i	,
		output	wire					m_axis_tvalid_o	,
		output	wire	[N_DDS*16-1:0]	m_axis_tdata_o	,
		
		input	wire	[31:0]			PINC0_REG		,
		input	wire	[31:0]			PINC1_REG		,
		input	wire	[31:0]			PINC2_REG		,
		input	wire	[31:0]			PINC3_REG		,
		input	wire	[31:0]			PINC4_REG		,
		input	wire	[31:0]			PINC5_REG		,
		input	wire	[31:0]			PINC6_REG		,
		input	wire	[31:0]			PINC7_REG		,
		input	wire	[31:0]			POFF0_REG		,
		input	wire	[31:0]			POFF1_REG		,
		input	wire	[31:0]			POFF2_REG		,
		input	wire	[31:0]			POFF3_REG		,
		input	wire	[31:0]			POFF4_REG		,
		input	wire	[31:0]			POFF5_REG		,
		input	wire	[31:0]			POFF6_REG		,
		input	wire	[31:0]			POFF7_REG		,
		input	wire	[15:0]			GAIN0_REG		,
		input	wire	[15:0]			GAIN1_REG		,
		input	wire	[15:0]			GAIN2_REG		,
		input	wire	[15:0]			GAIN3_REG		,
		input	wire	[15:0]			GAIN4_REG		,
		input	wire	[15:0]			GAIN5_REG		,
		input	wire	[15:0]			GAIN6_REG		,
		input	wire	[15:0]			GAIN7_REG		,
		input	wire					WE_REG
	);

/***********/
/* Signals */
/***********/

reg		[39:0]			s_axis_tdata_i_r1	;
reg		[39:0]			s_axis_tdata_i_r2	;
reg						s_axis_tvalid_i_r1	;
reg						s_axis_tvalid_i_r2	;
wire					s_axis_tready_o_int	;
reg						s_axis_tready_o_r1	;
reg						s_axis_tready_o_r2	;
		
reg						m_axis_tready_i_r1	;
reg						m_axis_tready_i_r2	;
wire					m_axis_tvalid_o_int	;
reg						m_axis_tvalid_o_r1	;
reg						m_axis_tvalid_o_r2	;
wire	[N_DDS*16-1:0]	m_axis_tdata_o_int	;
reg		[N_DDS*16-1:0]	m_axis_tdata_o_r1	;
reg		[N_DDS*16-1:0]	m_axis_tdata_o_r2	;
		
reg		[31:0]			PINC0_REG_r1		;
reg		[31:0]			PINC1_REG_r1		;
reg		[31:0]			PINC2_REG_r1		;
reg		[31:0]			PINC3_REG_r1		;
reg		[31:0]			PINC4_REG_r1		;
reg		[31:0]			PINC5_REG_r1		;
reg		[31:0]			PINC6_REG_r1		;
reg		[31:0]			PINC7_REG_r1		;
reg		[31:0]			POFF0_REG_r1		;
reg		[31:0]			POFF1_REG_r1		;
reg		[31:0]			POFF2_REG_r1		;
reg		[31:0]			POFF3_REG_r1		;
reg		[31:0]			POFF4_REG_r1		;
reg		[31:0]			POFF5_REG_r1		;
reg		[31:0]			POFF6_REG_r1		;
reg		[31:0]			POFF7_REG_r1		;
reg		[15:0]			GAIN0_REG_r1		;
reg		[15:0]			GAIN1_REG_r1		;
reg		[15:0]			GAIN2_REG_r1		;
reg		[15:0]			GAIN3_REG_r1		;
reg		[15:0]			GAIN4_REG_r1		;
reg		[15:0]			GAIN5_REG_r1		;
reg		[15:0]			GAIN6_REG_r1		;
reg		[15:0]			GAIN7_REG_r1		;
reg						WE_REG_r1			;
reg		[31:0]			PINC0_REG_r2		;
reg		[31:0]			PINC1_REG_r2		;
reg		[31:0]			PINC2_REG_r2		;
reg		[31:0]			PINC3_REG_r2		;
reg		[31:0]			PINC4_REG_r2		;
reg		[31:0]			PINC5_REG_r2		;
reg		[31:0]			PINC6_REG_r2		;
reg		[31:0]			PINC7_REG_r2		;
reg		[31:0]			POFF0_REG_r2		;
reg		[31:0]			POFF1_REG_r2		;
reg		[31:0]			POFF2_REG_r2		;
reg		[31:0]			POFF3_REG_r2		;
reg		[31:0]			POFF4_REG_r2		;
reg		[31:0]			POFF5_REG_r2		;
reg		[31:0]			POFF6_REG_r2		;
reg		[31:0]			POFF7_REG_r2		;
reg		[15:0]			GAIN0_REG_r2		;
reg		[15:0]			GAIN1_REG_r2		;
reg		[15:0]			GAIN2_REG_r2		;
reg		[15:0]			GAIN3_REG_r2		;
reg		[15:0]			GAIN4_REG_r2		;
reg		[15:0]			GAIN5_REG_r2		;
reg		[15:0]			GAIN6_REG_r2		;
reg		[15:0]			GAIN7_REG_r2		;
reg						WE_REG_r2			;

sg_mux8 
	#(
		.N_DDS(N_DDS)
	)
	sg_mux8_i	
	(
	// Reset and clock.
	.aresetn			(aresetn			),
	.aclk				(aclk				),

    // S_AXIS to queue waveforms.
	.s_axis_tready_o	(s_axis_tready_o_int),
	.s_axis_tvalid_i	(s_axis_tvalid_i_r2	),
	.s_axis_tdata_i		(s_axis_tdata_i_r2	),

	// M_AXIS for output.
	.m_axis_tready_i	(m_axis_tready_i_r2	),
	.m_axis_tvalid_o	(m_axis_tvalid_o_int),
	.m_axis_tdata_o		(m_axis_tdata_o_int	),

	// Registers.
	.PINC0_REG			(PINC0_REG_r2		),
	.PINC1_REG			(PINC1_REG_r2		),
	.PINC2_REG			(PINC2_REG_r2		),
	.PINC3_REG			(PINC3_REG_r2		),
	.PINC4_REG			(PINC4_REG_r2		),
	.PINC5_REG			(PINC5_REG_r2		),
	.PINC6_REG			(PINC6_REG_r2		),
	.PINC7_REG			(PINC7_REG_r2		),
	.POFF0_REG			(POFF0_REG_r2		),
	.POFF1_REG			(POFF1_REG_r2		),
	.POFF2_REG			(POFF2_REG_r2		),
	.POFF3_REG			(POFF3_REG_r2		),
	.POFF4_REG			(POFF4_REG_r2		),
	.POFF5_REG			(POFF5_REG_r2		),
	.POFF6_REG			(POFF6_REG_r2		),
	.POFF7_REG			(POFF7_REG_r2		),
	.GAIN0_REG			(GAIN0_REG_r2		),
	.GAIN1_REG			(GAIN1_REG_r2		),
	.GAIN2_REG			(GAIN2_REG_r2		),
	.GAIN3_REG			(GAIN3_REG_r2		),
	.GAIN4_REG			(GAIN4_REG_r2		),
	.GAIN5_REG			(GAIN5_REG_r2		),
	.GAIN6_REG			(GAIN6_REG_r2		),
	.GAIN7_REG			(GAIN7_REG_r2		),
	.WE_REG				(WE_REG_r2			)
	);

always @(posedge aclk) begin
	s_axis_tdata_i_r1	<= s_axis_tdata_i		;
	s_axis_tdata_i_r2	<= s_axis_tdata_i_r1	;
	s_axis_tvalid_i_r1	<= s_axis_tvalid_i		;
	s_axis_tvalid_i_r2	<= s_axis_tvalid_i_r1	;
	s_axis_tready_o_r1	<= s_axis_tready_o_int	;
	s_axis_tready_o_r2	<= s_axis_tready_o_r1	;
	
	m_axis_tready_i_r1	<= m_axis_tready_i		;
	m_axis_tready_i_r2	<= m_axis_tready_i_r1	;
	m_axis_tvalid_o_r1	<= m_axis_tvalid_o_int	;
	m_axis_tvalid_o_r2	<= m_axis_tvalid_o_r1	;
	m_axis_tdata_o_r1	<= m_axis_tdata_o_int	;
	m_axis_tdata_o_r2	<= m_axis_tdata_o_r1	;
	
	PINC0_REG_r1		<= PINC0_REG			;
	PINC1_REG_r1		<= PINC1_REG			;
	PINC2_REG_r1		<= PINC2_REG			;
	PINC3_REG_r1		<= PINC3_REG			;
	PINC4_REG_r1		<= PINC4_REG			;
	PINC5_REG_r1		<= PINC5_REG			;
	PINC6_REG_r1		<= PINC6_REG			;
	PINC7_REG_r1		<= PINC7_REG			;
	POFF0_REG_r1		<= POFF0_REG			;
	POFF1_REG_r1		<= POFF1_REG			;
	POFF2_REG_r1		<= POFF2_REG			;
	POFF3_REG_r1		<= POFF3_REG			;
	POFF4_REG_r1		<= POFF4_REG			;
	POFF5_REG_r1		<= POFF5_REG			;
	POFF6_REG_r1		<= POFF6_REG			;
	POFF7_REG_r1		<= POFF7_REG			;
	GAIN0_REG_r1		<= GAIN0_REG			;
	GAIN1_REG_r1		<= GAIN1_REG			;
	GAIN2_REG_r1		<= GAIN2_REG			;
	GAIN3_REG_r1		<= GAIN3_REG			;
	GAIN4_REG_r1		<= GAIN4_REG			;
	GAIN5_REG_r1		<= GAIN5_REG			;
	GAIN6_REG_r1		<= GAIN6_REG			;
	GAIN7_REG_r1		<= GAIN7_REG			;
	WE_REG_r1			<= WE_REG				;
	PINC0_REG_r2		<= PINC0_REG_r1			;
	PINC1_REG_r2		<= PINC1_REG_r1			;
	PINC2_REG_r2		<= PINC2_REG_r1			;
	PINC3_REG_r2		<= PINC3_REG_r1			;
	PINC4_REG_r2		<= PINC4_REG_r1			;
	PINC5_REG_r2		<= PINC5_REG_r1			;
	PINC6_REG_r2		<= PINC6_REG_r1			;
	PINC7_REG_r2		<= PINC7_REG_r1			;
	POFF0_REG_r2		<= POFF0_REG_r1			;
	POFF1_REG_r2		<= POFF1_REG_r1			;
	POFF2_REG_r2		<= POFF2_REG_r1			;
	POFF3_REG_r2		<= POFF3_REG_r1			;
	POFF4_REG_r2		<= POFF4_REG_r1			;
	POFF5_REG_r2		<= POFF5_REG_r1			;
	POFF6_REG_r2		<= POFF6_REG_r1			;
	POFF7_REG_r2		<= POFF7_REG_r1			;
	GAIN0_REG_r2		<= GAIN0_REG_r1			;
	GAIN1_REG_r2		<= GAIN1_REG_r1			;
	GAIN2_REG_r2		<= GAIN2_REG_r1			;
	GAIN3_REG_r2		<= GAIN3_REG_r1			;
	GAIN4_REG_r2		<= GAIN4_REG_r1			;
	GAIN5_REG_r2		<= GAIN5_REG_r1			;
	GAIN6_REG_r2		<= GAIN6_REG_r1			;
	GAIN7_REG_r2		<= GAIN7_REG_r1			;
	WE_REG_r2			<= WE_REG_r1			;
end

assign s_axis_tready_o	= s_axis_tready_o_r2	;
assign m_axis_tvalid_o	= m_axis_tvalid_o_r2	;
assign m_axis_tdata_o	= m_axis_tdata_o_r2		;

endmodule

