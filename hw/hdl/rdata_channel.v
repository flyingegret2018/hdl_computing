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
                       input      [001:0]              m_axi_rresp       ,
                       output wire                     m_axi_rready      , 

                       //---- local control ----
                       input                           start_pulse       ,
                       output reg [001:0]              rd_error          ,

                       output reg [0031:0]             lambda_i16        ,
                       output reg [0031:0]             lambda_i4         ,
                       output reg [0031:0]             lambda_uv         ,
                       output reg [0031:0]             tlambda           ,
                       output reg [0031:0]             lambda_mode       ,
                       output reg [0031:0]             min_disto         ,
                       output reg [0031:0]             max_edge          ,
                       output reg                      reload            ,
                       output reg [0255:0]             y1_q              ,
                       output reg [0255:0]             y1_iq             ,
                       output reg [0511:0]             y1_bias           ,
                       output reg [0511:0]             y1_zthresh        ,
                       output reg [0255:0]             y1_sharpen        ,
                       output reg [0255:0]             y2_q              ,
                       output reg [0255:0]             y2_iq             ,
                       output reg [0511:0]             y2_bias           ,
                       output reg [0511:0]             y2_zthresh        ,
                       output reg [0255:0]             y2_sharpen        ,
                       output reg [0255:0]             uv_q              ,
                       output reg [0255:0]             uv_iq             ,
                       output reg [0511:0]             uv_bias           ,
                       output reg [0511:0]             uv_zthresh        ,
                       output reg [0255:0]             uv_sharpen        ,
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

 wire      data_receive;
 reg       fifo_wr;
 reg [ 3:0]count;

 assign data_receive   = m_axi_rvalid && m_axi_rready;
 assign Y0_fifo_wr     = fifo_wr;
 assign Y1_fifo_wr     = fifo_wr;
 assign UV_fifo_wr     = fifo_wr;
 assign m_axi_rready   = ~Y0_fifo_full;
 assign UV_fifo_din    = m_axi_rdata;

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        count <= 'b0;
    end
    else begin
        if(start_pulse)
            count <= 'b0;
        else if(data_receive)
            if(count >= 'd8)
                count <= 'd6;
            else
                count <= count + 1'b1;
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        lambda_i16    <= 'b0;
        lambda_i4     <= 'b0;
        lambda_uv     <= 'b0;
        tlambda       <= 'b0;
        lambda_mode   <= 'b0;
        min_disto     <= 'b0;
        max_edge      <= 'b0;
        reload        <= 'b0;
        y1_q          <= 'b0;
        y1_iq         <= 'b0;
        y1_bias       <= 'b0;
        y1_zthresh    <= 'b0;
        y1_sharpen    <= 'b0;
        y2_q          <= 'b0;
        y2_iq         <= 'b0;
        y2_bias       <= 'b0;
        y2_zthresh    <= 'b0;
        y2_sharpen    <= 'b0;
        uv_q          <= 'b0;
        uv_iq         <= 'b0;
        uv_bias       <= 'b0;
        uv_zthresh    <= 'b0;
        uv_sharpen    <= 'b0;
        Y0_fifo_din   <= 'b0;
        Y1_fifo_din   <= 'b0;
        fifo_wr       <= 'b0;
    end
    else begin
        reload        <= 'b0;
        fifo_wr       <= 'b0;
        if(data_receive)
            case(count)
                'd0:begin
                    y1_q                <= m_axi_rdata[ 255:  0];
                    y1_iq               <= m_axi_rdata[ 511:256];
                    y1_bias             <= m_axi_rdata[1023:512];
                end
                'd1:begin
                    y1_zthresh          <= m_axi_rdata[ 511:  0];
                    y1_sharpen          <= m_axi_rdata[ 767:512];
                    y2_q                <= m_axi_rdata[1023:768];
                end
                'd2:begin
                    y2_iq               <= m_axi_rdata[ 255:  0];
                    y2_bias             <= m_axi_rdata[ 767:256];
                    y2_zthresh[255:  0] <= m_axi_rdata[1023:768];
                end
                'd3:begin
                    y2_zthresh[511:256] <= m_axi_rdata[ 255:  0];
                    uv_q                <= m_axi_rdata[ 511:256];
                    uv_iq               <= m_axi_rdata[ 767:512];
                    uv_bias[255:  0]    <= m_axi_rdata[1023:768];
                end
                'd4:begin
                    uv_bias[511:256]    <= m_axi_rdata[ 255:  0];
                    y2_sharpen          <= m_axi_rdata[ 767:256];
                    uv_zthresh          <= m_axi_rdata[1023:768];
                end
                'd5:begin
                    uv_sharpen          <= m_axi_rdata[ 255:  0];
                    max_edge            <= m_axi_rdata[ 415:384];
                    min_disto           <= m_axi_rdata[ 447:416];
                    lambda_i16          <= m_axi_rdata[ 479:448];
                    lambda_i4           <= m_axi_rdata[ 511:480];
                    lambda_uv           <= m_axi_rdata[ 543:512];
                    lambda_mode         <= m_axi_rdata[ 575:544];
                    tlambda             <= m_axi_rdata[ 639:608];
                    reload              <= 1'b1;
                end
                'd6:begin
                    Y0_fifo_din         <= m_axi_rdata;
                end
                'd7:begin
                    Y1_fifo_din         <= m_axi_rdata;
                end
                'd8:begin
                    fifo_wr             <= 1'b1;
                end
                default:;
            endcase
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

endmodule
