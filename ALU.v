
module ALU(
	input 		[31:0] 	inputA, inputB,
	input 		[4:0] 	opCode,
	input				carryIn,
	input 				S,
	output 	reg	[31:0] 	out, 
	output 	reg			cFlag, zFlag, nFlag, vFlag,
	input				debug
	);
			
	task  print;
		input port;
		begin
			$display("--------------------------- ALU ---------------------------");
			$display("opCode \t\tinputA \t\tinputB \tcIn \t\tout \tcFlag \tzFlag \tnFlag \tvFlag");
			$display("%b \t%d \t%d \t%d \t%d \t%b \t%b \t%b \t%b ",
				opCode, inputA, inputB, carryIn, out, cFlag, zFlag, nFlag, vFlag);
			$display("--------------------------- ALU ---------------------------");
		end
	endtask 
	
	always @ (*) begin
		case(opCode) 
			// 0000 AND		
			5'b0000: 	begin
						out = (inputA & inputB);
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = 0;
						end
						end
			// 0001 EOR		
			5'b0001:	begin
						out = inputA ^ inputB;
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = 0;
						end
						end
			// 0010 SUB		
			5'b0010:	begin
						out = inputA - inputB;
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = (inputA[31] & !inputB[31] & !out[31]) | 
								(!inputA[31] & inputB[31] & out[31]);
						end
						end
			// 0011 RSB		
			5'b0011:	begin
						out = inputB - inputA;
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = (inputA[31] & !inputB[31] & !out[31]) | 
								(!inputA[31] & inputB[31] & out[31]);
						end
						end
			// 0100 ADD		
			5'b0100:	begin
						{cFlag,out} = inputA + inputB;
						if (S) begin
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = (!inputA[31] & !inputB[31] & out[31]) | 
								(inputA[31] & inputB[31] & !out[31]);
						end
						end
			// 0101 ADC		
			5'b0101:	begin
						{cFlag,out} = inputA + inputB + carryIn;
						if (S) begin
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = (!inputA[31] & !inputB[31] & out[31]) | 
								(inputA[31] & inputB[31] & !out[31]);
						end
						end
			// 0110 SBC		
			5'b0110:	begin
						out = inputA - inputB - !carryIn;
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = (!inputA[31] & !inputB[31] & out[31]) | 
								(inputA[31] & inputB[31] & !out[31]);
						end
						end
			// 0111 RSC		
			5'b0111:	begin
						out = inputB - inputA - !carryIn;
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = (!inputA[31] & !inputB[31] & out[31]) | 
								(inputA[31] & inputB[31] & !out[31]);
						end
						end
			// 1000 AND	S	
			5'b1000: 	begin
						out = inputA & inputB;
						cFlag = out[31];
						zFlag = out == 32'b0;
						nFlag = out[31];
						vFlag = 0;
						end
			// 1001 EOR		
			5'b1001:	begin
						out = inputA ^ inputB;
						cFlag = out[31];
						zFlag = out == 32'b0;
						nFlag = out[31];
						vFlag = 0;
						end
			// 1010 SUB S
			5'b1010:	begin
						out = inputA - inputB;
						cFlag = out[31];
						zFlag = out == 32'b0;
						nFlag = out[31];
						vFlag = (!inputA[31] & !inputB[31] & out[31]) | 
							(inputA[31] & inputB[31] & !out[31]);
						end
			// 1011 ADD	S
			5'b1011:	begin
						{cFlag,out} = inputA + inputB;
						zFlag = out == 32'b0;
						nFlag = out[31];
						vFlag = (!inputA[31] & !inputB[31] & out[31]) | 
							(inputA[31] & inputB[31] & !out[31]);
						end		
			// 1100 ORR	
			5'b1100:	begin
						out = (inputA | inputB);
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = 0;
						end
						end
			// 1101 MOV	B
			5'b1101:	begin
						out = inputB;
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = 0;
						end
						end
			// 1110 AND	!B	
			5'b1110: 	begin
						out = inputA & ~inputB;
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = 0;
						end
						end
			// 1111 MVN !B
			5'b1111:	begin
						out = ~inputB;
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = 0;
						end
						end
			// 10000 MVN A 
			5'b10000:	begin
						out = (inputA===32'bX ? 32'b0: inputA);
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = 0;
						end
						end
			// 10001 MVN A + 4
			5'b10001:	begin
						out = (inputA===32'bX ? 32'b0: inputA) + 32'd4;
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = 0;
						end
						end
			// 10010 MVN A + B + 4
			5'b10010:	begin
						out = (inputA===32'bX ? 32'b0: inputA) + inputB + 32'd4;
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = 0;
						end
						end	
			// 10011 MVN A - B + 4
			5'b10011:	begin
						out = (inputA===32'bX ? 32'b0: inputA) - inputB + 32'd4;
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = 0;
						end
						end	
			// 10100 MVN A + 1
			5'b10100:	begin
						out = (inputA===32'bX ? 32'b0: inputA) + 32'd1;
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = 0;
						end
						end
			// 10101 MVN A - 4
			5'b10101:	begin
						out = (inputA===32'bX ? 32'b0: inputA) + 32'd1;
						if (S) begin
							cFlag = out[31];
							zFlag = out == 32'b0;
							nFlag = out[31];
							vFlag = 0;
						end
						end
			default:	begin
						out = 0;
						cFlag = 0;
						zFlag = 0;
						nFlag = 0;
						vFlag = 0;
						end
		endcase
		if(debug) print(0);
    end
	
endmodule

	
