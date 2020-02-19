//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	PickBestIntra4.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-17 13:30
// LastModified   :	2019-12-10 10:38
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module PickBestIntra4#(
 parameter BLOCK_SIZE   = 16
)(
 input                                                    clk
,input                                                    rst_n
,input                                                    start
,input      signed [32                           - 1 : 0] lambda_i4
,input      signed [32                           - 1 : 0] tlambda
,input      signed [32                           - 1 : 0] lambda_mode
,input             [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] Ysrc
,input             [ 8                           - 1 : 0] top_left
,input             [ 8 * 20                      - 1 : 0] top
,input             [ 8 * BLOCK_SIZE              - 1 : 0] left
,input             [16 * BLOCK_SIZE              - 1 : 0] q
,input             [16 * BLOCK_SIZE              - 1 : 0] iq
,input             [32 * BLOCK_SIZE              - 1 : 0] bias
,input             [32 * BLOCK_SIZE              - 1 : 0] zthresh
,input             [16 * BLOCK_SIZE              - 1 : 0] sharpen
,output            [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] Yout
,output reg        [64                           - 1 : 0] Score
,output            [ 8 * BLOCK_SIZE              - 1 : 0] mode_i4
,output            [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] levels
,output reg        [32                           - 1 : 0] nz
,output reg                                               done
);

wire[ 8 * BLOCK_SIZE - 1 : 0]Ysrc_i   [BLOCK_SIZE - 1 : 0];
reg [ 8 * BLOCK_SIZE - 1 : 0]Yout_i   [BLOCK_SIZE - 1 : 0];
reg [ 8              - 1 : 0]mode_i   [BLOCK_SIZE - 1 : 0];
reg [16 * BLOCK_SIZE - 1 : 0]levels_i [BLOCK_SIZE - 1 : 0];

genvar i;

generate

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    assign Ysrc_i[i] = 
    {Ysrc[8*((i/4)*64+(i%4)*4+52)-1:8*((i/4)*64+(i%4)*4+48)],
     Ysrc[8*((i/4)*64+(i%4)*4+36)-1:8*((i/4)*64+(i%4)*4+32)],
     Ysrc[8*((i/4)*64+(i%4)*4+20)-1:8*((i/4)*64+(i%4)*4+16)],
     Ysrc[8*((i/4)*64+(i%4)*4+ 4)-1:8*((i/4)*64+(i%4)*4+ 0)]};
 
    assign 
    {Yout[8*((i/4)*64+(i%4)*4+52)-1:8*((i/4)*64+(i%4)*4+48)],
     Yout[8*((i/4)*64+(i%4)*4+36)-1:8*((i/4)*64+(i%4)*4+32)],
     Yout[8*((i/4)*64+(i%4)*4+20)-1:8*((i/4)*64+(i%4)*4+16)],
     Yout[8*((i/4)*64+(i%4)*4+ 4)-1:8*((i/4)*64+(i%4)*4+ 0)]}
     = Yout_i[i];

     assign mode_i4[8 * (i + 1) - 1 : 8 * i] = mode_i[i];

     assign levels[256 * (i + 1) - 1 : 256 * i] = levels_i[i];
end

endgenerate

reg [ 31:0]left_i;
reg [  7:0]top_left_i;
reg [ 31:0]top_i;
reg [ 31:0]top_right_i;
wire[127:0]pred[9:0];

DC4 U_DC4(
    .top                            ( top_i                         ),
    .left                           ( left_i                        ),
    .dst                            ( pred[0]                       )
);

TM4 U_TM4(
    .top_left                       ( top_left_i                    ),
    .top                            ( top_i                         ),
    .left                           ( left_i                        ),
    .dst                            ( pred[1]                       )
);

VE4 U_VE4(
    .top_left                       ( top_left_i                    ),
    .top_right                      ( top_right_i[7:0]              ),
    .top                            ( top_i                         ),
    .dst                            ( pred[2]                       )
);

HE4 U_HE4(
    .top_left                       ( top_left_i                    ),
    .left                           ( left_i                        ),
    .dst                            ( pred[3]                       )
);

RD4 U_RD4(
    .top_left                       ( top_left_i                    ),
    .top                            ( top_i                         ),
    .left                           ( left_i                        ),
    .dst                            ( pred[4]                       )
);

VR4 U_VR4(
    .top_left                       ( top_left_i                    ),
    .top                            ( top_i                         ),
    .left                           ( left_i[23:0]                  ),
    .dst                            ( pred[5]                       )
);

LD4 U_LD4(
    .top                            ( top_i                         ),
    .top_right                      ( top_right_i                   ),
    .dst                            ( pred[6]                       )
);

VL4 U_VL4(
    .top                            ( top_i                         ),
    .top_right                      ( top_right_i                   ),
    .dst                            ( pred[7]                       )
);

HD4 U_HD4(
    .top_left                       ( top_left_i                    ),
    .top                            ( top_i[23:0]                   ),
    .left                           ( left_i                        ),
    .dst                            ( pred[8]                       )
);

HU4 U_HU4(
    .left                           ( left_i                        ),
    .dst                            ( pred[9]                       )
);

reg [   3:0]i4;
reg [ 127:0]src;
wire[ 127:0]dst[9:0];
wire[ 255:0]YLevels[9:0];
wire[   9:0]nz_i;
reg         rec_start;
wire[   9:0]rec_done;
wire[ 255:0]kWeightY;
wire[  31:0]sse[9:0];
wire[   9:0]sse_done;
wire[  31:0]disto[9:0];
wire[   9:0]disto_done;
wire[  31:0]sum[9:0];
wire[   9:0]cost_done;
wire[  15:0]FixedCost[9:0];
wire[  63:0]score[9:0];
reg [  63:0]score_tmp;
reg [   3:0]mode;
reg [ 127:0]o_tmp;
reg [ 127:0]pred_r[9:0];


assign FixedCost[0] = 'd40;
assign FixedCost[1] = 'd1151;
assign FixedCost[2] = 'd1723;
assign FixedCost[3] = 'd1874;
assign FixedCost[4] = 'd2103;
assign FixedCost[5] = 'd2019;
assign FixedCost[6] = 'd1628;
assign FixedCost[7] = 'd1777;
assign FixedCost[8] = 'd2226;
assign FixedCost[9] = 'd2137;

assign kWeightY[ 15:  0] = 'd38;
assign kWeightY[ 31: 16] = 'd32;
assign kWeightY[ 47: 32] = 'd20;
assign kWeightY[ 63: 48] = 'd9;
assign kWeightY[ 79: 64] = 'd32;
assign kWeightY[ 95: 80] = 'd28;
assign kWeightY[111: 96] = 'd17;
assign kWeightY[127:112] = 'd7;
assign kWeightY[143:128] = 'd20;
assign kWeightY[159:144] = 'd17;
assign kWeightY[175:160] = 'd10;
assign kWeightY[191:176] = 'd4;
assign kWeightY[207:192] = 'd9;
assign kWeightY[223:208] = 'd7;
assign kWeightY[239:224] = 'd4;
assign kWeightY[255:240] = 'd2;

generate

for(i = 0; i < 10; i = i + 1)begin
Reconstruct4 U_RECONSTRUCT4(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( rec_start                     ),
    .YPred                          ( pred_r[i]                     ),
    .Ysrc                           ( src                           ),
    .q                              ( q                             ),
    .iq                             ( iq                            ),
    .bias                           ( bias                          ),
    .zthresh                        ( zthresh                       ),
    .sharpen                        ( sharpen                       ),
    .Yout                           ( dst[i]                        ),
    .YLevels                        ( YLevels[i]                    ),
    .nz                             ( nz_i[i]                       ),
    .done                           ( rec_done[i]                   )
);

GetSSE4 U_GETSSE4(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( rec_done[i]                   ),
    .a                              ( src                           ),
    .b                              ( dst[i]                        ),
    .sse                            ( sse[i]                        ),
    .done                           ( sse_done[i]                   )
);

Disto4x4 U_DISTO4X4(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( rec_done[i]                   ),
    .ina                            ( src                           ),
    .inb                            ( dst[i]                        ),
    .w                              ( kWeightY                      ),
    .sum                            ( disto[i]                      ),
    .done                           ( disto_done[i]                 )
);

GetCostLuma4 U_GETCOSTLUMA4(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( rec_done[i]                   ),
    .levels                         ( YLevels[i]                    ),
    .sum                            ( sum[i]                        ),
    .done                           ( cost_done[i]                  )
);

RDScore U_RDSCORE(
    .lambda                         ( lambda_i4                     ),
    .tlambda                        ( tlambda                       ),
    .D                              ( sse[i]                        ),
    .SD                             ( disto[i]                      ),
    .H                              ( {16'b0,FixedCost[i]}          ),
    .R                              ( sum[i]                        ),
    .score                          ( score[i]                      )
);
end

endgenerate

wire[ 3:0]bestmode;
BestScore U_BESTSCORE(
    .score0                         ( score[0]                      ),
    .score1                         ( score[1]                      ),
    .score2                         ( score[2]                      ),
    .score3                         ( score[3]                      ),
    .score4                         ( score[4]                      ),
    .score5                         ( score[5]                      ),
    .score6                         ( score[6]                      ),
    .score7                         ( score[7]                      ),
    .score8                         ( score[8]                      ),
    .score9                         ( score[9]                      ),
    .mode                           ( bestmode                      )
);

wire[ 31:0]left_w;
wire[  7:0]top_left_w;
wire[ 31:0]top_w;
wire[ 31:0]top_right_w;
reg load;
RotateI4 U_ROTATEI4(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .load                           ( load                          ),
    .i4                             ( i4                            ),
    .Yin                            ( o_tmp                         ),
    .top_left                       ( top_left                      ),
    .top                            ( top                           ),
    .left                           ( left                          ),
    .left_i                         ( left_w                        ),
    .top_left_i                     ( top_left_w                    ),
    .top_i                          ( top_w                         ),
    .top_right_i                    ( top_right_w                   )
);

reg [8:0] cstate;
reg [8:0] nstate;

parameter IDLE        = 'h1;
parameter INIT        = 'h2;
parameter PRED        = 'h4;
parameter WAIT        = 'h8;
parameter SCORE       = 'h10;
parameter BEST        = 'h20;
parameter STORE       = 'h40;
parameter ROTATE      = 'h80;
parameter DONE        = 'h100; 

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
                nstate = INIT;
            else
                nstate = IDLE;
        INIT:
            nstate = PRED;
        PRED:
            nstate = WAIT;
        WAIT:
            if(disto_done[0])
                nstate = SCORE;
            else
                nstate = WAIT;
        SCORE:
            nstate = BEST;
        BEST:
            nstate = STORE;
        STORE:
            nstate = ROTATE;
        ROTATE:
            if(i4 >= 'd15)
                nstate = DONE;
            else
                nstate = PRED;
        DONE:
            nstate = IDLE;
        default:
            nstate = IDLE;
    endcase
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        i4           <= 'b0;
        rec_start    <= 'b0;
        left_i       <= 'b0;
        top_left_i   <= 'b0;
        top_i        <= 'b0;
        top_right_i  <= 'b0;
        src          <= 'b0;
        Score        <= 'b0;
        score_tmp    <= 'b0;
        mode         <= 'b0;
        o_tmp        <= 'b0;
        nz           <= 'b0;
        load         <= 'b0;
        pred_r[0]    <= 'b0;
        pred_r[1]    <= 'b0;
        pred_r[2]    <= 'b0;
        pred_r[3]    <= 'b0;
        pred_r[4]    <= 'b0;
        pred_r[5]    <= 'b0;
        pred_r[6]    <= 'b0;
        pred_r[7]    <= 'b0;
        pred_r[8]    <= 'b0;
        pred_r[9]    <= 'b0;
        mode_i[ 0]   <= 'b0;
        mode_i[ 1]   <= 'b0;
        mode_i[ 2]   <= 'b0;
        mode_i[ 3]   <= 'b0;
        mode_i[ 4]   <= 'b0;
        mode_i[ 5]   <= 'b0;
        mode_i[ 6]   <= 'b0;
        mode_i[ 7]   <= 'b0;
        mode_i[ 8]   <= 'b0;
        mode_i[ 9]   <= 'b0;
        mode_i[10]   <= 'b0;
        mode_i[11]   <= 'b0;
        mode_i[12]   <= 'b0;
        mode_i[13]   <= 'b0;
        mode_i[14]   <= 'b0;
        mode_i[15]   <= 'b0;
        Yout_i[ 0]   <= 'b0;
        Yout_i[ 1]   <= 'b0;
        Yout_i[ 2]   <= 'b0;
        Yout_i[ 3]   <= 'b0;
        Yout_i[ 4]   <= 'b0;
        Yout_i[ 5]   <= 'b0;
        Yout_i[ 6]   <= 'b0;
        Yout_i[ 7]   <= 'b0;
        Yout_i[ 8]   <= 'b0;
        Yout_i[ 9]   <= 'b0;
        Yout_i[10]   <= 'b0;
        Yout_i[11]   <= 'b0;
        Yout_i[12]   <= 'b0;
        Yout_i[13]   <= 'b0;
        Yout_i[14]   <= 'b0;
        Yout_i[15]   <= 'b0;
        levels_i[ 0] <= 'b0;
        levels_i[ 1] <= 'b0;
        levels_i[ 2] <= 'b0;
        levels_i[ 3] <= 'b0;
        levels_i[ 4] <= 'b0;
        levels_i[ 5] <= 'b0;
        levels_i[ 6] <= 'b0;
        levels_i[ 7] <= 'b0;
        levels_i[ 8] <= 'b0;
        levels_i[ 9] <= 'b0;
        levels_i[10] <= 'b0;
        levels_i[11] <= 'b0;
        levels_i[12] <= 'b0;
        levels_i[13] <= 'b0;
        levels_i[14] <= 'b0;
        levels_i[15] <= 'b0;
        done         <= 'b0;
    end
    else begin
        case(cstate)
            IDLE:begin
                done         <= 1'b0;
            end
            INIT:begin
                i4           <= 'b0;
                left_i       <= left;
                top_left_i   <= top_left;
                top_i        <= top[31: 0];
                top_right_i  <= top[63:32];
                src          <= Ysrc_i[0];
                Score        <= 'd211 * lambda_mode;
            end
            PRED:begin
                pred_r[0]    <= pred[0];
                pred_r[1]    <= pred[1];
                pred_r[2]    <= pred[2];
                pred_r[3]    <= pred[3];
                pred_r[4]    <= pred[4];
                pred_r[5]    <= pred[5];
                pred_r[6]    <= pred[6];
                pred_r[7]    <= pred[7];
                pred_r[8]    <= pred[8];
                pred_r[9]    <= pred[9];
                rec_start    <= 1'b1;
            end
            WAIT:begin
                rec_start    <= 1'b0;
            end
            SCORE:begin
                ;
            end
            BEST:begin
                mode         <= bestmode;
            end
            STORE:begin
                mode_i[i4]   <= {4'b0,mode};
                Yout_i[i4]   <= dst[mode];
                o_tmp        <= dst[mode];
                levels_i[i4] <= YLevels[mode];
                nz[i4]       <= nz_i[mode];
                score_tmp    <= ((sum[mode] << 10) + FixedCost[mode]) * lambda_mode +
                                (sse[mode] << 8) + disto[mode] * tlambda;
                load         <= 1'b1;
            end
            ROTATE:begin
                i4           <= i4 + 1'b1;
                left_i       <= left_w;
                top_left_i   <= top_left_w;
                top_i        <= top_w;
                top_right_i  <= top_right_w;
                src          <= Ysrc_i[i4 + 1'b1];
                Score        <= Score + score_tmp;
                load         <= 1'b0;
            end
            DONE:begin
                done         <= 1'b1;
            end
        endcase
    end
end

endmodule
