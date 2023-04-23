module pipelinedCPU;

reg CLOCK;

reg [31:0] RegFILE [0:31];

// Input for Fetch
reg[31:0] PCInF;   
// Output for Fetch  
wire[31:0] InstrF;    
wire[31:0] PCplus4F; 

// pipelined reg between stage 1 & 2
reg[31:0] InstrF2D;  
reg[31:0] PCplus4F2D;

// Input for Decode 
wire[31:0] InstrD;    
wire[31:0] PCplus4Din;
// Output for Decode
wire RegWriteD;
wire MemWriteD;
wire MemtoRegD;
wire RegDstD;
wire[2:0] nPC_selD;
wire[3:0] ALUCtrD;
wire[4:0] rtD;
wire[4:0] rdD;
wire[31:0] ExtImmD;
wire[25:0] targetD;
wire[4:0] saD;
wire[31:0] PCplus4Dout;
wire[31:0] busAD;
wire[31:0] busBD;

wire[4:0] rsD;

// pipelined reg between stage 2 & 3
reg MemWriteD2E;
reg RegWriteD2E;
reg MemtoRegD2E;
reg[2:0] nPC_selD2E;
reg[3:0] ALUCtrD2E;
reg ALUSrcD2E;
reg RegDstD2E;
reg[4:0] saD2E;
reg[31:0] busAD2E;
reg[31:0] busBD2E;
reg[31:0] ExtImmD2E;
reg[4:0] rtD2E;
reg[4:0] rdD2E;
reg[31:0] PCplus4D2E;
reg[25:0] targetD2E;

// Input for Excecute
wire MemWriteEin ;
wire RegWriteEin ;
wire MemtoRegEin ;
wire[2:0] nPC_selE;
wire[3:0] ALUCtrE ;
wire ALUSrcE ;
wire RegDstE ;
wire [4:0] saE ;
wire [31:0] busAE ;
wire [31:0] busBE ;
wire [31:0]ExtImmE ;
wire [31:0]rtE ;
wire [4:0] rdE ;
wire [25:0] targetE;
wire [31:0] PCplus4Ein;
// Output for Excecute
wire MemWriteEout ;
wire RegWriteEout ;
wire MemtoRegEout ;
wire[31:0] ALUoutE;
wire[31:0] WriteDataE;
wire[31:0] PCupdateE;
wire[4:0] WriteRegE;

// pipelined registers between stage 3 & 4
reg MemWriteE2M;
reg RegWriteE2M;
reg MemtoRegE2M;
reg[31:0] ALUoutE2M;
reg[31:0] PCupdateE2M;
reg[4:0] WriteRegE2M;
reg[31:0] WriteDataE2M;

// Input for stage 4
wire RegWriteMin;
wire MemtoRegMin;
wire[31:0] PCupdateMin;
wire[4:0] WriteRegMin;
wire[31:0] ALUoutMin;
wire MemWriteM;
wire[31:0] WriteDataM;
// output for stage 4
wire[31:0] ALUoutMout;
wire[31:0] ReadDataM;
wire RegWriteMout;
wire MemtoRegMout;
wire[31:0] PCupdateMout;
wire[4:0] WriteRegMout; 

//pipelined registers between stage 4 & 5
reg[31:0] ALUoutM2W;
reg[31:0] ReadDataM2W;
reg RegWriteM2W;
reg MemtoRegM2W;
reg[4:0] WriteRegM2W; 

// Input for stage 5;
wire[31:0] ALUoutW;
wire[31:0] ReadDataW;
wire RegWriteW;
wire MemtoRegW;
wire[4:0] WriteRegW; 


// storing the output for the previous stage 
// to the pipeline registers
always@(posedge CLOCK) begin
	// stage 1 -> 2
	InstrF2D <= InstrF;
	PCplus4F2D <= PCplus4F;

	// stage 2 -> 3
	MemWriteD2E <= MemWriteD;
	RegWriteD2E <= RegWriteD;
	MemtoRegD2E <= MemtoRegD;
	nPC_selD2E <= nPC_selD;
	ALUCtrD2E <= ALUCtrD;
	ALUSrcD2E <= ALUSrcD;
	RegDstD2E <= RegDstD;
	saD2E <= saD;
	busAD2E <= busAD;
	busBD2E <= busBD;
	ExtImmD2E <= ExtImmD;
	rtD2E <= rtD;
	rdD2E <= rdD;
	PCplus4D2E <= PCplus4Dout;
	targetD2E <= targetD;

	// stage 3 -> 4
	MemWriteE2M <= MemWriteEout;
	RegWriteE2M <= RegWriteEout;
	MemtoRegE2M <= MemtoRegEout;
	ALUoutE2M   <= ALUoutE;
	PCupdateE2M <= PCupdateE;
	WriteRegE2M <= WriteRegE;
	WriteDataE2M <= WriteDataE;

	// stage 4 -> 5
	ALUoutM2W  <= ALUoutMout;
	ReadDataM2W <= ReadDataM;
	RegWriteM2W <= RegWriteMout;
	MemtoRegM2W <= MemtoRegMout;
	WriteRegM2W <= WriteRegMout;

end

// pass the signals from the pipelined registers
// as input wire to the next stage

// stage 1 -> 2
assign InstrD = InstrF2D;
assign PCplus4Din = PCplus4F2D;
// stage 2 -> 3
assign MemWriteEin = MemWriteD2E;
assign RegWriteEin = RegWriteD2E;
assign MemtoRegEin = MemtoRegD2E;
assign nPC_selE  = nPC_selD2E;
assign ALUCtrE   = ALUCtrD2E;
assign ALUSrcE   = ALUSrcD2E;
assign RegDstE   = RegDstD2E;
assign	saE      = saD2E;
assign busAE     = busAD2E;
assign busBE     = busBD2E;
assign ExtImmE   = ExtImmD2E;
assign rtE       = rtD2E;
assign rdE 		 = rdD2E;
assign PCplus4Ein = PCplus4D2E;
assign targetE   = targetD2E;
// stage 3 -> 4
assign RegWriteMin = RegWriteE2M;
assign MemtoRegMin = MemtoRegE2M;
assign PCupdateMin = PCupdateE2M;
assign WriteRegMin = WriteRegE2M;
assign MemWriteM = MemWriteE2M;
assign ALUoutMin = ALUoutE2M;
assign WriteDataM = WriteDataE2M; 
// stage 4 -> 5
assign ALUoutW   = ALUoutM2W;
assign ReadDataW = ReadDataM2W;
assign RegWriteW = RegWriteM2W;
assign MemtoRegW = MemtoRegM2W;
assign WriteRegW = WriteRegM2W;

reg[7:0] idx;
reg[31:0] WD;

integer i,j,k;

initial begin
	for (i = 0; i < 2**5 -1 ; i = i+1)  begin
    RegFILE[i] = 32'h0000_0000;     
    end
end


Fetch Fetch_instruction( CLOCK, PCInF, InstrF, PCplus4F);
Decode Decode_instruction( InstrD, PCplus4Din, PCplus4Dout,
	RegWriteD, MemWriteD, MemtoRegD, nPC_selD, RegDstD, ALUSrcD, ALUCtrD
	, ExtImmD, rsD, rtD, rdD, saD, targetD);
assign busAD = RegFILE[rsD];
assign busBD = RegFILE[rtD];


Excecute Excecute_instruction( MemWriteEin , RegWriteEin , MemtoRegEin ,nPC_selE , ALUCtrE 
	, ALUSrcE , RegDstE ,saE ,busAE , busBE ,ExtImmE ,rtE , rdE ,targetE,PCplus4Ein              
	,MemWriteEout,RegWriteEout, MemtoRegEout,ALUoutE, PCupdateE,WriteRegE, WriteDataE); 
DataMem MemoryAccess( CLOCK
	, RegWriteMin
	, MemtoRegMin
	, PCupdateMin
	, WriteRegMin
	, ALUoutMin
	, MemWriteM
	, WriteDataM
	, ALUoutMout
	, RegWriteMout
	, MemtoRegMout
	, PCupdateMout
	, WriteRegMout
	, ReadDataM);

// WriteBack Process

always@(*) begin
  if (MemtoRegW) WD = ReadDataW;
  	else WD = ALUoutW;
  end

always@(negedge CLOCK)
	begin
	    if (RegWriteW) RegFILE[WriteRegW] <= WD;
	end

initial begin
	$dumpfile("pipeline.vcd");
	$dumpvars(CLOCK);
	CLOCK <= 1;
	PCInF <= 0;
	#5CLOCK <= 0;

	#5CLOCK <= 1;
	PCInF <= PCplus4F;
	#5CLOCK <= 0;

	for (idx = 0; idx < 2**7-1; idx = idx + 1) begin 

		if (InstrD == 32'b1111_1111_1111_1111_1111_1111_1111_1111) begin
				#5CLOCK <= 1;
				#5CLOCK <= 0;
				#5CLOCK <= 1;
				#5CLOCK <= 0;
				#5CLOCK <= 1;
				#5CLOCK <= 0;

				for ( k = 0; k < 2**9-1; k = k+1) begin
					$display("DataMemory %d data %b", k, {{MemoryAccess.DMem[4*k+3]} ,{MemoryAccess.DMem[4*k+2]} ,{MemoryAccess.DMem[4*k+1]} ,{MemoryAccess.DMem[4*k]} });
				end

			$finish;
			
		end

		else begin
			#5 CLOCK <= 1;
			
			if (nPC_selD[1:0] == 2'b00) PCInF <= PCplus4F;
			else if (nPC_selD[2] == 1'b1) begin
				#5 CLOCK <= 0;
				#5 CLOCK <= 1;
				PCInF <= busAD;
			end
			else begin
				#5CLOCK <= 0;
				#5CLOCK <= 1;
				PCInF <= PCupdateE;
			end
			
			#5CLOCK <= 0;
		end
	
	end	

end



endmodule