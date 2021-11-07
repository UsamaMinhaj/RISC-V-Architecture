module InstructionMemory
#(Address_width = 6)
(pc, resetn, instruction);
	
	input resetn; //Resetting all data
	input [Address_width-1+2:0]pc; //2 is added because we want to make pc 32 bit addressable
	output [31:0] instruction;
	
	reg [31:0] ROM [2**Address_width - 1:0]; //64 memory spaces. Can be accessed by 6 bit pc
	
	//Memory Space for writing ROM
	initial begin
	//ROM[0] = 32'h00400213;

		
	ROM[0] = 32'h00600093;
	ROM[1] = 32'h00100193;
	ROM[2] = 32'h00100113;
	ROM[3] = 32'h42117133;
	//ROM[4] = 32'h00000033;
	//ROM[5] = 32'h00000033;
	ROM[4] = 32'h403080B3;
	ROM[5] = 32'hFE009CE3;
	ROM[6] = 32'h00010133;
//	ROM[7] = 32'h00402183;
//	ROM[8] = 32'h00000033;
//	ROM[9] = 32'h00000033;
//	ROM[10] = 32'h004182B3;	
	
	end

	assign instruction = ROM[pc[Address_width:2]];

endmodule

module ProgramCounter
#(Address_width = 6)
(
	clock,
	resetn,
	En,
	PCSel,
	ALU,
	pc
);
	input clock, resetn,PCSel,En;
	input [31:0]ALU;
	output [Address_width-1+2:0]pc; //2 is added because we want to make pc 32 bit addressable
	reg [Address_width-1+2:0]counter; //2 is added because we want to make pc 32 bit addressable
	
	
	always@(posedge clock or negedge resetn) begin
	if(~resetn)
	counter <= 0;
	else if(En) begin
					if(PCSel == 0)
					counter <= pc + 3'b100; 
					else
					counter <= ALU;	
					end
	end
	assign pc = counter;
	
endmodule
