//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	HE4.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-17 14:28
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module HE4#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 4
)(
 input      [BIT_WIDTH - 1 : 0]                             top_left
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]                left
,output     [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]   dst
);

wire [BIT_WIDTH - 1 : 0] vals [BLOCK_SIZE - 1 : 0];

assign vals[0] = (top_left    + {left[ 7: 0],1'b0} + left[15: 8] + 2) >> 2;
assign vals[1] = (left[ 7: 0] + {left[15: 8],1'b0} + left[23:16] + 2) >> 2;
assign vals[2] = (left[15: 8] + {left[23:16],1'b0} + left[31:24] + 2) >> 2;
assign vals[3] = (left[23:16] + {left[31:24],1'b0} + left[31:24] + 2) >> 2;

genvar i,j;

generate

for(j = 0; j < BLOCK_SIZE; j = j + 1)begin
    for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
        assign dst[(j * BLOCK_SIZE + i) * BIT_WIDTH + 7 : (j * BLOCK_SIZE + i) * BIT_WIDTH] = vals[j];
    end
end

endgenerate

endmodule
