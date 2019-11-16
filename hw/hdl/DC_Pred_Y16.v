//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	DC_Pred_Y16.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-16 11:12
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module DC_Pred_Y16#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 16
,parameter BLOCK_NUM    = 10 //2^10
,parameter SHIFT        = 5
)(
 input                                                  clk
,input                                                  rst_n
,input                                                  start
,input      [BLOCK_NUM - 1 : 0]                         x
,input      [BLOCK_NUM - 1 : 0]                         y
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            top
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]            left
,output reg [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE-1 : 0] dst
,output reg                                             done
);

    parameter IDLE    = 6'h01;
    parameter BOTH    = 6'h02;
    parameter TOP     = 6'h04; 
    parameter LEFT    = 6'h08;
    parameter NONE    = 6'h10;
    parameter DONE    = 6'h20;
   
    reg  [005:0] cstate;
    reg  [005:0] nstate;

    wire[BIT_WIDTH - 1 : 0] top_i  [SHIFT - 2 : 0];
    wire[BIT_WIDTH - 1 : 0] left_i [SHIFT - 2 : 0];
    reg [BIT_WIDTH + SHIFT : 0] temp1;
    reg [BIT_WIDTH - 1 : 0] temp2;
    reg [SHIFT : 0]count;

    assign top_i [ 0] = top [7   : 0  ];
    assign top_i [ 1] = top [15  : 8  ];
    assign top_i [ 2] = top [23  : 16 ];
    assign top_i [ 3] = top [31  : 24 ];
    assign top_i [ 4] = top [39  : 32 ];
    assign top_i [ 5] = top [47  : 40 ];
    assign top_i [ 6] = top [55  : 48 ];
    assign top_i [ 7] = top [63  : 56 ];
    assign top_i [ 8] = top [71  : 64 ];
    assign top_i [ 9] = top [79  : 72 ];
    assign top_i [10] = top [87  : 80 ];
    assign top_i [11] = top [95  : 88 ];
    assign top_i [12] = top [103 : 96 ];
    assign top_i [13] = top [111 : 104];
    assign top_i [14] = top [119 : 112];
    assign top_i [15] = top [127 : 120];

    assign left_i[ 0] = left[7   : 0  ];
    assign left_i[ 1] = left[15  : 8  ];
    assign left_i[ 2] = left[23  : 16 ];
    assign left_i[ 3] = left[31  : 24 ];
    assign left_i[ 4] = left[39  : 32 ];
    assign left_i[ 5] = left[47  : 40 ];
    assign left_i[ 6] = left[55  : 48 ];
    assign left_i[ 7] = left[63  : 56 ];
    assign left_i[ 8] = left[71  : 64 ];
    assign left_i[ 9] = left[79  : 72 ];
    assign left_i[10] = left[87  : 80 ];
    assign left_i[11] = left[95  : 88 ];
    assign left_i[12] = left[103 : 96 ];
    assign left_i[13] = left[111 : 104];
    assign left_i[14] = left[119 : 112];
    assign left_i[15] = left[127 : 120];

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
                if(count <= BLOCK_SIZE)
                    nstate = BOTH;
                else
                    nstate = DONE;
            TOP:
                if(count <= BLOCK_SIZE)
                    nstate = TOP;
                else
                    nstate = DONE;
            LEFT: 
                if(count <= BLOCK_SIZE)
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
                    temp2 <= 'b0;
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
                    temp1 <= 'h80 << SHIFT;
                end
                DONE:begin
                    temp2 <= (temp1 + BLOCK_SIZE) >> SHIFT;
                    done  <= 1'b1;
                end
            endcase
        end
    end

assign temp2 = (temp1 + BLOCK_SIZE) >> SHIFT;

Fill #(
 .BIT_WIDTH     (BIT_WIDTH  )
,.BLOCK_SIZE    (BLOCK_SIZE )
) U_Fill (
 .value         (temp2   )
,.dst           (dst     )
);

endmodule
