module ControlUnit(
	instruction,
	clock,
	resetn,
	reset1,
	reset2,
	reset3,
	En1,
	En2,
	En3,
	BrEq,
	BrLT,
	WBselR2,
	RegWEnR3,
	MemRWR2,
	ALUselR,
	BselR,
	AselR,
	BrUnR,
	ImmSel,
	PCSelR
);
	
	
	input [31:0]instruction;
	input BrEq, BrLT, clock, resetn,En1,En2,En3,reset1,reset2,reset3;
	reg PCSelTemp; //Temporary wire for PCSel for branch instruction decoder logic
	 reg RegWEn, MemRW, Bsel, Asel, BrUn, PCSel;
	 reg [3:0]ALUsel;
	 reg [1:0] WBsel;
	 output reg [2:0]ImmSel;
	
	
	wire [6:0]opcode = instruction[6:0];
	wire [2:0]func3 = instruction[14:12];
	parameter Iform = 7'b0010011, Rform = 7'b0110011, Sform = 7'b0100011, LWform = 7'b0000011, Brform = 7'b1100011, UJform = 7'b1101111, JALRform =  7'b1100111;
	
	always@(*) begin
	case(opcode)
	
	Rform: begin
	RegWEn = 1'b1; MemRW = 1'b0; Bsel = 1'b0; Asel = 1'b0; BrUn = 1'b0; PCSel = 1'b0; ALUsel= {instruction[30],instruction[14:12]}; ImmSel = 3'b0; WBsel = 2'b1;
	end
	
	Iform: begin
	RegWEn = 1'b1; MemRW = 1'b0; Bsel = 1'b1; Asel = 1'b0; BrUn = 1'b0; PCSel = 1'b0; ALUsel= {instruction[30],instruction[14:12]}; ImmSel = 3'b0; WBsel = 2'b1;
	end
	
	Sform: begin
	RegWEn = 1'b0; MemRW = 1'b1; Bsel = 1'b1; Asel = 1'b0; BrUn = 1'b0; PCSel = 1'b0; ALUsel= 4'b0; ImmSel = 3'b1; WBsel = 2'b0;
	end
	
	//This is not complete, ALUsel is hardcoded
	LWform: begin
	RegWEn = 1'b1; MemRW = 1'b0; Bsel = 1'b1; Asel = 1'b0; BrUn = 1'b0; PCSel = 1'b0; ALUsel= 4'b0; ImmSel = 3'b0; WBsel = 2'b0;
	end
	
	Brform: begin
	RegWEn = 1'b0; MemRW = 1'b0; Bsel = 1'b1; Asel = 1'b1; BrUn = 1'b0; PCSel = PCSelTemp; ALUsel= 4'b0; ImmSel = 3'b10; WBsel = 2'b0;
	end
	
	UJform: begin
	RegWEn = 1'b1; MemRW = 1'b0; Bsel = 1'b1; Asel = 1'b1; BrUn = 1'b0; PCSel = 1'b1; ALUsel= 4'b0; ImmSel = 3'b11; WBsel = 2'b10;
	end
	
	JALRform: begin
	RegWEn = 1'b1; MemRW = 1'b0; Bsel = 1'b1; Asel = 1'b0; BrUn = 1'b0; PCSel = 1'b1; ALUsel= 4'b0; ImmSel = 3'b0; WBsel = 2'b10;
	end
	
	default: begin
	RegWEn = 1'b0; MemRW = 1'b0; Bsel = 1'b0; Asel = 1'b0; BrUn = 1'b0; PCSel = 1'b0; ALUsel= 4'b0; ImmSel = 3'b0; WBsel = 2'b0;
	end
	
	endcase
	end
	
	///////////////////////////
	// Branch PCsel decoder logic
	always@(*) begin
	
	case(func3)
	3'b0: PCSelTemp = BrEq;
	3'b1: PCSelTemp = ~BrEq; //Branch not equal
	3'd2: PCSelTemp = BrLT;	//Branch Less than
	3'd3: PCSelTemp = ~BrLT; //Branch greater than equal
	default: PCSelTemp = 0;
	endcase
	
	end
	
	///
	wire RegWEnR, MemRWR;
	output BselR, AselR, BrUnR, PCSelR;
	output [3:0]ALUselR;
	
	wire [1:0] WBselR;
//	output [2:0]ImmSelR;
	
	wire RegWEnR2;
	output MemRWR2;
	output [1:0] WBselR2;
	
	output RegWEnR3;
	/////////////////////////////////////
	//First Stage Pipeline
	Register AselRegister(Asel, clock, resetn, En1, AselR);
	Register BselRegister(Bsel, clock, resetn, En1, BselR);
	//Register ImmSelRegister(ImmSel, clock, resetn, ImmSelR); No delay is required for immGenerator
	Register ALUselRegister(ALUsel, clock, resetn, En1, ALUselR);
	Register WBselRegister(WBsel, clock, resetn, En1, WBselR);
	Register MemRWRegister(MemRW, clock, reset1, En1, MemRWR);
	Register RegWEnRegister(RegWEn,clock,reset1, En1, RegWEnR);
	Register PCSelRegister(PCSel,clock,resetn, En1, PCSelR);
	
	/////////////////////////////////////
	//Second stage Pipeline
	Register WBselRegister2(WBselR, clock, resetn, En2, WBselR2);
	Register MemRWRegister2(MemRWR, clock, reset2, En2, MemRWR2);
	Register RegWEnRegister2(RegWEnR,clock,reset2, En2, RegWEnR2);
	

	////////////////////////////////////
	//Third Stage Pipeline
	Register RegWEnRegister3(RegWEnR2,clock,reset3, En3, RegWEnR3);
endmodule
