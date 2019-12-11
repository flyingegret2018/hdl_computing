//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	CorrectDCValues.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-23 18:52
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module StoreDiffusionErrors(
 input                         clk
,input                         rst_n
,input                         start
,input               [  9 : 0] x
,input               [ 47 : 0] derr
,output reg          [ 31 : 0] left_derr
,output reg          [ 31 : 0] top_derr
,output reg                    top_derr_en
,output reg                    top_derr_wea
,output reg          [  9 : 0] top_derr_addr
,output reg                    done
);

    wire signed[7:0]derr_i[5:0];
    assign derr_i[0] = derr[ 7: 0];
    assign derr_i[1] = derr[15: 8];
    assign derr_i[2] = derr[23:16];
    assign derr_i[3] = derr[31:24];
    assign derr_i[4] = derr[39:32];
    assign derr_i[5] = derr[47:40];

    wire signed[7:0]left[3:0];
    assign left[0] = derr_i[0];
    assign left[1] = derr_i[2] * 'd3 >> 2;
    assign left[2] = derr_i[3];
    assign left[3] = derr_i[5] * 'd3 >> 2;

    wire signed[7:0]top[3:0];
    assign top[0] = derr_i[1];
    assign top[1] = derr_i[2] - left[1];
    assign top[2] = derr_i[1];
    assign top[3] = derr_i[5] - left[3];

    parameter IDLE    = 'h01;
    parameter WRITE   = 'h02;
   
    reg [1:0] cstate;
    reg [1:0] nstate;

    always @ (posedge clk or negedge rst_n)begin
        if(~rst_n)
            cstate <= IDLE;
        else
            cstate <= nstate;
    end

    always @ * begin
        case(cstate)
            IDLE:
                if(start)
                    nstate = WRITE;
                else
                    nstate = IDLE;
            WRITE:
                nstate = IDLE;
            default:
                nstate = IDLE;
        endcase
    end

    always @ (posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            top_derr_en   <= 'b0;
            top_derr_wea  <= 'b0;
            top_derr_addr <= 'b0;
            top_derr      <= 'b0;
            left_derr     <= 'b0;
            done          <= 'b0;
        end
        else begin
            case(cstate)
                IDLE:begin
                    top_derr_en   <= 'b0;
                    top_derr_wea  <= 'b0;
                    done          <= 'b0;
                end
                WRITE:begin
                    top_derr_en   <= 1'b1;
                    top_derr_wea  <= 1'b1;
                    top_derr_addr <= x;
                    top_derr      <= {top[3],top[2],top[1],top[0]};
                    left_derr     <= {left[3],left[2],left[1],left[0]};
                    done          <= 1'b1;
                end
            endcase
        end
    end

endmodule
