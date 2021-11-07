module ImmGenerator(
	instruction,
	immSel,
	immOut
);
	input [31:0]instruction;
	input [2:0]immSel;
	output reg [31:0]immOut;

	wire [31:0]immI,immS,immBr, immUJ;
	
	//Computing Immediates for I, S and Br format
	assign immI = {{20{instruction[31]}},instruction[31:20]};
	assign immS = {{20{instruction[31]}},instruction[31:25],instruction[11:7] };
	assign immBr = {{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
	assign immUJ = {{12{instruction[31]}},instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};
	
	always@(*) begin
	
	case(immSel)
	3'b0: immOut = immI;
	3'b1: immOut = immS;
	3'd2: immOut = immBr;
	3'd3: immOut = immUJ;
	default: immOut = 32'b0;
	endcase
	
	end
	
endmodule
