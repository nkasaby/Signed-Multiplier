// file: button_CU.v
// author: Nour Kasaby, Nadine Safwat, Mariam ElGhobary
/* This module will multiply two signed 8 bit numbers and display the signed product on a 7 segment display. 
 It also allows for the user to scroll and choose which 3 digits of the 5 digit number to display through the use of a left and right button.*/

`timescale 1ns/1ns

module main
    (
        input clk, 
        input multiply_but, 
        input right_but, 
        input left_but, 
        input[7:0] multiplier,
        input[7:0] multiplicand, 
        output endmult, 
        output [0:6] segments, 
        output [3:0] anode_active
    );
    
    wire clk_out;
    wire mult;
    wire [1:0] counter_out;
    wire [1:0] button_sel;
    wire [14:0] product;
    wire [19:0] BCD;
    wire segmnet_1;
    wire segment_2;
    wire segment_3;
    wire const_0;
    wire const_1;
    wire sign;
    
    reg [3:0] digit_1;
    reg [3:0] digit_2;
    reg [3:0] digit_3;
    reg [3:0] segment_display;
    
    assign const_0 = 1'b0;
    assign const_1 = 1'b1;
    
    button_detector detect_mult (.clk(clk), .in(multiply_but), .out(mult));
    clock_divider clk_div (.clk(clk) , .rst(const_0), .clk_out(clk_out));
    n_bit_counter #(.n(2), .modulo(4)) counter (.clk(clk_out) , .en(const_1), .up_down(const_1), .load(const_0), .count(counter_out));
    signed_seq_mult seq_multiplier (.clk(clk), .multiply_but(mult), .multiplier(multiplier), .multiplicand(multiplicand), .done(endmult), .sign(sign), .product(product));
    bin_to_BCD bbcd (.bin(product[14:0]), .bcd(BCD));
    button_CU bcu (.clk(clk) , .right_but(right_but), .left_but(left_but), .multiply(mult), .out(button_sel));
    
    
    always @ (*) begin 
        case(button_sel)
            2: begin
                digit_1 = BCD[3:0];
                digit_2 = BCD[7:4];
                digit_3 = BCD[11:8]; 
                
            end
            
            1: begin 
                digit_1 = BCD[7:4];
                digit_2 = BCD[11:8];
                digit_3 = BCD[15:12];
            end
            
            0: begin
                digit_1 = BCD[11:8];
                digit_2 = BCD[15:12];
                digit_3 = BCD[19:16]; 
            end
        endcase
        
        case(counter_out)
            0:  segment_display = digit_1; 
            1:  segment_display = digit_2; 
            2:  segment_display = digit_3;  
            3:  segment_display = (sign) ? 4'd10 : 4'd11;
        endcase 
    end
    
    seven_segment ss (.en(counter_out), .num(segment_display), .segments(segments), .anode_active(anode_active));
endmodule
