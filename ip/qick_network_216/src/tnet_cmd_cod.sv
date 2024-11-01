`include "_tnet_defines.svh"

module tnet_cmd_cod (
   input  wire             c_clk_i             ,
   input  wire             c_rst_ni            ,
   input  wire  [ 9:0]     param_NN            ,
   input  wire  [ 9:0]     param_ID            ,
   input  wire             c_cmd_i             ,
   input  wire  [4:0]      c_op_i              ,
   input  wire  [31:0]     c_dt_i [3]          ,
   input  wire  [4:0]      p_op_i              ,
   input  wire  [31:0]     p_dt_i [3]          ,
   input  wire             net_cmd_i           ,
   input  wire  [63:0]     net_cmd_h_i         ,
   input  wire  [63:0]     net_cmd_dt_i         ,
   output  wire [63:0]     header_o            ,
   output  wire [31:0]     data_o  [2]            ,
   output  wire            loc_cmd_req_o          ,
   input   wire            loc_cmd_ack_i          ,
   output  wire            net_cmd_req_o          ,
   input   wire            net_cmd_ack_i  ,
   output  wire  [8:0]     cmd_cnt_do                
   );

(* ASYNC_REG = "TRUE" *) reg [4:0] p_op_cdc;
reg [4:0] p_op_r;
always_ff @(posedge c_clk_i)
   if (!c_rst_ni) begin
      p_op_cdc  <= 5'd0;
      p_op_r    <= 5'd0;
   end else begin
      p_op_cdc  <= p_op_i; 
      p_op_r    <= p_op_cdc;
   end

// LOCAL COMMAND OPERATON CODER
reg        p_cmd_req, c_cmd_req;
reg [4:0]  loc_cmd_op;
reg [31:0] loc_cmd_dt[2];
reg [23:0] loc_cmd_hdt;

wire p_cmd_in, p_cmd_in_t01;
reg p_cmd_in_r;

assign p_cmd_in     =  |p_op_r ; 
assign p_cmd_in_t01 =  !p_cmd_in_r & p_cmd_in;

reg [2:0] p_cmd_cnt, c_cmd_cnt;
always_ff @(posedge c_clk_i) 
   if (!c_rst_ni) begin
      p_cmd_req    <= 1'b0;
      p_cmd_cnt    <= 3'd0;
      c_cmd_req    <= 1'b0;
      c_cmd_cnt    <= 3'd0;
      loc_cmd_op   <= 5'd0;
      loc_cmd_dt   <= '{default:'0};
      loc_cmd_hdt  <= 32'd0;
   end else begin 
      p_cmd_in_r <= p_cmd_in;
      if (p_cmd_in_t01) begin
         p_cmd_req    <= 1'b1;
         p_cmd_cnt    <= p_cmd_cnt + 1'b1;
         loc_cmd_op   <= p_op_r[4:0] ;
         loc_cmd_dt   <= {p_dt_i[0], p_dt_i[1] }  ;
         loc_cmd_hdt  <= p_dt_i[2] ;
      end else if (c_cmd_i) begin
         c_cmd_req   <= 1'b1;
         c_cmd_cnt   <= c_cmd_cnt + 1'b1;
         loc_cmd_op  <= c_op_i  ;
         loc_cmd_dt  <= {c_dt_i[0], c_dt_i[1]} ;
         loc_cmd_hdt <= c_dt_i[2]  ;
      end else
      if ( loc_cmd_ack_i ) begin 
         p_cmd_req  <= 1'b0;
         c_cmd_req  <= 1'b0;
      end
   end
   
reg [63:0] loc_cmd_header;

always_comb begin
//////////////////////////////////////////////////////////  Type_CMD___SWA___DEST_______SOURCE_____STEP_______ID0________ID1
   if      (loc_cmd_op == _get_net    ) loc_cmd_header =  64'b00_00001_100_1111111111_0000000001_0000000000_00000000000000_0000000001;
   else if (loc_cmd_op == _set_net    ) loc_cmd_header = {40'b00_00010_000_1111111111_0000000001_0000000000, 14'd1460, param_NN  };
   else if (loc_cmd_op == _sync1_net  ) loc_cmd_header = {40'b00_00011_100_1111111111_0000000001_0000000000, loc_cmd_hdt[23:10], 10'd0} ;
   else if (loc_cmd_op == _sync2_net  ) loc_cmd_header =  64'b00_00100_100_1111111111_0000000001_0000000000_00000000000000_0000000000;
   else if (loc_cmd_op == _sync3_net  ) loc_cmd_header =  64'b00_00101_100_1111111111_0000000001_0000000000_00000000000000_0000000000;
   else if (loc_cmd_op == _sync4_net  ) loc_cmd_header =  64'b00_00110_100_1111111111_0000000001_0000000000_00000000000000_0000000000;
   else if (loc_cmd_op == _get_off    ) loc_cmd_header = {14'b00_00111_000, loc_cmd_hdt[9:0] , param_ID, 34'd0};
   else if (loc_cmd_op == _updt_off   ) loc_cmd_header = {14'b00_01000_000, loc_cmd_hdt[9:0] , param_ID, 34'd0};
   else if (loc_cmd_op == _set_dt     ) loc_cmd_header = {14'b00_01001_100, loc_cmd_hdt[9:0] , param_ID, 34'd0};
   else if (loc_cmd_op == _get_dt     ) loc_cmd_header = {14'b00_01010_100, loc_cmd_hdt[9:0] , param_ID, 34'd0};
   else if (loc_cmd_op == _rst_time   ) loc_cmd_header = {24'b00_10000_100_1111111111, param_ID, 34'd0};
   else if (loc_cmd_op == _start_core ) loc_cmd_header = {24'b00_10001_100_1111111111, param_ID, 34'd0};
   else if (loc_cmd_op == _stop_core  ) loc_cmd_header = {24'b00_10010_100_1111111111, param_ID, 34'd0};
   else if (loc_cmd_op == _set_cond   ) loc_cmd_header = {24'b00_11000_100_1111111111, param_ID, 34'd0};
   else if (loc_cmd_op == _get_cond   ) loc_cmd_header = {24'b00_11001_100_1111111111, param_ID, 34'd0};
   else                                 loc_cmd_header =  64'b00_00000_000_0000000000_0000000000_0000000000_00000000_0000000000000000;
   end




   
reg [63:0] cmd_header_r;
reg [31:0] cmd_dt_r [2];


reg loc_cmd_req, net_cmd_req;
reg [2:0] net_cmd_cnt;
always_ff @(posedge c_clk_i) 
   if (!c_rst_ni) begin
      loc_cmd_req   <= 1'b0;
      net_cmd_req   <= 1'b0;
      net_cmd_cnt   <= 3'd0;
      cmd_header_r <= 63'd0;
      cmd_dt_r     <= '{default:'0};
   end else begin 
      if (c_cmd_req | p_cmd_req) begin
         loc_cmd_req    <= 1'b1;
         cmd_header_r   <= loc_cmd_header;
         cmd_dt_r       <= loc_cmd_dt;
      end else if (net_cmd_i) begin
         net_cmd_req    <= 1'b1;
         net_cmd_cnt    <= net_cmd_cnt + 1'b1;
         
         cmd_header_r   <= net_cmd_h_i;
         cmd_dt_r[0]    <= net_cmd_dt_i[31: 0] ;
         cmd_dt_r[1]    <= net_cmd_dt_i[63:32] ;
      end

      if (loc_cmd_ack_i & ~(p_cmd_req | c_cmd_req))  loc_cmd_req <= 1'b0;
      if (net_cmd_ack_i & ~net_cmd_i)        net_cmd_req <= 1'b0;
   end

// DEBUG
assign cmd_cnt_do ={ net_cmd_cnt, c_cmd_cnt, p_cmd_cnt };  

// OUTPUTS
assign loc_cmd_req_o = loc_cmd_req ;
assign net_cmd_req_o = net_cmd_req ;
assign header_o = cmd_header_r;
assign data_o   = cmd_dt_r;

endmodule

    