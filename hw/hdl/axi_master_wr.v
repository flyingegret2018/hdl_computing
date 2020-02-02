//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       : axi_master_wr.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-12-12 16:12
// LastModified   : 2019-12-12 16:12
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module axi_master_wr #(
                       parameter ID_WIDTH      = 2,
                       parameter ADDR_WIDTH    = 64,
                       parameter DATA_WIDTH    = 1024,
                       parameter AWUSER_WIDTH  = 8,
                       parameter ARUSER_WIDTH  = 8,
                       parameter WUSER_WIDTH   = 1,
                       parameter RUSER_WIDTH   = 1,
                       parameter BUSER_WIDTH   = 1
                       )
                      (
                       input                              clk               ,
                       input                              rst_n             , 
                       input       [0031:0]               i_snap_context    ,
                                                            
                       //---- AXI bus ----                   
                         // AXI write address channel           
                       output wire [ID_WIDTH - 1:0]       m_axi_awid        ,  
                       output wire [ADDR_WIDTH - 1:0]     m_axi_awaddr      ,  
                       output wire [0007:0]               m_axi_awlen       ,  
                       output wire [0002:0]               m_axi_awsize      ,  
                       output wire [0001:0]               m_axi_awburst     ,  
                       output wire [AWUSER_WIDTH - 1:0]   m_axi_awuser      , 
                       output wire [0003:0]               m_axi_awcache     , 
                       output wire [0001:0]               m_axi_awlock      ,  
                       output wire [0002:0]               m_axi_awprot      , 
                       output wire [0003:0]               m_axi_awqos       , 
                       output wire [0003:0]               m_axi_awregion    , 
                       output wire                        m_axi_awvalid     , 
                       input                              m_axi_awready     ,
                         // AXI write data channel
                       output wire [DATA_WIDTH - 1:0]     m_axi_wdata       ,  
                       output wire [(DATA_WIDTH/8) - 1:0] m_axi_wstrb       ,  
                       output wire                        m_axi_wlast       ,  
                       output wire                        m_axi_wvalid      ,  
                       input                              m_axi_wready      ,
                         // AXI write data channel            
                       output wire                        m_axi_bready      , 
                       input       [ID_WIDTH - 1:0]       m_axi_bid         ,
                       input       [0001:0]               m_axi_bresp       ,
                       input                              m_axi_bvalid      ,
                                 
                       //---- local control ----
                       input                              start_pulse       ,
                       input       [0063:0]               target_address    ,
                       input       [0031:0]               mb_w              ,
                       input       [0031:0]               mb_h              ,
                       input       [0009:0]               w1                ,
                       input       [0009:0]               h1                ,
                                 
                       //---- local status report ----            
                       output wire                        done_pulse        ,
                       output reg                         wr_error          ,

                       //---- WebPEncode ----
                       input                              fifo_empty        ,
                       input       [1023:0]               fifo_dout         ,
                       output                             fifo_rd      
                       );
                  

 wire      burst_sent;
 wire      resp_get;

//---- signals for AXI advanced features ----
 assign m_axi_awid     = 5'b0;
 assign m_axi_awsize   = 3'b111; // (2^7) * 8=1024
 assign m_axi_awburst  = 2'd1; // INCR mode for memory access
 assign m_axi_awcache  = 4'd3; // Normal Non-cacheable Bufferable
 assign m_axi_awuser   = i_snap_context[AWUSER_WIDTH - 1:0]; 
 assign m_axi_awprot   = 3'd0;
 assign m_axi_awqos    = 4'd0;
 assign m_axi_awregion = 4'd0; //?
 assign m_axi_awlock   = 2'b00; // normal access  
 assign m_axi_bready   = 1'b1;
 assign burst_sent     = m_axi_awvalid && m_axi_awready;
 assign resp_get       = m_axi_bvalid && m_axi_bready;

waddr_channel U_WADDR_CHANNEL(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .m_axi_awaddr                   ( m_axi_awaddr                  ),
    .m_axi_awlen                    ( m_axi_awlen                   ),
    .m_axi_awvalid                  ( m_axi_awvalid                 ),
    .m_axi_awready                  ( m_axi_awready                 ),
    .start_pulse                    ( start_pulse                   ),
    .target_address                 ( target_address                ),
    .w1                             ( w1                            ),
    .h1                             ( h1                            )
);

wdata_channel U_WDATA_CHANNEL(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .m_axi_wdata                    ( m_axi_wdata                   ),
    .m_axi_wstrb                    ( m_axi_wstrb                   ),
    .m_axi_wvalid                   ( m_axi_wvalid                  ),
    .m_axi_wlast                    ( m_axi_wlast                   ),
    .m_axi_wready                   ( m_axi_wready                  ),
    .start_pulse                    ( start_pulse                   ),
    .mb_w                           ( mb_w                          ),
    .mb_h                           ( mb_h                          ),
    .done_pulse                     ( done_pulse                    ),
    .fifo_empty                     ( fifo_empty                    ),
    .fifo_dout                      ( fifo_dout                     ),
    .fifo_rd                        ( fifo_rd                       )
);

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        wr_error <= 1'b0;
    else if(resp_get)
        wr_error <= (m_axi_bresp != 0);
    else if(wr_error)
        wr_error <= 1'b0;
end

endmodule
