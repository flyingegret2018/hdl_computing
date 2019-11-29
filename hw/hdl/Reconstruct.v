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
,output                                            done
);

wire        [ 8 * BLOCK_SIZE - 1 : 0]Ysrc_i [BLOCK_SIZE - 1 : 0];
wire        [ 8 * BLOCK_SIZE - 1 : 0]YPred_i[BLOCK_SIZE - 1 : 0];
wire        [ 8 * BLOCK_SIZE - 1 : 0]Yout_i [BLOCK_SIZE - 1 : 0];
wire signed [12 * BLOCK_SIZE - 1 : 0]FDCT_o [BLOCK_SIZE - 1 : 0];
wire signed [16 * BLOCK_SIZE - 1 : 0]Yac_i  [BLOCK_SIZE - 1 : 0];

genvar i;

generate

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    assign Ysrc_i[i] = 
    {Ysrc[8*((i/4)*64+(i%4)*4+52)-1:8*((i/4)*64+(i%4)*4+48)],
     Ysrc[8*((i/4)*64+(i%4)*4+36)-1:8*((i/4)*64+(i%4)*4+32)],
     Ysrc[8*((i/4)*64+(i%4)*4+20)-1:8*((i/4)*64+(i%4)*4+16)],
     Ysrc[8*((i/4)*64+(i%4)*4+ 4)-1:8*((i/4)*64+(i%4)*4+ 0)]};

    assign YPred_i[i] = 
    {YPred[8*((i/4)*64+(i%4)*4+52)-1:8*((i/4)*64+(i%4)*4+48)],
     YPred[8*((i/4)*64+(i%4)*4+36)-1:8*((i/4)*64+(i%4)*4+32)],
     YPred[8*((i/4)*64+(i%4)*4+20)-1:8*((i/4)*64+(i%4)*4+16)],
     YPred[8*((i/4)*64+(i%4)*4+ 4)-1:8*((i/4)*64+(i%4)*4+ 0)]};

    assign 
    {Yout[8*((i/4)*64+(i%4)*4+52)-1:8*((i/4)*64+(i%4)*4+48)],
     Yout[8*((i/4)*64+(i%4)*4+36)-1:8*((i/4)*64+(i%4)*4+32)],
     Yout[8*((i/4)*64+(i%4)*4+20)-1:8*((i/4)*64+(i%4)*4+16)],
     Yout[8*((i/4)*64+(i%4)*4+ 4)-1:8*((i/4)*64+(i%4)*4+ 0)]}
     = Yout_i[i];

    assign Y_ac_levels[16 * (i + 1) : 16 * i] = Yac_i[i];
end

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin:FDCT
    wire FDCT_done;
FTransform U_FDCT(
     .clk                           ( clk                           )
    ,.rst_n                         ( rst_n                         )
    ,.start                         ( start                         )
    ,.src                           ( Ysrc[i]                       )
    ,.ref                           ( YPred[i]                      )
    ,.out                           ( FDCT_o[i]                     )
    ,.done                          ( FDCT_done                     )
    );
end

wire [12 * BLOCK_SIZE - 1 : 0]dc_in ;
wire [15 * BLOCK_SIZE - 1 : 0]dc_out;

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    assign dc_in[12 * (i + 1) -1 : 12 * i] = FDCT_o[i][11:0];
end

wire FWHT_done;
FTransformWHT U_FWHT(
     .clk                           ( clk                           )   
    ,.rst_n                         ( rst_n                         )
    ,.start                         ( FDCT[0].FDCT_done             )
    ,.in                            ( dc_in                         )
    ,.out                           ( dc_out                        )
    ,.done                          ( FWHT_done                     )
);

wire QBDC_done;
wire [16 * BLOCK_SIZE - 1 : 0]QBDC_Rout;
QuantizeBlock U_QBDC(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( FWHT_done                     ),
    .in                             ( {'b0,dc_out}                  ),
    .q                              ( q2                            ),
    .iq                             ( iq2                           ),
    .bias                           ( bias2                         ),
    .zthresh                        ( zthresh2                      ),
    .sharpen                        ( sharpen2                      ),
    .Rout                           ( QBDC_Rout                     ),
    .out                            ( Y_dc_levels                   ),
    .done                           ( QBDC_done                     )
);

wire [16 * BLOCK_SIZE - 1 : 0]QBAC_i[BLOCK_SIZE - 1 : 0];
for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    assign QBAC_i[i] = {{4'b0,FDCT_o[i][191:180]},
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
                        16'b0};
end

wire [16 * BLOCK_SIZE - 1 : 0]QBAC_Rout[BLOCK_SIZE - 1 : 0];
for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
QuantizeBlock U_QBAC(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( FWHT_done                     ),
    .in                             ( QBAC_i[i]                     ),
    .q                              ( q1                            ),
    .iq                             ( iq1                           ),
    .bias                           ( bias1                         ),
    .zthresh                        ( zthresh1                      ),
    .sharpen                        ( sharpen1                      ),
    .Rout                           ( QBAC_Rout[i]                  ),
    .out                            ( Yac_i[i]                      ),
    .done                           (                               )
);
end

wire IWHT_done;
wire [16 * BLOCK_SIZE - 1 : 0]IWHT_out;
ITransformWHT U_IWHT(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( QBDC_done                     ),
    .in                             ( QBDC_Rout                     ),
    .out                            ( IWHT_out                      ),
    .done                           ( IWHT_done                     )
);

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
wire [255:0] tmp;
assgin tmp = {QBAC_Rout[i][255:16],IWHT_out[16 * (i + 1) - 1 : 16 * i]};
ITransform U_IDCT(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( IWHT_done                     ),
    .src                            ( tmp                           ),
    .ref                            ( YPred_i[i]                    ),
    .out                            ( Yout_i[i]                     ),
    .done                           ( done                          )
);
end

endgenerate

endmodule
