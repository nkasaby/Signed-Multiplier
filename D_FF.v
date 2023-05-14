`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2023 04:48:52 PM
// Design Name: 
// Module Name: D_FF
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dff_15bit (
  input clk,       // clock signal
  input reset,     // asynchronous reset input
  input enable,    // enable signal
  input [14:0] d,  // data input
  output reg [14:0] q // output
);

always @(posedge clk) begin
  if (reset) begin
    q <= 0;
  end else if (enable) begin
    q <= d;
  end
end

endmodule

