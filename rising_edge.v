// file: rising_edge.v
// author: Nour Kasaby, Nadine Safwat, Mariam ElGhobary
/* This module will move through three states in order to return 1 for only one clock cycle, which will ensure that no further module is hindred 
    by the long mechanical press of the button */ 

`timescale 1ns/1ns

module rising_edge
  (
    input clk, 
    input rst, 
    input in, 
    output out
  );

  reg [1:0] state;
  reg [1:0] next_state;
  localparam [1:0] A = 2'b00;
  localparam [1:0] B = 2'b01;
  localparam [1:0] C = 2'b10;
  
  always @ (*) begin
    case (state)
      A: if (in==0) next_state = A;
        else next_state = B;
        
      B: if (in==0) next_state = A;
        else next_state = C;
        
      C: if (in==0) next_state = A;
        else next_state = C;
        
      default: next_state = A;
    endcase
  end
  
  always @ (posedge clk or posedge rst) begin
    if(rst) state <= A;
    else state <= next_state;
  end
  
  assign out = (state == B);
endmodule
