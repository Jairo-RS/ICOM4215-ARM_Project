`include "ControlUnit.v"
`include "RegisterFile.v"
`include "ALU.v"

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
	reg [31:0] IR;
    reg MOC, COND, clk, clr;
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
	
	//Modeling All Muxes in Datapath
	always @ (*) begin
		case(MA)
			2'b00:	A <= IR[19:16];
			2'b01:	A <= IR[15:12]; 
			2'b10:	A <= 4'b1111; 
			2'b11:	A <= 4'b1111;
		endcase
		case(MB)
			2'b00:	aluB <= PB;
			2'b01:	aluB <= 32'b0; // Shifter
			2'b10:	aluB <= 32'b0; // RAM
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
	end

endmodule
