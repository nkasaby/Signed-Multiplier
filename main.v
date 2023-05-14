`timescale 1ns / 1ps

module main(input clk, multiply, rightb, leftb, input[7:0] mp,mc, output endmult, output [0:6] segments, output [3:0] anode_active);
wire clk_out;
reg [1:0] decoder;
wire [1:0] cout, sel;
wire [14:0] product;
wire [19:0] BCD;
wire seg1, seg2, seg3;
reg [3:0] d1,d2,d3, seg;
wire sign ,e;

clockDivider cd(clk,1'b0, clk_out);
nbit_counter #(2,4) c (clk_out,1'b1,1'b1,1'b0,cout);

//module signedSequentialMultiplier(input clk, mult, input [7:0] mp, mc, output sign, e, output [14:0] product );

signedSequentialMultiplier mult (.clk(clk), .mult(multiply), .mp(mp), .mc(mc), .e(e), .product (product) );

binToBCD bbcd (product[14:0], BCD);
buttonControlUnit bcu (clk, rightb, leftb, multiply, sel);
assign sign = ((mp[7])^(mc[7]));

always @ (*) begin 
  case(sel)
    0: begin
      d1 <= BCD[3:0];
      d2<= BCD[7:4];
      d3 <= BCD[11:8]; end
    1: begin 
      d1 <= BCD[7:4];
      d2<= BCD[11:8];
      d3 <= BCD[15:12]; end
    default: begin
      d1 <= BCD[11:8];
      d2<= BCD[15:12];
      d3 <= BCD[19:16]; end
    
  endcase
 /* 
  case(cout)
    0: begin seg = product[15] ? 4'd10 : 4'd11; decoder = 2'b0; end
    1: begin seg = d1; decoder = 2'b1; end
    2: begin seg = d2; decoder = 2'd2; end
    3: begin seg = d3; decoder = 2'd3; end
  endcase 
end

SevenSeg ss (decoder, seg, segments, anode_active);
*/
case(cout)
    0:  seg = d1; 
    1:  seg = d2; 
    2:  seg = d3;  
    3:  seg = sign ? 4'd10 : 4'd11; 
  endcase 
end

SevenSeg ss (cout, seg, segments, anode_active);
endmodule
