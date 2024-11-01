`include "_tnet_defines.svh"

module tnet_cmd_watch # (
   parameter DEBUG     = 1
)(
   input  wire             clk_i     ,
   input  wire             rst_ni    ,
   input  TYPE_TNET_CMD    current_st_i ,
   input  wire [ 3:0]      error_id_i  ,
   output reg  [ 4:0]      cmd_st_do    ,    
   output wire [99:0]      cmd_hist_do   ,  
   output wire [ 7:0]      ready_cnt_do   ,  
   output reg  [ 7:0]      error_cnt_do ,      
   output reg  [ 3:0]      error_id_do   , 
   output wire [31:0]      error_hist_do   
);

TYPE_TNET_CMD  current_st_r ;
reg [ 3:0]     error_id_r   ;

always_ff @(posedge clk_i)
   if (!rst_ni) begin
      current_st_r  <= NOT_READY;
      error_id_r    <= 1'b0;
   end else begin
      current_st_r  <= current_st_i; 
      error_id_r    <= error_id_i;
   end

assign cmd_error   = st_change & (current_st_i == ST_ERROR);
assign st_change   = current_st_i != current_st_r ;

// Command Execution
///////////////////////////////////////////////////////////////////////////////
reg [4:0] debug_dt;

// COMMAND STATE OUT
always_comb begin
   debug_dt = 0 ;
   case (current_st_i)
      NOT_READY         : debug_dt = 0 ;
      IDLE              : debug_dt = 1 ;
      LOC_GNET          : debug_dt = 2 ;
      LOC_SNET          : debug_dt = 3 ;
      LOC_SYNC1         : debug_dt = 4 ;
      LOC_UPDT_OFF      : debug_dt = 5 ;
      LOC_SET_DT        : debug_dt = 6 ;
      LOC_GET_DT        : debug_dt = 7 ;
      LOC_RST_TIME      : debug_dt = 8 ;
      LOC_START_CORE    : debug_dt = 9 ;
      LOC_STOP_CORE     : debug_dt = 10;
      NET_GNET_P        : debug_dt = 11;
      NET_SNET_P        : debug_dt = 12;
      NET_SYNC1_P       : debug_dt = 13;
      NET_UPDT_OFF_P    : debug_dt = 14;
      NET_SET_DT_P      : debug_dt = 15;
      NET_GET_DT_P      : debug_dt = 16;
      NET_RST_TIME_P    : debug_dt = 17;
      NET_START_CORE_P  : debug_dt = 18;
      NET_STOP_CORE_P   : debug_dt = 19;
      NET_GNET_R        : debug_dt = 20;
      NET_SNET_R        : debug_dt = 21;
      NET_SYNC1_R       : debug_dt = 22;
      NET_UPDT_OFF_R    : debug_dt = 23;
      NET_SET_DT_R      : debug_dt = 24;
      NET_GET_DT_R      : debug_dt = 24;
      NET_RST_TIME_R    : debug_dt = 25;
      NET_START_CORE_R  : debug_dt = 25;
      NET_STOP_CORE_R   : debug_dt = 25;
      NET_GET_DT_A      : debug_dt = 26;
      WAIT_TX_ACK       : debug_dt = 27;
      WAIT_TX_nACK      : debug_dt = 28;
      WAIT_CMD_nACK     : debug_dt = 29;
      LOC_SYNC2         : debug_dt = 30;
      LOC_SYNC3         : debug_dt = 30;
      LOC_SYNC4         : debug_dt = 30;
      LOC_GET_OFF       : debug_dt = 30;
      NET_SYNC2_P       : debug_dt = 30;
      NET_SYNC3_P       : debug_dt = 30;
      NET_SYNC4_P       : debug_dt = 30;
      NET_GET_OFF_P     : debug_dt = 30;
      NET_SYNC2_R       : debug_dt = 30;
      NET_SYNC3_R       : debug_dt = 30;
      NET_SYNC4_R       : debug_dt = 30;
      NET_GET_OFF_A     : debug_dt = 30;
      ST_ERROR          : debug_dt = 31;
   endcase
end

// Stores New State
reg [4:0] cmd_ST_r1;
always_ff @(posedge clk_i)
   if (!rst_ni) 
      cmd_ST_r1  <=  5'd0;
   else
      if (st_change)
         cmd_ST_r1  <= debug_dt; 

assign cmd_st_do   = cmd_ST_r1 ;

// Stores Error ID and Count
always_ff @(posedge clk_i) 
   if (!rst_ni) begin
      error_cnt_do   <= 8'd0;
      error_id_do    <= 4'd0;
   end else begin 
      if ( cmd_error ) begin   
         error_cnt_do <= error_cnt_do + 1'b1;
         error_id_do  <= error_id_r;
      end
   end



reg [99:0] cmd_st_hist ;
reg [ 7:0] ready_cnt ;

generate
   if (DEBUG) begin : DEBUG_STATE
      always_ff @(posedge clk_i)
         if (!rst_ni) begin 
            cmd_st_hist  <=  30'd0;
            ready_cnt    <=  8'd0;
         end else
            if (st_change) begin
               cmd_st_hist  <= {cmd_st_hist[94:0], cmd_ST_r1};
               if (current_st_i== NOT_READY)
                  ready_cnt = ready_cnt + 1'b1; 
            end
   end else begin
      always_comb begin
         cmd_st_hist  = 0 ;
         ready_cnt  = 0 ;
      end
   end
endgenerate

assign cmd_hist_do  = cmd_st_hist;
assign ready_cnt_do = ready_cnt ;



reg [31:0] cmd_err_hist;
generate
   if (DEBUG) begin : DEBUG_ERROR
      always_ff @(posedge clk_i)
         if (!rst_ni) 
            cmd_err_hist  <=  31'd0;
         else if ( cmd_error )   
            cmd_err_hist  <= {cmd_err_hist[27:0], error_id_do} ;
   end else begin
      always_comb 
         cmd_err_hist  = 0 ;
   end
endgenerate   

assign error_hist_do = cmd_err_hist;

      
endmodule



