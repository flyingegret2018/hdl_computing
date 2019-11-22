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
,input                        start
,input               [15 : 0] in
,input               [15 : 0] q
,input               [15 : 0] iq
,input               [31 : 0] bias
,input               [31 : 0] zthresh
,output reg signed   [15 : 0] out
,output reg signed   [ 7 : 0] err
,output reg                   done
);

always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        done  <= 'b0;
    end
    else begin
        done  <= start;
    end
end

wire sign;
assign sign = in < 'd0;

wire signed [15:0]V;
assign V = sign ? ('d0 - in) : in;

wire signed [31:0]qV;
assign qV = ((V * iq + bias) >> 17) * q;

wire signed [31:0]err_tmp;
assign err_tmp = V - qV;

always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out <= 'b0;
        err <= 'b0;
    end
    else begin
        if(V > zthresh)begin
            out <= sign ? ('d0 - qV) : qV;
            err <= (sign ? ('d0 - err) : err) >> 1;
        end
        else begin
            out <= 'b0;
            err <= in >> 1;
        end
    end
end

endmodule
