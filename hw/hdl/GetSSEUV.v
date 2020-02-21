//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	GetSSEUV.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-12-11 11:30
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module GetSSEUV#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 8
)(
 input                                            clk
,input                                            rst_n
,input                                            start
,input      [BIT_WIDTH * 16 * BLOCK_SIZE - 1 : 0] a
,input      [BIT_WIDTH * 16 * BLOCK_SIZE - 1 : 0] b
,output reg [32                          - 1 : 0] sse
,output reg                                       done
);

reg [2:0]count;
reg      ena;
reg      valid;
wire[8 * 16 - 1:0]tmpa[BLOCK_SIZE - 1:0];
wire[8 * 16 - 1:0]tmpb[BLOCK_SIZE - 1:0];

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        count <= 'b0;
    else
        if(start | count != 'b0)
            count <= count + 1'b1;
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        ena <= 1'b0;
    else
        if(start | count != 'b0)
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

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    assign tmpa[i] = a[8 * 16 * (i + 1) - 1 : 8 * 16 * i];
    assign tmpb[i] = b[8 * 16 * (i + 1) - 1 : 8 * 16 * i];
end

for(i = 0; i < 16; i = i + 1)begin:ROM
reg signed [8:0]addra;
wire [15:0]douta;
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
            addra <= tmpa[count][8 * (i + 1) - 1 : 8 * i] - 
                     tmpb[count][8 * (i + 1) - 1 : 8 * i]; 
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
                   ROM[12].douta + ROM[13].douta + ROM[14].douta + ROM[15].douta + sse;
end

reg [8:0]shift;
always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        done  <= 'b0;
        shift <= 'b0;
    end
    else begin
        shift[0]   <= start;
        shift[8:1] <= shift[7:0];
        done       <= shift[8];
    end
end

endmodule
