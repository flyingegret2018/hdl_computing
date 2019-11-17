//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	Horizontal_Pred.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-16 11:11
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module Horizontal_Pred_UV#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 8
,parameter UV_SIZE      = 16
)(
 input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            left_u
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            left_v
,output     [BIT_WIDTH * BLOCK_SIZE * UV_SIZE - 1 : 0]  dst
);

genvar i,j;

generate

for(j = 0; j < BLOCK_SIZE; j = j + 1)begin
    for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
        assign dst[(j * UV_SIZE + i) * BIT_WIDTH + 7 : (j * UV_SIZE + i) * BIT_WIDTH] = 
            left_u[j * BIT_WIDTH + 7 : j * BIT_WIDTH];
        assign dst[(j * UV_SIZE + i + 8) * BIT_WIDTH + 7 : (j * UV_SIZE + i + 8) * BIT_WIDTH] = 
            left_v[j * BIT_WIDTH + 7 : j * BIT_WIDTH];
    end
end

endgenerate

endmodule
