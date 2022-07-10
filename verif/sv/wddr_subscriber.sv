`uvm_analysis_imp_decl(_LPDDR5)
`uvm_analysis_imp_decl(_DFI)

class wddr_subscriber extends uvm_component;
	`uvm_component_utils(wddr_subscriber);
	
	wav_DFI_transfer dfi_trans;

	wav_DFI_lp_transfer lp_ctrl_trans, lp_data_trans;
	wav_DFI_phymstr_transfer phymstr_trans;
	wav_DFI_update_transfer ctrlupd_trans, phyupd_trans;
	// wav_DFI_read_transfer DFI_read_trans;
	wav_DFI_write_transfer DFI_write_trans;

	uvm_analysis_imp_DFI #(wav_DFI_transfer, wddr_subscriber) DFI_imp;
	
	gp_LPDDR5_cov_trans lpddr5_trans;
	uvm_analysis_imp_LPDDR5 #(gp_LPDDR5_cov_trans, wddr_subscriber) LPDDR5_imp;

	typedef enum  {DFI_C, control_c, phyupd_c, ctrlupd_c, phymstr_c, lp_ctrl_c, lp_data_c, read_c, write_c, freq_change_c} trans_c_e;
	trans_c_e trans_c;

	`define high_bin_only {bins is_high = {1};}

	// typedef enum {SAME, DIFFERENT} different_BA;
	// different_BA diff_BA;
	
	time prev_CA_time[command] = '{default:0};

	enum {
		NONE,
		RD_AFTER_RD_NO_SYNC,
		RD_AFTER_RD_WITH_SYNC, 	
		WR_AFTER_RD_WITH_SYNC, 	
		WR_AFTER_WR_NO_SYNC,
		WR_AFTER_WR_WITH_SYNC,
		MWR_SAME_BG,
		SRE_AFTER_PDE,
		ANY_COMMAND_AFTER_CAS_FS,
		WR_AFTER_WR_NO_CAS,
		WR_AFTER_WR_WITH_CAS,
		IO_AFTER_RD_NO_CAS,
		WR_AFTER_RD_WITH_CAS,
		RD_AFTER_RD_WITH_CAS,
		WR_AFTER_MRR_NO_CAS,
		WR_AFTER_MRR_WITH_CAS,
		WFF_AFTER_WFF_NO_CAS,
		WFF_AFTER_WFF_WITH_CAS,
		WFF_RFF_AFTER_RFF_NO_CAS,
		WFF_AFTER_RFF_WITH_CAS,
		RFF_AFTER_RFF_WITH_CAS,
		RDC_AFTER_RDC_NO_CAS,
		RDC_AFTER_RDC_WITH_CAS,
		DIFF_BANK_DURING_ACT,
		VR258,
		VR259_ab,
		VR259_pb,
		CMD_AFTER_CMD_SAME_BANK,
		CMD_AFTER_CMD_DIFF_BANK
	} lpddr5_cover_reqs;
	//--------------------------------COVERGROUPS------------------------------------
	//TODO Need to create cross bins to handle multiple commands in the same requirements
	covergroup lpddr5_cg;
		COMMANDS_COVER: coverpoint lpddr5_trans.CA {
			bins COMMANDS[] = COMMANDS_COVER with (item != DES && item != NOP);
			bins SRE_AFTER_PDE = (PDE => SRX);

			//TODO VR 253?? 
			bins VR256 = (ACT2[=1] => PRE);
			bins VR257 = (ACT2[=1] => ACT2);

			bins PPR_COMMANDS = (MRW1 => MRW2 => ACT1 => ACT2 => PRE => MRW1 => MRW2);
			bins TTR_COMMANDS = (MRW1 => MRW2 => ACT1 => ACT2 => PRE => ACT1 => ACT2 => PRE => ACT1 => ACT2 => PRE);
		}
		COVER_REQUIREMENTS: coverpoint lpddr5_cover_reqs;
	endgroup
	
	// Cover the occurence of the control_c transactions
	covergroup basic_DFI_cg;
		basic_cp: coverpoint trans_c {
			bins lp_ctrl_trans 		= {lp_ctrl_c};
			bins lp_data_trans 		= {lp_data_c};
			bins phymstr_trans 		= {phymstr_c};
			bins ctrlupd_trans 		= {ctrlupd_c};
			bins phyupd_trans		= {phyupd_c};
			bins read_trans			= {read_c};
			bins write_trans 		= {write_c};
			bins freq_change_trans	= {freq_change_c};
		}
	endgroup

	// Cover different parameters of phymstr
	covergroup phymstr_cg;
		phymstr_type_cp:		coverpoint phymstr_trans._type iff(phymstr_trans.req);
		phymstr_cs_state_cp:	coverpoint phymstr_trans.cs_state iff(phymstr_trans.req);
		phymstr_state_sel_cp:	coverpoint phymstr_trans.state_sel iff(phymstr_trans.req);
	endgroup

	// Cover different parameters of update
	covergroup update_cg;
		phyupd_type_cp:	coverpoint phyupd_trans._type iff(phyupd_trans.req);
	endgroup

	// Cover different parameters of lp
	covergroup lp_cg;
		lp_ctrl_wakeup_cp:	coverpoint lp_ctrl_trans.wakeup iff(lp_ctrl_trans.req)
		{
			bins one_cycle = {0};
			bins few_cycles = {[1:10]};
			bins many_cycles = {[11:18]};
			bins infinite_cycles = {19};
			illegal_bins more_than_infinity = {[20:$]};
		} 	

		lp_data_wakeup_cp:	coverpoint lp_data_trans.wakeup iff(lp_data_trans.req)
		{
			bins one_cycle = {0};
			bins few_cycles = {[1:10]};
			bins many_cycles = {[11:18]};
			bins infinite_cycles = {19};
			illegal_bins more_than_infinity = {[20:$]};
		}
	endgroup

	// Cover different parameters of write
	covergroup DFI_write_cg;
		wck_modes_p0_cp:	coverpoint DFI_write_trans.wck_toggle[0] iff(DFI_write_trans.wck_en[0]);
		wck_modes_p1_cp:	coverpoint DFI_write_trans.wck_toggle[1] iff(DFI_write_trans.wck_en[1]);
		wck_modes_p2_cp:	coverpoint DFI_write_trans.wck_toggle[2] iff(DFI_write_trans.wck_en[2]);
		wck_modes_p3_cp:	coverpoint DFI_write_trans.wck_toggle[3] iff(DFI_write_trans.wck_en[3]);
	endgroup

	// Cover different control high level scenarios
	covergroup advanced_control_cg;
		lp_ctrl_and_data_cp:	coverpoint (lp_ctrl_trans.req & lp_data_trans.req) `high_bin_only

		transitions_cp:	coverpoint trans_c {
			// read/write after lp(ctrl/data)
			bins read_after_lp_data 	= (lp_data_c => read_c);
			bins write_after_lp_data 	= (lp_data_c => write_c);

			bins read_after_lp_ctrl 	= (lp_ctrl_c => read_c);
			bins write_after_lp_ctrl 	= (lp_ctrl_c => write_c);
			
			// read/write after read/write
			bins read_after_read		= (read_c => read_c);
			bins write_after_read		= (read_c => write_c);
			bins write_after_write		= (write_c => write_c);
			bins read_after_write		= (write_c => read_c);
			
			// read_c/write after (ctrl/phy)update
			bins read_after_phyupd 		= (phyupd_c => read_c);
			bins write_after_phyupd 	= (phyupd_c => write_c);

			bins read_after_ctrlupd 	= (ctrlupd_c => read_c);
			bins write_after_ctrlupd 	= (ctrlupd_c => write_c);

			// read/write/frequency change after frequency change
			bins read_after_freq		= (freq_change_c => read_c);
			bins write_after_freq		= (freq_change_c => write_c);
			bins freq_after_freq		= (freq_change_c => freq_change_c);

			// (ctrl/phy) update after (phy/ctrl) update
			bins phyupd_after_ctrlupd	= (ctrlupd_c => phyupd_c);
			bins ctrlupd_after_phyupd	= (phyupd_c => ctrlupd_c);

			// (phy/ctrl) update and lp (ctrl/data)
			bins lp_data_after_lp_ctrl	= (lp_ctrl_c => lp_data_c);
			bins lp_ctrl_after_lp_data 	= (lp_data_c => lp_ctrl_c);
			
			bins lp_ctrl_after_ctrlupd 	= (ctrlupd_c => lp_ctrl_c);
			bins ctrlupd_after_lp_ctrl	= (lp_ctrl_c => ctrlupd_c);

			bins lp_data_after_ctrlupd 	= (ctrlupd_c => lp_data_c);
			bins ctrlupd_after_lp_data	= (lp_data_c => ctrlupd_c);

			bins lp_ctrl_after_phyupd 	= (phyupd_c => lp_ctrl_c);
			bins phyupd_after_lp_ctrl	= (lp_ctrl_c => phyupd_c);

			bins lp_data_after_phyupd 	= (phyupd_c => lp_data_c);
			bins phyupd_after_lp_data	= (lp_data_c => phyupd_c);

			//	same transaction repeated
			bins phyupd_after_phyupd	= (phyupd_c => phyupd_c);
			bins ctrlupd_after_ctrlupd	= (ctrlupd_c => ctrlupd_c);
			bins lp_ctrl_after_lp_ctrl	= (lp_ctrl_c => lp_ctrl_c);
			bins lp_data_after_lp_data	= (lp_data_c => lp_data_c);

			// frequency change and lp
			bins freq_after_lp_data		= (lp_data_c => freq_change_c);
			bins freq_after_lp_ctrl		= (lp_ctrl_c => freq_change_c);
			
			bins lp_data_after_freq		= (freq_change_c => lp_data_c);
			bins lp_ctrl_after_freq		= (freq_change_c => lp_ctrl_c);

			// frequency change and update
			bins freq_after_phyupd		= (phyupd_c => freq_change_c);
			bins freq_after_ctrlupd		= (ctrlupd_c => freq_change_c);
			
			bins phyupd_after_freq		= (freq_change_c => phyupd_c);
			bins ctrlupd_after_freq		= (freq_change_c => ctrlupd_c);
		}
	endgroup	
	//-------------------------------------------------------------------------------
	
	function new(string name = "wddr_subscriber", uvm_component parent);
		super.new(name, parent);
		DFI_imp = new("DFI_imp", this);
		LPDDR5_imp = new("LPDDR5_imp", this);
		
		lpddr5_trans = new();
		lpddr5_cg = new();

		// Instantiate the required transaction objects
		dfi_trans = wav_DFI_transfer::type_id::create("coverage_dfi_trans", this);
		
		lp_ctrl_trans = wav_DFI_lp_transfer::type_id::create("coverage_lp_ctrl_trans", this);
		lp_data_trans = wav_DFI_lp_transfer::type_id::create("coverage_lp_data_trans", this);

		phymstr_trans = wav_DFI_phymstr_transfer::type_id::create("coverage_lp_trans", this);

		ctrlupd_trans = wav_DFI_update_transfer::type_id::create("coverage_ctrlupd_trans", this);
		phyupd_trans = wav_DFI_update_transfer::type_id::create("coverage_phyupd_trans", this);

		DFI_write_trans = wav_DFI_write_transfer::type_id::create("coverage_DFI_write_trans", this);

		// Instantiate the required scalar data field
		trans_c = DFI_C;

		// Instantiate the covergroups
		basic_DFI_cg = new();
		phymstr_cg = new();
		update_cg = new();
		lp_cg = new();
		DFI_write_cg = new();
		advanced_control_cg = new();
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction: build_phase

	function automatic void reset_DFI_objects;
		lp_data_trans.reset();
		lp_ctrl_trans.reset();

		phyupd_trans.reset();
		ctrlupd_trans.reset();

		phymstr_trans.reset();

		DFI_write_trans.reset();

		trans_c = DFI_C;
	endfunction

	function automatic void handle_lp_cg(wav_DFI_lp_transfer trans);
		if (trans.is_ctrl) begin
			$cast(lp_ctrl_trans, trans);
			trans_c = lp_ctrl_c;
		end
		else begin
			$cast(lp_data_trans, trans);
			trans_c = lp_data_c;
		end

		lp_cg.sample();
	endfunction

	function automatic void handle_update_cg(wav_DFI_update_transfer trans);
		if (trans.is_ctrl) begin
			$cast(ctrlupd_trans, trans);
			trans_c = ctrlupd_c;
		end
		else begin
			$cast(phyupd_trans, trans);
			trans_c = phyupd_c;
		end

		update_cg.sample();
	endfunction
	
	function automatic void write_DFI(wav_DFI_transfer trans);
		static realtime last_time = 0, current_time = 0;
		//insert sample function(s) and any other needed logic
		wav_DFI_lp_transfer lp_trans;
		wav_DFI_update_transfer update_trans;
		// To ensure that we are not counting the same transaction twice
		current_time = $realtime;
		if ((current_time - last_time) > 10) begin
			last_time = current_time;
			reset_DFI_objects();
		end

		if (!$cast(dfi_trans, trans.clone())) begin
			`uvm_fatal(get_name(), "Coverage collector cannot cast wav_DFI_transfer object");			
		end
		case(trans.tr_type)
			phymstr: begin
				$cast(phymstr_trans, trans);
				trans_c = phymstr_c;
				phymstr_cg.sample();
				`uvm_info(get_name(), "Received a phymstr trans", UVM_MEDIUM);				
			end
			status_freq: begin
				trans_c = freq_change_c;
				`uvm_info(get_name(), "Received a status_freq trans", UVM_MEDIUM);
			end
			lp: begin
				$cast(lp_trans, trans);
				handle_lp_cg(lp_trans);
				`uvm_info(get_name(), "Received a lp trans", UVM_MEDIUM);
			end 
			update: begin     
				$cast(update_trans, trans);
				handle_update_cg(update_trans);
				`uvm_info(get_name(), "Received an update trans", UVM_MEDIUM);
			end
			write: begin     
				$cast(DFI_write_trans, trans);
				trans_c = write_c;
				DFI_write_cg.sample();
				`uvm_info(get_name(), "Received a write trans", UVM_MEDIUM);
			end
			// read: begin     
				// $cast(DFI_read_trans, trans);
				// trans_c = read_c;
			// end
		endcase    

		basic_DFI_cg.sample();
		advanced_control_cg.sample();
	endfunction
	

	function void write_LPDDR5(gp_LPDDR5_cov_trans lpddr5_trans_item);
		lpddr5_trans = lpddr5_trans_item;
		if(lpddr5_trans.CA != DES && lpddr5_trans.CA != NOP) begin
			
			//RD_AFTER_RD_NO_SYNC
			if(	lpddr5_trans.CA == RD32 ||
				lpddr5_trans.CA == RD16) begin
				if(	($time - prev_CA_time[RD16])/`tCK <= `tCCD || 
					($time - prev_CA_time[RD32])/`tCK <= `tCCD) begin
						lpddr5_cover_reqs = RD_AFTER_RD_NO_SYNC;
						lpddr5_cg.sample();
				end
			end

			//RD_AFTER_RD_WITH_SYNC
			if(	lpddr5_trans.CA == RD32 ||
				lpddr5_trans.CA == RD16) begin
				if(	($time - prev_CA_time[RD16])/`tCK > `tCCD || 
					($time - prev_CA_time[RD32])/`tCK > `tCCD) begin
						lpddr5_cover_reqs = RD_AFTER_RD_WITH_SYNC;
						lpddr5_cg.sample();
				end
			end

			//WR_AFTER_RD_WITH_SYNC
			if(	lpddr5_trans.CA == WR32 ||
				lpddr5_trans.CA == WR16) begin
				if(	($time - prev_CA_time[RD16])/`tCK > (`RL + `BL/8 + 1) || 
					($time - prev_CA_time[RD32])/`tCK > (`RL + `BL/8 + 1)
					) begin
						lpddr5_cover_reqs = WR_AFTER_RD_WITH_SYNC;
						lpddr5_cg.sample();
				end
			end

			//WR_AFTER_WR_NO_SYNC
			if(	lpddr5_trans.CA == WR32 ||
				lpddr5_trans.CA == WR16) begin
				if(	($time - prev_CA_time[WR16])/`tCK <= `tCCD || 
					($time - prev_CA_time[WR32])/`tCK <= `tCCD) begin
						lpddr5_cover_reqs = WR_AFTER_WR_NO_SYNC;
						lpddr5_cg.sample();
				end
			end
			
			//WR_AFTER_WR_WITH_SYNC
			if(	lpddr5_trans.CA == WR32 ||
				lpddr5_trans.CA == WR16) begin
				if(	($time - prev_CA_time[WR16])/`tCK > `tCCD || 
					($time - prev_CA_time[WR32])/`tCK > `tCCD) begin
						lpddr5_cover_reqs = WR_AFTER_WR_WITH_SYNC;
						lpddr5_cg.sample();
				end
			end

			//MWR_SAME_BG
			if(	lpddr5_trans.CA == MWR) begin
				if(	($time - prev_CA_time[MWR])/`tCK > (`WL + `BL/`n_max) &&
					(lpddr5_trans.prev_BA[3:2] == lpddr5_trans.BA[3:2])) begin
						lpddr5_cover_reqs = MWR_SAME_BG;
						lpddr5_cg.sample();
				end
			end

			//ANY_COMMAND_AFTER_CAS_FS
			if( lpddr5_trans.CA != WR16 &&
				lpddr5_trans.CA != WR32 ) begin
					if(	prev_CA_time.max()[0] == prev_CA_time[CAS_FS]) begin
						lpddr5_cover_reqs = ANY_COMMAND_AFTER_CAS_FS;
						lpddr5_cg.sample();
				end
			end

			//WR_AFTER_WR_NO_CAS
			if(	lpddr5_trans.CA == WR32 ||
				lpddr5_trans.CA == WR16 ||
				lpddr5_trans.CA == MWR) begin
				if(	($time - prev_CA_time[WR16])/`tCK <= (`WL + `BL/`n_max + $floor(`tWCKPST/`tCK)) || 
					($time - prev_CA_time[WR32])/`tCK <= (`WL + `BL/`n_max + $floor(`tWCKPST/`tCK)) ||
					($time - prev_CA_time[MWR])/`tCK <= (`WL + `BL/`n_max + $floor(`tWCKPST/`tCK))) begin
						lpddr5_cover_reqs = WR_AFTER_WR_NO_CAS;
						lpddr5_cg.sample();
				end
			end

			//WR_AFTER_WR_WITH_CAS
			if(	lpddr5_trans.CA == WR32 ||
				lpddr5_trans.CA == WR16 ||
				lpddr5_trans.CA == MWR) begin
				if(	($time - prev_CA_time[WR16])/`tCK > (`WL + `BL/`n_max + $floor(`tWCKPST/`tCK)) || 
					($time - prev_CA_time[WR32])/`tCK > (`WL + `BL/`n_max + $floor(`tWCKPST/`tCK)) ||
					($time - prev_CA_time[MWR])/`tCK > (`WL + `BL/`n_max + $floor(`tWCKPST/`tCK))) begin
						lpddr5_cover_reqs = WR_AFTER_WR_WITH_CAS;
						lpddr5_cg.sample();
				end
			end
			
			//IO_AFTER_RD_NO_CAS
			if(	lpddr5_trans.CA == WR32 ||
				lpddr5_trans.CA == WR16 ||
				lpddr5_trans.CA == MWR ||
				lpddr5_trans.CA == RD32 ||
				lpddr5_trans.CA == RD16) begin
				if(	($time - prev_CA_time[RD16])/`tCK <= (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK)) || 
					($time - prev_CA_time[RD32])/`tCK <= (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK))) begin
						lpddr5_cover_reqs = IO_AFTER_RD_NO_CAS;
						lpddr5_cg.sample();
				end
			end

			//WR_AFTER_RD_WITH_CAS
			if(	lpddr5_trans.CA == WR32 ||
				lpddr5_trans.CA == WR16 ||
				lpddr5_trans.CA == MWR) begin
				if(	($time - prev_CA_time[RD16])/`tCK > (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK)) || 
					($time - prev_CA_time[RD32])/`tCK > (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK))) begin
						lpddr5_cover_reqs = WR_AFTER_RD_WITH_CAS;
						lpddr5_cg.sample();
				end
			end

			//RD_AFTER_RD_WITH_CAS
			if(	lpddr5_trans.CA == RD32 ||
				lpddr5_trans.CA == RD16) begin
				if(	($time - prev_CA_time[RD16])/`tCK > (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK)) || 
					($time - prev_CA_time[RD32])/`tCK > (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK))) begin
						lpddr5_cover_reqs = RD_AFTER_RD_WITH_CAS;
						lpddr5_cg.sample();
				end
			end

			//WR_AFTER_MRR_NO_CAS
			if(	lpddr5_trans.CA == WR32 ||
				lpddr5_trans.CA == WR16 ||
				lpddr5_trans.CA == MWR) begin
				if(	($time - prev_CA_time[MRR])/`tCK <= (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK))) begin
						lpddr5_cover_reqs = WR_AFTER_MRR_NO_CAS;
						lpddr5_cg.sample();
				end
			end

			//WR_AFTER_MRR_WITH_CAS
			if(	lpddr5_trans.CA == WR32 ||
				lpddr5_trans.CA == WR16 ||
				lpddr5_trans.CA == MWR) begin
				if(	($time - prev_CA_time[MRR])/`tCK > (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK))) begin
						lpddr5_cover_reqs = WR_AFTER_MRR_WITH_CAS;
						lpddr5_cg.sample();
				end
			end

			//WFF_AFTER_WFF_NO_CAS
			if(	lpddr5_trans.CA == WFF) begin
				if(	($time - prev_CA_time[WFF])/`tCK <= (`WL + `BL/`n_max + $floor(`tWCKPST/`tCK))) begin
						lpddr5_cover_reqs = WFF_AFTER_WFF_NO_CAS;
						lpddr5_cg.sample();
				end
			end

			//WFF_AFTER_WFF_WITH_CAS
			if(	lpddr5_trans.CA == WFF) begin
				if(	($time - prev_CA_time[WFF])/`tCK > (`WL + `BL/`n_max + $floor(`tWCKPST/`tCK))) begin
						lpddr5_cover_reqs = WFF_AFTER_WFF_WITH_CAS;
						lpddr5_cg.sample();
				end
			end

			//WFF_RFF_AFTER_RFF_NO_CAS
			if(	lpddr5_trans.CA == WFF ||
				lpddr5_trans.CA == RFF) begin
				if(	($time - prev_CA_time[RFF])/`tCK <= (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK))) begin
						lpddr5_cover_reqs = WFF_RFF_AFTER_RFF_NO_CAS;
						lpddr5_cg.sample();
				end
			end

			//WFF_AFTER_RFF_WITH_CAS	
			if(	lpddr5_trans.CA == WFF) begin
				if(	($time - prev_CA_time[RFF])/`tCK > (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK))) begin
						lpddr5_cover_reqs = WFF_AFTER_RFF_WITH_CAS;
						lpddr5_cg.sample();
				end
			end
			
			//RFF_AFTER_RFF_WITH_CAS
			if(	lpddr5_trans.CA == RFF) begin
				if(	($time - prev_CA_time[RFF])/`tCK > (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK))) begin
						lpddr5_cover_reqs = RFF_AFTER_RFF_WITH_CAS;
						lpddr5_cg.sample();
				end
			end

			//RDC_AFTER_RDC_NO_CAS
			if(	lpddr5_trans.CA == RDC) begin
				if(	($time - prev_CA_time[RDC])/`tCK <= (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK))) begin
						lpddr5_cover_reqs = RDC_AFTER_RDC_NO_CAS;
						lpddr5_cg.sample();
				end
			end

			//RDC_AFTER_RDC_WITH_CAS
			if(	lpddr5_trans.CA == RDC) begin
				if(	($time - prev_CA_time[RDC])/`tCK > (`RL + `BL/`n_max + $floor(`tWCKPST/`tCK))) begin
						lpddr5_cover_reqs = RDC_AFTER_RDC_WITH_CAS;
						lpddr5_cg.sample();
				end
			end

			//DIFF_BANK_DURING_ACT
			if( lpddr5_trans.CA == WR32 ||
				lpddr5_trans.CA == WR16 ||
				lpddr5_trans.CA == MWR ||
				lpddr5_trans.CA == CAS_FS ||
				lpddr5_trans.CA == CAS_WR ||
				lpddr5_trans.CA == CAS_RD ||
				lpddr5_trans.CA == RD16 ||
				lpddr5_trans.CA == RD32 ||
				lpddr5_trans.CA == MRR) begin
				if( prev_CA_time.max()[0] == prev_CA_time[ACT1] &&
					lpddr5_trans.prev_BA != lpddr5_trans.BA) begin
						lpddr5_cover_reqs = DIFF_BANK_DURING_ACT;
						lpddr5_cg.sample();
				end
			end

			//VR258
			if( lpddr5_trans.CA == ACT2) begin
				if( prev_CA_time.max()[0] == prev_CA_time[ACT1] &&
					lpddr5_trans.prev_BA != lpddr5_trans.BA) begin
						lpddr5_cover_reqs = VR258;
						lpddr5_cg.sample();
				end 
			end

			//VR259_ab
			if( lpddr5_trans.CA == PRE && lpddr5_trans.ALL_BANKS == 1) begin
				lpddr5_cover_reqs = VR259_ab;
				lpddr5_cg.sample();
			end

			//VR259_pb
			if( lpddr5_trans.CA == PRE && lpddr5_trans.ALL_BANKS == 0) begin
				lpddr5_cover_reqs = VR259_pb;
				lpddr5_cg.sample();
			end

			//CMD_AFTER_CMD_SAME_BANK
			if( lpddr5_trans.CA == ACT2 ||
				lpddr5_trans.CA == WR32 ||
				lpddr5_trans.CA == WR16 ||
				lpddr5_trans.CA == MWR ||
				lpddr5_trans.CA == RD16 ||
				lpddr5_trans.CA == RD32 ||
				lpddr5_trans.CA == PRE) begin
				if((prev_CA_time.max()[0] == prev_CA_time[ACT1] ||
					prev_CA_time.max()[0] == prev_CA_time[RD32] ||
					prev_CA_time.max()[0] == prev_CA_time[RD16] ||
					prev_CA_time.max()[0] == prev_CA_time[WR16] ||
					prev_CA_time.max()[0] == prev_CA_time[WR32] ||
					prev_CA_time.max()[0] == prev_CA_time[MWR] ||
					prev_CA_time.max()[0] == prev_CA_time[PRE]) &&
					lpddr5_trans.prev_BA == lpddr5_trans.BA) begin
						lpddr5_cover_reqs = CMD_AFTER_CMD_SAME_BANK;
						lpddr5_cg.sample();
				end
			end

			//CMD_AFTER_CMD_DIFF_BANK
			if( lpddr5_trans.CA == ACT2 ||
				lpddr5_trans.CA == WR32 ||
				lpddr5_trans.CA == WR16 ||
				lpddr5_trans.CA == MWR ||
				lpddr5_trans.CA == RD16 ||
				lpddr5_trans.CA == RD32 ||
				lpddr5_trans.CA == PRE) begin
				if((prev_CA_time.max()[0] == prev_CA_time[ACT1] ||
					prev_CA_time.max()[0] == prev_CA_time[RD32] ||
					prev_CA_time.max()[0] == prev_CA_time[RD16] ||
					prev_CA_time.max()[0] == prev_CA_time[WR16] ||
					prev_CA_time.max()[0] == prev_CA_time[WR32] ||
					prev_CA_time.max()[0] == prev_CA_time[MWR] ||
					prev_CA_time.max()[0] == prev_CA_time[PRE]) &&
					lpddr5_trans.prev_BA != lpddr5_trans.BA) begin
						lpddr5_cover_reqs = CMD_AFTER_CMD_DIFF_BANK;
						lpddr5_cg.sample();
				end
			end
			prev_CA_time[lpddr5_trans.CA] = $time;
			lpddr5_cover_reqs = NONE;
			lpddr5_cg.sample();
		end
	endfunction

endclass: wddr_subscriber