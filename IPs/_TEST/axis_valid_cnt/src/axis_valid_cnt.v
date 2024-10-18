///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : mdife
//  Date           : 4-2022
//  Versi�n        : 1
///////////////////////////////////////////////////////////////////////////////
//Description:  Axi Stream Accumulator 
//////////////////////////////////////////////////////////////////////////////

module axis_valid_cnt  #(
   parameter AXIS_IN_DW    = 32 
) (
   // AXI Stream Slave I/F.
   input wire                   clk_i     ,
   input wire                   rst_ni  ,
   input wire                   s_axis_tvalid   ,
   output wire [31:0]           cnt_r_o         ,
   output wire [31:0]           cnt_o           );

reg  s_axis_tvalid_r;
wire s_axis_tvalid_t01;

always @ (posedge clk_i or negedge rst_ni) begin
   if (!rst_ni)
      s_axis_tvalid_r <=  0;
   else 
      s_axis_tvalid_r <= s_axis_tvalid;
end
assign s_axis_tvalid_t01   =  ~s_axis_tvalid_r  &  s_axis_tvalid;          
assign s_axis_tvalid_t10   =   s_axis_tvalid_r  & ~s_axis_tvalid;          

reg  [31:0] cnt, cnt_r;
wire [31:0] cnt_p1;

// COUNTER 
assign cnt_p1 = cnt + 1'b1;
always @ (posedge clk_i or negedge rst_ni) begin
   if      (!rst_ni)     cnt <= 0;
   else if (s_axis_tvalid_t01)   cnt <= 1; 
   else if (s_axis_tvalid)       cnt <= cnt_p1;
end

// OUT REGISTER 
always @ (posedge clk_i or negedge rst_ni) begin
   if      (!rst_ni)     cnt_r <= 0;
   else if (s_axis_tvalid_t10)        cnt_r <= cnt_p1; 

end
assign s_axis_tready = 1'b1;
assign cnt_o = cnt ;
assign cnt_r_o = cnt_r ;

endmodule
