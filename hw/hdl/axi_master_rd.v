//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       : axi_master_rd.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-12-12 16:12
// LastModified   : 2019-12-12 16:12
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module axi_master_rd #(
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
                       input                           clk               ,
                       input                           rst_n             , 
                       input      [0031:0]             i_snap_context    ,
                                                        
                       //---- AXI bus ----               
                         // AXI read address channel       
                       output reg [ID_WIDTH - 1:0]     m_axi_arid        ,  
                       output wire[ADDR_WIDTH - 1:0]   m_axi_araddr      ,  
                       output wire[0007:0]             m_axi_arlen       ,  
                       output wire[0002:0]             m_axi_arsize      ,  
                       output wire[0001:0]             m_axi_arburst     ,  
                       output wire[ARUSER_WIDTH - 1:0] m_axi_aruser      , 
                       output wire[0003:0]             m_axi_arcache     , 
                       output wire[0001:0]             m_axi_arlock      ,  
                       output wire[0002:0]             m_axi_arprot      , 
                       output wire[0003:0]             m_axi_arqos       , 
                       output wire[0003:0]             m_axi_arregion    , 
                       output wire                     m_axi_arvalid     , 
                       input                           m_axi_arready     ,
                         // AXI read data channel          
                       output                          m_axi_rready      , 
                       input      [ID_WIDTH - 1:0]     m_axi_rid         ,
                       input      [DATA_WIDTH - 1:0]   m_axi_rdata       ,
                       input      [0001:0]             m_axi_rresp       ,
                       input                           m_axi_rlast       ,
                       input                           m_axi_rvalid      ,

                       //---- local control ----
                       input                           start_pulse       ,
                       input      [0063:0]             source_address    ,
                       input      [0009:0]             w1                ,
                       input      [0009:0]             h1                ,

                       //---- local status report ----          
                       output                          rd_error          ,

                       //---- WebPEncode ----
                       input                           Y0_fifo_full      ,
                       input                           Y1_fifo_full      ,
                       input                           UV_fifo_full      ,
                       output     [1023:0]             Y0_fifo_din       ,
                       output     [1023:0]             Y1_fifo_din       ,
                       output     [1023:0]             UV_fifo_din       ,
                       output                          Y0_fifo_wr        ,
                       output                          Y1_fifo_wr        ,
                       output                          UV_fifo_wr        
                       );

 wire      burst_sent;

//---- signals for AXI advanced features ----
 assign m_axi_arsize   = 3'b111; // (2^7) * 8=1024
 assign m_axi_arburst  = 2'd1; // INCR mode for memory access
 assign m_axi_arcache  = 4'd3; // Normal Non-cacheable Bufferable
 assign m_axi_aruser   = i_snap_context[ARUSER_WIDTH - 1:0]; 
 assign m_axi_arprot   = 3'd0;
 assign m_axi_arqos    = 4'd0;
 assign m_axi_arregion = 4'd0; //?
 assign m_axi_arlock   = 2'b00; // normal access  
 assign burst_sent     = m_axi_arvalid && m_axi_arready;

raddr_channel U_RADDR_CHANNEL(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .m_axi_araddr                   ( m_axi_araddr                  ),
    .m_axi_arlen                    ( m_axi_arlen                   ),
    .m_axi_arvalid                  ( m_axi_arvalid                 ),
    .m_axi_arready                  ( m_axi_arready                 ),
    .start_pulse                    ( start_pulse                   ),
    .source_address                 ( source_address                ),
    .w1                             ( w1                            ),
    .h1                             ( h1                            )
);

rdata_channel #(
    .ID_WIDTH                       ( ID_WIDTH                      ))
U_RDATA_CHANNEL(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .m_axi_rdata                    ( m_axi_rdata                   ),
    .m_axi_rid                      ( m_axi_rid                     ),
    .m_axi_rlast                    ( m_axi_rlast                   ),
    .m_axi_rvalid                   ( m_axi_rvalid                  ),
    .m_axi_rresp                    ( m_axi_rresp                   ),
    .m_axi_rready                   ( m_axi_rready                  ),
    .start_pulse                    ( start_pulse                   ),
    .rd_error                       ( rd_error                      ),
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

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        m_axi_arid <= 0;
    else if(start_pulse)
        m_axi_arid <= 0;
    else if(burst_sent)
        m_axi_arid <= m_axi_arid + 1;
end

endmodule
