module axis_qbuff_v1
	#(
		// Delay line length.
		parameter DLY	= 2	,

		// Bits.
		parameter B		= 8	,

		// Number of lanes.
		parameter L		= 4	,

		// Memory Size.
		parameter N		= 4
	)
	( 	
		// Start.
		input	wire			start_in		,
		output	wire			start_out		,

		// AXI Slave I/F for configuration.
		input wire  			s_axi_aclk		,
		input wire  			s_axi_aresetn	,

		input wire [7:0]		s_axi_awaddr	,
		input wire [2:0]		s_axi_awprot	,
		input wire  			s_axi_awvalid	,
		output wire  			s_axi_awready	,

		input wire [31:0] 		s_axi_wdata		,
		input wire [3:0]		s_axi_wstrb		,
		input wire  			s_axi_wvalid	,
		output wire  			s_axi_wready	,

		output wire [1:0]		s_axi_bresp		,
		output wire  			s_axi_bvalid	,
		input wire  			s_axi_bready	,

		input wire [7:0] 		s_axi_araddr	,
		input wire [2:0] 		s_axi_arprot	,
		input wire  			s_axi_arvalid	,
		output wire  			s_axi_arready	,

		output wire [31:0] 		s_axi_rdata		,
		output wire [1:0]		s_axi_rresp		,
		output wire  			s_axi_rvalid	,
		input wire  			s_axi_rready	,

		// s_axis_* for input.
		input 	wire 			s_axis_aresetn	,
		input 	wire 			s_axis_aclk		,
		input	wire			s_axis_tvalid	,
		output	wire			s_axis_tready	,
		input	wire [L*B-1:0]	s_axis_tdata	,

		// m_axis_* for output.
		input 	wire 			m_axis_aresetn	,
		input 	wire 			m_axis_aclk		,
		output	wire			m_axis_tvalid	,
		input	wire			m_axis_tready	,
		output	wire [B-1:0]	m_axis_tdata	,
		output	wire			m_axis_tlast
	);

/********************/
/* Internal signals */
/********************/
// Registers.
wire			START_REG			;
wire			START_SRC_REG		;
wire			COMP_MODE_REG		;
wire [B-1:0]	COMP_THR_REG		;
wire [N-1:0]	WMEM_NSAMP_REG		;
wire			RMEM_START_REG		;

// Memory interface (write).
wire			mem_wea				;
wire [N-1:0]	mem_addra			;
wire [L*B-1:0]	mem_dia				;
wire [B-1:0]	mem_dia_v	[L]		;

// Memory interface (read).
wire [N-1:0]	mem_addrb			;
wire [L*B-1:0]	mem_dob				;
wire [B-1:0]	mem_dob_v	[L]		;

// Re-sync registers.
wire			START_REG_resync	;
wire			START_SRC_REG_resync;

/**********************/
/* Begin Architecture */
/**********************/
// START_REG_resync.
synchronizer_n START_REG_resync_i
	(
		.rstn	    (s_axis_aresetn			),
		.clk 		(s_axis_aclk			),
		.data_in	(START_REG				),
		.data_out	(START_REG_resync		)
	);

// START_SRC_REG_resync.
synchronizer_n START_SRC_REG_resync_i
	(
		.rstn	    (s_axis_aresetn			),
		.clk 		(s_axis_aclk			),
		.data_in	(START_SRC_REG			),
		.data_out	(START_SRC_REG_resync	)
	);

// Muxed start (0: internal start, 1: external start).
// start_in is on s_axis_aclk domain!!! Not re-synced to allow multiple blocks to start synced.
assign start_mux = (START_SRC_REG_resync == 1'b1)? start_in : START_REG_resync;

// AXI Slave.
axi_slv axi_slv_i
	(
		.s_axi_aclk		(s_axi_aclk	  	),
		.s_axi_aresetn	(s_axi_aresetn	),

		// Write Address Channel.
		.s_axi_awaddr	(s_axi_awaddr	),
		.s_axi_awprot	(s_axi_awprot	),
		.s_axi_awvalid	(s_axi_awvalid	),
		.s_axi_awready	(s_axi_awready	),

		// Write Data Channel.
		.s_axi_wdata	(s_axi_wdata	),
		.s_axi_wstrb	(s_axi_wstrb	),
		.s_axi_wvalid	(s_axi_wvalid	),
		.s_axi_wready	(s_axi_wready	),

		// Write Response Channel.
		.s_axi_bresp	(s_axi_bresp	),
		.s_axi_bvalid	(s_axi_bvalid	),
		.s_axi_bready	(s_axi_bready	),

		// Read Address Channel.
		.s_axi_araddr	(s_axi_araddr	),
		.s_axi_arprot	(s_axi_arprot	),
		.s_axi_arvalid	(s_axi_arvalid	),
		.s_axi_arready	(s_axi_arready	),

		// Read Data Channel.
		.s_axi_rdata	(s_axi_rdata	),
		.s_axi_rresp	(s_axi_rresp	),
		.s_axi_rvalid	(s_axi_rvalid	),
		.s_axi_rready	(s_axi_rready	),

		// Registers.
		.START_REG		(START_REG		),
		.START_SRC_REG	(START_SRC_REG	),
		.COMP_MODE_REG	(COMP_MODE_REG	),
		.COMP_THR_REG	(COMP_THR_REG	),
		.WMEM_NSAMP_REG	(WMEM_NSAMP_REG	),
		.RMEM_START_REG	(RMEM_START_REG	)
	);

// QBuff.
qbuff
	#(
		// Delay line length.
		.DLY(DLY),

		// Bits.
		.B	(B	),

		// Number of lanes.
		.L	(L	),

		// Memory Size.
		.N	(N	)
	)
	qbuff_i
	(
		// Reset and clock.
		.aresetn		(s_axis_aresetn	),
		.aclk			(s_axis_aclk	),

		// Input data.
		.din			(s_axis_tdata	),

		// Start.
		.start			(start_mux		),

		// Memory interface.
		.mem_we			(mem_wea		),
		.mem_addr		(mem_addra		),
		.mem_di			(mem_dia		),

		// Registers.
		.COMP_MODE_REG	(COMP_MODE_REG	),
		.COMP_THR_REG	(COMP_THR_REG	),
		.WMEM_NSAMP_REG	(WMEM_NSAMP_REG	)
	);

// Data reader.
data_reader
	#(
		// Number of memories.
		.NM	(L	),

		// Address map of each memory.
		.N	(N	),

		// Data width.
		.B	(B	)
	)
	data_reader_i
	(
		// Reset and clock.
		.aresetn		(m_axis_aresetn	),
		.aclk			(m_axis_aclk	),

        // Memory I/F.
        .mem_addr		(mem_addrb		),
        .mem_dout		(mem_dob		),
        
        // m_axis_* for data out.
		.m_axis_tvalid	(m_axis_tvalid	),
		.m_axis_tready	(m_axis_tready	),
		.m_axis_tdata	(m_axis_tdata	),
		.m_axis_tlast	(m_axis_tlast	),
		
        // Registers.
		.START_REG		(RMEM_START_REG	)
	);

genvar i;
generate
	for (i=0; i<L; i++) begin : GEN_bram
		// BRAM instance.
		bram_dp
		    #(
		        // Memory address size.
		        .N(N),
		        // Data width.
		        .B(B)
		    )
			bram_dp_i
		    ( 
				.clka  	(s_axis_aclk	),
		        .clkb   (m_axis_aclk	),
		        .ena    (1'b1			),
		        .enb    (1'b1			),
		        .wea    (mem_wea		),
		        .web    (1'b0			),
		        .addra  (mem_addra		),
		        .addrb  (mem_addrb		),
		        .dia    (mem_dia_v[i]	),
		        .dib    (0				),
		        .doa    (				),
		        .dob    (mem_dob_v[i]	)
		    );

		// Memory Input Data.
		assign mem_dia_v 	[i]			= mem_dia	[i*B +: B];

		// Memory Output Data.
		assign mem_dob		[i*B +: B] 	= mem_dob_v	[i];

	end
endgenerate

// Assign outputs.
assign start_out		= START_REG_resync;
assign s_axis_tready 	= 1'b1;

endmodule

