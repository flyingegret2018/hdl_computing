//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	FTransform.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-19 10:46
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module FTransform#(
 parameter BLOCK_SIZE   = 4
)(
 input                                              clk
,input                                              rst_n
,input                                              start
,input      [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]  src
,input      [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]  ref
,output     [12 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]  out
,output reg                                         done
);

wire        [ 7 : 0]src_i[BLOCK_SIZE * BLOCK_SIZE - 1 : 0];//8b
wire        [ 7 : 0]ref_i[BLOCK_SIZE * BLOCK_SIZE - 1 : 0];//8b
reg  signed [13 : 0]tmp  [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];//14b
reg  signed [11 : 0]out_i[BLOCK_SIZE * BLOCK_SIZE - 1 : 0];//12b

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
    assign src_i[i] = src  [ 8 * (i + 1) - 1 :  8 * i];
    assign ref_i[i] = ref  [ 8 * (i + 1) - 1 :  8 * i];
    assign out[12 * (i + 1) - 1 : 12 * i] = out_i[i];
end

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    wire signed [8 : 0] d0,d1,d2,d3;//9b
    assign d0 = src_i[BLOCK_SIZE * i + 0] - ref_i[BLOCK_SIZE * i + 0];
    assign d1 = src_i[BLOCK_SIZE * i + 1] - ref_i[BLOCK_SIZE * i + 1];
    assign d2 = src_i[BLOCK_SIZE * i + 2] - ref_i[BLOCK_SIZE * i + 2];
    assign d3 = src_i[BLOCK_SIZE * i + 3] - ref_i[BLOCK_SIZE * i + 3];

    wire signed [9 : 0] a0,a1,a2,a3;//10b
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
    
    wire signed [14 : 0] b0,b1,b2,b3;//15b
    assign b0 = tmp[i + 0] + tmp[i + 12];
    assign b1 = tmp[i + 4] + tmp[i +  8];
    assign b2 = tmp[i + 4] - tmp[i +  8];
    assign b3 = tmp[i + 0] - tmp[i + 12];
    
    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            out_i[i +  0] <= 'd0;
            out_i[i +  4] <= 'd0;
            out_i[i +  8] <= 'd0;
            out_i[i + 12] <= 'd0;
        end
        else begin
            out_i[i +  0] <= (b0 + b1 + 7) >>> 4;
            out_i[i +  4] <= ((b2 * 'd2217 + b3 * 'd5352 + 'd12000) >>> 16) + (b3 != 0);
            out_i[i +  8] <= (b0 - b1 + 7) >>> 4;
            out_i[i + 12] <= (b3 * 'd2217 - b2 * 'd5352 + 'd51000) >>> 16;
        end
    end
end

endgenerate

endmodule
