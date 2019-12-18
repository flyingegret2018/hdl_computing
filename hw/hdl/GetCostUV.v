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

reg [2:0]count;
reg [7:0]shift;

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        done  <= 'b0;
        shift <= 'b0;
    end
    else begin
        shift[0]   <= start;
        shift[7:1] <= shift[6:0];
        done       <= shift[7];
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        count <= 'b0;
    else
        if(shift[0] | count != 'b0)
            count <= count + 1'b1;
end

wire [16 * 16 - 1:0]tmp[7:0];

genvar i;

generate

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    assign tmp[i] = levels[16 * 16 * (i + 1) - 1 : 16 * 16 * i];
end

endgenerate

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        sum <= 'b0;
    else
        if(start)
            sum <= 'b0;
        else if(shift[0] | count != 'b0)
            sum <= tmp[count][ 15:  0] * tmp[count][ 15:  0] +
                   tmp[count][ 31: 16] * tmp[count][ 31: 16] +
                   tmp[count][ 47: 32] * tmp[count][ 47: 32] +
                   tmp[count][ 63: 48] * tmp[count][ 63: 48] +
                   tmp[count][ 79: 64] * tmp[count][ 79: 64] +
                   tmp[count][ 95: 80] * tmp[count][ 95: 80] +
                   tmp[count][111: 96] * tmp[count][111: 96] +
                   tmp[count][127:112] * tmp[count][127:112] +
                   tmp[count][143:128] * tmp[count][143:128] +
                   tmp[count][159:144] * tmp[count][159:144] +
                   tmp[count][175:160] * tmp[count][175:160] +
                   tmp[count][191:176] * tmp[count][191:176] +
                   tmp[count][207:192] * tmp[count][207:192] +
                   tmp[count][223:208] * tmp[count][223:208] +
                   tmp[count][239:224] * tmp[count][239:224] +
                   tmp[count][255:240] * tmp[count][255:240] +
                   sum;
end

endmodule
