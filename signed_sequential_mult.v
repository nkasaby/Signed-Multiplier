// file: signed_sequential_mult.v
// author: Nour Kasaby, Nadine Safwat, Mariam AlGhobary

`timescale 1ns/1ns

module signed_seq_mult
  (
    input clk, 
    input multiply_but,
    input [7:0] multiplier,
    input [7:0] multiplicand,
    output [14:0] product,
    output done,
    output reg sign
  );
  
  wire load;
  wire shift;
  wire const_0;
  wire const_1;

  wire [7:0] positive_mp;
  wire [7:0] positive_mc;
  wire [7:0] right_shift;
  wire [14:0] left_shift;
  wire [14:0] temp; 
  wire [14:0] add_in;
  wire [14:0] partial_product;

  assign const_0 = 1'b0;
  assign const_1 = 1'b1;
  assign positive_mp = (multiplier[7]) ? (~(multiplier) + 1 ) : multiplier;
  assign positive_mc = (multiplicand[7]) ? (~(multiplicand) + 1) : multiplicand;
  assign shift = (right_shift == 0) ? const_0 : const_1;
  assign partial_product = temp;
  assign add_in = right_shift[0] ? left_shift : 15'b0;
  
  always @ (posedge clk)  
  begin
    if(multiply_but == 1)
    sign <= ((multiplier[7])^(multiplicand[7]));
    else
    sign <= sign; 
  end
 
  
  
  n_bit_shifter rightShift(.clk(clk), .load(multiply_but), .shift(shift), .left_right(const_0), .in(positive_mp), .out(right_shift));
  n_bit_shifter #(.n(15)) leftShift (.clk(clk), .load(multiply_but), .shift(shift), .left_right(const_1), .in({7'b0,positive_mc}), .out(left_shift));
  dff_15bit dff(.clk(clk), .rst(multiply_but), .enable(const_1), .in(temp+add_in), .out(temp));
  
  assign product = (right_shift == 0) ? temp : 15'b0;
  
  assign done = ~shift;

endmodule
