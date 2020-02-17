//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	QuantizeBlock.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-20 14:42
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module QuantizeBlock#(
 parameter BLOCK_SIZE   = 4,
 parameter IW   = 16
)(
 input                                             clk
,input                                             rst_n
,input                                             start
,input      [IW * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] in
,input      [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] q
,input      [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] iq
,input      [32 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] bias
,input      [32 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] zthresh
,input      [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] sharpen
,output     [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] Rout
,output     [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] out
,output                                            nz
,output reg                                        done
);

wire signed [IW - 1:0]in_i     [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
wire signed [15    :0]q_i      [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
wire signed [15    :0]iq_i     [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
wire signed [31    :0]bias_i   [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
wire signed [31    :0]zthresh_i[BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
wire signed [15    :0]sharpen_i[BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
reg  signed [31    :0]level    [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
reg  signed [15    :0]Rout_i   [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
reg  signed [15    :0]out_i    [BLOCK_SIZE * BLOCK_SIZE - 1 : 0];
wire        [15    :0]t;

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
    assign in_i     [i] = in     [IW * (i + 1) - 1 : IW * i];
    assign q_i      [i] = q      [16 * (i + 1) - 1 : 16 * i];
    assign iq_i     [i] = iq     [16 * (i + 1) - 1 : 16 * i];
    assign bias_i   [i] = bias   [32 * (i + 1) - 1 : 32 * i];
    assign zthresh_i[i] = zthresh[32 * (i + 1) - 1 : 32 * i];
    assign sharpen_i[i] = sharpen[16 * (i + 1) - 1 : 16 * i];

    assign Rout[16 * (i + 1) - 1 : 16 * i] = Rout_i[i];
end

for(i = 0; i < BLOCK_SIZE * BLOCK_SIZE; i = i + 1)begin
    wire sign;
    assign sign = in_i[i][IW - 1];

    wire[31:0]coeff;
    assign coeff = sign ? (sharpen_i[i] - in_i[i]) : (sharpen_i[i] + in_i[i]); 
    
    wire[31:0]mul_tmp;
    assign mul_tmp = coeff * iq_i[i];

    wire sign_tmp;
    wire[31:0]coeff_tmp;
    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            sign_tmp  <= 'b0;
            coeff_tmp <= 'b0;
            level[i]  <= 'b0;
        end
        else begin
            sign_tmp  <= sign;
            coeff_tmp <= coeff;
            level[i]  <= (mul_tmp + bias_i[i]) >>> 17;
        end
    end
    
    wire signed [31:0]level1;
    assign level1 = (level[i] > 'd2047) ? 'd2047 : level[i];
    
    wire signed [31:0]level2;
    assign level2 = sign_tmp ? (~level1 + 1'b1) : level1;
    
    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            Rout_i[i] <= 'b0;
            out_i [i] <= 'b0;
        end
        else begin
            if(coeff_tmp > zthresh_i[i])begin
                Rout_i[i] <= level2 * q_i[i];
                out_i [i] <= level2;
            end
            else begin
                Rout_i[i] <= 'b0;
                out_i [i] <= 'b0;
            end
        end
    end

    assign t[i] = out_i[i] != 'b0;
end

endgenerate

assign nz = t[ 0] | t[ 1] | t[ 2] | t[ 3] | t[ 4] | t[ 5] | t[ 6] | t[ 7] |
            t[ 8] | t[ 9] | t[10] | t[11] | t[12] | t[13] | t[14] | t[15];

//zigzag
assign out[ 15:  0] = out_i[ 0];
assign out[ 31: 16] = out_i[ 1];
assign out[ 47: 32] = out_i[ 4];
assign out[ 63: 48] = out_i[ 8];
assign out[ 79: 64] = out_i[ 5];
assign out[ 95: 80] = out_i[ 2];
assign out[111: 96] = out_i[ 3];
assign out[127:112] = out_i[ 6];
assign out[143:128] = out_i[ 9];
assign out[159:144] = out_i[12];
assign out[175:160] = out_i[13];
assign out[191:176] = out_i[10];
assign out[207:192] = out_i[ 7];
assign out[223:208] = out_i[11];
assign out[239:224] = out_i[14];
assign out[255:240] = out_i[15];

endmodule
