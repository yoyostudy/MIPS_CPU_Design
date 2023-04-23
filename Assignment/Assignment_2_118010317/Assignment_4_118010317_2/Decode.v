/*
 * Module Name: Decode.v
 * Usage: This module implements the Decode stage
 *        used for pipelined CPU(stage II)
 * ----------------------------------------------
 * The decode stage will divide the instruction 
 * generate the control signals, read the registers.
 * Extender will extend the imm16 to 32-bit
 * ----------------------------------------------
 * After completing stage I (FETCH) process,
 * the output of stage I will be store in  
 * registors Instruction and PCplus4
 * 
 * Instruction will be divide into function field
 * such as opcode, func, rs, rt, rd, imm, target, sa
 * 
 * Based on opcode and func, the CONTROl component 
 * will generate control signals automatically given 
 * the Instruction signal changed
 * 
 * Based on rs, rt, the RegFile will read the registers
 * and pass out as wire busA, busB
 * 
 * Based on imm and the control signals, the extender will 
 * extend the imm using the right method, and pass 
 * out as wire extimm
 * 
 * Based on control signal, the write address will be choose 
 * from rt and rd (or $ra), and pass out as wire Rw
 * ----------------------------------------------
 * Input: Instruction
 * Output: busA, busB, extimm, Rw, sa, target, control signals
 * ----------------------------------------------
 * To avoid stucture harzads that may cause,
 * we read the registors in the second half 
 * part of the clock 
 * 
 */

module Decode
	(
		  input[31:0] InstrD
		, input[31:0] PCplus4Din
		, output[31:0] PCplus4Dout
		, output RegWriteD
		, output MemWriteD
		, output MemtoRegD
		, output[2:0] nPC_selD
		, output RegDstD
		, output ALUSrcD
		, output[3:0] ALUCtrD
		, output[31:0] extimmD
		, output[4:0] rsD
		, output[4:0] rtD
		, output[4:0] rdD
		, output[4:0] saD
		, output[25:0] targetD
	);

	reg [5:0] func;
	reg [5:0] op;
	reg [4:0] rs;
	reg [4:0] rt;
	reg [4:0] rd;
	reg [4:0] sa;
	reg [4:0] rw;
	reg [31:0] busWD;
	reg [15:0] imm;
	reg [25:0] target;

	reg [31:0] extimm;
	reg [31:0] PCplus4D;

	wire Extop;

	always@(InstrD) begin
		op = InstrD[31:26];
		rs = InstrD[25:21];
		rt = InstrD[20:16];
		rd = InstrD[15:11];
		sa = InstrD[10:6];
		imm = InstrD[15:0];
		target = InstrD[25:0];
		func = InstrD[5:0];
		PCplus4D = PCplus4Din;
	end

	control get_controlsignals(op, func, RegDstD, ALUSrcD, RegWriteD, MemtoRegD, MemWriteD, Extop, nPC_selD, ALUCtrD);
	//RegFile read_RegFile( CLOCK, 1'b0, rs, rt, rw, busWD, busAD, busBD);

	always @(Extop,imm) begin
		if (Extop) extimm = { {(16){imm[15]} }, imm};
		else extimm = { {(16){1'b0}}, imm};
	end

	assign extimmD = extimm;
	assign saD = sa;
	assign targetD = target;
	assign rtD = rt;
	assign rdD = rd;
	assign rsD = rs;
	assign PCplus4Dout = PCplus4D;


endmodule

module control
	( input [5:0] op, func,
	  output RegDst, ALUSrc, RegWrite, MemtoReg, MemWrite, Extop,
	  output [2:0] nPC_sel,
	  output [3:0] ALUCtr
	);

reg r_type, add, addu, and_, jr, nor_, or_, sll, sllv, slt, sra, srav, srl, srlv, sub, subu, xor_ ,
	addi, addiu, andi, beq, bne, ori, xori, lw, sw,
	j, jal;

always @(op, func)
begin 
	// control signals
	r_type 	= (~ op[5]) & (~ op[4])  & (~ op[3])   & (~ op[2]) 	  & (~ op[1]) 	    & (~ op[0])	;
	add    	= r_type    & (  func[5]) & (~ func[4]) & (~ func[3])  & (~ func[2]) 	& (~ func[1]) 	& (~ func[0]);
	addu 	= r_type    & (  func[5]) & (~ func[4]) & (~ func[3])  & (~ func[2]) 	& (~ func[1]) 	& (  func[0]);
	and_	= r_type    & (  func[5]) & (~ func[4]) & (~ func[3])  & (  func[2]) 	& (~ func[1]) 	& (~ func[0]);
	jr		= r_type    & (~ func[5]) & (~ func[4]) & (  func[3])  & (~ func[2]) 	& (~ func[1]) 	& (~ func[0]);
	nor_	= r_type    & (  func[5]) & (~ func[4]) & (~ func[3])  & (  func[2]) 	& (  func[1]) 	& (  func[0]);
	or_	    = r_type    & (  func[5]) & (~ func[4]) & (~ func[3])  & (  func[2]) 	& (~ func[1]) 	& (  func[0]);
	sll		= r_type    & (~ func[5]) & (~ func[4]) & (~ func[3])  & (~ func[2]) 	& (~ func[1]) 	& (~ func[0]);
	sllv	= r_type    & (~ func[5]) & (~ func[4]) & (~ func[3])  & (  func[2]) 	& (~ func[1]) 	& (~ func[0]);
	slt		= r_type    & (  func[5]) & (~ func[4]) & (  func[3])  & (~ func[2]) 	& (  func[1]) 	& (~ func[0]);
	sra		= r_type    & (~ func[5]) & (~ func[4]) & (~ func[3])  & (~ func[2]) 	& (  func[1]) 	& (  func[0]);
	srav	= r_type    & (~ func[5]) & (~ func[4]) & (~ func[3])  & (  func[2]) 	& (  func[1]) 	& (  func[0]);
	srl		= r_type    & (~ func[5]) & (~ func[4]) & (~ func[3])  & (~ func[2]) 	& (  func[1]) 	& (~ func[0]);
	srlv	= r_type    & (~ func[5]) & (~ func[4]) & (~ func[3])  & (  func[2]) 	& (  func[1]) 	& (~ func[0]);
	sub		= r_type    & (  func[5]) & (~ func[4]) & (~ func[3])  & (~ func[2]) 	& (  func[1]) 	& (~ func[0]);
	subu	= r_type    & (  func[5]) & (~ func[4]) & (~ func[3])  & (~ func[2]) 	& (  func[1]) 	& (  func[0]);
	xor_	= r_type    & (  func[5]) & (~ func[4]) & (~ func[3])  & (  func[2]) 	& (  func[1]) 	& (~ func[0]);

	addi	= (~ op[5]) & (~ op[4]) & (  op[3]) & (~ op[2]) & (~ op[1]) & (~ op[0])	;
	addiu	= (~ op[5]) & (~ op[4]) & (  op[3]) & (~ op[2]) & (~ op[1]) & (  op[0])	;
	andi	= (~ op[5]) & (~ op[4]) & (  op[3]) & (  op[2]) & (~ op[1]) & (~ op[0])	;
	beq		= (~ op[5]) & (~ op[4]) & (~ op[3]) & (  op[2]) & (~ op[1]) & (~ op[0])	;
	bne 	= (~ op[5]) & (~ op[4]) & (~ op[3]) & (  op[2]) & (~ op[1]) & (  op[0])	;
	ori 	= (~ op[5]) & (~ op[4]) & (  op[3]) & (  op[2]) & (~ op[1]) & (  op[0])	;
	xori	= (~ op[5]) & (~ op[4]) & (  op[3]) & (  op[2]) & (  op[1]) & (~ op[0])	;
	lw      = (  op[5]) & (~ op[4]) & (~ op[3]) & (~ op[2]) & (  op[1]) & (  op[0])	;
	sw		= (  op[5]) & (~ op[4]) & (  op[3]) & (~ op[2]) & (  op[1]) & (  op[0])	;

	j 		= (~ op[5]) & (~ op[4]) & (~ op[3]) & (~ op[2]) & (  op[1]) & (~ op[0])	;
	jal		= (~ op[5]) & (~ op[4]) & (~ op[3]) & (~ op[2]) & (  op[1]) & (  op[0])	;

end

	assign	RegDst = r_type; // except for jr
	assign  ALUSrc = addi | addiu | andi | ori | xori | lw | sw;
	assign  RegWrite = r_type | addi | addiu | andi | ori | xori | ~jr | lw  ;
	assign  MemtoReg = lw;
	assign  MemWrite = sw;
	assign  Extop = addi | addiu | lw | sw | bne | beq;
	assign  nPC_sel[2] = jr;
	assign  nPC_sel[1] = beq | bne;
	assign  nPC_sel[0] = bne | j | jal;  
	assign ALUCtr[0] = subu | sub | slt | beq | bne | or_ | ori | nor_ | sllv | srlv | srav ;
	assign ALUCtr[1] = xor_ | xori | nor_ | srl | srlv | slt ;
	assign ALUCtr[2] = and_ | andi | or_ | ori | xor_ | xori | nor_ | sra | srav;
	assign ALUCtr[3] = sll | sllv | srl | srlv | sra | srav;

endmodule


