//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	DC_Pred_UV.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-16 18:45
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module DC_Pred_UV#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 8
,parameter BLOCK_NUM    = 10 //2^10
,parameter UV_SIZE      = 16
,parameter SHIFT        = 4
)(
 input                                                  clk
,input                                                  rst_n
,input                                                  start
,input      [BLOCK_NUM - 1 : 0]                         x
,input      [BLOCK_NUM - 1 : 0]                         y
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            top_u
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            top_v
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            left_u
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            left_v
,output     [BIT_WIDTH * BLOCK_SIZE * UV_SIZE - 1 : 0]  dst
,output reg                                             done
);

    parameter IDLE    = 6'h01;
    parameter BOTH    = 6'h02;
    parameter TOP     = 6'h04; 
    parameter LEFT    = 6'h08;
    parameter NONE    = 6'h10;
    parameter DONE    = 6'h20;
   
    reg  [5:0] cstate;
    reg  [5:0] nstate;

    wire[BIT_WIDTH - 1 : 0] top_u_i  [BLOCK_SIZE - 1 : 0];
    wire[BIT_WIDTH - 1 : 0] top_v_i  [BLOCK_SIZE - 1 : 0];
    wire[BIT_WIDTH - 1 : 0] left_u_i [BLOCK_SIZE - 1 : 0];
    wire[BIT_WIDTH - 1 : 0] left_v_i [BLOCK_SIZE - 1 : 0];
    reg [BIT_WIDTH + SHIFT : 0] temp1_u;
    reg [BIT_WIDTH + SHIFT : 0] temp1_v;
    reg [BIT_WIDTH - 1 : 0] temp2_u;
    reg [BIT_WIDTH - 1 : 0] temp2_v;
    reg [SHIFT - 1 : 0]count;

    genvar i;

    generate

    for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
        assign top_u_i [i] = top_u [BIT_WIDTH * (i + 1) - 1 : BIT_WIDTH * i];
        assign top_v_i [i] = top_v [BIT_WIDTH * (i + 1) - 1 : BIT_WIDTH * i];
        assign left_u_i[i] = left_u[BIT_WIDTH * (i + 1) - 1 : BIT_WIDTH * i];
        assign left_v_i[i] = left_v[BIT_WIDTH * (i + 1) - 1 : BIT_WIDTH * i];
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
                nstate = DONE;
            DONE:
                nstate = IDLE;
            default:
                nstate = IDLE;
        endcase
    end

    always @ (posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            count   <= 'b0;
            temp1_u <= 'b0;
            temp2_u <= 'b0;
            temp1_v <= 'b0;
            temp2_v <= 'b0;
            done    <= 'b0;
        end
        else begin
            case(cstate)
                IDLE:begin
                    count   <= 'b0;
                    temp1_u <= 'b0;
                    temp1_v <= 'b0;
                    done    <= 'b0;
                end
                BOTH:begin
                    count   <= count + 1'b1;
                    temp1_u <= top_u_i[count] + left_u_i[count] + temp1_u;
                    temp1_v <= top_v_i[count] + left_v_i[count] + temp1_v;
                end
                TOP:begin
                    count   <= count + 1'b1;
                    temp1_u <= (top_u_i[count] << 1) + temp1_u;
                    temp1_v <= (top_v_i[count] << 1) + temp1_v;
                end
                LEFT:begin
                    count   <= count + 1'b1;
                    temp1_u <= (left_u_i[count] << 1) + temp1_u;
                    temp1_v <= (left_v_i[count] << 1) + temp1_v;
                end
                NONE:begin
                    temp1_u <= 'h80 << SHIFT;
                    temp1_v <= 'h80 << SHIFT;
                end
                DONE:begin
                    temp2_u <= (temp1_u + BLOCK_SIZE) >> SHIFT;
                    temp2_v <= (temp1_v + BLOCK_SIZE) >> SHIFT;
                    done  <= 1'b1;
                end
            endcase
        end
    end

Fill_UV U_Fill (
 .value_u       (temp2_u    )
,.value_v       (temp2_v    )
,.dst           (dst        )
);

endmodule
