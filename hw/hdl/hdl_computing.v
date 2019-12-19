//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	hdl_computing.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-12-12 16:04
// LastModified   :	2019-12-16 20:45
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module hdl_computing # (
           // Parameters of Axi Slave Bus Interface AXI_CTRL_REG
           parameter C_S_AXI_CTRL_REG_DATA_WIDTH    = 32,
           parameter C_S_AXI_CTRL_REG_ADDR_WIDTH    = 32,
       
           // Parameters of Axi Master Bus Interface AXI_HOST_MEM ; to Host memory
           parameter C_M_AXI_HOST_MEM_ID_WIDTH      = 2,
           parameter C_M_AXI_HOST_MEM_ADDR_WIDTH    = 64,
           parameter C_M_AXI_HOST_MEM_DATA_WIDTH    = 1024,
           parameter C_M_AXI_HOST_MEM_AWUSER_WIDTH  = 8,
           parameter C_M_AXI_HOST_MEM_ARUSER_WIDTH  = 8,
           parameter C_M_AXI_HOST_MEM_WUSER_WIDTH   = 1,
           parameter C_M_AXI_HOST_MEM_RUSER_WIDTH   = 1,
           parameter C_M_AXI_HOST_MEM_BUSER_WIDTH   = 1
)
(
input                                          clk                  ,
input                                          rst_n                ,


//---- AXI bus interfaced with SNAP core ----
  // AXI write address channel
output    [C_M_AXI_HOST_MEM_ID_WIDTH - 1:0]     m_axi_snap_awid     ,
output    [C_M_AXI_HOST_MEM_ADDR_WIDTH - 1:0]   m_axi_snap_awaddr   ,
output    [0007:0]                              m_axi_snap_awlen    ,
output    [0002:0]                              m_axi_snap_awsize   ,
output    [0001:0]                              m_axi_snap_awburst  ,
output    [0003:0]                              m_axi_snap_awcache  ,
output    [0001:0]                              m_axi_snap_awlock   ,
output    [0002:0]                              m_axi_snap_awprot   ,
output    [0003:0]                              m_axi_snap_awqos    ,
output    [0003:0]                              m_axi_snap_awregion ,
output    [C_M_AXI_HOST_MEM_AWUSER_WIDTH - 1:0] m_axi_snap_awuser   ,
output                                          m_axi_snap_awvalid  ,
input                                           m_axi_snap_awready  ,
  // AXI write data channel
output    [C_M_AXI_HOST_MEM_DATA_WIDTH - 1:0]   m_axi_snap_wdata    ,
output    [(C_M_AXI_HOST_MEM_DATA_WIDTH/8) -1:0]m_axi_snap_wstrb    ,
output                                          m_axi_snap_wlast    ,
output                                          m_axi_snap_wvalid   ,
input                                           m_axi_snap_wready   ,
  // AXI write response channel
output                                          m_axi_snap_bready   ,
input     [C_M_AXI_HOST_MEM_ID_WIDTH - 1:0]     m_axi_snap_bid      ,
input     [0001:0]                              m_axi_snap_bresp    ,
input                                           m_axi_snap_bvalid   ,
  // AXI read address channel
output    [C_M_AXI_HOST_MEM_ID_WIDTH - 1:0]     m_axi_snap_arid     ,
output    [C_M_AXI_HOST_MEM_ADDR_WIDTH - 1:0]   m_axi_snap_araddr   ,
output    [0007:0]                              m_axi_snap_arlen    ,
output    [0002:0]                              m_axi_snap_arsize   ,
output    [0001:0]                              m_axi_snap_arburst  ,
output    [C_M_AXI_HOST_MEM_ARUSER_WIDTH - 1:0] m_axi_snap_aruser   ,
output    [0003:0]                              m_axi_snap_arcache  ,
output    [0001:0]                              m_axi_snap_arlock   ,
output    [0002:0]                              m_axi_snap_arprot   ,
output    [0003:0]                              m_axi_snap_arqos    ,
output    [0003:0]                              m_axi_snap_arregion ,
output                                          m_axi_snap_arvalid  ,
input                                           m_axi_snap_arready  ,
  // AXI  ead data channel
output                                          m_axi_snap_rready   ,
input     [C_M_AXI_HOST_MEM_ID_WIDTH - 1:0]     m_axi_snap_rid      ,
input     [C_M_AXI_HOST_MEM_DATA_WIDTH - 1:0]   m_axi_snap_rdata    ,
input     [0001:0]                              m_axi_snap_rresp    ,
input                                           m_axi_snap_rlast    ,
input                                           m_axi_snap_rvalid   ,


//---- AXI Lite bus interfaced with SNAP core ----
  // AXI write address channel
output                                          s_axi_snap_awready  ,
input     [C_S_AXI_CTRL_REG_ADDR_WIDTH - 1:0]   s_axi_snap_awaddr   ,
input                                           s_axi_snap_awvalid  ,
  // axi write data channel
output                                          s_axi_snap_wready   ,
input     [C_S_AXI_CTRL_REG_DATA_WIDTH - 1:0]   s_axi_snap_wdata    ,
input     [(C_S_AXI_CTRL_REG_DATA_WIDTH/8) -1:0]s_axi_snap_wstrb    ,
input                                           s_axi_snap_wvalid   ,
  // AXI response channel
output    [0001:0]                              s_axi_snap_bresp    ,
output                                          s_axi_snap_bvalid   ,
input                                           s_axi_snap_bready   ,
  // AXI read address channel
output                                          s_axi_snap_arready  ,
input                                           s_axi_snap_arvalid  ,
input     [C_S_AXI_CTRL_REG_ADDR_WIDTH - 1:0]   s_axi_snap_araddr   ,
  // AXI read data channel
output    [C_S_AXI_CTRL_REG_DATA_WIDTH - 1:0]   s_axi_snap_rdata    ,
output    [0001:0]                              s_axi_snap_rresp    ,
input                                           s_axi_snap_rready   ,
output                                          s_axi_snap_rvalid   ,

// Other signals
input      [31:0]                               i_action_type       ,
input      [31:0]                               i_action_version
);

 

wire              start_pulse        ;
wire  [  63:0]    source_address     ;
wire  [  63:0]    target_address     ;
wire  [  63:0]    dqm_address        ;
wire              done_pulse         ;
wire              rd_error           ;
wire              wr_error           ;
wire  [  31:0]    snap_context       ;
wire  [  31:0]    mb_w               ;
wire  [  31:0]    mb_h               ;
wire  [   9:0]    w1                 ;
wire  [   9:0]    w2                 ;
wire  [   9:0]    h1                 ;
wire  [0031:0]    lambda_i16         ;
wire  [0031:0]    lambda_i4          ;
wire  [0031:0]    lambda_uv          ;
wire  [0031:0]    tlambda            ;
wire  [0031:0]    lambda_mode        ;
wire  [0031:0]    min_disto          ;
wire  [0031:0]    max_edge           ;
wire              reload             ;
wire  [0255:0]    y1_q               ;
wire  [0255:0]    y1_iq              ;
wire  [0511:0]    y1_bias            ;
wire  [0511:0]    y1_zthresh         ;
wire  [0255:0]    y1_sharpen         ;
wire  [0255:0]    y2_q               ;
wire  [0255:0]    y2_iq              ;
wire  [0511:0]    y2_bias            ;
wire  [0511:0]    y2_zthresh         ;
wire  [0255:0]    y2_sharpen         ;
wire  [0255:0]    uv_q               ;
wire  [0255:0]    uv_iq              ;
wire  [0511:0]    uv_bias            ;
wire  [0511:0]    uv_zthresh         ;
wire  [0255:0]    uv_sharpen         ;
wire              Y0_fifo_full       ;
wire              Y1_fifo_full       ;
wire              UV_fifo_full       ;
wire  [1023:0]    Y0_fifo_din        ;
wire  [1023:0]    Y1_fifo_din        ;
wire  [1023:0]    UV_fifo_din        ;
wire              Y0_fifo_wr         ;
wire              Y1_fifo_wr         ;
wire              UV_fifo_wr         ;
wire              Y0_fifo_empty      ;
wire              Y1_fifo_empty      ;
wire              UV_fifo_empty      ;
wire  [2047:0]    Yin                ;
wire  [1023:0]    UVin               ;
wire              Y0_fifo_rd         ;
wire              Y1_fifo_rd         ;
wire              UV_fifo_rd         ;
wire              fifo_full          ;
wire              fifo_wr            ;
wire  [1023:0]    data_out           ;
wire              fifo_empty         ;
wire  [1023:0]    fifo_dout          ;
wire              fifo_rd            ;







//---- registers hub for AXI Lite interface ----
axi_lite_slave #(
    .DATA_WIDTH                     ( C_S_AXI_CTRL_REG_DATA_WIDTH   ),
    .ADDR_WIDTH                     ( C_S_AXI_CTRL_REG_ADDR_WIDTH   ))
U_AXI_LITE_SLAVE(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .s_axi_awready                  ( s_axi_snap_awready            ),
    .s_axi_awaddr                   ( s_axi_snap_awaddr             ),
    .s_axi_awvalid                  ( s_axi_snap_awvalid            ),
    .s_axi_wready                   ( s_axi_snap_wready             ),
    .s_axi_wdata                    ( s_axi_snap_wdata              ),
    .s_axi_wstrb                    ( s_axi_snap_wstrb              ),
    .s_axi_wvalid                   ( s_axi_snap_wvalid             ),
    .s_axi_bresp                    ( s_axi_snap_bresp              ),
    .s_axi_bvalid                   ( s_axi_snap_bvalid             ),
    .s_axi_bready                   ( s_axi_snap_bready             ),
    .s_axi_arready                  ( s_axi_snap_arready            ),
    .s_axi_arvalid                  ( s_axi_snap_arvalid            ),
    .s_axi_araddr                   ( s_axi_snap_araddr             ),
    .s_axi_rdata                    ( s_axi_snap_rdata              ),
    .s_axi_rresp                    ( s_axi_snap_rresp              ),
    .s_axi_rready                   ( s_axi_snap_rready             ),
    .s_axi_rvalid                   ( s_axi_snap_rvalid             ),
    .start_pulse                    ( start_pulse                   ),
    .source_address                 ( source_address                ),
    .target_address                 ( target_address                ),
    .dqm_address                    ( dqm_address                   ),
    .mb_w                           ( mb_w                          ),
    .mb_h                           ( mb_h                          ),
    .w1                             ( w1                            ),
    .w2                             ( w2                            ),
    .h1                             ( h1                            ),
    .done_pulse                     ( done_pulse                    ),
    .rd_error                       ( rd_error                      ),
    .wr_error                       ( wr_error                      ),
    .i_action_type                  ( i_action_type                 ),
    .i_action_version               ( i_action_version              ),
    .o_snap_context                 ( snap_context                  )
);

//---- writing channel of AXI master interface facing SNAP ----
axi_master_rd #(
    .ID_WIDTH                       ( C_M_AXI_HOST_MEM_ID_WIDTH     ),
    .ADDR_WIDTH                     ( C_M_AXI_HOST_MEM_ADDR_WIDTH   ),
    .DATA_WIDTH                     ( C_M_AXI_HOST_MEM_DATA_WIDTH   ),
    .AWUSER_WIDTH                   ( C_M_AXI_HOST_MEM_AWUSER_WIDTH ),
    .ARUSER_WIDTH                   ( C_M_AXI_HOST_MEM_ARUSER_WIDTH ),
    .WUSER_WIDTH                    ( C_M_AXI_HOST_MEM_WUSER_WIDTH  ),
    .RUSER_WIDTH                    ( C_M_AXI_HOST_MEM_RUSER_WIDTH  ),
    .BUSER_WIDTH                    ( C_M_AXI_HOST_MEM_BUSER_WIDTH  ))
U_AXI_MASTER_RD(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .i_snap_context                 ( snap_context                  ),
    .m_axi_arid                     ( m_axi_snap_arid               ),
    .m_axi_araddr                   ( m_axi_snap_araddr             ),
    .m_axi_arlen                    ( m_axi_snap_arlen              ),
    .m_axi_arsize                   ( m_axi_snap_arsize             ),
    .m_axi_arburst                  ( m_axi_snap_arburst            ),
    .m_axi_aruser                   ( m_axi_snap_aruser             ),
    .m_axi_arcache                  ( m_axi_snap_arcache            ),
    .m_axi_arlock                   ( m_axi_snap_arlock             ),
    .m_axi_arprot                   ( m_axi_snap_arprot             ),
    .m_axi_arqos                    ( m_axi_snap_arqos              ),
    .m_axi_arregion                 ( m_axi_snap_arregion           ),
    .m_axi_arvalid                  ( m_axi_snap_arvalid            ),
    .m_axi_arready                  ( m_axi_snap_arready            ),
    .m_axi_rready                   ( m_axi_snap_rready             ),
    .m_axi_rid                      ( m_axi_snap_rid                ),
    .m_axi_rdata                    ( m_axi_snap_rdata              ),
    .m_axi_rresp                    ( m_axi_snap_rresp              ),
    .m_axi_rlast                    ( m_axi_snap_rlast              ),
    .m_axi_rvalid                   ( m_axi_snap_rvalid             ),
    .start_pulse                    ( start_pulse                   ),
    .source_address                 ( source_address                ),
    .dqm_address                    ( dqm_address                   ),
    .w1                             ( w1                            ),
    .h1                             ( h1                            ),
    .rd_error                       ( rd_error                      ),
    .lambda_i16                     ( lambda_i16                    ),
    .lambda_i4                      ( lambda_i4                     ),
    .lambda_uv                      ( lambda_uv                     ),
    .tlambda                        ( tlambda                       ),
    .lambda_mode                    ( lambda_mode                   ),
    .min_disto                      ( min_disto                     ),
    .max_edge                       ( max_edge                      ),
    .reload                         ( reload                        ),
    .y1_q                           ( y1_q                          ),
    .y1_iq                          ( y1_iq                         ),
    .y1_bias                        ( y1_bias                       ),
    .y1_zthresh                     ( y1_zthresh                    ),
    .y1_sharpen                     ( y1_sharpen                    ),
    .y2_q                           ( y2_q                          ),
    .y2_iq                          ( y2_iq                         ),
    .y2_bias                        ( y2_bias                       ),
    .y2_zthresh                     ( y2_zthresh                    ),
    .y2_sharpen                     ( y2_sharpen                    ),
    .uv_q                           ( uv_q                          ),
    .uv_iq                          ( uv_iq                         ),
    .uv_bias                        ( uv_bias                       ),
    .uv_zthresh                     ( uv_zthresh                    ),
    .uv_sharpen                     ( uv_sharpen                    ),
    .Y0_fifo_full                   ( Y0_fifo_full                  ),
    .Y1_fifo_full                   ( Y1_fifo_full                  ),
    .UV_fifo_full                   ( UV_fifo_full                  ),
    .Y0_fifo_din                    ( Y0_fifo_din                   ),
    .Y1_fifo_din                    ( Y1_fifo_din                   ),
    .UV_fifo_din                    ( UV_fifo_din                   ),
    .Y0_fifo_wr                     ( Y0_fifo_wr                    ),
    .Y1_fifo_wr                     ( Y1_fifo_wr                    ),
    .UV_fifo_wr                     ( UV_fifo_wr                    )
);

fifo_1024_in fifo_y0_in (
    .clk                            ( clk                           ),
    .srst                           ( ~rst_n                        ),
    .din                            ( Y0_fifo_din                   ),
    .wr_en                          ( Y0_fifo_wr                    ),
    .rd_en                          ( Y0_fifo_rd                    ),
    .dout                           ( Yin[1023:0]                   ),
    .full                           (                               ),
    .empty                          ( Y0_fifo_empty                 ),
    .prog_full                      ( Y0_fifo_full                  ),
    .wr_rst_busy                    (                               ),
    .rd_rst_busy                    (                               )
);

fifo_1024_in fifo_y1_in (
    .clk                            ( clk                           ),
    .srst                           ( ~rst_n                        ),
    .din                            ( Y1_fifo_din                   ),
    .wr_en                          ( Y1_fifo_wr                    ),
    .rd_en                          ( Y1_fifo_rd                    ),
    .dout                           ( Yin[2047:1024]                ),
    .full                           (                               ),
    .empty                          ( Y1_fifo_empty                 ),
    .prog_full                      ( Y1_fifo_full                  ),
    .wr_rst_busy                    (                               ),
    .rd_rst_busy                    (                               )
);

fifo_1024_in fifo_uv_in (
    .clk                            ( clk                           ),
    .srst                           ( ~rst_n                        ),
    .din                            ( UV_fifo_din                   ),
    .wr_en                          ( UV_fifo_wr                    ),
    .rd_en                          ( UV_fifo_rd                    ),
    .dout                           ( UVin                          ),
    .full                           (                               ),
    .empty                          ( UV_fifo_empty                 ),
    .prog_full                      ( UV_fifo_full                  ),
    .wr_rst_busy                    (                               ),
    .rd_rst_busy                    (                               )
);

WebPEncode U_WEBPENCODE(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .start                          ( start_pulse                   ),
    .w1                             ( w1                            ),
    .w2                             ( w2                            ),
    .h1                             ( h1                            ),
    .lambda_i16                     ( lambda_i16                    ),
    .lambda_i4                      ( lambda_i4                     ),
    .lambda_uv                      ( lambda_uv                     ),
    .tlambda                        ( tlambda                       ),
    .lambda_mode                    ( lambda_mode                   ),
    .min_disto                      ( min_disto                     ),
    .max_edgei                      ( max_edge                      ),
    .reload                         ( reload                        ),
    .y1_q                           ( y1_q                          ),
    .y1_iq                          ( y1_iq                         ),
    .y1_bias                        ( y1_bias                       ),
    .y1_zthresh                     ( y1_zthresh                    ),
    .y1_sharpen                     ( y1_sharpen                    ),
    .y2_q                           ( y2_q                          ),
    .y2_iq                          ( y2_iq                         ),
    .y2_bias                        ( y2_bias                       ),
    .y2_zthresh                     ( y2_zthresh                    ),
    .y2_sharpen                     ( y2_sharpen                    ),
    .uv_q                           ( uv_q                          ),
    .uv_iq                          ( uv_iq                         ),
    .uv_bias                        ( uv_bias                       ),
    .uv_zthresh                     ( uv_zthresh                    ),
    .uv_sharpen                     ( uv_sharpen                    ),
    .Yin                            ( Yin                           ),
    .UVin                           ( UVin                          ),
    .Y0_fifo_empty                  ( Y0_fifo_empty                 ),
    .Y1_fifo_empty                  ( Y1_fifo_empty                 ),
    .UV_fifo_empty                  ( UV_fifo_empty                 ),
    .fifo_full                      ( fifo_full                     ),
    .fifo_rd_y0                     ( Y0_fifo_rd                    ),
    .fifo_rd_y1                     ( Y1_fifo_rd                    ),
    .fifo_rd_uv                     ( UV_fifo_rd                    ),
    .fifo_wr                        ( fifo_wr                       ),
    .data_out                       ( data_out                      ),
    .done                           (                               )
);

fifo_1024_out fifo_out (
    .clk                            ( clk                           ),
    .srst                           ( ~rst_n                        ),
    .din                            ( data_out                      ),
    .wr_en                          ( fifo_wr                       ),
    .rd_en                          ( fifo_rd                       ),
    .dout                           ( fifo_dout                     ),
    .full                           (                               ),
    .empty                          ( fifo_empty                    ),
    .prog_full                      ( fifo_full                     ),
    .wr_rst_busy                    (                               ),
    .rd_rst_busy                    (                               )
);

//---- writing channel of AXI master interface facing SNAP ----
axi_master_wr #(
    .ID_WIDTH                       ( C_M_AXI_HOST_MEM_ID_WIDTH     ),
    .ADDR_WIDTH                     ( C_M_AXI_HOST_MEM_ADDR_WIDTH   ),
    .DATA_WIDTH                     ( C_M_AXI_HOST_MEM_DATA_WIDTH   ),
    .AWUSER_WIDTH                   ( C_M_AXI_HOST_MEM_AWUSER_WIDTH ),
    .ARUSER_WIDTH                   ( C_M_AXI_HOST_MEM_ARUSER_WIDTH ),
    .WUSER_WIDTH                    ( C_M_AXI_HOST_MEM_WUSER_WIDTH  ),
    .RUSER_WIDTH                    ( C_M_AXI_HOST_MEM_RUSER_WIDTH  ),
    .BUSER_WIDTH                    ( C_M_AXI_HOST_MEM_BUSER_WIDTH  ))
U_AXI_MASTER_WR(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .i_snap_context                 ( snap_context                  ),
    .m_axi_awid                     ( m_axi_snap_awid               ),
    .m_axi_awaddr                   ( m_axi_snap_awaddr             ),
    .m_axi_awlen                    ( m_axi_snap_awlen              ),
    .m_axi_awsize                   ( m_axi_snap_awsize             ),
    .m_axi_awburst                  ( m_axi_snap_awburst            ),
    .m_axi_awuser                   ( m_axi_snap_awuser             ),
    .m_axi_awcache                  ( m_axi_snap_awcache            ),
    .m_axi_awlock                   ( m_axi_snap_awlock             ),
    .m_axi_awprot                   ( m_axi_snap_awprot             ),
    .m_axi_awqos                    ( m_axi_snap_awqos              ),
    .m_axi_awregion                 ( m_axi_snap_awregion           ),
    .m_axi_awvalid                  ( m_axi_snap_awvalid            ),
    .m_axi_awready                  ( m_axi_snap_awready            ),
    .m_axi_wdata                    ( m_axi_snap_wdata              ),
    .m_axi_wstrb                    ( m_axi_snap_wstrb              ),
    .m_axi_wlast                    ( m_axi_snap_wlast              ),
    .m_axi_wvalid                   ( m_axi_snap_wvalid             ),
    .m_axi_wready                   ( m_axi_snap_wready             ),
    .m_axi_bready                   ( m_axi_snap_bready             ),
    .m_axi_bid                      ( m_axi_snap_bid                ),
    .m_axi_bresp                    ( m_axi_snap_bresp              ),
    .m_axi_bvalid                   ( m_axi_snap_bvalid             ),
    .start_pulse                    ( start_pulse                   ),
    .target_address                 ( target_address                ),
    .mb_w                           ( mb_w                          ),
    .mb_h                           ( mb_h                          ),
    .w1                             ( w1                            ),
    .h1                             ( h1                            ),
    .done_pulse                     ( done_pulse                    ),
    .wr_error                       ( wr_error                      ),
    .fifo_empty                     ( fifo_empty                    ),
    .fifo_dout                      ( fifo_dout                     ),
    .fifo_rd                        ( fifo_rd                       )
);

endmodule
