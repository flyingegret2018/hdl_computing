//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	RotateI4.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-12-11 10:50
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module RotateI4(
 input                           clk
,input                           rst_n
,input                           load
,input         [ 4      - 1 : 0] i4
,input         [ 8 * 16 - 1 : 0] Yin
,input         [ 8      - 1 : 0] top_left
,input         [ 8 * 20 - 1 : 0] top
,input         [ 8 * 16 - 1 : 0] left
,output reg    [32      - 1 : 0] left_i
,output reg    [ 8      - 1 : 0] top_left_i
,output reg    [32      - 1 : 0] top_i
,output reg    [32      - 1 : 0] top_right_i
);

reg [127:0]mem;

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        mem <= 'b0;
    else
        if(load)begin
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
end

always @ *begin
    case(i4)
        'h0: begin
            left_i      = {Yin[127:120],Yin[95:88],Yin[63:56],Yin[31:24]};
            top_left_i  = top [ 31: 24];
            top_i       = top [ 63: 32];
            top_right_i = top [ 95: 64];
        end
        'h1: begin
            left_i      = {Yin[127:120],Yin[95:88],Yin[63:56],Yin[31:24]};
            top_left_i  = top [ 63: 56];
            top_i       = top [ 95: 64];
            top_right_i = top [127: 96];
        end
        'h2: begin
            left_i      = {Yin[127:120],Yin[95:88],Yin[63:56],Yin[31:24]};
            top_left_i  = top [ 95: 88];
            top_i       = top [127: 96];
            top_right_i = top [159:128];
        end
        'h3: begin
            left_i      = left[ 63: 32];
            top_left_i  = left[ 31: 24];
            top_i       = mem [ 31:  0];
            top_right_i = mem [ 63: 32];
        end
        'h4: begin
            left_i      = {Yin[127:120],Yin[95:88],Yin[63:56],Yin[31:24]};
            top_left_i  = mem [ 31: 24];
            top_i       = mem [ 63: 32];
            top_right_i = mem [ 95: 64];
        end
        'h5: begin
            left_i      = {Yin[127:120],Yin[95:88],Yin[63:56],Yin[31:24]};
            top_left_i  = mem [ 63: 56];
            top_i       = mem [ 95: 64];
            top_right_i = mem [127: 96];
        end
        'h6: begin
            left_i      = {Yin[127:120],Yin[95:88],Yin[63:56],Yin[31:24]};
            top_left_i  = mem [ 95: 88];
            top_i       = mem [127: 96];
            top_right_i = top [159:128];
        end
        'h7: begin
            left_i      = left[ 95: 64];
            top_left_i  = left[ 63: 56];
            top_i       = mem [ 31:  0];
            top_right_i = mem [ 63: 32];
        end
        'h8: begin
            left_i      = {Yin[127:120],Yin[95:88],Yin[63:56],Yin[31:24]};
            top_left_i  = mem [ 31: 24];
            top_i       = mem [ 63: 32];
            top_right_i = mem [ 95: 64];
        end
        'h9: begin
            left_i      = {Yin[127:120],Yin[95:88],Yin[63:56],Yin[31:24]};
            top_left_i  = mem [ 63: 56];
            top_i       = mem [ 95: 64];
            top_right_i = mem [127: 96];
        end
        'ha: begin
            left_i      = {Yin[127:120],Yin[95:88],Yin[63:56],Yin[31:24]};
            top_left_i  = mem [ 95: 88];
            top_i       = mem [127: 96];
            top_right_i = top [159:128];
        end
        'hb: begin
            left_i      = left[127: 96];
            top_left_i  = left[ 95: 88];
            top_i       = mem [ 31:  0];
            top_right_i = mem [ 63: 32];
        end
        'hc: begin
            left_i      = {Yin[127:120],Yin[95:88],Yin[63:56],Yin[31:24]};
            top_left_i  = mem [ 31: 24];
            top_i       = mem [ 63: 32];
            top_right_i = mem [ 95: 64];
        end
        'hd: begin
            left_i      = {Yin[127:120],Yin[95:88],Yin[63:56],Yin[31:24]};
            top_left_i  = mem [ 63: 56];
            top_i       = mem [ 95: 64];
            top_right_i = mem [127: 96];
        end
        'he: begin
            left_i      = {Yin[127:120],Yin[95:88],Yin[63:56],Yin[31:24]};
            top_left_i  = mem [ 95: 88];
            top_i       = mem [127: 96];
            top_right_i = top [159:128];
        end
        'hf: begin
            left_i      = 'b0;
            top_left_i  = 'b0;
            top_i       = 'b0;
            top_right_i = 'b0;
        end
        default: begin
            left_i      = 'b0;
            top_left_i  = 'b0;
            top_i       = 'b0;
            top_right_i = 'b0;
        end
    endcase
end

endmodule
