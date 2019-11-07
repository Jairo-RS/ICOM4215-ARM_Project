`include "ControlUnit.v"
`include "RegisterFile.v"
`include "ALU.v"
`include "ram256x8.v"

//TODO: 
//	Implement Flag Register
//	Test Working ALU CU and RegF together
//  Implement Shifter Extender
//	Add RAM
module CPU ;
	wire FR_ld, RF_ld, IR_ld, MAR_ld, MDR_ld, R_W, MOV;
    wire [1:0] MA;
    wire [1:0] MB;
    wire [1:0] MC;
	wire MD, ME;
    wire [4:0] OP;
	wire [1:0] DT;
	wire [31:0] IR;
	wire MOC;
    reg COND, clk, clr;
    reg debug = 1;
	reg [3:0] cuC;
	
	ControlUnit CU(FR_ld, RF_ld, IR_ld, MAR_ld, MDR_ld, R_W, MOV, 
		MA, MB, MC, MD, ME, OP, DT, IR, MOC, COND, clk, clr,
		debug);
	
	wire cFlag, zFlag, nFlag, vFlag;
	reg [31:0] aluA, aluB;
	reg carryIn;
	wire [31:0] aluOut;
	reg [4:0] aluOP;
	
	ALU alu(aluA, aluB, aluOP, carryIn, aluOut, cFlag, zFlag, nFlag, vFlag);
	
	wire [31:0] PA, PB;
	reg [3:0] A, C;
//									PC         B
	regFile registerFile(PA, PB, aluOut, A, IR[3:0], C, RF_ld, Clk);
	
	wire 	[31:0] 	ramIn;
	wire 	[7:0] 	address;
	wire 	[31:0] 	ramOut;

	ram256x8 ram1(ramOut, MOC, R_W, address, ramIn, MOV, DT);
	
	MAR mar(address, aluOut, MAR_ld);
	
	reg [31:0] MEout;
	MDR mdr(ramIn, MEout, MDR_ld);
	
	InstructionReg instReg(IR, ramOut, IR_ld);
	
	//Modeling All Muxes in Datapath
	always @ (*) begin
		case(MA)
			2'b00:	A <= IR[19:16];
			2'b01:	A <= IR[15:12]; 
			2'b10:	A <= 4'b1111; 
			2'b11:	A <= 4'b0000;
		endcase
		case(MB)
			2'b00:	aluB <= PB;
			2'b01:	aluB <= 32'b0; // Shifter
			2'b10:	aluB <= ramIn; // RAM
			2'b11:	aluB <= 32'b0;
		endcase
		case(MC)
			2'b00:	C <= IR[15:12];
			2'b01:	C <= 4'b1111;
			2'b10:	C <= IR[19:16];
			2'b11:	C <= cuC;
		endcase
		case(MD)
			1'b0:	aluOP <= IR[24:21];
			1'b1:	aluOP <= OP;
		endcase
		case(ME)
			1'b0:	MEout <= ramOut;
			1'b1:	MEout <= aluOut;
		endcase
	end

endmodule

module MAR(
	output reg	[7:0]	Q,
	input 		[31:0]	D,
	input				MAR_ld);
	
	always @ (D, MAR_ld) begin
		if(MAR_ld)
			Q <= D[7:0];
	end
	
endmodule

module MDR(
	output reg	[31:0]	Q,
	input 		[31:0]	D,
	input				MDR_ld);
	
	always @ (D, MDR_ld) begin
		if(MDR_ld)
			Q <= D;
	end
	
endmodule

module InstructionReg(
	output reg	[31:0]	Q,
	input 		[31:0]	D,
	input				IR_ld);
	
	always @ (D, IR_ld) begin
		if(IR_ld)
			Q <= D;
	end
	
endmodule
	
