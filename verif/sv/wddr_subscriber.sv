`uvm_analysis_imp_decl(_LPDDR5)
`uvm_analysis_imp_decl(_DFI)

class wddr_subscriber extends uvm_component;
	`uvm_component_utils(wddr_subscriber);

	wav_DFI_transfer dfi_trans;
	uvm_analysis_imp_DFI #(wav_DFI_transfer) DFI_imp;
	
	wav_DFI_write_transfer lpddr5_trans;
	uvm_analysis_imp_LPDDR5 #(wav_DFI_write_transfer) LPDDR5_imp;

	//--------------------------------COVERGROUPS------------------------------------
	
	//-------------------------------------------------------------------------------
	
	function new(string name = "wddr_subscriber", uvm_component parent);
		super.new(name, parent);
		DFI_imp = new("DFI_imp", this);
		LPDDR5_imp = new("LPDDR5_imp", this);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction: build_phase
	
	function void write_DFI(wav_DFI_transfer dfi_trans);
		//insert sample function(s) and any other needed logic
	endfunction
	
	function void write_LPDDR5(wav_DFI_write_transfer lpddr5_trans);
		//insert sample function(s) and any other needed logic
	endfunction
	
endclass: wddr_subscriber