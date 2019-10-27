module NextStateDecoder (
	output reg	[9:0] 	nextState, 
	input		[9:0] 	state,
	input		[31:0] 	IR, 
	input 				Cond, MOC);

	reg debug = 1;

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
/* 				if (IR[27:25]== 3'b001 || (IR[27:25] == 3'b000 && IR[4] == 1'b0) 
					if(IR[24:23] == 2'b10) nextState <= ;
					if (IR[20] == 1'b1) nextState <= ;
					else nextState <= ;
                // Load and Store Immediate / Register Offset
                else if(IR[27:26] == 2'b01)
                    // postindex
                    if(IR[24] == 1'b0) nextState <= ;
                    if(IR[23] == 1'b1) nextState <= ;
                    else nextState <= ;
                // Branch and Branch and Link
                else if (IR[27:25] == 3'b101)
                    if(IR[24] == 1'b0) nextState <= ;
                    else nextState <= ; */
					
				// Extra Load/Store Addressing Mode 3
				if (IR[27:25]==3'b000 & IR[7]==1'b1 & IR[4]==1'b1) begin
					if (IR[20] == 1) begin	// LDRSB LDRSH LDRH
						if (IR[6] == 1) begin
							if (IR[5] == 0) begin
								nextState <= 
								(!IR[22] ? 10'd4:0) + 			//Register
								( IR[24] &  IR[21] ? 10'd8:0) +  //PRE index
								(!IR[24] & !IR[21] ? 10'd16:0) +  //POS index
								(!IR[23] ? 10'd96:0) + 			//Subtract
								10'd226; // LDRSB
								if (debug) $display("LDRSB");
							end
							else begin 
								nextState <= 
								(!IR[22] ? 10'd4:0) + 				//Register
								( IR[24] &  IR[21] ? 10'd8:0) +  	//PRE index
								(!IR[24] & !IR[21] ? 10'd16:0) +  	//POS index
								(!IR[23] ? 10'd96:0) + 				//Subtract
								+ 10'd250;							// LDRSH
								if (debug) $display("LDRSH");
							end
						end
						else begin
							$display("Error: LDRH not implemented");
							nextState <= 10'd0;
						end
					end
					else begin	// STRH LDRD STRD
						if (IR[6] == 1) begin	// Double operation
							if (IR[5] == 0) begin 
								nextState <= 
								(!IR[22] ? 10'd4:0) + 				//Register
								( IR[24] &  IR[21] ? 10'd8:0) +  	//PRE index
								(!IR[24] & !IR[21] ? 10'd16:0) +  	//POS index
								(!IR[23] ? 10'd96:0) + 				//Subtract
								+ 10'd202;							// LDRD
								if (debug) $display("LDRD");
							end
							else begin 
								nextState <= 
								(!IR[22] ? 10'd4:0) + 				//Register
								( IR[24] &  IR[21] ? 10'd8:0) +  	//PRE index
								(!IR[24] & !IR[21] ? 10'd16:0) +  	//POS index
								(!IR[23] ? 10'd96:0) + 				//Subtract
								+ 10'd274;							// STRD
								if (debug) $display("STRD");
							end
						end
						else begin
							$display("Error: STRH, SWPB, LDREX,STREX not implemented");
							nextState <= 10'd1;
						end
					end
				end
				// Multiple Load/Store Addressing Mode 4
				else if (IR[27:25]==3'b100) begin
					if (IR[20] == 1) begin			// LDMDA LDMIA LDMDB LDMIB
						if (IR[23] == 1) begin		// Increment
							if (IR[24] == 0) begin	// After
								nextState <= 10'd394; 				// LDMIA
								if (debug) $display("LDMIA");
							end
							else begin				// Before
								nextState <= 10'd409; 				// LDMIB
								if (debug) $display("LDMIB");
							end
						end
						else begin					// Decrement
							if (IR[24] == 0) begin	// After
								nextState <= 10'd424; 				// LDMDA
								if (debug) $display("LDMDA");
							end
							else begin				// Before
								nextState <= 10'd439; 				// LDMDB
								if (debug) $display("LDMDB");
							end
						end
					end
					else begin						// STMIA STMIB STMDA STMDB
						if (IR[23] == 1) begin		// Increment
							if (IR[24] == 0) begin	// After
								nextState <= 10'd455; 				// STMIA
								if (debug) $display("STMIA");
							end
							else begin				// Before
								nextState <= 10'd471; 				// STMIB
								if (debug) $display("STMIB");
							end
						end
						else begin					// Decrement
							if (IR[24] == 0) begin	// After
								nextState <= 10'd487; 				// STMDA
								if (debug) $display("STMDA");
							end
							else begin				// Before
								nextState <= 10'd503; 				// STMDB
								if (debug) $display("STMDB");
							end
						end
					end
				end
				// Branch and Branch and Link
                else if (IR[27:25] == 3'b101) begin
					if (IR[24]) begin 
						nextState <= 10'd519; 				// BL
						if (debug) $display("BL");
					end
					else begin 
						nextState <= 10'd520; 				// B
						if (debug) $display("B");
					end
				end

			    // Unknown instruction
                else begin
                    $display("Error. Unknown instruction.");
                    nextState <= 10'd1; //Go back to initial state
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