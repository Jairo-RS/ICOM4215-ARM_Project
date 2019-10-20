module ControlUnit (
	output FR_ld, RF_ld, IR_ld, MAR_ld, MDR_ld, R_W, MOV, 
		MA1, MA0, MB1, MB0, MC, MD, ME,
    output [4:0] OP,
    input [31:0] IR,
    input MOC, COND, clk, clr,
    input debug
    );

	wire[9:0] nextState, state;

	NextStateDecoder nextStateDecoder(nextState, state, IR, COND, MOC);

	StateReg stateRegister(state, nextState, clk, clr);
	
	ControlSignalsEncoder signalDecoder(FR_ld, RF_ld, IR_ld, MAR_ld, 
		 MDR_ld, R_W, MOV, MA1, MA0, MB1, MB0, MC, MD, ME, 
		 OP, state, IR);
		 
	always @(posedge clk) begin
		if(debug) begin
			$display("---------- State: %d ----------", state);
			$display("FR_ld \tRF_ld \tIR_ld \tMAR_ld \tMDR_ld \tR_W \tMOV \tMA1 \tMA0 \tMB1 \tMB0 \tMC \tMD \tME \tOP");
			$display("%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b ",
				FR_ld, RF_ld, IR_ld, MAR_ld, MDR_ld, R_W, MOV, MA1, MA0, MB1, MB0, MC, MD, ME, OP);
		end
	end
	
endmodule


module NextStateDecoder (
	output reg	[9:0] 	nextState, 
	input		[9:0] 	state,
	input		[31:0] 	IR, 
	input 				Cond, MOC);

	always @ (state) begin
        case (state) 
            9'd0: nextState <= 9'd1;
			9'd1: nextState <= 9'd2;
			9'd2: nextState <= 9'd3;
			9'd3: nextState <= 9'd4;
			9'd4: nextState <= 9'd5;
			default:
				nextState <= 9'd1;
            
		endcase
	end
endmodule


module StateReg (
	output reg	[9:0] 	state, 
	input 		[9:0] 	nextState, 
	input		 		clk, clr);
	
	initial begin
		state = 9'b00000;
	end
	
    always @(posedge clk,posedge clr) begin
        if(clr == 1'b1)
			state <= 9'b00000;
        else 
            state <= nextState;
	end
endmodule


module ControlSignalsEncoder (
    output reg FR_ld, RF_ld, IR_ld, MAR_ld, MDR_ld, R_W, MOV, MA1, 
		MA0, MB1, MB0, MC, MD, ME,
    output reg 	[4:0] 	OP,
    input 		[9:0] 	state,
	input 		[31:0] 	IR);
	
	always @ (state) begin
        case (state)
			9'd0: //Reset;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 1;
				MB0 = 1;
				MC = 1;
				MD = 1;
				ME = 0;
				OP = 5'b01101;
			end
			9'd1: //Fetch;
			begin
				FR_ld = 0;
				RF_ld = 0;
				IR_ld = 0;
				MAR_ld = 1;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 1;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 1;
				ME = 0;
				OP = 5'b10000;
			end
			9'd2: //;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 1;
				MOV = 1;
				MA1 = 1;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 1;
				MD = 1;
				ME = 0;
				OP = 5'b10001;
			end
			9'd3: //;
			begin
				FR_ld = 0;
				RF_ld = 0;
				IR_ld = 1;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 1;
				MOV = 1;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd4: //NoOp;
			begin
				FR_ld = 0;
				RF_ld = 0;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd5: //AND R;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd6: //AND Imm;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd7: //AND Shift;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd8: //AND R S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd9: //AND Imm S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd10: //AND Shift S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd11: //EOR R;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd12: //EOR Imm;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd13: //EOR Shift;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd14: //EOR R S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd15: //EOR Imm S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd16: //EOR Shift S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd17: //SUB R;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd18: //SUB Imm;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd19: //SUB Shift;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd20: //SUB R S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd21: //SUB Imm S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd22: //SUB Shift S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd23: //RSB R;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd24: //RSB Imm;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd25: //RSB Shift;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd26: //RSB R S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd27: //RSB Imm S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd28: //RSB Shift S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd29: //ADD R;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd30: //ADD Imm;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd31: //ADD Shift;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd32: //ADD R S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd33: //ADD Imm S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd34: //ADD Shift S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd35: //ADC R;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd36: //ADC Imm;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd37: //ADC Shift;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd38: //ADC R S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd39: //ADC Imm S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd40: //ADC Shift S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd41: //SBC R;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd42: //SBC Imm;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd43: //SBC Shift;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd44: //SBC R S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd45: //SBC Imm S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd46: //SBC Shift S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd47: //RSC R;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd48: //RSC Imm;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd49: //RSC Shift;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd50: //RSC R S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd51: //RSC Imm S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd52: //RSC Shift S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd53: //TST R;
			begin
				FR_ld = 1;
				RF_ld = 0;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd54: //TST Imm;
			begin
				FR_ld = 1;
				RF_ld = 0;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd55: //TST Shift;
			begin
				FR_ld = 1;
				RF_ld = 0;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd56: //TEQ R;
			begin
				FR_ld = 1;
				RF_ld = 0;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd57: //TEQ Imm;
			begin
				FR_ld = 1;
				RF_ld = 0;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd58: //TEQ Shift;
			begin
				FR_ld = 1;
				RF_ld = 0;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd59: //CMP R;
			begin
				FR_ld = 1;
				RF_ld = 0;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd60: //CMP Imm;
			begin
				FR_ld = 1;
				RF_ld = 0;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd61: //CMP Shift;
			begin
				FR_ld = 1;
				RF_ld = 0;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd62: //CMN R;
			begin
				FR_ld = 1;
				RF_ld = 0;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd63: //CMN Imm;
			begin
				FR_ld = 1;
				RF_ld = 0;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd64: //CMN Shift;
			begin
				FR_ld = 1;
				RF_ld = 0;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd65: //ORR R;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd66: //ORR Imm;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd67: //ORR Shift;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd68: //ORR R S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd69: //ORR Imm S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd70: //ORR Shift S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd71: //MOV R;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd72: //MOV Imm;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd73: //MOV Shift;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd74: //MOV R S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd75: //MOV Imm S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd76: //MOV Shift S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd77: //BIC R;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd78: //BIC Imm;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd79: //BIC Shift;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd80: //BIC R S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd81: //BIC Imm S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd82: //BIC Shift S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd83: //MVN R;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd84: //MVN Imm;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd85: //MVN Shift;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd86: //MVN R S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd87: //MVN Imm S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd88: //MVN Shift S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd89: //PASA R;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd90: //PASA Imm;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd91: //PASA Shift;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd92: //PASA R S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd93: //PASA Imm S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd94: //PASA Shift S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd95: //A+4 R;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd96: //A+4 Imm;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd97: //A+4 Shift;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd98: //A+4 R S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd99: //A+4 Imm S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd100: //A+4 Shift S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd101: //AD4 R;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd102: //AD4 Imm;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd103: //AD4 Shift;
			begin
				FR_ld = 0;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd104: //AD4 R S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 0;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd105: //AD4 Imm S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			9'd106: //AD4 Shift S;
			begin
				FR_ld = 1;
				RF_ld = 1;
				IR_ld = 0;
				MAR_ld = 0;
				MDR_ld = 0;
				R_W = 0;
				MOV = 0;
				MA1 = 0;
				MA0 = 0;
				MB1 = 0;
				MB0 = 1;
				MC = 0;
				MD = 0;
				ME = 0;
				OP = 5'b00000;
			end
			
			// Template
			9'd256:
            begin
                FR_ld = 0;
                RF_ld = 0;
                IR_ld = 0;
                MAR_ld = 0;
                MDR_ld = 0;
                R_W = 0;
                MOV = 0;
                MA1 = 0;
                MA0 = 0;
                MB1 = 0;
                MB0 = 0;
                MC = 0;
                MD = 0;
                ME = 0;
                OP = 5'b00000;
            end
			
			
            default:
                $display("Error: Control Signal Encoder. State not recognized S = %b", state);
            endcase 
		end
     
endmodule