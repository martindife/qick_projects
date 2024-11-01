module axis_switch_v1
	#(
		parameter B = 16,
		parameter N = 16
	)
	( 
		// AXI Slave I/F for configuration.
		input	wire			s_axi_aclk		,
		input	wire			s_axi_aresetn	,
		
		input	wire [5:0]		s_axi_awaddr	,
		input	wire [2:0]		s_axi_awprot	,
		input	wire			s_axi_awvalid	,
		output	wire			s_axi_awready	,
		
		input	wire [31:0]		s_axi_wdata		,
		input	wire [3:0]		s_axi_wstrb		,
		input	wire			s_axi_wvalid	,
		output	wire			s_axi_wready	,
		
		output	wire [1:0]		s_axi_bresp		,
		output	wire			s_axi_bvalid	,
		input	wire			s_axi_bready	,
		
		input	wire [5:0]		s_axi_araddr	,
		input	wire [2:0]		s_axi_arprot	,
		input	wire			s_axi_arvalid	,
		output	wire			s_axi_arready	,
		
		output	wire [31:0]		s_axi_rdata		,
		output	wire [1:0]		s_axi_rresp		,
		output	wire			s_axi_rvalid	,
		input	wire			s_axi_rready	,

		// Reset and Clock for s/m axis.
		input 	wire 			aresetn			,
		input 	wire 			aclk			,

		// s_axis_* for input.
		input	wire			s_axis_tvalid	,
		output	wire			s_axis_tready	,
		input	wire [B-1:0]	s_axis_tdata	,

		// mx_axis_* for output.
		output	wire			m00_axis_tvalid	,
		output	wire [B-1:0]	m00_axis_tdata	,
		output	wire			m01_axis_tvalid	,
		output	wire [B-1:0]	m01_axis_tdata	,
		output	wire			m02_axis_tvalid	,
		output	wire [B-1:0]	m02_axis_tdata	,
		output	wire			m03_axis_tvalid	,
		output	wire [B-1:0]	m03_axis_tdata	,
		output	wire			m04_axis_tvalid	,
		output	wire [B-1:0]	m04_axis_tdata	,
		output	wire			m05_axis_tvalid	,
		output	wire [B-1:0]	m05_axis_tdata	,
		output	wire			m06_axis_tvalid	,
		output	wire [B-1:0]	m06_axis_tdata	,
		output	wire			m07_axis_tvalid	,
		output	wire [B-1:0]	m07_axis_tdata	,
		output	wire			m08_axis_tvalid	,
		output	wire [B-1:0]	m08_axis_tdata	,
		output	wire			m09_axis_tvalid	,
		output	wire [B-1:0]	m09_axis_tdata	,
		output	wire			m10_axis_tvalid	,
		output	wire [B-1:0]	m10_axis_tdata	,
		output	wire			m11_axis_tvalid	,
		output	wire [B-1:0]	m11_axis_tdata	,
		output	wire			m12_axis_tvalid	,
		output	wire [B-1:0]	m12_axis_tdata	,
		output	wire			m13_axis_tvalid	,
		output	wire [B-1:0]	m13_axis_tdata	,
		output	wire			m14_axis_tvalid	,
		output	wire [B-1:0]	m14_axis_tdata	,
		output	wire			m15_axis_tvalid	,
		output	wire [B-1:0]	m15_axis_tdata
	);

/********************/
/* Internal signals */
/********************/
// Pipeline regs.
reg			valid_r1	;
reg			valid_r2	;
reg			valid_r3	;
reg			valid_r4	;
reg	[B-1:0]	din_r1		;
reg	[B-1:0]	din_r2		;
reg	[B-1:0]	dout_r1	[N]	;
reg	[B-1:0]	dout_r2	[N]	;

// Output data vector.
wire	[B-1:0]	dout_v	[N]	;

// Registers.
wire [7:0]	CHANNEL_REG;

/**********************/
/* Begin Architecture */
/**********************/
// AXI Slave.
axi_slv axi_slv_i
	(
		.aclk			(s_axi_aclk	 	),
		.aresetn		(s_axi_aresetn	),

		// Write Address Channel.
		.awaddr			(s_axi_awaddr 	),
		.awprot			(s_axi_awprot 	),
		.awvalid		(s_axi_awvalid	),
		.awready		(s_axi_awready	),

		// Write Data Channel.
		.wdata			(s_axi_wdata	),
		.wstrb			(s_axi_wstrb	),
		.wvalid			(s_axi_wvalid   ),
		.wready			(s_axi_wready	),

		// Write Response Channel.
		.bresp			(s_axi_bresp	),
		.bvalid			(s_axi_bvalid	),
		.bready			(s_axi_bready	),

		// Read Address Channel.
		.araddr			(s_axi_araddr 	),
		.arprot			(s_axi_arprot 	),
		.arvalid		(s_axi_arvalid	),
		.arready		(s_axi_arready	),

		// Read Data Channel.
		.rdata			(s_axi_rdata	),
		.rresp			(s_axi_rresp	),
		.rvalid			(s_axi_rvalid	),
		.rready			(s_axi_rready	),

		// Registers.
		.CHANNEL_REG	(CHANNEL_REG	)
	);

genvar i;
generate
	for (i=0; i<N; i=i+1) begin
		always @(posedge aclk) begin
			// Pipeline registers.
			dout_r1	[i]	<= dout_v 	[i];
			dout_r2	[i]	<= dout_r1	[i];
		end

		// Assign output based on register.
		assign dout_v[i] = (CHANNEL_REG == i)? din_r2 : 0;
		
	end
endgenerate

always @(posedge aclk) begin
	// Pipeline registers.
	valid_r1 	<= s_axis_tvalid;
	valid_r2 	<= valid_r1;
	valid_r3 	<= valid_r2;
	valid_r4 	<= valid_r3;
	din_r1		<= s_axis_tdata;
	din_r2 		<= din_r1;
end

// Assign outputs.
assign s_axis_tready = 1'b1;
assign	m00_axis_tvalid	= valid_r4;
assign	m01_axis_tvalid	= valid_r4;
assign	m02_axis_tvalid	= valid_r4;
assign	m03_axis_tvalid	= valid_r4;
assign	m04_axis_tvalid	= valid_r4;
assign	m05_axis_tvalid	= valid_r4;
assign	m06_axis_tvalid	= valid_r4;
assign	m07_axis_tvalid	= valid_r4;
assign	m08_axis_tvalid	= valid_r4;
assign	m09_axis_tvalid	= valid_r4;
assign	m10_axis_tvalid	= valid_r4;
assign	m11_axis_tvalid	= valid_r4;
assign	m12_axis_tvalid	= valid_r4;
assign	m13_axis_tvalid	= valid_r4;
assign	m14_axis_tvalid	= valid_r4;
assign	m15_axis_tvalid	= valid_r4;
assign	m00_axis_tdata	= dout_r2[0];
assign	m01_axis_tdata	= dout_r2[1];
assign	m02_axis_tdata	= dout_r2[2];
assign	m03_axis_tdata	= dout_r2[3];
assign	m04_axis_tdata	= dout_r2[4];
assign	m05_axis_tdata	= dout_r2[5];
assign	m06_axis_tdata	= dout_r2[6];
assign	m07_axis_tdata	= dout_r2[7];
assign	m08_axis_tdata	= dout_r2[8];
assign	m09_axis_tdata	= dout_r2[9];
assign	m10_axis_tdata	= dout_r2[10];
assign	m11_axis_tdata	= dout_r2[11];
assign	m12_axis_tdata	= dout_r2[12];
assign	m13_axis_tdata	= dout_r2[13];
assign	m14_axis_tdata	= dout_r2[14];
assign	m15_axis_tdata	= dout_r2[15];

endmodule

