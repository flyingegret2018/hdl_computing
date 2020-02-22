//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	Reconstruct.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-17 13:30
// LastModified   :	2019-11-21 13:31
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module Reconstruct#(
 parameter BLOCK_SIZE   = 16
)(
 input                                             clk
,input                                             rst_n
,input                                             start
,input      [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] YPred
,input      [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] Ysrc
,input      [16 * BLOCK_SIZE              - 1 : 0] q1
,input      [16 * BLOCK_SIZE              - 1 : 0] iq1
,input      [32 * BLOCK_SIZE              - 1 : 0] bias1
,input      [32 * BLOCK_SIZE              - 1 : 0] zthresh1
,input      [16 * BLOCK_SIZE              - 1 : 0] sharpen1
,input      [16 * BLOCK_SIZE              - 1 : 0] q2
,input      [16 * BLOCK_SIZE              - 1 : 0] iq2
,input      [32 * BLOCK_SIZE              - 1 : 0] bias2
,input      [32 * BLOCK_SIZE              - 1 : 0] zthresh2
,input      [16 * BLOCK_SIZE              - 1 : 0] sharpen2
,output     [ 8 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] Yout
,output     [16 * BLOCK_SIZE              - 1 : 0] Y_dc_levels
,output     [16 * BLOCK_SIZE * BLOCK_SIZE - 1 : 0] Y_ac_levels
,output     [32                           - 1 : 0] nz
,output reg                                        done
);

(* max_fanout = "64" *)reg  [ 8              - 1 : 0]count;
wire [ 8 * BLOCK_SIZE - 1 : 0]Ysrc_w[BLOCK_SIZE - 1 : 0];
wire [ 8 * BLOCK_SIZE - 1 : 0]YPred_w[BLOCK_SIZE - 1 : 0];
reg  [ 8 * BLOCK_SIZE - 1 : 0]Yout_r[BLOCK_SIZE - 1 : 0];
reg  [ 8 * BLOCK_SIZE - 1 : 0]Ysrc_r;
reg  [ 8 * BLOCK_SIZE - 1 : 0]YPred_r;
wire [ 8 * BLOCK_SIZE - 1 : 0]Yout_w;
wire [16 * BLOCK_SIZE - 1 : 0]FDCT_w;
reg  [16 * BLOCK_SIZE - 1 : 0]AC_Rout_r[BLOCK_SIZE - 1 : 0];
wire [16 * BLOCK_SIZE - 1 : 0]AC_Rout_w;
reg  [16 * BLOCK_SIZE - 1 : 0]Yac_r[BLOCK_SIZE - 1 : 0];
wire [16 * BLOCK_SIZE - 1 : 0]Yac_w;
reg  [16              - 1 : 0]AC_nz_r;
wire                          AC_nz_w;
reg  [16 * BLOCK_SIZE - 1 : 0]FWHT_r;
wire [16 * BLOCK_SIZE - 1 : 0]FWHT_w;
wire [16 * BLOCK_SIZE - 1 : 0]DC_Rout_w;
wire                          DC_nz_w;
wire [16 * BLOCK_SIZE - 1 : 0]IWHT_w;
reg  [16 * BLOCK_SIZE - 1 : 0]IDCT_r;

assign nz = {7'b0,DC_nz_w,8'b0,AC_nz_r};

genvar i;

generate

for(i = 0; i < BLOCK_SIZE; i = i + 1)begin
    assign Ysrc_w[i] = 
    {Ysrc[8*((i/4)*64+(i%4)*4+52)-1:8*((i/4)*64+(i%4)*4+48)],
     Ysrc[8*((i/4)*64+(i%4)*4+36)-1:8*((i/4)*64+(i%4)*4+32)],
     Ysrc[8*((i/4)*64+(i%4)*4+20)-1:8*((i/4)*64+(i%4)*4+16)],
     Ysrc[8*((i/4)*64+(i%4)*4+ 4)-1:8*((i/4)*64+(i%4)*4+ 0)]};

    assign YPred_w[i] = 
    {YPred[8*((i/4)*64+(i%4)*4+52)-1:8*((i/4)*64+(i%4)*4+48)],
     YPred[8*((i/4)*64+(i%4)*4+36)-1:8*((i/4)*64+(i%4)*4+32)],
     YPred[8*((i/4)*64+(i%4)*4+20)-1:8*((i/4)*64+(i%4)*4+16)],
     YPred[8*((i/4)*64+(i%4)*4+ 4)-1:8*((i/4)*64+(i%4)*4+ 0)]};

    assign 
    {Yout[8*((i/4)*64+(i%4)*4+52)-1:8*((i/4)*64+(i%4)*4+48)],
     Yout[8*((i/4)*64+(i%4)*4+36)-1:8*((i/4)*64+(i%4)*4+32)],
     Yout[8*((i/4)*64+(i%4)*4+20)-1:8*((i/4)*64+(i%4)*4+16)],
     Yout[8*((i/4)*64+(i%4)*4+ 4)-1:8*((i/4)*64+(i%4)*4+ 0)]}
     = Yout_r[i];

    assign Y_ac_levels[256 * (i + 1) - 1 : 256 * i] = Yac_r[i];
end

endgenerate

FTransform #(
    .I_WIDTH                        (  8                            ),
    .O_WIDTH                        ( 16                            ))
U_FDCT(
     .clk                           ( clk                           )
    ,.rst_n                         ( rst_n                         )
    ,.start                         (                               )
    ,.src                           ( Ysrc_r                        )
    ,.ref                           ( YPred_r                       )
    ,.out                           ( FDCT_w                        )
    ,.done                          (                               )
);

QuantizeBlock #(
    .BLOCK_SIZE                     ( 4                             ),
    .IW                             ( 16                            ))
U_QBAC(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          (                               ),
    .in                             ( {FDCT_w[255:16],16'b0}        ),
    .q                              ( q1                            ),
    .iq                             ( iq1                           ),
    .bias                           ( bias1                         ),
    .zthresh                        ( zthresh1                      ),
    .sharpen                        ( sharpen1                      ),
    .Rout                           ( AC_Rout_w                     ),
    .out                            ( Yac_w                         ),
    .nz                             ( AC_nz_w                       ),
    .done                           (                               )
);

FTransformWHT U_FWHT(
     .clk                           ( clk                           )   
    ,.rst_n                         ( rst_n                         )
    ,.start                         (                               )
    ,.in                            ( FWHT_r                        )
    ,.out                           ( FWHT_w                        )
    ,.done                          (                               )
);

QuantizeBlock #(
    .BLOCK_SIZE                     ( 4                             ),
    .IW                             ( 16                            ))
U_QBDC(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          (                               ),
    .in                             ( FWHT_w                        ),
    .q                              ( q2                            ),
    .iq                             ( iq2                           ),
    .bias                           ( bias2                         ),
    .zthresh                        ( zthresh2                      ),
    .sharpen                        ( sharpen2                      ),
    .Rout                           ( DC_Rout_w                     ),
    .out                            ( Y_dc_levels                   ),
    .nz                             ( DC_nz_w                       ),
    .done                           (                               )
);

ITransformWHT U_IWHT(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          (                               ),
    .in                             ( DC_Rout_w                     ),
    .out                            ( IWHT_w                        ),
    .done                           (                               )
);

ITransform U_IDCT(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          (                               ),
    .src                            ( IDCT_r                        ),
    .ref                            ( YPred_r                       ),
    .out                            ( Yout_w                        ),
    .done                           (                               )
);

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        count <= 'b0;
    else
        if(count >= 'd41)
            count <= 'b0;
        else if(start | count != 'b0)
            count <= count + 1'b1;
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        Ysrc_r          <= 'b0;
        YPred_r         <= 'b0;
        Yac_r[ 0]       <= 'b0;
        Yac_r[ 1]       <= 'b0;
        Yac_r[ 2]       <= 'b0;
        Yac_r[ 3]       <= 'b0;
        Yac_r[ 4]       <= 'b0;
        Yac_r[ 5]       <= 'b0;
        Yac_r[ 6]       <= 'b0;
        Yac_r[ 7]       <= 'b0;
        Yac_r[ 8]       <= 'b0;
        Yac_r[ 9]       <= 'b0;
        Yac_r[10]       <= 'b0;
        Yac_r[11]       <= 'b0;
        Yac_r[12]       <= 'b0;
        Yac_r[13]       <= 'b0;
        Yac_r[14]       <= 'b0;
        Yac_r[15]       <= 'b0;
        AC_Rout_r[ 0]   <= 'b0;
        AC_Rout_r[ 1]   <= 'b0;
        AC_Rout_r[ 2]   <= 'b0;
        AC_Rout_r[ 3]   <= 'b0;
        AC_Rout_r[ 4]   <= 'b0;
        AC_Rout_r[ 5]   <= 'b0;
        AC_Rout_r[ 6]   <= 'b0;
        AC_Rout_r[ 7]   <= 'b0;
        AC_Rout_r[ 8]   <= 'b0;
        AC_Rout_r[ 9]   <= 'b0;
        AC_Rout_r[10]   <= 'b0;
        AC_Rout_r[11]   <= 'b0;
        AC_Rout_r[12]   <= 'b0;
        AC_Rout_r[13]   <= 'b0;
        AC_Rout_r[14]   <= 'b0;
        AC_Rout_r[15]   <= 'b0;
        AC_nz_r         <= 'b0;
        FWHT_r          <= 'b0;
        IDCT_r          <= 'b0;
        Yout_r[ 0]      <= 'b0;
        Yout_r[ 1]      <= 'b0;
        Yout_r[ 2]      <= 'b0;
        Yout_r[ 3]      <= 'b0;
        Yout_r[ 4]      <= 'b0;
        Yout_r[ 5]      <= 'b0;
        Yout_r[ 6]      <= 'b0;
        Yout_r[ 7]      <= 'b0;
        Yout_r[ 8]      <= 'b0;
        Yout_r[ 9]      <= 'b0;
        Yout_r[10]      <= 'b0;
        Yout_r[11]      <= 'b0;
        Yout_r[12]      <= 'b0;
        Yout_r[13]      <= 'b0;
        Yout_r[14]      <= 'b0;
        Yout_r[15]      <= 'b0;
        done            <= 'b0;
    end
    else begin
        case(count)
            'd0:begin
                Ysrc_r          <= Ysrc_w [ 0];
                YPred_r         <= YPred_w[ 0];
                done            <= 'b0;
            end
            'd1:begin
                Ysrc_r          <= Ysrc_w [ 1];
                YPred_r         <= YPred_w[ 1];
            end
            'd2:begin
                Ysrc_r          <= Ysrc_w [ 2];
                YPred_r         <= YPred_w[ 2];
            end
            'd3:begin
                Ysrc_r          <= Ysrc_w [ 3];
                YPred_r         <= YPred_w[ 3];
                FWHT_r[ 15:  0] <= FDCT_w[15:0];
            end
            'd4:begin
                Ysrc_r          <= Ysrc_w [ 4];
                YPred_r         <= YPred_w[ 4];
                FWHT_r[ 31: 16] <= FDCT_w[15:0];
            end
            'd5:begin
                Ysrc_r          <= Ysrc_w [ 5];
                YPred_r         <= YPred_w[ 5];
                FWHT_r[ 47: 32] <= FDCT_w[15:0];
                Yac_r[0]        <= Yac_w;
                AC_Rout_r[0]    <= AC_Rout_w;
                AC_nz_r[0]      <= AC_nz_w;
            end
            'd6:begin
                Ysrc_r          <= Ysrc_w [ 6];
                YPred_r         <= YPred_w[ 6];
                FWHT_r[ 63: 48] <= FDCT_w[15:0];
                Yac_r[1]        <= Yac_w;
                AC_Rout_r[1]    <= AC_Rout_w;
                AC_nz_r[1]      <= AC_nz_w;
            end
            'd7:begin
                Ysrc_r          <= Ysrc_w [ 7];
                YPred_r         <= YPred_w[ 7];
                FWHT_r[ 79: 64] <= FDCT_w[15:0];
                Yac_r[2]        <= Yac_w;
                AC_Rout_r[2]    <= AC_Rout_w;
                AC_nz_r[2]      <= AC_nz_w;
            end
            'd8:begin
                Ysrc_r          <= Ysrc_w [ 8];
                YPred_r         <= YPred_w[ 8];
                FWHT_r[ 95: 80] <= FDCT_w[15:0];
                Yac_r[3]        <= Yac_w;
                AC_Rout_r[3]    <= AC_Rout_w;
                AC_nz_r[3]      <= AC_nz_w;
            end
            'd9:begin
                Ysrc_r          <= Ysrc_w [ 9];
                YPred_r         <= YPred_w[ 9];
                FWHT_r[111: 96] <= FDCT_w[15:0];
                Yac_r[4]        <= Yac_w;
                AC_Rout_r[4]    <= AC_Rout_w;
                AC_nz_r[4]      <= AC_nz_w;
            end
            'd10:begin
                Ysrc_r          <= Ysrc_w [10];
                YPred_r         <= YPred_w[10];
                FWHT_r[127:112] <= FDCT_w[15:0];
                Yac_r[5]        <= Yac_w;
                AC_Rout_r[5]    <= AC_Rout_w;
                AC_nz_r[5]      <= AC_nz_w;
            end
            'd11:begin
                Ysrc_r          <= Ysrc_w [11];
                YPred_r         <= YPred_w[11];
                FWHT_r[143:128] <= FDCT_w[15:0];
                Yac_r[6]        <= Yac_w;
                AC_Rout_r[6]    <= AC_Rout_w;
                AC_nz_r[6]      <= AC_nz_w;
            end
            'd12:begin
                Ysrc_r          <= Ysrc_w [12];
                YPred_r         <= YPred_w[12];
                FWHT_r[159:144] <= FDCT_w[15:0];
                Yac_r[7]        <= Yac_w;
                AC_Rout_r[7]    <= AC_Rout_w;
                AC_nz_r[7]      <= AC_nz_w;
            end
            'd13:begin
                Ysrc_r          <= Ysrc_w [13];
                YPred_r         <= YPred_w[13];
                FWHT_r[175:160] <= FDCT_w[15:0];
                Yac_r[8]        <= Yac_w;
                AC_Rout_r[8]    <= AC_Rout_w;
                AC_nz_r[8]      <= AC_nz_w;
            end
            'd14:begin
                Ysrc_r          <= Ysrc_w [14];
                YPred_r         <= YPred_w[14];
                FWHT_r[191:176] <= FDCT_w[15:0];
                Yac_r[9]        <= Yac_w;
                AC_Rout_r[9]    <= AC_Rout_w;
                AC_nz_r[9]      <= AC_nz_w;
            end
            'd15:begin
                Ysrc_r          <= Ysrc_w [15];
                YPred_r         <= YPred_w[15];
                FWHT_r[207:192] <= FDCT_w[15:0];
                Yac_r[10]       <= Yac_w;
                AC_Rout_r[10]   <= AC_Rout_w;
                AC_nz_r[10]     <= AC_nz_w;
            end
            'd16:begin
                FWHT_r[223:208] <= FDCT_w[15:0];
                Yac_r[11]       <= Yac_w;
                AC_Rout_r[11]   <= AC_Rout_w;
                AC_nz_r[11]     <= AC_nz_w;
            end
            'd17:begin
                FWHT_r[239:224] <= FDCT_w[15:0];
                Yac_r[12]       <= Yac_w;
                AC_Rout_r[12]   <= AC_Rout_w;
                AC_nz_r[12]     <= AC_nz_w;
            end
            'd18:begin
                FWHT_r[255:240] <= FDCT_w[15:0];
                Yac_r[13]       <= Yac_w;
                AC_Rout_r[13]   <= AC_Rout_w;
                AC_nz_r[13]     <= AC_nz_w;
            end
            'd19:begin
                Yac_r[14]       <= Yac_w;
                AC_Rout_r[14]   <= AC_Rout_w;
                AC_nz_r[14]     <= AC_nz_w;
            end
            'd20:begin
                Yac_r[15]       <= Yac_w;
                AC_Rout_r[15]   <= AC_Rout_w;
                AC_nz_r[15]     <= AC_nz_w;
            end
            'd23:begin
                IDCT_r          <= {AC_Rout_r[ 0][255:16],IWHT_w[ 15:  0]};
            end
            'd24:begin
                IDCT_r          <= {AC_Rout_r[ 1][255:16],IWHT_w[ 31: 16]};
                YPred_r         <= YPred_w[ 0];
            end
            'd25:begin
                IDCT_r          <= {AC_Rout_r[ 2][255:16],IWHT_w[ 47: 32]};
                YPred_r         <= YPred_w[ 1];
            end
            'd26:begin
                IDCT_r          <= {AC_Rout_r[ 3][255:16],IWHT_w[ 63: 48]};
                YPred_r         <= YPred_w[ 2];
                Yout_r[ 0]      <= Yout_w;
            end
            'd27:begin
                IDCT_r          <= {AC_Rout_r[ 4][255:16],IWHT_w[ 79: 64]};
                YPred_r         <= YPred_w[ 3];
                Yout_r[ 1]      <= Yout_w;
            end
            'd28:begin
                IDCT_r          <= {AC_Rout_r[ 5][255:16],IWHT_w[ 95: 80]};
                YPred_r         <= YPred_w[ 4];
                Yout_r[ 2]      <= Yout_w;
            end
            'd29:begin
                IDCT_r          <= {AC_Rout_r[ 6][255:16],IWHT_w[111: 96]};
                YPred_r         <= YPred_w[ 5];
                Yout_r[ 3]      <= Yout_w;
            end
            'd30:begin
                IDCT_r          <= {AC_Rout_r[ 7][255:16],IWHT_w[127:112]};
                YPred_r         <= YPred_w[ 6];
                Yout_r[ 4]      <= Yout_w;
            end
            'd31:begin
                IDCT_r          <= {AC_Rout_r[ 8][255:16],IWHT_w[143:128]};
                YPred_r         <= YPred_w[ 7];
                Yout_r[ 5]      <= Yout_w;
            end
            'd32:begin
                IDCT_r          <= {AC_Rout_r[ 9][255:16],IWHT_w[159:144]};
                YPred_r         <= YPred_w[ 8];
                Yout_r[ 6]      <= Yout_w;
            end
            'd33:begin
                IDCT_r          <= {AC_Rout_r[10][255:16],IWHT_w[175:160]};
                YPred_r         <= YPred_w[ 9];
                Yout_r[ 7]      <= Yout_w;
            end
            'd34:begin
                IDCT_r          <= {AC_Rout_r[11][255:16],IWHT_w[191:176]};
                YPred_r         <= YPred_w[10];
                Yout_r[ 8]      <= Yout_w;
            end
            'd35:begin
                IDCT_r          <= {AC_Rout_r[12][255:16],IWHT_w[207:192]};
                YPred_r         <= YPred_w[11];
                Yout_r[ 9]      <= Yout_w;
            end
            'd36:begin
                IDCT_r          <= {AC_Rout_r[13][255:16],IWHT_w[223:208]};
                YPred_r         <= YPred_w[12];
                Yout_r[10]      <= Yout_w;
            end
            'd37:begin
                IDCT_r          <= {AC_Rout_r[14][255:16],IWHT_w[239:224]};
                YPred_r         <= YPred_w[13];
                Yout_r[11]      <= Yout_w;
            end
            'd38:begin
                IDCT_r          <= {AC_Rout_r[15][255:16],IWHT_w[255:240]};
                YPred_r         <= YPred_w[14];
                Yout_r[12]      <= Yout_w;
            end
            'd39:begin
                YPred_r         <= YPred_w[15];
                Yout_r[13]      <= Yout_w;
            end
            'd40:begin
                Yout_r[14]      <= Yout_w;
            end
            'd41:begin
                Yout_r[15]      <= Yout_w;
                done            <= 'b1;
            end
            default:;
        endcase 
    end
end

endmodule
