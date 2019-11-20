//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	ITransform.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-20 16:48
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module ITransform#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 4
)(
 input                                                          clk
,input                                                          rst_n
,input                                                          start
,input      [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]       src
,input      [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]       ref
,output     [(BIT_WIDTH + 4) * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] out
,output reg                                                     done
);

reg signed [BIT_WIDTH + 5 : 0]tmp  [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];//14b
reg        [BIT_WIDTH - 1 : 0]src_i[BLOCK_SIZE * BLOCK_SIZE - 1 : 0];//8b
reg        [BIT_WIDTH - 1 : 0]ref_i[BLOCK_SIZE * BLOCK_SIZE - 1 : 0];//8b
reg signed [BIT_WIDTH + 3 : 0]out_i[BLOCK_SIZE * BLOCK_SIZE - 1 : 0];//12b

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
    assign src_i[i] = src[BIT_WIDTH * (i + 1) - 1 : BIT_WIDTH * i];
    assign ref_i[i] = ref[BIT_WIDTH * (i + 1) - 1 : BIT_WIDTH * i];
    assign out[i] = out_i[(BIT_WIDTH + 4) * (i + 1) - 1 : (BIT_WIDTH + 4) * i];
end

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    wire signed [BIT_WIDTH : 0] d0,d1,d2,d3;//9b
    assign d0 = src_i[BLOCK_SIZE * i + 0] - ref_i[BLOCK_SIZE * i + 0];
    assign d1 = src_i[BLOCK_SIZE * i + 1] - ref_i[BLOCK_SIZE * i + 1];
    assign d2 = src_i[BLOCK_SIZE * i + 2] - ref_i[BLOCK_SIZE * i + 2];
    assign d3 = src_i[BLOCK_SIZE * i + 3] - ref_i[BLOCK_SIZE * i + 3];

    wire signed [BIT_WIDTH + 1 : 0] a0,a1,a2,a3;//10b
    assign a0 = d0 + d3;
    assign a1 = d1 + d2;
    assign a2 = d1 - d2;
    assign a3 = d0 - d3;
    
    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            tmp[BLOCK_SIZE * i + 0] <= 'd0;
            tmp[BLOCK_SIZE * i + 1] <= 'd0;
            tmp[BLOCK_SIZE * i + 2] <= 'd0;
            tmp[BLOCK_SIZE * i + 3] <= 'd0;
        end
        else begin
            tmp[BLOCK_SIZE * i + 0] <= (a0 + a1) * 8;
            tmp[BLOCK_SIZE * i + 1] <= (a2 * 'd2217 + a3 * 'd5352 + 'd1812) >> 9;
            tmp[BLOCK_SIZE * i + 2] <= (a0 - a1) * 8;
            tmp[BLOCK_SIZE * i + 3] <= (a3 * 'd2217 - a2 * 'd5352 + 'd937) >> 9;
        end
    end
    
    wire signed [BIT_WIDTH + 6 : 0] b0,b1,b2,b3;//15b
    assign b0 = tmp[0 + i] + tmp[12 + i];
    assign b1 = tmp[4 + i] + tmp[ 8 + i];
    assign b2 = tmp[4 + i] - tmp[ 8 + i];
    assign b3 = tmp[0 + i] - tmp[12 + i];
    
    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            out_i[i +  0] <= 'd0;
            out_i[i +  4] <= 'd0;
            out_i[i +  8] <= 'd0;
            out_i[i + 12] <= 'd0;
        end
        else begin
            out_i[i +  0] <= (b0 + b1 + 7) >> 4;
            out_i[i +  4] <= (b2 * 'd2217 + b3 * 'd5352 + 'd12000) >> 16 + (b3 != 0);
            out_i[i +  8] <= (b0 - b1 + 7) >> 4;
            out_i[i + 12] <= (b3 * 'd2217 - b2 * 'd5352 + 'd51000) >> 16;
        end
    end
end

endgenerate

endmodule
