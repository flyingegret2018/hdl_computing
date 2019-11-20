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
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 4
)(
 input                                                          clk
,input                                                          rst_n
,input                                                          start
,input      [(BIT_WIDTH + 8) * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] in
,output     [(BIT_WIDTH + 8) * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] out
,output reg                                                     done
);

reg signed [BIT_WIDTH + 5 : 0]tmp  [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];//14b
reg signed [BIT_WIDTH + 8 : 0]in_i [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];//12b
reg signed [BIT_WIDTH + 8 : 0]out_i[BLOCK_SIZE * BLOCK_SIZE - 1 : 0];//15b


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
    assign in_i[i] = in   [(BIT_WIDTH + 8) * (i + 1) - 1 : (BIT_WIDTH + 8) * i];
    assign out [i] = out_i[(BIT_WIDTH + 8) * (i + 1) - 1 : (BIT_WIDTH + 8) * i];
end

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    wire signed [BIT_WIDTH + 4 : 0] a0,a1,a2,a3;//13b
    assign a0 = in_i[BLOCK_SIZE * i + 0] + in_i[BLOCK_SIZE * i + 2];
    assign a1 = in_i[BLOCK_SIZE * i + 1] + in_i[BLOCK_SIZE * i + 3];
    assign a2 = in_i[BLOCK_SIZE * i + 1] - in_i[BLOCK_SIZE * i + 3];
    assign a3 = in_i[BLOCK_SIZE * i + 0] - in_i[BLOCK_SIZE * i + 2];

    assign tmp[BLOCK_SIZE * i + 0] = a0 + a1;
    assign tmp[BLOCK_SIZE * i + 1] = a3 + a2;
    assign tmp[BLOCK_SIZE * i + 2] = a3 - a2;
    assign tmp[BLOCK_SIZE * i + 3] = a0 - a1;
    
    wire signed [BIT_WIDTH + 6 : 0] b0,b1,b2,b3;//15b
    assign b0 = tmp[0 + i] + tmp[ 8 + i];
    assign b1 = tmp[4 + i] + tmp[12 + i];
    assign b2 = tmp[4 + i] - tmp[12 + i];
    assign b3 = tmp[0 + i] - tmp[ 8 + i];
    
    wire signed [BIT_WIDTH + 7 : 0] c0,c1,c2,c3;//16b
    assign c0 = b0 + b1;
    assign c1 = b3 + b2;
    assign c2 = b3 - b2;
    assign c3 = b0 - b1;
    
    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            out_i[i +  0] <= 'd0;
            out_i[i +  4] <= 'd0;
            out_i[i +  8] <= 'd0;
            out_i[i + 12] <= 'd0;
        end
        else begin
            out_i[i +  0] <= c0 >> 1;
            out_i[i +  4] <= c1 >> 1;
            out_i[i +  8] <= c2 >> 1;
            out_i[i + 12] <= c3 >> 1;
        end
    end
end

endgenerate

endmodule
