//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	Reconstruct.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-17 13:30
// LastModified   :	2019-11-21 13:31
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module Reconstruct#(
 parameter BLOCK_SIZE   = 8
)(
 input                             clk
,input                             rst_n
,input                             start
,input      [ 9               : 0] x
,input      [ 9               : 0] y
,input      [ 8 *  8 * 16 - 1 : 0] UVsrc
,input      [ 8 *  8 * 16 - 1 : 0] UVPred
,input      [16 * 16      - 1 : 0] q
,input      [16 * 16      - 1 : 0] iq
,input      [32 * 16      - 1 : 0] bias
,input      [32 * 16      - 1 : 0] zthresh
,input      [16 * 16      - 1 : 0] sharpen
,input      [31               : 0] left_derr
,input      [31               : 0] top_derr
,output                            top_derr_en
,output     [ 9               : 0] top_derr_addr
,output     [ 8 *  8 * 16 - 1 : 0] UVout
,output     [16 *  8 * 16 - 1 : 0] UVlevels
,input      [47               : 0] derr
,output                            done
);

wire        [ 8 * 16 - 1 : 0]UVsrc_i     [BLOCK_SIZE - 1 : 0];
wire        [ 8 * 16 - 1 : 0]UVPred_i    [BLOCK_SIZE - 1 : 0];
wire        [ 8 * 16 - 1 : 0]UVout_i     [BLOCK_SIZE - 1 : 0];
wire signed [12 * 16 - 1 : 0]FDCT_o      [BLOCK_SIZE - 1 : 0];
wire signed [16 * 16 - 1 : 0]UVlevels_i  [BLOCK_SIZE - 1 : 0];

genvar i;

generate

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    assign UVsrc_i[i] = 
    {UVsrc[8*((i/4)*64+(i%4)*4+52)-1:8*((i/4)*64+(i%4)*4+48)],
     UVsrc[8*((i/4)*64+(i%4)*4+36)-1:8*((i/4)*64+(i%4)*4+32)],
     UVsrc[8*((i/4)*64+(i%4)*4+20)-1:8*((i/4)*64+(i%4)*4+16)],
     UVsrc[8*((i/4)*64+(i%4)*4+ 4)-1:8*((i/4)*64+(i%4)*4+ 0)]};

    assign UVPred_i[i] = 
    {UVPred[8*((i/4)*64+(i%4)*4+52)-1:8*((i/4)*64+(i%4)*4+48)],
     UVPred[8*((i/4)*64+(i%4)*4+36)-1:8*((i/4)*64+(i%4)*4+32)],
     UVPred[8*((i/4)*64+(i%4)*4+20)-1:8*((i/4)*64+(i%4)*4+16)],
     UVPred[8*((i/4)*64+(i%4)*4+ 4)-1:8*((i/4)*64+(i%4)*4+ 0)]};

    assign 
    {UVout[8*((i/4)*64+(i%4)*4+52)-1:8*((i/4)*64+(i%4)*4+48)],
     UVout[8*((i/4)*64+(i%4)*4+36)-1:8*((i/4)*64+(i%4)*4+32)],
     UVout[8*((i/4)*64+(i%4)*4+20)-1:8*((i/4)*64+(i%4)*4+16)],
     UVout[8*((i/4)*64+(i%4)*4+ 4)-1:8*((i/4)*64+(i%4)*4+ 0)]}
     = UVout_i[i];
end

assign UVlevels[ 15 :   0] = UVlevels_i[0];
assign UVlevels[ 31 :  16] = UVlevels_i[1];
assign UVlevels[ 47 :  32] = UVlevels_i[4];
assign UVlevels[ 63 :  48] = UVlevels_i[5];
assign UVlevels[ 79 :  64] = UVlevels_i[2];
assign UVlevels[ 95 :  80] = UVlevels_i[3];
assign UVlevels[111 :  96] = UVlevels_i[6];
assign UVlevels[127 : 112] = UVlevels_i[7];

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin:FDCT
    wire FDCT_done;
FTransform U_FDCT(
     .clk                           ( clk                           )
    ,.rst_n                         ( rst_n                         )
    ,.start                         ( start                         )
    ,.src                           ( UVsrc[i]                      )
    ,.ref                           ( UVPred[i]                     )
    ,.out                           ( FDCT_o[i]                     )
    ,.done                          ( FDCT_done                     )
    );
end

wire [127:0]CDCV_i;
assign CDCV_i = {{4'b0,FDCT_o[7][11:0]},
                 {4'b0,FDCT_o[6][11:0]},
                 {4'b0,FDCT_o[5][11:0]},
                 {4'b0,FDCT_o[4][11:0]},
                 {4'b0,FDCT_o[3][11:0]},
                 {4'b0,FDCT_o[2][11:0]},
                 {4'b0,FDCT_o[1][11:0]},
                 {4'b0,FDCT_o[0][11:0]}};

wire CDCV_done;
wire [127:0]CDCV_o;
CorrectDCValues U_CDCV(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( FDCT[0].FDCT_done             ),
    .x                              ( x                             ),
    .y                              ( y                             ),
    .in                             ( CDCV_i                        ),
    .q                              ( q[15:0]                       ),
    .iq                             ( iq[15:0]                      ),
    .bias                           ( bias[31:0]                    ),
    .zthresh                        ( zthresh[31:0]                 ),
    .left_derr                      ( left_derr                     ),
    .top_derr                       ( top_derr                      ),
    .top_derr_en                    ( top_derr_en                   ),
    .top_derr_addr                  ( top_derr_addr                 ),
    .out                            ( CDCV_o                        ),
    .derr                           ( derr                          ),
    .done                           ( CDCV_done                     )
);

wire [255:0]QB_i[BLOCK_SIZE - 1 : 0];
for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    assign QB_i[i] = {{4'b0,FDCT_o[i][191:180]},
                      {4'b0,FDCT_o[i][179:168]},
                      {4'b0,FDCT_o[i][167:156]},
                      {4'b0,FDCT_o[i][155:144]},
                      {4'b0,FDCT_o[i][143:132]},
                      {4'b0,FDCT_o[i][131:120]},
                      {4'b0,FDCT_o[i][119:108]},
                      {4'b0,FDCT_o[i][107: 96]},
                      {4'b0,FDCT_o[i][ 95: 84]},
                      {4'b0,FDCT_o[i][ 83: 72]},
                      {4'b0,FDCT_o[i][ 71: 60]},
                      {4'b0,FDCT_o[i][ 59: 48]},
                      {4'b0,FDCT_o[i][ 47: 36]},
                      {4'b0,FDCT_o[i][ 35: 24]},
                      {4'b0,FDCT_o[i][ 23: 12]},
                      CDCV_o[16 * (i + 1) : 16 * i]};
end

wire [16 * 16 - 1 : 0]QB_Rout[BLOCK_SIZE - 1 : 0];
for(i = 0; i < BLOCK_SIZE; i = i + 1)begin:QB
wire QB_done;
QuantizeBlock U_QB(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( CDCV_done                     ),
    .in                             ( QB_i[i]                       ),
    .q                              ( q                             ),
    .iq                             ( iq                            ),
    .bias                           ( bias                          ),
    .zthresh                        ( zthresh                       ),
    .sharpen                        ( sharpen                       ),
    .Rout                           ( QB_Rout[i]                    ),
    .out                            ( UVlevels_i[i]                 ),
    .done                           ( QB_done                       )
);
end

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
ITransform U_IDCT(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( QB[0].QB_done                 ),
    .src                            ( QB_rout[i]                    ),
    .ref                            ( UVPred_i[i]                   ),
    .out                            ( UVout_i[i]                    ),
    .done                           ( done                          )
);
end

endgenerate

endmodule
