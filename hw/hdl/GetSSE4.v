//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	GetSSE4.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-12-10 10:38
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module GetSSE4#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 4
)(
 input                                                    clk
,input                                                    rst_n
,input                                                    start
,input      [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] a
,input      [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] b
,output reg [32                                  - 1 : 0] sse
,output reg                                               done
);

reg ena;
reg valid;

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        ena <= 1'b0;
    else
        if(start)
            ena <= 1'b1;
        else
            ena <= 1'b0;
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        valid <= 1'b0;
    else
        if(ena)
            valid <= 1'b1;
        else
            valid <= 1'b0;
end

genvar i;

generate

for(i = 0; i < 16; i = i + 1)begin:ROM
reg signed[8:0]addra;
wire [31:0]douta;
rom_pow U0 (
    .clka                           (clk                            ),
    .ena                            (ena                            ),
    .addra                          (addra                          ),
    .douta                          (douta                          )
);

    always @ (posedge clk or negedge rst_n)begin
        if(~rst_n)
            addra <= 'b0;
        else
            addra <= a[8 * (i + 1) - 1 : 8 * i] - b[8 * (i + 1) - 1 : 8 * i]; 
    end
end

endgenerate

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        sse <= 'b0;
    else
        if(start)
            sse <= 'b0;
        else if(valid)
            sse <= ROM[ 0].douta + ROM[ 1].douta + ROM[ 2].douta + ROM[ 3].douta +
                   ROM[ 4].douta + ROM[ 5].douta + ROM[ 6].douta + ROM[ 7].douta +
                   ROM[ 8].douta + ROM[ 9].douta + ROM[10].douta + ROM[11].douta +
                   ROM[12].douta + ROM[13].douta + ROM[14].douta + ROM[15].douta;
end

reg [1:0]shift;
always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        done  <= 'b0;
        shift <= 'b0;
    else
        shift[0] <= start;
        shift[1] <= shift[0];
        done  <= shift[1];
end

endmodule
