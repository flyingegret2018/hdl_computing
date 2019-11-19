//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	VR4.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-17 15:49
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module VR4#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 4
)(
 input      [BIT_WIDTH - 1 : 0]                             top_left
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]                top
,input      [BIT_WIDTH * (BLOCK_SIZE - 1) - 1 : 0]          left
,output     [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]   dst
);

wire [BIT_WIDTH - 1 : 0] vals [9 : 0];

assign vals[0] = (top_left   + top[ 7: 0] + 1) >> 1;
assign vals[1] = (top[ 7: 0] + top[15: 8] + 1) >> 1;
assign vals[2] = (top[15: 8] + top[23:16] + 1) >> 1;
assign vals[3] = (top[23:16] + top[31:24] + 1) >> 1;

assgin vals[4] = (left[23:16] + (left[15: 8] << 1) + left[ 7: 0] + 2) >> 2;
assgin vals[5] = (left[15: 8] + (left[ 7: 0] << 1) + top_left    + 2) >> 2;
assgin vals[6] = (left[ 7: 0] + (top_left    << 1) + top [ 7: 0] + 2) >> 2;
assgin vals[7] = (top_left    + (top [ 7: 0] << 1) + top [15: 8] + 2) >> 2;
assgin vals[8] = (top [ 7: 0] + (top [15: 8] << 1) + top [23:16] + 2) >> 2;
assgin vals[9] = (top [15: 8] + (top [23:16] << 1) + top [31:24] + 2) >> 2;

assign dst [7  :0  ] = vals[0]; //00
assign dst [15 :8  ] = vals[1]; //01
assign dst [23 :16 ] = vals[2]; //02
assign dst [31 :24 ] = vals[3]; //03
assign dst [39 :32 ] = vals[6]; //04
assign dst [47 :40 ] = vals[7]; //05
assign dst [55 :48 ] = vals[8]; //06
assign dst [63 :56 ] = vals[9]; //07
assign dst [71 :64 ] = vals[5]; //08
assign dst [79 :72 ] = vals[0]; //09
assign dst [87 :80 ] = vals[1]; //10
assign dst [95 :88 ] = vals[2]; //11
assign dst [103:96 ] = vals[4]; //12
assign dst [111:104] = vals[6]; //13
assign dst [119:112] = vals[7]; //14
assign dst [127:120] = vals[8]; //15

endmodule
