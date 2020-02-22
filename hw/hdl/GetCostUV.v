//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	GetCostLuma.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-12-09 11:39
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module GetCostUV#(
 parameter BIT_WIDTH    = 16
,parameter BLOCK_SIZE   = 8
)(
 input                                            clk
,input                                            rst_n
,input                                            start
,input      [BIT_WIDTH * 16 * BLOCK_SIZE - 1 : 0] levels
,output reg [32                          - 1 : 0] sum
,output reg                                       done
);

(* max_fanout = "64" *)reg  [2          :0]count;
reg  [0          :0]shift;
wire [16 * 16 - 1:0]level[7:0];
reg  [31         :0]tmp[7:0];

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        count <= 'b0;
    else
        if(start | count != 'b0)
            count <= count + 1'b1;
end

genvar i;

generate

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    assign level[i] = levels[16 * 16 * (i + 1) - 1 : 16 * 16 * i];
end

endgenerate

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
        if(start | count != 'b0)begin
            tmp[0] <= $signed(level[count][ 15:  0]) * $signed(level[count][ 15:  0]) +
                      $signed(level[count][ 31: 16]) * $signed(level[count][ 31: 16]) +
                      $signed(tmp[0]);

            tmp[1] <= $signed(level[count][ 47: 32]) * $signed(level[count][ 47: 32]) +
                      $signed(level[count][ 63: 48]) * $signed(level[count][ 63: 48]) +
                      $signed(tmp[1]);

            tmp[2] <= $signed(level[count][ 79: 64]) * $signed(level[count][ 79: 64]) +
                      $signed(level[count][ 95: 80]) * $signed(level[count][ 95: 80]) +
                      $signed(tmp[2]);

            tmp[3] <= $signed(level[count][111: 96]) * $signed(level[count][111: 96]) +
                      $signed(level[count][127:112]) * $signed(level[count][127:112]) +
                      $signed(tmp[3]);

            tmp[4] <= $signed(level[count][143:128]) * $signed(level[count][143:128]) +
                      $signed(level[count][159:144]) * $signed(level[count][159:144]) +
                      $signed(tmp[4]);

            tmp[5] <= $signed(level[count][175:160]) * $signed(level[count][175:160]) +
                      $signed(level[count][191:176]) * $signed(level[count][191:176]) +
                      $signed(tmp[5]);

            tmp[6] <= $signed(level[count][207:192]) * $signed(level[count][207:192]) +
                      $signed(level[count][223:208]) * $signed(level[count][223:208]) +
                      $signed(tmp[6]);

            tmp[7] <= $signed(level[count][239:224]) * $signed(level[count][239:224]) +
                      $signed(level[count][255:240]) * $signed(level[count][255:240]) +
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
        shift <= count == 'h7;
        done  <= shift;
    end
end

endmodule
