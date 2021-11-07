module ALU(
	RS1,
	RS2,
	ALUsel,
	ALUout
);

	input [31:0]RS1, RS2;
	input [3:0] ALUsel;
	output reg[31:0]ALUout;

	//Definining all the functions of ALU
	parameter Add = 4'b0,And = 4'b111, Or = 4'b110, Xor = 4'b100, srl = 4'b101, sra = 4'b1101, sll = 4'b1, slt = 4'b10, Sub = 4'b1000, mul = 4'b1111;//Special code for mul 
	//Special code for mul 
	always@(*) begin //ALU select mux 
	case(ALUsel)
	
	Add: ALUout = RS1 + RS2;
	And: ALUout = RS1 & RS2;
	 Or: ALUout = RS1 | RS2;
	Xor: ALUout = RS1 ^ RS2;
	srl: ALUout = RS1 >> RS2[4:0];
	sra: ALUout = RS1 >>> RS2[4:0];	
	sll: ALUout = RS1 << RS2[4:0];
	slt: ALUout = RS1 < RS2 ? 32'b1 : 32'b0 ;
	Sub: ALUout = RS1 - RS2;
   mul: ALUout = RS1*RS2;
	default: ALUout = 32'b0;
	endcase
	end
	
endmodule
