// file: synchronizer.v
// author: Nour Kasaby, Nadine Safwat, Mariam ElGhobary
// This module will 

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
