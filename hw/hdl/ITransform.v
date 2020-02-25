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
 parameter SRC_WIDTH = 16,
 parameter REF_WIDTH =  8,
 parameter OUT_WIDTH =  8
)(
 input                               clk
,input                               rst_n
,input                               start
,input      [SRC_WIDTH * 16 - 1 : 0] src
,input      [REF_WIDTH * 16 - 1 : 0] ref
,output     [OUT_WIDTH * 16 - 1 : 0] out
,output reg                          done
);

wire signed [SRC_WIDTH - 1 : 0]src_i[15:0];
wire        [REF_WIDTH - 1 : 0]ref_i[15:0];
reg         [OUT_WIDTH - 1 : 0]out_i[15:0];
reg  signed [18            : 0]tmp  [15:0];

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

for(i = 0; i < 16; i = i + 1)begin
    assign src_i[i] = src[SRC_WIDTH * (i + 1) - 1 : SRC_WIDTH * i];
    assign ref_i[i] = ref[REF_WIDTH * (i + 1) - 1 : REF_WIDTH * i];
    assign out[OUT_WIDTH * (i + 1) - 1 : OUT_WIDTH * i] = out_i[i];
end

for(i = 0; i < 4; i = i + 1)begin
    wire signed [31 : 0] d0,d1,d2,d3;
    assign d0 = src_i[i +  4] * $signed(35468);
    assign d1 = src_i[i + 12] * $signed(85627);
    assign d2 = src_i[i +  4] * $signed(85627);
    assign d3 = src_i[i + 12] * $signed(35468);

    wire signed [17 : 0] a0,a1,a2,a3;
    assign a0 = src_i[i + 0] + src_i[i + 8];
    assign a1 = src_i[i + 0] - src_i[i + 8];
    assign a2 = (d0 >>> 16) - (d1 >>> 16);
    assign a3 = (d2 >>> 16) + (d3 >>> 16);

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            tmp[4 * i + 0] <= 'd0;
            tmp[4 * i + 1] <= 'd0;
            tmp[4 * i + 2] <= 'd0;
            tmp[4 * i + 3] <= 'd0;
        end
        else begin
            tmp[4 * i + 0] <= a0 + a3;
            tmp[4 * i + 1] <= a1 + a2;
            tmp[4 * i + 2] <= a1 - a2;
            tmp[4 * i + 3] <= a0 - a3;
        end
    end
    
    wire signed [31 : 0] e0,e1,e2,e3;
    assign e0 = tmp[i +  4] * $signed(35468);
    assign e1 = tmp[i + 12] * $signed(85627);
    assign e2 = tmp[i +  4] * $signed(85627);
    assign e3 = tmp[i + 12] * $signed(35468);

    wire signed [20 : 0] b0,b1,b2,b3;
    assign b0 = tmp[i + 0] + tmp[i + 8] + $signed('d4);
    assign b1 = tmp[i + 0] - tmp[i + 8] + $signed('d4);
    assign b2 = (e0 >>> 16) - (e1 >>> 16);
    assign b3 = (e2 >>> 16) + (e3 >>> 16);
    
    wire signed [19 : 0] c0,c1,c2,c3;
    assign c0 = $signed({1'b0,ref_i[4 * i + 0]}) + (b0 + b3 >>> 3);
    assign c1 = $signed({1'b0,ref_i[4 * i + 1]}) + (b1 + b2 >>> 3);
    assign c2 = $signed({1'b0,ref_i[4 * i + 2]}) + (b1 - b2 >>> 3);
    assign c3 = $signed({1'b0,ref_i[4 * i + 3]}) + (b0 - b3 >>> 3);
    
    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            out_i[4 * i + 0] <= 'd0;
            out_i[4 * i + 1] <= 'd0;
            out_i[4 * i + 2] <= 'd0;
            out_i[4 * i + 3] <= 'd0;
        end
        else begin
            out_i[4 * i + 0] <=  (c0 > $signed('hff)) ? 'hff : (c0 < $signed('h0)) ? 'h0 : c0;
            out_i[4 * i + 1] <=  (c1 > $signed('hff)) ? 'hff : (c1 < $signed('h0)) ? 'h0 : c1;
            out_i[4 * i + 2] <=  (c2 > $signed('hff)) ? 'hff : (c2 < $signed('h0)) ? 'h0 : c2;
            out_i[4 * i + 3] <=  (c3 > $signed('hff)) ? 'hff : (c3 < $signed('h0)) ? 'h0 : c3;
        end
    end
end

endgenerate

endmodule
