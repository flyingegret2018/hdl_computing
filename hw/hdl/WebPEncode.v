//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	WebPEncode.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-17 13:30
// LastModified   :	2019-12-12 16:17
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module WebPEncode#(
 parameter BLOCK_SIZE   = 16
)(
 input                                            clk
,input                                            rst_n
,input                                            start
,input             [10                   - 1 : 0] x
,input             [10                   - 1 : 0] y
,input             [ 8 * 16 * BLOCK_SIZE - 1 : 0] Yin
,input             [ 8 *  8 * BLOCK_SIZE - 1 : 0] UVin
,input      signed [32                   - 1 : 0] lambda_i16
,input      signed [32                   - 1 : 0] lambda_i4
,input      signed [32                   - 1 : 0] lambda_uv
,input      signed [32                   - 1 : 0] tlambda
,input      signed [32                   - 1 : 0] lambda_mode
,input      signed [32                   - 1 : 0] min_disto
,input      signed [32                   - 1 : 0] max_edgei
,input                                            reload
,input             [16 * 16              - 1 : 0] y1_q
,input             [16 * 16              - 1 : 0] y1_iq
,input             [32 * 16              - 1 : 0] y1_bias
,input             [32 * 16              - 1 : 0] y1_zthresh
,input             [16 * 16              - 1 : 0] y1_sharpen
,input             [16 * 16              - 1 : 0] y2_q
,input             [16 * 16              - 1 : 0] y2_iq
,input             [32 * 16              - 1 : 0] y2_bias
,input             [32 * 16              - 1 : 0] y2_zthresh
,input             [16 * 16              - 1 : 0] y2_sharpen
,input             [16 * 16              - 1 : 0] uv_q
,input             [16 * 16              - 1 : 0] uv_iq
,input             [32 * 16              - 1 : 0] uv_bias
,input             [32 * 16              - 1 : 0] uv_zthresh
,input             [16 * 16              - 1 : 0] uv_sharpen
,output reg                                       done
);

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        done      <= 'b0;
        ac_levels <= 'b0;
        Yout      <= 'b0;
        mbtype    <= 'b0;
        nz        <= 'b0;
        skipped   <= 'b0;
    end
    else begin
        if(PB4_done)begin
            done      <= 1'b1;
            if(Yscore4 >= Yscore)begin
                ac_levels <= ac_levels0;
                Yout      <= Yout16;
                mbtype    <= 'b1;
                nz        <= {'b0,Ynz[24],UVnz[23:16],Ynz[15:0]};
                skipped   <= {'b0,Ynz[24],UVnz[23:16],Ynz[15:0]} == 'b0;
            end
            else begin
                ac_levels <= ac_levels1;
                Yout      <= Yout4;
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
