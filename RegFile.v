module RegFile(
	clock,
	rs1,
	rs2,
	rdd,
	Data,
	MemREn,
	resetn,
	Rs1, //Data 1 out
	Rs2 //Data 2 out
);
	input [4:0]rs1, rs2, rdd;
	input MemREn, resetn, clock;
	input [31:0]Data;
	
	output [31:0]Rs1, Rs2;
	
	//32 registers of regFile
	reg [31:0]Registers [31:0];
	
	//////////////////
	//MUX for rs1
	assign Rs1 =  Registers[rs1];
	
	//////////////////
	//MUX for rs2
	assign Rs2 = Registers[rs2];

	///////////////////////////////////////
	//Decoder for writing data in Registers
	always@(posedge clock or negedge resetn) begin
	if(~resetn) begin
	integer i;
	for(i=1;i<32;i=i+1) 
	Registers[i] <= 32'b0;
	end
	else if(MemREn && rdd != 5'b0) 
	Registers[rdd] <= Data;
	
	end
	
endmodule
