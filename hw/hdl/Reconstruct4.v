//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	Reconstruct4.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-17 13:30
// LastModified   :	2019-11-22 11:37
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module Reconstruct4#(
 parameter BLOCK_SIZE   = 4
)(
 input                                             clk
,input                                             rst_n
,input                                             start
,input      [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] YPred
,input      [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] Ysrc
,input      [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] q
,input      [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] iq
,input      [32 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] bias
,input      [32 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] zthresh
,input      [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] sharpen
,output     [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] Yout
,output     [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] YLevels
,output                                            nz
,output                                            done
);

wire [12 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]FDCT_out;
wire FDCT_done;
FTransform U_FDCT(
     .clk                           (clk                            )
    ,.rst_n                         (rst_n                          )
    ,.start                         (start                          )
    ,.src                           (Ysrc                           )
    ,.ref                           (YPred                          )
    ,.out                           (FDCT_out                       )
    ,.done                          (FDCT_done                      )
    );

wire [255:0]QB_i;
assign QB_i = {{4'b0,FDCT_out[191:180]},
               {4'b0,FDCT_out[179:168]},
               {4'b0,FDCT_out[167:156]},
               {4'b0,FDCT_out[155:144]},
               {4'b0,FDCT_out[143:132]},
               {4'b0,FDCT_out[131:120]},
               {4'b0,FDCT_out[119:108]},
               {4'b0,FDCT_out[107: 96]},
               {4'b0,FDCT_out[ 95: 84]},
               {4'b0,FDCT_out[ 83: 72]},
               {4'b0,FDCT_out[ 71: 60]},
               {4'b0,FDCT_out[ 59: 48]},
               {4'b0,FDCT_out[ 47: 36]},
               {4'b0,FDCT_out[ 35: 24]},
               {4'b0,FDCT_out[ 23: 12]},
               {4'b0,FDCT_out[ 11:  0]}};

wire QB_done;
wire [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]QB_Rout;
QuantizeBlock U_QB(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( FDCT_done                     ),
    .in                             ( QB_i                          ),
    .q                              ( q                             ),
    .iq                             ( iq                            ),
    .bias                           ( bias                          ),
    .zthresh                        ( zthresh                       ),
    .sharpen                        ( sharpen                       ),
    .Rout                           ( QB_Rout                       ),
    .out                            ( YLevels                       ),
    .nz                             ( nz                            ),
    .done                           ( QB_done                       )
);

ITransform U_IDCT(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( QB_done                       ),
    .src                            ( QB_Rout                       ),
    .ref                            ( YPred                         ),
    .out                            ( Yout                          ),
    .done                           ( done                          )
);

endmodule
