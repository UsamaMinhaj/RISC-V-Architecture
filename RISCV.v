module RISCV(
	clock,
	resetn,
	instruction, RS1, RS2,   ALUin1, ALUin2, instructionR, pc, ALUOut,WBselOut,DataMemOut,RegWEnout
	//WBselOut, RegWEnout, rddR3out, immSelout,pcSelout , ALUOut, DataMemOut, immOut,
);

	input clock, resetn;
	output [7:0]pc;
	output [31:0]instruction, RS1, RS2, ALUOut;
	output [31:0]	DataMemOut;
	wire [31:0]	immOut;
	output reg [31:0]  ALUin1, ALUin2; 
	output reg [31:0]WBselOut;
	output RegWEnout;
	wire pcSelout;
	wire  [2:0]immSelout;
	wire [4:0]rddR3out;
	//WBselOut, RegWEnout, rddR3out, immSelout,pcSelout , ALUOut, DataMemOut, immOut;
	assign rddR3out = rddR3;
	
	//////////////////////////
	//Pipelining Register Control
	//Number represents the stage of pipeline
	reg En1,En2,En3;	
	wire En4 = 1,En5 = 1;
	reg control_reset1;
	wire control_reset2 = resetn, control_reset3 =  resetn;
	
	
	
	//////////////////////////'
	//Control Wires
	reg  BrEq, BrLT;
	wire RegWEn, MemRW, Bsel, Asel, BrUn, PCSel;
	wire [3:0]ALUsel;
	wire [1:0] WBsel;
	wire [2:0]ImmSel;
	
	////////////////////////////
	output [31:0]instructionR;
	wire  [31:0]RS1R, RS2R, immOutR, ALUOutR, RS2R2, WBselOutR, instructionR2;
	wire [4:0]rddR, rddR2, rddR3;
	wire [7:0]pcR,pcR2;
	
	assign RegWEnout = RegWEn;
	assign immSelout = ImmSel;
	assign pcSelout = PCSel;
	
	///////////////////////////////
	wire [4:0]rs1,rs2;
	assign rs1 = instructionR[19:15];
	assign rs2 = instructionR[24:20];
	
	////////////////////////////
	ControlUnit ControlUnit(instructionR, clock, resetn, control_reset1, control_reset2, control_reset3, En3, En4, En5, BrEq, BrLT, WBsel, RegWEn, MemRW, ALUsel, Bsel, Asel, BrUn, ImmSel, PCSel);
	ProgramCounter ProgramCounter(clock,resetn,En1,PCSel,ALUOut, pc);
	InstructionMemory Imem(pc, resetn, instruction);
	RegFile Registers(clock, instructionR[19:15], instructionR[24:20], rddR3, WBselOutR, RegWEn, resetn, RS1, RS2);	
	ImmGenerator ImmGen(instructionR, ImmSel, immOut);
	ALU ALU(ALUin1,ALUin2,ALUsel,ALUOut);
	DataMemory DataMemory(ALUOutR[5:0], clock, RS2R2, MemRW, resetn, DataMemOut);
	////////////////////////////
	
	////////////////////////////
	Register #(5) rddRegister(instructionR[11:7], clock, resetn, 1'b1, rddR);
	Register #(5) rddRegister2(rddR, clock, resetn, 1'b1, rddR2);
	Register #(5) rddRegister3(rddR2, clock, resetn, 1'b1, rddR3);
	
	Register pcRegister(pc, clock, resetn, En3, pcR);
	Register pcRegister2(pcR, clock, resetn, En4, pcR2);
	
	////////////////////////////
	Register InstructionMemoryRegister(instruction,clock,resetn,En2,instructionR);
	
	Register InstructionMemoryRegister2(instruction,clock,resetn,En3,instructionR2);
	Register RS1Register(RS1Mux,clock,resetn,En3,RS1R);
	Register RS2Register(RS2Mux,clock,resetn,En3,RS2R);
	Register ImmGenRegister(immOut,clock,resetn,En3,immOutR);
	
	Register ALURegister(ALUOut,clock,resetn,En4,ALUOutR);
	Register RS2Register2(RS2R,clock,resetn,En4,RS2R2);
	//Register RS1Register(RS1R,clock,resetn,RS1R);
	
	Register WBSelOutRegister(WBselOut,clock,resetn,En5,WBselOutR);
	////////////////////////////
	
	//Branch Comparator for branch instructions
	always@(*) begin
	
	if(RS1Mux == RS2Mux) begin
	BrEq = 1;
	BrLT = 0;
	end
	else if(RS1Mux < RS2Mux) begin
	BrEq = 0;
	BrLT = 1;
	end
	else begin
	BrEq = 0;
	BrLT = 0;
	end
	
	end
	////////////////////////////
	
	////////////////////////////
	//Mux for ASel
	always@(*) begin
	
	case(Asel) 
	1'b0: ALUin1 = RS1R;
	1'b1: ALUin1 = pcR2;	
	endcase
	
	end
	
	//Mux for BSel
	always@(*) begin
	
	case(Bsel) 
	1'b0: ALUin2 = RS2R;
	1'b1: ALUin2 = immOutR;	
	endcase
	
	end
	////////////////////////////
	
	
	////////////////////////////
	//Mux for WBsel
	always@(*) begin
	case(WBsel)
	2'b0: WBselOut = DataMemOut;
	2'b1: WBselOut = ALUOutR;
	2'd2: WBselOut = pc + 3'd4;
	default: WBselOut = 32'b0;
		
	endcase
	end
	////////////////////////////
	
	
	////////////////////////////
	//Data hazard for R and I format
	reg [31:0]RS1Mux,RS2Mux;
	 
	//Mux for RS1
	always@(*) begin
	if(rs1 == rddR && (instructionR2[6:0] != LWform ) && counter == 0) 
	RS1Mux = ALUOut;
	else if(rs1 == rddR2 &&  counter == 0)
	RS1Mux = WBselOut;
	else if(rs1 == rddR3 && counter == 0)
	RS1Mux = WBselOutR;
	else
	RS1Mux = RS1;
	end
	
	//Mux for RS2
	always@(*) begin
	
	if(rs2 == rddR && (instructionR2[6:0] != LWform ) &&  counter == 0) 
	RS2Mux = ALUOut;
	else if(rs2 == rddR2 && counter == 0)
	RS2Mux = WBselOut;
	else if(rs2 == rddR3 && counter == 0)
	RS2Mux = WBselOutR;
	else
	RS2Mux = RS2;
	
	end
	
	////////////////////////////
	
	
	////////////////////////////
	//Data stalling
	parameter LWform = 7'b0000011, Iform = 7'b0010011, Rform = 7'b0110011;
	always@(*) begin
	
	if(LWform == instructionR2[6:0] && rs1 == rddR) begin
	En1 = 0;	En2 = 0;	En3 = 0;control_reset1=0;
	end
	else if(PCSel == 1 || counter == 1) begin
	control_reset1 = 0;En1 = 1;En2 = 1;	En3 = 1;
	end
	else begin
	En1 = 1;	En2 = 1;	En3 = 1;control_reset1=resetn;
	end
	end
	////////////////////////////
	
	////////////////////////////
	// Branch and Jump Hazard
	reg [1:0]counter;
	always@(posedge clock) begin
	if(PCSel == 1 || counter == 1)                         
	counter <= counter + 1;
	else 
	counter<=0;
	end
	
endmodule


////////////////////////Register////////////////////////////
module Register
 #(parameter width = 32)
(
	input [width - 1:0]D,
	input clock, resetn, En,
	output reg [width - 1:0]Q
);
	
	always@(posedge clock or negedge resetn) begin
	
	if(~resetn)
	Q <= 1'b0;
	else if(En)
	Q <= D;
	
	end
	

endmodule
