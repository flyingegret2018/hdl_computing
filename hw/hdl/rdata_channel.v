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

 wire      data_receive;
 wire      fifo_wr;
 reg [ 3:0]count;

 assign m_axi_rready   = ~Y0_fifo_full | count != 'd0;
 assign data_receive   = m_axi_rvalid && m_axi_rready;
 assign fifo_wr        = m_axi_rvalid && m_axi_rready && m_axi_rlast;
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
            if(count >= 'd2)
                count <= 'b0;
            else
                count <= count + 1'b1;
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        Y0_fifo_din   <= 'b0;
        Y1_fifo_din   <= 'b0;
    end
    else begin
        if(data_receive)begin
            case(count)
                'd0:begin
                    Y0_fifo_din         <= m_axi_rdata;
                end
                'd1:begin
                    Y1_fifo_din         <= m_axi_rdata;
                end
                'd2:begin
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

assign lambda_i16  = 32'h18CC;
assign lambda_i4   = 32'h15;
assign lambda_uv   = 32'h1F;
assign tlambda     = 32'h2E;
assign lambda_mode = 32'h7;
assign min_disto   = 32'h1E0;
assign y1_q        = {{15{16'h001E}},16'h0018};
assign y1_iq       = {{15{16'h1111}},16'h1555};
assign y1_bias     = {{15{32'hDC00}},32'hC000};
assign y1_zthresh  = {{15{32'h0011}},32'h000F};
assign y1_sharpen  = {{7{16'h1}},16'h0,16'h1,16'h1,16'h0,16'h0,16'h1,{3{16'h0}}};
assign y2_q        = {{15{16'h002E}},16'h0030};
assign y2_iq       = {{15{16'h0B21}},16'h0AAA};
assign y2_bias     = {{15{32'hD800}},32'hC000};
assign y2_zthresh  = {{15{32'h001A}},32'h001E};
assign y2_sharpen  = 256'b0;
assign uv_q        = {{15{16'h001A}},16'h0017};
assign uv_iq       = {{15{16'h13B1}},16'h1642};
assign uv_bias     = {{15{32'hE600}},32'hDC00};
assign uv_zthresh  = {{15{32'h000E}},32'h000D};
assign uv_sharpen  = 256'b0;

endmodule
