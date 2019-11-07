module ram256x8(
	output reg 	[31:0] 	DataOut, 
	output reg 			MOC = 1,
	input 				ReadWrite, 
	input 		[7:0] 	Address,
	input 		[31:0] 	DataIn,
	input 				MOV,
	input  		[1:0]	DataType);

reg [7:0] Mem[0:255];
always @ (MOV, ReadWrite)
	if (MOV) begin
		if(ReadWrite) begin
			case (DataType)
				2'b00:begin	//Byte
					MOC= 0;
					DataOut	<=	{23'b0,Mem[Address]};
					MOC =1;
				end

				2'b01: begin	//half word
					MOC = 0;
					DataOut	<=	{16'b0, Mem[Address], Mem[Address+1]};
					MOC = 1;
				end

				2'b10:begin	// Word
					MOC = 0;
					DataOut	<=	{Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
					MOC = 1;
				end
					
				2'b11:begin	// Double Word
					MOC = 0;
					DataOut	<=	{Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
					MOC = 1;
				end
				default: begin
					MOC = 0;
					DataOut	<=	32'b0;
					MOC = 1;
				end
			endcase		
		end
		else begin
			case (DataType)
				2'b00:begin	//Byte 
					MOC= 0;
					Mem[Address]	<=	DataIn ;
					MOC =1;
				end

				2'b01: begin	//half word 
					MOC = 0;
					Mem[Address]	<=	DataIn[15:8];
					Mem[Address+1]	<=	DataIn[7:0];
					MOC = 1;
				end

				2'b10:begin	// Word
					MOC = 0;
					Mem[Address]	<=	DataIn[31:24];
					Mem[Address+1]	<=	DataIn[23:16];
					Mem[Address+2]	<=	DataIn[15:8];
					Mem[Address+3]	<=	DataIn[7:0];
					MOC = 1;
				end
		
				2'b11:begin	// Double Word
					MOC = 0;
					Mem[Address]	<=	DataIn[31:24];
					Mem[Address+1]	<=	DataIn[23:16];
					Mem[Address+2]	<=	DataIn[15:8];
					Mem[Address+3]	<=	DataIn[7:0];
					MOC = 1;
				end
			endcase
		end
	end
endmodule
