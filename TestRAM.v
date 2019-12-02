`include "ram256x8.v"
module RAM_Access;
	integer 		fi, fo, count = 0, code;
	reg 	[31:0] 	DataIn;
	reg 			ReadWrite, MOV=0;
	reg 	[7:0] 	Address;
	wire 	[31:0] 	DataOut;
	reg 	[7:0] 	data;
	wire 			MOC;
	reg 	[1:0] 	DataType;
	
	reg outFile=0;

	ram256x8 ram1 (DataOut, MOC, ReadWrite, Address, DataIn, MOV, DataType, 1'b0,1'b0);
	initial begin
		fi =$fopen("input_file0.txt","r");
		Address = 8'b00000000;
		$display("--------------------------- Preloading ---------------------------");
		$display("		Addr	    Mem	      data");
		while (!$feof(fi)) begin
			code = $fscanf(fi,"%b",data);
			ram1.Mem[Address] = data;
			$display("Preloading Addr %b = %b | %b", Address, ram1.Mem[Address], data);
			Address = Address + 1;
			count = Address/4;
		end
		$fclose(fi);
	end

	initial begin
		$display("-----------------------------------------------------------------");
		$display("------------------------- Manual Writing ------------------------");
		fo = $fopen("mem.txt", "w"); 
		DataIn = 32'b0;
		
		MOV = 1'b0; ReadWrite = 1'b0;
		Address = #1 8'b00001100;

		#6 DataIn = 32'b11111111110100111000000110010111;
		#1 DataType = 2'b00;
		#1 MOV = 1'b1;
		while (!MOC)
				#1;
		#1 MOV = ~MOC;
		$display("Loading Addr %b = %b | %b", Address, 
			{ram1.Mem[Address], ram1.Mem[Address+1], ram1.Mem[Address+2], ram1.Mem[Address+3]}, DataIn);
		Address = Address + 8'd4;

		#1 DataIn = 32'b11111111110100111000000110010111;
		#1 DataType = 2'b01;
		#1 MOV = 1'b1;
		while (!MOC)
				#1;
		#1 MOV = ~MOC;
		$display("Loading Addr %b = %b | %b", Address, 
			{ram1.Mem[Address], ram1.Mem[Address+1], ram1.Mem[Address+2], ram1.Mem[Address+3]}, DataIn);
		Address = Address + 8'd4;

		#1 DataIn = 32'b11111111110100111000000110010111;
		#1 DataType = 2'b10;
		#1 ReadWrite = 1'b0;
		#1 MOV = 1'b1;
		while (!MOC)
				#1;
		#1 MOV = ~MOC;
		$display("Loading Addr %b = %b | %b", Address, 
			{ram1.Mem[Address], ram1.Mem[Address+1], ram1.Mem[Address+2], ram1.Mem[Address+3]}, DataIn);
		Address = Address + 8'd4;
		
		#1 DataIn = 32'b01;
		#1 DataType = 2'b11;
		#1 ReadWrite = 1'b0;
		#1 MOV = 1'b1;
		while (!MOC)
				#1;
		#1 MOV = ~MOC;
		$display("Loading Addr %b = %b | %b", Address, 
			{ram1.Mem[Address], ram1.Mem[Address+1], ram1.Mem[Address+2], ram1.Mem[Address+3]}, DataIn);
		Address = Address + 8'd4;

		#1 DataIn = 32'b11;
		#1 DataType = 2'b11;
		#1 ReadWrite = 1'b0;
		#1 MOV = 1'b1;
		while (!MOC)
				#1;
		#1 MOV = ~MOC;
		$display("Loading Addr %b = %b | %b", Address, 
			{ram1.Mem[Address], ram1.Mem[Address+1], ram1.Mem[Address+2], ram1.Mem[Address+3]}, DataIn);
		
		#3;
		$display("-----------------------------------------------------------------");
		MOV = 1'b0; ReadWrite = 1'b1;
		Address = #1 8'b00000000;
		outFile = 1;
		
		DataType = 2'b10;
		$display("------------- Reading Memory Stored From Preloading -------------");

		repeat(count) begin
			#1 MOV = 1;
			while (!MOC)
				#1;
			#1 MOV = ~MOV;
			Address = Address + 8'd4;
		end
		
		#5
		$display("--------------- Reading Memory Stored From Manual ---------------");
		DataType = 2'b00;
		#1 MOV = 1;
		while (!MOC)
			#1;
		#1 MOV = ~MOV;
		Address = Address + 8'd4;
		
		DataType = 2'b01;
		#1 MOV = 1;
		while (!MOC)
			#1;
		#1 MOV = ~MOV;
		Address = Address + 8'd4;
		
		DataType = 2'b10;
		#1 MOV = 1;
		while (!MOC)
			#1;
		#1 MOV = ~MOV;
		Address = Address + 8'd4;
		
		DataType = 2'b11;
		#1 MOV = 1;
		while (!MOC)
			#1;
		#1 MOV = ~MOV;
		Address = Address + 8'd4;
		
		DataType = 2'b11;
		#1 MOV = 1;
		while (!MOC)
			#1;
		#1 MOV = ~MOV;
		Address = Address + 8'd4;
	end
	
	always @ (MOC, MOV) begin
	  $display("MOC : %d 	MOV : %d     		  	     %d",MOC,MOV,$time);
	end
	always @ (posedge MOV) begin 
		#1; 
		if (outFile) begin 
			$fdisplay(fo,"Data of Addr %b = %b | %d %d", Address, DataOut, DataOut, $time);
			$display("Dataout: %b %d %d",DataOut, DataOut, $time);
		end
	end 
	
	// always @ (DataOut) begin
	  // #1; $display("Dataout: %b %d",DataOut,$time);
	// end


endmodule
