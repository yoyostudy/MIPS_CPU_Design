/*
 * Module Name : WriteBack.v
 * Usage : This Module implements the Register Write Back process
 *         that is used for pipeline CPU (stage V)
 * -------------------------------------------------------------
 * This module serves for Arithmetic/Logic/Shift/slt/lw instructions
 * 
 * The Write_Register address is already implemented in Decode Stage
 * (by RegFile component) as wire Rw
 * -----------------------------------------------------------------
 * Input: CLOCK, ALUout, ReadData, control signals(MemtoReg, RegWr)
 */

module WriteBack
 	(
      input CLOCK
    , input[31:0] ALUoutW
    , input[31:0] ReadDataW
    , input RegWriteW
    , input MemtoRegW
    , input[4:0] WriteRegW
 	);

      reg[31:0] WD;
      wire[31:0] busA,busB;

      always@(*) begin
      	if (MemtoRegW) WD = ReadDataW;
      	else WD = ALUoutW;
      end

RegFile writeReg(CLOCK, RegWriteW, 5'b00000, 5'b00000, WriteRegW, WD, busA, busB);

endmodule