//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	True_Motion_Pred.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-16 11:09
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module True_Motion_Pred_UV#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 8
,parameter UV_SIZE      = 16
)(
 input      [BIT_WIDTH - 1 : 0]                         top_left_u
,input      [BIT_WIDTH - 1 : 0]                         top_left_v
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            top_u
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            top_v
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            left_u
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            left_v
,output     [BIT_WIDTH * BLOCK_SIZE * UV_SIZE-1 : 0]    dst
);

genvar i,j;

generate

for(j = 0; j < BLOCK_SIZE; j = j + 1)begin
    for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
        wire signed [BIT_WIDTH + 1 : 0] temp_u;
        wire signed [BIT_WIDTH + 1 : 0] temp_v;
        assign temp_u = top_u[i * BIT_WIDTH + 7 : i * BIT_WIDTH] + 
            left_u[j * BIT_WIDTH + 7 : j * BIT_WIDTH] - top_left_u;
        assign temp_v = top_v[i * BIT_WIDTH + 7 : i * BIT_WIDTH] + 
            left_v[j * BIT_WIDTH + 7 : j * BIT_WIDTH] - top_left_v;
        assign dst[(j * UV_SIZE + i) * BIT_WIDTH + 7 : (j * UV_SIZE + i) * BIT_WIDTH] = 
            (temp_u > 'hff) ? 'hff : (temp_u < 'h0) ? 'h0 : temp_u;
        assign dst[(j * UV_SIZE + i + 8) * BIT_WIDTH + 7 : (j * UV_SIZE + i + 8) * BIT_WIDTH] = 
            (temp_v > 'hff) ? 'hff : (temp_v < 'h0) ? 'h0 : temp_v;
    end
end

endgenerate

endmodule
