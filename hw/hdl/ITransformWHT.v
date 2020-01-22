//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	ITransformWHT.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-20 16:48
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module ITransformWHT#(
 parameter BLOCK_SIZE   = 4
)(
 input                                             clk
,input                                             rst_n
,input                                             start
,input      [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] in
,output     [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] out
,output reg                                        done
);

wire signed [15 : 0]in_i [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
wire signed [17 : 0]tmp  [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
reg  signed [15 : 0]out_i[BLOCK_SIZE * BLOCK_SIZE - 1 : 0];

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
    assign in_i[i] = in   [16 * (i + 1) - 1 : 16 * i];
    assign out[16 * (i + 1) - 1 : 16 * i] = out_i[i];
end

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    wire signed [16 : 0] a0,a1,a2,a3;
    assign a0 = in_i[0 + i] + in_i[12 + i];
    assign a1 = in_i[4 + i] + in_i[ 8 + i];
    assign a2 = in_i[4 + i] - in_i[ 8 + i];
    assign a3 = in_i[0 + i] - in_i[12 + i];

    assign tmp[i +  0] = a0 + a1;
    assign tmp[i +  4] = a3 + a2;
    assign tmp[i +  8] = a0 - a1;
    assign tmp[i + 12] = a3 - a2;
    
    wire signed [19 : 0] b0,b1,b2,b3;
    assign b0 = tmp[BLOCK_SIZE * i + 0] + tmp[BLOCK_SIZE * i + 3] + 'd3;
    assign b1 = tmp[BLOCK_SIZE * i + 1] + tmp[BLOCK_SIZE * i + 2];
    assign b2 = tmp[BLOCK_SIZE * i + 1] - tmp[BLOCK_SIZE * i + 2];
    assign b3 = tmp[BLOCK_SIZE * i + 0] - tmp[BLOCK_SIZE * i + 3] + 'd3;
    
    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            out_i[BLOCK_SIZE * i + 0] <= 'd0;
            out_i[BLOCK_SIZE * i + 1] <= 'd0;
            out_i[BLOCK_SIZE * i + 2] <= 'd0;
            out_i[BLOCK_SIZE * i + 3] <= 'd0;
        end
        else begin
            out_i[BLOCK_SIZE * i + 0] <= (b0 + b1) >>> 3;
            out_i[BLOCK_SIZE * i + 1] <= (b3 + b2) >>> 3;
            out_i[BLOCK_SIZE * i + 2] <= (b0 - b1) >>> 3;
            out_i[BLOCK_SIZE * i + 3] <= (b3 - b2) >>> 3;
        end
    end
end

endgenerate

endmodule
