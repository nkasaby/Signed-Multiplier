// file: signed_seq_mult.v
// author: Nour Kasaby, Mariam ElGhobary, Nadine Hakam
// This module will take in two signed 8 bit numbers and return the sign of the final product and multilpy the two numbrs as unsigned numbers to obtain the magnitude of the product.

`timescale 1ns/1ns

module signed_seq_mult
  (
    input clk, 
    input multiply_but,
    input [7:0] multiplier,
    input [7:0] multiplicand,
    output [14:0] product,
    output wire done,
    output reg sign
  );
  
  wire load;
  wire shift;
  wire const_0;
  wire const_1;
  wire z_flag;
  wire [7:0] positive_mp;
  wire [7:0] positive_mc;
  wire [7:0] right_shift;
  wire [14:0] left_shift;
  wire [14:0] add_in;
  wire [14:0] partial_product;

  assign const_0 = 1'b0;
  assign const_1 = 1'b1;
  assign positive_mp = (multiplier[7]) ? (~(multiplier) + 1 ) : multiplier;
  assign positive_mc = (multiplicand[7]) ? (~(multiplicand) + 1) : multiplicand;
  assign shift = ~(right_shift == 0); 
  assign add_in = right_shift[0] ? left_shift : 15'b0;
  assign z_flag = (multiplicand == 8'b0 || multiplier == 8'b0);
  
  n_bit_shifter rightShift(.clk(clk), .load(multiply_but), .shift(shift), .left_right(const_0), .in(positive_mp), .out(right_shift));
  n_bit_shifter #(.n(15)) leftShift (.clk(clk), .load(multiply_but), .shift(shift), .left_right(const_1), .in({7'b0,positive_mc}), .out(left_shift));
  dff_15bit dff(.clk(clk), .rst(multiply_but), .enable(const_1), .in(partial_product+add_in), .out(partial_product));
  
  always @ (posedge clk) begin
    if(multiply_but)
        sign <= z_flag ? const_0 : ((multiplier[7])^(multiplicand[7]));
    else 
        sign <= sign; 
  end 

  assign product = (right_shift == 0) ? partial_product : 15'b0;
  assign done = (right_shift == 0);
  
endmodule
