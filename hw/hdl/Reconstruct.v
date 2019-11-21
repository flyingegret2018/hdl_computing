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
 parameter BLOCK_SIZE   = 16
)(
 input                                             clk
,input                                             rst_n
,input                                             start
,input      [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] YPred
,input      [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] Ysrc
,input      [16 * BLOCK_SIZE              - 1 : 0] q1
,input      [16 * BLOCK_SIZE              - 1 : 0] iq1
,input      [32 * BLOCK_SIZE              - 1 : 0] bias1
,input      [32 * BLOCK_SIZE              - 1 : 0] zthresh1
,input      [16 * BLOCK_SIZE              - 1 : 0] sharpen1
,input      [16 * BLOCK_SIZE              - 1 : 0] q2
,input      [16 * BLOCK_SIZE              - 1 : 0] iq2
,input      [32 * BLOCK_SIZE              - 1 : 0] bias2
,input      [32 * BLOCK_SIZE              - 1 : 0] zthresh2
,input      [16 * BLOCK_SIZE              - 1 : 0] sharpen2
,output     [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] Yout
,output     [16 * BLOCK_SIZE              - 1 : 0] Y_dc_levels
,output     [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] Y_ac_levels
,output reg                                        done
);

wire        [ 8 * BLOCK_SIZE - 1 : 0]Ysrc_i [BLOCK_SIZE - 1 : 0];
wire        [ 8 * BLOCK_SIZE - 1 : 0]YPred_i[BLOCK_SIZE - 1 : 0];
wire        [ 8 * BLOCK_SIZE - 1 : 0]Yout_i [BLOCK_SIZE - 1 : 0];
wire signed [12 * BLOCK_SIZE - 1 : 0]FDCT_o [BLOCK_SIZE - 1 : 0];
wire signed [16 * BLOCK_SIZE - 1 : 0]Yac_i  [BLOCK_SIZE - 1 : 0];
wire signed [16 * BLOCK_SIZE - 1 : 0]Ydc_i                      ;

genvar i;

generate

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    assign Ysrc_i[i] = 
        {Ysrc[8 * ((i/4) * 64 + (i%4) * 4 + 52) - 1 : 8 * ((i/4) * 64 + (i%4) * 4 + 48)],
         Ysrc[8 * ((i/4) * 64 + (i%4) * 4 + 36) - 1 : 8 * ((i/4) * 64 + (i%4) * 4 + 32)],
         Ysrc[8 * ((i/4) * 64 + (i%4) * 4 + 20) - 1 : 8 * ((i/4) * 64 + (i%4) * 4 + 16)],
         Ysrc[8 * ((i/4) * 64 + (i%4) * 4 +  4) - 1 : 8 * ((i/4) * 64 + (i%4) * 4 +  0)]};

    assign YPred_i[i] = 
        {YPred[8 * ((i/4) * 64 + (i%4) * 4 + 52) - 1 : 8 * ((i/4) * 64 + (i%4) * 4 + 48)],
         YPred[8 * ((i/4) * 64 + (i%4) * 4 + 36) - 1 : 8 * ((i/4) * 64 + (i%4) * 4 + 32)],
         YPred[8 * ((i/4) * 64 + (i%4) * 4 + 20) - 1 : 8 * ((i/4) * 64 + (i%4) * 4 + 16)],
         YPred[8 * ((i/4) * 64 + (i%4) * 4 +  4) - 1 : 8 * ((i/4) * 64 + (i%4) * 4 +  0)]};
    
    assign Yout[8 * ((i/4) * 64 + (i%4) * 4 + 52) - 1 : 8 * ((i/4) * 64 + (i%4) * 4 + 48)] = Yout_i[i][127:96];
    assign Yout[8 * ((i/4) * 64 + (i%4) * 4 + 36) - 1 : 8 * ((i/4) * 64 + (i%4) * 4 + 32)] = Yout_i[i][ 95:64];
    assign Yout[8 * ((i/4) * 64 + (i%4) * 4 + 20) - 1 : 8 * ((i/4) * 64 + (i%4) * 4 + 16)] = Yout_i[i][ 63:32];
    assign Yout[8 * ((i/4) * 64 + (i%4) * 4 +  4) - 1 : 8 * ((i/4) * 64 + (i%4) * 4 +  0)] = Yout_i[i][ 31: 0];
end

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin:FDCT
    wire done;
    FTransform U_FDCT(
     .clk   (clk         )
    ,.rst_n (rst_n       )
    ,.start (start       )
    ,.src   (Ysrc[i]     )
    ,.ref   (YPred[i]    )
    ,.out   (FDCT_o[i]   )
    ,.done  (done        )
    );
end

wire [12 * BLOCK_SIZE - 1 : 0]dc_in ;
wire [15 * BLOCK_SIZE - 1 : 0]dc_out;

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin:FDCT
    assign dc_in[12 * (i + 1) -1 : 12 * i] = FDCT_o[i][11:0];
end

wire FWHT_done;
FTransformWHT U_FWHT(
 .clk   (clk         )   
,.rst_n (rst_n       )
,.start (FDCT[0].done)
,.in    (dc_in       )
,.out   (dc_out      )
,.done  (FWHT_done   )
);


QuantizeBlock #(
    .BLOCK_SIZE                     ( 4                             ))
U_QUANTIZEBLOCK_0(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( start                         ),
    .in                             ( in                            ),
    .q                              ( q                             ),
    .iq                             ( iq                            ),
    .bias                           ( bias                          ),
    .zthresh                        ( zthresh                       ),
    .sharpen                        ( sharpen                       ),
    .R_in                           ( R_in                          ),
    .out                            ( out                           ),
    .done                           ( done                          )
);


endgenerate
