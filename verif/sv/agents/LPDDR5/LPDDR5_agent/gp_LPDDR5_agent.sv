class gp_LPDDR5_agent extends uvm_agent;
	`uvm_component_utils(gp_LPDDR5_agent)

	gp_LPDDR5_monitor lpddr5_monitor;

	function new(string name = "gp_LPDDR5_agent", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		lpddr5_monitor = gp_LPDDR5_monitor::type_id::create("lpddr5_monitor", this);
	endfunction 
	
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
	endtask
endclass