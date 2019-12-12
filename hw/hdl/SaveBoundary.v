//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	SaveBoundary.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-17 13:30
// LastModified   :	2019-12-12 15:20
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module SaveBoundary#(
 parameter BLOCK_SIZE   = 16
)(
 input                                            clk
,input                                            rst_n
,input                                            load
,input             [10                   - 1 : 0] x
,input             [10                   - 1 : 0] y
,input             [10                   - 1 : 0] mb_w
,input             [10                   - 1 : 0] mb_h
,input             [ 8 * 16 * BLOCK_SIZE - 1 : 0] Yin
,input             [ 8 * 16 * BLOCK_SIZE - 1 : 0] UVin
,output            [ 8                   - 1 : 0] top_left_y
,output            [ 8                   - 1 : 0] top_left_u
,output            [ 8                   - 1 : 0] top_left_v
,output            [ 8 * 20              - 1 : 0] top_y
,output            [ 8 *  8              - 1 : 0] top_u
,output            [ 8 *  8              - 1 : 0] top_v
,output            [ 8 * 16              - 1 : 0] left_y
,output            [ 8 *  8              - 1 : 0] left_u
,output            [ 8 *  8              - 1 : 0] left_v
);

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        done      <= 'b0;
        ac_levels <= 'b0;
        mbtype    <= 'b0;
        nz        <= 'b0;
        skipped   <= 'b0;
    end
    else begin
        if(PB4_done)begin
            done      <= 1'b1;
            if(Yscore4 >= Yscore)begin
                ac_levels <= ac_levels0;
                mbtype    <= 'b1;
                nz        <= {'b0,Ynz[24],UVnz[23:16],Ynz[15:0]};
                skipped   <= {'b0,Ynz[24],UVnz[23:16],Ynz[15:0]} == 'b0;
            end
            else begin
                ac_levels <= ac_levels1;
                mbtype    <= 'b0;
                nz        <= {'b0,UVnz[23:16],Ynz4[15:0]};
                skipped   <= {'b0,UVnz[23:16],Ynz4[15:0]} == 'b0;
            end
        end
        else begin
            done      <= 1'b0;
        end
    end
end

endmodule
