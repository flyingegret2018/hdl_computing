//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	HU4.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-19 10:42
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module HU4#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 4
)(
 input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]                left
,output     [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]   dst
);

wire [BIT_WIDTH - 1 : 0] vals [6 : 0];

assign vals[0] = (left[ 7: 0] + left[15: 8] + 1) >> 1;
assign vals[1] = (left[15: 8] + left[23:16] + 1) >> 1;
assign vals[2] = (left[23:16] + left[31:24] + 1) >> 1;

assign vals[3] = (left[ 7: 0] + (left[15: 8] << 1) + left[23:16] + 2) >> 2;
assign vals[4] = (left[15: 8] + (left[23:16] << 1) + left[31:24] + 2) >> 2;
assign vals[5] = (left[23:16] + (left[31:24] << 1) + left[31:24] + 2) >> 2;

assign vals[6] = left[31:24];

assign dst [7  :0  ] = vals[0]; //00
assign dst [15 :8  ] = vals[3]; //01
assign dst [23 :16 ] = vals[1]; //02
assign dst [31 :24 ] = vals[4]; //03
assign dst [39 :32 ] = vals[1]; //04
assign dst [47 :40 ] = vals[4]; //05
assign dst [55 :48 ] = vals[2]; //06
assign dst [63 :56 ] = vals[5]; //07
assign dst [71 :64 ] = vals[2]; //08
assign dst [79 :72 ] = vals[5]; //09
assign dst [87 :80 ] = vals[6]; //10
assign dst [95 :88 ] = vals[6]; //11
assign dst [103:96 ] = vals[6]; //12
assign dst [111:104] = vals[6]; //13
assign dst [119:112] = vals[6]; //14
assign dst [127:120] = vals[6]; //15

endmodule
