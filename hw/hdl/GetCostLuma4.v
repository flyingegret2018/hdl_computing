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


always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        done  <= 'b0;
    end
    else begin
        done  <= start;
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        sum <= 'b0;
    else
        if(start)
            sum <= $signed(levels[ 15:  0]) * $signed(levels[ 15:  0]) +
                   $signed(levels[ 31: 16]) * $signed(levels[ 31: 16]) +
                   $signed(levels[ 47: 32]) * $signed(levels[ 47: 32]) +
                   $signed(levels[ 63: 48]) * $signed(levels[ 63: 48]) +
                   $signed(levels[ 79: 64]) * $signed(levels[ 79: 64]) +
                   $signed(levels[ 95: 80]) * $signed(levels[ 95: 80]) +
                   $signed(levels[111: 96]) * $signed(levels[111: 96]) +
                   $signed(levels[127:112]) * $signed(levels[127:112]) +
                   $signed(levels[143:128]) * $signed(levels[143:128]) +
                   $signed(levels[159:144]) * $signed(levels[159:144]) +
                   $signed(levels[175:160]) * $signed(levels[175:160]) +
                   $signed(levels[191:176]) * $signed(levels[191:176]) +
                   $signed(levels[207:192]) * $signed(levels[207:192]) +
                   $signed(levels[223:208]) * $signed(levels[223:208]) +
                   $signed(levels[239:224]) * $signed(levels[239:224]) +
                   $signed(levels[255:240]) * $signed(levels[255:240]);
end

endmodule
