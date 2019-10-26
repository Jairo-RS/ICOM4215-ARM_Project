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
				//Data Processing Immediate / Register shift
				if (IR[27:25]== 3'b001 || (IR[27:25] == 3'b000 && IR[4] == 1'b0) 
					if(IR[24:23] == 2'b10) nextState <= ;
					if (IR[20] == 1'b1) nextState <= ;
					else nextState <= ;
                // Load and Store Immediate / Register Offset
                else if(IR[27:26] == 2'b01)
                    // postindex
                    if(IR[24] == 1'b0) nextState <= ;
                    if(IR[23] == 1'b1) nextState <= ;
                    else nextState <= ;
                // Load and Store Miscellaneous
                else if(IR[27:25] == 3'b000 && IR[4] == 1'b1)
                    // postindex
                    if(IR[24] == 1'b0) nextState <= ;
                    if(IR[23] == 1'b1)
					else nextState <= ;
                // Branch and Branch and Link
                else if (IR[27:25] == 3'b101)
                    if(IR[24] == 1'b0) nextState <= ;
                    else nextState <= ;
					
				// Extra Load/Stores
				if (IR[27:25]==3'b000 & IR[7]==1'b1 & IR[4]==1'b1) begin
					if (IR[22] == 0) tempState+=10'd4 // Uses Register
					if (IR[24]==1 && IR[21] == 1) tempState+=10'd4 // PRE index
					else if (IR[24]==0 && IR[21] == 0) tempState+=10'd4 // POS index
					if (IR[23] == 0) tempState+=10'd96 // Subtract
					
					if (IR[20] == 1) begin	// LDRSB LDRSH LDRH
						if (IR[6] == 1) begin
							if (IR[5] == 0) begin
								tempState+=10'd227 // LDRSB
							end
							else tempState+=10'd251;	// LDRSH
						end
						else begin
							$display("Error: LDRH not implemented");
							nextState <= 10'd1;
						end
					end
					else begin	// STRH LDRD STRD
						if (IR[6] == 1) begin	// Double operation
							if (IR[5] == 0) tempState+= 10'd203;	// LDRD
							else nextState <= 10'd275;	// STRD
						end
						else begin
							$display("Error: STRH, SWPB, LDREX,STREX not implemented");
							nextState <= 10'd1;
						end
					end
					nextState <= tempState;
				end				
			    // Unknown instruction
                else begin
                    $display("Error. Unknown instruction.");
                    nextState <= 9'd1; //Go back to initial state
				end
			end
			
			//ALU Instructions
			10'd5 : nextState <= ;
			10'd6 : nextState <= ;
			10'd7 : nextState <= ;
			10'd8 : nextState <= ;
			10'd9 : nextState <= ;
			10'd10 : nextState <= ;
			10'd11 : nextState <= ;
			
			//LOAD Adressing Mode 2
			10'd12 : //LDR Imm + OFF
				if(IR[27:20] == 8'b01011001 ) nextState <= ;
				else nextState <= ;
			10'd13 :
				if(IR[27:20] == 8'b01011001 ) nextState <= ;
				else nextState <= ;
			10'd14 :
				if(IR[27:20] == 8'b01011001 ) nextState <= ;
				else nextState <= ;
			10'd15 :
				if(IR[27:20] == 8'b01011001 ) nextState <= ;
				else nextState <= ;
			10'd16 : //LDR R + OFF
				if(IR[27:20] == 8'b01111001 ) nextState <= ;
				else nextState <= ;
			10'd17 :
				if(IR[27:20] == 8'b01111001 ) nextState <= ;
				else nextState <= ;
			10'd18 :
				if(IR[27:20] == 8'b01111001 ) nextState <= ;
				else nextState <= ;
			10'd19 :
				if(IR[27:20] == 8'b01111001 ) nextState <= ;
				else nextState <= ;
			10'd20 : //LDR Imm + PRE
				if(IR[27:20] == 8'b01011011 ) nextState <= ;
				else nextState <= ;
			10'd21 :
				if(IR[27:20] == 8'b01011011 ) nextState <= ;
				else nextState <= ;
			10'd22 :
				if(IR[27:20] == 8'b01011011 ) nextState <= ;
				else nextState <= ;
			10'd23 :
				if(IR[27:20] == 8'b01011011 ) nextState <= ;
				else nextState <= ;
			10'd24 : //LDR R + PRE
				if(IR[27:20] == 8'b01111011 ) nextState <= ;
				else nextState <= ;
			10'd25 :
				if(IR[27:20] == 8'b01111011 ) nextState <= ;
				else nextState <= ;
			10'd26 :
				if(IR[27:20] == 8'b01111011 ) nextState <= ;
				else nextState <= ;
			10'd27 :
				if(IR[27:20] == 8'b01111011 ) nextState <= ;
				else nextState <= ;
			10'd28 : //LDR Imm + POS
				if(IR[27:20] == 8'b01001001 || IR[27:20] == 8'b01001011) nextState <= ;
				else nextState <= ;
			10'd29 :
				if(IR[27:20] == 8'b01001001 || IR[27:20] == 8'b01001011) nextState <= ;
				else nextState <= ;
			10'd30 :
				if(IR[27:20] == 8'b01001001 || IR[27:20] == 8'b01001011) nextState <= ;
				else nextState <= ;
			10'd31 :
				if(IR[27:20] == 8'b01001001 || IR[27:20] == 8'b01001011) nextState <= ;
				else nextState <= ;
			10'd32 : //LDR R + POS
				if(IR[27:20] == 8'b01101001 || IR[27:20] == 8'b01001011) nextState <= ;
				else nextState <= ;
			10'd33 : 
				if(IR[27:20] == 8'b01101001 || IR[27:20] == 8'b01001011) nextState <= ;
				else nextState <= ;
			10'd34 : 
				if(IR[27:20] == 8'b01101001 || IR[27:20] == 8'b01001011) nextState <= ;
				else nextState <= ;
			10'd35 : 
				if(IR[27:20] == 8'b01101001 || IR[27:20] == 8'b01001011) nextState <= ;
				else nextState <= ;
			10'd36 : 

			default:
				nextState <= 10'd1;
            
		endcase
	end
endmodule