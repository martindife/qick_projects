module xcom_qctrl (
// CLK & RST
   input  wire             c_clk_i      ,
   input  wire             c_rst_ni     ,
   input  wire             t_clk_i      ,
   input  wire             t_rst_ni     ,
   input  wire             pulse_sync_i ,
   input  wire             qctrl_req_i  ,
   input  wire  [2:0]      qctrl_dt_i   ,
   input  wire             qsync_req_i  ,
// TPROC CONTROL
   output reg              p_start_o    ,
   output reg              p_stop_o     ,
   output reg              t_rst_o      ,
   output reg              t_updt_o     ,
   output reg              c_start_o    ,
   output reg              c_stop_o     
);

reg [2:0] qctrl_cnt;

// PULSE SYNC 
///////////////////////////////////////////////////////////////////////////////
reg t_pulse_r2 ;
sync_reg # (
   .DW ( 1 )
) t_sync_pulse (
   .dt_i      ( pulse_sync_i ) ,
   .clk_i     ( t_clk_i      ) ,
   .rst_ni    ( t_rst_ni     ) ,
   .dt_o      ( t_pulse_r    ) );

always_ff @ (posedge t_clk_i, negedge t_rst_ni) begin
   if (!t_rst_ni)   t_pulse_r2   <= 1'b0; 
   else             t_pulse_r2   <= t_pulse_r;
end
assign t_sync_t01 = !t_pulse_r2 & t_pulse_r ;


reg c_start_s, c_stop_s;
assign qctrl_pulse_end = (qctrl_cnt == 3'd7);

// PROCESSOR CONTROL
///////////////////////////////////////////////////////////////////////////////
typedef enum { QCTRL_IDLE, QRST_WSYNC, QRST_EXEC, QCTRL_EXEC } TYPE_QCTRL_ST ;
   (* fsm_encoding = "sequential" *) TYPE_QCTRL_ST qctrl_st;
   TYPE_QCTRL_ST qctrl_st_nxt;

always_ff @ (posedge t_clk_i) begin
   if      ( !t_rst_ni   )  qctrl_st  <= QCTRL_IDLE;
   else                     qctrl_st  <= qctrl_st_nxt;
end

always_comb begin
   qctrl_st_nxt = qctrl_st; // Default Current
   p_start_o    = 1'b0;
   p_stop_o     = 1'b0;
   t_rst_o      = 1'b0;
   t_updt_o     = 1'b0;
   c_start_s    = 1'b0;
   c_stop_s     = 1'b0;
   qctrl_en    = 3'd0;
   case (qctrl_st)
      QCTRL_IDLE  : 
         if      ( qsync_req_i ) qctrl_st_nxt = QRST_WSYNC;
         else if ( qctrl_req_i ) qctrl_st_nxt = QCTRL_EXEC;     
      QRST_WSYNC : begin
         if ( t_sync_t01  ) qctrl_st_nxt = QRST_EXEC;     
      end
      QRST_EXEC : begin
         p_start_o  = 1'b1;
         qctrl_en   = 1'b1;
         if ( qctrl_pulse_end ) qctrl_st_nxt = QCTRL_IDLE;     
      end
      QCTRL_EXEC : begin
         case (qctrl_dt_i)
            3'b010  : t_rst_o   = 1'b1;
            3'b011  : t_updt_o  = 1'b1;
            3'b100  : c_start_s = 1'b1;
            3'b101  : c_stop_s  = 1'b1;
            3'b110  : p_start_o = 1'b1;
            3'b111  : p_stop_o  = 1'b1;
         endcase
         qctrl_en  = 1'b1;
         if ( qctrl_pulse_end ) qctrl_st_nxt = QCTRL_IDLE;     
      end
      default: qctrl_st_nxt = qctrl_st;
   endcase
end

reg qctrl_en;
always_ff @ (posedge t_clk_i) begin
   if      ( !t_rst_ni) qctrl_cnt  <= 0;
   else if ( qctrl_en ) qctrl_cnt  <= qctrl_cnt+1'b1;
   else                 qctrl_cnt  <= 0;
end

sync_reg #(.DW(2)) c_ctrl_sync (
   .dt_i      ( {c_start_s, c_stop_s} ) ,
   .clk_i     ( c_clk_i     ) ,
   .rst_ni    ( c_rst_ni    ) ,
   .dt_o      ( {c_start_o, c_stop_o} ) );
   
// OUTPUTS
///////////////////////////////////////////////////////////////////////////////

endmodule
