`include "ControlUnit.v"

module main;
	
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
	reg showClock = 0;
		
	ControlUnit CU(FR_ld, RF_ld, IR_ld, MAR_ld, MDR_ld, R_W, MOV, 
		MA, MB, MC, MD, ME, OP, DT, IR, MOC, COND, clk, clr,
		debug);
	
	function [31:0] makeADDRMode3;
		input [3:0] cond;
		input P, U, I, W, L;
		input [3:0] Rn, Rd, Im;
		input S, H;
		input [3:0] Rm;
		begin
			makeADDRMode3 = {cond,3'b0,P,U,I,W,L,Rn,Rd,Im,1'b1,S,H,1'b1,Rm};
		end
	endfunction
	
	function [31:0] makeADDRMode4;
		input [3:0] cond;
		input P, U, S, W, L;
		input [3:0] Rn;
		input [15:0] Rd;
		begin
			makeADDRMode4 = {cond,3'b100,P,U,S,W,L,Rn,Rd};
		end
	endfunction
	
	initial begin

		clk = 0;
		clr = 0;
		#200;
		if (showClock) $display("Clock");
		clk = 1;
		#200;
		clk = 0;
		#200;
		if (showClock) $display("Clock");
		clk = 1;
		#200;
		$display("Clear enabled");
		clr = 1;
		clk = 0;
		#200;
		if (showClock) $display("Clock");
		clk = 1;
		#200;
		clk = 0;
		#200;
		if (showClock) $display("Clock");
		clk = 1;
		clr = 0;	//Clear = 0 here to let it sit for two clock cycles
		#200;
		clk = 0;
		$display("Clear disabled");
		#200;
		if (showClock) $display("Clock");
		clk = 1;
		#200;
		clk = 0;

		//					COND P U I W L Rn	Rd	 Im   S H Rm
		//IR = makeADDRMode3 (4'b0,1,0,1,0,0,4'b0,4'b0,3'b0,0,1,4'b0);
		
		//					COND P U S W L Rn	Rd	 
		IR = makeADDRMode4 (4'b0,1,0,0,0,0,4'b0,15'b0);
		$display("IR %b", IR);

		MOC = 1;
		// Testing states
		#200;
		$display("\n\nReset");
		clr = 1;
		clk = 0;
		#200;
		if (showClock) $display("Clock");
		clk = 1;
		clr = 0;
		#200;
		clk = 0;
		#200;
		if (showClock) $display("Clock");
		clk = 1;
		#200;
		clk = 0;
		#200;
		if (showClock) $display("Clock");
		clk = 1;
		#200;
		clk = 0;
		#200;
		if (showClock) $display("Clock");
		clk = 1;
		#200;
		clk = 0;
		#200;
		if (showClock) $display("Clock");
		clk = 1;
		#200;
		clk = 0;
		#200;
		if (showClock) $display("Clock");
		clk = 1;
		#200;
		clk = 0;
		#200;
		if (showClock) $display("Clock");
		clk = 1;
		#200;
		clk = 0;
		#200;
		if (showClock) $display("Clock");
		clk = 1;
	end

endmodule