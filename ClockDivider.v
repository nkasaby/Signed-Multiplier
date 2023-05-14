`timescale 1ns / 1ps

module clockDivider #(parameter n = 250000)
(input clk, rst, output reg clk_out);
  
wire [31:0] count;
nbit_counter#(.n(32),.x(n)) counter1 (clk, 1'b1, 1'b1, 1'b0, count); 


// Handle the output clock
always @ (posedge clk, posedge rst) begin
  if (rst) 
    clk_out <= 0;
  else if (count == n-1)
    clk_out <= ~ clk_out;
end

endmodule 
//works
