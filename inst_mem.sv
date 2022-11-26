module inst_mem (
	input logic clk, nrst,
	input logic inst_mem_wren,
	input logic [31:0] inst_mem_write_addr, inst_mem_write_data,
	input logic [31:0] inst_mem_read_addr,
	output logic [31:0] inst
);
	
	localparam INST_SIZE=2**32;

	logic [31:0] inst_reg [INST_SIZE];
	
	assign inst = inst_reg[inst_mem_read_addr];
	
	always_ff @(posedge clk, negedge nrst)
		if(~nrst)
			begin
			genvar i;
			for(i = 0; i < INST_SIZE; i++) 
				inst_reg[i] <= 0;
			end
		else
			if(inst_mem_wren)
				inst_reg[inst_mem_write_addr] <= inst_mem_write_data;
				
endmodule