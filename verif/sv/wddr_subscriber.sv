`uvm_analysis_imp_decl(_LPDDR5)
`uvm_analysis_imp_decl(_DFI)

class wddr_subscriber extends uvm_component;
	`uvm_component_utils(wddr_subscriber);

	wav_DFI_transfer dfi_trans;
	uvm_analysis_imp_DFI #(wav_DFI_transfer) DFI_imp;
	
	// wav_DFI_write_transfer is a placeholder for another transaction that will inlcue the abstracted
	// values of the DRAM interface
	wav_DFI_write_transfer lpddr5_trans;
	uvm_analysis_imp_LPDDR5 #(wav_DFI_write_transfer) LPDDR5_imp;

	time prev_CA_time;
	typedef enum {SAME, DIFFERENT} different_BA;
	different_BA diff_BA;
	//--------------------------------COVERGROUPS------------------------------------
	covergroup lpddr5_cg (
		input command CA, prev_CA,
		input bit [3:0] BA, prev_BA,
		input time prev_CA_time,
		input different_BA diff_BA
		);

		COVER_REQUIREMENTS: coverpoint CA {
			bins COMMANDS[] = CA with (item != DES && CA != NOP);
			
			bins RD_AFTER_RD_NO_SYNC[] = (RD32,RD16 => RD32,RD16) with (($time - prev_CA_time)/`tCK <= `tCCD);
			bins RD_AFTER_RD_WITH_SYNC[] = (RD32,RD16 => CAS_FS,CAS_RD => RD32,RD16) with (($time - prev_CA_time)/`tCK > `tCCD);
			bins WR_AFTER_RD_WITH_SYNC[] = (RD32,RD16 => CAS_FS,CAS_WR => WR32,WR16) with (($time - prev_CA_time)/`tCK > (`RL + `BL/8 + 1));
			bins WR_AFTER_WR_NO_SYNC[] = (WR32,WR16 => WR32,WR16) with (($time - prev_CA_time)/`tCK <= `tCCD);
			bins WR_AFTER_WR_WITH_SYNC[] = (WR32,WR16 => CAS_FS,CAS_WR => WR32,WR16) with (($time - prev_CA_time)/`tCK > `tCCD);
			
			bins MWR_SAME_BG = (MWR => MWR) with ((prev_BA[3:2] == BA[3:2]) && (`tCK > `WL + `BL/`n_max));
			bins SRE_AFTER_PDE = (PDE => SRE);
			bins ANY_COMMAND_AFTER_CAS_FS = (CAS_FS => item) with (item != WR16 && item != WR32);
			
			bins WR_AFTER_WR_NO_CAS[] = (WR16,WR32,MWR => WR16,WR32,MWR) with (($time - prev_CA_time)/`tCK <= (`WL + `BL/`n_max + $floor(`tWCKPST/`tCK)));
			bins WR_AFTER_WR_WITH_CAS[] = (WR16,WR32,MWR => CAS_FS,CAS_WR => WR16,WR32,MWR) with (($time - prev_CA_time)/`tCK > (`WL + `BL/`n_max + $floor(`tWCKPST/`tCK)));
			
			bins IO_AFTER_RD_NO_CAS[] = (RD16,RD32 => RD16,RD32,WR16,WR32,MWR) with (($time - prev_CA_time)/`tCK <= (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK)));
			bins WR_AFTER_RD_WITH_CAS[] = (RD16,RD32 => CAS_FS,CAS_WR => WR16,WR32,MWR) with (($time - prev_CA_time)/`tCK > (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK)));
			bins RD_AFTER_RD_WITH_CAS[] = (RD16,RD32 => CAS_FS,CAS_RD => RD16,RD32) with (($time - prev_CA_time)/`tCK > (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK)));
			
			bins WR_AFTER_MRR_NO_CAS[] = (MRR => MRR,WR16,WR32,MWR) with (($time - prev_CA_time)/`tCK <= (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK)));
			bins WR_AFTER_MRR_WITH_CAS[] = (MRR => CAS_FS,CAS_WD => MRR,WR16,WR32,MWR) with (($time - prev_CA_time)/`tCK > (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK)));
			
			bins WFF_AFTER_WFF_NO_CAS = (WFF => WFF) with(($time - prev_CA_time)/`tCK <= (`WL + `BL/`n_max + $floor(`tWCKPST/`tCK)));
			bins WFF_AFTER_WFF_WITH_CAS = (WFF => CAS_FS, CAS_WR => WFF) with(($time - prev_CA_time)/`tCK > (`WL + `BL/`n_max + $floor(`tWCKPST/`tCK)));

			bins WFF_RFF_AFTER_RFF_NO_CAS = (RFF => WFF,RFF) with(($time - prev_CA_time)/`tCK <= (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK)));
			bins WFF_AFTER_RFF_WITH_CAS = (RFF => CAS_FS,CAS_WR => WFF) with(($time - prev_CA_time)/`tCK > (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK)));
			bins RFF_AFTER_RFF_WITH_CAS = (RFF => CAS_FS,CAS_RD => RFF) with(($time - prev_CA_time)/`tCK > (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK)));

			bins RDC_AFTER_RDC_NO_CAS = (RDC => RDC) with(($time - prev_CA_time)/`tCK <= (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK)));
			bins RDC_AFTER_RDC_WITH_CAS = (RDC => CAS_FS,CAS_RD => RDC) with(($time - prev_CA_time)/`tCK > (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK)));

			//TODO VR 253?? 
			bins DIFF_BANK_DURING_ACT = (ACT2[=1] => CAS_FS, CAS_WR, CAS_RD, WR16, WR32, MWR, RD16, RD32, MRR) with (diff_BA == DIFFERENT && prev_CA == ACT1);
			bins VR256 = (ACT2[=1] => PRE);
			bins VR257 = (ACT2[=1] => ACT2);
			bins VR258 = (ACT2[=1] => ACT2) with (diff_BA == DIFFERENT);
			bins VR259_ab = {PRE} with (ALL_BANKS == 1);
			bins VR259_pb = {PRE} with (ALL_BANKS == 0);

			bins CMD_AFTER_CMD_SAME_BANK[] = (ACT2, RD32, RD16, WR16, WR32, MWR, PRE => ACT2, RD32, RD16, WR16, WR32, MWR, PRE) with (diff_BA == SAME);
			illegal_bins PRE_ACT_ILLEGAL_CASES[] = (ACT2, RD32, RD16, WR16, WR32, MWR => ACT2), (PRE => RD32, RD16, WR16, WR32, MWR) with (diff_BA == SAME);
			bins CMD_AFTER_CMD_DIFF_BANK[] = (ACT2, RD32, RD16, WR16, WR32, MWR, PRE => ACT2, RD32, RD16, WR16, WR32, MWR, PRE) with (diff_BA == DIFFERENT);

			bins PPR_COMMANDS = (MRW1 => MRW2 => ACT1 => ACT2 => PRE => MRW1 => MRW2);
			bins TTR_COMMANDS = (MRW1 => MRW2 => ACT1 => ACT2 => PRE => ACT1 => ACT2 => PRE => ACT1 => ACT2 => PRE);
			//TODO Single-Ended MODE: Will still see how it's implemented in the monitor
		}
	endgroup
	
	//-------------------------------------------------------------------------------
	
	function new(string name = "wddr_subscriber", uvm_component parent);
		super.new(name, parent);
		DFI_imp = new("DFI_imp", this);
		LPDDR5_imp = new("LPDDR5_imp", this);
		// lpddr5_cg = new(lpddr5_trans, );
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction: build_phase
	
	function void write_DFI(wav_DFI_transfer dfi_trans);
		//insert sample function(s) and any other needed logic
	endfunction
	
	//TODO UNCOMMENT ALL OF THIS AFTER DEFINING THE PROPER TRANSACTION (SEQUENCE ITEM) CLASS
	function void write_LPDDR5(wav_DFI_write_transfer lpddr5_trans);
		// if(lpddr5_trans.CA != DES && lpddr5_trans.CA != NOP) begin
		// 	if(lpddr5_trans.BA != lpddr5_trans.prev_BA) diff_BA = DIFFERENT;
		// 	else diff_BA = SAME;
		// 	lpddr5_trans_cg.sample();
		// 	prev_CA_time = $time;
		// end
	endfunction

endclass: wddr_subscriber