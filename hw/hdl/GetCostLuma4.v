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

reg [ 0:0]shift;
reg [31:0]tmp[7:0];

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        tmp[0] <= 'b0;
        tmp[1] <= 'b0;
        tmp[2] <= 'b0;
        tmp[3] <= 'b0;
        tmp[4] <= 'b0;
        tmp[5] <= 'b0;
        tmp[6] <= 'b0;
        tmp[7] <= 'b0;
    end
    else begin
        if(start)begin
            tmp[0] <= $signed(levels[ 15:  0]) * $signed(levels[ 15:  0]) +
                      $signed(levels[ 31: 16]) * $signed(levels[ 31: 16]) +
                      $signed(tmp[0]);

            tmp[1] <= $signed(levels[ 47: 32]) * $signed(levels[ 47: 32]) +
                      $signed(levels[ 63: 48]) * $signed(levels[ 63: 48]) +
                      $signed(tmp[1]);

            tmp[2] <= $signed(levels[ 79: 64]) * $signed(levels[ 79: 64]) +
                      $signed(levels[ 95: 80]) * $signed(levels[ 95: 80]) +
                      $signed(tmp[2]);

            tmp[3] <= $signed(levels[111: 96]) * $signed(levels[111: 96]) +
                      $signed(levels[127:112]) * $signed(levels[127:112]) +
                      $signed(tmp[3]);

            tmp[4] <= $signed(levels[143:128]) * $signed(levels[143:128]) +
                      $signed(levels[159:144]) * $signed(levels[159:144]) +
                      $signed(tmp[4]);

            tmp[5] <= $signed(levels[175:160]) * $signed(levels[175:160]) +
                      $signed(levels[191:176]) * $signed(levels[191:176]) +
                      $signed(tmp[5]);

            tmp[6] <= $signed(levels[207:192]) * $signed(levels[207:192]) +
                      $signed(levels[223:208]) * $signed(levels[223:208]) +
                      $signed(tmp[6]);

            tmp[7] <= $signed(levels[239:224]) * $signed(levels[239:224]) +
                      $signed(levels[255:240]) * $signed(levels[255:240]) +
                      $signed(tmp[7]);
        end
        else begin
            tmp[0] <= 'b0;
            tmp[1] <= 'b0;
            tmp[2] <= 'b0;
            tmp[3] <= 'b0;
            tmp[4] <= 'b0;
            tmp[5] <= 'b0;
            tmp[6] <= 'b0;
            tmp[7] <= 'b0;
        end
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        sum <= 'b0;
    else
        if(shift)
            sum <= tmp[0] + tmp[1] + tmp[2] + tmp[3] + 
                   tmp[4] + tmp[5] + tmp[6] + tmp[7];
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        done  <= 'b0;
        shift <= 'b0;
    end
    else begin
        shift <= start;
        done  <= shift;
    end
end

endmodule
