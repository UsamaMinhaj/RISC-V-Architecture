module DataMemory
#(parameter DataMemory_width = 8)
(
	address,
	clock,
	data,
	wren,
	resetn,
	q
);
	input	[DataMemory_width-1:0]  address;
	input	  clock;
	input	[31:0]  data;
	input	  wren;
	output	[31:0]  q;
	input resetn;
	
	reg [31:0] ram[DataMemory_width**2 - 1:0]; //32 bit data with 256 spaces
	
	//assign address = (~wren & read_address) | (wren & write_address); 
	
	always@(posedge clock or negedge resetn) begin
	if(~resetn)
	ram[0] <= 0; 
	else if(wren)
	ram[address] <= data;
	end
	assign q = ram[address];
	
endmodule
