`timescale 1ns/1ps
module alu_tb;

reg signed [31:0]	 i_datain, gr0, gr1, exp_result;
wire signed [31:0]	 result; 
wire [2:0] flags;
reg bol;

alu testalu(i_datain,gr0,gr1,result,flags);
always @(*)
begin
		bol = (result == exp_result);
end

initial begin
	$display("--------Test begin ---------------------------------------");
	$display("--------Begin Shift Test  --------------------------------");
	$display("instruction:opcode:func  :gr0     :gr1     :result   :reg_A   :reg_B   :reg_C  :flags:exp_result:Equal? ");
	$monitor("   %h:%b:%b:%h:%h:%h:%h:%h:%h:%b  :%h  :%b",
			i_datain,testalu.opcode,testalu.func, gr0 ,gr1, result,  testalu.reg_A, testalu.reg_B, testalu.reg_C, flags, exp_result, bol);

	#10 i_datain 	<=32'b0000_0000_0000_0001_0001_0000_1000_0000;  //sll (sa=2,rt=00001)  
		gr1 		<=32'b1101_1101_1101_1101_1101_1101_1101_1101;        
		exp_result 	<=32'b0111_0111_0111_0111_0111_0111_0111_0100;

	#10 i_datain 	<=32'b0000_0000_0000_0001_0001_0000_0100_0010;  // srl (sa=1,rt=00001)  
		gr1 		<=32'b1101_1101_1101_1101_1101_1101_1101_1101;        
		exp_result 	<=32'b0110_1110_1110_1110_1110_1110_1110_1110;
	
	#10 i_datain 	<=32'b0000_0000_0000_0001_0001_0001_0000_0011;  // sra(rt=x1,sa=4)
		gr1 		<=32'b1100_0000_0100_0000_0100_0000_0100_0000;
		exp_result	<=32'b1111_1100_0000_0100_0000_0100_0000_0100;

	#10 i_datain 	<=32'b0000_0000_0000_0001_0001_0000_0100_0100;  // sllv (rt=x1,rs=x0,sa=3)
		gr1 		<=32'b1101_1101_1101_1101_1101_1101_1101_1101;
		gr0 		<=32'b0000_0000_0000_0000_0000_0000_0000_0011;
		exp_result 	<=32'b1110_1110_1110_1110_1110_1110_1110_1000;

	#10 i_datain 	<=32'b0000_0000_0000_0001_0001_0001_0000_0110;  // srlv(rs=x0,rt=x1, sa =3)
		gr1 		<=32'b0100_0000_0100_0000_0100_0000_0100_0000;
		gr0 		<=32'b0000_0000_0000_0000_0000_0000_0000_0011;
		exp_result 	<=32'b0000_1000_0000_1000_0000_1000_0000_1000;

	#10 i_datain 	<=32'b0000_0000_0000_0001_0001_0001_0000_0111; // srav(rt=x1,rs=x0,sa=4)
		gr1 		<=32'b1100_0000_0100_0000_0100_0000_0100_0000;
		gr0 		<=32'b0000_0000_0000_0000_0000_0000_0000_0100;	
		exp_result	<=32'b1111_1100_0000_0100_0000_0100_0000_0100;
		
	#10 $display("--------Begin Arithemetic Test  ------------------------------");
	$display("instruction:opcode:func  :gr0     :gr1     :result   :reg_A   :reg_B   :reg_C  :flags:exp_result:Equal? ");

	#10 i_datain 	<=32'b0000_0000_0000_0001_0001_0001_0010_0000; // add(rt=x1,rs=x0,sa=4) // postive overflow
		gr1 		<=32'b0111_1111_1111_1111_1111_1111_1111_1111;
		gr0 		<=32'b0000_0000_0000_0000_0000_0000_0000_0001;
		exp_result  <=32'b1000_0000_0000_0000_0000_0000_0000_0000;

	#10 i_datain 	<=32'b0000_0000_0000_0001_0001_0001_0010_0001; // addu(rt=x1,rs=x0,sa=4)
		gr1 		<=32'b0111_1111_1111_1111_1111_1111_1111_1111;
		gr0 		<=32'b0111_1111_1111_1111_1111_1111_1111_1111;	
		exp_result  <=32'b1111_1111_1111_1111_1111_1111_1111_1110;


	#10 i_datain 	<=32'b0010_0000_0000_0001_0000_0000_0000_0001; // addi(rt=x1,rs=x0) // no overflow
		gr0 		<=32'b0111_1111_1111_1111_1111_1111_1111_1111;	
		exp_result  <=32'b1000_0000_0000_0000_0000_0000_0000_0000;

	#10 i_datain 	<=32'b0010_0100_0000_0001_1111_1111_1111_1111; // addiu(rt=x1,rs=x0)
		gr0 		<=32'b0111_1111_1111_1111_1111_1111_1111_1011;
		exp_result  <=32'b0111_1111_1111_1111_1111_1111_1111_1010;	
	

	#10 i_datain 	<=32'b0000_0000_0000_0001_0001_0001_0010_0010; // sub(rt=x1,rs=x0,sa=4) // negative overflow
		gr0 		<=32'b0111_1111_1111_1111_1111_1111_1111_1111;
		gr1 		<=32'b1000_0000_0000_0000_0000_0000_0000_0001;	
		exp_result	<=32'b1111_1111_1111_1111_1111_1111_1111_1110;

	#10 i_datain 	<=32'b0000_0000_0000_0001_0001_0001_0010_0011; // subu(rt=x1,rs=x0,sa=4)
		gr0 		<=32'b0111_1111_1111_1111_1111_1111_1111_1111;
		gr1 		<=32'b0000_0000_0000_0000_0000_0000_0000_0010;
		exp_result  <=32'b0111_1111_1111_1111_1111_1111_1111_1101;
	
	#10 i_datain 	<=32'b0001_0000_0000_0001_1111_1111_1111_1111; // beq(rt=x1,rs=x0) not equal ZF=0
		gr0 		<=32'b0111_1111_1111_1111_1111_1111_1111_1011;
		gr1 		<=32'b0111_1111_1111_1111_1111_1111_1111_1011;
		exp_result  <=0;	

	#10 i_datain 	<=32'b0001_0100_0000_0001_1111_1111_1111_1111; // bnq(rt=x1,rs=x0) equal ZF=1
		gr0 		<=32'b0111_1111_1111_1111_1111_1111_1111_1001;
		gr1 		<=32'b0111_1111_1111_1111_1111_1111_1111_1011;
		exp_result  <=0;	

	#10 
	$display("--------Begin Logic Test   ------------------------");
	$display("instruction:opcode:func  :gr0     :gr1     :result   :reg_A   :reg_B   :reg_C  :flags:exp_result:Equal? ");

	#10 i_datain 	<=32'b0000_0000_0000_0001_0010_0000_0010_0100; // and (rt=x1,rs=x0)
		gr0 		<=32'b1111_1111_1111_1111_1111_1111_1111_1111;
		gr1 		<=32'b1000_0000_0000_0000_0000_0000_0000_0001;	
		exp_result	<=32'b1000_0000_0000_0000_0000_0000_0000_0001;	
	
	#10 i_datain 	<=32'b0000_0000_0000_0001_0010_0000_0010_0101; // or (rt=x1,rs=x0)
		gr0 		<=32'b1111_1111_1111_1111_1111_1111_1111_1111;
		gr1 		<=32'b1000_0000_0000_0000_0000_0000_0000_0001;	
		exp_result	<=32'b1111_1111_1111_1111_1111_1111_1111_1111;

	#10 i_datain 	<=32'b0000_0000_0000_0001_0010_0000_0010_0110; // xor (rt=x1,rs=x0)
		gr0 		<=32'b1111_1111_1111_1111_1111_1111_1111_1111;
		gr1 		<=32'b1000_0000_0000_0000_0000_0000_0000_0001;	
		exp_result	<=32'b0111_1111_1111_1111_1111_1111_1111_1110;

	#10 i_datain 	<=32'b0000_0000_0000_0001_0010_0000_0010_0111; // nor (rt=x1,rs=x0)
		gr0 		<=32'b1111_1111_1111_1111_1111_1111_1111_1011;
		gr1 		<=32'b1000_0000_0000_0000_0000_0000_0000_0001;
		exp_result	<=32'b0000_0000_0000_0000_0000_0000_0000_0100;

	#10 i_datain 	<=32'b0011_0000_0000_0001_0010_0000_0010_0111; // andi (rt=x1,rs=x0)
		gr0 		<=32'b1111_1111_1111_1111_1111_1111_1111_1111;
		exp_result	<=32'b0000_0000_0000_0000_0010_0000_0010_0111;

	#10 i_datain 	<=32'b0011_0100_0000_0001_0010_0000_0010_0111; // ori (rt=x1,rs=x0)
		gr0 		<=32'b1111_1111_1111_1111_1111_1111_1111_1111;	
		exp_result	<=32'b1111_1111_1111_1111_1111_1111_1111_1111;

	#10 i_datain 	<=32'b0011_1000_0000_0001_0010_0000_0010_0111; // xori (rt=x1,rs=x0)
		gr0 		<=32'b1111_1111_1111_1111_1111_1111_1111_1111;
		exp_result	<=32'b1111_1111_1111_1111_1101_1111_1101_1000;	

	#10 $display("--------Begin Comparison Test ----------------------------");
	$display("instruction:opcode:func  :gr0     :gr1     :result   :reg_A   :reg_B   :reg_C  :flags:exp_result:Equal? ");

	#10 i_datain 	<=32'b0000_0000_0000_0001_0010_0000_0010_1010; // slt (rt=x1,rs=x0) SF=1
		gr0 	 	<=32'b1111_1111_1111_1111_1111_1111_1111_1111;
		gr1 		<=32'b0000_0000_0000_0000_0000_0000_0000_0001;
		exp_result	<=0;

	#10 i_datain 	<=32'b0000_0000_0000_0001_0010_0000_0010_1011; // sltu (rt=x1,rs=x0) SF=0
		gr0 		<=32'b1111_1111_1111_1111_1111_1111_1111_1111;
		gr1 		<=32'b0000_0000_0000_0000_0000_0000_0000_0001;
		exp_result	<=0;

	#10 i_datain 	<=32'b0010_1000_0000_0001_0000_0000_0000_0001; // slti (rt=x1,rs=x0) SF=1
		gr0 		<=32'b1111_1111_1111_1111_1111_1111_1111_1111;
		exp_result	<=0;

	#10 i_datain 	<=32'b0010_1100_0000_0001_1000_0000_0000_0001; // sltiu (rt=x1,rs=x0) SF=0
		gr0 		<=32'b1111_1111_1111_1111_1111_1111_1111_1111;
		exp_result	<=0;


	#10 
	$display("--------Finish Testing ----------------------");
	$finish;
end


endmodule