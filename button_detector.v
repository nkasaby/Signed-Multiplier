// file: button_detector.v
// author: Nour Kasaby, Nadine Safwat, Mariam ElGhobary
// This module will 

`timescale 1ns/1ns

module button_detector 
  (
    input clk,
    input in, 
    output wire out
  );

  wire clk_out;
  wire debounce;
  wire syncronize;
  wire const_0;
  
  assign const_0 = 1'b0;
  
  clock_divider  #(.freq(30000)) clk_div (.clk(clk), .rst(const_0), .clk_out(clk_out));
  synchronizer synch (.clk(clk_out), .in(in), .out(syncronize));
  debouncer deb (.clk(clk_out), .rst(const_0), .in(in), .out(debounce));
  rising_edge rise_edge (.clk(clk_out), .rst(const_0), .in(debounce), .out(out));
  
endmodule
