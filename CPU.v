`include "ControlUnit.v"
`include "RegisterFile.v"
`include "ALU.v"
`include "ram256x8.v"
`include "FlagRegister.v"
`include "ShifterSignExtender.v"

module CPU(
	input				debugCU, debugALU, debugRF, debugRAM
	);
	
	wire FR_ld, RF_ld, IR_ld, MAR_ld, MDR_ld, R_W, MOV;
    wire [1:0] MA;
    wire [1:0] MB;
    wire [1:0] MC;
	wire MD, ME;
    wire [4:0] OP;
	wire [1:0] DT;
	wire [31:0] IR;
	wire MOC, COND;
    reg clk, clr;
	reg [3:0] cuC;
	
	ControlUnit CU(FR_ld, RF_ld, IR_ld, MAR_ld, MDR_ld, R_W, MOV, 
		MA, MB, MC, MD, ME, OP, DT, IR, MOC, COND, clk, clr,
		debugCU);
		
	wire cFlag, zFlag, nFlag, vFlag;
	wire [31:0] aluA;
	reg [31:0] aluB;
	wire carryIn;
	wire [31:0] aluOut;
	reg [4:0] aluOP;
	
	ALU alu(aluA, aluB, aluOP, carryIn, aluOut, cFlag, zFlag, nFlag, vFlag, debugALU);
	
	wire [31:0] PA, PB;
	reg [3:0] A, C;
//									PC         B
	regFile registerFile(aluA, PB, aluOut, A, IR[3:0], C, RF_ld, clk, debugRF);
	
	wire 	[31:0] 	ramIn;
	wire 	[7:0] 	address;
	wire 	[31:0] 	ramOut;

	ram256x8 ram(ramOut, MOC, R_W, address, ramIn, MOV, DT, debugRAM);

	MAR mar(address, aluOut, MAR_ld);
	
	reg [31:0] MEout;
	MDR mdr(ramIn, MEout, MDR_ld);
	
	InstructionReg instReg(IR, ramOut, IR_ld);
	
	reg [3:0] flags;
	FlagRegister flagReg({cFlag, zFlag, nFlag, vFlag}, flags, FR_ld, clk);
	
	ConditionTester condTester(COND, flags[3], flags[2], flags [1], flags[0], IR[31:28]);
	
	wire [31:0] shiftOut;
	ShifterSignExtender shfterExtender(shiftOut, carryIn, cFlag, IR, PB);
	
	//Modeling All Muxes in Datapath
	always @ (clk) begin
		case(MA)
			2'b00:	A <= IR[19:16];
			2'b01:	A <= IR[15:12]; 
			2'b10:	A <= 4'b1111; 
			2'b11:	A <= 4'b0000;
			default: A <= IR[19:16];
		endcase
		case(MB)
			2'b00:	aluB <= PB;
			2'b01:	aluB <= shiftOut; // Shifter
			2'b10:	aluB <= ramIn; // RAM
			2'b11:	aluB <= 32'b0;
			default: aluB <= PB;
		endcase
		case(MC)
			2'b00:	C <= IR[15:12];
			2'b01:	C <= 4'b1111;
			2'b10:	C <= IR[19:16];
			2'b11:	C <= 4'b1110;
			default: C <= IR[15:12];
		endcase
		case(MD)
			1'b0:	aluOP <= IR[24:21];
			1'b1:	aluOP <= OP;
			default: aluOP <= IR[24:21];
		endcase
		case(ME)
			1'b0:	MEout <= ramOut;
			1'b1:	MEout <= aluOut;
			default: MEout <= ramOut;
		endcase
	end

endmodule

module MAR(
	output reg	[7:0]	Q,
	input 		[31:0]	D,
	input				MAR_ld);
	
	always @ (D, MAR_ld) begin
		if(MAR_ld)
			Q = D[7:0];
	end
	
endmodule

module MDR(
	output reg	[31:0]	Q,
	input 		[31:0]	D,
	input				MDR_ld);
	
	always @ (D, MDR_ld) begin
		if(MDR_ld)
			Q = D;
	end
	
endmodule

module InstructionReg(
	output reg	[31:0]	Q,
	input 		[31:0]	D,
	input				IR_ld);
	
	always @ (D, IR_ld) begin
		if(IR_ld)
			Q = D;
	end
	
endmodule
	
