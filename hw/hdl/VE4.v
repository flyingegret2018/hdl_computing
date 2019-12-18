//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	VE4.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-17 14:22
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module VE4#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 4
)(
 input      [BIT_WIDTH - 1 : 0]                             top_left
,input      [BIT_WIDTH - 1 : 0]                             top_right
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]                top
,output     [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]   dst
);

wire [BIT_WIDTH - 1 : 0] vals [BLOCK_SIZE - 1 : 0];

assign vals[0] = (top_left   + (top[ 7: 0] << 1) + top[15: 8] + 2) >> 2;
assign vals[1] = (top[ 7: 0] + (top[15: 8] << 1) + top[23:16] + 2) >> 2;
assign vals[2] = (top[15: 8] + (top[23:16] << 1) + top[31:24] + 2) >> 2;
assign vals[3] = (top[23:16] + (top[31:24] << 1) + top_right  + 2) >> 2;

genvar i,j;

generate

for(j = 0; j < BLOCK_SIZE; j = j + 1)begin
    for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
        assign dst[(j * BLOCK_SIZE + i) * BIT_WIDTH + 7 : (j * BLOCK_SIZE + i) * BIT_WIDTH] = vals[i];
    end
end

endgenerate

endmodule
