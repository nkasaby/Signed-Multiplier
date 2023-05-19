// file: bin_to_BCD.v
// author: Nour Kasaby, Nadine Safwat, Mariam ElGhobary
// This module will 

`timescale 1ns/1ns

module bin_to_BCD
  (
    input [14:0] bin, 
    output reg[19:0] bcd
  ); 
  
  integer i,j;
  
  wire const_0;
  assign const_0 = 1'b0;
  
  always @ (*) begin
    bcd = const_0;
    
    for (i = 14 ; i >= 0 ; i = i-1) begin	
      if (bcd[3:0] >= 5) 
        bcd[3:0] = bcd[3:0] + 3;
        
    	if (bcd[7:4] >= 5) 
    	  bcd[7:4] = bcd[7:4] + 3;
    	  
    	if (bcd[11:8] >= 5) 
    	  bcd[11:8] = bcd[11:8] + 3;
    	  
    	if (bcd[15:12] >= 5) 
    	  bcd[15:12] = bcd[15:12] + 3;
    	  
    	if (bcd[19:16] >= 5) 
    	  bcd[19:16] = bcd[19:16] + 3;
    	  
    	bcd = {bcd[18:0],bin[i]};			
    end
end

endmodule
