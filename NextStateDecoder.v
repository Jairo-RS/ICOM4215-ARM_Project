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
				if (!Cond)	begin
					nextState <= 10'd1;
				end
				else begin
					//Following Instructions Format Table
					//Data Processing Register
					if(IR[27:25] == 3'b000 & IR[6:4] == 3'b000)
						//TST
						if (IR[24:21] == 4'b1000 | IR[24:21] == 4'b1001) 
							nextState <= 10'd9;
						else nextState <= 10'd5;
					
					//Data Processing Immediate
					else if (IR[27:25] == 3'b001 & IR[20] == 1'b1) 
						//TST
						if (IR[24:21] == 4'b1000 | IR[24:21] == 4'b1001) 
							nextState <= 10'd9;
						else nextState <= 10'd6;
					
					//Shift by register
					else if(IR[27:25] == 3'b000 & IR[7] == 1'b0 & IR[4] == 1'b1) begin
						//TST
						if (IR[24:21] == 4'b1000 | IR[24:21] == 4'b1001) 
							nextState <= 10'd9;
						else nextState <= 10'd7;
					end
					
					//Shift by immediate
					else if(IR[27:25] == 3'b000 & IR[4] == 1'b0) 
						//TST
						if (IR[24:21] == 4'b1000 | IR[24:21] == 4'b1001) 
							nextState <= 10'd9;
						else nextState <= 10'd8;
					

					//Load and Store
					else if(IR[27:25] == 3'b010) begin //Immediate
						if(IR[20] == 1) begin 	//LDR
								nextState <=
								( IR[24] &  IR[21] ? 10'd8:0) +   //PRE-index
								(!IR[24] ? 10'd16:0) +    //POS-index
								( IR[22] ? 10'd24:0) +    //Byte
								(!IR[23] ? 10'd96:0) +    //Subtract
								10'd11; //LDR / LDRB
						end
						else begin				//STR
							nextState <=
								( IR[24] &  IR[21] ? 10'd8:0) +   //PRE-index
								(!IR[24] ? 10'd16:0) +    //POS-index
								( IR[22] ? 10'd24:0) +    //Byte
								(!IR[23] ? 10'd96:0) +    //Subtract
								10'd59; //STR ? STRB
						end
					end
					else if(IR[27:25] == 3'b011 & IR[4] == 0) begin //Register
						if(IR[20] == 1) begin 	//LDR
								nextState <=
								( IR[24] &  IR[21] ? 10'd8:0) +   //PRE-index
								(!IR[24] ? 10'd16:0) +    //POS-index
								( IR[22] ? 10'd24:0) +    //Byte
								(!IR[23] ? 10'd96:0) +    //Subtract
								+ 10'd15; //LDR R / LDRB R
						end
						else begin				//STR
							nextState <=
								( IR[24] &  IR[21] ? 10'd8:0) +   //PRE-index
								(!IR[24] ? 10'd16:0) +    //POS-index
								( IR[22] ? 10'd24:0) +    //Byte
								(!IR[23] ? 10'd96:0) +    //Subtract
								+ 10'd63; //STR R / STRB R
						end
					end
					
					// Extra Load/Store Addressing Mode 3
					else if (IR[27:25]==3'b000 & IR[7]==1'b1 & IR[4]==1'b1) begin
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
									if (IR[21] == 0) begin
										nextState <= 10'd395; 				// LDMIA
										if (debug) $display("LDMIA");
									end
									else begin 
										nextState <= 10'd424; 				// LDMIA W
										if (debug) $display("LDMIA W");
									end
								end
								else begin				// Before
									if (IR[21] == 0) begin
										nextState <= 10'd398; 				// LDMIB
										if (debug) $display("LDMIB");
									end
									else begin 
										nextState <= 10'd427; 				// LDMIB W
										if (debug) $display("LDMIB W");
									end
								end
							end
							else begin					// Decrement
								if (IR[24] == 0) begin	// After
									if (IR[21] == 0) begin
										nextState <= 10'd401; 				// LDMDA
										if (debug) $display("LDMDA");
									end
									else begin 
										nextState <= 10'd430; 				// LDMDA W
										if (debug) $display("LDMDA W");
									end
								end
								else begin				// Before
									if (IR[21] == 0) begin
										nextState <= 10'd405; 				// LDMDB
										if (debug) $display("LDMDB");
									end
									else begin 
										nextState <= 10'd434; 				// LDMDB W
										if (debug) $display("LDMDB W");
									end
								end
							end
						end
						else begin						// STMIA STMIB STMDA STMDB
							if (IR[23] == 1) begin		// Increment
								if (IR[24] == 0) begin	// After
									if (IR[21] == 0) begin
										nextState <= 10'd409; 				// STMIA
										if (debug) $display("STMIA");
									end
									else begin 
										nextState <= 10'd438; 				// STMIA W
										if (debug) $display("STMIA W");
									end
								end
								else begin				// Before
									if (IR[21] == 0) begin
										nextState <= 10'd413; 				// STMIB
										if (debug) $display("STMIB");
									end
									else begin 
										nextState <= 10'd442; 				// STMIB W
										if (debug) $display("STMIB W");
									end
								end
							end
							else begin					// Decrement
								if (IR[24] == 0) begin	// After
									if (IR[21] == 0) begin
										nextState <= 10'd417; 				// STMDA
										if (debug) $display("STMDA");
									end
									else begin 
										nextState <= 10'd446; 				// STMDA W
										if (debug) $display("STMDA W");
									end
								end
								else begin				// Before
									if (IR[21] == 0) begin
										nextState <= 10'd421; 				// STMDB
										if (debug) $display("STMDB");
									end
									else begin 
										nextState <= 10'd450; 				// STMDB W
										if (debug) $display("STMDB W");
									end
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
			end
			
			//ALU Instructions are handled by default case
			
			//LOAD Adressing Mode 2
			10'd11,10'd12: //LDR Imm + OFF
				nextState <= state + 10'b1;
			10'd13: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd15,10'd16: //LDR R + OFF
				nextState <= state + 10'b1;
			10'd17: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd19,10'd20: //LDR Imm + PRE
				nextState <= state + 10'b1;
			10'd21: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd23,10'd24: //LDR R + PRE
				nextState <= state + 10'b1;
			10'd25: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd27,10'd28: //LDR Imm + POS
				nextState <= state + 10'b1;
			10'd29: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd31,10'd32: //LDR R + POS
				nextState <= state + 10'b1;
			10'd33: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd35,10'd36: //LDRB Imm + OFF
				nextState <= state + 10'b1;
			10'd37: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd39,10'd40: //LDRB R + OFF
				nextState <= state + 10'b1;
			10'd41: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd43,10'd44: //LDRB Imm + PRE
				nextState <= state + 10'b1;
			10'd45: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd47,10'd48: //LDRB R + PRE
				nextState <= state + 10'b1;
			10'd49: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd51,10'd52: //LDRB Imm + POS
				nextState <= state + 10'b1;
			10'd53: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd55,10'd56: //LDRB R + POS
				nextState <= state + 10'b1;
			10'd57: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd59,10'd60: //STR Imm + OFF
				nextState <= state + 10'b1;
			10'd61: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd63,10'd64: //STR R + OFF
				nextState <= state + 10'b1;
			10'd65: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd67,10'd68: //STR Imm + PRE
				nextState <= state + 10'b1;
			10'd69: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd71,10'd72: //STR R + PRE
				nextState <= state + 10'b1;
			10'd73: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd75,10'd76: //STR Imm + POS
				nextState <= state + 10'b1;
			10'd77: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd79,10'd80: //STR R + POS
				nextState <= state + 10'b1;
			10'd81: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd83,10'd84: //STRB Imm + OFF
				nextState <= state + 10'b1;
			10'd85: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd87,10'd88: //STRB R + OFF
				nextState <= state + 10'b1;
			10'd89: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd91,10'd92: //STRB Imm + PRE
				nextState <= state + 10'b1;
			10'd93: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd95,10'd96: //STRB R + PRE
				nextState <= state + 10'b1;
			10'd97: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd99,10'd100: //STRB Imm + POS
				nextState <= state + 10'b1;
			10'd101: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd103,10'd104: //STRB R + POS
				nextState <= state + 10'b1;
			10'd105: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd107,10'd108: //LDR Imm - OFF
				nextState <= state + 10'b1;
			10'd109: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd111,10'd112: //LDR R - OFF
				nextState <= state + 10'b1;
			10'd113: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd115,10'd116: //LDR Imm - PRE
				nextState <= state + 10'b1;
			10'd117: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd119,10'd120: //LDR R - PRE
				nextState <= state + 10'b1;
			10'd121: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd123,10'd124: //LDR Imm - POS
				nextState <= state + 10'b1;
			10'd125: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd127,10'd128: //LDR R - POS
				nextState <= state + 10'b1;
			10'd129: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd131,10'd132: //LDRB Imm - OFF
				nextState <= state + 10'b1;
			10'd133: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd135,10'd136: //LDRB R - OFF
				nextState <= state + 10'b1;
			10'd137: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd139,10'd140: //LDRB Imm - PRE
				nextState <= state + 10'b1;
			10'd141: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd143,10'd144: //LDRB R - PRE
				nextState <= state + 10'b1;
			10'd145: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd147,10'd148: //LDRB Imm - POS
				nextState <= state + 10'b1;
			10'd149: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd151,10'd152: //LDRB R - POS
				nextState <= state + 10'b1;
			10'd153: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd155,10'd156: //STR Imm - OFF
				nextState <= state + 10'b1;
			10'd157: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd159,10'd160: //STR R - OFF
				nextState <= state + 10'b1;
			10'd161: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd163,10'd164: //STR Imm - PRE
				nextState <= state + 10'b1;
			10'd165: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd167,10'd168: //STR R - PRE
				nextState <= state + 10'b1;
			10'd169: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd171,10'd172: //STR Imm - POS
				nextState <= state + 10'b1;
			10'd173: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd175,10'd176: //STR R - POS
				nextState <= state + 10'b1;
			10'd177: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd179,10'd180: //STRB Imm - OFF
				nextState <= state + 10'b1;
			10'd181: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd183,10'd184: //STRB R - OFF
				nextState <= state + 10'b1;
			10'd185: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd187,10'd188: //STRB Imm - PRE
				nextState <= state + 10'b1;
			10'd189: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd191,10'd192: //STRB R - PRE
				nextState <= state + 10'b1;
			10'd193: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd195,10'd196: //STRB Imm - POS
				nextState <= state + 10'b1;
			10'd197: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd199,10'd200: //STRB R - POS
				nextState <= state + 10'b1;
			10'd201: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd203,10'd204: //LDRD Imm + OFF
				nextState <= state + 10'b1;
			10'd205: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd207,10'd208: //LDRD R + OFF
				nextState <= state + 10'b1;
			10'd209: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd211,10'd212: //LDRD Imm + PRE
				nextState <= state + 10'b1;
			10'd213: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd215,10'd216: //LDRD R + PRE
				nextState <= state + 10'b1;
			10'd217: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd219,10'd220: //LDRD Imm + POS
				nextState <= state + 10'b1;
			10'd221: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd223,10'd224: //LDRD R + POS
				nextState <= state + 10'b1;
			10'd225: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd227,10'd228: //LDRSB Imm + OFF
				nextState <= state + 10'b1;
			10'd229: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd231,10'd232: //LDRSB R + OFF
				nextState <= state + 10'b1;
			10'd233: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd235,10'd236: //LDRSB Imm + PRE
				nextState <= state + 10'b1;
			10'd237: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd239,10'd240: //LDRSB R + PRE
				nextState <= state + 10'b1;
			10'd241: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd243,10'd244: //LDRSB Imm + POS
				nextState <= state + 10'b1;
			10'd245: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd247,10'd248: //LDRSB R + POS
				nextState <= state + 10'b1;
			10'd249: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd251,10'd252: //LDRSH Imm + OFF
				nextState <= state + 10'b1;
			10'd253: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd255,10'd256: //LDRSH R + OFF
				nextState <= state + 10'b1;
			10'd257: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd259,10'd260: //LDRSH Imm + PRE
				nextState <= state + 10'b1;
			10'd261: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd263,10'd264: //LDRSH R + PRE
				nextState <= state + 10'b1;
			10'd265: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd267,10'd268: //LDRSH Imm + POS
				nextState <= state + 10'b1;
			10'd269: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd271,10'd272: //LDRSH R + POS
				nextState <= state + 10'b1;
			10'd273: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd275,10'd276: //STRD Imm + OFF
				nextState <= state + 10'b1;
			10'd277: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd279,10'd280: //STRD R + OFF
				nextState <= state + 10'b1;
			10'd281: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd283,10'd284: //STRD Imm + PRE
				nextState <= state + 10'b1;
			10'd285: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd287,10'd288: //STRD R + PRE
				nextState <= state + 10'b1;
			10'd289: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd291,10'd292: //STRD Imm + POS
				nextState <= state + 10'b1;
			10'd293: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd295,10'd296: //STRD R + POS
				nextState <= state + 10'b1;
			10'd297: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd299,10'd300: //LDRD Imm - OFF
				nextState <= state + 10'b1;
			10'd301: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd303,10'd304: //LDRD R - OFF
				nextState <= state + 10'b1;
			10'd305: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd307,10'd308: //LDRD Imm - PRE
				nextState <= state + 10'b1;
			10'd309: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd311,10'd312: //LDRD R - PRE
				nextState <= state + 10'b1;
			10'd313: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd315,10'd316: //LDRD Imm - POS
				nextState <= state + 10'b1;
			10'd317: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd319,10'd320: //LDRD R - POS
				nextState <= state + 10'b1;
			10'd321: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd323,10'd324: //LDRSB Imm - OFF
				nextState <= state + 10'b1;
			10'd325: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd327,10'd328: //LDRSB R - OFF
				nextState <= state + 10'b1;
			10'd329: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd331,10'd332: //LDRSB Imm - PRE
				nextState <= state + 10'b1;
			10'd333: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd335,10'd336: //LDRSB R - PRE
				nextState <= state + 10'b1;
			10'd337: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd339,10'd340: //LDRSB Imm - POS
				nextState <= state + 10'b1;
			10'd341: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd343,10'd344: //LDRSB R - POS
				nextState <= state + 10'b1;
			10'd345: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd347,10'd348: //LDRSH Imm - OFF
				nextState <= state + 10'b1;
			10'd349: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd351,10'd352: //LDRSH R - OFF
				nextState <= state + 10'b1;
			10'd353: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd355,10'd356: //LDRSH Imm - PRE
				nextState <= state + 10'b1;
			10'd357: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd359,10'd360: //LDRSH R - PRE
				nextState <= state + 10'b1;
			10'd361: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd363,10'd364: //LDRSH Imm - POS
				nextState <= state + 10'b1;
			10'd365: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd367,10'd368: //LDRSH R - POS
				nextState <= state + 10'b1;
			10'd369: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd371,10'd372: //STRD Imm - OFF
				nextState <= state + 10'b1;
			10'd373: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd375,10'd376: //STRD R - OFF
				nextState <= state + 10'b1;
			10'd377: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd379,10'd380: //STRD Imm - PRE
				nextState <= state + 10'b1;
			10'd381: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd383,10'd384: //STRD R - PRE
				nextState <= state + 10'b1;
			10'd385: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd387,10'd388: //STRD Imm - POS
				nextState <= state + 10'b1;
			10'd389: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd391,10'd392: //STRD R - POS
				nextState <= state + 10'b1;
			10'd393: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd395,10'd396: //LDMIA / LDMFD
				nextState <= state + 10'b1;
			10'd397: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd398,10'd399: //LDMIB / LDMED
				nextState <= state + 10'b1;
			10'd400: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd401,10'd402: //LDMIDA / LDMFA
				nextState <= state + 10'b1;
			10'd403: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd405,10'd406: //LDMDB / LDMEA
				nextState <= state + 10'b1;
			10'd407: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd409,10'd410: //STMIA / STMEA
				nextState <= state + 10'b1;
			10'd411: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd413,10'd414: //STMIB / STMFA
				nextState <= state + 10'b1;
			10'd415: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd417,10'd418: //STMDA / STMED
				nextState <= state + 10'b1;
			10'd419: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd421,10'd422: //STMDB / STMFD
				nextState <= state + 10'b1;
			10'd423: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd424,10'd425: //LDMIA / LDMFD W
				nextState <= state + 10'b1;
			10'd426: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd427,10'd428: //LDMIB / LDMED W
				nextState <= state + 10'b1;
			10'd429: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd430,10'd431: //LDMIDA / LDMFA W
				nextState <= state + 10'b1;
			10'd432: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd434,10'd435: //LDMDB / LDMEA W
				nextState <= state + 10'b1;
			10'd436: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd438,10'd439: //STMIA / STMEA W
				nextState <= state + 10'b1;
			10'd440: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd442,10'd443: //STMIB / STMFA W
				nextState <= state + 10'b1;
			10'd444: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd446,10'd447: //STMDA / STMED W
				nextState <= state + 10'b1;
			10'd448: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;
			10'd450,10'd451: //STMDB / STMFD W
				nextState <= state + 10'b1;
			10'd452: //
				if (MOC) nextState <= state + 10'b1;
				else nextState <= state;

			default:
				nextState <= 10'd1;
            
		endcase
	end
endmodule