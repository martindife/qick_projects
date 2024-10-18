`include "_tnet_defines.svh"

module tnet_cmd_proc # (
   parameter DEBUG     = 1
)(
   input  wire             c_clk_i          ,
   input  wire             c_rst_ni         ,
   input  wire             ctrl_rst_i       ,
// External Signaling
   input  wire             aurora_ready_i   ,
   input  wire             tx_ready_t01     ,
   input  wire             net_sync_i       ,
   input TYPE_QPARAM       param_i          ,
   input wire [31:0]       tnet_dt_i[2]     ,
   input  wire [31:0]      t_time_abs       ,
   output  wire            c_ready_o        ,
// Command Control
   input   wire            loc_cmd_req_i    ,
   input   wire            net_cmd_req_i    ,
   input  wire [63:0]      cmd_header_i     ,
   input  wire [31:0]      cmd_dt_i [2]     ,
   output  wire            loc_cmd_ack_o    ,
   output  wire            net_cmd_ack_o    ,
// Update Parameter   
   output                 tx_req_set_o      ,
   output TYPE_PARAM_WE   param_we          ,
   output reg  [31:0]     param_64_dt [2]   ,
   output reg  [31:0]     param_32_dt       ,
   output reg  [ 9:0]     param_10_dt       ,
// Transmit Info
   output  reg            tx_req_o          ,
   output  reg [63:0]     tx_cmd_header_o   ,
   output  reg [31:0]     tx_cmd_dt_o[2]    ,
   input   wire           tx_ack_i          ,
// Control tProc
   output  TYPE_CTRL_REQ   ctrl_cmd_req_o   ,
   output  TYPE_CTRL_OP    ctrl_cmd_op_o    ,
   output  reg [47:0]      ctrl_cmd_dt_o    ,
   input   wire            ctrl_cmd_ok_i    ,
   input   wire            ctrl_cmd_ack_i   ,
// Debug
   output  wire [12:0]    tnet_st_do        ,
   output  wire [ 7:0]    error_cnt_do      ,
   output  wire [ 7:0]    ready_cnt_do      ,
   output  wire [ 3:0]    error_id_do       ,
   output  wire [31:0]    error_hist_do     ,
   output  wire [14:0]    cmd_do            ,
   output  wire [99:0]    cmd_st_hist_do     
  );


reg         cmd_end, cmd_step , cmd_error ;
//reg         get_time_lcs ;
reg         tx_req_set ;
reg  [63:0] tx_cmd_header ;
reg  [31:0] tx_cmd_dt [2];


// Sync Input Rising edge detection
///////////////////////////////////////////////////////////////////////////////
wire net_sync_t10 ;
reg net_sync_r, net_sync_r2 ;
(* ASYNC_REG = "TRUE" *) reg net_sync_cdc ;
always_ff @(posedge c_clk_i, negedge c_rst_ni) begin
   if (!c_rst_ni) begin
      net_sync_cdc   <= 0;
      net_sync_r     <= 0;
      net_sync_r2    <= 0;
   end else begin
      net_sync_cdc   <= net_sync_i;
      net_sync_r     <= net_sync_cdc;
      net_sync_r2    <= net_sync_r;
   end
end

assign net_sync_t10  = net_sync_r2 & !net_sync_r ;




// Command Decoding
///////////////////////////////////////////////////////////////////////////////

wire [ 4:0] header_id ;
wire [ 2:0] header_flg ;
wire [ 9:0] header_dst, header_src, header_step, header_step_p1 ;
wire [13:0] header_dt1 ;
wire [ 9:0] header_dt0, header_dt0_p1 ;
wire [63:0] cmd_header_p ;


assign header_id   = cmd_header_i[61:57];
assign header_flg  = cmd_header_i[56:54];
assign header_dst  = cmd_header_i[53:44];
assign header_src  = cmd_header_i[43:34];
assign header_step = cmd_header_i[33:24];
assign header_dt1  = cmd_header_i[23: 10];
assign header_dt0  = cmd_header_i[9: 0];
assign header_step     = cmd_header_i[33:24];
assign header_step_p1  = header_step + 1'b1;
assign header_dt0_p1   = header_dt0 + 1'b1;

assign cmd_header_p    = { cmd_header_i[63:34], header_step_p1, cmd_header_i[23:0] } ;

assign net_src_hit = (header_src == param_i.ID) ;
assign net_dst_hit = (header_dst == param_i.ID) ;

assign is_ret      = net_src_hit & ~header_flg[0] ;
assign is_ans      = net_dst_hit & header_flg[0];


// It has to be this way for VIVADO recognize a FSM !!!
assign id_get_net     = (header_id == _get_net    );
assign id_set_net     = (header_id == _set_net    );
assign id_sync_1      = (header_id == _sync1_net  );
assign id_sync_2      = (header_id == _sync2_net  );
assign id_sync_3      = (header_id == _sync3_net  );
assign id_sync_4      = (header_id == _sync4_net  );
assign id_get_off     = (header_id == _get_off    );
assign id_updt_off    = (header_id == _updt_off   );
assign id_set_dt      = (header_id == _set_dt     );
assign id_get_dt      = (header_id == _get_dt     );
assign id_rst_time    = (header_id == _rst_time   );
assign id_start_core  = (header_id == _start_core );
assign id_stop_core   = (header_id == _stop_core  );
assign id_set_cond    = (header_id == _set_cond   );
assign id_get_cond    = (header_id == _set_cond   );



// Signaling 
///////////////////////////////////////////////////////////////////////////////
TYPE_CTRL_REQ  ctrl_cmd_req ;
TYPE_CTRL_OP   ctrl_cmd_op ;
reg [4:0]      ctrl_cmd_dt ;
reg            time_out ;

wire ctrl_req, ctrl_rdy;
assign ctrl_req     = ctrl_cmd_req != X_NOP ;
assign ctrl_rdy     = ~ctrl_req &  ~ctrl_cmd_ack_i ;


// Command execution Handshake
///////////////////////////////////////////////////////////////////////////////
wire cmd_ack;
reg  loc_cmd_ack, loc_cmd_ack_set, loc_cmd_ack_clr  ;
reg  net_cmd_ack, net_cmd_ack_set, net_cmd_ack_clr  ; 

always_ff @ (posedge c_clk_i, negedge c_rst_ni) begin
   if (!c_rst_ni) begin
      loc_cmd_ack   <= 1'b0;
      net_cmd_ack   <= 1'b0;
   end else begin 
      if (loc_cmd_ack_clr | time_out | ctrl_rst_i ) loc_cmd_ack <= 1'b0;
      else if (loc_cmd_ack_set)                     loc_cmd_ack <= 1'b1;
      if (net_cmd_ack_clr | time_out | ctrl_rst_i ) net_cmd_ack <= 1'b0;
      else if (net_cmd_ack_set)                     net_cmd_ack <= 1'b1;
   end
end

assign cmd_ack = loc_cmd_ack | net_cmd_ack;


// TIMEOUT
///////////////////////////////////////////////////////////////////////////////
reg  [31:0] tx_rdy_t01_cnt_r ;
wire [31:0] tx_rdy_t01_cnt ;
reg  [10:0] time_out_cnt ;
reg         time_out_cnt_r;
wire        time_out_cnt_en ;


assign time_out_cnt_en  = ~main_idle & aurora_ready_i ;

always_ff @ (posedge c_clk_i, negedge c_rst_ni) begin
   if (!c_rst_ni) begin
      time_out_cnt      <= 0 ;
      time_out_cnt_r    <= 0 ;
      time_out          <= 0 ;
   end else begin
      time_out_cnt_r <= time_out_cnt[10];
      time_out   <= !time_out_cnt_r & time_out_cnt[10];
      if ( time_out_cnt_en ) begin
         if ( time_cnt_hit )  time_out_cnt <= time_out_cnt + 1'b1; 
      end else 
         time_out_cnt <= 0;
   end
end

// Count tx_ready_t01 when time_out_cnt_en
assign time_cnt_hit = tx_rdy_t01_cnt[31];

always_ff @ (posedge c_clk_i, negedge c_rst_ni) begin
   if      ( !c_rst_ni          ) tx_rdy_t01_cnt_r <= 0 ;
   else if ( time_cnt_hit       ) tx_rdy_t01_cnt_r <= 0 ;
   else if ( time_out_cnt_en    ) tx_rdy_t01_cnt_r <= tx_rdy_t01_cnt ;
   else                           tx_rdy_t01_cnt_r <= 0 ;
end

assign tx_rdy_t01_cnt_rst = time_cnt_hit | !time_out_cnt_en;

addsub_32 node_time_inst (
  .CLK  ( c_clk_i            ), // input wire CLK
  .SCLR ( tx_rdy_t01_cnt_rst       ),  // input wire SCLR
  .CE   ( tx_ready_t01       ), // input wire CE
  .A    ( tx_rdy_t01_cnt_r   ), // input wire [31 : 0] A
  .B    ( 32'd1              ), // input wire [31 : 0] B
  .ADD  ( 1                  ), // input wire ADD
  .S    ( tx_rdy_t01_cnt     )  // output wire [31 : 0] S
  );

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///// MAIN STATE
///////////////////////////////////////////////////////////////////////////////
typedef enum {
   M_NOT_READY  = 0, 
   M_IDLE       = 1,
   M_LOC_CMD    = 2,
   M_NET_CMD    = 3,
   M_WRESP      = 4,
   M_NET_RESP   = 5,
   M_CMD_EXEC   = 6,
   M_ERROR      = 7 
} TYPE_MAIN_ST  ;

(* fsm_encoding = "sequential" *) TYPE_MAIN_ST main_st;
TYPE_MAIN_ST main_st_nxt;

always_ff @ (posedge c_clk_i) begin
   if      ( !c_rst_ni   )  main_st  <= M_NOT_READY;
   else                     main_st  <= main_st_nxt;
end
always_comb begin
   main_st_nxt  = main_st; // Default Current
//   if      ( !aurora_ready_i ) main_st_nxt = M_NOT_READY;
//   else
      case (main_st)
         M_NOT_READY :  begin
            if      (  time_out       ) main_st_nxt = M_ERROR;     
            else if ( aurora_ready_i  ) main_st_nxt = M_IDLE;
         end
         M_IDLE      :  begin
            if      (  time_out       ) main_st_nxt = M_ERROR;     
            else if ( loc_cmd_req_i   ) main_st_nxt = M_LOC_CMD;
            else if ( net_cmd_req_i   ) main_st_nxt = M_NET_CMD;
         end
         M_LOC_CMD   :  begin
            if      (  time_out       ) main_st_nxt = M_ERROR;     
            else if ( cmd_error       ) main_st_nxt = M_ERROR;
            else if ( cmd_step         ) main_st_nxt = M_WRESP;
         end
         M_NET_CMD   :  begin
            if      (  time_out       ) main_st_nxt = M_ERROR;     
            else if ( cmd_error       ) main_st_nxt = M_ERROR;
            else if ( cmd_end         ) main_st_nxt = M_IDLE;
         end
         M_WRESP     :  begin
            if      (  time_out       ) main_st_nxt = M_ERROR;     
            else if ( net_cmd_req_i   ) main_st_nxt = M_NET_RESP;
            else if ( cmd_error       ) main_st_nxt = M_ERROR;
         end
         M_NET_RESP  : begin
            if      (  time_out       ) main_st_nxt = M_ERROR;     
            else if ( cmd_error       ) main_st_nxt = M_ERROR;  
            else if ( cmd_end         ) main_st_nxt = M_IDLE ;
            else if ( ctrl_req        ) main_st_nxt = M_CMD_EXEC ;
         end
         M_CMD_EXEC  :  begin
            if      (  time_out       ) main_st_nxt = M_ERROR;     
            else if ( cmd_error       ) main_st_nxt = M_ERROR;
            else if ( ctrl_rdy        ) main_st_nxt = M_IDLE ;
         end
         M_ERROR     :  begin
            if      (  time_out       ) main_st_nxt = M_ERROR;     
            else if ( cmd_step         ) main_st_nxt = M_IDLE ;
         end
         default     : main_st_nxt = M_IDLE ;
      endcase
end

// State Outputs
assign main_idle    = (main_st == M_IDLE);
assign main_LC      = (main_st == M_LOC_CMD);
assign main_NC      = (main_st == M_NET_CMD);
assign main_NR      = (main_st == M_NET_RESP) & is_ret;
assign main_NA      = (main_st == M_NET_RESP) & is_ans;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///// TASK STATE
///////////////////////////////////////////////////////////////////////////////
typedef enum {
   T_NOT_READY =0, 
   T_IDLE      =1, 
   T_LOC_CMD   =2,
   T_LOC_SEND  =3,
   T_LOC_WnREQ =4, 
   T_NET_CMD   =5, 
   T_NET_SEND  =6,
   T_ERROR     =7   
} TYPE_TNET_TASK ;



(* fsm_encoding = "sequential" *) TYPE_TNET_TASK task_st;
TYPE_TNET_TASK task_st_nxt;

always_ff @ (posedge c_clk_i) begin
   if      ( !c_rst_ni   )  task_st  <= T_NOT_READY;
   else                     task_st  <= task_st_nxt;
end

always_comb begin
   task_st_nxt      = task_st; // Default Current
   loc_cmd_ack_set  = 1'b0 ;
   loc_cmd_ack_clr  = 1'b0 ;
   net_cmd_ack_set  = 1'b0 ; 
   net_cmd_ack_clr  = 1'b0 ;
//   if (!aurora_ready_i )  
//      task_st_nxt = T_NOT_READY;
//   else
      case (task_st)
         T_NOT_READY : begin
            loc_cmd_ack_clr = 1'b1;
            net_cmd_ack_clr = 1'b1;
            if (aurora_ready_i)  task_st_nxt = T_IDLE;
         end
         T_IDLE      : begin
            loc_cmd_ack_clr = 1'b1;
            net_cmd_ack_clr = 1'b1;
               if (loc_cmd_req_i) begin
               task_st_nxt      = T_LOC_CMD;
            end
            else if (net_cmd_req_i) begin
               task_st_nxt      = T_NET_CMD;
            end
         end
   // LOCAL COMMAND
         T_LOC_CMD : begin
            loc_cmd_ack_set  = 1'b1 ;
            if      ( tx_req_o  )     task_st_nxt = T_LOC_SEND;
            else if ( cmd_step   )     task_st_nxt = T_LOC_WnREQ;
            else if ( cmd_error )     task_st_nxt = T_LOC_WnREQ;
         end
         T_LOC_SEND : begin
            if      ( !tx_ack_i & !tx_req_o   )     task_st_nxt = T_LOC_WnREQ;
            else if ( cmd_error )     task_st_nxt = T_ERROR;
         end
         T_LOC_WnREQ : begin
            if ( !loc_cmd_req_i )  task_st_nxt = T_IDLE;
         end
   // NETWORK COMMAND
         T_NET_CMD : begin
            net_cmd_ack_set  = 1'b1 ; 
            if      ( tx_req_o  )     task_st_nxt = T_NET_SEND;
            else if ( cmd_step   )     task_st_nxt = T_LOC_WnREQ;
            else if ( cmd_error )     task_st_nxt = T_ERROR;
         end
         T_NET_SEND : begin
            if (!tx_ack_i & !tx_req_o) task_st_nxt = T_IDLE;
         end
         T_ERROR : begin
            if ( !loc_cmd_req_i )  task_st_nxt = T_IDLE;
         end

         default     : task_st_nxt = T_IDLE;
      endcase
end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///// COMMAND EXECUTION STATE
///////////////////////////////////////////////////////////////////////////////

(* fsm_encoding = "sequential" *) (* fsm_safe_state = "reset_state" *) TYPE_TNET_CMD cmd_st;
TYPE_TNET_CMD cmd_st_nxt;


always_ff @ (posedge c_clk_i) begin
   if      (!c_rst_ni)   cmd_st  <= NOT_READY;
   else                  cmd_st  <= cmd_st_nxt;
end

reg [3:0] error_id;

always_comb begin
   cmd_st_nxt     = cmd_st; // Default Current
   cmd_step       = 1'b0;
   cmd_end        = 1'b0;
   ctrl_cmd_req   = X_NOP;
   tx_req_set     = 1'b0 ;
   param_we       = '{default:'0};
   param_32_dt    = 32'd0;
   param_10_dt    = 10'd0;
   tx_cmd_dt      = '{default:'0};
   tx_cmd_header  = 0;
   error_id       = 15;
   ctrl_cmd_op    = NOP;
   param_64_dt    = '{default:'0};
   //get_time_lcs   = 1'b0;
   ctrl_cmd_dt    = '{default:'0};
   cmd_error      = 1'b0;

   case (cmd_st)
      NOT_READY: if (aurora_ready_i)  cmd_st_nxt = IDLE;
      IDLE: begin
         if      ( main_LC & id_get_net    ) cmd_st_nxt = LOC_GNET;
         else if ( main_LC & id_set_net    ) cmd_st_nxt = LOC_SNET;
         else if ( main_LC & id_sync_1     ) cmd_st_nxt = LOC_SYNC1;
         else if ( main_LC & id_sync_2     ) cmd_st_nxt = LOC_SYNC2;
         else if ( main_LC & id_get_off    ) cmd_st_nxt = ST_ERROR;
         else if ( main_LC & id_updt_off   ) cmd_st_nxt = LOC_UPDT_OFF;
         else if ( main_LC & id_set_dt     ) cmd_st_nxt = LOC_SET_DT;
         else if ( main_LC & id_get_dt     ) cmd_st_nxt = LOC_GET_DT;
         else if ( main_LC & id_rst_time   ) cmd_st_nxt = LOC_RST_TIME;
         else if ( main_LC & id_start_core ) cmd_st_nxt = LOC_START_CORE;
         else if ( main_LC & id_stop_core  ) cmd_st_nxt = LOC_STOP_CORE;
         else if ( main_NC & id_get_net    ) cmd_st_nxt = NET_GNET_P;
         else if ( main_NC & id_set_net    ) cmd_st_nxt = NET_SNET_P;
         else if ( main_NC & id_sync_1     ) cmd_st_nxt = NET_SYNC1_P;
         else if ( main_NC & id_sync_2     ) cmd_st_nxt = ST_ERROR;
         else if ( main_NC & id_get_off    ) cmd_st_nxt = ST_ERROR;
         else if ( main_NC & id_updt_off   ) cmd_st_nxt = NET_UPDT_OFF_P;
         else if ( main_NC & id_set_dt     ) cmd_st_nxt = NET_SET_DT_P;
         else if ( main_NC & id_get_dt     ) cmd_st_nxt = NET_GET_DT_P;
         else if ( main_NC & id_rst_time   ) cmd_st_nxt = NET_RST_TIME_P;
         else if ( main_NC & id_start_core ) cmd_st_nxt = NET_START_CORE_P;
         else if ( main_NC & id_stop_core  ) cmd_st_nxt = NET_STOP_CORE_P;
         else if ( main_NR & id_get_net    ) cmd_st_nxt = NET_GNET_R;
         else if ( main_NR & id_set_net    ) cmd_st_nxt = NET_SNET_R;
         else if ( main_NR & id_sync_1     ) cmd_st_nxt = NET_SYNC1_R;
         else if ( main_NR & id_sync_2     ) cmd_st_nxt = ST_ERROR;
         else if ( main_NR & id_get_off    ) cmd_st_nxt = ST_ERROR;
         else if ( main_NR & id_updt_off   ) cmd_st_nxt = NET_UPDT_OFF_R;
         else if ( main_NR & id_set_dt     ) cmd_st_nxt = NET_SET_DT_R;
         else if ( main_NR & id_get_dt     ) cmd_st_nxt = NET_GET_DT_R;
         else if ( main_NR & id_rst_time   ) cmd_st_nxt = NET_RST_TIME_R;
         else if ( main_NR & id_start_core ) cmd_st_nxt = NET_START_CORE_R;
         else if ( main_NR & id_stop_core  ) cmd_st_nxt = NET_STOP_CORE_R;
         else if ( main_NA & id_get_net    ) cmd_st_nxt = ST_ERROR;
         else if ( main_NA & id_set_net    ) cmd_st_nxt = ST_ERROR;
         else if ( main_NA & id_sync_1     ) cmd_st_nxt = ST_ERROR;
         else if ( main_NA & id_sync_2     ) cmd_st_nxt = ST_ERROR;
         else if ( main_NA & id_get_off    ) cmd_st_nxt = ST_ERROR;
         else if ( main_NA & id_updt_off   ) cmd_st_nxt = ST_ERROR;
         else if ( main_NA & id_set_dt     ) cmd_st_nxt = ST_ERROR;
         else if ( main_NA & id_get_dt     ) cmd_st_nxt = ST_ERROR;
         else if ( main_NA & id_rst_time   ) cmd_st_nxt = ST_ERROR;
         else if ( main_NA & id_start_core ) cmd_st_nxt = ST_ERROR;
         else if ( main_NA & id_stop_core  ) cmd_st_nxt = ST_ERROR;
      end
      LOC_GNET      : begin
         param_we.ID   = 1'b1;
         param_10_dt   = 10'd1;
         tx_cmd_header = cmd_header_i;
         tx_cmd_dt[1]  = 0;
         tx_cmd_dt[0]  = 0;
         // Wait for TX
         if (tx_ready_t01) begin
            cmd_st_nxt = WAIT_TX_ACK;
            ctrl_cmd_req = X_NOW;
            ctrl_cmd_op  = QICK_TIME_RST ;
            tx_req_set   = 1'b1 ;
         end
      end
      LOC_SNET      : begin
         tx_cmd_header = cmd_header_i;
         tx_cmd_dt[1]  = param_i.RTD;
         tx_cmd_dt[0]  = 0;
         // Wait for TX
         if (tx_ready_t01) begin
            cmd_st_nxt = WAIT_TX_ACK;
            ctrl_cmd_req  = X_NOW;
            ctrl_cmd_op   = QICK_TIME_RST ;
            tx_req_set    = 1'b1 ;
         end
      end
      LOC_SYNC1     : begin
         tx_cmd_header = cmd_header_i;
         tx_cmd_dt     = '{default:'0};
         // Wait for EXTERNAL SYNC
         if (net_sync_t10) begin
            cmd_st_nxt = WAIT_TX_ACK;
            ctrl_cmd_req  = X_EXT;
            ctrl_cmd_op   = QICK_TIME_RST ;
            tx_req_set    = 1'b1 ;
         end
      end
      LOC_UPDT_OFF: begin
         tx_cmd_header = cmd_header_i;
         tx_cmd_dt     = cmd_dt_i;
         // Wait for TX
         if (tx_ready_t01) begin
            cmd_st_nxt = WAIT_TX_ACK;
            tx_req_set = 1'b1 ;
         end
      end
      LOC_SET_DT: begin
         tx_cmd_header = cmd_header_i;
         tx_cmd_dt     = cmd_dt_i;
         if (tx_ready_t01) begin
            cmd_st_nxt = WAIT_TX_ACK;
            tx_req_set = 1'b1 ;
         end
      end
      LOC_GET_DT: begin
         tx_cmd_header = cmd_header_i;
         tx_cmd_dt     = '{default:'0};
         if (tx_ready_t01) begin
            cmd_st_nxt = WAIT_TX_ACK;
            tx_req_set    = 1'b1 ;
         end
      end
/// COMMAND RESET TIME      
      LOC_RST_TIME: begin
         ctrl_cmd_req  = X_TIME;
         ctrl_cmd_op   = QICK_TIME_RST ; 
         ctrl_cmd_dt   = {cmd_dt_i[0][15:0] , cmd_dt_i[1] };
         tx_cmd_header = cmd_header_i;
         tx_cmd_dt     = cmd_dt_i; //Time
         if      (ctrl_cmd_ack_i & ctrl_cmd_ok_i ) cmd_st_nxt = WAIT_TX_ACK; 
         else if (ctrl_cmd_ack_i & !ctrl_cmd_ok_i) cmd_st_nxt =  ST_ERROR; 
         
         if (ctrl_cmd_ack_i & ctrl_cmd_ok_i) tx_req_set    = 1'b1 ;
      end
      NET_RST_TIME_P: begin
         ctrl_cmd_req  = X_TIME;
         ctrl_cmd_op   = QICK_TIME_RST ;
         ctrl_cmd_dt   = {cmd_dt_i[0][15:0] , cmd_dt_i[1] };
         tx_cmd_header = cmd_header_i;
         tx_cmd_dt     = cmd_dt_i;
         if (tx_ready_t01) begin
            cmd_st_nxt = WAIT_TX_ACK;
            tx_req_set    = 1'b1 ;
         end
      end
      NET_RST_TIME_R: begin
         cmd_st_nxt =  WAIT_CMD_nACK;
         cmd_step    = 1'b1;
      end

      
      NET_GNET_P    : begin
         param_we.ID   = 1'b1  ;
         param_10_dt   = header_dt0_p1;
         tx_cmd_header = {cmd_header_p[63:24],  header_dt1, header_dt0_p1} ;
         tx_cmd_dt[1]  = 0;
         tx_cmd_dt[0]  = 0;
         // Wait for TX
         if (tx_ready_t01) begin
            cmd_st_nxt = WAIT_TX_ACK;
            tx_req_set = 1'b1 ;
         end
      end
      NET_SNET_P    : begin
         param_we.RTD   = 1'b1  ;
         param_32_dt    = cmd_dt_i[1];
         param_we.NN    = 1'b1  ;
         param_10_dt    = cmd_header_i[9:0];
         tx_cmd_header  = cmd_header_p;
         tx_cmd_dt      = cmd_dt_i;
         // Wait for TX
         if (tx_ready_t01) begin 
            cmd_st_nxt = WAIT_TX_ACK;
            tx_req_set = 1'b1 ;
         end
      end
      NET_SYNC1_P   : begin
         ctrl_cmd_req  = X_EXT;
         ctrl_cmd_op   = QICK_TIME_RST ;
         tx_cmd_header = cmd_header_p;
         tx_cmd_dt     = '{default:'0};
         // Wait for TX
         if (tx_ready_t01) begin
            cmd_st_nxt = WAIT_TX_ACK;
            tx_req_set     = 1'b1 ;
         end            
         
      end




      NET_GNET_R    : begin
         param_we.RTD   = 1'b1  ;
         param_32_dt    = t_time_abs[31:0];
         param_we.NN    = 1'b1  ;
         param_10_dt    = header_dt0 ;
         cmd_step        = 1'b1;
         cmd_st_nxt     = WAIT_CMD_nACK;
      end
      NET_SNET_R    : begin
         cmd_step        = 1'b1;
         cmd_st_nxt = WAIT_CMD_nACK;
      end
      NET_SYNC1_R   : begin
         if (net_sync_t10) begin
            cmd_step = 1'b1;
            cmd_st_nxt = WAIT_CMD_nACK;
         end
      end
      WAIT_TX_ACK   : begin
         if ( tx_ack_i  )  begin
            cmd_step = 1'b1;
            cmd_st_nxt = WAIT_TX_nACK;
         end
      end
      WAIT_TX_nACK  : begin
         if ( !tx_ack_i )  begin
            cmd_st_nxt = WAIT_CMD_nACK;
         end
      end
      WAIT_CMD_nACK : begin
         if ( !cmd_ack  )  begin
            cmd_st_nxt = IDLE;
            cmd_end = 1'b1;
         end
      end
      ST_ERROR: begin
         cmd_error     = 1'b1 ;
         if (!cmd_ack) begin
            cmd_step = 1'b1 ;
            cmd_st_nxt = IDLE;
         end
      end
      default : begin 
         error_id   = 14;
         cmd_st_nxt = ST_ERROR;
      end
   endcase
end


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DEBUG
///////////////////////////////////////////////////////////////////////////////
wire [ 4:0] cmd_ds;

tnet_cmd_watch  # (
   .DEBUG ( DEBUG )
) debug_inst (
   .clk_i          ( c_clk_i        ),
   .rst_ni         ( c_rst_ni       ),
   .current_st_i   ( cmd_st         ),
   .error_id_i     ( main_st[3:0]   ),
   .cmd_st_do      ( cmd_ds         ),
   .cmd_hist_do    ( cmd_st_hist_do ),
   .ready_cnt_do   ( ready_cnt_do   ),
   .error_cnt_do   ( error_cnt_do   ),   
   .error_id_do    ( error_id_do    ),
   .error_hist_do  ( error_hist_do  )
);

   
assign tnet_st_do   = { cmd_ds[4:0], task_st[3:0], main_st[3:0] } ;
assign cmd_do       = { id_get_cond, id_set_cond, id_stop_core, id_start_core, id_rst_time, id_get_dt, id_set_dt, id_updt_off, id_get_off, id_sync_4, id_sync_3, id_sync_2, id_sync_1, id_set_net, id_get_net } ;



///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// OUTPUTS
///////////////////////////////////////////////////////////////////////////////

always_ff @ (posedge c_clk_i, negedge c_rst_ni) begin
   if (!c_rst_ni) begin
      tx_req_o            <= 1'b0;
      tx_cmd_header_o   <= 64'd0;
      tx_cmd_dt_o       <= '{default:'0};
   end else begin 
      if (tx_req_set ) begin   
         tx_req_o          <= 1'b1;
         tx_cmd_header_o <= tx_cmd_header;
         tx_cmd_dt_o     <= { tx_cmd_dt[0], tx_cmd_dt[1] };
      end 
      if (tx_req_o & tx_ack_i) begin
         tx_req_o <= 1'b0;
      end
   end
end

assign c_ready_o      = (main_st == M_IDLE) ;
assign loc_cmd_ack_o  = loc_cmd_ack ;
assign net_cmd_ack_o  = net_cmd_ack ;
assign tx_req_set_o   = tx_req_set ;
assign ctrl_cmd_req_o = ctrl_cmd_req ;
assign ctrl_cmd_op_o  = ctrl_cmd_op  ;
assign ctrl_cmd_dt_o  = ctrl_cmd_dt  ;

endmodule

