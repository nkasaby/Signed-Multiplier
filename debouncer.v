// file: debouncer.v
// author: Nour Kasaby, Nadine Safwat, Mariam ElGhobary
// This module will 

`timescale 1ns/1ns

module debouncer
  (
    input clk, 
    input rst, 
    input in, 
    output wire out
  );
  
  reg q1;
  reg q2;
  reg q3;
  
  always @ (posedge clk or posedge rst) begin
   if(rst) begin
     q1 <= 0;
     q2 <= 0;
     q3 <= 0;
   end
   
   else begin
     q1 <= in;
     q2 <= q1;
     q3 <= q2;
   end
  end
  
  wire const_0;
  wire and_expression;
  
  assign const_0 = 1'b0;
  assign and_expression = q1&q2&q3;
  
  assign out = (rst) ? const_0 : and_expression;
endmodule
