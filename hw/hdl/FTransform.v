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
 parameter I_WIDTH =  8,
 parameter O_WIDTH = 12
)(
 input                             clk
,input                             rst_n
,input                             start
,input      [I_WIDTH * 16 - 1 : 0] src
,input      [I_WIDTH * 16 - 1 : 0] ref
,output     [O_WIDTH * 16 - 1 : 0] out
,output reg                        done
);

wire        [I_WIDTH - 1:0]src_i[15:0];
wire        [I_WIDTH - 1:0]ref_i[15:0];
reg  signed [13         :0]tmp  [15:0];//14b
reg  signed [O_WIDTH - 1:0]out_i[15:0];//12b

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
    assign src_i[i] = src [I_WIDTH * (i + 1) - 1 : I_WIDTH * i];
    assign ref_i[i] = ref [I_WIDTH * (i + 1) - 1 : I_WIDTH * i];
    assign out[O_WIDTH * (i + 1) - 1 : O_WIDTH * i] = out_i[i];
end

for(i = 0; i < 4; i = i + 1)begin
    wire signed [8 : 0] a0,a1,a2,a3;//9b
    assign a0 = src_i[4 * i + 0] - ref_i[4 * i + 0];
    assign a1 = src_i[4 * i + 1] - ref_i[4 * i + 1];
    assign a2 = src_i[4 * i + 2] - ref_i[4 * i + 2];
    assign a3 = src_i[4 * i + 3] - ref_i[4 * i + 3];

    wire signed [9 : 0] b0,b1,b2,b3;//10b
    assign b0 = a0 + a3;
    assign b1 = a1 + a2;
    assign b2 = a1 - a2;
    assign b3 = a0 - a3;
    
    wire signed [31 : 0] c0,c1,c2,c3;
    assign c0 = b2 * 2217;
    assign c1 = b3 * 5352;
    assign c2 = b3 * 2217;
    assign c3 = b2 * 5352;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            tmp[4 * i + 0] <= 'd0;
            tmp[4 * i + 1] <= 'd0;
            tmp[4 * i + 2] <= 'd0;
            tmp[4 * i + 3] <= 'd0;
        end
        else begin
            tmp[4 * i + 0] <= (b0 + b1        <<< 3);
            tmp[4 * i + 1] <= (c0 + c1 + 1812 >>> 9);
            tmp[4 * i + 2] <= (b0 - b1        <<< 3);
            tmp[4 * i + 3] <= (c2 - c3 + 0937 >>> 9);
        end
    end
    
    wire signed [14 : 0] d0,d1,d2,d3;//15b
    assign d0 = tmp[i + 0] + tmp[i + 12];
    assign d1 = tmp[i + 4] + tmp[i +  8];
    assign d2 = tmp[i + 4] - tmp[i +  8];
    assign d3 = tmp[i + 0] - tmp[i + 12];

    wire signed [31 : 0] e0,e1,e2,e3;
    assign e0 = d2 * 2217;
    assign e1 = d3 * 5352;
    assign e2 = d3 * 2217;
    assign e3 = d2 * 5352;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            out_i[i +  0] <= 'd0;
            out_i[i +  4] <= 'd0;
            out_i[i +  8] <= 'd0;
            out_i[i + 12] <= 'd0;
        end
        else begin
            out_i[i +  0] <= (d0 + d1 +     7 >>>  4);
            out_i[i +  4] <= (e0 + e1 + 12000 >>> 16) + (d3 != 0);
            out_i[i +  8] <= (d0 - d1 +     7 >>>  4);
            out_i[i + 12] <= (e2 - e3 + 51000 >>> 16);
        end
    end
end

endgenerate

endmodule
