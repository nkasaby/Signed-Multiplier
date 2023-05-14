`timescale 1ns / 1ps

module nbit_counter #(parameter n =3, x=3)(input clk, en, updown, load, output reg [n-1:0] count); 

always @(posedge clk) begin
 if (load == 1)
    count <= 0;
 else begin
    if (en == 1) begin
      if(updown == 1)
        count <= (count == x-1)? 0: count + 1;
      else
        count <= (count == 0) ? x-1: count - 1;
    end
  end
end
endmodule
//needs testing