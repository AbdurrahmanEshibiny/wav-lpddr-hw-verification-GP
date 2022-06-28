class gp_LPDDR5_cov_trans extends uvm_sequence_item;
	`uvm_object_utils(gp_LPDDR5_cov_trans);

	command CA;
	command prev_CA;
	bit [3:0] BA, prev_BA;
	bit ALL_BANKS = 0;

	function new(string name = "gp_LPDDR5_cov_trans");
		super.new(name);
	endfunction: new
endclass: gp_LPDDR5_cov_trans

