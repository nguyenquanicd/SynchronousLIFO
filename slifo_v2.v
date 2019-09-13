//===================================================================================
// File name:	slifo.v
// Project:	Flexible synchronous LIFO
// Function:	Synchronous LIFO with the configuration parameters
//        v2: Enable read and write at the same time
// Author:	nguyenquan.icd@gmail.com
// Website: http://nguyenquanicd.blogspot.com
//===================================================================================

//All defines are used to configured the synchronous LIFO before synthesizing
`include "slifo_define.h"
module slifo_v2 (clk, rst_n, wr, rd,
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
`include "slifo_parameter.h"
//inputs
input clk;
`ifdef SET_LOW_EN
  input [POINTER_WIDTH:0] low_th;
`endif
`ifdef SET_HIGH_EN
  input [POINTER_WIDTH:0] high_th;
`endif
input rst_n;
input wr;
input rd;
input [DATA_WIDTH-1:0] data_in;
//outputs
output  reg [DATA_WIDTH-1:0] data_out;
`ifdef LOW_TH_SIGNAL
  output wire lifo_low_th;
`endif
`ifdef HIGH_TH_SIGNAL
  output wire lifo_high_th;
`endif
`ifdef OV_SIGNAL
  output reg lifo_ov;
`endif
`ifdef UD_SIGNAL
  output reg lifo_ud;
`endif
`ifdef EMPTY_SIGNAL
  output  lifo_empty;
`else
  wire    lifo_empty;
`endif
`ifdef FULL_SIGNAL
  output  lifo_full;
`else
  wire    lifo_full;
`endif
`ifdef WR_SAME_TIME_EN
  output reg lifo_valid;
`endif
//Internal signals
reg [POINTER_WIDTH:0] pointer;
wire [POINTER_WIDTH:0] next_pointer, add_value;
reg [DATA_WIDTH-1:0] mem_array[DATA_NUM-1:0];
wire lifo_re, lifo_we, lifo_en;
//pointer
`ifdef WR_SAME_TIME_EN
  assign lifo_we = wr & ~lifo_full & ~rd;
`else
  assign lifo_we = wr & ~lifo_full;
`endif
//
`ifdef WR_SAME_TIME_EN
  assign lifo_re = rd & ~lifo_empty & ~wr;
`else
  assign lifo_re = rd & ~lifo_empty;
`endif
//
assign lifo_en = lifo_re ^ lifo_we;
//
assign add_value[POINTER_WIDTH:0] = lifo_re? {{POINTER_WIDTH{1'b1}}, 1'b0}: {POINTER_WIDTH{1'b0}};
//
assign next_pointer[POINTER_WIDTH:0] = 
        pointer[POINTER_WIDTH:0] +
        add_value[POINTER_WIDTH:0] + 1'b1;
//
always @ (posedge clk) begin
  if (~rst_n)
    pointer[POINTER_WIDTH:0] <= {(POINTER_WIDTH+1){1'b0}};
  else if (lifo_en)
    pointer[POINTER_WIDTH:0] <= next_pointer[POINTER_WIDTH:0];
end
//Status
//
assign lifo_full = pointer[POINTER_WIDTH];
//
assign lifo_empty= ~|pointer[POINTER_WIDTH:0];
//memory array
always @ (posedge clk) begin
  if (lifo_we)
    mem_array[pointer[POINTER_WIDTH-1:0]] <=
    data_in[DATA_WIDTH-1:0];
end
//DATA OUTPUT
//
`ifdef WR_SAME_TIME_EN
  wire forward_dt = wr & rd;
  wire [DATA_WIDTH-1:0] pre_data_out = forward_dt?
  data_in[DATA_WIDTH-1:0]: mem_array[next_pointer[POINTER_WIDTH-1:0]];
`else
  wire [DATA_WIDTH-1:0] pre_data_out = mem_array[next_pointer[POINTER_WIDTH-1:0]];
`endif
//
`ifdef OUTPUT_REG
  always @ (posedge clk) begin
    data_out[DATA_WIDTH-1:0] <= pre_data_out[DATA_WIDTH-1:0];
  end
`else
  always @ (*) begin
    data_out[DATA_WIDTH-1:0] = pre_data_out[DATA_WIDTH-1:0];
  end
`endif
//The low threshold signal
`ifdef LOW_TH_SIGNAL
  `ifdef SET_LOW_EN
    wire [POINTER_WIDTH:0] low_level = low_th[POINTER_WIDTH:0];
  `else
    wire [POINTER_WIDTH:0] low_level = TH_LEVEL;
  `endif
`endif

`ifdef LOW_TH_SIGNAL
  assign lifo_low_th = (pointer[POINTER_WIDTH:0] < low_level[POINTER_WIDTH:0]);
`endif
//The high threshold signal
`ifdef HIGH_TH_SIGNAL
  `ifdef SET_HIGH_EN
    wire [POINTER_WIDTH:0] high_level = high_th[POINTER_WIDTH:0];
  `else
    wire [POINTER_WIDTH:0] high_level = TH_LEVEL;
  `endif
`endif

`ifdef HIGH_TH_SIGNAL
  assign lifo_high_th = (pointer[POINTER_WIDTH:0] >= high_level[POINTER_WIDTH:0]);
`endif
//Overflow
`ifdef OV_SIGNAL
  //
  `ifdef WR_SAME_TIME_EN
    wire set_ov = wr & lifo_full & ~rd;
  `else
    wire set_ov = wr & lifo_full;
  `endif
  //
  always @ (posedge clk) begin
    if (~rst_n) lifo_ov <= 1'b0;
    else if (rd) lifo_ov <= 1'b0;
    else if (set_ov) lifo_ov <= 1'b1;
  end
`endif
//Underflow
`ifdef UD_SIGNAL
  //
  `ifdef WR_SAME_TIME_EN
    wire set_ud = rd & lifo_empty & ~wr;
  `else
    wire set_ud = rd & lifo_empty;
  `endif
  //
  always @ (posedge clk) begin
    if (~rst_n) lifo_ud <= 1'b0;
    else if (wr) lifo_ud <= 1'b0;
    else if (set_ud) lifo_ud <= 1'b1;
  end
`endif
//The valid signal of the output data
`ifdef WR_SAME_TIME_EN
  `ifdef OUTPUT_REG
    always @ (posedge clk) begin
      lifo_valid <= lifo_re | forward_dt;
    end
  `else
     always @ (*) begin
      lifo_valid = lifo_re| forward_dt;
    end 
  `endif
`endif
endmodule
