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

module QuantizeSingle(
 input                        clk
,input                        rst_n
,input      signed   [15 : 0] in
,input      signed   [15 : 0] q
,input      signed   [15 : 0] iq
,input      signed   [31 : 0] bias
,input      signed   [31 : 0] zthresh
,output reg signed   [15 : 0] out
,output reg signed   [ 7 : 0] err
);

wire sign;
assign sign = in[15];

wire signed [15:0]V;
assign V = sign ? (~in + 1'b1) : in;

wire signed [31:0]mul_tmp;
assign mul_tmp = V * iq;

reg signed [31:0]tmp;
reg signed [15:0]V_tmp;
reg signed [15:0]in_tmp;
reg sign_tmp;
always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        tmp      <= 'b0;
        V_tmp    <= 'b0;
        sign_tmp <= 'b0;
        in_tmp   <= 'b0;
    end
    else begin
        tmp      <= (mul_tmp + bias) >>> 17;
        V_tmp    <= V;
        sign_tmp <= sign;
        in_tmp   <= in;
    end
end

wire signed [31:0]qV;
assign qV = tmp * q;

wire signed [31:0]err_tmp;
assign err_tmp = V_tmp - qV;

always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out <= 'b0;
        err <= 'b0;
    end
    else begin
        if(V_tmp > zthresh)begin
            out <= (sign_tmp ? (~qV + 1'b1) : qV);
            err <= (sign_tmp ? (~err_tmp + 1'b1) : err_tmp) >>> 1;
        end
        else begin
            out <= 'b0;
            err <= in_tmp >>> 1;
        end
    end
end

endmodule
