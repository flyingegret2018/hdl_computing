//-------------------------------------------------------------------
// CopyRight(c) 2019 zhaoxingchang All Rights Reserved
//-------------------------------------------------------------------
// ProjectName    : 
// Author         : zhaoxingchang
// E-mail         : zxctja@163.com
// FileName       :	DC4.v
// ModelName      : 
// Description    : 
//-------------------------------------------------------------------
// Create         : 2019-11-15 11:29
// LastModified   :	2019-11-17 14:23
// Version        : 1.0
//-------------------------------------------------------------------

`timescale 1ns/100ps

module DC4#(
 parameter BIT_WIDTH    = 8
,parameter BLOCK_SIZE   = 4
,parameter SHIFT        = 3
)(
 input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]                top
,input      [BIT_WIDTH * BLOCK_SIZE - 1 : 0]                left
,output     [BIT_WIDTH * BLOCK_SIZE * BLOCK_SIZE - 1 : 0]   dst
);

wire[BIT_WIDTH + SHIFT : 0] temp1;
wire[BIT_WIDTH - 1 : 0] temp2;

assign temp1 =  top[7  : 0 ] + left[7  : 0 ] +
                top[15 : 8 ] + left[15 : 8 ] +
                top[23 : 16] + left[23 : 16] +
                top[31 : 24] + left[31 : 24];

assign temp2 = (temp1 + BLOCK_SIZE) >> SHIFT;

Fill #(
 .BIT_WIDTH     (BIT_WIDTH  )
,.BLOCK_SIZE    (BLOCK_SIZE )
) U_Fill (
 .value         (temp2   )
,.dst           (dst     )
);

endmodule
