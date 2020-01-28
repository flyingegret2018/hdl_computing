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
,input             [10                   - 1 : 0] w1
,input             [10                   - 1 : 0] w2
,input             [10                   - 1 : 0] h1
,input             [ 8 * 16 * BLOCK_SIZE - 1 : 0] Yin
,input             [ 8 *  8 * BLOCK_SIZE - 1 : 0] UVin
,input             [ 8 * 20              - 1 : 0] top_y_i
,input             [ 8 *  8              - 1 : 0] top_u_i
,input             [ 8 *  8              - 1 : 0] top_v_i
,output reg        [ 8                   - 1 : 0] top_left_y
,output reg        [ 8                   - 1 : 0] top_left_u
,output reg        [ 8                   - 1 : 0] top_left_v
,output reg        [ 8 * 20              - 1 : 0] top_y
,output reg        [ 8 *  8              - 1 : 0] top_u
,output reg        [ 8 *  8              - 1 : 0] top_v
,output reg        [ 8 * 16              - 1 : 0] left_y
,output reg        [ 8 *  8              - 1 : 0] left_u
,output reg        [ 8 *  8              - 1 : 0] left_v
);

wire        top_y_wen;
wire        top_y_wea;
wire[  9:0] top_y_waddr;
wire[127:0] top_y_w;
reg         top_y_ren;
reg [  9:0] top_y_raddr;
wire[127:0] top_y_r;
wire        top_uv_wen;
wire        top_uv_wea;
wire[  9:0] top_uv_waddr;
wire[127:0] top_uv_w;
reg         top_uv_ren;
reg [  9:0] top_uv_raddr;
wire[127:0] top_uv_r;
reg [127:0] top_y_tmp;

top_ram U_TOP_Y_RAM (
    .clka                           ( clk                           ),
    .ena                            ( top_y_wen                     ),
    .wea                            ( top_y_wea                     ),
    .addra                          ( top_y_waddr                   ),
    .dina                           ( top_y_w                       ),
    .clkb                           ( clk                           ),
    .enb                            ( top_y_ren                     ),
    .addrb                          ( top_y_raddr                   ),
    .doutb                          ( top_y_r                       )
);

top_ram U_TOP_UV_RAM (
    .clka                           ( clk                           ),
    .ena                            ( top_uv_wen                    ),
    .wea                            ( top_uv_wea                    ),
    .addra                          ( top_uv_waddr                  ),
    .dina                           ( top_uv_w                      ),
    .clkb                           ( clk                           ),
    .enb                            ( top_uv_ren                    ),
    .addrb                          ( top_uv_raddr                  ),
    .doutb                          ( top_uv_r                      )
);

assign top_y_wen    = load;
assign top_y_wea    = load;
assign top_y_waddr  = x;
assign top_y_w      = Yin[2047:1920];
assign top_uv_wen   = load;
assign top_uv_wea   = load;
assign top_uv_waddr = x;
assign top_uv_w     = UVin[1023:896];

reg [2:0] cstate;
reg [2:0] nstate;

parameter READ       = 'h1;
parameter WAIT       = 'h2; 
parameter STORE      = 'h4;

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        cstate <= READ;
    else
        cstate <= nstate;
end

always @ * begin
    case(cstate)
        READ:
            nstate = WAIT;
        WAIT:
            if(load)
                nstate = STORE;
            else
                nstate = WAIT;
        STORE:
            nstate = READ;
        default:
            nstate = READ;
    endcase
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        top_y_ren    <= 'b0;
        top_y_raddr  <= 'b0;
        top_uv_ren   <= 'b0;
        top_uv_raddr <= 'b0;
        top_y_tmp    <= 'b0;
    end
    else begin
        case(cstate)
            READ:begin
                top_y_ren    <= 1'b1;
                top_uv_ren   <= 1'b1;
                top_y_raddr  <= (x < w2) ? (x + 2'd2) : (x < w1) ? 'b0 : 'b1;
                top_uv_raddr <= (x < w1) ? (x + 1'b1) : 'b0;
            end
            WAIT:begin
                top_y_ren    <= 1'b0;
                top_uv_ren   <= 1'b0;
            end
            STORE:begin
                top_y_tmp    <= top_y_r;
            end
        endcase
    end
end

always @ * begin
    if(x < w1)begin
        left_y = {Yin [2047:2040],Yin [1919:1912],Yin [1791:1784],Yin [1663:1656],
                  Yin [1535:1528],Yin [1407:1400],Yin [1279:1272],Yin [1151:1144],
                  Yin [1023:1016],Yin [ 895: 888],Yin [ 767: 760],Yin [ 639: 632],
                  Yin [ 511: 504],Yin [ 383: 376],Yin [ 255: 248],Yin [ 127: 120]};
        left_u = {UVin[ 959: 952],UVin[ 831: 824],UVin[ 703: 696],UVin[ 575: 568],
                  UVin[ 447: 440],UVin[ 319: 312],UVin[ 191: 184],UVin[  63:  56]};
        left_v = {UVin[1023:1016],UVin[ 895: 888],UVin[ 767: 760],UVin[ 639: 632],
                  UVin[ 511: 504],UVin[ 383: 376],UVin[ 255: 248],UVin[ 127: 120]};
        top_left_y = top_y_i[127:120];
        top_left_u = top_u_i[ 63: 56];
        top_left_v = top_v_i[ 63: 56];
    end
    else begin
        left_y = {16{8'd129}};
        left_u = { 8{8'd129}};
        left_v = { 8{8'd129}};
        top_left_y = 8'd129;
        top_left_u = 8'd129;
        top_left_v = 8'd129;
    end
end

always @ * begin
    if(y == 'b0 && x < w1)begin
        top_y = {20{8'd127}};
        top_u = { 8{8'd127}};
        top_v = { 8{8'd127}};
    end
    else begin
        top_y[127:0] = top_y_tmp;
        top_u = top_uv_r[ 63: 0];
        top_v = top_uv_r[127:64];
        if(x == w2)begin
            top_y[159:128] = {4{top_y_i[127:120]}};
        end
        else begin
            top_y[159:128] = top_y_r[31:0];
        end
    end
end

endmodule
