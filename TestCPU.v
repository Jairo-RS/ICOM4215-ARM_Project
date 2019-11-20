`include "CPU.v"

//TODO: 
//  Verify Overflow Flag (ALU) when subtracting and the anser is negative
module main;
	integer 		fi, fo, code;
	reg 	[7:0] 	Address;
	reg 	[7:0] 	data;
	
	reg [31:0] IR;
	CPU cpu(1'b1,1'b1,1'b1,1'b0);
		
    initial begin
		fi =$fopen("input_file0.txt","r");
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
		
		#10
		cpu.clk = 1'b0;
		cpu.clr = 1'b0;
//MOV Imm       COND   |OP|S|Rn||Rd|ImRo| Imm8 |	
		//IR =32'b00000011101000000001000000000100;
//ADD Imm       COND   |OP|S|Rn||Rd|ImRo| Imm8 |	 
		//IR =32'b00000010100000010001000000001000;
		repeat (4) begin
            #10 cpu.clk <= !cpu.clk;
			#10 cpu.clk <= !cpu.clk;		
        end
		//Stops the simulation when the ram has run out of preloaded instructions 
		while (cpu.IR !== 32'bX) begin
			#10 cpu.clk <= !cpu.clk;
			#10 cpu.clk <= !cpu.clk;
		end
    end
endmodule
