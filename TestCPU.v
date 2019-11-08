`include "CPU.v"
`include "RegisterFile.v"

module main;

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
	
	ControlUnit CU1(FR_ld, RF_ld, IR_ld, MAR_ld, MDR_ld, R_W, MOV, 
		MA, MB, MC, MD, ME, OP, DT, IR, MOC, COND, clk, clr,
		debug);
	
	wire cFlag, zFlag, nFlag, vFlag;
	reg [31:0] aluA, aluB;
	reg carryIn;
	wire [31:0] aluOut;
	reg [4:0] aluOP;
	
	ALU Alu(aluA, aluB, aluOP, carryIn, aluOut, cFlag, zFlag, nFlag, vFlag);
	
	wire [31:0] PA, PB;
	reg [3:0] A, C;
//									PC         B
	regFile registerFile1(PA, PB, aluOut, A, IR[3:0], C, RF_ld, Clk);

    // Specify simulation time
    parameter sim_time = 3000;

    initial #sim_time $finish;

    // Initialize simulation
    initial begin
    clk = 1'b0;
    clr = 1'b0;
    C = 4'b0000;


    end
    // Toggle clk
    initial begin
        #10 RF_ld = 1;
        repeat (400) begin
            #10 {clk, clr} <= {!clk, 1'b1};

            if(C == 4'b1010)  begin //Register 10

//ORR Imm Shft  COND   |OP|S|Rn||Rd|ImSh SH |Rm|	 
		/*IR =32'b00000000110010001100001100101010;

            $display("IR %b", IR);*/

            end
            $display("Entrada A ALU: %b", PA);
            $display("Entrada B ALU: %b", aluB);
            $display("Operacion del ALU: %b", aluOp);
        end
    end




   /* $display("Register R0:%d",regFile.Q0);
    $display("Register R1:%d",regFile.Q1);
    $display("Register R2:%d",regFile.Q2);
    $display("Register R3:%d",regFile.Q3);
    $display("Register R4:%d",regFile.Q4);
    $display("Register R5:%d",regFile.Q5);
    $display("Register R6:%d",regFile.Q6);
    $display("Register R7:%d",regFile.Q7);
    $display("Register R8:%d",regFile.Q8);
    $display("Register R9:%d",regFile.Q9);
    $display("Register R10:%d",regFile.Q10);
    $display("Register R11:%d",regFile.Q11);
    $display("Register R12:%d",regFile.Q12);
    $display("Register R13:%d",regFile.Q13);
    $display("Register R14:%d",regFile.Q14);
    $display("Register R15:%d",regFile.Q15);*/

endmodule
