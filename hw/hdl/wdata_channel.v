//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       : wdata_channel.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-12-16 20:35
// LastModified   : 2019-12-16 20:35
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module wdata_channel
                      (
                       input                           clk                ,
                       input                           rst_n              , 

                       //---- AXI bus ----
                          // AXI write data channel
                       output            [1023:0]      m_axi_wdata        ,
                       output            [0127:0]      m_axi_wstrb        ,
                       output                          m_axi_wvalid       ,
                       output                          m_axi_wlast        ,
                       input                           m_axi_wready       ,

                       //---- local control ----
                       input                           start_pulse        ,
                       input       [0031:0]            mb_w               ,
                       input       [0031:0]            mb_h               ,
                                 
                       //---- local status report ----         
                       output reg                      done_pulse         ,

                       //---- WebPEncode ----
                       input                           fifo_empty         ,
                       input       [1023:0]            fifo_dout          ,
                       output                          fifo_rd      
                      );

 reg [ 2:0]rd_count;
 reg [31:0]mb_count;
 reg [31:0]mb_total;
 wire      data_sent;
 reg [ 4:0]cstate;
 reg [ 4:0]nstate;

parameter IDLE = 'h1;
parameter INIT = 'h2;
parameter WAIT = 'h4;
parameter SEND = 'h8;
parameter DONE = 'h10;

 assign m_axi_wdata    = fifo_dout;
 assign m_axi_wstrb    = {128{1'b1}};
 assign m_axi_wlast    = rd_count >= 'd6 && (cstate == SEND);
 assign m_axi_wvalid   = m_axi_wready && (cstate == SEND);
 assign fifo_rd        = m_axi_wready && (cstate == SEND);
 assign data_send      = m_axi_wready && (cstate == SEND);

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)
        cstate <= IDLE;
    else
        cstate <= nstate;
end

always @ * begin
    case(cstate)
        IDLE:
            if(start_pulse)
                nstate = INIT;
            else
                nstate = IDLE;
        INIT:
            if(fifo_empty)
                nstate = WAIT;
            else
                nstate = SEND;
        WAIT:
            if(fifo_empty)
                nstate = WAIT;
            else
                nstate = SEND;
        SEND:
            if(rd_count >= 'd6 && m_axi_wready)
                nstate = DONE;
            else
                nstate = SEND;
        DONE:
            if(mb_count >= mb_total)
                nstate = IDLE;
            else
                nstate = WAIT;
        default:
            nstate = IDLE;
    endcase
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        mb_total     <= 'b0;
    end
    else begin
        case(cstate)
            IDLE:begin
                ;
            end
            INIT:begin
                mb_total     <= mb_w[10:0] * mb_h[10:0];
            end
            WAIT:begin
                ;
            end
            SEND:begin
                ;
            end
            DONE:begin
                ;
            end
        endcase
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        rd_count <= 'b0;
    end
    else begin
        if(start_pulse)
            rd_count <= 'b0;
        else if(data_send)
            if(rd_count >= 'd6)
                rd_count <= 'b0;
            else
                rd_count <= rd_count + 1'b1;
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        mb_count <= 'b0;
    end
    else begin
        if(start_pulse)
            mb_count <= 'b0;
        else if(mb_count >= mb_total)
            mb_count <= 'b0;
        else if(m_axi_wlast && m_axi_wready)
            mb_count <= mb_count + 1'b1;
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        done_pulse <= 'b0;
    end
    else begin
        if(mb_count >= mb_total)
            done_pulse <= 'b1;
        else
            done_pulse <= 'b0;
    end
end

endmodule
