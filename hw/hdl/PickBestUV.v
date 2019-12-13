//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	PickBestUV.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-17 13:30
// LastModified   :	2019-12-11 13:31
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module PickBestUV#(
 parameter BLOCK_SIZE   = 8
)(
 input                                            clk
,input                                            rst_n
,input                                            start
,input             [10                   - 1 : 0] x
,input             [10                   - 1 : 0] y
,input      signed [32                   - 1 : 0] lambda_uv
,input             [ 8 * 16 * BLOCK_SIZE - 1 : 0] in
,input             [ 8                   - 1 : 0] top_left_u
,input             [ 8                   - 1 : 0] top_left_v
,input             [ 8 *  8              - 1 : 0] top_v
,input             [ 8 *  8              - 1 : 0] top_u
,input             [ 8 *  8              - 1 : 0] left_u
,input             [ 8 *  8              - 1 : 0] left_v
,input             [16 * 16              - 1 : 0] q
,input             [16 * 16              - 1 : 0] iq
,input             [32 * 16              - 1 : 0] bias
,input             [32 * 16              - 1 : 0] zthresh
,input             [16 * 16              - 1 : 0] sharpen
,output            [ 8 * 16 * BLOCK_SIZE - 1 : 0] out
,output            [32                   - 1 : 0] mode_uv
,output            [16 * 16 * BLOCK_SIZE - 1 : 0] levels
,output            [32                   - 1 : 0] nz
,output reg                                       done
);

wire [8 * 16 * BLOCK_SIZE - 1 : 0]pred[3:0];
DC_Pred_UV U_DC_PRED_UV(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( start                         ),
    .x                              ( x                             ),
    .y                              ( y                             ),
    .top_u                          ( top_u                         ),
    .top_v                          ( top_v                         ),
    .left_u                         ( left_u                        ),
    .left_v                         ( left_v                        ),
    .dst                            ( pred[3]                       ),
    .done                           (                               )
);

Vertical_Pred_UV U_VERTICAL_PRED_UV(
    .top_u                          ( top_u                         ),
    .top_v                          ( top_v                         ),
    .dst                            ( pred[0]                       )
);

Horizontal_Pred_UV U_HORIZONTAL_PRED_UV(
    .left_u                         ( left_u                        ),
    .left_v                         ( left_v                        ),
    .dst                            ( pred[1]                       )
);

True_Motion_Pred_UV U_TRUE_MOTION_PRED_UV(
    .top_left_u                     ( top_left_u                    ),
    .top_left_v                     ( top_left_v                    ),
    .top_u                          ( top_u                         ),
    .top_v                          ( top_v                         ),
    .left_u                         ( left_u                        ),
    .left_v                         ( left_v                        ),
    .dst                            ( pred[2]                       )
);

wire        rec_done;
reg         rec_start;
reg [1023:0]UVPred;
wire[1023:0]UVout;
wire[2047:0]UVlevels;
wire[  31:0]nz_i;
wire[  31:0]left_derr;
wire[  31:0]top_derr;
wire[   9:0]top_derr_addr;
wire        top_derr_en;
wire[  31:0]top_derr_w;
wire[   9:0]top_derr_waddr;
wire        top_derr_wen;
wire        top_derr_wea;
wire[  47:0]derr;
ReconstructUV U_RECONSTRUCTUV(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( rec_start                     ),
    .x                              ( x                             ),
    .y                              ( y                             ),
    .UVsrc                          ( in                            ),
    .UVPred                         ( UVPred                        ),
    .q                              ( q                             ),
    .iq                             ( iq                            ),
    .bias                           ( bias                          ),
    .zthresh                        ( zthresh                       ),
    .sharpen                        ( sharpen                       ),
    .left_derr                      ( left_derr                     ),
    .top_derr                       ( top_derr                      ),
    .top_derr_en                    ( top_derr_en                   ),
    .top_derr_addr                  ( top_derr_addr                 ),
    .UVout                          ( UVout                         ),
    .UVlevels                       ( UVlevels                      ),
    .derr                           ( derr                          ),
    .nz                             ( nz_i                          ),
    .done                           ( rec_done                      )
);

top_derr_ram U_TOP_DERR_RAM (
    .clka                           ( clk                           ),
    .ena                            ( top_derr_wen                  ),
    .wea                            ( top_derr_wea                  ),
    .addra                          ( top_derr_waddr                ),
    .dina                           ( top_derr_w                    ),
    .clkb                           ( clk                           ),
    .enb                            ( top_derr_en                   ),
    .addrb                          ( top_derr_addr                 ),
    .doutb                          ( top_derr                      )
);

reg  SDE_start;
wire SDE_done;
StoreDiffusionErrors U_STOREDIFFUSIONERRORS(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( SDE_start                     ),
    .x                              ( x                             ),
    .derr                           ( derr                          ),
    .left_derr                      ( left_derr                     ),
    .top_derr                       ( top_derr_w                    ),
    .top_derr_en                    ( top_derr_wen                  ),
    .top_derr_wea                   ( top_derr_wea                  ),
    .top_derr_addr                  ( top_derr_waddr                ),
    .done                           ( SDE_done                      )
);

wire[31:0]sse;
wire sse_done;
GetSSEUV U_GETSSEUV(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( rec_done                      ),
    .a                              ( in                            ),
    .b                              ( UVout                         ),
    .sse                            ( sse                           ),
    .done                           ( sse_done                      )
);

wire[31:0]sum;
wire cost_done;
GetCostLuma U_GETCOSTLUMA(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( rec_done                      ),
    .levels                         ( UVlevels                      ),
    .sum                            ( sum                           ),
    .done                           ( cost_done                     )
);

wire[15:0]FixedCost[3:0];
assign FixedCost[0] = 'd302;
assign FixedCost[1] = 'd984;
assign FixedCost[2] = 'd439;
assign FixedCost[3] = 'd642;

reg [   1:0]count;
reg [2047:0]levels_tmp;
reg [  31:0]nz_tmp;
reg [1023:0]UVout_tmp;
reg [  63:0]Score;
reg [  63:0]score_tmp;
reg [   1:0]uv;
reg [   1:0]mode;

assign levels = levels_tmp;
assign nz = nz_tmp;
assign out = UVout_tmp;
assign mode_uv = {'b0,mode};

reg [7:0] cstate;
reg [7:0] nstate;

parameter IDLE       = 'h1;
parameter PRED       = 'h2;
parameter WAIT       = 'h4; 
parameter FIRSTSCORE = 'h8;
parameter SCORE      = 'h10;
parameter COMP       = 'h20;
parameter STORE      = 'h40;
parameter DONE       = 'h80;

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
                nstate = PRED;
            else
                nstate = IDLE;
        PRED:
            nstate = WAIT;
        WAIT:
            if(count == 2'b11)
                if(uv == 'b1)
                    nstate = FIRSTSCORE;
                else
                    nstate = SCORE;
            else
                nstate = WAIT;
        FIRSTSCORE:
            nstate = PRED;
        SCORE:
            nstate = COMP;
        COMP:
            if(Score > score_tmp)
                nstate = STORE;
            else
                if(uv == 'd0)
                    nstate = DONE;
                else
                    nstate = PRED;
        STORE:
            if(uv == 'd0)
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
        rec_start  <= 'b0;
        SDE_start  <= 'b0;
        levels_tmp <= 'b0;
        nz_tmp     <= 'b0;
        Score      <= 'b0;
        score_tmp  <= 'b0;
        UVout_tmp  <= 'b0;
        mode       <= 'b0;
        uv         <= 'b0;
        done       <= 'b0;
    end
    else begin
        case(cstate)
            IDLE:begin
                uv         <= 2'b0;
                SDE_start  <= 1'b0;
                done       <= 1'b0;
            end
            PRED:begin
                rec_start  <= 1'b1;
                UVPred     <= pred[uv];
                uv         <= uv + 1'b1;
            end
            WAIT:begin
                rec_start  <= 1'b0;
            end
            FIRSTSCORE:begin
                Score      <= ((sum << 10) + FixedCost[1]) * lambda_uv + 'd256 * sse;
                mode       <= 2'b1;
                uv         <= 2'b1;
                levels_tmp <= UVlevels;
                UVout_tmp  <= UVout;
                nz_tmp     <= nz_i;
            end
            SCORE:begin
                score_tmp  <= ((sum << 10) + FixedCost[uv]) * lambda_uv + 'd256 * sse;
            end
            COMP:begin
                ;
            end
            STORE:begin
                mode       <= uv;
                levels_tmp <= UVlevels;
                UVout_tmp  <= UVout;
                nz_tmp     <= nz_i;
                Score      <= score_tmp;
            end
            DONE:begin
                done       <= 1'b1;
                SDE_start  <= 1'b1;
            end
        endcase
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        count <= 'b0;
    end
    else begin
        if(rec_done)
            count <= 'b0;
        else
            case({sse_done,disto_done,cost_done})
                3'b111:count <= count + 2'b11;
                3'b110:count <= count + 2'b10;
                3'b101:count <= count + 2'b10;
                3'b011:count <= count + 2'b10;
                3'b001:count <= count + 2'b01;
                3'b010:count <= count + 2'b01;
                3'b100:count <= count + 2'b01;
                3'b000:count <= count + 2'b00;
            endcase
    end
end

endmodule
