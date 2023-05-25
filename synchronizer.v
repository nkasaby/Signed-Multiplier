// file: synchronizer.v
// author: Nour Kasaby, Nadine Safwat, Mariam ElGhobary
// This module will reduce the risk of metastability by filtering the mechanical input through an always block (D-flip flop)

`timescale 1ns/1ns

module synchronizer
  (
    input clk,
    input in,
    output reg out
  );
  
  reg meta;
  
  always @ (posedge clk) begin 
    meta <= in;
    out <= meta;
  end
   
endmodule
