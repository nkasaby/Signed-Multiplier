`timescale 1ns / 1ps

module rising_edge(input clk, rst, w, output z);
  reg [1:0] state, nextState;
  parameter [1:0] A= 2'b00, B=2'b01, C=2'b10;
  
  always @ (w or state)
  
  case (state)
    A: if (w==0) nextState = A;
      else nextState = B;
    B: if (w==0) nextState = A;
      else nextState = C;
    C: if (w==0) nextState = A;
      else nextState = C;
    default: nextState = A;
  endcase
  
  always @ (posedge clk or posedge rst) begin
    if(rst) state <= A;
    else state <= nextState;
  end
  
  assign z = (state == B);
endmodule
//works

module synchronizer(input sig,clk,output reg sig1);
  reg meta;
  always @ (posedge clk) begin 
    meta <= sig;
    sig1<= meta;
  end
endmodule
//works

module debouncer(input clk, rst, in, output out);
  reg q1,q2,q3;
  always@(posedge clk, posedge rst) begin
   if(rst == 1'b1) begin
     q1 <= 0;
     q2 <= 0;
     q3 <= 0;
   end
   else begin
     q1 <= in;
     q2 <= q1;
     q3 <= q2;
   end
  end
  assign out = (rst) ? 0 : q1&q2&q3;
endmodule
//works

module ButtonDetector(input A, clk, output z);
  wire clk_out ,deb,sync;
  clockDivider  #(30000) cd (clk, 1'b0, clk_out);
  debouncer d (clk_out, 1'b0, A,deb);
  synchronizer s (deb, clk_out,sync);
  rising_edge re (clk_out, 1'b0, sync, z);
endmodule
//works

module buttonControlUnit(input clk, r, l, mult, output [1:0] c);
wire a,b,m, en;
wire [1:0] cout;

ButtonDetector buttona (r,clk,a);
ButtonDetector buttonb (l,clk,b);
ButtonDetector multiply (mult, clk, m);

nbit_counter #(2,3) counter (clk,en,a,m,cout);

assign en = ((cout[1] || cout [0]) & b) || ((~(cout[1] & ~cout[0]) & a));

assign c = cout;

endmodule 
//Might not work
