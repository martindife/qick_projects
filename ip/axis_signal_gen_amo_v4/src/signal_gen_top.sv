module signal_gen_top
	#(
		// Number of bits for Time counter.
		parameter BT 	= 8	,

		// Memory length (bits).
		parameter NMEM	= 8	,

		// Number of DDSs (do not edit).
		parameter NDDS 	= 32
	)
	( 	
		// Reset and clock.
		input	wire			aresetn			,
		input	wire			aclk			,

		// s0_axis: parameter memory.
		input	wire			s0_axis_tvalid	,
		output	wire			s0_axis_tready	,
		input	wire	[31:0]	s0_axis_tdata	,
		input	wire			s0_axis_tlast	,

		// s1_axis: waveform push.
		input	wire			s1_axis_tvalid	,
		output	wire			s1_axis_tready	,
		input	wire	[79:0]	s1_axis_tdata	,

		// m0_axis for data output.
		output	wire			m0_axis_tvalid	,
		output	wire	[15:0]	m0_axis_tdata	,

		// m1_axis for auxiliary data output.
		output	wire			m1_axis_tvalid	,
		output	wire	[15:0]	m1_axis_tdata	,

		// Registers.
		input	wire			MEMW_START_REG
	);

/********************/
/* Internal signals */
/********************/

// Memory Writer signals.
wire	[15:0]		mem_addr	;
wire	[255:0]		mem_din		;
wire	[31:0]		mem_we		;

// Fifo signals.
wire				fifo_wr_en	;
wire	[79:0]		fifo_din	;
wire				fifo_rd_en	;
wire	[79:0]		fifo_dout	;
wire				fifo_full	;
wire				fifo_empty	;

// Control block signals.
wire				phase_sync	;
wire	[31:0]		addr_o		;
wire	[7:0]		ctrl_o		;
wire	[7:0]		qsel_o		;
wire				tout_valid	;
wire	[BT-1:0]	tout		;

/**********************/
/* Begin Architecture */
/**********************/

// Memory Writer.
mem_writer mem_writer_i
	(
		// Reset and clock.
		.rstn			(aresetn		),
		.clk			(aclk			),

		// AXIS for data input.
		.s_axis_tvalid	(s0_axis_tvalid	),
		.s_axis_tready	(s0_axis_tready	),
		.s_axis_tdata	(s0_axis_tdata	),
		.s_axis_tlast	(s0_axis_tlast	),
	
		// Memory interface.
		.mem_addr		(mem_addr		),
		.mem_din		(mem_din		),
		.mem_we			(mem_we			),
		
		// Registers.
		.START_REG		(MEMW_START_REG	)
	);

// Fifo.
fifo
    #(
        // Data width.
        .B	(80),
        
        // Fifo depth.
        .N	(16)
    )
    fifo_i
	( 
        .rstn	(aresetn	),
        .clk 	(aclk		),

        // Write I/F.
        .wr_en 	(fifo_wr_en	),
        .din    (fifo_din	),
        
        // Read I/F.
        .rd_en 	(fifo_rd_en	),
        .dout  	(fifo_dout	),
        
        // Flags.
        .full   (fifo_full	),
        .empty  (fifo_empty	)
    );

assign fifo_wr_en	= s1_axis_tvalid;
assign fifo_din		= s1_axis_tdata;

// Control block.
ctrl_top
	#(
		// Number of bits for Time counter.
		.BT(BT)
	)
	ctrl_top_i
	(
		// Reset and clock.
		.rstn		(aresetn	),
		.clk		(aclk		),

		// Fifo interface.
		.fifo_rd_en	(fifo_rd_en	),
		.fifo_empty	(fifo_empty	),
		.fifo_dout	(fifo_dout	),

		// Phase sync.
		.phase_sync	(phase_sync	),

		// Fifo fields.
		.addr_o		(addr_o		),
		.ctrl_o		(ctrl_o		),
		.qsel_o		(qsel_o		),

		// Output time.
		.tout_valid	(tout_valid	),
		.tout		(tout		)
	);

// Modulated DDS Sum block.
mod_dds_sum
	#(
		// Number of bits of t.
		.BT		(BT		),

		// Memory length (bits).
		.NMEM	(NMEM	),

		// Number of DDSs (do not edit).
		.NDDS	(NDDS	)
	)
	mod_dds_sum_i
	(
		// Reset and clock.
		.aresetn		(aresetn		),
		.aclk			(aclk			),

		// Memory write.
		.mem_we			(mem_we			),
		.mem_waddr		(mem_addr		),
		.mem_din		(mem_din		),

		// Memory read.
		.mem_raddr		(addr_o			),

		// Quantization.
		.qsel			(qsel_o			),

		// Control flags.
		.ctrl			(ctrl_o			),

		// Phase sync.
		.sync			(phase_sync		),

		// Time base.
		.t_in_valid		(tout_valid		),
		.t_in			(tout			),

		// m0_axis for data output.
		.m0_axis_tvalid	(m0_axis_tvalid	),
		.m0_axis_tdata	(m0_axis_tdata	),

		// m1_axis for auxiliary data output.
		.m1_axis_tvalid	(m1_axis_tvalid	),
		.m1_axis_tdata	(m1_axis_tdata	)
	);

// Assign outputs.
assign s1_axis_tready = ~fifo_full;

endmodule

