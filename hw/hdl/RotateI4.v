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
 input                           clk
,input                           rst_n
,input         [ 5      - 1 : 0] i4
,input         [ 8 * 16 - 1 : 0] Yin
,input         [ 8      - 1 : 0] top_left
,input         [ 8 * 20 - 1 : 0] top
,input         [ 8 * 16 - 1 : 0] left
,output        [32      - 1 : 0] left_i
,output        [ 8      - 1 : 0] top_left_i
,output        [32      - 1 : 0] top_i
,output        [32      - 1 : 0] top_right_i
);

reg [127:0]mem;

always @ (posedge clk or negedge rst_n)begin
    case(i4)
        'h0: mem[ 31: 0] <= Yin[127:96];
        'h1: mem[ 63:32] <= Yin[127:96];
        'h2: mem[ 95:64] <= Yin[127:96];
        'h3: mem[127:96] <= Yin[127:96];
        'h4: mem[ 31: 0] <= Yin[127:96];
        'h5: mem[ 63:32] <= Yin[127:96];
        'h6: mem[ 95:64] <= Yin[127:96];
        'h7: mem[127:96] <= Yin[127:96];
        'h8: mem[ 31: 0] <= Yin[127:96];
        'h9: mem[ 63:32] <= Yin[127:96];
        'ha: mem[ 95:64] <= Yin[127:96];
        'hb: mem[127:96] <= Yin[127:96];
        default:;
    endcase
end

always @ *begin
    case(i4)
        'h0: begin
            left_i      = {Yin[127:120],Yin[],Yin[],Yin[]};
            top_left_i  = top[31:24];
            top_i       = ;
            top_right_i = ;
        end
        'h1: beginend
        'h2: beginend
        'h3: beginend
        'h4: beginend
        'h5: beginend
        'h6: beginend
        'h7: beginend
        'h8: beginend
        'h9: beginend
        'ha: beginend
        'hb: beginend
        'hc: beginend
        'hd: beginend
        'he: beginend
        'hf: beginend
        default:;
    endcase
end

endmodule
