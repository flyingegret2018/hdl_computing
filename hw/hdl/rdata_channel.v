//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       : rdata_channel.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-12-16 15:52
// LastModified   : 2019-12-16 15:52
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module rdata_channel #(
                       parameter ID_WIDTH      = 2
                       )
                      (
                       input                           clk               ,
                       input                           rst_n             , 
                                                        
                       //---- AXI bus ----               
                         // AXI read address channel       
                       input      [1023:0]             m_axi_rdata       ,  
                       input [ID_WIDTH-1:0]            m_axi_rid         ,  
                       input                           m_axi_rlast       , 
                       input                           m_axi_rvalid      ,
                       input      [0001:0]             m_axi_rresp       ,
                       output wire                     m_axi_rready      , 

                       //---- local control ----
                       input                           start_pulse       ,
                       output reg                      rd_error          ,

                       output     [32      - 1 : 0]    lambda_i16        ,
                       output     [32      - 1 : 0]    lambda_i4         ,
                       output     [32      - 1 : 0]    lambda_uv         ,
                       output     [32      - 1 : 0]    tlambda           ,
                       output     [32      - 1 : 0]    lambda_mode       ,
                       output     [32      - 1 : 0]    min_disto         ,
                       output     [16 * 16 - 1 : 0]    y1_q              ,
                       output     [16 * 16 - 1 : 0]    y1_iq             ,
                       output     [32 * 16 - 1 : 0]    y1_bias           ,
                       output     [32 * 16 - 1 : 0]    y1_zthresh        ,
                       output     [16 * 16 - 1 : 0]    y1_sharpen        ,
                       output     [16 * 16 - 1 : 0]    y2_q              ,
                       output     [16 * 16 - 1 : 0]    y2_iq             ,
                       output     [32 * 16 - 1 : 0]    y2_bias           ,
                       output     [32 * 16 - 1 : 0]    y2_zthresh        ,
                       output     [16 * 16 - 1 : 0]    y2_sharpen        ,
                       output     [16 * 16 - 1 : 0]    uv_q              ,
                       output     [16 * 16 - 1 : 0]    uv_iq             ,
                       output     [32 * 16 - 1 : 0]    uv_bias           ,
                       output     [32 * 16 - 1 : 0]    uv_zthresh        ,
                       output     [16 * 16 - 1 : 0]    uv_sharpen        ,
                       output reg [1023:0]             Y0_fifo_din       ,
                       output reg [1023:0]             Y1_fifo_din       ,
                       output     [1023:0]             UV_fifo_din       ,
                       input                           Y0_fifo_full      ,
                       input                           Y1_fifo_full      ,
                       input                           UV_fifo_full      ,
                       output                          Y0_fifo_wr        ,
                       output                          Y1_fifo_wr        ,
                       output                          UV_fifo_wr        
                       );

 wire        data_receive;
 wire        fifo_wr;
 reg [   3:0]count;
 reg [1023:0]tmp;

 assign m_axi_rready   = ~Y0_fifo_full | count != 'd1;
 assign data_receive   = m_axi_rvalid && m_axi_rready;
 assign fifo_wr        = m_axi_rvalid && m_axi_rready && m_axi_rlast && count != 'd0;
 assign Y0_fifo_wr     = fifo_wr;
 assign Y1_fifo_wr     = fifo_wr;
 assign UV_fifo_wr     = fifo_wr;
 assign UV_fifo_din    = m_axi_rdata;

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        count <= 'b0;
    end
    else begin
        if(start_pulse)
            count <= 'b0;
        else if(data_receive)
            if(count >= 'd3)
                count <= 'b1;
            else
                count <= count + 1'b1;
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        tmp         <= 'b0;
        Y0_fifo_din <= 'b0;
        Y1_fifo_din <= 'b0;
    end
    else begin
        if(data_receive)begin
            case(count)
                'd0:begin
                    tmp         <= m_axi_rdata;
                end
                'd1:begin
                    Y0_fifo_din <= m_axi_rdata;
                end
                'd2:begin
                    Y1_fifo_din <= m_axi_rdata;
                end
                'd3:begin
                    ;
                end
                default:;
            endcase
        end
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        rd_error <= 'b0;
    end
    else begin
        if(data_receive)
            if(m_axi_rresp != 'b0)
                rd_error <= 1'b1;
            else
                rd_error <= 1'b0;
    end
end

assign y1_q        = {{15{ 8'b0,tmp[  23:  16]}}, 8'b0,tmp[   7:   0]};
assign y1_iq       = {{15{      tmp[  63:  48]}},      tmp[  47:  32]};
assign y1_bias     = {{15{            32'hDC00}},            32'hC000};
assign y1_zthresh  = {{15{24'b0,tmp[ 167: 160]}},24'b0,tmp[ 135: 128]};
assign y1_sharpen  = tmp[ 447: 192];
assign y2_q        = {{15{ 8'b0,tmp[ 471: 464]}}, 8'b0,tmp[ 455: 448]};
assign y2_iq       = {{15{      tmp[ 511: 496]}},      tmp[ 495: 480]};
assign y2_bias     = {{15{            32'hD800}},            32'hC000};
assign y2_zthresh  = {{15{24'b0,tmp[ 615: 608]}},24'b0,tmp[ 583: 576]};
assign y2_sharpen  = 256'b0;
assign uv_q        = {{15{ 8'b0,tmp[ 663: 656]}}, 8'b0,tmp[ 647: 640]};
assign uv_iq       = {{15{      tmp[ 703: 688]}},      tmp[ 687: 672]};
assign uv_bias     = {{15{            32'hE600}},            32'hDC00};
assign uv_zthresh  = {{15{24'b0,tmp[ 807: 800]}},24'b0,tmp[ 775: 768]};
assign uv_sharpen  = 256'b0; 
assign min_disto   = {20'b0,tmp[ 843: 832]};
assign lambda_i16  = {16'b0,tmp[ 879: 864]};
assign lambda_i4   = {24'b0,tmp[ 903: 896]};
assign lambda_uv   = {24'b0,tmp[ 935: 928]};
assign lambda_mode = {28'b0,tmp[ 963: 960]};
assign tlambda     = {24'b0,tmp[ 999: 992]};

endmodule
