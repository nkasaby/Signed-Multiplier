`timescale 1ns / 1ps

module nbit_shifter #(parameter n=8)(input clk, load, shift, lr, input [n-1:0] a, output reg [n-1:0] b);

always @ (posedge clk) begin
  if(load) b = a;
  
   if (shift && ~load) begin
      if(lr == 1'b1) b = {b[n-2:0],1'b0};
         else b = {1'b0, b[n-1:1]};
  end
end

endmodule
//needs testing