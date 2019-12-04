`include "CPU.v"

//TODO: 
//	Start Load Store Multiple
module main;
	integer 		fi, fo, code;
	reg 	[7:0] 	Address;
	reg 	[7:0] 	data;
	
	reg [31:0] IR;
	reg [7:0] i;
	reg [31:0] temp;
	reg debugCU=1'b0, debugALU=1'b0, debugRAM=1'b0, debogREG=1'b0, debugSE=1'b0;
	CPU cpu(debugCU,debugALU,debogREG,debugRAM,debugSE);
		
    initial begin
		fi =$fopen("input_file3.txt","r");
		Address = 8'b00000000;
		$display("--------------------------- Preloading ---------------------------");
		while (!$feof(fi)) begin
			code = $fscanf(fi,"%b",data);
			cpu.ram.Mem[Address] = data;
			Address = Address + 1;
			if(Address%4==0)
				$display("Preloading Instruction %b", {cpu.ram.Mem[Address-4],
				cpu.ram.Mem[Address-3],cpu.ram.Mem[Address-2],cpu.ram.Mem[Address-1]});
		end
		$display("--------------------------- Preloading ---------------------------");
		$fclose(fi);
		fo = $fopen("OutputMemStart.txt", "w"); 
		for(i=0; i<8'd250; i=i+7'd4) begin
			$fdisplay(fo,"Data of Addr %d: %b %b %b %b", i, cpu.ram.Mem[i], cpu.ram.Mem[i+1], 
			cpu.ram.Mem[i+2], cpu.ram.Mem[i+3]);
			$fdisplay(fo,"             \t\t\t%d \t%d \t%d \t%d", cpu.ram.Mem[i], cpu.ram.Mem[i+1], 
			cpu.ram.Mem[i+2], cpu.ram.Mem[i+3]);
		end
		
		#10
		cpu.clk = 1'b0;
		cpu.clr = 1'b0;
//MOV Imm       COND   |OP|S|Rn||Rd|ImRo| Imm8 |	
		//IR =32'b00000011101000000001000000000100;
//ADD Imm       COND   |OP|S|Rn||Rd|ImRo| Imm8 |	 
		//IR =32'b00000010100000010001000000001000;
		//Stops the simulation when the ram has run out of preloaded instructions 
		repeat (4) begin
            #10 cpu.clk <= !cpu.clk;
			#10 cpu.clk <= !cpu.clk;		
        end
		
		repeat (133) begin
            #10 cpu.clk <= !cpu.clk;
			#10 cpu.clk <= !cpu.clk;		
        end
		repeat (100) begin
            #10 cpu.clk <= !cpu.clk;
			#10 cpu.clk <= !cpu.clk;		
        end
		
		// while (cpu.IR !== 32'bX) begin
			// #10 cpu.clk <= !cpu.clk;
			// #10 cpu.clk <= !cpu.clk;
		// end
		
		fo = $fopen("OutputMemEnd.txt", "w"); 
		for(i=0; i<8'd250; i=i+7'd4) begin
			$fdisplay(fo,"Data of Addr %d: %b %b %b %b", i, cpu.ram.Mem[i], cpu.ram.Mem[i+1], 
			cpu.ram.Mem[i+2], cpu.ram.Mem[i+3]);
			$fdisplay(fo,"             \t\t\t%d \t%d \t%d \t%d", cpu.ram.Mem[i], cpu.ram.Mem[i+1], 
			cpu.ram.Mem[i+2], cpu.ram.Mem[i+3]);
		end

		fo = $fopen("OutputRegEnd.txt", "w"); 
		$fdisplay(fo,"Data of REG 0: %b %b %b %b", cpu.registerFile.Q0[31:24], 
		cpu.registerFile.Q0[23:16], cpu.registerFile.Q0[15:8], cpu.registerFile.Q0[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q0[31:24], 
			cpu.registerFile.Q0[23:16],	cpu.registerFile.Q0[15:8], cpu.registerFile.Q0[7:0]);
		
		$fdisplay(fo,"Data of REG 1: %b %b %b %b", cpu.registerFile.Q1[31:24], 
		cpu.registerFile.Q1[23:16], cpu.registerFile.Q1[15:8], cpu.registerFile.Q1[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q1[31:24], 
			cpu.registerFile.Q1[23:16], cpu.registerFile.Q1[15:8], cpu.registerFile.Q1[7:0]);
			
		$fdisplay(fo,"Data of REG 2: %b %b %b %b", cpu.registerFile.Q2[31:24], 
		cpu.registerFile.Q2[23:16], cpu.registerFile.Q2[15:8], cpu.registerFile.Q2[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q2[31:24], 
			cpu.registerFile.Q2[23:16], cpu.registerFile.Q2[15:8], cpu.registerFile.Q2[7:0]);
		
		$fdisplay(fo,"Data of REG 3: %b %b %b %b", cpu.registerFile.Q3[31:24], 
		cpu.registerFile.Q3[23:16], cpu.registerFile.Q3[15:8], cpu.registerFile.Q3[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q3[31:24], 
			cpu.registerFile.Q3[23:16], cpu.registerFile.Q3[15:8], cpu.registerFile.Q3[7:0]);
		
		$fdisplay(fo,"Data of REG 4: %b %b %b %b", cpu.registerFile.Q4[31:24], 
		cpu.registerFile.Q4[23:16], cpu.registerFile.Q4[15:8], cpu.registerFile.Q4[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q4[31:24], 
			cpu.registerFile.Q4[23:16], cpu.registerFile.Q4[15:8], cpu.registerFile.Q4[7:0]);
		
		$fdisplay(fo,"Data of REG 5: %b %b %b %b", cpu.registerFile.Q5[31:24], 
		cpu.registerFile.Q5[23:16], cpu.registerFile.Q5[15:8], cpu.registerFile.Q5[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q5[31:24], 
			cpu.registerFile.Q5[23:16], cpu.registerFile.Q5[15:8], cpu.registerFile.Q5[7:0]);
			
		$fdisplay(fo,"Data of REG 6: %b %b %b %b", cpu.registerFile.Q6[31:24], 
		cpu.registerFile.Q6[23:16], cpu.registerFile.Q6[15:8], cpu.registerFile.Q6[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q6[31:24], 
			cpu.registerFile.Q6[23:16], cpu.registerFile.Q6[15:8], cpu.registerFile.Q6[7:0]);
			
		$fdisplay(fo,"Data of REG 7: %b %b %b %b", cpu.registerFile.Q7[31:24], 
		cpu.registerFile.Q7[23:16], cpu.registerFile.Q7[15:8], cpu.registerFile.Q7[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q7[31:24], 
			cpu.registerFile.Q7[23:16], cpu.registerFile.Q7[15:8], cpu.registerFile.Q7[7:0]);
			
		$fdisplay(fo,"Data of REG 8: %b %b %b %b", cpu.registerFile.Q8[31:24], 
		cpu.registerFile.Q8[23:16], cpu.registerFile.Q8[15:8], cpu.registerFile.Q8[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q8[31:24], 
			cpu.registerFile.Q8[23:16], cpu.registerFile.Q8[15:8], cpu.registerFile.Q8[7:0]);
			
		$fdisplay(fo,"Data of REG 9: %b %b %b %b", cpu.registerFile.Q9[31:24], 
		cpu.registerFile.Q9[23:16], cpu.registerFile.Q9[15:8], cpu.registerFile.Q9[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q9[31:24], 
			cpu.registerFile.Q9[23:16], cpu.registerFile.Q9[15:8], cpu.registerFile.Q9[7:0]);
		
		$fdisplay(fo,"Data of REG 10: %b %b %b %b", cpu.registerFile.Q10[31:24], 
		cpu.registerFile.Q10[23:16], cpu.registerFile.Q10[15:8], cpu.registerFile.Q10[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q10[31:24], 
			cpu.registerFile.Q10[23:16], cpu.registerFile.Q10[15:8], cpu.registerFile.Q10[7:0]);
			
		$fdisplay(fo,"Data of REG 11: %b %b %b %b", cpu.registerFile.Q11[31:24], 
		cpu.registerFile.Q11[23:16], cpu.registerFile.Q11[15:8], cpu.registerFile.Q11[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q11[31:24], 
			cpu.registerFile.Q11[23:16], cpu.registerFile.Q11[15:8], cpu.registerFile.Q11[7:0]);
		
		$fdisplay(fo,"Data of REG 12: %b %b %b %b", cpu.registerFile.Q12[31:24], 
		cpu.registerFile.Q12[23:16], cpu.registerFile.Q12[15:8], cpu.registerFile.Q12[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q12[31:24], 
			cpu.registerFile.Q12[23:16], cpu.registerFile.Q12[15:8], cpu.registerFile.Q12[7:0]);
			
		$fdisplay(fo,"Data of REG 13: %b %b %b %b", cpu.registerFile.Q13[31:24], 
		cpu.registerFile.Q13[23:16], cpu.registerFile.Q13[15:8], cpu.registerFile.Q13[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q13[31:24], 
			cpu.registerFile.Q13[23:16], cpu.registerFile.Q13[15:8], cpu.registerFile.Q13[7:0]);
			
		$fdisplay(fo,"Data of REG 14: %b %b %b %b", cpu.registerFile.Q14[31:24], 
		cpu.registerFile.Q14[23:16], cpu.registerFile.Q14[15:8], cpu.registerFile.Q14[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q14[31:24], 
			cpu.registerFile.Q14[23:16], cpu.registerFile.Q14[15:8], cpu.registerFile.Q14[7:0]);
			
		$fdisplay(fo,"Data of REG 15: %b %b %b %b", cpu.registerFile.Q15[31:24], 
		cpu.registerFile.Q15[23:16], cpu.registerFile.Q15[15:8], cpu.registerFile.Q15[7:0]);
		$fdisplay(fo,"             \t\t%d \t%d \t%d \t%d", cpu.registerFile.Q15[31:24], 
			cpu.registerFile.Q15[23:16], cpu.registerFile.Q15[15:8], cpu.registerFile.Q15[7:0]);
    end
endmodule
