`include "ram256x32.v"
module RAM_Access;
	integer 		fi, fo, count = 0, code;
	reg 	[31:0] 	DataIn;
	reg 			ReadWrite, MOV=0;
	reg 	[7:0] 	Address;
	wire 	[31:0] 	DataOut;
	reg 	[31:0] 	data;
	wire 			MOC;
	reg 	[1:0] 	DataType;

	ram256x32 ram1 (DataOut, MOC, ReadWrite, Address, DataIn, MOV, DataType);

	initial begin
		fi =$fopen("input_file0.txt","r");
		Address = 8'b00000000;
		$display("		Addr    	 	Mem 			 	data");
		while (!$feof(fi)) begin
			if(!$feof(fi)) code = $fscanf(fi,"%b",data[31:24]);
			else data[31:24] = 8'b0;
			if(!$feof(fi)) code = $fscanf(fi,"%b",data[23:16]);
			else data[23:16] = 8'b0;
			if(!$feof(fi)) code = $fscanf(fi,"%b",data[15:8]);
			else data[15:8] = 8'b0;
			if(!$feof(fi)) code = $fscanf(fi,"%b",data[7:0]);
			else data[7:0] = 8'b0;
			ram1.Mem[Address] = data;
			$display("Preloading Addr %b = %b | %b", Address, ram1.Mem[Address], data);
			Address = Address + 1;
			count = count + 1;
		end
		$fclose(fi);
	end

	initial begin
		$display("------------------------------------------------------------------");
		fo = $fopen("memcontent.txt", "w"); 
		MOV = 0;
		ReadWrite = 1;
		Address = #1 8'b00000000;
		DataType = 2'b10;

		repeat(count) begin
			#1 MOV = 1;
			while (!MOC)
				#1;
			#1 MOV = ~MOV;
			Address = Address + 1;
		end
		#3;
		$display("------------------------------------------------------------------");
		MOV = 1'b0; ReadWrite = 1'b1;
		Address = #1 8'b00000000;

		repeat(count) begin
			#1 MOV = 1;
			while (!MOC)
				#1;
			#1 MOV = ~MOV;
			Address = Address + 1;
		end
	end
	
	always @ (MOC, MOV) begin
	  $display("MOC : %d 	MOV : %d     		  	     %d",MOC,MOV,$time);
	end
	always @ (posedge MOV) begin 
		#1; $fdisplay(fo,"Data of Addr %b = %b | %d %d", Address, DataOut, DataOut, $time);
		$display("Dataout: %b %d %d",DataOut, DataOut, $time);
	end 
	// always @ (DataOut) begin
	  // #1; $display("Dataout: %b %d",DataOut,$time);
	// end


endmodule
