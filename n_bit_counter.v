// file: n_bit_counter.v
// author: Nour Kasaby, Nadine Safwat, Mariam ElGhobary
// This module will increment or decrement depending on the value of up_down

`timescale 1ns/1ns

module n_bit_counter #(parameter n = 3, parameter modulo = 3)
  (
    input clk, 
    input en, 
    input up_down, 
    input load, 
    output reg [n-1:0] count
  ); 

  wire const_0;
  
  assign const_0 = 1'b0;
  
  always @ (posedge clk) begin
    if (load == 1)
      count <= const_0;
    else begin
      if (en == 1) begin
        if(up_down == 1)
          count <= (count == modulo - 1)? const_0: count + 1;
        else
          count <= (count == const_0) ? modulo - 1: count - 1;
      end
    end
  end
endmodule
