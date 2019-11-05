`include "RegisterFile.v"

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