//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	FTransformWHT.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-20 14:37
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module FTransformWHT#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 4
)(
 input                                             clk
,input                                             rst_n
,input                                             start
,input      [12 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] in
,output     [15 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] out
,output reg                                        done
);

wire signed [11 : 0]in_i [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];//12b
wire signed [13 : 0]tmp  [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];//14b
reg  signed [14 : 0]out_i[BLOCK_SIZE * BLOCK_SIZE - 1 : 0];//15b


always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        done  <= 'b0;
    end
    else begin
        done  <= start;
    end
end

genvar i;

generate

for(i = 0; i < BLOCK_SIZE * BLOCK_SIZE; i = i + 1)begin
    assign in_i[i] = in   [12 * (i + 1) - 1 : (BIT_WIDTH + 4) * i];
    assign out [i] = out_i[15 * (i + 1) - 1 : (BIT_WIDTH + 7) * i];
end

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    wire signed [12 : 0] a0,a1,a2,a3;//13b
    assign a0 = in_i[BLOCK_SIZE * i + 0] + in_i[BLOCK_SIZE * i + 2];
    assign a1 = in_i[BLOCK_SIZE * i + 1] + in_i[BLOCK_SIZE * i + 3];
    assign a2 = in_i[BLOCK_SIZE * i + 1] - in_i[BLOCK_SIZE * i + 3];
    assign a3 = in_i[BLOCK_SIZE * i + 0] - in_i[BLOCK_SIZE * i + 2];

    assign tmp[BLOCK_SIZE * i + 0] = a0 + a1;
    assign tmp[BLOCK_SIZE * i + 1] = a3 + a2;
    assign tmp[BLOCK_SIZE * i + 2] = a3 - a2;
    assign tmp[BLOCK_SIZE * i + 3] = a0 - a1;
    
    wire signed [14 : 0] b0,b1,b2,b3;//15b
    assign b0 = tmp[0 + i] + tmp[ 8 + i];
    assign b1 = tmp[4 + i] + tmp[12 + i];
    assign b2 = tmp[4 + i] - tmp[12 + i];
    assign b3 = tmp[0 + i] - tmp[ 8 + i];
    
    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            out_i[i +  0] <= 'd0;
            out_i[i +  4] <= 'd0;
            out_i[i +  8] <= 'd0;
            out_i[i + 12] <= 'd0;
        end
        else begin
            out_i[i +  0] <= (b0 + b1) >> 1;
            out_i[i +  4] <= (b3 + b2) >> 1;
            out_i[i +  8] <= (b3 - b2) >> 1;
            out_i[i + 12] <= (b0 - b1) >> 1;
        end
    end
end

endgenerate

endmodule
