module NextStateDecoder (
	output reg	[9:0] 	nextState, 
	input		[9:0] 	state,
	input		[31:0] 	IR, 
	input 				Cond, MOC);

	reg tempState = 10'b0;

	always @ (state) begin
        case (state) 
            10'd0: nextState <= 10'd1;
			10'd1: nextState <= 10'd2;
			10'd2: nextState <= 10'd3;
			10'd3: if(MOC) nextState <= 10'd4;
				else nextState <= 10'd3;
			10'd4: begin
				//Following Instructions Format Table
				//Data Processing Register
				if(IR[27:25] == 3'b000 & IR[6:4] == 3'b000)
					nextState <= 10'd5;
				//Data Processing Immediate
				else if (IR[27:25] == 3'b001 & IR[20] == 1'b1) 
					nextState <= 10'd6;
				//Shift by register
				else if(IR[27:25] == 3'b000 & IR[4] == 1'b1) 
					nextState <= 10'd7;
				//Shift by immediate
				else if(IR[27:25] == 3'b000 & IR[4] == 1'b0) 
					nextState <= 10'd8;
				//TST
				//if (IR[27:25]== 3'b000 & IR[7] == 0 && IR[4] == 1) nextState <= 10'd9;
	
                        	//Load and Store
                        	else if(IR[27:25] == 3'b010) begin //Immediate
					$display("Correct");
					if(IR[20] == 1) begin //LDR
							nextState <=
							( IR[24] & !IR[21] ? 10'd4:0) +   //Register
							( IR[24] &  IR[21] ? 10'd8:0) +   //PRE-index
							(!IR[24] ? 10'd16:0) +    //POS-index
							(!IR[23] ? 10'd96:0) +    //Subtract
							+ 10'd35; //LDRB
					end
					else begin
					if(IR[20] == 0) begin //STR
							nextState <=
							( IR[24] & !IR[21] ? 10'd4:0) +   //Register
							( IR[24] &  IR[21] ? 10'd8:0) +   //PRE-index
							(!IR[24] ? 10'd16:0) +    //POS-index
							(!IR[23] ? 10'd96:0) +    //Subtract
							+ 10'd83; //STRB
						end
					end
					else begin
                                		$display("Error. No more Adressing Modes 2 instructions.");
                                		nextState <= 10'd0; //Go back to initial state
					end
				end
				else if(IR[27:25] == 3'b011 & IR[4] == 0) begin //Register
					$display("Correct");
					if(IR[20] == 1) begin //LDR
							nextState <=
							( IR[24] &  IR[21] ? 10'd8:0) +   //PRE-index
							(!IR[24] ? 10'd16:0) +    //POS-index
							(!IR[23] ? 10'd96:0) +    //Subtract
							+ 10'd39; //LDRB R
					end
					else begin
					if(IR[20] == 0) begin //STR
							nextState <=
							( IR[24] & !IR[21] ? 10'd4:0) +   //Register
							( IR[24] &  IR[21] ? 10'd8:0) +   //PRE-index
							(!IR[24] ? 10'd16:0) +    //POS-index
							(!IR[23] ? 10'd96:0) +    //Subtract
							+ 10'd87; //STRB R
						end
					end
					else begin
                                		$display("Error. No more Adressing Modes 2 instructions.");
                                		nextState <= 10'd0; //Go back to initial state
					end
				end
			    // Unknown instruction
                	else begin
                    		$display("Error. Unknown instruction.");
                    		nextState <= 9'd1; //Go back to initial state
			end
		end
			
			//ALU Instructions
			// 10'd5 : nextState <= ;
			// 10'd6 : nextState <= ;
			// 10'd7 : nextState <= ;
			// 10'd8 : nextState <= ;
			// 10'd9 : nextState <= ;
			// 10'd10 : nextState <= ;
			// 10'd11 : nextState <= ;
			
			//LOAD Adressing Mode 2
			// 10'd12 : //LDR Imm + OFF
				// if(IR[27:20] == 8'b01011001 ) nextState <= ;
				// else nextState <= ;
			// 10'd13 :
				// if(IR[27:20] == 8'b01011001 ) nextState <= ;
				// else nextState <= ;
			// 10'd14 :
				// if(IR[27:20] == 8'b01011001 ) nextState <= ;
				// else nextState <= ;
			// 10'd15 :
				// if(IR[27:20] == 8'b01011001 ) nextState <= ;
				// else nextState <= ;
			// 10'd16 : //LDR R + OFF
				// if(IR[27:20] == 8'b01111001 ) nextState <= ;
				// else nextState <= ;
			// 10'd17 :
				// if(IR[27:20] == 8'b01111001 ) nextState <= ;
				// else nextState <= ;
			// 10'd18 :
				// if(IR[27:20] == 8'b01111001 ) nextState <= ;
				// else nextState <= ;
			// 10'd19 :
				// if(IR[27:20] == 8'b01111001 ) nextState <= ;
				// else nextState <= ;
			// 10'd20 : //LDR Imm + PRE
				// if(IR[27:20] == 8'b01011011 ) nextState <= ;
				// else nextState <= ;
			// 10'd21 :
				// if(IR[27:20] == 8'b01011011 ) nextState <= ;
				// else nextState <= ;
			// 10'd22 :
				// if(IR[27:20] == 8'b01011011 ) nextState <= ;
				// else nextState <= ;
			// 10'd23 :
				// if(IR[27:20] == 8'b01011011 ) nextState <= ;
				// else nextState <= ;
			// 10'd24 : //LDR R + PRE
				// if(IR[27:20] == 8'b01111011 ) nextState <= ;
				// else nextState <= ;
			// 10'd25 :
				// if(IR[27:20] == 8'b01111011 ) nextState <= ;
				// else nextState <= ;
			// 10'd26 :
				// if(IR[27:20] == 8'b01111011 ) nextState <= ;
				// else nextState <= ;
			// 10'd27 :
				// if(IR[27:20] == 8'b01111011 ) nextState <= ;
				// else nextState <= ;
			// 10'd28 : //LDR Imm + POS
				// if(IR[27:20] == 8'b01001001 || IR[27:20] == 8'b01001011) nextState <= ;
				// else nextState <= ;
			// 10'd29 :
				// if(IR[27:20] == 8'b01001001 || IR[27:20] == 8'b01001011) nextState <= ;
				// else nextState <= ;
			// 10'd30 :
				// if(IR[27:20] == 8'b01001001 || IR[27:20] == 8'b01001011) nextState <= ;
				// else nextState <= ;
			// 10'd31 :
				// if(IR[27:20] == 8'b01001001 || IR[27:20] == 8'b01001011) nextState <= ;
				// else nextState <= ;
			// 10'd32 : //LDR R + POS
				// if(IR[27:20] == 8'b01101001 || IR[27:20] == 8'b01001011) nextState <= ;
				// else nextState <= ;
			// 10'd33 : 
				// if(IR[27:20] == 8'b01101001 || IR[27:20] == 8'b01001011) nextState <= ;
				// else nextState <= ;
			// 10'd34 : 
				// if(IR[27:20] == 8'b01101001 || IR[27:20] == 8'b01001011) nextState <= ;
				// else nextState <= ;
			// 10'd35 : 
				// if(IR[27:20] == 8'b01101001 || IR[27:20] == 8'b01001011) nextState <= ;
				// else nextState <= ;
			// 10'd36 :

			default:
				nextState <= 10'd1;
            
		endcase
	end
endmodule