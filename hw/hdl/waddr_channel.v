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

module waddr_channel
                      (
                       input                           clk                ,
                       input                           rst_n              , 
                                                        
                       //---- AXI bus ----               
                         // AXI read address channel       
                       output wire [063:0]             m_axi_awaddr       ,  
                       output wire [007:0]             m_axi_awlen        ,  
                       output wire                     m_axi_awvalid      ,
                       input                           m_axi_awready      ,

                       //---- local control ----
                       input                           start_pulse        ,
                       input      [063:0]              target_address     ,
                       input      [009:0]              w1                 ,
                       input      [009:0]              h1                 
                       );

 reg [ 9:0]x;
 reg [ 9:0]y;
 reg [63:0]address;
 reg [ 2:0]cstate;
 reg [ 2:0]nstate;

parameter IDLE = 'h1;
parameter ADDR = 'h2;
parameter SEND = 'h4;

 assign m_axi_awaddr   = address;
 assign m_axi_awlen    = 8'd6;
 assign m_axi_awvalid  = (cstate == SEND);

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
                nstate = ADDR;
            else
                nstate = IDLE;
        ADDR:
            if(x > w1 && y >= h1)
                nstate = IDLE;
            else
                nstate = SEND;
        SEND:
            if(m_axi_awready)
                nstate = ADDR;
            else
                nstate = SEND;
        default:
            nstate = IDLE;
    endcase
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        address <= 'b0;
        x       <= 'b0;
        y       <= 'b0;
    end
    else begin
        case(cstate)
            IDLE:begin
                x       <= 'b0;
                y       <= 'b0;
            end
            ADDR:begin
                address <= (x == 10'b0 && y == 10'b0) ? target_address : (address + 'd896);
                x       <= (x >= w1) ? 10'b0 : (x + 1'b1);
                y       <= (x >= w1) ? (y + 1'b1) : y;
            end
            SEND:begin
                ;
            end
        endcase
    end
end

endmodule
