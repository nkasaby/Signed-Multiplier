`timescale 1ns / 1ps

module binToBCD
  (input [14:0] bin,  // binary
    output reg[19:0] bcd); // bcd {...,thousands,hundreds,tens,ones}
  integer i,j;

  always @(bin) begin
    bcd=0;		 	
    for (i=14;i>=0;i=i-1) begin					//Iterate once for each bit in input number
        if (bcd[3:0] >= 5) bcd[3:0] = bcd[3:0] + 3;		//If any BCD digit is >= 5, add three
      	if (bcd[7:4] >= 5) bcd[7:4] = bcd[7:4] + 3;
      	if (bcd[11:8] >= 5) bcd[11:8] = bcd[11:8] + 3;
      	if (bcd[15:12] >= 5) bcd[15:12] = bcd[15:12] + 3;
      	if (bcd[19:16] >= 5) bcd[19:16] = bcd[19:16] + 3;
      	bcd = {bcd[18:0],bin[i]};				//Shift one bit, and shift in proper bit from input 
    end
end
endmodule

//needs test