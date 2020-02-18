//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	CorrectDCValues.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-23 18:52
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module CorrectDCValues#(
 parameter I_WIDTH = 16,
 parameter O_WIDTH = 16
)(
 input                                     clk
,input                                     rst_n
,input                                     start
,input               [      9         : 0] x
,input               [      9         : 0] y
,input               [I_WIDTH * 8 - 1 : 0] in
,input               [     15         : 0] q
,input               [     15         : 0] iq
,input               [     31         : 0] bias
,input               [     31         : 0] zthresh
,input               [     31         : 0] left_derr
,input               [     31         : 0] top_derr
,output reg                                top_derr_en
,output              [      9         : 0] top_derr_addr
,output              [O_WIDTH * 8 - 1 : 0] out
,output              [      8 * 6 - 1 : 0] derr
,output reg                                done
);

reg  [12:0] cstate;
reg  [12:0] nstate;

wire signed[I_WIDTH - 1:0]in_i [7:0];
wire signed[O_WIDTH - 1:0]out_i[7:0];
reg  signed[15:0]tmp [5:0];
reg  signed[ 7:0]top_tmp [1:0];
reg  signed[ 7:0]left_tmp[1:0];
reg  signed[15:0]utmp;
reg  signed[15:0]vtmp;
reg  signed[ 7:0]err [5:0];
wire signed[ 7:0]uerr;
wire signed[ 7:0]verr;
wire signed[15:0]uout;
wire signed[15:0]vout;
wire signed[ 7:0]top [3:0];
wire signed[ 7:0]left[3:0];
wire signed[11:0]mul_tmp[13:0];

assign top_derr_addr = x;
assign mul_tmp[ 0] = top [0] * 7;
assign mul_tmp[ 1] = left[0] * 8;
assign mul_tmp[ 2] = top [2] * 7;
assign mul_tmp[ 3] = left[2] * 8;
assign mul_tmp[ 4] = top_tmp [0] * 7;
assign mul_tmp[ 5] = uerr * 8;
assign mul_tmp[ 6] = top_tmp [1] * 7;
assign mul_tmp[ 7] = verr * 8;
assign mul_tmp[ 8] = err[0] * 7;
assign mul_tmp[ 9] = left_tmp[0] * 8;
assign mul_tmp[10] = err[3] * 7;
assign mul_tmp[11] = left_tmp[1] * 8;
assign mul_tmp[12] = err[1] * 7;
assign mul_tmp[13] = err[4] * 7;

genvar i;

generate

for(i = 0; i < 8; i = i + 1)begin
    assign in_i[i] = in[I_WIDTH * (i + 1) - 1 : I_WIDTH * i];
    assign out[O_WIDTH * (i + 1) - 1 : O_WIDTH * i] = out_i[i];
end

for(i = 0; i < 4; i = i + 1)begin
    assign top [i] = top_derr [8 * (i + 1) - 1 : 8 * i];
    assign left[i] = left_derr[8 * (i + 1) - 1 : 8 * i];
end

endgenerate

parameter IDLE    = 'h01;
parameter BOTH    = 'h02;
parameter TOP     = 'h04; 
parameter LEFT    = 'h08;
parameter NONE    = 'h10;
parameter EN      = 'h20;
parameter WAIT    = 'h40;
parameter STEP1   = 'h80;
parameter STEP2   = 'h100;
parameter STEP3   = 'h200;
parameter STEP4   = 'h400;
parameter STEP5   = 'h800;
parameter STEP6   = 'h1000;

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        cstate <= IDLE;
    else
        cstate <= nstate;
end

always @ * begin
    case(cstate)
        IDLE:
            if(start)
                if(y != 'b0)
                    nstate = EN;
                else
                    if(x != 'b0)
                        nstate = LEFT;
                    else
                        nstate = NONE;
            else
                nstate = IDLE;
        EN:
            nstate = WAIT;
        WAIT:
            if(x != 'b0)
                nstate = BOTH;
            else
                nstate = TOP;
        BOTH:
            nstate = STEP1;
        TOP:
            nstate = STEP1;
        LEFT: 
            nstate = STEP1;
        NONE:
            nstate = STEP1;
        STEP1:
            nstate = STEP2;
        STEP2:
            nstate = STEP3;
        STEP3:
            nstate = STEP4;
        STEP4:
            nstate = STEP5;
        STEP5:
            nstate = STEP6;
        STEP6:
            nstate = IDLE;
        default:
            nstate = IDLE;
    endcase
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        tmp[0]      <= 'b0;
        tmp[1]      <= 'b0;
        tmp[2]      <= 'b0;
        tmp[3]      <= 'b0;
        tmp[4]      <= 'b0;
        tmp[5]      <= 'b0;
        top_tmp [0] <= 'b0;
        top_tmp [1] <= 'b0;
        left_tmp[0] <= 'b0;
        left_tmp[1] <= 'b0;
        top_derr_en <= 'b0;
        utmp        <= 'b0;
        vtmp        <= 'b0;
        err[0]      <= 'b0;
        err[1]      <= 'b0;
        err[2]      <= 'b0;
        err[3]      <= 'b0;
        err[4]      <= 'b0;
        err[5]      <= 'b0;
        done        <= 'b0;
    end
    else begin
        case(cstate)
            IDLE:begin
                top_derr_en <= 'b0;
                done        <= 'b0;
            end
            EN:begin
                top_derr_en <= 'b1;
            end
            WAIT:begin
                top_derr_en <= 'b0;
            end
            BOTH:begin
                top_tmp [0] <= top [1];
                top_tmp [1] <= top [3];
                left_tmp[0] <= left[1];
                left_tmp[1] <= left[3];
                utmp        <= in_i[0] + (mul_tmp[ 0] + mul_tmp[ 1] >>> 3);
                vtmp        <= in_i[4] + (mul_tmp[ 2] + mul_tmp[ 3] >>> 3);
            end
            TOP:begin
                top_tmp [0] <= top [1];
                top_tmp [1] <= top [3];
                left_tmp[0] <= 'b0;
                left_tmp[1] <= 'b0;
                utmp        <= in_i[0] + (mul_tmp[ 0] >>> 3);
                vtmp        <= in_i[4] + (mul_tmp[ 2] >>> 3);
            end
            LEFT:begin
                top_tmp [0] <= 'b0;
                top_tmp [1] <= 'b0;
                left_tmp[0] <= left[1];
                left_tmp[1] <= left[3];
                utmp        <= in_i[0] + (mul_tmp[ 1] >>> 3);
                vtmp        <= in_i[4] + (mul_tmp[ 3] >>> 3);
            end
            NONE:begin
                top_tmp [0] <= 'b0;
                top_tmp [1] <= 'b0;
                left_tmp[0] <= 'b0;
                left_tmp[1] <= 'b0;
                utmp        <= in_i[0];
                vtmp        <= in_i[4];
            end
            STEP1:begin
                ;
            end
            STEP2:begin
                tmp[0]      <= uout;
                tmp[1]      <= vout;
                err[0]      <= uerr;
                err[3]      <= verr;
                utmp        <= in_i[1] + (mul_tmp[ 4] + mul_tmp[ 5] >>> 3);
                vtmp        <= in_i[5] + (mul_tmp[ 6] + mul_tmp[ 7] >>> 3);
            end
            STEP3:begin
                utmp        <= in_i[2] + (mul_tmp[ 8] + mul_tmp[ 9] >>> 3);
                vtmp        <= in_i[6] + (mul_tmp[10] + mul_tmp[11] >>> 3);
            end
            STEP4:begin
                tmp[2]      <= uout;
                tmp[3]      <= vout;
                err[1]      <= uerr;
                err[4]      <= verr;
            end
            STEP5:begin
                tmp[4]      <= uout;
                tmp[5]      <= vout;
                err[2]      <= uerr;
                err[5]      <= verr;
                utmp        <= in_i[3] + (mul_tmp[12] + mul_tmp[ 5] >>> 3);
                vtmp        <= in_i[7] + (mul_tmp[13] + mul_tmp[ 7] >>> 3);
            end
            STEP6:begin
                done        <= 'b1;
            end
        endcase
    end
end

QuantizeSingle U_QSU(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( 'b0                           ),
    .in                             ( utmp                          ),
    .q                              ( q                             ),
    .iq                             ( iq                            ),
    .bias                           ( bias                          ),
    .zthresh                        ( zthresh                       ),
    .out                            ( uout                          ),
    .err                            ( uerr                          ),
    .done                           (                               )
);

QuantizeSingle U_QSV(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( 'b0                           ),
    .in                             ( vtmp                          ),
    .q                              ( q                             ),
    .iq                             ( iq                            ),
    .bias                           ( bias                          ),
    .zthresh                        ( zthresh                       ),
    .out                            ( vout                          ),
    .err                            ( verr                          ),
    .done                           (                               )
);

assign derr[ 7: 0] = err[1];
assign derr[15: 8] = err[2];
assign derr[23:16] = uerr;
assign derr[31:24] = err[4];
assign derr[39:32] = err[5];
assign derr[47:40] = verr;

assign out_i[0] = tmp[0];
assign out_i[1] = tmp[2];
assign out_i[2] = tmp[4];
assign out_i[3] = uout;
assign out_i[4] = tmp[1];
assign out_i[5] = tmp[3];
assign out_i[6] = tmp[5];
assign out_i[7] = vout;

endmodule
