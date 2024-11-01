`include "_tnet_defines.svh"

module tnet_qick_cmd (
   input  wire            c_clk_i         ,
   input  wire            c_rst_ni        ,
   input  wire            t_clk_i         ,
   input  wire            t_rst_ni        ,
   input  wire            net_sync_i      ,
   input  wire [31:0]     RTD_i           ,
   input  wire [47:0]     t_time_abs      ,
   input  TYPE_CTRL_REQ   ctrl_cmd_req_i  ,
   input  TYPE_CTRL_OP    ctrl_cmd_op_i   ,
   input  reg  [47:0]     ctrl_cmd_dt_i   ,
   output reg             ctrl_cmd_ok_o  ,
   output reg             ctrl_cmd_ack_o  ,

   output reg             core_start_o    ,
   output reg             core_stop_o     ,
   output reg             time_reset_o    ,
   output reg             time_init_o     ,
   output reg             time_updt_o     ,        
   output wire [31:0]     time_off_dt_o   ,
   output wire [2:0]      ctrl_st_do
      
   );


// Core Start and Core Stop are c_clk Sync
// Time commandas are t_clk Sync

reg net_sync_r, net_sync_r2 ;
(* ASYNC_REG = "TRUE" *) reg net_sync_cdc ;
always_ff @(posedge t_clk_i, negedge t_rst_ni) begin
   if (!t_rst_ni) begin
      net_sync_cdc   <= 0;
      net_sync_r     <= 0;
      net_sync_r2    <= 0;
   end else begin
      net_sync_cdc   <= net_sync_i;
      net_sync_r     <= net_sync_cdc;
      net_sync_r2    <= net_sync_r;
   end
end

wire net_sync_t01 ;
assign net_sync_t01  = !net_sync_r2 & net_sync_r ;


///// STATE
///////////////////////////////////////////////////////////////////////////////
enum {
   T_IDLE         = 1,
   T_CHECK_TIME1  = 2,
   T_CHECK_TIME2  = 3,
   T_WAIT_TIME    = 4,
   T_WAIT_SYNC    = 5,
   T_EXECUTE      = 6,
   T_ERROR        = 7 
} time_ctrl_st_nxt, time_ctrl_st;

always_ff @(posedge t_clk_i)
   if      ( !t_rst_ni )  time_ctrl_st  <= T_IDLE;
   else                   time_ctrl_st  <= time_ctrl_st_nxt;


wire ctrl_req;
assign ctrl_req     = ctrl_cmd_req_i != X_NOP ;


reg check_time_en;
wire ctrl_cmd_time_ok, ctrl_cmd_time_exec ;

assign ctrl_cmd_time_ok   = !ctrl_time[47] ;
assign ctrl_cmd_time_exec = ctrl_left_time[47] ;


reg    ctrl_cmd_exec ;
// State Change
always_comb begin
   time_ctrl_st_nxt  = time_ctrl_st; // Default Current
   check_time_en  = 1'b0 ;
   ctrl_cmd_exec  = 1'b0 ;
   ctrl_cmd_ack_o = 1'b1 ;
   ctrl_cmd_ok_o   = 1'b0 ;
      case (time_ctrl_st)
         T_IDLE        : begin
            ctrl_cmd_ack_o = 1'b0 ;
            if      ( ctrl_cmd_req_i== X_NOW  ) time_ctrl_st_nxt = T_EXECUTE;
            else if ( ctrl_cmd_req_i== X_TIME ) time_ctrl_st_nxt = T_CHECK_TIME1;
            else if ( ctrl_cmd_req_i== X_EXT  ) time_ctrl_st_nxt = T_WAIT_SYNC;
         end
         T_CHECK_TIME1  : begin
            check_time_en = 1'b1 ;
            time_ctrl_st_nxt = T_CHECK_TIME2;
         end
         T_CHECK_TIME2 : if      ( ctrl_cmd_time_ok  ) time_ctrl_st_nxt = T_WAIT_TIME;
                         else                           time_ctrl_st_nxt = T_ERROR;
         T_WAIT_TIME   : begin
            ctrl_cmd_ok_o = 1'b1;
            if  ( ctrl_cmd_time_exec        ) time_ctrl_st_nxt = T_EXECUTE;
         end
         T_WAIT_SYNC   : if  ( net_sync_t01        ) time_ctrl_st_nxt = T_EXECUTE;
         T_EXECUTE     : begin
            ctrl_cmd_exec = 1'b1 ;
            time_ctrl_st_nxt = T_IDLE ;
         end
         T_ERROR       : time_ctrl_st_nxt = T_IDLE ;
      endcase
end


TYPE_CTRL_OP net_ctrl_op_r ;
reg [47:0] net_ctrl_time_r ;

always_ff @(posedge t_clk_i)
   if (!t_rst_ni) begin
      net_ctrl_op_r     <= NOP;
      net_ctrl_time_r   <= 1'b0 ;
   end
// REGISTER INPUTS
   else if ( !ctrl_cmd_ack_o & ctrl_req ) begin
            net_ctrl_op_r    <= ctrl_cmd_op_i;
            net_ctrl_time_r  <= ctrl_cmd_dt_i;
      end



// State Change
always_comb begin
   time_reset_o  = 1'b0;
   time_init_o   = 1'b0;
   time_updt_o   = 1'b0;
   core_start_o  = 1'b0;
   core_stop_o   = 1'b0;
   if (ctrl_cmd_exec)
      case (net_ctrl_op_r)
         QICK_TIME_RST   :  time_reset_o  = 1'b1;
         QICK_TIME_INIT  :  time_init_o   = 1'b1;
         QICK_TIME_UPDT  :  time_updt_o   = 1'b1;
         QICK_CORE_START :  core_start_o  = 1'b1;
         QICK_CORE_STOP  :  core_stop_o   = 1'b1;
      endcase
end

wire [47:0] ctrl_left_time;

ADDSUB_MACRO #(
      .DEVICE     ("7SERIES"),        // Target Device: "7SERIES" 
      .LATENCY    ( 1   ),            // Desired clock cycle latency, 0-2
      .WIDTH      ( 48  )             // Input / output bus width, 1-48
   ) TIME_CMP_inst (
      .CLK        ( t_clk_i           ), // 1-bit clock input
      .RST        ( ~t_rst_ni         ), // 1-bit active high synchronous reset
      .CE         ( 1'b1              ), // 1-bit clock enable input
      .ADD_SUB    ( 1'b0              ), // 1-bit add/sub input, high selects add, low selects subtract
      .A          ( net_ctrl_time_r   ), // Input B bus, width defined by WIDTH 
      .B          ( t_time_abs        ), // Input A bus, width defined by WIDTH 
      .RESULT     ( ctrl_left_time    ), // A-B
      .CARRYIN    ( 1'b0              ), // 1-bit carry-in input
      .CARRYOUT   (                   )  // 1-bit carry-out output signal
   );

reg [47:0] ctrl_time;

ADDSUB_MACRO #(
      .DEVICE     ("7SERIES"),        // Target Device: "7SERIES" 
      .LATENCY    ( 1   ),            // Desired clock cycle latency, 0-2
      .WIDTH      ( 48  )             // Input / output bus width, 1-48
   ) CMD_TIME (
      .CLK        ( t_clk_i         ),    // 1-bit clock input
      .RST        ( ~t_rst_ni       ),     // 1-bit active high synchronous reset
      .CE         ( check_time_en   ),    // 1-bit clock enable input
      .ADD_SUB    ( 1'b0            ),    // 1-bit add/sub input, high selects add, low selects subtract
      .A          ( {16'd0, RTD_i}  ),   // Input B bus, width defined by WIDTH 
      .B          ( ctrl_left_time  ),    // Input A bus, width defined by WIDTH 
      .RESULT     ( ctrl_time       ), // Add/sub result output, width defined by WIDTH 
      .CARRYIN    ( 1'b0            ),    // 1-bit carry-in input
      .CARRYOUT   (                 )    // 1-bit carry-out output signal
   );
   
   
   
assign ctrl_st_do = time_ctrl_st[2:0];
endmodule

    