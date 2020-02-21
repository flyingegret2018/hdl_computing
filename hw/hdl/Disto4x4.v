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
 input                                             clk
,input                                             rst_n
,input                                             start
,input      [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] ina
,input      [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] inb
,input      [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] w
,output reg [31                               : 0] sum
,output reg                                        done
);

wire [31:0]suma,sumb;
wire [31:0]tmp;
reg  [ 1:0]shift;

TTransform U_TT_A(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .in                             ( ina                           ),
    .w                              ( w                             ),
    .sum                            ( suma                          ),
);

TTransform U_TT_B(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .in                             ( inb                           ),
    .w                              ( w                             ),
    .sum                            ( sumb                          ),
);

assign tmp = (sumb > suma) ? (sumb - suma) : (suma - sumb);

always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        sum <= 'b0;
    end
    else begin
        if(shift[1])
            sum <= tmp >> 5;
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        done  <= 'b0;
        shift <= 'b0;
    end
    else begin
        shift[0] <= start;
        shift[1] <= shift[0];
        done     <= shift[1];
    end
end

endmodule
