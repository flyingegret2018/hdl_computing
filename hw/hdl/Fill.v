//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	Fill.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-16 11:10
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module Fill#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 16
)(
 input      [BIT_WIDTH - 1 : 0]                             value
,output     [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]   dst
);

genvar i;

generate

for(i = 0; i < BLOCK_SIZE * BLOCK_SIZE; i = i + 1)begin
    assign dst[i * BIT_WIDTH + 7 : i * BIT_WIDTH] = value;
end

endgenerate

endmodule
