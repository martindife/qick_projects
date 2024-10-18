// Code your design here
module axis_cnt 
  #(
		parameter TDATA_DW = 32 ,
		parameter TDATA_QTY = 2 ,
		parameter TUSER_DW = 32
  ) (
    input wire [TDATA_DW-1:0]       max_value_i     ,
    input wire                     cnt_single_i     ,
    input wire                     cnt_en_i     ,

   // m_axis interfase.
   input wire                    m_axis_aclk     ,
   input wire                    m_axis_aresetn  ,
   output wire [TDATA_QTY*TDATA_DW-1:0]	 m_axis_tdata    ,
   output wire [TUSER_DW-1:0]	 m_axis_tuser    ,
   output wire                   m_axis_tlast    ,
   input  wire                   m_axis_tready  ,
   output wire                   m_axis_tvalid   );


reg [TDATA_DW-1:0] cnt;
wire [TDATA_DW-1:0] cnt_p1 ;
reg working, iddle;
wire cnt_last;
wire cnt_rst_n;
 
///////////////////////////////////////////////////////////////////////////////
// WORKING STATE MACHINE
localparam
   ST_IDLE       = 2'b00,
   ST_WORKING    = 2'b01,
   ST_WAITING    = 2'b11;
reg [2:0] cnt_st, cnt_st_nxt;

//  Sequential Logic
always @ (posedge m_axis_aclk or negedge m_axis_aresetn) if (!m_axis_aresetn)  cnt_st <=  ST_IDLE; else cnt_st <=  cnt_st_nxt;
// Combinational Logic
always @ (cnt_st, cnt_single_i, cnt_en_i, cnt_last) begin : CNT_UPDATE_ST
   cnt_st_nxt      = cnt_st;  // default is to stay in current state
   working         = 1'b0; // Default is not working
   iddle           = 1'b0; // Default is not working
   case (cnt_st)
      ST_IDLE : begin
         iddle       = 1'b1;
         if (cnt_single_i | cnt_en_i) cnt_st_nxt = ST_WORKING;
      end
      ST_WORKING : begin
         working   = 1'b1;
         if (!cnt_en_i & cnt_last) cnt_st_nxt = ST_WAITING;
      end
      ST_WAITING : begin
         if (cnt_en_i) 
            cnt_st_nxt = ST_WORKING;
            else
         if (!cnt_single_i) cnt_st_nxt = ST_IDLE;
      end
      endcase 
end

// Control Signals
assign cnt_last = (cnt_p1 >= max_value_i ) ? 1 : 0;
assign cnt_rst_n = m_axis_aresetn & !cnt_last;

assign cnt_p1 = cnt + 1'b1;
always @ (posedge m_axis_aclk) begin
   if       (iddle)            cnt <= 0;
   else if  (!cnt_rst_n)       cnt <= 0;
   else if  (m_axis_tready & working)    cnt <= cnt_p1;
  end

// OUT ASSIGNMENT
assign m_axis_tdata   = { TDATA_QTY{cnt} };
assign m_axis_tuser   = cnt[TUSER_DW-1:0];
assign m_axis_tlast   = cnt_last;
assign m_axis_tvalid  = working;

endmodule
