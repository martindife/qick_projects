module tb();


// Number of bits for Time counter.
parameter BT = 8;

// Reset and clock.
reg				rstn		;
reg				clk			;

// Fifo interface.
wire			fifo_rd_en	;
wire			fifo_empty	;
wire	[71:0]	fifo_dout	;

// Phase sync.
wire			phase_sync	;

// Fifo fields.
wire	[31:0]	addr_o		;
wire	[7:0]	ctrl_o		;

// Output time.
wire			tout_valid	;
wire 	[BT-1:0]tout		;


// Fifo control.
reg				fifo_wr_en	;
wire	[71:0]	fifo_din	;

// Fifo fields.
reg		[31:0]	addr_r		;
reg		[31:0]	wait_r		;
reg		[7:0]	ctrl_r		;

assign fifo_din = {ctrl_r, wait_r, addr_r};

fifo
    #(
        // Data width.
        .B(72),
        
        // Fifo depth.
        .N(4)
    )
    fifo_i
    ( 
        .rstn	(rstn		),
        .clk 	(clk		),

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

ctrl_top
	#(
		// Number of bits for Time counter.
		.BT(BT)
	)
	DUT
	(
		// Reset and clock.
		.rstn		,
		.clk		,

		// Fifo interface.
		.fifo_rd_en	,
		.fifo_empty	,
		.fifo_dout	,

		// Phase sync.
		.phase_sync	,

		// Fifo fields.
		.addr_o		,
		.ctrl_o		,

		// Output time.
		.tout_valid	,
		.tout
	);

// Main TB.
initial begin
	rstn		<= 0;
	fifo_wr_en	<= 0;
	addr_r		<= 0;
	wait_r		<= 0;
	ctrl_r		<= 0;
	#300;
	rstn		<= 1;

	#500;

	// Push something into the fifo.
	@(posedge clk);
	fifo_wr_en	<= 1;
	addr_r 		<= 100;
	wait_r		<= 0;

	@(posedge clk);
	fifo_wr_en	<= 1;
	addr_r 		<= 76;
	wait_r		<= 7;

	@(posedge clk);
	fifo_wr_en	<= 0;
end

always begin
	clk <= 0;
	#5;
	clk <= 1;
	#5;
end  

endmodule

