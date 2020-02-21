//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	Disto16x16.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-12-06 16:18
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module Disto16x16#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 16
)(
 input                                             clk
,input                                             rst_n
,input                                             start
,input      [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] ina
,input      [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] inb
,input      [16 * BLOCK_SIZE              - 1 : 0] w
,output reg [31                               : 0] sum
,output reg                                        done
);

wire[ 8 * BLOCK_SIZE - 1 : 0]tmpa[BLOCK_SIZE - 1 : 0];
wire[ 8 * BLOCK_SIZE - 1 : 0]tmpb[BLOCK_SIZE - 1 : 0];
reg [ 8 * BLOCK_SIZE - 1 : 0]tmpc;
reg [ 8 * BLOCK_SIZE - 1 : 0]tmpd;
reg [ 3                  : 0]count;
reg                          valid;
wire[31                  : 0]sum4;
wire                         done4;

genvar i;

generate

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    assign tmpa[i] = 
    {ina[8*((i/4)*64+(i%4)*4+52)-1:8*((i/4)*64+(i%4)*4+48)],
     ina[8*((i/4)*64+(i%4)*4+36)-1:8*((i/4)*64+(i%4)*4+32)],
     ina[8*((i/4)*64+(i%4)*4+20)-1:8*((i/4)*64+(i%4)*4+16)],
     ina[8*((i/4)*64+(i%4)*4+ 4)-1:8*((i/4)*64+(i%4)*4+ 0)]};

    assign tmpb[i] = 
    {inb[8*((i/4)*64+(i%4)*4+52)-1:8*((i/4)*64+(i%4)*4+48)],
     inb[8*((i/4)*64+(i%4)*4+36)-1:8*((i/4)*64+(i%4)*4+32)],
     inb[8*((i/4)*64+(i%4)*4+20)-1:8*((i/4)*64+(i%4)*4+16)],
     inb[8*((i/4)*64+(i%4)*4+ 4)-1:8*((i/4)*64+(i%4)*4+ 0)]};
end

endgenerate

Disto4x4 U_DISTO4X4(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( valid                         ),
    .ina                            ( tmpc                          ),
    .inb                            ( tmpd                          ),
    .w                              ( w                             ),
    .sum                            ( sum4                          ),
    .done                           ( done4                         )
);

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        count <= 'b0;
    else
        if(start | count != 'b0)
            count <= count + 1'b1;
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        valid <= 1'b0;
    else
        if(start | count != 'b0)
            valid <= 1'b1;
        else
            valid <= 1'b0;
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        tmpc <= 'b0;
        tmpd <= 'b0;
    end
    else begin
        tmpc <= tmpa[count];
        tmpd <= tmpb[count];
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        sum <= 'b0;
    else
        if(start)
            sum <= 'b0;
        else if(done4)
            sum <= sum + sum4;
end

reg [18:0]shift;
always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        done  <= 'b0;
        shift <= 'b0;
    end
    else begin
        shift[0] <= start;
        shift[18:1] <= shift[17:0];
        done  <= shift[18];
    end
end

endmodule
