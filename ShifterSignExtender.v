module Shifter_SignExtender(
	output reg [31:0] out, 
	input [31:0] IR, Rm);
	
	reg [31:0] temp; //temporary register
	reg leastBit; //least significant bit
	integer i;

	always @(*) begin
		case(IR[27:25])
			3'b000: begin
				if(IR[4] == 1'b0) begin //Data processing imm shift
					temp = IR[7:0];
					for(i=0; i<(IR[11:8])*2; i=i+1) begin
						leastBit = temp[0];
						temp = temp >> 1;  
						temp[31] = leastBit;
					end
					assign out = temp;
				end
				else begin//Data processing register shift
					case(IR[6:5])
						2'b00: begin //LSL
							assign out = Rm;
						end
						2'b01: begin //LSR
							assign out = 0;
						end
						2'b10: begin //ASR
							if (Rm[31] == 1'b0) begin
								assign out = 32'b0;
							end
							else begin
								assign out = 32'hFFFFFFFF;
							end
						end
						2'b11: begin //ROR
							assign out = Rm >>> 1; //>>> (ASR (keep sign))
						end
					endcase
				end
		    end

			3'b001: begin //Data processing immediate
				case(IR[6:5])
					2'b00: begin //LSL
						assign out = Rm << IR[11:7];
					end
					2'b01: begin //LSR
						assign out = Rm >> IR[11:7];
					end
					2'b10: begin //ASR
						assign out = $signed(Rm) >>> IR[11:7];
					end
					2'b11: begin //ROR
						temp = Rm;
						for(i=0; i<IR[11:7]; i=i+1) begin
							leastBit = temp[0];
							temp = temp >> 1;
							temp[31] = leastBit;
						end
						assign out = temp;
					end
				endcase
			end

			3'b010: begin //Load/Store immediate
				assign out = IR[11:0];
			end

			3'b011: begin //Load/Store register
				temp = IR[7:0];
				for(i=0; i<(IR[11:8])*2; i=i+1)
					begin
						leastBit = temp[0];
						temp = temp >> 1;
						temp[31] = leastBit;
					end
				assign out = temp;
			end

			3'b101: begin //Branch and Branch & Link
				//IR[23:0]*4 -> offset x 4
				//{8{IR[23]}} -> concatenating 8 copies
				//assign out = { {8{IR[23]}}, IR[23:0]} << 2;
				assign out = { {8{IR[23]}}, IR[23:0]*4 };
			end

			default: assign out = Rm;
		endcase
	end
endmodule