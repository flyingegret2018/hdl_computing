//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	DC_Pred.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-17 14:23
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module DC_Pred#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 16
,parameter BLOCK_NUM    = 10 //2^10
,parameter SHIFT        = 5
)(
 input                                                    clk
,input                                                    rst_n
,input                                                    start
,input      [BLOCK_NUM - 1 : 0]                           x
,input      [BLOCK_NUM - 1 : 0]                           y
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]              top
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]              left
,output     [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] dst
,output reg                                               done
);

    parameter IDLE    = 6'h01;
    parameter BOTH    = 6'h02;
    parameter TOP     = 6'h04; 
    parameter LEFT    = 6'h08;
    parameter NONE    = 6'h10;
    parameter DONE    = 6'h20;
   
    reg  [5:0] cstate;
    reg  [5:0] nstate;

    wire[BIT_WIDTH - 1 : 0] top_i  [BLOCK_SIZE - 1 : 0];
    wire[BIT_WIDTH - 1 : 0] left_i [BLOCK_SIZE - 1 : 0];
    reg [BIT_WIDTH + SHIFT : 0] temp1;
    reg [BIT_WIDTH - 1 : 0] temp2;
    reg [SHIFT - 1 : 0]count;

    genvar i;

    generate

    for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
        assign top_i [i] = top [BIT_WIDTH * (i + 1) - 1 : BIT_WIDTH * i];
        assign left_i[i] = left[BIT_WIDTH * (i + 1) - 1 : BIT_WIDTH * i];
    end

    endgenerate

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
                    if(x != 'b0)
                        if(y != 'b0)
                            nstate = BOTH;
                        else
                            nstate = LEFT;
                    else
                        if(y != 'b0)
                            nstate = TOP;
                        else
                            nstate = NONE;
                else
                    nstate = IDLE;
            BOTH:
                if(count < BLOCK_SIZE - 1)
                    nstate = BOTH;
                else
                    nstate = DONE;
            TOP:
                if(count < BLOCK_SIZE - 1)
                    nstate = TOP;
                else
                    nstate = DONE;
            LEFT: 
                if(count < BLOCK_SIZE - 1)
                    nstate = LEFT;
                else
                    nstate = DONE;
            NONE:
                nstate = IDLE;
            DONE:
                nstate = IDLE;
            default:
                nstate = IDLE;
        endcase
    end

    always @ (posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            count <= 'b0;
            temp1 <= 'b0;
            temp2 <= 'b0;
            done  <= 'b0;
        end
        else begin
            case(cstate)
                IDLE:begin
                    count <= 'b0;
                    temp1 <= 'b0;
                    done  <= 'b0;
                end
                BOTH:begin
                    count <= count + 1'b1;
                    temp1 <= top_i[count] + left_i[count] + temp1;
                end
                TOP:begin
                    count <= count + 1'b1;
                    temp1 <= (top_i[count] << 1) + temp1;
                end
                LEFT:begin
                    count <= count + 1'b1;
                    temp1 <= (left_i[count] << 1) + temp1;
                end
                NONE:begin
                    temp2 <= 'h80;
                    done  <= 'b1;
                end
                DONE:begin
                    temp2 <= (temp1 + BLOCK_SIZE) >> SHIFT;
                    done  <= 1'b1;
                end
            endcase
        end
    end

Fill #(
 .BIT_WIDTH     (BIT_WIDTH  )
,.BLOCK_SIZE    (BLOCK_SIZE )
) U_Fill (
 .value         (temp2   )
,.dst           (dst     )
);

endmodule
