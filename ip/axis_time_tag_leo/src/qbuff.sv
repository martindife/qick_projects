module qbuff
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
		// Reset and clock.
		input 	wire 			aresetn			,
		input 	wire 			aclk			,

		// Input data.
		input	wire [L*B-1:0]	din				,

		// Start.
		input	wire			start			,

		// Memory interface.
		output	wire			mem_we			,
		output	wire [N-1:0]	mem_addr		,
		output	wire [L*B-1:0]	mem_di			,

		// Registers.
		input	wire			COMP_MODE_REG	,
		input	wire [B-1:0]	COMP_THR_REG	,
		input	wire [N-1:0]	WMEM_NSAMP_REG
	);

/*************/
/* Internals */
/*************/
// Cmp signals.
wire	[B-1:0]		cmp_din_v 	[L]	;
wire	[B-1:0]		cmp_dout_v	[L]	;
wire	[L*B-1:0]	cmp_dout		;
wire	[L-1:0]		flag_v			;

// Handshake with memory writer.
wire				write			;
wire				write_ack		;

// Counter for time-tag.
reg		[2*B-1:0]	cnt;
reg		[2*B-1:0]	cnt_la;
reg		[2*B-1:0]	cnt_r;

/****************/
/* Architecture */
/****************/
// Apply data latency to counter.
latency_reg
	#(
		// Latency.
		.N	(DLY+2	),

		// Data width.
		.B	(2*B	)
	)
	cnt_latency_reg_i
	(
		// Reset and clock.
		.rstn	(aresetn	),
		.clk	(aclk		),

		// Data input.
		.din	(cnt		),

		// Data output.
		.dout	(cnt_la		)
	);

genvar i;
generate
	for (i=0; i<L; i++) begin: GEN_cmp
		// Comp block instantiation.
		// Latency for din-dout: DLY + 2
		cmp
			#(
				// Delay line length.
				.DLY(DLY),
		
				// Bits.
				.B	(B	)
			)
			cmp_i
			(
				// Reset and clock.
				.aresetn	(aresetn		),
				.aclk		(aclk			),
		
				// Input data.
				.din		(cmp_din_v[i]	),
		
				// Delayed data.
				.dout		(cmp_dout_v[i]	),
		
				// Comparison flag.
				.flag		(flag_v[i]		),
		
				// Registers.
				.MODE_REG	(COMP_MODE_REG	),
				.THR_REG	(COMP_THR_REG	)
			);

			// Input data to vector.
			assign cmp_din_v[i]			= din[B*i +: B];

			// Output vector to data.
			assign cmp_dout [B*i +: B]	= cmp_dout_v[i];
	end
endgenerate

// Qualifier block.
qual
	#(
		// Number of inputs.
		.L(L)
	)
	qual_i
	(
		// Reset and clock.
		.aresetn	(aresetn	),
		.aclk		(aclk		),

		// Start.
		.start		(start		),

		// Input triggers.
		.din		(flag_v		),

		// Handshake with memory writer.
		.write		(write		),
		.write_ack	(write_ack	)
	);

write_mem
	#(
		// Memory Size.
		.N(N),

		// Bits.
		.B(B),

		// Number of lanes.
		.L(L)
	)
	write_mem_i
	(
		// Reset and clock.
		.aresetn	(aresetn		),
		.aclk		(aclk			),

		// Start.
		.start		(start			),

		// Input data.
		.din		(cmp_dout		),

		// Time-tag.
		.ttag		(cnt_r			),

		// Handshake.
		.write		(write			),
		.write_ack	(write_ack		),

		// Memory interface.
		.mem_we		(mem_we			),
		.mem_addr	(mem_addr		),
		.mem_di		(mem_di			),

		// Registers.
		.NSAMP_REG	(WMEM_NSAMP_REG	)
	);

// Registers.
always @(posedge aclk) begin
	if (!aresetn) begin
		// Counter for time-tag.
		cnt 	<= 0;
		cnt_r	<= 0;
	end
	else begin
		// Counter for time-tag.
		if (start == 1'b1)
			cnt <= cnt + 1;
		else
			cnt <= 0;

		if (write == 1'b0)
			cnt_r <= cnt_la;
	end
end

endmodule

