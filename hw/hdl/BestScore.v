//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	BestScore.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-12-10 14:11
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module BestScore(
 input  signed [63:0] score0
,input  signed [63:0] score1
,input  signed [63:0] score2
,input  signed [63:0] score3
,input  signed [63:0] score4
,input  signed [63:0] score5
,input  signed [63:0] score6
,input  signed [63:0] score7
,input  signed [63:0] score8
,input  signed [63:0] score9
,output reg    [ 3:0] mode
);

wire[8:0]a;
wire[8:0]b;
wire[8:0]c;
wire[8:0]d;
wire[8:0]e;
wire[8:0]f;
wire[8:0]g;
wire[8:0]h;
wire[8:0]i;
wire[8:0]j;

assign a[0] = score0 <= score1;
assign a[1] = score0 <= score2;
assign a[2] = score0 <= score3;
assign a[3] = score0 <= score4;
assign a[4] = score0 <= score5;
assign a[5] = score0 <= score6;
assign a[6] = score0 <= score7;
assign a[7] = score0 <= score8;
assign a[8] = score0 <= score9;

assign b[0] = ~a[0];
assign b[1] = score1 <= score2;
assign b[2] = score1 <= score3;
assign b[3] = score1 <= score4;
assign b[4] = score1 <= score5;
assign b[5] = score1 <= score6;
assign b[6] = score1 <= score7;
assign b[7] = score1 <= score8;
assign b[8] = score1 <= score9;

assign c[0] = ~a[1];
assign c[1] = ~b[1];
assign c[2] = score2 <= score3;
assign c[3] = score2 <= score4;
assign c[4] = score2 <= score5;
assign c[5] = score2 <= score6;
assign c[6] = score2 <= score7;
assign c[7] = score2 <= score8;
assign c[8] = score2 <= score9;

assign d[0] = ~a[2];
assign d[1] = ~b[2];
assign d[2] = ~c[2];
assign d[3] = score3 <= score4;
assign d[4] = score3 <= score5;
assign d[5] = score3 <= score6;
assign d[6] = score3 <= score7;
assign d[7] = score3 <= score8;
assign d[8] = score3 <= score9;

assign e[0] = ~a[3];
assign e[1] = ~b[3];
assign e[2] = ~c[3];
assign e[3] = ~d[3];
assign e[4] = score4 <= score5;
assign e[5] = score4 <= score6;
assign e[6] = score4 <= score7;
assign e[7] = score4 <= score8;
assign e[8] = score4 <= score9;

assign f[0] = ~a[4];
assign f[1] = ~b[4];
assign f[2] = ~c[4];
assign f[3] = ~d[4];
assign f[4] = ~e[4];
assign f[5] = score5 <= score6;
assign f[6] = score5 <= score7;
assign f[7] = score5 <= score8;
assign f[8] = score5 <= score9;

assign g[0] = ~a[5];
assign g[1] = ~b[5];
assign g[2] = ~c[5];
assign g[3] = ~d[5];
assign g[4] = ~e[5];
assign g[5] = ~f[5];
assign g[6] = score6 <= score7;
assign g[7] = score6 <= score8;
assign g[8] = score6 <= score9;

assign h[0] = ~a[6];
assign h[1] = ~b[6];
assign h[2] = ~c[6];
assign h[3] = ~d[6];
assign h[4] = ~e[6];
assign h[5] = ~f[6];
assign h[6] = ~g[6];
assign h[7] = score7 <= score8;
assign h[8] = score7 <= score9;

assign i[0] = ~a[7];
assign i[1] = ~b[7];
assign i[2] = ~c[7];
assign i[3] = ~d[7];
assign i[4] = ~e[7];
assign i[5] = ~f[7];
assign i[6] = ~g[7];
assign i[7] = ~h[7];
assign i[8] = score8 <= score9;

assign j[0] = ~a[8];
assign j[1] = ~b[8];
assign j[2] = ~c[8];
assign j[3] = ~d[8];
assign j[4] = ~e[8];
assign j[5] = ~f[8];
assign j[6] = ~g[8];
assign j[7] = ~h[8];
assign j[8] = ~i[8];

always @ * begin
    if(a == 'b1_1111_1111)begin
        mode  = 'h00;
    end
    else if(b == 'b1_1111_1111)begin
        mode  = 'h01;
    end
    else if(c == 'b1_1111_1111)begin
        mode  = 'h02;
    end
    else if(d == 'b1_1111_1111)begin
        mode  = 'h03;
    end
    else if(e == 'b1_1111_1111)begin
        mode  = 'h04;
    end
    else if(f == 'b1_1111_1111)begin
        mode  = 'h05;
    end
    else if(g == 'b1_1111_1111)begin
        mode  = 'h06;
    end
    else if(h == 'b1_1111_1111)begin
        mode  = 'h07;
    end
    else if(i == 'b1_1111_1111)begin
        mode  = 'h08;
    end
    else if(j == 'b1_1111_1111)begin
        mode  = 'h09;
    end
    else begin
        mode  = 'b0;
    end
end
endmodule
