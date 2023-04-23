module alu(i_datain,gr0,gr1,result,flags);

//---------------------
//------ o/i ----------
input  signed[31:0]  i_datain, gr0, gr1;

output signed[31:0]  result;
output [2:0] flags;   //[ZF,SF,OF]

//------ variables ---- 
reg signed[31:0]    rom[0:1];
reg OF; // overflow flag
reg SF; // negative(signal) flag. neg -> 1
reg ZF; // zero flag, zero -> ZF = 0

reg [5:0] 			opcode, func;
reg [15:0]			imm;
integer				add_rs, add_rt;   // address of registers. 0 or 1
reg signed[31:0] 	reg_rs, reg_rt;
reg signed [31:0] 	reg_A, reg_B, reg_C;
reg unsigned [31:0] x,y,z;

always @(i_datain,gr0,gr1,flags)
begin
	rom[0] = gr0;
	rom[1] = gr1;
	OF = 0;
	ZF = 0;
	SF = 0;
	reg_C = 0;
	
	// step 1. Parsing the Instructions
	opcode = i_datain[31:26];
	func = i_datain[5:0];
	imm = i_datain[15:0];
	add_rt = i_datain[20:16];
	add_rs = i_datain[25:21];
	
	// step 2. Fetch values in mem
	reg_rt = rom[add_rt];
	reg_rs = rom[add_rs];
	
	// step 3. Implementation functionalities
	case(opcode) 6'b000000:
		begin

			case(func) 6'b000000:  // sll
				begin
					reg_A = reg_rt;   
					reg_B = i_datain[10:6];
					reg_C = reg_A << reg_B;
				end
			endcase

			case(func) 6'b000100:  // sllv
				begin
					reg_A = reg_rt;   
					reg_B = reg_rs[4:0];
					reg_C = reg_A << reg_B;
				end
			endcase

			case(func) 6'b000010:  // srl
				begin
					reg_A = reg_rt;   
					reg_B = i_datain[10:6];
					reg_C = reg_A >> reg_B;
				end
			endcase

			case(func) 6'b000110:  // srlv
				begin
					reg_A = reg_rt;   
					reg_B = reg_rs[4:0];
					reg_C = reg_A >> reg_B;
				end
			endcase

			case(func) 6'b000011:  // sra
				begin
					reg_A = reg_rt;   
					reg_B = i_datain[10:6];
					reg_C = reg_A >>> reg_B;
				end
			endcase

			case(func) 6'b000111:  // srav
				begin
					reg_A = reg_rt;   
					reg_B = reg_rs[4:0];
					reg_C = reg_A >>> reg_B;
				end
			endcase

						
			case(func) 6'b100000:  // add
				begin
					reg_A = reg_rs;   
					reg_B = reg_rt;
					reg_C = reg_A + reg_B;
					OF = (~(reg_A[31]^reg_B[31])) & ( reg_A[31]^reg_C[31] );
				end
			endcase
			
			case(func) 6'b100001:  // addu
				begin
					reg_A = reg_rs;   
					reg_B = reg_rt;
					reg_C = reg_A + reg_B;
				end
			endcase 

			case(func) 6'b100010:  // sub
				begin
					reg_A = reg_rs;   
					reg_B = reg_rt;
					reg_C = reg_A - reg_B;
					OF = ( reg_A[31]^reg_B[31] ) & ( reg_A[31]^reg_C[31] );
				end
			endcase 

			case(func) 6'b100011:  // subu
				begin
					reg_A = reg_rs;   
					reg_B = reg_rt;
					reg_C = reg_A - reg_B;
				end
			endcase 


			case(func) 6'b100100: // and
				begin
					reg_A = reg_rs;
					reg_B = reg_rt;
					reg_C = reg_A & reg_B;
				end
			endcase

			case(func) 6'b100101: // or
				begin
					reg_A = reg_rs;
					reg_B = reg_rt;
					reg_C = reg_A | reg_B;
				end
			endcase

			case(func) 6'b100110: // xor
				begin
					reg_A = reg_rs;
					reg_B = reg_rt;
					reg_C = reg_A ^ reg_B;
				end
			endcase	

			case(func) 6'b100111: // nor
				begin
					reg_A = reg_rs;
					reg_B = reg_rt;
					reg_C = ~(reg_A | reg_B);
				end
			endcase	

			case(func) 6'b101010: // slt
				begin
					reg_B = reg_rs - reg_rt;
					SF = reg_B[31];
				end
			endcase


			case(func) 6'b101011: // sltu
				begin
					x = reg_rs;
					y = reg_rt;
					SF = (x < y);
				end
			endcase

		end
	endcase

	case(opcode) 6'b001000: // addi
		begin
			reg_A = reg_rs;
			reg_B = { { (16){ i_datain[15] } } ,imm};
			reg_C = reg_A + reg_B;
			OF = (~(reg_A[31]^reg_B[31])) & ( (reg_A[31]&reg_B[31])^reg_C[31] );
		end
	endcase

	case(opcode) 6'b001001: // addiu
		begin
			reg_A = reg_rs;
			reg_B = { { (16){ i_datain[15] } } ,imm};
			reg_C = reg_A + reg_B;
		end
	endcase

	case(opcode) 6'b000100: // beq
		begin
			reg_A = reg_rs;
			reg_B = reg_rt;
			ZF = (reg_A == reg_B); // == -> 1; != -> 0
		end
	endcase

	case(opcode) 6'b000101: // bne
		begin
			reg_A = reg_rs;
			reg_B = reg_rt;
			ZF = (reg_A == reg_B); 
		end
	endcase

	case(opcode) 6'b001010: // slti
		begin
			reg_B =  { { (16){ imm[15] } },imm };
			reg_A = reg_rs - reg_B;
			SF = reg_A[31];
		end
	endcase

	case(opcode) 6'b001011: // sltiu
		begin
			x = reg_rs;
			y = { { (16){ imm[15] } },imm };
			SF = x-y;
		end
	endcase

	case(opcode) 6'b001100: // andi
		begin
			reg_A = reg_rs;
			reg_B = { { (16){1'b0} } ,imm};
			reg_C = reg_A & reg_B;			
		end
	endcase

	case(opcode) 6'b001101: // ori
		begin
			reg_A = reg_rs;
			reg_B = { { (16){1'b0} } ,imm};
			reg_C = reg_A | reg_B;
			
		end
	endcase

	case(opcode) 6'b001110: // xori
		begin
			reg_A = reg_rs;
			reg_B = { { (16){1'b0} } ,imm};
			reg_C = reg_A ^ reg_B;
			
		end
	endcase

	case(opcode) 6'b100011: // lw
		begin
			reg_A = reg_rs;
			reg_B = { { (16){ i_datain[15] } } ,imm};
			reg_C = reg_A + reg_B;
		end
	endcase

	case(opcode) 6'b101011: // sw
		begin
			reg_A = reg_rs;
			reg_B = { { (16){ i_datain[15] } } ,imm};
			reg_C = reg_A + reg_B;
		end
	endcase

end


assign result = reg_C[31:0];
assign flags = { ZF, SF, OF};

endmodule