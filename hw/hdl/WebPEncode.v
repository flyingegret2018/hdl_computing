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
,input             [10                   - 1 : 0] w1
,input             [10                   - 1 : 0] w2
,input             [10                   - 1 : 0] h1
,input      signed [32                   - 1 : 0] lambda_i16
,input      signed [32                   - 1 : 0] lambda_i4
,input      signed [32                   - 1 : 0] lambda_uv
,input      signed [32                   - 1 : 0] tlambda
,input      signed [32                   - 1 : 0] lambda_mode
,input      signed [32                   - 1 : 0] min_disto
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
,input             [ 8 * 16 * BLOCK_SIZE - 1 : 0] Yin
,input             [ 8 *  8 * BLOCK_SIZE - 1 : 0] UVin
,input                                            Y0_fifo_empty
,input                                            Y1_fifo_empty
,input                                            UV_fifo_empty
,input                                            fifo_full
,output                                           fifo_rd_y0
,output                                           fifo_rd_y1
,output                                           fifo_rd_uv
,output reg                                       fifo_wr
,output reg        [32 * 32              - 1 : 0] data_out
,output reg                                       done
);

reg [   2:0]count;
reg [   9:0]x;
reg [   9:0]y;
reg [   7:0]top_left_y;
reg [   7:0]top_left_u;
reg [   7:0]top_left_v;
reg [ 159:0]top_y;
reg [  63:0]top_u;
reg [  63:0]top_v;
reg [ 127:0]left_y;
reg [  63:0]left_u;
reg [  63:0]left_v;
wire        fifo_rd;
reg         D_start;
wire        D_done;
wire[2047:0]Yout;
wire[1023:0]UVout;
wire[  31:0]mode_i16;
wire[ 127:0]mode_i4;
wire[  31:0]mode_uv;
wire[ 255:0]dc_levels;
wire[4095:0]ac_levels;
wire[2047:0]uv_levels;
wire[   7:0]skipped;
wire[   7:0]mbtype;
wire[  31:0]nz;
wire[  31:0]max_edge;
wire[   7:0]top_left_y_w;
wire[   7:0]top_left_u_w;
wire[   7:0]top_left_v_w;
wire[ 159:0]top_y_w;
wire[  63:0]top_u_w;
wire[  63:0]top_v_w;
wire[ 127:0]left_y_w;
wire[  63:0]left_u_w;
wire[  63:0]left_v_w;
reg [   7:0]cstate;
reg [   7:0]nstate;

parameter IDLE   = 'h1;
parameter INIT   = 'h2;
parameter RDEN   = 'h4; 
parameter DSTART = 'h8;
parameter WAIT   = 'h10;
parameter FULL   = 'h20;
parameter REINIT = 'h40;
parameter DONE   = 'h80;

assign fifo_rd_y0 = fifo_rd;
assign fifo_rd_y1 = fifo_rd;
assign fifo_rd_uv = fifo_rd;
assign fifo_rd = (cstate == RDEN) | (cstate == REINIT);

Decimate U_DECIMATE(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( D_start                       ),
    .x                              ( x                             ),
    .y                              ( y                             ),
    .Yin                            ( Yin                           ),
    .UVin                           ( UVin                          ),
    .lambda_i16                     ( lambda_i16                    ),
    .lambda_i4                      ( lambda_i4                     ),
    .lambda_uv                      ( lambda_uv                     ),
    .tlambda                        ( tlambda                       ),
    .lambda_mode                    ( lambda_mode                   ),
    .min_disto                      ( min_disto                     ),
    .top_left_y                     ( top_left_y                    ),
    .top_left_u                     ( top_left_u                    ),
    .top_left_v                     ( top_left_v                    ),
    .top_y                          ( top_y                         ),
    .top_u                          ( top_u                         ),
    .top_v                          ( top_v                         ),
    .left_y                         ( left_y                        ),
    .left_u                         ( left_u                        ),
    .left_v                         ( left_v                        ),
    .y1_q                           ( y1_q                          ),
    .y1_iq                          ( y1_iq                         ),
    .y1_bias                        ( y1_bias                       ),
    .y1_zthresh                     ( y1_zthresh                    ),
    .y1_sharpen                     ( y1_sharpen                    ),
    .y2_q                           ( y2_q                          ),
    .y2_iq                          ( y2_iq                         ),
    .y2_bias                        ( y2_bias                       ),
    .y2_zthresh                     ( y2_zthresh                    ),
    .y2_sharpen                     ( y2_sharpen                    ),
    .uv_q                           ( uv_q                          ),
    .uv_iq                          ( uv_iq                         ),
    .uv_bias                        ( uv_bias                       ),
    .uv_zthresh                     ( uv_zthresh                    ),
    .uv_sharpen                     ( uv_sharpen                    ),
    .Yout                           ( Yout                          ),
    .UVout                          ( UVout                         ),
    .mode_i16                       ( mode_i16                      ),
    .mode_i4                        ( mode_i4                       ),
    .mode_uv                        ( mode_uv                       ),
    .dc_levels                      ( dc_levels                     ),
    .ac_levels                      ( ac_levels                     ),
    .uv_levels                      ( uv_levels                     ),
    .skipped                        ( skipped                       ),
    .mbtype                         ( mbtype                        ),
    .nz                             ( nz                            ),
    .max_edge                       ( max_edge                      ),
    .done                           ( D_done                        )
);

SaveBoundary U_SAVEBOUNDARY(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .load                           ( D_done                        ),
    .x                              ( x                             ),
    .y                              ( y                             ),
    .w1                             ( w1                            ),
    .w2                             ( w2                            ),
    .h1                             ( h1                            ),
    .Yin                            ( Yout                          ),
    .UVin                           ( UVout                         ),
    .top_y_i                        ( top_y                         ),
    .top_u_i                        ( top_u                         ),
    .top_v_i                        ( top_v                         ),
    .top_left_y                     ( top_left_y_w                  ),
    .top_left_u                     ( top_left_u_w                  ),
    .top_left_v                     ( top_left_v_w                  ),
    .top_y                          ( top_y_w                       ),
    .top_u                          ( top_u_w                       ),
    .top_v                          ( top_v_w                       ),
    .left_y                         ( left_y_w                      ),
    .left_u                         ( left_u_w                      ),
    .left_v                         ( left_v_w                      )
);

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
                nstate = INIT;
            else
                nstate = IDLE;
        INIT:
            nstate = RDEN;
        RDEN:
            if(Y0_fifo_empty)
                nstate = RDEN;
            else
                nstate = DSTART;
        DSTART:
            nstate = WAIT;
        WAIT:
            if(D_done)
                if(fifo_full)
                    nstate = FULL;
                else
                    if(x >= w1 && y >= h1)
                        nstate = DONE;
                    else
                        nstate = REINIT;
            else
                nstate = WAIT;
        FULL:
            if(fifo_full)
                nstate = FULL;
            else
                if(x >= w1 && y >= h1)
                    nstate = DONE;
                else
                    nstate = REINIT;
        REINIT:
            if(Y0_fifo_empty)
                nstate = RDEN;
            else
                nstate = DSTART;
        DONE:
            nstate = IDLE;
        default:
            nstate = IDLE;
    endcase
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        done       <= 'b0;
        x          <= 'b0;
        y          <= 'b0;
        top_left_y <= 'b0;
        top_left_u <= 'b0;
        top_left_v <= 'b0;
        top_y      <= 'b0;
        top_u      <= 'b0;
        top_v      <= 'b0;
        left_y     <= 'b0;
        left_u     <= 'b0;
        left_v     <= 'b0;
        D_start    <= 'b0;
    end
    else begin
        case(cstate)
            IDLE:begin
                done       <= 1'b0;
            end
            INIT:begin
                x          <= 'b0;
                y          <= 'b0;
                top_left_y <= 8'd127;
                top_left_u <= 8'd127;
                top_left_v <= 8'd127;
                top_y      <= {20{8'd127}};
                top_u      <= { 8{8'd127}};
                top_v      <= { 8{8'd127}};
                left_y     <= {16{8'd129}};
                left_u     <= { 8{8'd129}};
                left_v     <= { 8{8'd129}};
            end
            RDEN:begin
                ;
            end
            DSTART:begin
                D_start    <= 1'b1;
            end
            WAIT:begin
                D_start    <= 1'b0;
            end
            FULL:begin
                ;
            end
            REINIT:begin
                x          <= (x >= w1) ? 'b0 : (x + 1'b1);
                y          <= (x >= w1) ? (y + 1'b1) : y;
                top_left_y <= top_left_y_w;
                top_left_u <= top_left_u_w;
                top_left_v <= top_left_v_w;
                top_y      <= top_y_w;
                top_u      <= top_u_w;
                top_v      <= top_v_w;
                left_y     <= left_y_w;
                left_u     <= left_u_w;
                left_v     <= left_v_w;
            end
            DONE:begin
                done       <= 1'b1;
            end
        endcase
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        count <= 'b0;
    else
        if(count >= 'd6)
            count <= 'b0;
        else if(D_done | count != 'b0)
            count <= count + 1'b1;
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        data_out <= 'b0;
        fifo_wr  <= 'b0;
    end
    else
        if(D_done | count != 'b0)begin
            fifo_wr  <= 1'b1;
            case(count)
                'd0: data_out <= ac_levels[1023:   0];
                'd1: data_out <= ac_levels[2047:1024];
                'd2: data_out <= ac_levels[3071:2048];
                'd3: data_out <= ac_levels[4095:3072];
                'd4: data_out <= uv_levels[1023:   0];
                'd5: data_out <= uv_levels[2047:1024];
                'd6: data_out <= {64'b0,max_edge,16'b0,skipped,mbtype,416'b0,
                                  nz,mode_uv,mode_i4,mode_i16,dc_levels};
                default:;
            endcase 
        end
        else begin
            fifo_wr  <= 1'b0;
        end
end

endmodule
