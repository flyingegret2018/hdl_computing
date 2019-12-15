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
                       parameter DATA_WIDTH    = 512,
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
                       output reg [ADDR_WIDTH - 1:0]   m_axi_araddr      ,  
                       output reg [0007:0]             m_axi_arlen       ,  
                       output wire[0002:0]             m_axi_arsize      ,  
                       output wire[0001:0]             m_axi_arburst     ,  
                       output wire[ARUSER_WIDTH - 1:0] m_axi_aruser      , 
                       output wire[0003:0]             m_axi_arcache     , 
                       output wire[0001:0]             m_axi_arlock      ,  
                       output wire[0002:0]             m_axi_arprot      , 
                       output wire[0003:0]             m_axi_arqos       , 
                       output wire[0003:0]             m_axi_arregion    , 
                       output reg                      m_axi_arvalid     , 
                       input                           m_axi_arready     ,
                         // AXI read data channel          
                       output reg                      m_axi_rready      , 
                       input      [ID_WIDTH - 1:0]     m_axi_rid         ,
                       input      [DATA_WIDTH - 1:0]   m_axi_rdata       ,
                       input      [0001:0]             m_axi_rresp       ,
                       input                           m_axi_rlast       ,
                       input                           m_axi_rvalid      ,

                       //---- local control ----
                       input                           start_pulse       ,
                       input      [0063:0]             source_address    ,
                       input      [0063:0]             dqm_address       ,
                       input      [0031:0]             mb_w              ,
                       input      [0031:0]             mb_h              ,

                       //---- local status report ----          
                       output reg                      done_pulse        ,
                       output reg                      rd_error          ,

                       //---- WebPEncode ----
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
                       input                           Y0_fifo_full      ,
                       input                           Y1_fifo_full      ,
                       input                           UV_fifo_full      ,
                       output reg [1023:0]             Y0_fifo_din       ,
                       output reg [1023:0]             Y1_fifo_din       ,
                       output     [1023:0]             UV_fifo_din       ,
                       output                          Y0_fifo_wr        ,
                       output                          Y1_fifo_wr        ,
                       output                          UV_fifo_wr        
                       );

 wire     burst_sent;
 reg      fifo_wr;
 reg [9:0]x;
 reg [9:0]y;

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
 assign Y0_fifo_wr     = fifo_wr;
 assign Y1_fifo_wr     = fifo_wr;
 assign UV_fifo_wr     = fifo_wr;

 always@(posedge clk or negedge rst_n)
 begin
     if(~rst_n)
         m_axi_arid <= 0;
     else if(start_pulse)
         m_axi_arid <= 0;
     else if(burst_sent)
         m_axi_arid <= m_axi_arid + 1;
 end

parameter IDLE     = 6'h01;
parameter DQM_ADDR = 6'h02;
parameter DQM_READ = 6'h04; 
parameter LEFT    = 6'h08;
parameter NONE    = 6'h10;
parameter DONE    = 6'h20;

reg  [5:0] cstate;
reg  [5:0] nstate;

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
                nstate = DQM_ADDR;
            else
                nstate = IDLE;
        DQM_ADDR:
            nstate = DQM_WAIT;
        DQM_WAIT:
            if(m_axi_arready)
                nstate = YUV_ADDR;
            else
                nstate = DQM_WAIT;
        YUV_ADDR:
            nstate = YUV_WAIT;
        YUV_WAIT:
            if(m_axi_arready)
                nstate = YUV_ADDR;
            else
                nstate = YUV_WAIT;
        DONE:
            nstate = IDLE;
        default:
            nstate = IDLE;
    endcase
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        m_axi_araddr  <= 'b0;
        m_axi_arlen   <= 'b0;
        m_axi_arvalid <= 'b0;
        m_axi_rready  <= 'b0;
        done_pulse    <= 'b0;
        x             <= 'b0;
        y             <= 'b0;
    end
    else begin
        case(cstate)
            IDLE:begin
                m_axi_arvalid <= 'b0;
                m_axi_rready  <= 'b0;
                done_pulse    <= 'b0;
                x             <= 'b0;
                y             <= 'b0;
            end
            DQM_ADDR:begin
                m_axi_araddr  <= dqm_address;
                m_axi_arlen   <= 8'd5;
                m_axi_arvalid <= 1'b1;
            end
            DQM_WAIT:begin
                m_axi_arvalid <= ~m_axi_arready;
            end
            YUV_ADDR:begin
                m_axi_araddr  <= source_address;
                m_axi_arlen   <= 8'd2;
                m_axi_arvalid <= 1'b1;
                x             <= (x >= w);
                y             <= (x >= w);
            end
            YUV_WAIT:begin
                m_axi_arvalid <= ~m_axi_arready;
            end
            DONE:begin
            end
        endcase
    end
end

always @ (posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        m_axi_araddr  <= 'b0;
        m_axi_arlen   <= 'b0;
        m_axi_arvalid <= 'b0;
        m_axi_rready  <= 'b0;
        done_pulse    <= 'b0;
        rd_error      <= 'b0;
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
        case(cstate)
            IDLE:begin
                m_axi_arvalid <= 1'b0;
                m_axi_rready  <= 1'b0;
                done_pulse    <= 1'b0;
                reload        <= 1'b0;
                fifo_wr       <= 1'b0;
            end
            DQM_ADDR:begin
                m_axi_araddr  <= dqm_address;
                m_axi_arlen   <= 8'd5;
                m_axi_arvalid <= 1'b1;
            end
            WAIT:begin
            end
            DONE:begin
            end
        endcase
    end
end

endmodule
