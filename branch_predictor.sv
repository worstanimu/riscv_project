module branch_predictor (
	input logic clk, nrst,
	input logic [31:0] inst,
	input logic branch_zero,
	input logic ctrl_branch,
	output logic default_branch,
	output logic should_branch,
	output logic branch_override
);

	typedef enum logic [1:0] {STRONG_NOBRANCH=2'b00, WEAK_NOBRANCH=2'b01, STRONG_BRANCH=2'b10, WEAK_BRANCH=2'b11} state;
	state state_now;

	assign should_branch = ctrl_branch && ((inst[14:12] == 3'b000 && branch_zero) || (inst[14:12] == 3'b001 && ~branch_zero));
	assign default_branch = state_now[1];

	always_ff @(posedge clk, negedge nrst)
		if(~nrst)
			state_now <= STRONG_NOBRANCH;
		else
			unique case(state_now)
				default: state_now <= STRONG_NOBRANCH;
				STRONG_NOBRANCH: state_now <= (should_branch)? WEAK_NOBRANCH : STRONG_NOBRANCH;
				WEAK_NOBRANCH: state_now <= (should_branch)? WEAK_BRANCH : STRONG_NOBRANCH;
				WEAK_BRANCH: state_now <= (should_branch)? STRONG_BRANCH : WEAK_NOBRANCH;
				STRONG_BRANCH: state_now <= (should_branch)? STRONG_BRANCH : WEAK_BRANCH;
			endcase	

	assign branch_override = (default_branch & ~should_branch) | (~default_branch & should_branch); 

endmodule