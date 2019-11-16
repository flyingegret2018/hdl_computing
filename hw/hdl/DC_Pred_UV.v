//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	DC_Pred_UV.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-16 11:10
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module DC_Pred_UV#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 8
,parameter SHIFT        = 4
)(
 input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]                top_u
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]                top_v
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]                left_u
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]                left_v
,output     [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]   dst
);

reg [BIT_WIDTH + SHIFT : 0] temp1_u,temp1_v;
reg [BIT_WIDTH - 1 : 0] temp2_u,temp2_v;

assign temp1_u = top_u[7  : 0 ] + left_u[7  : 0 ] +
                 top_u[15 : 8 ] + left_u[15 : 8 ] +
                 top_u[23 : 16] + left_u[23 : 16] +
                 top_u[31 : 24] + left_u[31 : 24] +
                 top_u[39 : 32] + left_u[39 : 32] +
                 top_u[47 : 40] + left_u[47 : 40] +
                 top_u[55 : 48] + left_u[55 : 48] +
                 top_u[63 : 56] + left_u[63 : 56];

assign temp2_u = (temp1_u + BLOCK_SIZE) >> SHIFT;

assign temp1_v = top_v[7  : 0 ] + left_v[7  : 0 ] +
                 top_v[15 : 8 ] + left_v[15 : 8 ] +
                 top_v[23 : 16] + left_v[23 : 16] +
                 top_v[31 : 24] + left_v[31 : 24] +
                 top_v[39 : 32] + left_v[39 : 32] +
                 top_v[47 : 40] + left_v[47 : 40] +
                 top_v[55 : 48] + left_v[55 : 48] +
                 top_v[63 : 56] + left_v[63 : 56];

assign temp2_v = (temp1_v + BLOCK_SIZE) >> SHIFT;

Fill_UV U_Fill (
 .value_u       (temp2_u    )
,.value_v       (temp2_v    )
,.dst           (dst        )
);

endmodule
