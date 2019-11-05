module test_regFile;
	wire [31:0] A, B;

	reg [31:0] C;

	reg [3:0] regA, regB, deC;

	reg Ld, Clk;

	regFile rFile(A, B, C, regA, regB, deC, Ld, Clk);

	initial #160 $finish;

	initial begin
		Ld  = 1'b0;
		Clk = 1'b0;
		regA = 4'b0000;
		regB = 4'b0000;
		deC = 4'b0000;
		C = 32'd100;
	
		forever #5 Clk = ~Clk;
	end
	
	initial begin
		#5 Ld = 1;
		repeat (15) begin
			#10 regA = regA + 4'b0001;
			regB = regB + 4'b0001;
			deC = deC + 4'b0001;
			C = C + 32'd4;
			
		if(deC == 4'b1010) 
	        begin
			C <= 32'd35;
            	end
		end
	end

	initial begin
		$display("Clk   Ld    deC      regA   regB       C          A          B                  Time");
		$monitor("%b     %b     %b      %d    %d %d %d %d %d",Clk, Ld, deC, regA, regB, C, A, B, $time);
	end

endmodule

module regFile(output [31:0]PA, PB, input [31:0]PC, input [3:0]A, B, C, input RF, Clk);
wire [31:0] Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15;
wire [15:0] E;

decoder dec(E, C, RF);

register R0(Q0, PC, E[0], Clk);
register R1(Q1, PC, E[1], Clk);
register R2(Q2, PC, E[2], Clk);
register R3(Q3, PC, E[3], Clk);
register R4(Q4, PC, E[4], Clk);
register R5(Q5, PC, E[5], Clk);
register R6(Q6, PC, E[6], Clk);
register R7(Q7, PC, E[7], Clk);
register R8(Q8, PC, E[8], Clk);
register R9(Q9, PC, E[9], Clk);
register R10(Q10, PC, E[10], Clk);
register R11(Q11, PC, E[11], Clk);
register R12(Q12, PC, E[12], Clk);
register R13(Q13, PC, E[13], Clk);
register R14(Q14, PC, E[14], Clk);
register R15(Q15, PC, E[15], Clk);

mux_16x1 mux_A(PA, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, A);
mux_16x1 mux_B(PB, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, B);

endmodule

module decoder(output reg [15:0]E, input [3:0]D, input Ld);

always @(D, Ld)
   begin

    if(Ld == 1'b0)
	E <= 16'b0000000000000000;
    else if(Ld == 1'b1)
	if(D == 4'b0000)
	    E <= 16'b0000000000000001;
	else if( D == 4'b0001)
	    E <= 16'b0000000000000010;
	else if(D == 4'b0010)
	    E <= 16'b0000000000000100;
	else if(D == 4'b0011)
	    E <= 16'b0000000000001000;
	else if(D == 4'b0100)
	    E <= 16'b0000000000010000;
	else if(D == 4'b0101)
	    E <= 16'b0000000000100000;
	else if(D == 4'b0110)
	    E <= 16'b0000000001000000;
	else if(D == 4'b0111)
	    E <= 16'b0000000010000000;
	else if(D == 4'b1000)
	    E <= 16'b0000000100000000;
	else if(D == 4'b1001)
	    E <= 16'b0000001000000000;
	else if(D == 4'b1010)
	    E <= 16'b0000010000000000;
	else if(D == 4'b1011)
	    E <= 16'b0000100000000000;
	else if(D == 4'b1100)
	    E <= 16'b0001000000000000;
	else if(D == 4'b1101)
	    E <= 16'b0010000000000000;
	else if(D == 4'b1110)
	    E <= 16'b0100000000000000;
	else if(D == 4'b1111)
	    E <= 16'b1000000000000000;
   end
endmodule


module register(output reg [31:0] Q, input [31:0] D, input Ld, Clk);

always @(posedge Clk)
   begin
   if(!Ld == 1'b1)
     Q <= D;
   end

endmodule

module mux_16x1(output reg [31:0] P,input [31:0]Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, input [3:0]S);

always @(Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, S)
case(S)
4'b0000 : P <= Q0;
4'b0001 : P <= Q1;
4'b0010 : P <= Q2;
4'b0011 : P <= Q3;
4'b0100 : P <= Q4;
4'b0101 : P <= Q5;
4'b0110 : P <= Q6;
4'b0111 : P <= Q7;
4'b1000 : P <= Q8;
4'b1001 : P <= Q9;
4'b1010 : P <= Q10;
4'b1011 : P <= Q11;
4'b1100 : P <= Q12;
4'b1101 : P <= Q13;
4'b1110 : P <= Q14;
4'b1111 : P <= Q15;
endcase

endmodule