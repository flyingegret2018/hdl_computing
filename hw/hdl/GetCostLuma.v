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

module GetCostLuma#(
 parameter BIT_WIDTH    = 16
,parameter BLOCK_SIZE   = 16
)(
 input                                                    clk
,input                                                    rst_n
,input                                                    start
,input      [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] ac
,input      [BIT_WIDTH * BLOCK_SIZE              - 1 : 0] dc
,output reg [32                                  - 1 : 0] sum
,output reg                                               done
);

(* max_fanout = "64" *)reg  [ 3         :0]count;
reg  [ 0         :0]shift;
reg  [31         :0]tmp[8:0];
wire [16 * 16 - 1:0]tmp_ac[15:0];
wire [16      - 1:0]tmp_dc[15:0];

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
    assign tmp_ac[i] = ac[16 * 16 * (i + 1) - 1 : 16 * 16 * i];
    assign tmp_dc[i] = dc[16 *      (i + 1) - 1 : 16      * i];
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
        tmp[8] <= 'b0;
    end
    else begin
        if(start | count != 'b0)begin
            tmp[0] <= $signed(tmp_ac[count][ 15:  0]) * $signed(tmp_ac[count][ 15:  0]) +
                      $signed(tmp_ac[count][ 31: 16]) * $signed(tmp_ac[count][ 31: 16]) +
                      $signed(tmp[0]);

            tmp[1] <= $signed(tmp_ac[count][ 47: 32]) * $signed(tmp_ac[count][ 47: 32]) +
                      $signed(tmp_ac[count][ 63: 48]) * $signed(tmp_ac[count][ 63: 48]) +
                      $signed(tmp[1]);

            tmp[2] <= $signed(tmp_ac[count][ 79: 64]) * $signed(tmp_ac[count][ 79: 64]) +
                      $signed(tmp_ac[count][ 95: 80]) * $signed(tmp_ac[count][ 95: 80]) +
                      $signed(tmp[2]);

            tmp[3] <= $signed(tmp_ac[count][111: 96]) * $signed(tmp_ac[count][111: 96]) +
                      $signed(tmp_ac[count][127:112]) * $signed(tmp_ac[count][127:112]) +
                      $signed(tmp[3]);

            tmp[4] <= $signed(tmp_ac[count][143:128]) * $signed(tmp_ac[count][143:128]) +
                      $signed(tmp_ac[count][159:144]) * $signed(tmp_ac[count][159:144]) +
                      $signed(tmp[4]);

            tmp[5] <= $signed(tmp_ac[count][175:160]) * $signed(tmp_ac[count][175:160]) +
                      $signed(tmp_ac[count][191:176]) * $signed(tmp_ac[count][191:176]) +
                      $signed(tmp[5]);

            tmp[6] <= $signed(tmp_ac[count][207:192]) * $signed(tmp_ac[count][207:192]) +
                      $signed(tmp_ac[count][223:208]) * $signed(tmp_ac[count][223:208]) +
                      $signed(tmp[6]);

            tmp[7] <= $signed(tmp_ac[count][239:224]) * $signed(tmp_ac[count][239:224]) +
                      $signed(tmp_ac[count][255:240]) * $signed(tmp_ac[count][255:240]) +
                      $signed(tmp[7]);

            tmp[8] <= $signed(tmp_dc[count]         ) * $signed(tmp_dc[count]         ) + 
                      $signed(tmp[8]);
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
            tmp[8] <= 'b0;
        end
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        sum <= 'b0;
    else
        if(shift)
            sum <= tmp[0] + tmp[1] + tmp[2] + tmp[3] + 
                   tmp[4] + tmp[5] + tmp[6] + tmp[7] + 
                   tmp[8];
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        done  <= 'b0;
        shift <= 'b0;
    end
    else begin
        shift <= count == 'hf;
        done  <= shift;
    end
end

endmodule
