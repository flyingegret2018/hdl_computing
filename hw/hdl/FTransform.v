//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	FTransform.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-19 10:46
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module FTransform#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 4
)(
 input                                                          clk
,input                                                          rst_n
,input                                                          start
,input      [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]       src
,input      [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]       ref
,output     [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE * 2 - 1 : 0]   out
,output reg                                                     done
);

wire [BIT_WIDTH - 1 : 0] vals [9 : 0];

assign vals[0] = (left[ 7: 0] + top_left    + 1) >> 1;
assign vals[1] = (left[15: 8] + left[ 7: 0] + 1) >> 1;
assign vals[2] = (left[23:16] + left[15: 8] + 1) >> 1;
assign vals[3] = (left[31:24] + left[23:16] + 1) >> 1;

assgin vals[4] = (top [ 7: 0] + (top [15: 8] << 1) + top [23:16] + 2) >> 2;
assgin vals[5] = (top_left    + (top [ 7: 0] << 1) + top [15: 8] + 2) >> 2;
assgin vals[6] = (left[ 7: 0] + (top_left    << 1) + top [ 7: 0] + 2) >> 2;
assgin vals[7] = (left[15: 8] + (left[ 7: 0] << 1) + top_left    + 2) >> 2;
assgin vals[8] = (left[23:16] + (left[15: 8] << 1) + left[ 7: 0] + 2) >> 2;
assgin vals[9] = (left[31:24] + (left[23:16] << 1) + left[15: 8] + 2) >> 2;

assign dst [7  :0  ] = vals[0]; //00
assign dst [15 :8  ] = vals[6]; //01
assign dst [23 :16 ] = vals[5]; //02
assign dst [31 :24 ] = vals[4]; //03
assign dst [39 :32 ] = vals[1]; //04
assign dst [47 :40 ] = vals[7]; //05
assign dst [55 :48 ] = vals[0]; //06
assign dst [63 :56 ] = vals[6]; //07
assign dst [71 :64 ] = vals[2]; //08
assign dst [79 :72 ] = vals[8]; //09
assign dst [87 :80 ] = vals[1]; //10
assign dst [95 :88 ] = vals[7]; //11
assign dst [103:96 ] = vals[3]; //12
assign dst [111:104] = vals[9]; //13
assign dst [119:112] = vals[2]; //14
assign dst [127:120] = vals[8]; //15

endmodule
