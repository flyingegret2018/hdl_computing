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
 parameter BLOCK_SIZE   = 4
)(
 input                                             clk
,input                                             rst_n
,input                                             start
,input      [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] src
,input      [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] ref
,output     [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] out
,output reg                                        done
);

wire signed [15 : 0]src_i[BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
wire        [ 8 : 0]ref_i[BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
reg         [ 8 : 0]out_i[BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
reg  signed [18 : 0]tmp  [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];

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
    assign src_i[i] = src  [16 * (i + 1) - 1 : 16 * i];
    assign ref_i[i] = ref  [ 8 * (i + 1) - 1 :  8 * i];
    assign out[ 8 * (i + 1) - 1 :  8 * i] = out_i[i];
end

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    wire signed [17 : 0] a0,a1,a2,a3;
    assign a0 = src_i[i + 0] + src_i[i + 8];
    assign a1 = src_i[i + 0] - src_i[i + 8];
    assign a2 = (src_i[i + 4] * 'd35468 >>> 16) - (src_i[i + 12] * 'd85627 >>> 16);
    assign a3 = (src_i[i + 4] * 'd85627 >>> 16) + (src_i[i + 12] * 'd35468 >>> 16);

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            tmp[BLOCK_SIZE * i + 0] <= 'd0;
            tmp[BLOCK_SIZE * i + 1] <= 'd0;
            tmp[BLOCK_SIZE * i + 2] <= 'd0;
            tmp[BLOCK_SIZE * i + 3] <= 'd0;
        end
        else begin
            tmp[BLOCK_SIZE * i + 0] <= a0 + a3;
            tmp[BLOCK_SIZE * i + 1] <= a1 + a2;
            tmp[BLOCK_SIZE * i + 2] <= a1 - a2;
            tmp[BLOCK_SIZE * i + 3] <= a0 - a3;
        end
    end
    
    wire signed [20 : 0] b0,b1,b2,b3;
    assign b0 = tmp[i + 0] + tmp[i + 8] + 'd4;
    assign b1 = tmp[i + 0] - tmp[i + 8] + 'd4;
    assign b2 = (tmp[i + 4] * 'd35468 >>> 16) - (tmp[i + 12] * 'd85627 >>> 16);
    assign b3 = (tmp[i + 4] * 'd85627 >>> 16) + (tmp[i + 12] * 'd35468 >>> 16);
    
    wire signed [18 : 0] c0,c1,c2,c3;
    assign c0 = ref_i[BLOCK_SIZE * i + 0] + (b0 + b3 >>> 3);
    assign c1 = ref_i[BLOCK_SIZE * i + 1] + (b1 + b2 >>> 3);
    assign c2 = ref_i[BLOCK_SIZE * i + 2] + (b1 - b2 >>> 3);
    assign c3 = ref_i[BLOCK_SIZE * i + 3] + (b0 - b3 >>> 3);
    
    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            out_i[BLOCK_SIZE * i + 0] <= 'd0;
            out_i[BLOCK_SIZE * i + 1] <= 'd0;
            out_i[BLOCK_SIZE * i + 2] <= 'd0;
            out_i[BLOCK_SIZE * i + 3] <= 'd0;
        end
        else begin
            out_i[BLOCK_SIZE * i + 0] <=  (c0 > 'hff) ? 'hff : (c0 < 'h0) ? 'h0 : c0;
            out_i[BLOCK_SIZE * i + 1] <=  (c1 > 'hff) ? 'hff : (c1 < 'h0) ? 'h0 : c0;
            out_i[BLOCK_SIZE * i + 2] <=  (c2 > 'hff) ? 'hff : (c2 < 'h0) ? 'h0 : c0;
            out_i[BLOCK_SIZE * i + 3] <=  (c3 > 'hff) ? 'hff : (c3 < 'h0) ? 'h0 : c0;
        end
    end
end

endgenerate

endmodule
