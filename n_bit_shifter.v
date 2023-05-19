// file: n_bit_shifter.v
// author: Nour Kasaby, Nadine Safwat, Mariam ElGhobary
// This module will 

`timescale 1ns/1ns

module n_bit_shifter #(parameter n = 8)
  (
    input clk, 
    input load, 
    input shift, 
    input left_right, 
    input [n-1:0] in, 
    output reg [n-1:0] out
  );

wire const_0; 
wire const_1;

assign const_0 = 1'b0;
assign const_1 = 1'b1;

always @ (posedge clk) begin
  if(load) 
    out = in;
  else if (shift) begin
    if(left_right == const_1)
      out = {out[n-2:0] , const_0};
    else 
      out = {const_0, out[n-1:1]};
  end
end

endmodule
