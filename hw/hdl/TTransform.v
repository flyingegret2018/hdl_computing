//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	TTransform.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-12-06 14:20
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module TTransform#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 4
)(
 input                                                    clk
,input                                                    rst_n
,input                                                    start
,input             [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] in
,input             [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] w
,output reg signed [31                               : 0] sum
,output reg                                               done
);

wire        [ 7 : 0]in_i [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
wire signed [10 : 0]tmp  [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
wire signed [12 : 0]tmp1 [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
reg  signed [12 : 0]tmp2 [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
wire signed [15 : 0]w_i  [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];

reg shift;
always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        done  <= 'b0;
        shift <= 'b0;
    end
    else begin
        shift <= start;
        done  <= shift;
    end
end

genvar i;

generate

for(i = 0; i < BLOCK_SIZE * BLOCK_SIZE; i = i + 1)begin
    assign in_i[i] = in   [ 8 * (i + 1) - 1 :  8 * i];
    assign w_i [i] = w    [16 * (i + 1) - 1 : 16 * i];

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)
            tmp2[i] <= 'b0;
        else
            tmp2[i] <= tmp1[i][12] ? (~tmp1[i] + 1'b1) : tmp1[i];
    end
end

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    wire signed [9 : 0] a0,a1,a2,a3;
    assign a0 = in_i[BLOCK_SIZE * i + 0] + in_i[BLOCK_SIZE * i + 2];
    assign a1 = in_i[BLOCK_SIZE * i + 1] + in_i[BLOCK_SIZE * i + 3];
    assign a2 = in_i[BLOCK_SIZE * i + 1] - in_i[BLOCK_SIZE * i + 3];
    assign a3 = in_i[BLOCK_SIZE * i + 0] - in_i[BLOCK_SIZE * i + 2];

    assign tmp[BLOCK_SIZE * i + 0] = a0 + a1;
    assign tmp[BLOCK_SIZE * i + 1] = a3 + a2;
    assign tmp[BLOCK_SIZE * i + 2] = a3 - a2;
    assign tmp[BLOCK_SIZE * i + 3] = a0 - a1;
    
    wire signed [11 : 0] b0,b1,b2,b3;
    assign b0 = tmp[0 + i] + tmp[ 8 + i];
    assign b1 = tmp[4 + i] + tmp[12 + i];
    assign b2 = tmp[4 + i] - tmp[12 + i];
    assign b3 = tmp[0 + i] - tmp[ 8 + i];

    assign tmp1[i +  0] = b0 + b1;
    assign tmp1[i +  4] = b3 + b2;
    assign tmp1[i +  8] = b3 - b2;
    assign tmp1[i + 12] = b0 - b1;
end

endgenerate

always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        sum <= 'b0;
    end
    else begin
        sum <= tmp2[ 0] * w_i[ 0] + tmp2[ 1] * w_i[ 1] + 
               tmp2[ 2] * w_i[ 2] + tmp2[ 3] * w_i[ 3] + 
               tmp2[ 4] * w_i[ 4] + tmp2[ 5] * w_i[ 5] + 
               tmp2[ 6] * w_i[ 6] + tmp2[ 7] * w_i[ 7] + 
               tmp2[ 8] * w_i[ 8] + tmp2[ 9] * w_i[ 9] + 
               tmp2[10] * w_i[10] + tmp2[11] * w_i[11] + 
               tmp2[12] * w_i[12] + tmp2[13] * w_i[13] + 
               tmp2[14] * w_i[14] + tmp2[15] * w_i[15];
    end
end

endmodule
