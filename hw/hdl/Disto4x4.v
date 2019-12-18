//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	Disto4x4.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-12-06 15:54
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module Disto4x4#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 4
)(
 input                                                    clk
,input                                                    rst_n
,input                                                    start
,input             [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] ina
,input             [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] inb
,input             [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] w
,output     signed [31                               : 0] sum
,output reg                                               done
);

wire signed[31:0]suma,sumb;

TTransform U_TT_A(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( start                         ),
    .in                             ( ina                           ),
    .w                              ( w                             ),
    .sum                            ( suma                          ),
    .done                           ( done                          )
);

TTransform U_TT_B(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( start                         ),
    .in                             ( inb                           ),
    .w                              ( w                             ),
    .sum                            ( sumb                          ),
    .done                           (                               )
);

wire signed[31:0]tmp;
wire [31:0]tmp1;

assign tmp = sumb - suma;
assign tmp1 = (tmp < 'b0) ? ('b0 - tmp) : tmp;
assign sum = tmp1 >> 5;

endmodule
