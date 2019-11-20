//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	TM4.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-19 10:42
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module TM4#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 4
)(
 input      [BIT_WIDTH - 1 : 0]                         top_left
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            top
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            left
,output     [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE-1 : 0] dst
);

genvar i,j;

generate

for(j = 0; j < BLOCK_SIZE; j = j + 1)begin
    for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
        wire signed [BIT_WIDTH + 1 : 0] temp;
        assign temp = top[i * BIT_WIDTH + 7 : i * BIT_WIDTH] + 
            left[j * BIT_WIDTH + 7 : j * BIT_WIDTH] - top_left;
        assign dst[(j * BLOCK_SIZE + i) * BIT_WIDTH + 7 : (j * BLOCK_SIZE + i) * BIT_WIDTH] = 
            (temp > 'hff) ? 'hff : (temp < 'h0) ? 'h0 : temp;
    end
end

endgenerate

endmodule
