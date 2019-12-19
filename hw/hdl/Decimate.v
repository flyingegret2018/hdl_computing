//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	Decimate.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-17 13:30
// LastModified   :	2019-12-12 10:12
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module Decimate#(
 parameter BLOCK_SIZE   = 16
)(
 input                                            clk
,input                                            rst_n
,input                                            start
,input             [10                   - 1 : 0] x
,input             [10                   - 1 : 0] y
,input             [ 8 * 16 * BLOCK_SIZE - 1 : 0] Yin
,input             [ 8 *  8 * BLOCK_SIZE - 1 : 0] UVin
,input      signed [32                   - 1 : 0] lambda_i16
,input      signed [32                   - 1 : 0] lambda_i4
,input      signed [32                   - 1 : 0] lambda_uv
,input      signed [32                   - 1 : 0] tlambda
,input      signed [32                   - 1 : 0] lambda_mode
,input      signed [32                   - 1 : 0] min_disto
,input      signed [32                   - 1 : 0] max_edgei
,input                                            reload
,input             [ 8                   - 1 : 0] top_left_y
,input             [ 8                   - 1 : 0] top_left_u
,input             [ 8                   - 1 : 0] top_left_v
,input             [ 8 * 20              - 1 : 0] top_y
,input             [ 8 *  8              - 1 : 0] top_u
,input             [ 8 *  8              - 1 : 0] top_v
,input             [ 8 * 16              - 1 : 0] left_y
,input             [ 8 *  8              - 1 : 0] left_u
,input             [ 8 *  8              - 1 : 0] left_v
,input             [16 * 16              - 1 : 0] y1_q
,input             [16 * 16              - 1 : 0] y1_iq
,input             [32 * 16              - 1 : 0] y1_bias
,input             [32 * 16              - 1 : 0] y1_zthresh
,input             [16 * 16              - 1 : 0] y1_sharpen
,input             [16 * 16              - 1 : 0] y2_q
,input             [16 * 16              - 1 : 0] y2_iq
,input             [32 * 16              - 1 : 0] y2_bias
,input             [32 * 16              - 1 : 0] y2_zthresh
,input             [16 * 16              - 1 : 0] y2_sharpen
,input             [16 * 16              - 1 : 0] uv_q
,input             [16 * 16              - 1 : 0] uv_iq
,input             [32 * 16              - 1 : 0] uv_bias
,input             [32 * 16              - 1 : 0] uv_zthresh
,input             [16 * 16              - 1 : 0] uv_sharpen
,output reg        [ 8 * 16 * BLOCK_SIZE - 1 : 0] Yout
,output            [ 8 *  8 * BLOCK_SIZE - 1 : 0] UVout
,output            [32                   - 1 : 0] mode_i16
,output            [ 8 * 16              - 1 : 0] mode_i4
,output            [32                   - 1 : 0] mode_uv
,output            [16 * 16              - 1 : 0] dc_levels
,output reg        [16 * 16 * BLOCK_SIZE - 1 : 0] ac_levels
,output            [16 *  8 * BLOCK_SIZE - 1 : 0] uv_levels
,output reg        [ 8                   - 1 : 0] skipped
,output            [ 8                   - 1 : 0] mbtype
,output reg        [32                   - 1 : 0] nz
,output            [32                   - 1 : 0] max_edgeo
,output reg                                       done
);

wire[  63:0]Yscore;
wire[  31:0]Ynz;
wire[4095:0]ac_levels0;
wire[2047:0]Yout16;
reg         mbtype_i;
assign mbtype = {7'b0,mbtype_i};

PickBestIntra U_PICKBESTINTRA(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( start                         ),
    .x                              ( x                             ),
    .y                              ( y                             ),
    .lambda_i16                     ( lambda_i16                    ),
    .tlambda                        ( tlambda                       ),
    .lambda_mode                    ( lambda_mode                   ),
    .min_disto                      ( min_disto                     ),
    .max_edgei                      ( max_edgei                     ),
    .reload                         ( reload                        ),
    .Ysrc                           ( Yin                           ),
    .top_left                       ( top_left_y                    ),
    .top                            ( top_y[127:0]                  ),
    .left                           ( left_y                        ),
    .q1                             ( y1_q                          ),
    .iq1                            ( y1_iq                         ),
    .bias1                          ( y1_bias                       ),
    .zthresh1                       ( y1_zthresh                    ),
    .sharpen1                       ( y1_sharpen                    ),
    .q2                             ( y2_q                          ),
    .iq2                            ( y2_iq                         ),
    .bias2                          ( y2_bias                       ),
    .zthresh2                       ( y2_zthresh                    ),
    .sharpen2                       ( y2_sharpen                    ),
    .out                            ( Yout16                        ),
    .Score                          ( Yscore                        ),
    .mode_i16                       ( mode_i16                      ),
    .max_edgeo                      ( max_edgeo                     ),
    .dc_levels                      ( dc_levels                     ),
    .ac_levels                      ( ac_levels0                    ),
    .nz                             ( Ynz                           ),
    .done                           (                               )
);

wire[  63:0]Yscore4;
wire[  31:0]Ynz4;
wire[4095:0]ac_levels1;
wire[2047:0]Yout4;
wire        PB4_done;
PickBestIntra4 U_PICKBESTINTRA4(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( start                         ),
    .lambda_i4                      ( lambda_i4                     ),
    .tlambda                        ( tlambda                       ),
    .lambda_mode                    ( lambda_mode                   ),
    .Ysrc                           ( Yin                           ),
    .top_left                       ( top_left_y                    ),
    .top                            ( top_y                         ),
    .left                           ( left_y                        ),
    .q                              ( y1_q                          ),
    .iq                             ( y1_iq                         ),
    .bias                           ( y1_bias                       ),
    .zthresh                        ( y1_zthresh                    ),
    .sharpen                        ( y1_sharpen                    ),
    .Yout                           ( Yout4                         ),
    .Score                          ( Yscore4                       ),
    .mode_i4                        ( mode_i4                       ),
    .levels                         ( ac_levels1                    ),
    .nz                             ( Ynz4                          ),
    .done                           ( PB4_done                      )
);

wire[  31:0]UVnz;
PickBestUV U_PICKBESTUV(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( start                         ),
    .x                              ( x                             ),
    .y                              ( y                             ),
    .lambda_uv                      ( lambda_uv                     ),
    .in                             ( UVin                          ),
    .top_left_u                     ( top_left_u                    ),
    .top_left_v                     ( top_left_v                    ),
    .top_v                          ( top_v                         ),
    .top_u                          ( top_u                         ),
    .left_u                         ( left_u                        ),
    .left_v                         ( left_v                        ),
    .q                              ( uv_q                          ),
    .iq                             ( uv_iq                         ),
    .bias                           ( uv_bias                       ),
    .zthresh                        ( uv_zthresh                    ),
    .sharpen                        ( uv_sharpen                    ),
    .out                            ( UVout                         ),
    .mode_uv                        ( mode_uv                       ),
    .levels                         ( uv_levels                     ),
    .nz                             ( UVnz                          ),
    .done                           (                               )
);

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        done      <= 'b0;
        ac_levels <= 'b0;
        Yout      <= 'b0;
        mbtype_i  <= 'b0;
        nz        <= 'b0;
        skipped   <= 'b0;
    end
    else begin
        if(PB4_done)begin
            done      <= 1'b1;
            if(Yscore4 >= Yscore)begin
                ac_levels <= ac_levels0;
                Yout      <= Yout16;
                mbtype_i  <= 1'b1;
                nz        <= {7'b0,Ynz[24],UVnz[23:16],Ynz[15:0]};
                skipped   <= {Ynz[24],UVnz[23:16],Ynz[15:0]} == 'b0;
            end
            else begin
                ac_levels <= ac_levels1;
                Yout      <= Yout4;
                mbtype_i  <= 1'b0;
                nz        <= {8'b0,UVnz[23:16],Ynz4[15:0]};
                skipped   <= {UVnz[23:16],Ynz4[15:0]} == 'b0;
            end
        end
        else begin
            done      <= 1'b0;
        end
    end
end

endmodule
