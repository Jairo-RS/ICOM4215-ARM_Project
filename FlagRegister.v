module FlagRegister(
    output reg 	[3:0] 	Q, 
    input 		[3:0] 	D, 
    input 				FR_ld, clk);

    always @(posedge clk) begin
        if(FR_ld)
            Q <= D;
    end
endmodule

module ConditionTester(
    output reg Cond,
    input cFlag, zFlag, nFlag, vFlag,
    input [3:0] IR);

    always@(IR, cFlag, zFlag, nFlag, vFlag) begin
        case(IR)
            4'b0000: begin //EQ (Equal)
            	if(zFlag == 1) Cond = 1;
				else Cond = 0;
            end

            4'b0001: begin //NE (Not Equal)
            	if(zFlag == 0) Cond = 1;
				else Cond = 0;
			end

            4'b0010: begin //CS/HS (Carry Set or (Unsigned higher or same))
            	if(cFlag == 1) Cond = 1;
				else Cond = 0;
			end

            4'b0011: begin //CC/LO (Carry Clear or Unsigned lower)
			    if(cFlag == 0) Cond = 1;
				else Cond = 0;
			end

            4'b0100: begin //MI (Minus)
            	if(nFlag == 1) Cond = 1;
				else Cond = 0;
			end

            4'b0101: begin //PL (Positive or plus)
            	if(nFlag == 0) Cond = 1;
				else Cond = 0;
			end 

            4'b0110: begin //VS (Signed Overflow)
            	if(vFlag == 1) Cond = 1;
				else Cond = 0;
			end

            4'b0111: begin //VC (No Signed Overflow)
            	if(vFlag == 0) Cond = 1;
				else Cond = 0;
			end

            4'b1000: begin //HI (Unsigned Higher)
            	if(cFlag == 1 && zFlag == 0) Cond = 1;
				else Cond = 0;
			end

            4'b1001: begin //LS (Unsigned Lower or same)
            	if(cFlag == 0 && zFlag == 1) Cond = 1;
				else Cond = 0;
			end

            4'b1010: begin //GE (Greater or equal)
            	if(cFlag == vFlag) Cond = 1;
				else Cond = 0;
			end

            4'b1011: begin //LT (Signed Less than)
            	if(!nFlag == vFlag) Cond = 1;
				else Cond = 0;
			end

            4'b1100: begin //GT (Signed Greater than)
            	if(zFlag == 0 && nFlag == vFlag) Cond = 1;
				else Cond = 0;
			end

            4'b1101: begin //LE (Signed Less than or equal)
            	if(zFlag == 1 || nFlag != vFlag) Cond = 1;
				else Cond = 0;
			end

            4'b1110: //AL (Always executed)
            Cond = 1;

            default:
            Cond = 0;

        endcase
    end

endmodule