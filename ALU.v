
module ALU(input 		[31:0] 	inputA, inputB,
			input 		[4:0] 	opCode,
			input				carryIn,
			output 	reg	[31:0] 	out, 
			output 	reg			cFlag, zFlag, nFlag, vFlag
	 );
			
	always @ (*) begin
		case(opCode) 
			// 0000 AND		
			4'b0000: 	begin
						out = inputA & inputB;
						cFlag = out[31];
						zFlag = ~(|out);
						nFlag = out[31];
						vFlag = 0;
						end
			// 0001 BIC		
			4'b0001: 	begin
						out = inputA & !inputB;
						cFlag = out[31];
						zFlag = ~(|out);
						nFlag = out[31];
						vFlag = 0;
						end
			// 0010 ORR	
			4'b0010:	begin
						out = inputA | inputB;
						cFlag = out[31];
						zFlag = ~(|out);
						nFlag = out[31];
						vFlag = 0;
						end
			// 0011 EOR		
			4'b0011:	begin
						out = inputA ^ inputB;
						cFlag = out[31];
						zFlag = ~(|out);
						nFlag = out[31];
						vFlag = 0;
						end
			// 0100 ADD		
			4'b0100:	begin
						{cFlag,out} = inputA + inputB;
						zFlag = ~(|out);
						nFlag = out[31];
						vFlag = (!inputA[31] & !inputB[31] & out[31]) | 
							(inputA[31] & inputB[31] & !out[31]);
						end
			// 0101 ADC		
			4'b0101:	begin
						{cFlag,out} = inputA + inputB + carryIn;
						zFlag = ~(|out);
						nFlag = out[31];
						vFlag = (!inputA[31] & !inputB[31] & out[31]) | 
							(inputA[31] & inputB[31] & !out[31]);
						end
			// 0110 SUB		
			4'b0110:	begin
						out = inputA - inputB;
						cFlag = out[31];
						zFlag = ~(|out);
						nFlag = out[31];
						vFlag = (!inputA[31] & !inputB[31] & out[31]) | 
							(inputA[31] & inputB[31] & !out[31]);
						end
			// 0111 SBC		
			4'b0111:	begin
						out = inputA - inputB - carryIn;
						cFlag = out[31];
						zFlag = ~(|out);
						nFlag = out[31];
						vFlag = (!inputA[31] & !inputB[31] & out[31]) | 
							(inputA[31] & inputB[31] & !out[31]);
						end
			// 1000 RSB		
			4'b1000:	begin
						out = inputB - inputA;
						cFlag = out[31];
						zFlag = ~(|out);
						nFlag = out[31];
						vFlag = (!inputA[31] & !inputB[31] & out[31]) | 
							(inputA[31] & inputB[31] & !out[31]);
						end
			// 1001 RSC		
			4'b1001:	begin
						out = inputB - inputA - carryIn;
						cFlag = out[31];
						zFlag = ~(|out);
						nFlag = out[31];
						vFlag = (!inputA[31] & !inputB[31] & out[31]) | 
							(inputA[31] & inputB[31] & !out[31]);
						end
			// 1010 MOV		
			4'b1010:	begin
						out = inputB;
						cFlag = 0;
						zFlag = ~(|out);
						nFlag = out[31];
						vFlag = 0;
						end
			// 1011 MVN		
			4'b1011:	begin
						out = ~inputB;
						cFlag = 0;
						zFlag = ~(|out);
						nFlag = out[31];
						vFlag = 0;
						end
			// 1100 		
			//4'b1100:	
			// 1101 
			//4'b1101:	
			// 1110 
			//4'b1110:	
			// 1111 
			//4'b1111:	
			default:	begin
						out = 0;
						cFlag = 0;
						zFlag = 0;
						nFlag = 0;
						vFlag = 0;
						end
		endcase
    end
	
endmodule

	
