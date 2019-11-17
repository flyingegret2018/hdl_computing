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
 input      [BIT_WIDTH - 1 : 0]                         top_left_v
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            top_u
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            top_v
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            left_u
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            left_v
,output     [BIT_WIDTH * BLOCK_SIZE * UV_SIZE-1 : 0]    dst
);

genvar i,j;

generate

wire signed [BIT_WIDTH + 1 : 0] temp_u;
wire signed [BIT_WIDTH + 1 : 0] temp_v;

for(j = 0; j < BLOCK_SIZE; j = j + 1)begin
    for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
        assign temp_u = top_u[i] + left_u[j] - top_left;
        assign dst[(j * BLOCK_SIZE + i) * BIT_WIDTH + 7 : (j * BLOCK_SIZE + i) * BIT_WIDTH] = 
            (temp > 'hff) ? 'hff : (temp < 'h0) ? 'h0 : temp;
    end
end

endgenerate

endmodule
