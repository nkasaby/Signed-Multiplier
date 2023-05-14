`timescale 1ns / 1ps

module signedSequentialMultiplier(input clk, mult, input [7:0] mp, mc,e, output [14:0] product );
wire [7:0] Rshifted;
wire [14:0] Lshifted, temp, add_in;
wire load, shift;
wire [7:0] posmp,posmc;
wire [14:0] products;
//reg signed mp,mc;
//assign sign = ((mp<0)^(mc<0));
assign posmp = (mp<0)?(~mp+1):mp;
assign posmc = (mc<0)?(~mc+1):mc;
assign shift = (Rshifted==0)?1'b0:1'b1;
//assign test = {Rshifted[0],load,shift};
assign load = mult;
assign products = temp;
assign add_in = Rshifted[0]? Lshifted:16'b0000_0000_0000_0000;

//ButtonDetector detect (mult, clk, load);
nbit_shifter rightShift(clk, load, shift, 1'b0, posmp, Rshifted);
nbit_shifter #(15)leftShift (clk, load, shift, 1'b1, {7'b0,posmc}, Lshifted);

dff_15bit dffxx( .clk(clk), .reset(mult), .enable(1'b1), .d(temp+add_in), .q(temp));

assign product = (Rshifted==0) ? temp : 15'b0;

//always @ (posedge clk) begin

//if(~(mp == 0)) begin
//posmp = {mp[6:0],1'b0};
//posmc = {8'b0, mc[7:1]};

// case(mp[0])
//    0: product <= product + 0;
//    1: product <= product + Lshifted;
//endcase 
//end
//end

assign e = ~shift;

endmodule

//needs testing