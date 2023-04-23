/*
 * Module Name : DataMem.v
 * Usage : This module implements the memory access process
 *         which is used for pipeline CPU (stage IV)
 * --------------------------------------------------------
 * This module is mainly for lw/sw 
 * 
 * For lw: it will read the ALUout as the address of the 
 * DataMemory, then automatically pass the data in the 
 * address to the output wire RD
 * 
 * For sw: At the rising edge of CLOCK, if MemWrite == 1
 * it will write the busB as input data given the ALUout 
 * as the address
 * --------------------------------------------------------
 * Input : CLOCK, ALUout, busB, WriteData, MemWrite
 * Output : ReadData
 * --------------------------------------------------------
 * Module Component : DataMem
 */


 module DataMem
 	(
          input CLOCK
        , input RegWriteMin
        , input MemtoRegMin
        , input [31:0] PCupdateMin
        , input [4:0]  WriteRegMin
        , input [31:0] ALUoutMin
        , input MemWriteM
        , input[31:0] WriteDataM

        , output [31:0] ALUoutMout
        , output  RegWriteMout
        , output  MemtoRegMout
        , output [31:0] PCupdateMout
        , output [4:0] WriteRegMout
        , output [31:0] ReadDataM
 	);

    reg[7:0]  DMem[0:2**14-1];
    
    reg[31:0] temp_data;
    reg[13:0] n;
    reg[9:0] j;
    reg[9:0] address;
    reg[31:0] reg_rdata;

    initial begin
        for ( n = 0; n<2**14-1; n = n+1) DMem[n] = 8'b0000_0000;
    end

    always@(*) begin
        if (ALUoutMin[1:0] == 2'b00)  address = ALUoutMin;
        else address = { { ALUoutMin[31:2]} , {2'b00} } + 3'b100;
        reg_rdata = { { DMem[address+3]}, {DMem[address+2]},{DMem[address+1]},{DMem[address]} };
    end

    always@(posedge CLOCK) begin
        if (MemWriteM) begin
            DMem[address] = WriteDataM[7:0];
            DMem[address+1] = WriteDataM[15:8];
            DMem[address+2] = WriteDataM[23:16];
            DMem[address+3] = WriteDataM[31:24];
        end

    end

    assign ReadDataM = reg_rdata ;
    assign RegWriteMout = RegWriteMin;
    assign MemtoRegMout = MemtoRegMin;
    assign PCupdateMout = PCupdateMin;
    assign ALUoutMout = ALUoutMin;
    assign WriteRegMout = WriteRegMin;

 endmodule