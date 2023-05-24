// file: clock_divider.v
// author: Nour Kasaby, Nadine Safwat, Mariam ElGhobary
// This module will divide the clock frequency from 10MHz to about 100Hz according the the FPGA provided in the lab

`timescale 1ns/1ns

module clock_divider #(parameter freq = 250000)
  (
    input clk, 
    input rst, 
    output reg clk_out
  );
  
  wire [31:0] count;
  wire const_0;
  wire const_1;
  
  assign const_1 = 1'b1;
  assign const_0 = 1'b0;
  
  n_bit_counter #(.n(32),.modulo(freq)) counter1 (.clk(clk), .en(const_1), .up_down(const_1), .load(const_0), .count(count)); 
  
  always @ (posedge clk or posedge rst) begin
    if (rst) 
      clk_out <= const_0;
    else if (count == freq - 1)
      clk_out <= ~clk_out;
  end

endmodule 
