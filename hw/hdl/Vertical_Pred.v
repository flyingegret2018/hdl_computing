//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	Vertical_Pred.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-16 11:11
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module Vertical_Pred#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 16
)(
 input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]                top
,output     [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]   dst
);

genvar i,j;

generate

for(j = 0; j < BLOCK_SIZE; j = j + 1)begin
    for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
        assign dst[(j * BLOCK_SIZE + i) * BIT_WIDTH + 7 : (j * BLOCK_SIZE + i) * BIT_WIDTH] = 
            top[i * BIT_WIDTH + 7 : i * BIT_WIDTH];
    end
end

endgenerate

endmodule
