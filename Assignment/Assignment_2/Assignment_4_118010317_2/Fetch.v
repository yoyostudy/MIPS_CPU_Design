/*
 * Module Name : Fetch.v
 * Usage : This module implements the Fetch stage
 *         used for pipelined CPU (stage I)
 * -----------------------------------------------
 * At the rising edge of the clock, if input data PCIn
 * signal changed, PC will update, and pass to the 
 * output wire PCF --- implemented by PC
 *  
 * The output wire PCF by PC connect to the InstructionRAM
 * as Input. PCF also connect to an ALU as input
 * 
 * Once InstructionRAM delects any update on the input 
 * it will generate instruction automatically and pass 
 * to the output wire InstrD --- Implemented by InstrctionRAM
 * 
 * In the same time, PCF will pass to an ALU component
 * and increment by 4, the result PCplus4 will be as output
 * -----------------------------------------------------
 * Input : CLOCK, PCIn 
 * Output: InstrD, PCPlus4D
 */

module Fetch
  (
      input CLOCK
    , input[31:0] PCInF
    , output[31:0] InstrF
    , output[31:0] PCplus4F
  );

  wire[31:0] PCF;

    PC get_PC(CLOCK,PCInF,PCF);  
    InstructionRAM get_Instr(PCF, InstrF);

assign PCplus4F = PCF + 4;

endmodule

/*
 * Module name: PC
 * Usage: This module implements the function of PC 
 * -------------------------------------------------
 * At each rising edge of the clock, PC will update
 * to the input address passed to the PC component
 * 
 * This module will also implements the PC input address
 * selction based on the control signal
 * -------------------------------------------------
 */

module PC 
    (
          input CLOCK
        , input[31:0] PCInput
        , output[31:0] PCOutput
    );

    reg[31:0] reg_PC;

    always @(negedge CLOCK, PCInput) begin
        reg_PC <= PCInput;
    end

    assign PCOutput = reg_PC;


endmodule


/*
 * FILE NAME: InstructionRAM.v
 * Usage: Load Instruction & Fetch Instruction automatically 
 * ---------------------------------------------------------
 * Initially the module will load the machine code 
 * and store them in InstructionRAM
 * Each Instruction will be store in 4 blocks
 *
 * Each time the input PCF update, the InstructionRAM will
 * automatically fetch the instruction using the address PCF.
 * ---------------------------------------------------------
 * InstructionRAM is read only.
 * Input contains: （Test_machinecode_file）, PC
 * Output contains: Instruction
 * ---------------------------------------------------------
 * parameter settings:
 * set Instruction_num = 256 temporarily
 * i.e. InstructionRAM size to be 4*Instruction_num temporarily. 
 * n,j represents the address index of original instruction 
 * and RAM respectively; (2**n)< num; (2**j)< 4*num are required       
 */

`timescale 100fs/100fs
module InstructionRAM   
    (   input [31:0] FETCH_ADDRESS
      , output reg [31:0] RD
    );

  // for initialize
  reg [31:0] RAM_temp [0:2**8-1]; 
  reg [7:0]  RAM [0:2**10-1]; 
  reg [7:0]  n;
  reg [9:0]  j;
  reg [31:0] temp;
  
  // This part load the machine code into RAM
  // Every 32-bit instruction will be stored in 4 blocks
  initial 
  begin
    $readmemb("instructions.bin",RAM_temp);
    for ( n = 0; n < 2**8-1; n = n+1) 
    begin
      temp = RAM_temp[n];
      RAM[4*n  ] = temp[7:0];
      RAM[4*n+1] = temp[15:8];
      RAM[4*n+2] = temp[23:16];
      RAM[4*n+3] = temp[31:24];
    end
  
  // initial display of Machine Code
  /*
    $display(" Machine Code store in the Instruction RAM ----");
    for ( j = 0; j < 2**10-1 ; j = j+1)
    $display("count: %b -- Instruction %b", j, RAM[j]);
  */
  end
  
  // This part parse the instruction from the address
  // Every time when FETCH_ADDRESS change, temp_DATA will change
  always @(FETCH_ADDRESS) 
    begin
    RD = { {RAM[FETCH_ADDRESS+3]},{RAM[FETCH_ADDRESS+2]},{RAM[FETCH_ADDRESS+1]},{RAM[FETCH_ADDRESS]} };
    end

endmodule




