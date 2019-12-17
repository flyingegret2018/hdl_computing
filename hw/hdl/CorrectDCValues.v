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

module CorrectDCValues(
 input                         clk
,input                         rst_n
,input                         start
,input               [  9 : 0] x
,input               [  9 : 0] y
,input               [127 : 0] in
,input               [ 15 : 0] q
,input               [ 15 : 0] iq
,input               [ 31 : 0] bias
,input               [ 31 : 0] zthresh
,input               [ 31 : 0] left_derr
,input               [ 31 : 0] top_derr
,output reg                    top_derr_en
,output reg          [  9 : 0] top_derr_addr
,output reg          [127 : 0] out
,output              [ 47 : 0] derr
,output reg                    done
);

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
   
    reg  [12:0] cstate;
    reg  [12:0] nstate;

    reg  signed[31:0]tmp [5:0];
    reg  signed[ 7:0]top [3:0];
    reg  signed[ 7:0]left[3:0];
    reg  signed[15:0]u_tmp;
    reg  signed[15:0]v_tmp;
    reg  signed[ 7:0]uerr0;
    reg  signed[ 7:0]verr0;
    reg  signed[ 7:0]uerr1;
    reg  signed[ 7:0]verr1;
    reg  signed[ 7:0]uerr2;
    reg  signed[ 7:0]verr2;

    wire signed[ 7:0] uerr;
    wire signed[ 7:0] verr;
    wire signed[15:0] uout;
    wire signed[15:0] vout;

    wire signed[7:0] top0 ;
    wire signed[7:0] top1 ;
    wire signed[7:0] top2 ;
    wire signed[7:0] top3 ;
    wire signed[7:0] left0;
    wire signed[7:0] left1;
    wire signed[7:0] left2;
    wire signed[7:0] left3;

    assign top0  = top_derr [ 7: 0];
    assign top1  = top_derr [15: 8];
    assign top2  = top_derr [23:16];
    assign top3  = top_derr [31:24];
    assign left0 = left_derr[ 7: 0];
    assign left1 = left_derr[15: 8];
    assign left2 = left_derr[23:16];
    assign left3 = left_derr[31:24];

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
            tmp [0]       <= 'b0;
            tmp [1]       <= 'b0;
            tmp [2]       <= 'b0;
            tmp [3]       <= 'b0;
            tmp [4]       <= 'b0;
            tmp [5]       <= 'b0;
            top [1]       <= 'b0;
            top [3]       <= 'b0;
            left[1]       <= 'b0;
            left[3]       <= 'b0;
            top_derr_en   <= 'b0;
            top_derr_addr <= 'b0;
            utmp          <= 'b0;
            vtmp          <= 'b0;
            done          <= 'b0;
            uerr0         <= 'b0;
            verr0         <= 'b0;
            uerr1         <= 'b0;
            verr1         <= 'b0;
            uerr2         <= 'b0;
            verr2         <= 'b0;
        end
        else begin
            case(cstate)
                IDLE:begin
                    top_derr_en   <= 'b0;
                    done          <= 'b0;
                end
                EN:begin
                    top_derr_en   <= 'b1;
                    top_derr_addr <= x;
                end
                WAIT:begin
                    top_derr_en   <= 'b0;
                end
                BOTH:begin
                    top [1]       <= top1 ;
                    top [3]       <= top3 ;
                    left[1]       <= left1;
                    left[3]       <= left3;
                    utmp          <= in[ 15:  0] + ((top0 * 7 + left0 * 8) >> 3);
                    vtmp          <= in[ 79: 64] + ((top2 * 7 + left2 * 8) >> 3);
                end
                TOP:begin
                    top [1]       <= top1;
                    top [3]       <= top3;
                    left[1]       <= 'b0;
                    left[3]       <= 'b0;
                    utmp          <= in[ 15:  0] + ((top0 * 7 + 'b0 * 8) >> 3);
                    vtmp          <= in[ 79: 64] + ((top2 * 7 + 'b0 * 8) >> 3);
                end
                LEFT:begin
                    top [1]       <= 'b0;
                    top [3]       <= 'b0;
                    left[1]       <= left1;
                    left[3]       <= left3;
                    utmp          <= in[ 15:  0] + (('b0 * 7 + left0 * 8) >> 3);
                    vtmp          <= in[ 79: 64] + (('b0 * 7 + left2 * 8) >> 3);
                end
                NONE:begin
                    top [1]       <= 'b0;
                    top [3]       <= 'b0;
                    left[1]       <= 'b0;
                    left[3]       <= 'b0;
                    utmp          <= in[ 15:  0] + (('b0 * 7 + 'b0 * 8) >> 3);
                    vtmp          <= in[ 79: 64] + (('b0 * 7 + 'b0 * 8) >> 3);
                end
                STEP1:begin
                    ;
                end
                STEP2:begin
                    tmp[0]        <= uout;
                    tmp[1]        <= vout;
                    uerr0         <= uerr;
                    verr0         <= verr;
                    utmp          <= in[ 31: 16] + ((top[1] * 7 + uerr * 8) >> 3);
                    vtmp          <= in[ 95: 80] + ((top[3] * 7 + verr * 8) >> 3);
                end
                STEP3:begin
                    utmp          <= in[ 47: 32] + ((uerr0 * 7 + left[1] * 8) >> 3);
                    vtmp          <= in[111: 96] + ((verr0 * 7 + left[3] * 8) >> 3);
                end
                STEP4:begin
                    tmp[2]        <= uout;
                    tmp[3]        <= vout;
                    uerr1         <= uerr;
                    verr1         <= verr;
                end
                STEP5:begin
                    tmp[4]        <= uout;
                    tmp[5]        <= vout;
                    uerr2         <= uerr;
                    verr2         <= verr;
                    utmp          <= in[ 63: 48] + ((uerr1 * 7 + uerr * 8) >> 3);
                    vtmp          <= in[127:112] + ((verr1 * 7 + verr * 8) >> 3);
                end
                STEP6:begin
                    done          <= 'b1;
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

assign derr[ 7: 0] = uerr1;
assign derr[15: 8] = uerr2;
assign derr[23:15] = uerr;
assign derr[31:24] = verr1;
assign derr[39:32] = verr2;
assign derr[47:40] = verr;

assign out[ 15:  0] = tmp[0];
assign out[ 31: 16] = tmp[2];
assign out[ 47: 32] = tmp[4];
assign out[ 63: 48] = uout;
assign out[ 79: 64] = tmp[1];
assign out[ 95: 80] = tmp[3];
assign out[111: 96] = tmp[5];
assign out[127:112] = vout;

endmodule
