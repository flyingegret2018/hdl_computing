/*
 * Copyright 2019 International Business Machines
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
`timescale 1ns/1ps

module wr_data_send_channel
                      (
                       input                           clk                ,
                       input                           rst_n              , 

                       //---- AXI bus ----
                          // AXI write data channel
                       output reg        [1023:0]      m_axi_wdata        ,
                       output            [0127:0]      m_axi_wstrb        ,
                       output reg                      m_axi_wvalid       ,
                       output reg                      m_axi_wlast        ,
                       input                           m_axi_wready       ,

                       //---- local control ----
                       input                           start_pulse        ,
                       input       [0031:0]            mb_w               ,
                       input       [0031:0]            mb_h               ,
                                 
                       //---- local status report ----         
                       output wire                     done_pulse         ,

                       //---- WebPEncode ----
                       input                           fifo_empty         ,
                       input       [1023:0]            fifo_dout          ,
                       output                          fifo_rd      
                      );

 reg [ 2:0]count;
 reg [ 2:0]rd_count;
 reg [31:0]mb_count;
 reg [31:0]mb_total;
 wire      data_sent;
 reg [ 2:0]cstate;
 reg [ 2:0]nstate;

 assign m_axi_wstrb    = {128{1'b1}};
 assign data_send      = m_axi_wvalid && m_axi_wready;
 assign fifo_rd        = (cstate == RDEN) && (rd_count != 'b0)

parameter IDLE = 'h1;
parameter ADDR = 'h2;
parameter SEND = 'h4;

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
            nstate = RDEN;
        RDEN:
            if(fifo_empty)
                nstate = SEND;
            else
                nstate = RDEN;
        SEND:
            if(m_axi_awready)
                nstate = RDEN;
            else
                nstate = SEND;
        default:
            nstate = IDLE;
    endcase
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        mb_total     <= 'b0;
        fifo_rd      <= 'b0;
        m_axi_wdata  <= 'b0;
        m_axi_wvalid <= 'b0;
        m_axi_wlast  <= 'b0;
        done_pulse   <= 'b0;
    end
    else begin
        case(cstate)
            IDLE:begin
                m_axi_wvalid <= 1'b0;
                m_axi_wlast  <= 1'b0;
                done_pulse   <= 1'b0;
            end
            INIT:begin
                mb_total   <= mb_w[10:0] * mb_h[10:0];
            end
            ADDR:begin
            end
            SEND:begin
                ;
            end
        endcase
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        count <= 'b0;
    end
    else begin
        if(start_pulse)
            count <= 'b0;
        else if(data_send)
            if(count >= 'd6)
                count <= 'b0;
            else
                count <= count + 1'b1;
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        rd_count <= 'b0;
    end
    else begin
        if(start_pulse)
            rd_count <= 'b0;
        else if((cstate == RDEN) && (rd_count != 'b0))
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
        else if(m_axi_wlast)
            mb_count <= mb_count + 1'b1;
    end
end

endmodule
