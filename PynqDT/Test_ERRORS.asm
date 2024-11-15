//TEST program for ALL instructions
// DIRECTIVES
// Assign new names to the registers.
.ALIAS repeat_cnt r0
.ALIAS addr_aux r1
.ALIAS data_aux r2
.ALIAS time_aux r3 ; .ALIAS time_aux s3
.CONST cuatro #4
INIT:

REG_WR r0 imm cuatro 


ARITH T w1 w2
ARITH PT w1 r2 w3
ARITH TP w1 w2 r3
ARITH PTM w1 r2 w3 r4

// CONF INTRUCTIONS
/////////////////////////////////////////////////
// .ALIAS r10 r1 
// .ALIAS y*n r1 
// .ALIAS home run
// .ALIAS aux 

// TEST -op(r3 - #3) -wr(r1 imm)
// TEST -op(r3 - #3) -ww
// TEST -op(r4 AND #b11) -wp @100
// TEST -op(r4 CAT r5) -wp @100
// TEST  -op(r4 AND #b12)

// REGISTER Instructions
/////////////////////////////////////////////////
// GENERAL REGITSERS
// REG_WR r0 imm #255 -wr(r1 imm)
// REG_WR r0 imm #255 -ww
// REG_WR r0 imm #255 -wp(wmem)
// REG_WR r0 imm #255 -uf 
// REG_WR r0 op -op(s0 - 255)
// REG_WR r0 op -op(s0 - #b255)
// REG_WR r1 imm #b1 @100
// REG_WR r1 imm #5000000000
// REG_WR r1 imm #b2


// MEMORY Instructions
/////////////////////////////////////////////////
// DMEM_WR
// DMEM_WR [1]
 DMEM_WR [w1] imm #5
// DMEM_WR [s1]
// DMEM_WR [&0] -ww
// DMEM_WR [&0] -wp(r_wave)
// DMEM_WR [&0] -op(r1 + r2)
// DMEM_WR [&0] imm
// DMEM_WR [&0] imm #5000000000
// DMEM_WR [&0] imm #100000 -op(r1-r2) -uf

// WMEM_WR
// WMEM_WR [1]
// WMEM_WR [s1]

// WMEM_WR [&0] -wr(r1 imm)
// WMEM_WR [r2] -wr(r1 op) 
// WMEM_WR [r2] -wr(r1 imm) #100 @255
// WMEM_WR [r2] @255 -op(r1 - #100) -uf

//PA
//PB 31 r1 r2 r3 r4 r5

// DIV #1 #1

JUMP HERE