//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       : axi_lite_slave.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-12-12 16:09
// LastModified   : 2019-12-12 16:09
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module axi_lite_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
                      input                            clk              ,
                      input                            rst_n            ,

                      //---- AXI Lite bus----
                        // AXI write address channel
                      output reg                       s_axi_awready    ,
                      input      [ADDR_WIDTH - 1:0]    s_axi_awaddr     ,
                      input                            s_axi_awvalid    ,
                        // axi write data channel
                      output reg                       s_axi_wready     ,
                      input      [DATA_WIDTH - 1:0]    s_axi_wdata      ,
                      input      [(DATA_WIDTH/8) - 1:0]s_axi_wstrb      ,
                      input                            s_axi_wvalid     ,
                        // AXI response channel
                      output     [01:0]                s_axi_bresp      ,
                      output reg                       s_axi_bvalid     ,
                      input                            s_axi_bready     ,
                        // AXI read address channel
                      output reg                       s_axi_arready    ,
                      input                            s_axi_arvalid    ,
                      input      [ADDR_WIDTH - 1:0]    s_axi_araddr     ,
                        // AXI read data channel
                      output reg [DATA_WIDTH - 1:0]    s_axi_rdata      ,
                      output     [01:0]                s_axi_rresp      ,
                      input                            s_axi_rready     ,
                      output reg                       s_axi_rvalid     ,

                      //---- local control ----
                      output                           start_pulse      ,
                      output     [63:0]                source_address   ,
                      output     [63:0]                target_address   ,
                      output     [63:0]                dqm_address      ,
                      output     [31:0]                mb_w             ,
                      output     [31:0]                mb_h             ,
                      output     [09:0]                w1               ,
                      output     [09:0]                w2               ,
                      output     [09:0]                h1               ,
                      //---- local status ----
                      input                            done_pulse       ,
                      input                            rd_error         ,
                      input                            wr_error         ,

                      //---- snap status ----
                      input      [31:0]                i_action_type    ,
                      input      [31:0]                i_action_version ,
                      output     [31:0]                o_snap_context
                      );
            

//---- declarations ----
 wire[31:0] REG_snap_control_rd;
 wire[31:0] REG_user_status;

 wire[31:0] regw_snap_status;
 wire[31:0] regw_snap_int_enable;
 wire[31:0] regw_snap_context;

 wire[31:0] regw_control;
 wire[63:0] regw_source_address;
 wire[63:0] regw_target_address;
 wire[31:0] regw_mb_w;
 wire[31:0] regw_mb_h;
 wire[63:0] regw_dqm_address;
 wire[31:0] regw_soft_reset;

 reg [31:0] write_address;
 wire[31:0] wr_mask;

 wire       soft_reset;
 

 ///////////////////////////////////////////////////
 //***********************************************//
 //>                REGISTERS                    <//
 //***********************************************//
 //                                               //
 /**/   reg [31:0] REG_snap_control          ;  /**/
 /**/   reg [31:0] REG_snap_int_enable       ;  /**/
 /**/   reg [31:0] REG_snap_context          ;  /**/
 /*-----------------------------------------------*/
 /**/   reg [31:0] REG_user_control          ;  /**/
 /**/   reg [63:0] REG_source_address        ;  /**/
 /**/   reg [63:0] REG_target_address        ;  /**/
 /**/   reg [63:0] REG_dqm_address           ;  /**/
 /**/   reg [31:0] REG_mb_w                  ;  /**/
 /**/   reg [31:0] REG_mb_h                  ;  /**/
 /**/   reg [31:0] REG_soft_reset            ;  /**/
 //                                               //
 //-----------------------------------------------//
 //                                               //
 ///////////////////////////////////////////////////


//---- parameters ----
 // Register addresses arrangement
 parameter ADDR_SNAP_CONTROL        = 32'h00,
           ADDR_SNAP_INT_ENABLE     = 32'h04,
           ADDR_SNAP_ACTION_TYPE    = 32'h10,
           ADDR_SNAP_ACTION_VERSION = 32'h14,
           ADDR_SNAP_CONTEXT        = 32'h20,
           // User defined below
           ADDR_USER_STATUS         = 32'h30,
           ADDR_USER_CONTROL        = 32'h34,
           ADDR_SOURCE_ADDRESS_L    = 32'h38,
           ADDR_SOURCE_ADDRESS_H    = 32'h3C,
           ADDR_TARGET_ADDRESS_L    = 32'h40,
           ADDR_TARGET_ADDRESS_H    = 32'h44,
           ADDR_DQM_ADDRESS_L       = 32'h48,
           ADDR_DQM_ADDRESS_H       = 32'h4C,
           ADDR_MB_W                = 32'h50,
           ADDR_MB_H                = 32'h54,
           ADDR_SOFT_RESET          = 32'h58;

 

//---- local controlling signals assignments ----
 assign source_address = REG_source_address;
 assign target_address = REG_target_address;
 assign dqm_address    = REG_dqm_address;
 assign mb_w           = REG_mb_w;
 assign mb_h           = REG_mb_h;
 assign o_snap_context = REG_snap_context;
 assign soft_reset     = REG_soft_reset[0];

/***********************************************************************
*                          writing registers                           *
***********************************************************************/

//---- write address capture ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     write_address <= 32'd0;
   else if(s_axi_awvalid & s_axi_awready)
     write_address <= s_axi_awaddr;

//---- write address ready ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     s_axi_awready <= 1'b1;
   else if(s_axi_awvalid)
     s_axi_awready <= 1'b0;
   else if(s_axi_wvalid & s_axi_wready)
     s_axi_awready <= 1'b1;

//---- write data ready ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     s_axi_wready <= 1'b0;
   else if(s_axi_awvalid & s_axi_awready)
     s_axi_wready <= 1'b1;
   else if(s_axi_wvalid)
     s_axi_wready <= 1'b0;

//---- handle write data strobe ----
 assign wr_mask = {{8{s_axi_wstrb[3]}},{8{s_axi_wstrb[2]}},{8{s_axi_wstrb[1]}},{8{s_axi_wstrb[0]}}};

 assign regw_snap_status     = {(s_axi_wdata&wr_mask)|(~wr_mask&REG_snap_control)};
 assign regw_snap_int_enable = {(s_axi_wdata&wr_mask)|(~wr_mask&REG_snap_int_enable)};
 assign regw_snap_context    = {(s_axi_wdata&wr_mask)|(~wr_mask&REG_snap_context)};
 assign regw_control         = {(s_axi_wdata&wr_mask)|(~wr_mask&REG_user_control)};
 assign regw_source_address  = {(s_axi_wdata&wr_mask)|(~wr_mask&REG_source_address)};
 assign regw_target_address  = {(s_axi_wdata&wr_mask)|(~wr_mask&REG_target_address)};
 assign regw_dqm_address     = {(s_axi_wdata&wr_mask)|(~wr_mask&REG_dqm_address)};
 assign regw_mb_w            = {(s_axi_wdata&wr_mask)|(~wr_mask&REG_mb_w)};
 assign regw_mb_h            = {(s_axi_wdata&wr_mask)|(~wr_mask&REG_mb_h)};
 assign regw_soft_reset      = {(s_axi_wdata&wr_mask)|(~wr_mask&REG_soft_reset)};

//---- write registers ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     begin
       REG_snap_control    <= 32'd0;
       REG_snap_int_enable <= 32'd0;
       REG_snap_context    <= 32'd0;
       REG_user_control    <= 32'd0;
       REG_source_address  <= 64'd0;
       REG_target_address  <= 64'd0;
       REG_dqm_address     <= 64'd0;
       REG_mb_w            <= 32'd0;
       REG_mb_h            <= 32'd0;
       REG_soft_reset      <= 32'd0;
     end
    else if(soft_reset)
    begin
       REG_snap_control    <= 32'd0;
       REG_snap_int_enable <= 32'd0;
       REG_snap_context    <= 32'd0;
       REG_user_control    <= 32'd0;
       REG_source_address  <= 64'd0;
       REG_target_address  <= 64'd0;
       REG_dqm_address     <= 64'd0;
       REG_mb_w            <= 32'd0;
       REG_mb_h            <= 32'd0;
       REG_soft_reset      <= 32'd0;
    end
   else if(s_axi_wvalid & s_axi_wready)
     case(write_address)
       ADDR_SNAP_CONTROL     : REG_snap_control    <= regw_snap_status;
       ADDR_SNAP_INT_ENABLE  : REG_snap_int_enable <= regw_snap_int_enable;
       ADDR_SNAP_CONTEXT     : REG_snap_context    <= regw_snap_context;

       ADDR_USER_CONTROL     : REG_user_control    <= regw_control;

       ADDR_SOURCE_ADDRESS_H : REG_source_address  <= {regw_source_address,REG_source_address[31:00]};
       ADDR_SOURCE_ADDRESS_L : REG_source_address  <= {REG_source_address[63:32],regw_source_address};
       ADDR_TARGET_ADDRESS_H : REG_target_address  <= {regw_target_address,REG_target_address[31:00]};
       ADDR_TARGET_ADDRESS_L : REG_target_address  <= {REG_target_address[63:32],regw_target_address};
       ADDR_DQM_ADDRESS_H    : REG_dqm_address     <= {regw_dqm_address,REG_dqm_address[31:00]};
       ADDR_DQM_ADDRESS_L    : REG_dqm_address     <= {REG_dqm_address[63:32],regw_dqm_address};
       ADDR_MB_W             : REG_mb_w            <= regw_mb_w;
       ADDR_MB_H             : REG_mb_h            <= regw_mb_h;

       ADDR_SOFT_RESET       : REG_soft_reset      <= regw_soft_reset;
       default :;
     endcase

 reg [9:0]w1;
 reg [9:0]w2;
 reg [9:0]h1;
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     begin
       w1 <= 10'd0;
       w2 <= 10'd0;
       h1 <= 10'd0;
     end
    else if(soft_reset)
    begin
       w1 <= 10'd0;
       w2 <= 10'd0;
       h1 <= 10'd0;
    end
   else if(s_axi_wvalid & s_axi_wready)
     case(write_address)
       ADDR_MB_W: w1 <= regw_mb_w - 1'd1;
       ADDR_MB_W: w2 <= regw_mb_w - 2'd2;
       ADDR_MB_H: h1 <= regw_mb_h - 1'd1;
       default :;
     endcase

/***********************************************************************
*                          Control Flow                                *
***********************************************************************/
// The build-in snap_action_start() and snap_action_completed functions 
// sets REG_snap_control bit "start" and reads bit "idle"
// The other things are managed by REG_user_control (user defined control register)
// Flow:
// ---------------------------------------------------------------------------------------------
// Software                                  Hardware REG                               Hardware signal & action
// ---------------------------------------------------------------------------------------------
// snap_action_start()                      |                                          |
//                                          | SNAP_CONTROL[snap_start]=1               |
// mmio_write(USER_CONTROL[address...])     |                                          | snap_start_pulse
// mmio_write(USER_CONTROL[mb_w...])        |                                          |
// mmio_write(USER_CONTROL[mb_h...])        |                                          |
// mmio_write(USER_CONTROL[start])=1        |                                          |
//                                          | CONTROL[start]=1                         |
//                                          |                                          | start
//                                          |                                          | Run WebPEncode
//                                          |                                          | .
//                                          |                                          | .
//                                          |                                          | .
//                                          |                                          | done
//                                          | USER_STATUS[done]= 1                     |
// wait(USER_STATUS)                        |                                          |
// mmio_write(USER_CONTROL[finish])=1       |                                          |
//                                          | USER_CONTROL[finish]=1                   |
//                                          | SNAP_CONTROL[snap_idle]=1                |
// snap_action_completed()                  |                                          |
//

wire snap_start_pulse;

reg snap_start_q;
reg snap_idle_q;
reg start_q;

reg rd_error_q;
reg wr_error_q;
reg done_q;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        snap_start_q <= 0;
        start_q      <= 0;
    end
    else if(soft_reset) begin
        snap_start_q <= 0;
        start_q      <= 0;
    end
    else begin
        snap_start_q <= REG_snap_control[0];
        start_q      <= REG_user_control[0];
    end
end

assign snap_start_pulse = REG_snap_control[0] & ~snap_start_q;
assign start_pulse = REG_user_control[0] & ~start_q;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
       snap_idle_q <= 0;
    end
    else if(soft_reset) begin
       snap_idle_q <= 0;
    end
    else if (REG_user_control[1]) begin   //finish
       snap_idle_q <= 1;
    end
end

always@(posedge clk or negedge rst_n)
   if (~rst_n) begin
     rd_error_q      <= 0;
   end
   else if(soft_reset) begin
     rd_error_q      <= 0;
   end
   else if(rd_error) begin
     rd_error_q      <= rd_error;
   end

always@(posedge clk or negedge rst_n)
   if (~rst_n) begin
     wr_error_q      <= 0;
   end
   else if(soft_reset) begin
     wr_error_q      <= 0;
   end
   else if(wr_error) begin
     wr_error_q      <= 1;
   end

always@(posedge clk or negedge rst_n)
   if (~rst_n)
     done_q <= 0;
   else if(soft_reset)
     done_q <= 0;
   else if (done_pulse)
     done_q <= 1;

assign REG_user_status     = {'d0, rd_error_q, wr_error_q, done_q};
assign REG_snap_control_rd = {REG_snap_control[31:4], 1'b1, snap_idle_q, 1'b0, snap_start_q};
//Address: 0x000
//  31..8  RO: Reserved
//      7  RW: auto restart
//   6..4  RO: Reserved
//      3  RO: Ready     (not used)
//      2  RO: Idle      (in use)
//      1  RC: Done      (not used)
//      0  RW: Start     (in use)
/***********************************************************************
*                       reading registers                              *
***********************************************************************/

//---- read registers ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     s_axi_rdata <= 32'd0;
   else if(s_axi_arvalid & s_axi_arready)
     case(s_axi_araddr)
       ADDR_SNAP_CONTROL        : s_axi_rdata <= REG_snap_control_rd;
       ADDR_SNAP_INT_ENABLE     : s_axi_rdata <= REG_snap_int_enable[31 : 0];
       ADDR_SNAP_ACTION_TYPE    : s_axi_rdata <= i_action_type;
       ADDR_SNAP_ACTION_VERSION : s_axi_rdata <= i_action_version;
       ADDR_SNAP_CONTEXT        : s_axi_rdata <= REG_snap_context[31 : 0];

       ADDR_USER_STATUS         : s_axi_rdata <= REG_user_status;
       ADDR_USER_CONTROL        : s_axi_rdata <= REG_user_control;
       ADDR_SOURCE_ADDRESS_L    : s_axi_rdata <= REG_source_address[31  :  0];
       ADDR_SOURCE_ADDRESS_H    : s_axi_rdata <= REG_source_address[63  : 32];
       ADDR_TARGET_ADDRESS_L    : s_axi_rdata <= REG_target_address[31  :  0];
       ADDR_TARGET_ADDRESS_H    : s_axi_rdata <= REG_target_address[63  : 32];
       ADDR_DQM_ADDRESS_L       : s_axi_rdata <= REG_dqm_address[31  :  0];
       ADDR_DQM_ADDRESS_H       : s_axi_rdata <= REG_dqm_address[63  : 32];
       ADDR_MB_W                : s_axi_rdata <= REG_mb_w;
       ADDR_MB_H                : s_axi_rdata <= REG_mb_h;
       ADDR_SOFT_RESET          : s_axi_rdata <= REG_soft_reset;
       default                  : s_axi_rdata <= 32'h5a5aa5a5;
     endcase

//---- address ready: deasserts once arvalid is seen; reasserts when current read is done ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     s_axi_arready <= 1'b1;
   else if(s_axi_arvalid)
     s_axi_arready <= 1'b0;
   else if(s_axi_rvalid & s_axi_rready)
     s_axi_arready <= 1'b1;

//---- data ready: deasserts once rvalid is seen; reasserts when new address has come ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     s_axi_rvalid <= 1'b0;
   else if (s_axi_arvalid & s_axi_arready)
     s_axi_rvalid <= 1'b1;
   else if (s_axi_rready)
     s_axi_rvalid <= 1'b0;

/***********************************************************************
*                        status reporting                              *
***********************************************************************/

//---- axi write response ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n) 
     s_axi_bvalid <= 1'b0;
   else if(s_axi_wvalid & s_axi_wready)
     s_axi_bvalid <= 1'b1;
   else if(s_axi_bready)
     s_axi_bvalid <= 1'b0;

 assign s_axi_bresp = 2'd0;

//---- axi read response ----
 assign s_axi_rresp = 2'd0;

endmodule

