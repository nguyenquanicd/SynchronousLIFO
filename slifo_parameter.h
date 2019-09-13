//===================================================================================
// File name:	slifo_define.h
// Project:	Flexible synchronous LIFO
// Function:	
// Author:	nguyenquan.icd@gmail.com
// Website: http://nguyenquanicd.blogspot.com
//===================================================================================

//Parameters are used to set the capacity of FIFO
parameter DATA_WIDTH    = 16;
parameter POINTER_WIDTH = 4;
//
`ifndef SET_HIGH_EN
  parameter TH_LEVEL  = (2**POINTER_WIDTH)/2;
`else
  `ifndef SET_LOW_EN
     parameter TH_LEVEL  = (2**POINTER_WIDTH)/2;
  `endif
`endif
parameter DATA_NUM      = 2**POINTER_WIDTH;