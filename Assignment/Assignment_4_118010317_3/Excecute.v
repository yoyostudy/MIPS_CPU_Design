/*
 * Module Name : Excecute.v
 * Usage: This module implements the Execute Stage
 *        used for piplined CPU (stage III)
 * ------------------------------------------------
 * The execute stage will perform ALU operation so 
 * as to get the ALU result and the branch address
 * ------------------------------------------------
 * This part contains two ALU:
 *
 * ALU1  (busA,busB,sa,Extimm --> ALUout, ZERO, (OF))
 *    -- For Arithmetic/Logic/Shift Instructions
 *    -- For Unconditionally Jump(beq/bne/slt) = "sub"
 *    -- For lw/sw = ("SUB")
 * 
 * ALU2  (PCplus4, target --> PCJump)
 *    -- For j, jal
 * 
 * ALU3 (PCplus4, ExtImm --> PCBranch)
 *    -- For lw, sw
 * 
 * PC update will also be implemented in this module
 * ------------------------------------------------
 * Input : busA, busB, sa, ExtImm, PCplus4, controlsigs
 * Output : ALUout, ZERO_flag, WriteData, PCBranch
 * ------------------------------------------------
 * For the consideration of Hazards, slt may do some 
 * adjustment
 */


 module ALU1
    (   
          input[31:0] busA 
        , input[31:0] busB
        , input[4:0] sa
        , input[31:0] Extimm
        , input ALUSrc
        , input[3:0] ALUCtr
        , output[31:0] ALUout
        , output ZERO
    );

    reg[31:0] SrcA;
    reg[31:0] SrcB;
    reg[31:0] reg_out;
    reg reg_Zero;

    always@(*) begin
        if ( ALUCtr[3] & (~ALUCtr[0]) ) SrcA = sa;
        else SrcA = busA;
    end 

    always@(*) begin
        if (ALUSrc) SrcB = Extimm;
        else SrcB = busB;
    end

    always@(*) begin
        case (ALUCtr) 
        4'b0000: reg_out = SrcA + SrcB;
        4'b0001: reg_out = SrcA - SrcB;
        4'b0011: reg_out = (SrcA - SrcB) >>> 31; //($signed(SrcA) < $signed(SrcB));
        4'b0100: reg_out = SrcA & SrcB;
        4'b0101: reg_out = SrcA | SrcB;
        4'b0110: reg_out = SrcA ^ SrcB;
        4'b0111: reg_out = ~(SrcA | SrcB);
        endcase

        case (ALUCtr[3:1]) 
        3'b100: reg_out = SrcB << SrcA;
        3'b101: reg_out = SrcB >> SrcA;
        3'b110: reg_out = ( $signed(SrcB) ) >>> SrcA;
        endcase

        reg_Zero = (reg_out == 0);

    end

    assign ALUout = reg_out;
    assign ZERO = reg_Zero;

 endmodule


module ALU2
    (

          input [31:0] PCplus4
        , input[25:0] target
        , output[31:0] PCJump
    );

    reg[31:0] reg_pcJump;

    always@(*) begin
        reg_pcJump = { {PCplus4[31:28]}, target, {2'b00} } ;
    end

    assign PCJump = reg_pcJump;

endmodule

module ALU3
    (
          input[31:0] PCplus4
        , input[31:0] ExtImmE
        , output[31:0] PCBranch

    );

    reg[31:0] reg_PCBranch;

    always @(*) begin
        reg_PCBranch = PCplus4 + (ExtImmE <<2);

    end 

    assign PCBranch = reg_PCBranch;

endmodule

module Excecute
    (
          input MemWriteEin 
        , input RegWriteEin 
        , input MemtoRegEin 
        , input[2:0] nPC_selE 
        , input[3:0] ALUCtrE 
        , input ALUSrcE 
        , input RegDstE 
        , input[4:0] saE 
        , input[31:0] busAE 
        , input[31:0] busBE 
        , input [31:0]ExtImmE 
        , input [31:0]rtE 
        , input[4:0] rdE 
        , input[25:0] targetE
        , input [31:0] PCplus4Ein
              
        , output MemWriteEout
        , output RegWriteEout
        , output MemtoRegEout
        , output[31:0] ALUoutE
        , output[31:0] PCupdateE
        , output[4:0] WriteRegE
        , output[31:0] WriteDataE
    );

wire[31:0] PCBranch; 
wire[31:0] PCJump; 
wire ZERO;
reg[31:0] reg_PCupdate;
reg[4:0] reg_WriteRegE;

ALU1 run_ALU1( busAE, busBE, saE, ExtImmE, ALUSrcE, ALUCtrE, ALUoutE, ZERO);
ALU2 run_ALU2( PCplus4Ein, targetE, PCJump);
ALU3 run_ALU3( PCplus4Ein, ExtImmE, PCBranch);

always@(*) begin
    case (nPC_selE[1])
        1'b1: if (ZERO ^ nPC_selE[0]) reg_PCupdate = PCBranch; // beq,bne
        1'b0: 
        begin
            if (nPC_selE[0]) reg_PCupdate = PCJump;    // j, jal
            else if (nPC_selE[2]) reg_PCupdate = busAE;    // jr
            else reg_PCupdate = PCplus4Ein;
        end
    endcase

    case (RegDstE)
        1'b0: reg_WriteRegE = rtE;
        1'b1: reg_WriteRegE = rdE;
    endcase
end


assign PCupdateE = reg_PCupdate;

assign MemWriteEout = MemWriteEin;
assign RegWriteEout = RegWriteEin;
assign MemtoRegEout = MemtoRegEin;
assign WriteRegE = reg_WriteRegE;
assign WriteDataE = busBE;



endmodule