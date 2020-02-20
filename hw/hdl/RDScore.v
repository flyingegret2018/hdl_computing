//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	RDScore.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-12-10 13:37
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module RDScore(
 input                    clk
,input                    rst_n
,input      signed [31:0] lambda
,input      signed [31:0] tlambda
,input      signed [31:0] D
,input      signed [31:0] SD
,input      signed [31:0] H
,input      signed [31:0] R
,output reg        [63:0] score
);

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        score <= 'b0;
    else
        score <= ((R << 10) + H) * lambda + (D << 8) + SD * tlambda;
end

endmodule
