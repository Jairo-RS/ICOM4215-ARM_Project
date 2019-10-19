`include "ControlUnit.v"

module main;
	
	wire FR_ld, RF_ld, IR_ld, MAR_ld, MDR_ld, R_W, MOV, 
		MA1, MA0, MB1, MB0, MC, MD, ME;
    wire [4:0] OP;
	reg [31:0] IR;
    reg MOC, COND, clk, clr;
    reg ZF, N, C, V;
	
	ControlUnit CU(FR_ld, RF_ld, IR_ld, MAR_ld, MDR_ld, R_W, MOV, 
		MA1, MA0, MB1, MB0, MC, MD, ME, OP, IR, MOC, COND, clk, clr,
		ZF, N, C, V);
	
	initial begin

	end

endmodule