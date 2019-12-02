`include "NextStateDecoder.v"

module ControlUnit (
	output FR_ld, RF_ld, IR_ld, MAR_ld, MDR_ld, R_W, MOV, 
	output [1:0] MA,
    output [1:0] MB,
    output [1:0] MC,
	output MD, ME,
    output [4:0] OP,
	output [1:0] DT,
	output [3:0] CCU,
	output SIGN,
    input [31:0] IR,
    input MOC, COND, clk, clr,
    input debug
    );

	wire[9:0] nextState, state;

	NextStateDecoder nextStateDecoder(nextState, state, IR, COND, MOC);

	StateReg stateRegister(state, nextState, clk, clr);
	
	ControlSignalsEncoder signalDecoder(FR_ld, RF_ld, IR_ld, MAR_ld, 
		 MDR_ld, R_W, MOV, MA, MB, MC, MD, ME, OP, DT, CCU, SIGN, state, IR);
		 
	always @(nextState) begin
		if(debug) begin
			$display("======================= State: %d =======================", state);
			$display("FR_ld \tRF_ld \tIR_ld \tMAR_ld \tMDR_ld \tR_W \tMOV \tMA \tMB \tMC \tMD \tME \tOP \tDT \tCCU \tSIGN \tCOND");
			$display("%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b",
				FR_ld, RF_ld, IR_ld, MAR_ld, MDR_ld, R_W, MOV, MA, MB, MC, MD, ME, OP, DT, CCU, SIGN, COND);
			$display("IR %b", IR);
		end
	end
endmodule


module StateReg (
	output reg	[9:0] 	state, 
	input 		[9:0] 	nextState, 
	input		 		clk, clr);
	
	initial begin
		state = 10'b00000;
	end
	
    always @(posedge clk,posedge clr) begin
        if(clr == 1'b1)
			state <= 10'b00000;
        else 
            state <= nextState;
	end
endmodule


module ControlSignalsEncoder (
    output reg FR_ld, RF_ld, IR_ld, MAR_ld, MDR_ld, R_W, MOV, 
	output reg[1:0] MA,
    output reg[1:0] MB,
    output reg[1:0] MC,
	output reg MD, ME,
    output reg 	[4:0] 	OP,
	output reg 	[1:0] 	DT,
	output reg 	[3:0] 	CCU,
	output reg			SIGN,
    input 		[9:0] 	state,
	input 		[31:0] IR);
	
	always @ (state) begin
        case (state)
			10'd0: //Reset
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b11;	MC = 2'b01;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd1: //Fetch
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b10;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd2: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b10;
				MB = 2'b00;	MC = 2'b01;	MD = 1;	ME = 0;	OP = 5'b10001;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd3: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 1;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd4: //NoOp
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd5: //ALU R
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd6: //ALU Imm / Shift
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd7: //ALU R S
			begin
				FR_ld = 1;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd8: //ALU Imm / Shift S
			begin
				FR_ld = 1;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd9: //TST R
			begin
				FR_ld = 1;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd10: //TST Imm / Shift
			begin
				FR_ld = 1;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end			
			10'd11: //LDR Imm + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd12: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd13: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd14: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd15: //LDR R + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd16: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd17: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd18: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd19: //LDR Imm + PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd20: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd21: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd22: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd23: //LDR R + PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd24: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd25: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd26: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd27: //LDR Imm + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd28: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd29: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd30: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd31: //LDR R + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd32: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd33: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd34: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd35: //LDRB Imm + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd36: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd37: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd38: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd39: //LDRB R + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd40: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd41: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd42: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd43: //LDRB Imm + PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd44: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd45: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd46: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd47: //LDRB R + PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd48: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd49: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd50: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd51: //LDRB Imm + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd52: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd53: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd54: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd55: //LDRB R + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd56: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd57: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd58: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd59: //STR Imm + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd60: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd61: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd62: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd63: //STR R + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd64: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd65: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd66: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd67: //STR Imm + PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd68: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd69: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd70: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd71: //STR R + PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd72: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd73: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd74: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd75: //STR Imm + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd76: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd77: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 0;	ME = 0;	OP = 5'b00100;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd78: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd79: //STR R + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd80: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd81: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 0;	ME = 0;	OP = 5'b00100;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd82: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd83: //STRB Imm + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd84: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd85: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd86: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd87: //STRB R + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd88: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd89: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd90: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd91: //STRB Imm + PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd92: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd93: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd94: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd95: //STRB R + PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd96: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd97: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd98: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd99: //STRB Imm + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd100: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd101: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 0;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd102: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd103: //STRB R + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd104: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd105: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 0;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd106: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd107: //LDR Imm - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd108: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd109: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd110: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd111: //LDR R - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd112: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd113: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd114: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd115: //LDR Imm - PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd116: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd117: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd118: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd119: //LDR R - PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd120: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd121: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd122: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd123: //LDR Imm - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd124: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd125: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd126: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd127: //LDR R - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd128: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd129: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd130: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd131: //LDRB Imm - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd132: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd133: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd134: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd135: //LDRB R - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd136: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd137: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd138: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd139: //LDRB Imm - PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd140: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd141: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd142: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd143: //LDRB R - PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd144: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd145: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd146: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd147: //LDRB Imm - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd148: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd149: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd150: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd151: //LDRB R - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd152: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd153: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd154: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd155: //STR Imm - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd156: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd157: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd158: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd159: //STR R - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd160: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd161: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd162: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd163: //STR Imm - PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd164: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd165: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd166: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd167: //STR R - PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd168: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd169: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd170: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd171: //STR Imm - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd172: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd173: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 0;	ME = 0;	OP = 5'b00010;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd174: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd175: //STR R - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd176: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd177: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 0;	ME = 0;	OP = 5'b00010;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd178: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd179: //STRB Imm - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd180: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd181: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd182: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd183: //STRB R - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd184: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd185: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd186: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd187: //STRB Imm - PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd188: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd189: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd190: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd191: //STRB R - PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd192: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd193: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd194: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd195: //STRB Imm - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd196: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd197: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 0;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd198: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd199: //STRB R - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd200: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd201: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 0;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd202: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd203: //LDRD Imm + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd204: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd205: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd206: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b11;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = IR[15:12]+4'd1;	SIGN = 0;
			end
			10'd207: //LDRD R + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd208: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd209: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd210: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b11;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = IR[15:12]+4'd1;	SIGN = 0;
			end
			10'd211: //LDRD Imm + PRE
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd212: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd213: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd214: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b11;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = IR[15:12]+4'd1;	SIGN = 0;
			end
			10'd215: //LDRD R + PRE
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd216: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd217: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd218: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b11;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = IR[15:12]+4'd1;	SIGN = 0;
			end
			10'd219: //LDRD Imm + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10001;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd220: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd221: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd222: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b11;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = IR[15:12]+4'd1;	SIGN = 0;
			end
			10'd223: //LDRD R + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10001;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd224: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd225: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd226: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b11;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = IR[15:12]+4'd1;	SIGN = 0;
			end
			10'd227: //LDRSB Imm + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd228: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 1;
			end
			10'd229: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd230: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd231: //LDRSB R + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd232: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 1;
			end
			10'd233: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd234: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd235: //LDRSB Imm + PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd236: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 1;
			end
			10'd237: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd238: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd239: //LDRSB R + PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd240: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 1;
			end
			10'd241: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd242: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd243: //LDRSB Imm + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd244: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 1;
			end
			10'd245: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd246: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd247: //LDRSB R + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd248: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 1;
			end
			10'd249: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd250: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd251: //LDRSH Imm + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd252: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b01;	CCU = 0;	SIGN = 1;
			end
			10'd253: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd254: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd255: //LDRSH R + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd256: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b01;	CCU = 0;	SIGN = 1;
			end
			10'd257: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd258: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd259: //LDRSH Imm + PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd260: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b01;	CCU = 0;	SIGN = 1;
			end
			10'd261: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd262: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd263: //LDRSH R + PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd264: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b01;	CCU = 0;	SIGN = 1;
			end
			10'd265: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd266: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd267: //LDRSH Imm + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd268: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b01;	CCU = 0;	SIGN = 1;
			end
			10'd269: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd270: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd271: //LDRSH R + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd272: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b01;	CCU = 0;	SIGN = 1;
			end
			10'd273: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd274: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd275: //STRD Imm + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd276: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b11;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd277: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd278: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd279: //STRD R + OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd280: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b11;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd281: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd282: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd283: //STRD Imm + PRE
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd284: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b11;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd285: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd286: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd287: //STRD R + PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd288: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd289: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd290: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd291: //STRD Imm + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd292: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd293: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd294: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd295: //STRD R + POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd296: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd297: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd298: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd299: //LDRD Imm - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd300: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd301: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd302: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b11;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = IR[15:12]+4'd1;	SIGN = 0;
			end
			10'd303: //LDRD R - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd304: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd305: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd306: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b11;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = IR[15:12]+4'd1;	SIGN = 0;
			end
			10'd307: //LDRD Imm - PRE
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10011;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd308: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd309: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd310: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b11;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = IR[15:12]+4'd1;	SIGN = 0;
			end
			10'd311: //LDRD R - PRE
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10011;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd312: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd313: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd314: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b11;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = IR[15:12]+4'd1;	SIGN = 0;
			end
			10'd315: //LDRD Imm - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10001;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd316: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd317: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd318: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b11;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = IR[15:12]+4'd1;	SIGN = 0;
			end
			10'd319: //LDRD R - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10001;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd320: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd321: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd322: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b11;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = IR[15:12]+4'd1;	SIGN = 0;
			end
			10'd323: //LDRSB Imm - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd324: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 1;
			end
			10'd325: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd326: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd327: //LDRSB R - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd328: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 1;
			end
			10'd329: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd330: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd331: //LDRSB Imm - PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd332: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 1;
			end
			10'd333: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd334: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd335: //LDRSB R - PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd336: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 1;
			end
			10'd337: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd338: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd339: //LDRSB Imm - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd340: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 1;
			end
			10'd341: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd342: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd343: //LDRSB R - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd344: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 1;
			end
			10'd345: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd346: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd347: //LDRSH Imm - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd348: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b01;	CCU = 0;	SIGN = 1;
			end
			10'd349: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd350: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd351: //LDRSH R - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd352: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b01;	CCU = 0;	SIGN = 1;
			end
			10'd353: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd354: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd355: //LDRSH Imm - PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd356: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b01;	CCU = 0;	SIGN = 1;
			end
			10'd357: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd358: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd359: //LDRSH R - PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd360: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b01;	CCU = 0;	SIGN = 1;
			end
			10'd361: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd362: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd363: //LDRSH Imm - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd364: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b01;	CCU = 0;	SIGN = 1;
			end
			10'd365: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd366: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd367: //LDRSH R - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd368: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b01;	CCU = 0;	SIGN = 1;
			end
			10'd369: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd370: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd371: //STRD Imm - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10011;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd372: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b11;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd373: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd374: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd375: //STRD R - OFF
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10011;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd376: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b11;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd377: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd378: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd379: //STRD Imm - PRE
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd380: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd381: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd382: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd383: //STRD R - PRE
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd384: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd385: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd386: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd387: //STRD Imm - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10001;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd388: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b11;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd389: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd390: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd391: //STRD R - POS
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd392: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd393: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b00010;	DT = 2'b11;	CCU = 0;	SIGN = 0;
			end
			10'd394: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd395: //LDMIA / LDMFD
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd396: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10001;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd397: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd398: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd399: //LDMIB / LDMED
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10001;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd400: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd401: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd402: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd403: //LDMIDA / LDMFA
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd404: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10011;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd405: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd406: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd407: //LDMDB / LDMEA
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10011;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd408: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd409: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd410: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd411: //STMIA / STMEA
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd412: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd413: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 0;	ME = 0;	OP = 5'b10001;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd414: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd415: //STMIB / STMFA
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10001;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd416: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd417: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd418: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd419: //STMDA / STMED
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd420: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd421: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 0;	ME = 0;	OP = 5'b10011;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd422: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd423: //STMDB / STMFD
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10011;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd424: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd425: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd426: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd427: //LDMIA / LDMFD W
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd428: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10001;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd429: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd430: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd431: //LDMIB / LDMED W
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10001;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd432: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd433: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd434: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd435: //LDMIDA / LDMFA W
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd436: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10011;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd437: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd438: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd439: //LDMDB / LDMEA W
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10011;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd440: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd441: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 1;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd442: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b10;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b01101;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd443: //STMIA / STMEA W
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd444: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd445: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 0;	ME = 0;	OP = 5'b10001;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd446: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd447: //STMIB / STMFA W
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10001;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd448: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd449: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd450: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd451: //STMDA / STMED W
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 0;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd452: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd453: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 0;	ME = 0;	OP = 5'b10011;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd454: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd455: //STMDB / STMFD W
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 1;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10011;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd456: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 1;	R_W = 0;	MOV = 0;	MA = 2'b01;
				MB = 2'b00;	MC = 2'b00;	MD = 1;	ME = 1;	OP = 5'b10000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd457: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b10;	CCU = 0;	SIGN = 0;
			end
			10'd458: //
			begin
				FR_ld = 0;	RF_ld = 0;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 1;	MA = 2'b00;
				MB = 2'b00;	MC = 2'b00;	MD = 0;	ME = 0;	OP = 5'b00000;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd459: //B
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b10;
				MB = 2'b01;	MC = 2'b01;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end
			10'd460: //BL
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b10;
				MB = 2'b00;	MC = 2'b11;	MD = 1;	ME = 0;	OP = 5'b00100;	DT = 2'b00;	CCU = 4'b1110;	SIGN = 0;
			end
			10'd461: //
			begin
				FR_ld = 0;	RF_ld = 1;	IR_ld = 0;	MAR_ld = 0;	MDR_ld = 0;	R_W = 0;	MOV = 0;	MA = 2'b10;
				MB = 2'b01;	MC = 2'b10;	MD = 1;	ME = 0;	OP = 5'b10010;	DT = 2'b00;	CCU = 0;	SIGN = 0;
			end

            default:
                $display("Error: Control Signal Encoder. State not recognized S = %b", state);
            endcase 
		end
     
endmodule