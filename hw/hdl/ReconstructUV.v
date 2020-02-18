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
,output reg                        done
);

reg  [ 8      - 1 : 0]count;
wire [ 8 * 16 - 1 : 0]UVsrc_w     [BLOCK_SIZE - 1 : 0];
wire [ 8 * 16 - 1 : 0]UVPred_w    [BLOCK_SIZE - 1 : 0];
reg  [ 8 * 16 - 1 : 0]UVout_r     [BLOCK_SIZE - 1 : 0];
reg  [ 8 * 16 - 1 : 0]UVsrc_r;
reg  [ 8 * 16 - 1 : 0]UVPred_r;
wire [ 8 * 16 - 1 : 0]UVout_w;
reg  [16 * 16 - 1 : 0]FDCT_o      [BLOCK_SIZE - 1 : 0];
wire [16 * 16 - 1 : 0]FDCT_w;
reg  [16 *  8 - 1 : 0]CDCV_i;
wire [16 *  8 - 1 : 0]CDCV_o;
reg  [16 * 16 - 1 : 0]QB_i;
reg  [16 * 16 - 1 : 0]UVlevels_i  [BLOCK_SIZE - 1 : 0];
wire [16 * 16 - 1 : 0]UVlevels_w;
wire [16 * 16 - 1 : 0]QB_Rout_w;
reg  [ 8      - 1 : 0]QB_nz;
wire [ 1      - 1 : 0]QB_nz_w;

assign nz = {8'b0,QB_nz,16'b0};

assign UVsrc_w[0] = {UVsrc[ 415:384],UVsrc[287:256],UVsrc[159:128],UVsrc[ 31:  0]};
assign UVsrc_w[1] = {UVsrc[ 447:416],UVsrc[319:288],UVsrc[191:160],UVsrc[ 63: 32]};
assign UVsrc_w[2] = {UVsrc[ 927:896],UVsrc[799:768],UVsrc[671:640],UVsrc[543:512]};
assign UVsrc_w[3] = {UVsrc[ 959:928],UVsrc[831:800],UVsrc[703:672],UVsrc[575:544]};
assign UVsrc_w[4] = {UVsrc[ 479:448],UVsrc[351:320],UVsrc[223:192],UVsrc[ 95: 64]};
assign UVsrc_w[5] = {UVsrc[ 511:480],UVsrc[383:352],UVsrc[255:224],UVsrc[127: 96]};
assign UVsrc_w[6] = {UVsrc[ 991:960],UVsrc[863:832],UVsrc[735:704],UVsrc[607:576]};
assign UVsrc_w[7] = {UVsrc[1023:992],UVsrc[895:864],UVsrc[767:736],UVsrc[639:608]};

assign UVPred_w[0] = {UVPred[ 415:384],UVPred[287:256],UVPred[159:128],UVPred[ 31:  0]};
assign UVPred_w[1] = {UVPred[ 447:416],UVPred[319:288],UVPred[191:160],UVPred[ 63: 32]};
assign UVPred_w[2] = {UVPred[ 927:896],UVPred[799:768],UVPred[671:640],UVPred[543:512]};
assign UVPred_w[3] = {UVPred[ 959:928],UVPred[831:800],UVPred[703:672],UVPred[575:544]};
assign UVPred_w[4] = {UVPred[ 479:448],UVPred[351:320],UVPred[223:192],UVPred[ 95: 64]};
assign UVPred_w[5] = {UVPred[ 511:480],UVPred[383:352],UVPred[255:224],UVPred[127: 96]};
assign UVPred_w[6] = {UVPred[ 991:960],UVPred[863:832],UVPred[735:704],UVPred[607:576]};
assign UVPred_w[7] = {UVPred[1023:992],UVPred[895:864],UVPred[767:736],UVPred[639:608]};

assign {UVout[ 415:384],UVout[287:256],UVout[159:128],UVout[ 31:  0]} = UVout_r[0];
assign {UVout[ 447:416],UVout[319:288],UVout[191:160],UVout[ 63: 32]} = UVout_r[1];
assign {UVout[ 927:896],UVout[799:768],UVout[671:640],UVout[543:512]} = UVout_r[2];
assign {UVout[ 959:928],UVout[831:800],UVout[703:672],UVout[575:544]} = UVout_r[3];
assign {UVout[ 479:448],UVout[351:320],UVout[223:192],UVout[ 95: 64]} = UVout_r[4];
assign {UVout[ 511:480],UVout[383:352],UVout[255:224],UVout[127: 96]} = UVout_r[5];
assign {UVout[ 991:960],UVout[863:832],UVout[735:704],UVout[607:576]} = UVout_r[6];
assign {UVout[1023:992],UVout[895:864],UVout[767:736],UVout[639:608]} = UVout_r[7];

assign UVlevels[ 255:   0] = UVlevels_i[0];
assign UVlevels[ 511: 256] = UVlevels_i[1];
assign UVlevels[ 767: 512] = UVlevels_i[2];
assign UVlevels[1023: 768] = UVlevels_i[3];
assign UVlevels[1279:1024] = UVlevels_i[4];
assign UVlevels[1535:1280] = UVlevels_i[5];
assign UVlevels[1791:1536] = UVlevels_i[6];
assign UVlevels[2047:1792] = UVlevels_i[7];

FTransform #(
    .I_WIDTH                        (  8                            ),
    .O_WIDTH                        ( 16                            ))
U_FDCT(
     .clk                           ( clk                           )
    ,.rst_n                         ( rst_n                         )
    ,.start                         (                               )
    ,.src                           ( UVsrc_r                       )
    ,.ref                           ( UVPred_r                      )
    ,.out                           ( FDCT_w                        )
    ,.done                          (                               )
);

CorrectDCValues U_CDCV(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          (                               ),
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
    .done                           (                               )
);

QuantizeBlock #(
    .BLOCK_SIZE                     ( 4                             ),
    .IW                             ( 16                            ))
U_QB(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          (                               ),
    .in                             ( QB_i                          ),
    .q                              ( q                             ),
    .iq                             ( iq                            ),
    .bias                           ( bias                          ),
    .zthresh                        ( zthresh                       ),
    .sharpen                        ( sharpen                       ),
    .Rout                           ( QB_Rout_w                     ),
    .out                            ( UVlevels_w                    ),
    .nz                             ( QB_nz_w                       ),
    .done                           (                               )
);

ITransform U_IDCT(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          (                               ),
    .src                            ( QB_Rout_w                     ),
    .ref                            ( UVPred_r                      ),
    .out                            ( UVout_w                       ),
    .done                           (                               )
);

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        count <= 'b0;
    else
        if(count >= 'd31)
            count <= 'b0;
        else if(start | count != 'b0)
            count <= count + 1'b1;
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        UVsrc_r         <= 'b0;
        UVPred_r        <= 'b0;
        FDCT_o[0]       <= 'b0;
        FDCT_o[1]       <= 'b0;
        FDCT_o[2]       <= 'b0;
        FDCT_o[3]       <= 'b0;
        FDCT_o[4]       <= 'b0;
        FDCT_o[5]       <= 'b0;
        FDCT_o[6]       <= 'b0;
        FDCT_o[7]       <= 'b0;
        CDCV_i          <= 'b0;
        QB_i            <= 'b0;
        UVlevels_i[0]   <= 'b0;
        UVlevels_i[1]   <= 'b0;
        UVlevels_i[2]   <= 'b0;
        UVlevels_i[3]   <= 'b0;
        UVlevels_i[4]   <= 'b0;
        UVlevels_i[5]   <= 'b0;
        UVlevels_i[6]   <= 'b0;
        UVlevels_i[7]   <= 'b0;
        QB_nz           <= 'b0;
        UVout_r[0]      <= 'b0;
        UVout_r[1]      <= 'b0;
        UVout_r[2]      <= 'b0;
        UVout_r[3]      <= 'b0;
        UVout_r[4]      <= 'b0;
        UVout_r[5]      <= 'b0;
        UVout_r[6]      <= 'b0;
        UVout_r[7]      <= 'b0;
        done            <= 'b0;
    end
    else begin
        case(count)
            'd0:begin
                UVsrc_r         <= UVsrc_w [0];
                UVPred_r        <= UVPred_w[0];
                done            <= 'b0;
            end
            'd1:begin
                UVsrc_r         <= UVsrc_w [1];
                UVPred_r        <= UVPred_w[1];
            end
            'd2:begin
                UVsrc_r         <= UVsrc_w [2];
                UVPred_r        <= UVPred_w[2];
            end
            'd3:begin
                UVsrc_r         <= UVsrc_w [3];
                UVPred_r        <= UVPred_w[3];
                CDCV_i[ 15:  0] <= FDCT_w[15:0];
                FDCT_o[0]       <= FDCT_w;
            end
            'd4:begin
                UVsrc_r         <= UVsrc_w [4];
                UVPred_r        <= UVPred_w[4];
                CDCV_i[ 31: 16] <= FDCT_w[15:0];
                FDCT_o[1]       <= FDCT_w;
            end
            'd5:begin
                UVsrc_r         <= UVsrc_w [5];
                UVPred_r        <= UVPred_w[5];
                CDCV_i[ 47: 32] <= FDCT_w[15:0];
                FDCT_o[2]       <= FDCT_w;
            end
            'd6:begin
                UVsrc_r         <= UVsrc_w [6];
                UVPred_r        <= UVPred_w[6];
                CDCV_i[ 63: 48] <= FDCT_w[15:0];
                FDCT_o[3]       <= FDCT_w;
            end
            'd7:begin
                UVsrc_r         <= UVsrc_w [7];
                UVPred_r        <= UVPred_w[7];
                CDCV_i[ 79: 64] <= FDCT_w[15:0];
                FDCT_o[4]       <= FDCT_w;
            end
            'd8:begin
                CDCV_i[ 95: 80] <= FDCT_w[15:0];
                FDCT_o[5]       <= FDCT_w;
            end
            'd9:begin
                CDCV_i[111: 96] <= FDCT_w[15:0];
                FDCT_o[6]       <= FDCT_w;
            end
            'd10:begin
                CDCV_i[127:112] <= FDCT_w[15:0];
                FDCT_o[7]       <= FDCT_w;
            end
            'd19:begin
                QB_i            <= {FDCT_o[0][255:16],CDCV_o[ 15:  0]};
            end
            'd20:begin
                QB_i            <= {FDCT_o[1][255:16],CDCV_o[ 31: 16]};
            end
            'd21:begin
                QB_i            <= {FDCT_o[2][255:16],CDCV_o[ 47: 32]};
            end
            'd22:begin
                QB_i            <= {FDCT_o[3][255:16],CDCV_o[ 63: 48]};
                UVlevels_i[0]   <= UVlevels_w;
                QB_nz[0]        <= QB_nz_w;
                UVPred_r        <= UVPred_w[0];
            end
            'd23:begin
                QB_i            <= {FDCT_o[4][255:16],CDCV_o[ 79: 64]};
                UVlevels_i[1]   <= UVlevels_w;
                QB_nz[1]        <= QB_nz_w;
                UVPred_r        <= UVPred_w[1];
            end
            'd24:begin
                QB_i            <= {FDCT_o[5][255:16],CDCV_o[ 95: 80]};
                UVlevels_i[2]   <= UVlevels_w;
                QB_nz[2]        <= QB_nz_w;
                UVPred_r        <= UVPred_w[2];
                UVout_r[ 0]     <= UVout_w;
            end
            'd25:begin
                QB_i            <= {FDCT_o[6][255:16],CDCV_o[111: 96]};
                UVlevels_i[3]   <= UVlevels_w;
                QB_nz[3]        <= QB_nz_w;
                UVPred_r        <= UVPred_w[3];
                UVout_r[ 1]     <= UVout_w;
            end
            'd26:begin
                QB_i            <= {FDCT_o[7][255:16],CDCV_o[127:112]};
                UVlevels_i[4]   <= UVlevels_w;
                QB_nz[4]        <= QB_nz_w;
                UVPred_r        <= UVPred_w[4];
                UVout_r[ 2]     <= UVout_w;
            end
            'd27:begin
                UVlevels_i[5]   <= UVlevels_w;
                QB_nz[5]        <= QB_nz_w;
                UVPred_r        <= UVPred_w[5];
                UVout_r[ 3]     <= UVout_w;
            end
            'd28:begin
                UVlevels_i[6]   <= UVlevels_w;
                QB_nz[6]        <= QB_nz_w;
                UVPred_r        <= UVPred_w[6];
                UVout_r[ 4]     <= UVout_w;
            end
            'd29:begin
                UVlevels_i[7]   <= UVlevels_w;
                QB_nz[7]        <= QB_nz_w;
                UVPred_r        <= UVPred_w[7];
                UVout_r[ 5]     <= UVout_w;
            end
            'd30:begin
                UVout_r[ 6]     <= UVout_w;
            end
            'd31:begin
                UVout_r[ 7]     <= UVout_w;
                done            <= 'b1;
            end
            default:;
        endcase 
    end
end

endmodule
