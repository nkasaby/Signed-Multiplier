// file: button_CU.v
// author: Nour Kasaby, Nadine Safwat, Mariam ElGhobary
/* This Module goes through 3 states based on which button (left or right) is pressed in order to produce a select flag that will allow the seven 
   segment module to 'scroll' through the 5 digits of the product*/

`timescale 1ns/1ns

module button_CU
  (
    input clk,
    input right_but,
    input left_but,
    input multiply, 
    output wire [1:0] out
  );
  
  wire [1:0] signal;
  wire [1:0] counter_out;
  wire clk_out;
  wire const_0;
  
  assign const_0 = 1'b0;
  
  button_detector right_button (.clk(clk), .in(right_but), .out(signal[0]));
  button_detector left_button (.clk(clk), .in(left_but), .out(signal[1]));
  clock_divider  #(.freq(30000)) clk_div1 (.clk(clk), .rst(const_0), .clk_out(clk_out));
  
  reg [1:0] state;
  reg [1:0] next_state;
  
  
  parameter s0 = 2'b00;
  parameter s1 = 2'b01;
  parameter s2 = 2'b10;
  
  always @ (*) begin
    case(state) 
        s0: begin
            if(signal == 2'b01) next_state = s1;
            else next_state = s0;
            end
        s1: begin 
            if(signal == 2'b01) next_state = s2;
            else if(signal == 2'b10) next_state = s0;
            else next_state = s1;
            end
        s2: begin 
            if(signal == 2'b10) next_state = s1;
            else next_state = s2;
            end
        default: next_state = s2;
    endcase
  end

  always @ (posedge clk_out) begin
    if(multiply) state <= s0; 
    else state <= next_state;
  end
  
  assign out = state;
endmodule 
