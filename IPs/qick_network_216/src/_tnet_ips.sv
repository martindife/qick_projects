
/// Clock Domain Register Change
module sync_reg # (
   parameter DW  = 32
)(
   input  wire [DW-1:0] dt_i     , 
   input  wire          clk_i  ,
   input  wire          rst_ni  ,
   output wire [DW-1:0] dt_o     );
   
(* ASYNC_REG = "TRUE" *) reg [DW-1:0] data_rcd, data_r ;
always_ff @(posedge clk_i)
   if(!rst_ni) begin
      data_rcd  <= 0;
      data_r    <= 0;
   end else begin 
      data_rcd  <= dt_i;
      data_r    <= data_rcd;
      end
assign dt_o = data_r ;

endmodule


/*
module net_div_r #(
   parameter DW      = 32 ,
   parameter N_PIPE  = 32 
) (
   input  wire             clk_i           ,
   input  wire             rst_ni          ,
   input  wire             start_i         ,
   input  wire [DW-1:0]    A_i             ,
   input  wire [DW-1:0]    B_i             ,
   output wire             ready_o         ,
   output wire             end_o         ,
   output wire [DW-1:0]    div_quotient_o  ,
   output wire [DW-1:0]    div_remainder_o );

localparam comb_per_reg = DW / N_PIPE;

reg [DW-1     : 0 ] inB     ;
reg [DW-1     : 0 ] q_temp     ;
reg [DW-1     : 0 ] r_temp     [N_PIPE] ;
reg [DW-1     : 0 ] r_temp_nxt [N_PIPE] ;
reg [2*DW-1 : 0 ] sub_temp [N_PIPE] ;

integer ind_comb_stage [N_PIPE];
integer ind_bit[N_PIPE]; 

wire working;
reg  [N_PIPE-1:0] en_r  ;

assign working    = |en_r;


always_ff @ (posedge clk_i, negedge rst_ni) begin
   if (!rst_ni) begin         
      en_r       <= 0 ;
      r_temp [0] <= 0 ;
      inB        <= 0 ;
   end else
      if (start_i) begin
         en_r           <= {en_r[N_PIPE-2:0], 1'b1} ;
         r_temp   [0]   <= A_i ;
         inB            <= B_i ;
      end else if (working)
         en_r           <= {en_r[N_PIPE-2:0], 1'b0} ;
end // Always


///////////////////////////////////////////////////////////////////////////
// FIRST STAGE
always @ (r_temp[0], r_temp_nxt[0], inB) begin
   r_temp_nxt[0] = r_temp[0];
   for (ind_comb_stage[0]=0; ind_comb_stage[0] < comb_per_reg ; ind_comb_stage[0]=ind_comb_stage[0]+1) begin
      ind_bit[0] = (DW-1) - ( ind_comb_stage[0] ) ;
      sub_temp[0] = inB << ind_bit[0] ;
      if (r_temp_nxt[0] >= sub_temp[0]) begin
         q_temp [ind_bit[0]]  = 1'b1 ;
         r_temp_nxt[0] = r_temp_nxt[0] - sub_temp[0];
      end else 
         q_temp [ind_bit[0]] = 1'b0;
   end
end

genvar ind_reg_stage;
for (ind_reg_stage=1; ind_reg_stage < N_PIPE ; ind_reg_stage=ind_reg_stage+1) begin
   // SEQUENCIAL PART
   always_ff @ (posedge clk_i) begin 
      r_temp   [ind_reg_stage]   = r_temp_nxt   [ind_reg_stage-1] ;
   end
   // COMBINATORIAL PART
   always_comb begin
      r_temp_nxt[ind_reg_stage] = r_temp[ind_reg_stage];
      for (ind_comb_stage[ind_reg_stage]=0; ind_comb_stage[ind_reg_stage] < comb_per_reg ; ind_comb_stage[ind_reg_stage]=ind_comb_stage[ind_reg_stage]+1) begin
         ind_bit[ind_reg_stage] = (DW-1) - (ind_comb_stage[ind_reg_stage] + (ind_reg_stage * comb_per_reg)) ;
         sub_temp[ind_reg_stage] = inB << ind_bit[ind_reg_stage] ;
         if (r_temp_nxt[ind_reg_stage] >= sub_temp[ind_reg_stage]) begin
            q_temp [ind_bit[ind_reg_stage]]  = 1'b1 ;
            r_temp_nxt[ind_reg_stage] = r_temp_nxt[ind_reg_stage] - sub_temp[ind_reg_stage];
         end else 
            q_temp [ind_bit[ind_reg_stage]] = 1'b0;
      end
   end
end

assign ready_o          = ~working;
assign end_o            = en_r[N_PIPE-1];
assign div_quotient_o   = q_temp;
assign div_remainder_o  = r_temp_nxt[N_PIPE-1];

endmodule
*/
