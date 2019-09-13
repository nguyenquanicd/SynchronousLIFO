//===================================================================================
// File name:	tb_slifo.v
// Project:	Flexible synchronous LIFO
// Function:	The basic testbench of SLIFO
// Author:	nguyenquan.icd@gmail.com
// Website: http://nguyenquanicd.blogspot.com
//===================================================================================
`include "slifo_define.h"
module tb_slifo_v2;
`include "slifo_parameter.h"

//inputs
reg clk;
`ifdef SET_LOW_EN
  reg [POINTER_WIDTH:0] low_th;
`endif
`ifdef SET_HIGH_EN
  reg [POINTER_WIDTH:0] high_th;
`endif
reg rst_n;
reg wr;
reg rd;
reg [DATA_WIDTH-1:0] data_in;
//outputs
wire [DATA_WIDTH-1:0] data_out;
`ifdef LOW_TH_SIGNAL
  wire lifo_low_th;
`endif
`ifdef HIGH_TH_SIGNAL
  wire lifo_high_th;
`endif
`ifdef OV_SIGNAL
  wire lifo_ov;
`endif
`ifdef UD_SIGNAL
  wire lifo_ud;
`endif

`ifdef EMPTY_SIGNAL
  wire  lifo_empty;
`endif

`ifdef FULL_SIGNAL
  wire  lifo_full;
`endif

`ifdef WR_SAME_TIME_EN
  wire lifo_valid;
`endif

slifo_v2 dut (clk, rst_n, wr, rd,
                  `ifdef EMPTY_SIGNAL
                    lifo_empty,
                  `endif
                  `ifdef FULL_SIGNAL
                    lifo_full,
                  `endif
                  `ifdef SET_LOW_EN
                    low_th,
                  `endif
                  `ifdef SET_HIGH_EN
                    high_th,
                  `endif
                  `ifdef LOW_TH_SIGNAL
                    lifo_low_th,
                  `endif
                  `ifdef HIGH_TH_SIGNAL
                    lifo_high_th,
                  `endif
                  `ifdef OV_SIGNAL
                    lifo_ov,
                  `endif
                  `ifdef UD_SIGNAL
                    lifo_ud,
                  `endif
                  `ifdef WR_SAME_TIME_EN
                    lifo_valid,
                  `endif
                    data_in, data_out);

initial begin
  clk = 0;
	forever #10 clk = !clk;
end

`ifdef SET_LOW_EN
  initial begin
    low_th[POINTER_WIDTH:0] = 2;
  end
`endif
`ifdef SET_HIGH_EN
  initial begin
    high_th[POINTER_WIDTH:0] = 5;
  end
`endif

initial begin
  rst_n = 0;
	#80
	rst_n = 1;
end

initial begin
  #80
  wr = 0;
  data_in[DATA_WIDTH-1:0] = 'd5;
  #91
  wr = 1;
  repeat (20)  wr = #80 ~wr;
  #200
  wr = 1;
end

always @ (posedge clk) data_in[DATA_WIDTH-1:0] <= data_in[DATA_WIDTH-1:0] + 1;

initial begin
  #80
  rd = 0;
  #11
  rd = 1;
  repeat (121)  rd = #20 ~rd;
end

endmodule
