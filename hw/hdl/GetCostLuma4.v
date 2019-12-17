//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	GetCostLuma4.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-12-10 10:38
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module GetCostLuma4#(
 parameter BIT_WIDTH    = 16
,parameter BLOCK_SIZE   = 4
)(
 input                                                    clk
,input                                                    rst_n
,input                                                    start
,input      [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] levels
,output reg [32                                  - 1 : 0] sum
,output reg                                               done
);

reg [1:0]shift;

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        done  <= 'b0;
        shift <= 'b0;
    end
    else begin
        shift[0] <= start;
        done  <= shift[0];
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        sum <= 'b0;
    else
        if(start)
            sum <= 'b0;
        else if(shift[0])
            sum <= levels[ 15:  0] * levels[ 15:  0] +
                   levels[ 31: 16] * levels[ 31: 16] +
                   levels[ 47: 32] * levels[ 47: 32] +
                   levels[ 63: 48] * levels[ 63: 48] +
                   levels[ 79: 64] * levels[ 79: 64] +
                   levels[ 95: 80] * levels[ 95: 80] +
                   levels[111: 96] * levels[111: 96] +
                   levels[127:112] * levels[127:112] +
                   levels[143:128] * levels[143:128] +
                   levels[159:144] * levels[159:144] +
                   levels[175:160] * levels[175:160] +
                   levels[191:176] * levels[191:176] +
                   levels[207:192] * levels[207:192] +
                   levels[223:208] * levels[223:208] +
                   levels[239:224] * levels[239:224] +
                   levels[255:240] * levels[255:240];
end

endmodule
