module stage_if_bhv(
	//Global clock and reset
	input logic clk, nrst,

	//Instruction memory loading inputs
	input logic [31:0] inst_mem_write_addr, inst_mem_write_data,
	input logic inst_mem_wren,

	//Branch/Jump addresses from ID stage
	input logic [31:0] correct_addr, jump_addr,
	//Branch/Jump control signals from ID stage
	input logic default_branch, branch_override, ctrl_jump, 
	
	//Data outputs to ID stage
	output logic [31:0] PC_4, branch_addr, inst, 
	//Control signal outputs to ID stage
	output logic ctrl_branch
);

	logic [31:0] PC, nPC, branch_PC, override_PC;
	logic [31:0] branch_addr_from_inst, branch_addr;
	logic [6:0] opcode;
	logic branch_test;

	inst_mem inst_mem (
		.clk(clk), .nrst(nrst),
		.inst_mem_wren(inst_mem_wren),
		.inst_mem_write_addr(inst_mem_write_addr),
		.inst_mem_write_data(inst_mem_write_data),
		.inst_mem_read_addr(PC), .inst(inst)
	);

	assign opcode = inst[6:0];
	assign branch_addr_from_inst = {{19{inst[31]}}, inst[7], inst[30:25], inst[11:8], '0};
	assign ctrl_branch = (opcode == 7'b1100011);
	assign branch_test = default_branch & ctrl_branch;
	
	assign PC_4 = PC+4;
	assign branch_PC = (branch_test)? (PC_4 + branch_addr_from_inst) : PC_4;
	assign override_PC = (branch_override)? correct_addr : branch_PC;
	assign nPC = (ctrl_jump)? jump_addr : override_PC;
	
	always_ff @(posedge clk, negedge nrst)
		if(~nrst)
			PC <= 0;
		else
			//Pause operation when loading instructions
			if (inst_mem_wren)
				PC <= PC;
			else
				PC <= nPC;
				

endmodule