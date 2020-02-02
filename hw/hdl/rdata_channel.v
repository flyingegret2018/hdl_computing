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

assign y1_q        = {{15{tmp[  31:  16]}},tmp[  15:   0]};
assign y1_iq       = {{15{tmp[  63:  48]}},tmp[  47:  32]};
assign y1_bias     = {{15{tmp[ 127:  96]}},tmp[  95:  64]};
assign y1_zthresh  = {{15{tmp[ 191: 160]}},tmp[ 159: 128]};
assign y1_sharpen  = tmp[ 447: 192];
assign y2_q        = {{15{tmp[ 479: 464]}},tmp[ 463: 448]};
assign y2_iq       = {{15{tmp[ 511: 496]}},tmp[ 495: 480]};
assign y2_bias     = {{15{tmp[ 575: 544]}},tmp[ 543: 512]};
assign y2_zthresh  = {{15{tmp[ 639: 608]}},tmp[ 607: 576]};
assign y2_sharpen  = 256'b0;
assign uv_q        = {{15{tmp[ 671: 656]}},tmp[ 655: 640]};
assign uv_iq       = {{15{tmp[ 703: 688]}},tmp[ 687: 672]};
assign uv_bias     = {{15{tmp[ 767: 736]}},tmp[ 735: 704]};
assign uv_zthresh  = {{15{tmp[ 831: 800]}},tmp[ 799: 768]};
assign uv_sharpen  = 256'b0; 
assign min_disto   = tmp[ 863: 832];
assign lambda_i16  = tmp[ 895: 864];
assign lambda_i4   = tmp[ 927: 896];
assign lambda_uv   = tmp[ 959: 928];
assign tlambda     = tmp[ 991: 960];
assign lambda_mode = tmp[1023: 992];

endmodule
