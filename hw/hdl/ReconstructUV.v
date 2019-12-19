//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	ReconstructUV.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-17 13:30
// LastModified   :	2019-12-11 14:00
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module ReconstructUV#(
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
,output     [47               : 0] derr
,output     [31               : 0] nz
,output                            done
);

wire        [ 8 * 16 - 1 : 0]UVsrc_i     [BLOCK_SIZE - 1 : 0];
wire        [ 8 * 16 - 1 : 0]UVPred_i    [BLOCK_SIZE - 1 : 0];
wire        [ 8 * 16 - 1 : 0]UVout_i     [BLOCK_SIZE - 1 : 0];
wire signed [12 * 16 - 1 : 0]FDCT_o      [BLOCK_SIZE - 1 : 0];
wire signed [16 * 16 - 1 : 0]UVlevels_i  [BLOCK_SIZE - 1 : 0];

assign UVsrc_i[0] = {UVsrc[ 415:384],UVsrc[287:256],UVsrc[159:128],UVsrc[ 31:  0]};
assign UVsrc_i[1] = {UVsrc[ 447:416],UVsrc[319:288],UVsrc[191:160],UVsrc[ 63: 32]};
assign UVsrc_i[2] = {UVsrc[ 927:896],UVsrc[799:768],UVsrc[671:640],UVsrc[543:512]};
assign UVsrc_i[3] = {UVsrc[ 959:928],UVsrc[831:800],UVsrc[703:672],UVsrc[575:544]};
assign UVsrc_i[4] = {UVsrc[ 479:448],UVsrc[351:320],UVsrc[223:192],UVsrc[ 95: 64]};
assign UVsrc_i[5] = {UVsrc[ 511:480],UVsrc[383:352],UVsrc[255:224],UVsrc[127: 96]};
assign UVsrc_i[6] = {UVsrc[ 991:960],UVsrc[863:832],UVsrc[735:704],UVsrc[607:576]};
assign UVsrc_i[7] = {UVsrc[1023:992],UVsrc[895:864],UVsrc[767:736],UVsrc[639:608]};

assign UVPred_i[0] = {UVPred[ 415:384],UVPred[287:256],UVPred[159:128],UVPred[ 31:  0]};
assign UVPred_i[1] = {UVPred[ 447:416],UVPred[319:288],UVPred[191:160],UVPred[ 63: 32]};
assign UVPred_i[2] = {UVPred[ 927:896],UVPred[799:768],UVPred[671:640],UVPred[543:512]};
assign UVPred_i[3] = {UVPred[ 959:928],UVPred[831:800],UVPred[703:672],UVPred[575:544]};
assign UVPred_i[4] = {UVPred[ 479:448],UVPred[351:320],UVPred[223:192],UVPred[ 95: 64]};
assign UVPred_i[5] = {UVPred[ 511:480],UVPred[383:352],UVPred[255:224],UVPred[127: 96]};
assign UVPred_i[6] = {UVPred[ 991:960],UVPred[863:832],UVPred[735:704],UVPred[607:576]};
assign UVPred_i[7] = {UVPred[1023:992],UVPred[895:864],UVPred[767:736],UVPred[639:608]};

assign {UVout[ 415:384],UVout[287:256],UVout[159:128],UVout[ 31:  0]} = UVout_i[0];
assign {UVout[ 447:416],UVout[319:288],UVout[191:160],UVout[ 63: 32]} = UVout_i[1];
assign {UVout[ 927:896],UVout[799:768],UVout[671:640],UVout[543:512]} = UVout_i[2];
assign {UVout[ 959:928],UVout[831:800],UVout[703:672],UVout[575:544]} = UVout_i[3];
assign {UVout[ 479:448],UVout[351:320],UVout[223:192],UVout[ 95: 64]} = UVout_i[4];
assign {UVout[ 511:480],UVout[383:352],UVout[255:224],UVout[127: 96]} = UVout_i[5];
assign {UVout[ 991:960],UVout[863:832],UVout[735:704],UVout[607:576]} = UVout_i[6];
assign {UVout[1023:992],UVout[895:864],UVout[767:736],UVout[639:608]} = UVout_i[7];

genvar i;

generate

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
    ,.src                           ( UVsrc_i[i]                    )
    ,.ref                           ( UVPred_i[i]                   )
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
                      CDCV_o[16 * (i + 1) - 1: 16 * i]};
end

wire [7:0]QB_nz;
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
    .nz                             ( QB_nz[i]                      ),
    .done                           ( QB_done                       )
);
end

assign nz = {8'b0,QB_nz,16'b0};

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
wire [7:0]IDCT_done;
ITransform U_IDCT(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( QB[0].QB_done                 ),
    .src                            ( QB_Rout[i]                    ),
    .ref                            ( UVPred_i[i]                   ),
    .out                            ( UVout_i[i]                    ),
    .done                           ( IDCT_done[i]                  )
);
end

endgenerate

assign done = IDCT_done[0];

endmodule
