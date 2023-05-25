// file: seven_segment.v
// author: Nour Kasaby, Nadine Safwat, Mariam ElGhobary
/* This Module will recieve a 4 bit number from the binary to bcd module and, using the created binary codes, will display the given number on the seven segment. If the number is
    10 a minus sign is shown, if its anything more nothing will show. The input en will decide whoch if the 4 will be turned on. */

`timescale 1ns/1ns

module seven_segment
  (
    input [1:0] en, 
    input [3:0] num, 
    output reg [0:6] segments,
    output reg [3:0] anode_active
  );

  always @ (*) begin
    case(en)
      0: anode_active = 4'b1110;
      1: anode_active = 4'b1101;
      2: anode_active = 4'b1011;
      3: anode_active = 4'b0111;
    endcase
    
    case(num) 
      0: segments = 7'b0000001; 
      1: segments = 7'b1001111;
      2: segments = 7'b0010010;
      3: segments = 7'b0000110;
      4: segments = 7'b1001100;
      5: segments = 7'b0100100;
      6: segments = 7'b0100000;
      7: segments = 7'b0001111;
      8: segments = 7'b0000000;
      9: segments = 7'b0000100;
      10: segments = 7'b1111110;
      default : segments = 7'b1111111;
    endcase
  end                                                                                                                                                                                                                                                                                                                                                                                                                                                   
endmodule
