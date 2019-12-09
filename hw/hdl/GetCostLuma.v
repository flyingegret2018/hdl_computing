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

reg [3:0]count;
reg [15:0]shift;

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        done  <= 'b0;
        shift <= 'b0;
    else
        shift[0] <= start;
        shift[15:1] <= shift[14:0];
        done  <= shift[15];
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        count <= 'b0;
    else
        if(shift[0] | count != 'b0)
            count <= count + 1'b1;
end

wire [16 * 16 - 1:0]tmp_ac[15:0];
wire [16      - 1:0]tmp_dc[15:0];

genvar i;

generate

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    assign tmp_ac[i] = ac[16 * 16 * (i + 1) - 1 : 16 * 16 * i];
    assign tmp_dc[i] = dc[16 *      (i + 1) - 1 : 16      * i];
end

endgenerate

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        sum <= 'b0;
    else
        if(start)
            sum <= 'b0;
        else if(shift[0] | count != 'b0)
            sum <= tmp_ac[count][ 15:  0] * tmp_ac[count][ 15:  0] +
                   tmp_ac[count][ 31: 16] * tmp_ac[count][ 31: 16] +
                   tmp_ac[count][ 47: 32] * tmp_ac[count][ 47: 32] +
                   tmp_ac[count][ 63: 48] * tmp_ac[count][ 63: 48] +
                   tmp_ac[count][ 79: 64] * tmp_ac[count][ 79: 64] +
                   tmp_ac[count][ 95: 80] * tmp_ac[count][ 95: 80] +
                   tmp_ac[count][111: 96] * tmp_ac[count][111: 96] +
                   tmp_ac[count][127:112] * tmp_ac[count][127:112] +
                   tmp_ac[count][143:128] * tmp_ac[count][143:128] +
                   tmp_ac[count][159:144] * tmp_ac[count][159:144] +
                   tmp_ac[count][175:160] * tmp_ac[count][175:160] +
                   tmp_ac[count][191:176] * tmp_ac[count][191:176] +
                   tmp_ac[count][207:192] * tmp_ac[count][207:192] +
                   tmp_ac[count][223:208] * tmp_ac[count][223:208] +
                   tmp_ac[count][239:224] * tmp_ac[count][239:224] +
                   tmp_ac[count][255:240] * tmp_ac[count][255:240] +
                   tmp_dc[count] * tmp_dc[count] + sum;
end

endmodule
