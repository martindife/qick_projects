module debouncer
	#(
		// Number of stages.
		parameter N = 10
	)
	(
		// reset and clock.
		input	wire	aresetn	,
		input	wire	aclk	,

		// Input/output.
		input	wire	din		,
		output	wire	dout
	);

/********************/
/* Internal signals */
/********************/
// Re-synced input.
wire		din_resync	;

// Delay line.
reg	[N-1:0]	din_r		;

// And.
wire		din_int		;

/****************/
/* Architecture */
/****************/

// din_resync.
synchronizer_n din_resync_i
	(
		.rstn	    (aresetn	),
		.clk 		(aclk		),
		.data_in	(din		),
		.data_out	(din_resync	)
	);

genvar i;
generate
	for (i=0; i<N; i=i+1) begin
		// Registers.
		always @(posedge aclk) begin
			if (aresetn == 1'b0) begin
				// Delay line.
				din_r[i] <= 0;
			end
			else begin
				// Delay line.
				if (i == 0) 
					din_r[i] <= din_resync;
				else
					din_r[i] <= din_r[i-1];
			end
		end
	end
endgenerate

// And.
assign din_int =& din_r;

// Assign output.
assign dout = din_int;

endmodule

