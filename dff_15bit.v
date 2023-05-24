// file: dff_15bit.v
// author: Nour Kasaby, Nadine Safwat, Mariam ElGhobary
// This module will store in the values of the partial products after the multiplication occurs

`timescale 1ns/1ns

module dff_15bit 
(
  input clk,       
  input rst,    
  input enable,    
  input [14:0] in,  
  output reg [14:0] out
);

wire const_0; 

assign const_0 = 1'b0;

always @(posedge clk or posedge rst) begin
  if (rst)
    out <= const_0;
  else if (enable)
    out <= in;
end

endmodule
