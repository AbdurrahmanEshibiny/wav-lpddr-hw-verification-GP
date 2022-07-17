class gp_LPDDR5_monitor extends uvm_monitor;
	`uvm_component_utils(gp_LPDDR5_monitor)
	
	uvm_analysis_port #(gp_LPDDR5_cov_trans) subscriber_port_item;
	uvm_analysis_port #(wav_DFI_write_transfer) recieved_transaction;
	wav_DFI_write_transfer item;
	gp_LPDDR5_cov_trans cov_trans_item;

	//-------------------Start of variable declarations-------------------------------
	//typdef command was moved to gp_lpddr5_pkg.sv
	command CA, prev_CA, next_CA, type_last_wr_or_rd;
	bit [17:0] ROW;
	
	// typedef enum {	POWER_ON, IDLE, ACTIVATING, BANK_ACTIVE, PER_BANK_REFRESH, SYNC_RD, READ32, READ16, 
	// 				READ_WITH_AP, WRITE32, WRITE16, MASKWRITE, SYNC_WR, SYNC_WR, WR_OR_MWR_WITH_AP, ACTIVE_POWER_DOWN,
	// 				SELF_REFRESH, BUS_TRAINING, SELF_REFRESH_POWER_DOWN, ALL_BANK_REFRESH,
	// 				DEEP_SLEEP_MODE, IDLE_POWER_DOWN, PRECHARGING
	// } state;

	typedef enum {	IDLE, POWER_ON, BANK_ACTIVE, ACTIVATING, PER_BANK_REFRESH, SYNC_RD, READ32, READ16, 
					READ_WITH_AP, WRITE32, WRITE16, MASKWRITE, SYNC_WR, WR_OR_MWR_WITH_AP, ACTIVE_POWER_DOWN,
					SELF_REFRESH, BUS_TRAINING, SELF_REFRESH_POWER_DOWN, ALL_BANK_REFRESH,
					DEEP_SLEEP_MODE, IDLE_POWER_DOWN, PRECHARGING, SYNC_FS
	} state;
	
	// `ifdef BG_MODE
	// bit [1:0] BA; 
	// bit [1:0] BG;
	// state bank_state [4][4];  //[BG][BA]
	// `elsif B8_MODE
	// bit [2:0] BA;
	// state bank_state [8];
	// `else 
	// bit [3:0] BA;
	// bit [3:0] prev_BA;
	// state bank_state [16];
	// `endif
	// bit [3:0] BA;
	// bit [3:0] prev_BA;
	// state bank_state [16];

	// enum {BG = 4, Eight_bank = 8, sixteen_Bank = 16} bank_mode;

	`ifdef BG_MODE
	int bank_mode = 4;
	logic [1:0] BA; 
	logic [1:0] BG;
	state bank_state [4][4];  //[BG][BA]
	bit is_refreshed [4][4];
	time time_refresh_per_bank [4][4];
	`elsif B8_MODE
	int bank_mode = 8;
	logic [2:0] BA;
	state bank_state [8];
	bit is_refreshed [16];
	time time_refresh_per_bank [16];
	`else 
	int bank_mode = 16;
	bit [3:0] BA;
	state bank_state [16];
	bit is_refreshed [16];
	time time_refresh_per_bank [16];	
	`endif
	
	bit [3:0] prev_BA;
	bit [5:0] COL;
	bit [7:0] OP;
	bit [6:0] MA;
	// bit WS_WR, WS_RD, WS_FS;

	bit ALL_BANKS = 0;
	bit AUTO_PRECHARGE = 0;
	time time_last_auto_precharge;

	//---------------------Nada's variable declarations----------------------

	int queue [$];
	bit flag_16_refresh_commands_done, flag_wck_off;
	bit flag_8_refresh_commands_done;
	bit flag_all_bank_refresh_commands_done;
	bit [0:7] write_data [8];
	int i;
	int j = 0;
	logic [0: 15]DQ;
	int tWCK2CK = 0;
	int tWCKDQO = `tWCKDQO;
	int tWCKDQI = `tWCKDQI;
	int tCK = `tCK;
	int nWR = `nWR;
	int tCMDPD = `max(1.75ns, 2*`tCK);
	int tMRWPD = `max(14ns, 6*`tCK);
	int tESPD = 2;
	int tRFCab = 210;
	int tRFCpb = 100;
	int tpbR2pbR = 90;
	int tRP = `tRP;
	int tRRD = `tRRD;
	time tCSPD = `max(1.75ns, 2*`tCK);
	int tPDN = 0;
	int tXSR_DSM = 200*1000;
	int tWCKPRE_Static = 2;
	int tWCKPRE_Toggle_WR = 2;
	int tSR = `max(15ns, 2*`tCK);
	int nck = `tCK;
	int WL = `WL;
	int RU = 1;
	int delay;
	int BL = 16;
	int time_refresh_all_bank, time_prev_CA, time_SRE,time_last_MRR, time_last_MRW, time_last_write, time_last_read, time_DSE, time_DSX,
	time_last_MW_with_auto, time_last_command, time_SRX, time_bank_precharge, time_bank_activate, time_WR_command,
	time_SE, time_PDX, time_PDE, time_last_refresh_per_bank,flag_BG_refresh_commands_done;
 	/*assign DQ = {ch0_vif.dq0_dq0, ch0_vif.dq0_dq1, ch0_vif.dq0_dq2, ch0_vif.dq0_dq3, ch0_vif.dq0_dq4, ch0_vif.dq0_dq5,
	ch0_vif.dq0_dq6, ch0_vif.dq0_dq7,ch1_vif.dq1_dq0, ch1_vif.dq1_dq1, ch1_vif.dq1_dq2, ch1_vif.dq1_dq3,
	ch1_vif.dq1_dq4, ch1_vif.dq1_dq5,ch1_vif.dq1_dq6, ch1_vif.dq1_dq7};*/
	
	//--------------------------------------------------------------------------
	//----------------------------Ziad's variable decalarations-----------------  
	
	/// ***Activate Commands & PRE Charge internal variables*** \\\////edit
    logic [3:0] BA_of_last_act1;// bank address of the last bank that have ACT1 command
	logic [3:0] BA_of_last_act2;// bank address of the last bank that have ACT2 command
	time time_of_last_act2;// to know the last time that any bank has act2
	bit first_act2;// flag to know if it is the first time ever to get act2 so that we only check about tAAD
	bit [3:0] act1_to_act2_counter;//to handle tAAD (8 cycles)
    time act2_time[16];//last time for this bank to get ACT2
	time PRE_time[16];//last time for this bank to get PRECHARGE 
	bit not_first_precharge[16];//flag to ensure start check for tRC 
	/// ***Transaction Commands internal variables*** \\\
	logic [3:0] BA_of_last_wr_or_rd;// to handle different bank relation ships
	time time_of_last_wr_or_rd;// to handle different bank relationships
    time time_of_last_cas_wr;
    time time_of_last_cas_rd;
	bit we_have_WR_before;
	//-------------------------------------------------------------------------
	//---------------------End of variable declarations------------------------

	virtual gp_LPDDR5_channel_intf ch0_vif;
	virtual gp_LPDDR5_channel_intf ch1_vif;
	int ratio;

	semaphore act1_key;// to prevent any bank to recieve act1 command if any other bank wait for act2

	function new(string name = "gp_LPDDR5_monitor", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(! uvm_config_db#(virtual gp_LPDDR5_channel_intf)::get(this, "", "ch0_vif", ch0_vif)) begin
			`uvm_fatal("gp_LPDDR5_monitor", "Failed to get virtual interface from config db")
		end
		if(! uvm_config_db#(virtual gp_LPDDR5_channel_intf)::get(this, "", "ch1_vif", ch1_vif)) begin
			`uvm_fatal("gp_LPDDR5_monitor", "Failed to get virtual interface from config db")
		end
		if(! uvm_config_db #(int) :: get(this, "", "ratio", ratio))
			`uvm_info("gp_LPDDR5_monitor", "Failed Ratio", UVM_MEDIUM)
		recieved_transaction = new("recieved_transaction", this);
		subscriber_port_item = new("subscriber_port_item", this);
		cov_trans_item = gp_LPDDR5_cov_trans::type_id::create("cov_trans_item");
		item		   = wav_DFI_write_transfer::type_id::create("item");		
		//TODO get config db for ch1_vif 	
		act1_key = new(1);
	endfunction: build_phase
	
	// task get_next_CA();
	// 	@(posedge ch0_vif.ck_t);
	// 	casex({ch0_vif.cs, ch0_vif.ca})
	// 				{1'b0, 7'bxxxxxxx}: begin
	// 					next_CA = DES;
	// 				end 
	// 				{1'b1, 7'b0000000}: begin
	// 					next_CA = NOP;
	// 				end
	// 				{1'b1, 7'b0000001}: begin
	// 					next_CA = PDE;
	// 				end
	// 				{1'b1, 7'b111xxxx}: begin
	// 					next_CA = ACT1;
	// 				end
	// 				{1'b1, 7'b110xxxx}: begin
	// 					next_CA = ACT2;
	// 				end
	// 				{1'b1, 7'b0001111}: begin
	// 					next_CA = PRE;
	// 				end
	// 				{1'b1, 7'b0001110}: begin
	// 					next_CA = REF;
	// 				end
	// 				{1'b1, 7'b010xxxx}: begin
	// 					next_CA = MWR;
	// 				end
	// 				{1'b1, 7'b011xxxx}: begin
	// 					next_CA = WR16;
	// 				end
	// 				{1'b1, 7'b0010xxx}: begin
	// 					next_CA = WR32;
	// 				end
	// 				{1'b1, 7'b100xxxx}: begin
	// 					next_CA = RD16;
	// 				end
	// 				{1'b1, 7'b101xxxx}: begin
	// 					next_CA = RD32;
	// 				end
	// 				{1'b1, 7'b0011100}: begin
	// 					next_CA = CAS_WR;
	// 				end
	// 				{1'b1, 7'b0011010}: begin
	// 					next_CA = CAS_RD;
	// 				end
	// 				{1'b1, 7'b0011001}: begin
	// 					next_CA = CAS_FS;
	// 				end
	// 				{1'b1, 7'b0011111}: begin
	// 					next_CA = CAS_OFF;
	// 				end
	// 				{1'b1, 7'b000011x}: begin
	// 					next_CA = MPC;
	// 				end
	// 				{1'b1, 7'b0001011}: begin
	// 					next_CA = SRE;
	// 				end
	// 				{1'b1, 7'b0010xxx}: begin
	// 					next_CA = SRX;
	// 				end
	// 				{1'b1, 7'b0001101}: begin
	// 					next_CA = MRW1;
	// 				end
	// 				{1'b1, 7'b000100x}: begin
	// 					next_CA = MRW2;
	// 				end
	// 				{1'b1, 7'b0001100}: begin
	// 					next_CA = MRR;
	// 				end
	// 				{1'b1, 7'b0000011}: begin
	// 					next_CA = WFF;
	// 				end
	// 				{1'b1, 7'b0000010}: begin
	// 					next_CA = RFF;
	// 				end
	// 				default: `uvm_error("gp_lpddr5_monitor", "Recieved unknown command on CA bus")
	// 			endcase
	// endtask

	task automatic ziad_checks();
		case  (next_CA)
			ACT1:begin
              if(!act1_key.try_get(1)) `uvm_error("gp_lpddr5_monitor", "Failed to Recieve ACT1 command") //$error("Failed to Recieve ACT1 command");
				else begin
					bank_state[BA]=ACTIVATING;
					prev_CA=ACT1;
					prev_BA=BA;
                    BA_of_last_act1=BA;
                  //$display("at time=%0t,for bank num %0d bank state is %s",$time,BA,bank_state[BA].name);
                  //$display("at time=%0t,i'am in ACT1",$time);
				end
			end
			ACT2:begin//edit page 186
           if (bank_state[BA]==ACTIVATING/*BA==BA_of_last_act1*/) begin //to prevent receving act2 for any bank before act1
                //$display("at time %0t BA=%0d",$time,BA);
                act1_key.put(1);//  Regardless the correctness of ACT2 to the current bank state, any bank now can have ACT1 and not to block the monitor
				if ((act1_to_act2_counter<=`tAAD)) begin // to handle act2 after act1
                    if (! first_act2) begin//bacause if it's the first time ever to receive act2 we don,t need to check any timing parameter just tAAD
						bank_state[BA]=BANK_ACTIVE;
						prev_CA=ACT2; 
						first_act2=1;
						prev_BA=BA;
                        BA_of_last_act2=BA;
                        time_of_last_act2=$time;
                        act2_time[BA]=$time;
                      //$display("at time=%0t,for bank num %0d bank state is %s",$time,BA,bank_state[BA].name);
                      //$display("at time=%0t,i'am in ACT2",$time);
					end//edit
					else if ((BA_of_last_act2==BA) && (($time-time_of_last_act2)>=$ceil(`tRC/`tCK))) begin // to handle active to active same bank and ensure we excced the min time tRC
						bank_state[BA]=BANK_ACTIVE;
						prev_CA=ACT2;
						prev_BA=BA;
                        BA_of_last_act2=BA;
                        time_of_last_act2=$time;
                        act2_time[BA]=$time;
                      //$display("at time=%0t,for bank num %0d bank state is %s",$time,BA,bank_state[BA].name);
                      //$display("at time=%0t,i'am in ACT2",$time);
					end
					else if ((BA_of_last_act2!=BA) && (($time-time_of_last_act2)>=$ceil(`tRRD/`tCK))) begin // to handle active to active different bank and ensure we exceed min time tRRD
						bank_state[BA]=BANK_ACTIVE;
						prev_CA=ACT2;
						prev_BA=BA;
                        BA_of_last_act2=BA;
                        time_of_last_act2=$time;
                        act2_time[BA]=$time;
                      //$display("at time=%0t,for bank num %0d bank state is %s",$time,BA,bank_state[BA].name);
                      //$display("at time=%0t,i'am in ACT2",$time);
					end
					else  `uvm_error("gp_lpddr5_monitor", "Failed to Recieve ACT2") //$error("Failed to Recieve ACT2"); 
				end
				else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve ACT2") //$error("Failed to Recieve ACT2");
              end
              else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve ACT2") //$error("Failed to Recieve ACT2 command");
			end
			CAS_WR:begin
				prev_CA=CAS_WR;
                time_of_last_cas_wr=$time;
                  //$display("at time=%0t,i'am in CAS_WR",$time);
			end
			CAS_RD:begin
				prev_CA=CAS_RD;
                time_of_last_cas_rd=$time;
                 // $display("at time=%0t,i'am in CAS_RD",$time);
			end
			WR16:begin
              if ((($time-act2_time[BA])>=$ceil(`tRCD/`tCK)*`tCK) && (bank_state[BA]==BANK_ACTIVE)) begin
					if (prev_CA!=CAS_WR) begin
						case (prev_CA) 
							WR16:begin
								if (($time-time_of_last_wr_or_rd<=`max_WR16_after_WR16_ANB)&&($time-time_of_last_wr_or_rd>=`min_WR16_after_WR16_ANB))begin
									prev_CA=WR16;
									prev_BA=BA;
                                    time_of_last_wr_or_rd=$time;
                                    type_last_wr_or_rd=WR16;
                                    BA_of_last_wr_or_rd=BA;
									we_have_WR_before=1;
								end
                              else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve WR16") //$error("Failed to Recieve WR16");
							end
							MWR:begin
								if (($time-time_of_last_wr_or_rd<=`max_WR16_after_MWR_ANB)&&($time-time_of_last_wr_or_rd>=`min_WR16_after_MWR_ANB))begin
									prev_CA=WR16;
									prev_BA=BA;
                                    time_of_last_wr_or_rd=$time;
                                    type_last_wr_or_rd=WR16;
                                    BA_of_last_wr_or_rd=BA;
									we_have_WR_before=1;
								end
                              else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve WR16") //$error("Failed to Recieve WR16");
							end
							RD16:begin
								if (($time-time_of_last_wr_or_rd<=`max_WR16_after_RD16_ANB)&&($time-time_of_last_wr_or_rd>=`min_WR16_after_RD16_ANB))begin
									prev_CA=WR16;
									prev_BA=BA;
                                    time_of_last_wr_or_rd=$time;
                                    type_last_wr_or_rd=WR16;
                                    BA_of_last_wr_or_rd=BA;
									we_have_WR_before=1;
                                  //$display("at time=%0t,i'am in WR16",$time);
								end
                              else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve WR16") //$error("Failed to Recieve WR16");
							end
							MRR:begin
								if (($time-time_of_last_wr_or_rd<=`max_WR16orMWR_after_MRR_ANB)&&($time-time_of_last_wr_or_rd>=`min_WR16orMWR_after_MRR_ANB))begin
									prev_CA=WR16;
									prev_BA=BA;
                                    time_of_last_wr_or_rd=$time;
                                    type_last_wr_or_rd=WR16;
                                    BA_of_last_wr_or_rd=BA;
									we_have_WR_before=1;
                                  //$display("at time=%0t,i'am in WR16",$time);
								end
                              else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve WR16")//$error("Failed to Recieve WR16");
							end
							PRE:begin
                              if (prev_BA==BA) `uvm_error("gp_lpddr5_monitor", "Failed to Recieve WR16") //$error("Failed to Recieve WR16");
								else begin
									prev_CA=WR16;
									prev_BA=BA;
                                    type_last_wr_or_rd=WR16;
                                    BA_of_last_wr_or_rd=BA;
									we_have_WR_before=1;
                                  //$display("at time=%0t,i'am in WR16",$time);
								end
                              //$error("Failed to Recieve WR16 after precharge");
							end
                            ACT2:begin
                                case(type_last_wr_or_rd)
                                    WR16:begin
                                        if (($time-time_of_last_wr_or_rd<=`max_WR16_after_WR16_ANB)&&($time-time_of_last_wr_or_rd>=`min_WR16_after_WR16_ANB))begin
                                            prev_CA=WR16;
                                            prev_BA=BA;
                                            time_of_last_wr_or_rd=$time;
                                            type_last_wr_or_rd=WR16;
                                            BA_of_last_wr_or_rd=BA;
											we_have_WR_before=1;
                                        end
                                        else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve WR16") //$error("Failed to Recieve WR16");                                      
                                    end
                                    MWR:begin
                                        if (($time-time_of_last_wr_or_rd<=`max_WR16_after_MWR_ANB)&&($time-time_of_last_wr_or_rd>=`min_WR16_after_MWR_ANB))begin
                                            prev_CA=WR16;
                                            prev_BA=BA;
                                            time_of_last_wr_or_rd=$time;
                                            type_last_wr_or_rd=WR16;
                                            BA_of_last_wr_or_rd=BA;
											we_have_WR_before=1;
                                        end
                                        else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve WR16") //$error("Failed to Recieve WR16");
                                    end
									MRR:begin
										if (($time-time_of_last_wr_or_rd<=`max_WR16orMWR_after_MRR_ANB)&&($time-time_of_last_wr_or_rd>=`min_WR16orMWR_after_MRR_ANB))begin
											prev_CA=WR16;
											prev_BA=BA;
											time_of_last_wr_or_rd=$time;
											type_last_wr_or_rd=WR16;
											BA_of_last_wr_or_rd=BA;
											we_have_WR_before=1;
										//$display("at time=%0t,i'am in WR16",$time);
										end
									    else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve WR16")//$error("Failed to Recieve WR16");
									end
                                    RD16:begin
                                        if (($time-time_of_last_wr_or_rd<=`max_WR16_after_RD16_ANB)&&($time-time_of_last_wr_or_rd>=`min_WR16_after_RD16_ANB))begin
                                                prev_CA=WR16;
                                                prev_BA=BA;
                                                time_of_last_wr_or_rd=$time;
                                                type_last_wr_or_rd=WR16;
                                                BA_of_last_wr_or_rd=BA;
												we_have_WR_before=1;
                                            //$display("at time=%0t,i'am in WR16",$time);
                                        end
                                        else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve WR16") //$error("Failed to Recieve WR16");
                                    end
                                endcase
                            end
                            default: `uvm_error("gp_lpddr5_monitor", "Failed to Recieve WR16") //$error("Failed to Recieve WR16");
						endcase
					end
					else if (prev_CA==CAS_WR && (($time-time_of_last_cas_wr)==`tcas_wr)) begin
						prev_CA=WR16;
						prev_BA=BA;
                        time_of_last_wr_or_rd=$time;
                        type_last_wr_or_rd=WR16;
                        BA_of_last_wr_or_rd=BA;
						we_have_WR_before=1;
                      //$display("at time=%0t,i'am in WR16",$time);
					end
                    else  `uvm_error("gp_lpddr5_monitor", "Failed to Recieve WR16") //$error("Failed to Recieve WR16");
				end
              else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve WR16") //$error("Failed to Recieve WR16");
			end
			MWR:begin
              if ((($time-act2_time[BA])>=$ceil(`tRCD/`tCK)*`tCK) && (bank_state[BA]==BANK_ACTIVE)) begin
					if (prev_CA!=CAS_WR) begin
						case (prev_CA) 
							WR16:begin
                              if ((BA_of_last_wr_or_rd==BA) && ($time-time_of_last_wr_or_rd<=`max_MWR_after_WR16_SB)&&($time-time_of_last_wr_or_rd>=`min_MWR_after_WR16_SB)) begin
									prev_CA=MWR;
									prev_BA=BA;
                                    time_of_last_wr_or_rd=$time;
                                    type_last_wr_or_rd=MWR;
                                    BA_of_last_wr_or_rd=BA;
									we_have_WR_before=1;
								end
								else if ((BA_of_last_wr_or_rd!=BA) && ($time-time_of_last_wr_or_rd<=`max_MWR_after_WR16_DB)&&($time-time_of_last_wr_or_rd>=`min_MWR_after_WR16_DB)) begin
									prev_CA=MWR;
									prev_BA=BA;
                                    time_of_last_wr_or_rd=$time;
                                    type_last_wr_or_rd=MWR;
                                    BA_of_last_wr_or_rd=BA;
									we_have_WR_before=1;
								end
                              else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve MWR") //$error("Failed to Recieve MWR");
							end
							MWR:begin
								if ((BA_of_last_wr_or_rd==BA) && ($time-time_of_last_wr_or_rd<=`max_MWR_after_MWR_SB)&&($time-time_of_last_wr_or_rd>=`min_MWR_after_MWR_SB)) begin
									prev_CA=MWR;
									prev_BA=BA;
                                    time_of_last_wr_or_rd=$time;
                                    type_last_wr_or_rd=MWR;
                                    BA_of_last_wr_or_rd=BA;
									we_have_WR_before=1;
								end
								else if ((BA_of_last_wr_or_rd!=BA) && ($time-time_of_last_wr_or_rd<=`max_MWR_after_MWR_DB)&&($time-time_of_last_wr_or_rd>=`min_MWR_after_MWR_DB)) begin
									prev_CA=MWR;
									prev_BA=BA;
                                    time_of_last_wr_or_rd=$time;
                                    type_last_wr_or_rd=MWR;
                                    BA_of_last_wr_or_rd=BA;
									we_have_WR_before=1;
									//$display("i'am in MWR2");
								end
                                  else if (BA_of_last_wr_or_rd!=BA &&  $time-time_of_last_wr_or_rd>=`max_MWR_after_MWR_DB) begin
									  `uvm_error("gp_lpddr5_monitor", "Failed to Recieve MWR") //$error("Failed to Recieve MWR");
								  end
							end
							MRR:begin
								if (($time-time_of_last_wr_or_rd<=`max_WR16orMWR_after_MRR_ANB)&&($time-time_of_last_wr_or_rd>=`min_WR16orMWR_after_MRR_ANB))begin
									prev_CA=MWR;
									prev_BA=BA;
                                    time_of_last_wr_or_rd=$time;
                                    type_last_wr_or_rd=MWR;
                                    BA_of_last_wr_or_rd=BA;
									we_have_WR_before=1;
                                  //$display("at time=%0t,i'am in WR16",$time);
								end
                                else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve MWR") //$error("Failed to Recieve WR16");
							end
							RD16:begin
								if (($time-time_of_last_wr_or_rd<=`max_MWR_after_RD16_ANB)&&($time-time_of_last_wr_or_rd>=`min_MWR_after_RD16_ANB))begin
									prev_CA=MWR;
									prev_BA=BA;
                                    time_of_last_wr_or_rd=$time;
                                    type_last_wr_or_rd=MWR;
                                    BA_of_last_wr_or_rd=BA;
									we_have_WR_before=1;
								end
                              else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve MWR") //$error("Failed to Recieve MWR");
							end
							PRE:begin
                              if (prev_BA==BA) `uvm_error("gp_lpddr5_monitor", "Failed to Recieve MWR") //$error("Failed to Recieve MWR");
								else begin
									bank_state[BA]= MASKWRITE;
									prev_CA=MWR;
									prev_BA=BA;
									we_have_WR_before=1;
								end
							end
                            ACT2:begin
                                case(type_last_wr_or_rd)
                                    WR16:begin
                                        if ((BA_of_last_wr_or_rd!=BA) && ($time-time_of_last_wr_or_rd<=`max_MWR_after_WR16_DB)&&($time-time_of_last_wr_or_rd>=`min_MWR_after_WR16_DB)) begin
                                            prev_CA=MWR;
                                            prev_BA=BA;
                                            time_of_last_wr_or_rd=$time;
                                            type_last_wr_or_rd=MWR;
                                            BA_of_last_wr_or_rd=BA;
											we_have_WR_before=1;
                                        end
                                        else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve MWR") //$error("Failed to Recieve MWR");
                                    end
                                    MWR:begin
                                        if ((BA_of_last_wr_or_rd!=BA) && ($time-time_of_last_wr_or_rd<=`max_MWR_after_MWR_DB)&&($time-time_of_last_wr_or_rd>=`min_MWR_after_MWR_DB)) begin
                                            prev_CA=MWR;
                                            prev_BA=BA;
                                            time_of_last_wr_or_rd=$time;
                                            type_last_wr_or_rd=MWR;
                                            BA_of_last_wr_or_rd=BA;
											we_have_WR_before=1;
                                        end
                                        else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve MWR") //$error("Failed to Recieve MWR");
                                    end
									MRR:begin
										if (($time-time_of_last_wr_or_rd<=`max_WR16orMWR_after_MRR_ANB)&&($time-time_of_last_wr_or_rd>=`min_WR16orMWR_after_MRR_ANB))begin
											prev_CA=MWR;
											prev_BA=BA;
											time_of_last_wr_or_rd=$time;
											type_last_wr_or_rd=MWR;
											BA_of_last_wr_or_rd=BA;
											we_have_WR_before=1;
										//$display("at time=%0t,i'am in WR16",$time);
										end
										else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve MWR") //$error("Failed to Recieve WR16");
									end
                                    RD16:begin
                                        if (($time-time_of_last_wr_or_rd<=`max_MWR_after_RD16_ANB)&&($time-time_of_last_wr_or_rd>=`min_MWR_after_RD16_ANB))begin
                                            prev_CA=MWR;
                                            prev_BA=BA;
                                            time_of_last_wr_or_rd=$time;
                                            type_last_wr_or_rd=MWR;
                                            BA_of_last_wr_or_rd=BA;
											we_have_WR_before=1;
                                        end
                                        else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve MWR") //$error("Failed to Recieve MWR");
                                    end
                                endcase
                            end
                            default: `uvm_error("gp_lpddr5_monitor", "Failed to Recieve MWR") //$error("Failed to Recieve MWR");
						endcase
					end
					else if (prev_CA==CAS_WR && (($time-time_of_last_cas_wr)==`tcas_wr)) begin
						prev_CA=MWR;
						prev_BA=BA;
                        time_of_last_wr_or_rd=$time;
                        type_last_wr_or_rd=MWR;
                        BA_of_last_wr_or_rd=BA;
						we_have_WR_before=1;
						//$display("at time =%0t i'am in MWR3",$time);
					end
					else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve MWR") //$error("Failed to Recieve MWR");
				end
              else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve MWR") //$error("Failed to Recieve MWR");
			end
			RD16:begin
              if ((($time-act2_time[BA])>=$ceil(`tRCD/`tCK)*`tCK) && (bank_state[BA]==BANK_ACTIVE)) begin
				if (prev_CA!=CAS_RD) begin
						case (prev_CA) 
							RD16:begin
								if (($time-time_of_last_wr_or_rd<=`max_RD16_after_RD16_ANB)&&($time-time_of_last_wr_or_rd>=`min_RD16_after_RD16_ANB))begin
									prev_CA=RD16;
									prev_BA=BA;
                                    time_of_last_wr_or_rd=$time;
                                    type_last_wr_or_rd=RD16;
                                    BA_of_last_wr_or_rd=BA;
								end
                              else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve RD16") //$error("Failed to Recieve RD16");
							end
							PRE:begin
                              if (prev_BA==BA) `uvm_error("gp_lpddr5_monitor", "Failed to Recieve RD16") //$error("Failed to Recieve RD16");
								else begin
									prev_CA=RD16;
									prev_BA=BA;
									type_last_wr_or_rd=RD16;
                                    BA_of_last_wr_or_rd=BA;
								end
							end
                            ACT2:begin
                                case(type_last_wr_or_rd)
                                RD16:begin
                                    if (($time-time_of_last_wr_or_rd<=`max_RD16_after_RD16_ANB)&&($time-time_of_last_wr_or_rd>=`min_RD16_after_RD16_ANB))begin
                                        prev_CA=RD16;
                                        prev_BA=BA;
                                        time_of_last_wr_or_rd=$time;
                                        type_last_wr_or_rd=RD16;
                                        BA_of_last_wr_or_rd=BA;
                                    end
                                    else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve RD16") //$error("Failed to Recieve RD16");
                                end
                                endcase
                            end
                              default: `uvm_error("gp_lpddr5_monitor", "Failed to Recieve RD16") //$error("Failed to Recieve RD16");
						endcase
					end
					else if (prev_CA==CAS_RD && (($time-time_of_last_cas_rd)==`tcas_rd)) begin
						if (we_have_WR_before && ($time-time_of_last_wr_or_rd>=`min_RD16_after_WR16_ANB) && ($time-time_of_last_wr_or_rd>=`min_RD16_after_MWR_ANB) )
						begin
							prev_CA=RD16;
							prev_BA=BA;
							time_of_last_wr_or_rd=$time;
							type_last_wr_or_rd=RD16;
							BA_of_last_wr_or_rd=BA;
						end
						else begin
							prev_CA=RD16;
							prev_BA=BA;
							time_of_last_wr_or_rd=$time;
							type_last_wr_or_rd=RD16;
							BA_of_last_wr_or_rd=BA;
						end
					end
					else begin
						`uvm_error("gp_lpddr5_monitor", "Failed to Recieve RD16") // $error("Failed to Recieve RD16");
					end
              end
              else begin
				 `uvm_error("gp_lpddr5_monitor", "Failed to Recieve RD16") //$error("Failed to Recieve RD16");
			  end
			end
			MRR:begin
				case (prev_CA)
				MRR:begin
					if (($time-time_of_last_wr_or_rd>=`min_MRR_after_MRR_ANB) && ($time-time_of_last_wr_or_rd>=`min_MRR_after_MRR_ANB)) begin
						    prev_CA=MRR;
							prev_BA=BA;
							time_of_last_wr_or_rd=$time;
							type_last_wr_or_rd=MRR;
							BA_of_last_wr_or_rd=BA;
					end
					else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve MRR") //$error("Failed to Recieve MRR");
				end
				CAS_RD:begin
					if (($time-time_of_last_cas_rd)==`tcas_rd) begin
						    prev_CA=MRR;
							prev_BA=BA;
							time_of_last_wr_or_rd=$time;
							type_last_wr_or_rd=MRR;
							BA_of_last_wr_or_rd=BA;
					end
					else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve MRR") //$error("Failed to Recieve MRR");
				end
				endcase
			end
			PRE:begin
              if(($time-act2_time[BA]>=$ceil(`tRAS/`tCK)*`tCK) && (bank_state[BA]==BANK_ACTIVE)) begin
					case(type_last_wr_or_rd)
				    WR16:begin
						if ($time-time_of_last_wr_or_rd>=(`WL+`BL_nmax+1+$ceil(`tWR/`tCK))*`tCK) begin
							prev_CA=PRE;
							prev_BA=BA;
							not_first_precharge[BA]=1;
							PRE_time[16]=$time;
						end
						else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve  PRE") //$error("Failed to Recieve PRE");
					end
					MWR:begin
						if ($time-time_of_last_wr_or_rd>=(`WL+`BL_nmax+1+$ceil(`tWR/`tCK))*`tCK) begin
							prev_CA=PRE;
							prev_BA=BA;
							not_first_precharge[BA]=1;
							PRE_time[16]=$time;
						end
						else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve  PRE") //$error("Failed to Recieve PRE");
					end
					RD16:begin
						if ($time-time_of_last_wr_or_rd>=(`BL_nmax+$ceil(`tRBTP/`tCK))*`tCK) begin
							prev_CA=PRE;
							prev_BA=BA;
							not_first_precharge[BA]=1;
							PRE_time[16]=$time;
						end
						else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve  PRE") //$error("Failed to Recieve PRE");
					end
					endcase
				end
				else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve  PRE") //$error("Failed to Recieve PRE");
			end
			RD16:begin
              if ((($time-act2_time[BA])>=$ceil(`tRCD/`tCK)*`tCK) && (bank_state[BA]==BANK_ACTIVE)) begin
				if (prev_CA!=CAS_RD) begin
						case (prev_CA) 
							RD16:begin
								if (($time-time_of_last_wr_or_rd<=`max_RD16_after_RD16_ANB)&&($time-time_of_last_wr_or_rd>=`min_RD16_after_RD16_ANB))begin
									prev_CA=RD16;
									prev_BA=BA;
                                    time_of_last_wr_or_rd=$time;
                                    type_last_wr_or_rd=RD16;
                                    BA_of_last_wr_or_rd=BA;
								end
                              else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve RD16") //$error("Failed to Recieve RD16");
							end
							PRE:begin
                              if (prev_BA==BA) `uvm_error("gp_lpddr5_monitor", "Failed to Recieve RD16") //$error("Failed to Recieve RD16");
								else begin
									prev_CA=RD16;
									prev_BA=BA;
									type_last_wr_or_rd=RD16;
                                    BA_of_last_wr_or_rd=BA;
								end
							end
                            ACT2:begin
                                case(type_last_wr_or_rd)
                                RD16:begin
                                    if (($time-time_of_last_wr_or_rd<=`max_RD16_after_RD16_ANB)&&($time-time_of_last_wr_or_rd>=`min_RD16_after_RD16_ANB))begin
                                        prev_CA=RD16;
                                        prev_BA=BA;
                                        time_of_last_wr_or_rd=$time;
                                        type_last_wr_or_rd=RD16;
                                        BA_of_last_wr_or_rd=BA;
                                    end
                                    else `uvm_error("gp_lpddr5_monitor", "Failed to Recieve RD16") //$error("Failed to Recieve RD16");
                                end
                                endcase
                            end
                              default: `uvm_error("gp_lpddr5_monitor", "Failed to Recieve RD16") //$error("Failed to Recieve RD16");
						endcase
					end
					else if (prev_CA==CAS_RD && (($time-time_of_last_cas_rd)==`tcas_rd)) begin
						if (we_have_WR_before && ($time-time_of_last_wr_or_rd>=`min_RD16_after_WR16_ANB) && ($time-time_of_last_wr_or_rd>=`min_RD16_after_MWR_ANB) )
						begin
							prev_CA=RD16;
							prev_BA=BA;
							time_of_last_wr_or_rd=$time;
							type_last_wr_or_rd=RD16;
							BA_of_last_wr_or_rd=BA;
						end
						else begin
							prev_CA=RD16;
							prev_BA=BA;
							time_of_last_wr_or_rd=$time;
							type_last_wr_or_rd=RD16;
							BA_of_last_wr_or_rd=BA;
						end
					end
					else begin
						`uvm_error("gp_lpddr5_monitor", "Failed to Recieve RD16") // $error("Failed to Recieve RD16");
					end
              end
              else begin
				 `uvm_error("gp_lpddr5_monitor", "Failed to Recieve RD16") //$error("Failed to Recieve RD16");
			  end
			end
          default: begin
              //do nothing this means it's another command that out of the scope of this task
          end
		endcase
	endtask

	task run_phase(uvm_phase phase);
		int counter = 0;
		item = wav_DFI_write_transfer::type_id::create("item", this);

		phase.raise_objection(this);
		`uvm_info(get_name(), "LPDDR5 monitor started, objection raised.", UVM_NONE)
		
		fork 
			forever begin
				@(posedge ch0_vif.ck_t) begin
					ALL_BANKS = 0;
					AUTO_PRECHARGE = 0;
					foreach(bank_state[bank]) if(bank_state[bank] == PRECHARGING)  bank_state[bank]=IDLE;

					casex({ch0_vif.cs, ch0_vif.ca})
						{1'b0, 7'bxxxxxxx}: begin
							next_CA = DES;
						end 
						{1'b1, 7'b0000000}: begin
							next_CA = NOP;
						end
						{1'b1, 7'b0000001}: begin
							next_CA = PDE;
							$display("entered");
						end
						{1'b1, 7'b111xxxx}: begin
							next_CA = ACT1;
						end
						{1'b1, 7'b110xxxx}: begin
							next_CA = ACT2;
						end
						{1'b1, 7'b0001111}: begin
							next_CA = PRE;
						end
						{1'b1, 7'b0001110}: begin
							next_CA = REF;
						end
						{1'b1, 7'b010xxxx}: begin
							next_CA = MWR;
						end
						{1'b1, 7'b011xxxx}: begin
							next_CA = WR16;
							`uvm_info("LPDDR5_monitor","WR16", UVM_MEDIUM)
						end
						{1'b1, 7'b0010xxx}: begin
							next_CA = WR32;
							`uvm_info("LPDDR5_monitor","WR16", UVM_MEDIUM)
						end
						{1'b1, 7'b100xxxx}: begin
							next_CA = RD16;
						end
						{1'b1, 7'b101xxxx}: begin
							next_CA = RD32;
						end
						// {1'b1, 7'b0011xxx}: begin
						// 	next_CA = CAS;
						// end
						{1'b1, 7'b0011100}: begin
							next_CA = CAS_WR;
						end
						{1'b1, 7'b0011010}: begin
							next_CA = CAS_RD;
						end
						{1'b1, 7'b0011001}: begin
							next_CA = CAS_FS;
						end
						{1'b1, 7'b0011111}: begin
							next_CA = CAS_OFF;
						end
						{1'b1, 7'b000011x}: begin
							next_CA = MPC;
						end
						{1'b1, 7'b0001011}: begin
							next_CA = SRE;
						end
						{1'b1, 7'b0010xxx}: begin
							next_CA = SRX;
						end
						{1'b1, 7'b0001101}: begin
							next_CA = MRW1;
						end
						{1'b1, 7'b000100x}: begin
							next_CA = MRW2;
						end
						{1'b1, 7'b0001100}: begin
							next_CA = MRR;
						end
						{1'b1, 7'b0000011}: begin
							next_CA = WFF;
						end
						{1'b1, 7'b0000010}: begin
							next_CA = RFF;
						end
						{1'b1, 7'b0000101}: begin
							next_CA = RDC;
						end 
						default: if(ch0_vif.cs) `uvm_warning("gp_LPDDR5_monitor", "Recieved unknown command on CA bus")
					endcase
					if(ch0_vif.DQ !== 16'hzzzz) begin 
						counter += 1;
						//`uvm_info("gp_LPDDR5_monitor", $psprintf("counter = %d", counter), UVM_NONE)
					end
					//`uvm_info("gp_LPDDR5_monitor", $psprintf("DQ = %h", ch0_vif.DQ), UVM_NONE)
					// `uvm_info("gp_LPDDR5_monitor", $psprintf("next_CA %b", ch0_vif.ca), UVM_NONE)
					// `uvm_info("gp_LPDDR5_monitor", next_CA.name, UVM_NONE)
				end 
				@(negedge ch0_vif.ck_t) begin
					// ziad_checks();
					prev_CA = CA;
					CA = next_CA;
					prev_BA = BA;
					BA={ch0_vif.ca3, ch0_vif.ca2, ch0_vif.ca1, ch0_vif.ca0};
					ALL_BANKS = ch0_vif.ca6;
					case(next_CA)
						PRE: begin
							bank_state[BA] = PRECHARGING;
							assert(!$isunknown(ch0_vif.ca4) && !$isunknown(ch0_vif.ca4)) begin
								`uvm_warning("gp_LPDDR5_monitor", "Invalid signals are supposed to be valid")
							end 
						end
						PDE:begin
							if((($time - time_SRE) <2*nck ))
								// || ((CA != (REF || PRE)) && !AUTO_PRECHARGE)
								// || (($time - time_last_read) < (`RL + RU*((tWCK2CK + tWCKDQO)/tCK) + BL/8 +1))
								// || (($time - time_last_write) < (WL + RU*((tWCK2CK + tWCKDQI)/tCK) + BL/8 +1)) 
								// || (($time - time_last_MW_with_auto) < ( WL + RU*((tWCK2CK + tWCKDQI)/tCK) + nWR + BL/8 +1))
								// || (($time - time_last_MRR) < (`RL + RU*((tWCK2CK + tWCKDQO)/tCK) + nWR + BL/8 +1)) 
								// || (($time - time_last_command) < (tCMDPD)) 
								// || (($time - time_last_MRW) < (tMRWPD))
								// || (($time - time_SRE) < tESPD) )
									`uvm_error("gp_lpddr5_monitor", "Cannot enter power down")
								else
								begin
									time_PDE = $time;
									CA = PDE;
									cov_trans_item.CA = CA;
									subscriber_port_item.write(cov_trans_item);
									if (CA == SRE) bank_state = '{default:SELF_REFRESH_POWER_DOWN};
									else bank_state = '{default:IDLE_POWER_DOWN};
									$display("entered power down");
									while(1) begin
										@(ch0_vif.cs)begin //wait for cs to toggle for DSX
											if( ($time - time_PDE) < tCSPD ) begin
												`uvm_error("gp_lpddr5_monitor", "Cannot exit power down too soon")
												$display("%0t, %0t, %0t", $time, time_PDE, tCSPD);
											end
											else begin
												time_PDX = $time;
												bank_state = '{default:IDLE};
												$display("OUTT, %t", $time);
												CA = SRE;
												break;
											end
										end
										cov_trans_item.CA = CA;
										subscriber_port_item.write(cov_trans_item);
									end	
								end
						end
						ACT1:begin end
						ACT2:begin end
						PRE:begin end
						REF:begin
							if (ch0_vif.ca6 == 0) begin
								// if(bank_mode == 4)
								// begin
								`ifdef BG_MODE
									if((is_refreshed[BG][BA]) || (bank_state[BG][BA] != IDLE) 
										|| (($time - time_refresh_all_bank) < tRFCab )
										|| (($time - time_refresh_per_bank[BG][BA]) < tRFCpb )
										|| (($time - time_last_refresh_per_bank) < tpbR2pbR)
										|| (($time - time_bank_precharge[BG][BA]) < tRP )
										|| (($time - time_bank_precharge[BG][BA]) < tRRD ))
										`uvm_error("gp_lpddr5_monitor", "Cannot refresh this bank untill all other banks are refreshed")
									else
									begin
										is_refreshed[BG][BA] = 1;
										time_refresh_per_bank[BG][BA] = $time;
										bank_state[BG][BA] = PER_BANK_REFRESH;
										CA = REF;
										time_last_refresh_per_bank = $time;
										if(is_refreshed == '1)
										begin
											flag_BG_refresh_commands_done = 1;
											is_refreshed = '0;
										end
										#tRFCpb bank_state = IDLE;
									end
								// end
								`elsif
								
								// if(bank_mode == 16)
								// begin
									if((is_refreshed[BA]) || (bank_state[BA] != IDLE) 
										|| (($time - time_refresh_all_bank) < tRFCab )
										|| (($time - time_refresh_per_bank[BA]) < tRFCpb )
										|| (($time - time_last_refresh_per_bank) < tpbR2pbR)
										|| (($time - time_bank_precharge[BA]) < tRP )
										|| (($time - time_bank_precharge[BA]) < tRRD ))
										`uvm_error("gp_lpddr5_monitor", "Cannot refresh this bank untill all other banks are refreshed")
									else
									begin
										is_refreshed[BA] = 1;
										time_refresh_per_bank[BA] = $time;
										bank_state [BA]= PER_BANK_REFRESH;
										CA = REF;
										time_last_refresh_per_bank = $time;
										if(is_refreshed == '1)
										begin
											flag_16_refresh_commands_done = 1;
											is_refreshed = '0;
										end
										#tRFCpb bank_state = IDLE;
									end
								// end
								`endif
							end
							else if (ch0_vif.ca6 == 1) // ALL BANK refresh
							begin
								// if(bank_mode == 4) begin
								`ifdef BG_MODE
									if ((bank_state != '{IDLE}) 
										|| (($time - time_last_refresh_per_bank) < tRFCpb )
										|| (($time - time_refresh_all_bank) < tpbR2pbR )
										|| (($time - time_refresh_all_bank) < tRFCab )
										|| (($time - time_bank_precharge[BG][BA]) < tRP )) //precharge to all?
										`uvm_error("gp_lpddr5_monitor", "Cannot refresh this bank untill all other banks are refreshed")
									else 
										begin
										bank_state = ALL_BANK_REFRESH;
										CA = REF;
										time_refresh_all_bank = $time;
										flag_all_bank_refresh_commands_done = 1;
										#tRFCab bank_state = IDLE;
										end
								// end
								// else begin
								`else
									if ((bank_state != '{default:IDLE}) 
									|| (($time - time_last_refresh_per_bank) < tRFCpb )
									|| (($time - time_refresh_all_bank) < tpbR2pbR )
									|| (($time - time_refresh_all_bank) < tRFCab )
									|| (($time - time_bank_precharge[BA]) < tRP )) //precharge to all?
									`uvm_error("gp_lpddr5_monitor", "Cannot enter all bank refresh")
									else 
										begin
										bank_state = '{default:ALL_BANK_REFRESH};
										CA = REF;
										time_refresh_all_bank = $time;
										flag_all_bank_refresh_commands_done = 1;
										#tRFCab bank_state = '{default:IDLE};
										end
								// end
								`endif
							end	
						end			
						MWR:begin
							// if (flag_wck_off) begin
							// 	while($time < (time_WR_command + tWCKPRE_Static + tWCKPRE_Toggle_WR)) 
							// 	begin
							// 		if($isunknown(ch0_vif.dq0_wck_t))
							// 			`uvm_error("gp_lpddr5_monitor", "WCK error")
							// 	end
							// end
							// i = 0;
							// if(bank_mode == 8) begin
							// repeat(16) begin
							// 	@(posedge ch0_vif.dq0_wck_t)begin
							// 		// item.data[j][i] = DQ[i];
							// 		//TODO fix this @ Nada
							// 		i++;
							// 	end
							// end
							// end
							// else begin
							// repeat(16) begin
							// 	@(posedge ch0_vif.dq0_wck_t)begin
							// 		// item.data[j][i] = DQ[i];
							// 		//TODO fix this @ Nada
							// 		i++;
							// 	end
							// end
							// end
							// j++;
							// if(j == 4)begin
							// 	recieved_transaction.write(item); 
							// 	i = 0; 
							// end
						end
						WR16:begin
							//while(1) begin
								//while($isunknown(ch0_vif.dq0))begin end
									//$display("%0d", i);
									// uvm_config_db #(int) :: wait_modified(this, "", "ratio");
									// uvm_config_db #(int) :: get(this, "", "ratio", ratio);
									// $display("nada__ratio %0d", ratio);
									if(ratio != 0) while(1) begin 
										@(ch0_vif.dq0_wck_t)begin
											if (ch0_vif.DQ[0] == 1'b1 || ch0_vif.DQ[1] == 1'b1|| ch0_vif.DQ[2] == 1'b1|| ch0_vif.DQ[3] == 1'b1 || ch0_vif.DQ[4] == 1'b1
											|| ch0_vif.DQ[5] == 1'b1 || ch0_vif.DQ[6] == 1'b1 || ch0_vif.DQ[7] == 1'b1 || ch0_vif.DQ[8] == 1'b1 || ch0_vif.DQ[9] == 1'b1
											|| ch0_vif.DQ[10] == 1'b1 || ch0_vif.DQ[11] == 1'b1 || ch0_vif.DQ[12] == 1'b1 || ch0_vif.DQ[13] == 1'b1 || ch0_vif.DQ[14] == 1'b1
											|| ch0_vif.DQ[15] == 1'b1) begin
													//$display("break");
													break;
												end
										end
									end
									//$display("OUT");
									////////////////////////// 2 to 1 /////////////////////////////////////
									if(ratio == 2) begin
										i=2;
										item.wrdata[i] = {16'h0000,ch1_vif.DQ, ch0_vif.DQ};
										@(ch0_vif.dq0_wck_t)begin
											i=0;
												item.wrdata[i] = {16'h0000,ch1_vif.DQ, ch0_vif.DQ};												
											end
									end
									///////////////////// 4 to 1 ////////////////////////////////////////
									if(ratio == 4) begin
										i = 1;
										item.wrdata[i][31:0] = {ch1_vif.DQ, ch0_vif.DQ};
										@(ch0_vif.dq0_wck_t)begin
												item.wrdata[i][63:32] = {ch1_vif.DQ, ch0_vif.DQ};
												i--;
											end
										@(ch0_vif.dq0_wck_t)begin
												item.wrdata[i][31:0] = {ch1_vif.DQ, ch0_vif.DQ};
											end
										@(ch0_vif.dq0_wck_t)begin
												item.wrdata[i][63:32] = {ch1_vif.DQ, ch0_vif.DQ};
											end
									end
									recieved_transaction.write(item); 
									//break;
							//end
									//j++;
									//if(j == 4)begin
										//i = 0; 
									//end
							end
						WR32:begin
							//while(1) begin
								//while($isunknown(ch0_vif.dq0))begin end
									//$display("%0d", i);
									// uvm_config_db #(int) :: wait_modified(this, "", "ratio");
									// uvm_config_db #(int) :: get(this, "", "ratio", ratio);
									// $display("nada__ratio %0d", ratio);
									while(1) begin 
										@(ch0_vif.dq0_wck_t)begin
											if (ch0_vif.DQ[0] == 1'b1 || ch0_vif.DQ[1] == 1'b1|| ch0_vif.DQ[2] == 1'b1|| ch0_vif.DQ[3] == 1'b1 || ch0_vif.DQ[4] == 1'b1
											|| ch0_vif.DQ[5] == 1'b1 || ch0_vif.DQ[6] == 1'b1 || ch0_vif.DQ[7] == 1'b1 || ch0_vif.DQ[8] == 1'b1 || ch0_vif.DQ[9] == 1'b1
											|| ch0_vif.DQ[10] == 1'b1 || ch0_vif.DQ[11] == 1'b1 || ch0_vif.DQ[12] == 1'b1 || ch0_vif.DQ[13] == 1'b1 || ch0_vif.DQ[14] == 1'b1
											|| ch0_vif.DQ[15] == 1'b1) begin
													//$display("break");
													break;
												end
										end
									end
									//$display("OUT");
									////////////////////////// 2 to 1 /////////////////////////////////////
									if(ratio == 2) begin
										i=2;
										item.wrdata[i] = {16'h0000,ch1_vif.DQ, ch0_vif.DQ};
										@(ch0_vif.dq0_wck_t)begin
											i=0;
												item.wrdata[i] = {16'h0000,ch1_vif.DQ, ch0_vif.DQ};												
											end
									end
									///////////////////// 4 to 1 ////////////////////////////////////////
									if(ratio == 4) begin
										i = 1;
										item.wrdata[i][31:0] = {ch1_vif.DQ, ch0_vif.DQ};
										@(ch0_vif.dq0_wck_t)begin
												item.wrdata[i][63:32] = {ch1_vif.DQ, ch0_vif.DQ};
												i--;
											end
										@(ch0_vif.dq0_wck_t)begin
												item.wrdata[i][31:0] = {ch1_vif.DQ, ch0_vif.DQ};
											end
										@(ch0_vif.dq0_wck_t)begin
												item.wrdata[i][63:32] = {ch1_vif.DQ, ch0_vif.DQ};
											end
									end
									recieved_transaction.write(item); 
									//break;
							//end
									//j++;
									//if(j == 4)begin
										//i = 0; 
									//end
							end
						RD16:begin end
						RD32:begin end
						// CAS:begin end
						MPC:begin 
							`uvm_info("gp_lpddr5_monitor", "Recieved MPC", UVM_MEDIUM)
						end
						SRE: begin 
							cov_trans_item.CA = CA;
							subscriber_port_item.write(cov_trans_item);	
							if({ch0_vif.ca5,ch0_vif.ca6} == 2'b10) begin
								if(bank_state != '{default:IDLE})	// deep sleep entry
								`uvm_error("gp_lpddr5_monitor", "Cannot enter deep sleep mode")
								else
								begin
									time_DSE = $time;
									bank_state = '{default:DEEP_SLEEP_MODE};
									while(1) begin
										@(ch0_vif.cs)begin //wait for cs to toggle for DSX
											if( ($time - time_SE) < tPDN )
												`uvm_error("gp_lpddr5_monitor", "Cannot exit deep sleep mode too soon")
											else begin
												time_DSX = $time;
												bank_state = '{default:IDLE};
												break;
											end
										end
									end
								
								end
							end
							if({ch0_vif.ca5,ch0_vif.ca6} == 2'b01) begin		// deep sleep entry with self refresh
								if( bank_state != '{default:IDLE})	
								`uvm_error("gp_lpddr5_monitor", "Cannot enter deep sleep mode")
								else
								begin
									time_DSE = $time;
									bank_state = '{default:DEEP_SLEEP_MODE};
									while(1) begin
										@(ch0_vif.cs)begin 	//wait for cs to toggle for DSX
											if( ($time - time_SE) < tPDN )
												`uvm_error("gp_lpddr5_monitor", "Cannot exit deep sleep mode too soon")
											else begin
												time_DSX = $time;
												bank_state = '{default:IDLE};
												break;
											end
										end
										cov_trans_item.CA = CA;
										subscriber_port_item.write(cov_trans_item);	
									end
								
								end
							end
							
							else begin //self refresh
								if(bank_state != '{default:IDLE})
									`uvm_error("gp_lpddr5_monitor", "Error in self refresh")
								else
								begin
									flag_8_refresh_commands_done 	    = 0;
									flag_16_refresh_commands_done 	    = 0;
									flag_all_bank_refresh_commands_done = 0;
									time_SRE = $time;
									bank_state = '{default:SELF_REFRESH};
								end
							end
						end
						SRX:begin
							cov_trans_item.CA = CA;
							subscriber_port_item.write(cov_trans_item);
							if(($time - time_DSX < tXSR_DSM) ||  ($time - time_SRE < tSR))
								`uvm_error("gp_lpddr5_monitor", "cannot exit self refresh")
							else begin
								flag_8_refresh_commands_done 	    = 1;
								flag_16_refresh_commands_done 	    = 1;
								flag_all_bank_refresh_commands_done = 1;
								time_SRX = $time;
								bank_state = '{default:IDLE};
							end
						end
						
						MRW1:begin 
							`uvm_info("gp_lpddr5_monitor","Recieved MRW1", UVM_MEDIUM)
						end
						MRW2:begin 
							`uvm_info("gp_lpddr5_monitor","Recieved MRW2", UVM_MEDIUM)
						end
						MRR:begin
							`uvm_info("gp_lpddr5_monitor","Recieved MRR", UVM_MEDIUM)
						 end
						WFF:begin
							`uvm_info("gp_lpddr5_monitor","Recieved WFF", UVM_MEDIUM)
						 end
						RFF:begin
							`uvm_info("gp_lpddr5_monitor","Recieved RFF", UVM_MEDIUM)
						 end
					endcase
					cov_trans_item.CA = CA;
					cov_trans_item.BA = BA;
					cov_trans_item.prev_BA = prev_BA;
					cov_trans_item.ALL_BANKS = ALL_BANKS;
					subscriber_port_item.write(cov_trans_item);
				end 

				//Here we put all the checkers that need to be completed after the command detection

				//Shibiny's checkers:
				fork : PPR_checker
					if(CA==MRW2 && MA==41 && OP[4]==1) begin
						time start;
						if(bank_state!='{default: IDLE}) begin
							`uvm_warning("PPR_checker", "Attempting to enter PPR mode while there are non-idle banks")
							disable PPR_checker;
						end
					
						start = $time;
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if((($time - start)/int'(`tCK) < `tMRD) || !(CA==MRW2 && MA==42 && OP==8'b1100_1111)) begin
							`uvm_warning("PPR_checker", "Guard key not entered correctly during Post Package Repair entry")
							disable PPR_checker;
						end
					
						start = $time;
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if((($time - start)/int'(`tCK) < `tMRD) || !(CA==MRW2 && MA==42 && OP==8'b0111_0011)) begin
							`uvm_warning("PPR_checker", "Guard key not entered correctly during Post Package Repair entry")
							disable PPR_checker;
						end
					
						start = $time;
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if((($time - start)/int'(`tCK) < `tMRD) || !(CA==MRW2 && MA==42 && OP==8'b1011_1011)) begin
							`uvm_warning("PPR_checker", "Guard key not entered correctly during Post Package Repair entry")
							disable PPR_checker;
						end
					
						start = $time;
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if((($time - start)/int'(`tCK) < `tMRD) || !(CA==MRW2 && MA==42 && OP==8'b0011_1011)) begin
							`uvm_warning("PPR_checker", "Guard key not entered correctly during Post Package Repair entry")
							disable PPR_checker;
						end
					
						start = $time;
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if((($time - start)/int'(`tCK) < `tMRD) || !(CA==ACT1)) begin
							`uvm_warning("PPR_checker", "Guard key not entered correctly during Post Package Repair entry")
							disable PPR_checker;
						end
					
						@(CA) 
						if (!(CA==ACT2)) begin
							`uvm_warning("PPR_checker", "Guard key not entered correctly during Post Package Repair entry")
							disable PPR_checker;
						end  

						`uvm_info("PPR_checker", "Entering 2 second simulation time for PPR programming", UVM_NONE)
						start = $time;
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if((($time - start)/int'(`tCK) < `tPGM) || !(CA==PRE)) begin
							`uvm_warning("PPR_checker", "Error during PPR")
							disable PPR_checker;
						end
					
						start = $time;
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if((($time - start)/int'(`tCK) < `tPGM_EXIT) || !(CA==MRW2 && MA==41 && OP[4]==0)) begin
							`uvm_warning("PPR_checker", "Error during PPR")
							disable PPR_checker;
						end
					
						start = $time;
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if((($time - start)/int'(`tCK) < `tPGM_PST) || ch0_vif.ddr_reset_n) begin
							`uvm_warning("PPR_checker", "Error during PPR")
							disable PPR_checker;
						end

						`uvm_info("PPR_checker", "PPR operation successful", UVM_LOW)
					end 
				join_none

				fork : TRR_checker
					if(CA==MRW2 && MA==27 && OP[7]==1) begin
						time start;
						if(bank_state!='{default: IDLE}) begin
							`uvm_warning("TRR_checker", "Attempting to enter TRR mode while there are non-idle banks")
							disable TRR_checker;
						end
		
						start = $time;
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if((($time - start)/int'(`tCK) < `tMRD) || !(CA==ACT1)) begin
							`uvm_warning("TRR_checker", "Error during TRR")
							disable TRR_checker;
						end
						@(CA) 
						if (!(CA==ACT2)) begin
							`uvm_warning("TRR_checker", "ACT1 not followed by ACT2")
							disable TRR_checker;
						end
		
						start = $time;
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if((($time - start)/int'(`tCK) < `tRAS*1.5) || !(CA==PRE)) begin
							`uvm_warning("TRR_checker", "Error during TRR")
							disable TRR_checker;
						end
		
						start = $time;
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if((($time - start)/int'(`tCK) < `tRP) || !(CA==ACT1)) begin
							`uvm_warning("TRR_checker", "Error during TRR")
							disable TRR_checker;
						end
						@(CA) 
						if (!(CA==ACT2)) begin
							`uvm_warning("TRR_checker", "ACT1 not followed by ACT2")
							disable TRR_checker;
						end
		
						start = $time;
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if((($time - start)/int'(`tCK) < `tRAS) || !(CA==PRE)) begin
							`uvm_warning("TRR_checker", "Error during TRR")
							disable TRR_checker;
						end
		
						start = $time;
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if((($time - start)/int'(`tCK) < `tRP) || !(CA==ACT1)) begin
							`uvm_warning("TRR_checker", "Error during TRR")
							disable TRR_checker;
						end
						@(CA) 
						if (!(CA==ACT2)) begin
							`uvm_warning("TRR_checker", "ACT1 not followed by ACT2")
							disable TRR_checker;
						end
		
						start = $time;
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if((($time - start)/int'(`tCK) < `tRAS) || !(CA==PRE)) begin
							`uvm_warning("TRR_checker", "Error during TRR")
							disable TRR_checker;
						end
		
						start = $time;
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if(($time - start)/int'(`tCK) < (`tRP+`tMRD)) begin
							`uvm_warning("TRR_checker", "Error during TRR")
							disable TRR_checker;
						end
		
						`uvm_info("TRR_checker", "TRR operation successful", UVM_LOW)
					end 
				join_none
				
				fork : PRE_timing_checker
					int start;
					if(CA==ACT2) begin
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if(CA==PRE) begin
							if(BA == prev_BA) begin
								if(($time - start)/int'(`tCK) < $ceil(real'(`tRAS)/real'(`tCK))) begin
									`uvm_warning("PRE_timing_checker", "Timing violation between ACT2 and PRE (same bank)")
								end
							end
						end
					end 

					if(CA==RD16 || CA==RD32) begin
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if(CA==PRE) begin
							if(BA == prev_BA) begin
								if(($time - start)/int'(`tCK) < (`BLn_min+$ceil(real'(`tRBTP)/`tCK))) begin
									`uvm_warning("PRE_timing_checker", "Timing violation between RD16/32 and PRE (same bank)")
								end
							end
						end
					end 

					if(CA==WR16 || CA==WR32 || CA==MWR) begin
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if(CA==PRE) begin
							if(BA == prev_BA) begin
								if(($time - start)/int'(`tCK) < (`WL+1+`BLn_min+$ceil(real'(`tWR)/`tCK))) begin
									`uvm_warning("PRE_timing_checker", "Timing violation between WR16/32 & MWR and PRE (same bank)")
								end
							end
						end
					end 

					if(CA==PRE) begin
						while(1) begin
							@(CA) begin
								if(!(CA == DES || CA == NOP)) break;
							end 
						end
						if(CA==ACT1) begin
							if(BA == prev_BA) begin
								if(($time - start)/int'(`tCK) < $ceil(real'(`tRP)/real'(`tCK))) begin
									`uvm_warning("PRE_timing_checker", "Timing violation between PRE and ACT1 (same bank)")
								end
							end
						end
					end 
				join_none
				
				`ifdef BG_MODE
				fork : AUTO_PRECHARGE_checkers
					if(AUTO_PRECHARGE == 1) begin
						if(CA==RD16 || CA==RD32) begin
							while(1) begin
								@(CA) begin
									if(!(CA == DES || CA == NOP)) break;
								end 
							end

							if(BA == prev_BA) begin
								if(CA==ACT1) begin
									if(($time - start)/int'(`tCK) < (`BLn_min + `nRBTP + $ceil(real'(`tRPpb)/real'(`tCK)))) begin
										`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between RD16/RD32(with AP) and ACT (same bank)")
									end
								end
								else if (CA==PRE) begin
									if(($time - start)/int'(`tCK) < (`BLn_min + `nRBTP)) begin
										`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between RD16/RD32(with AP) and PRE (same bank)")
									end
								end
							end 
							
							else if(BA[3:2] == prev_BA[3:2]) begin
								if(CA==RD16 || CA==RD32) begin
									if(($time - start)/int'(`tCK) < (`BLn)) begin
										`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between RD16/RD32(with AP) and RD16/RD32 (different bank)")
									end
								end
								if(CA==WR16 || CA==WR32 || CA==MWR) begin
									if(($time - start)/int'(`tCK) < (`BLn_max + `RL + $ceil(real'(`tWCKDQO_max)/`tCK) - `WL)) begin
										`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between RD16/RD32(with AP) and WR16/WR32/MWR (different bank)")
									end
								end
							end 

							else begin
								if(CA==RD16 || CA==RD32) begin
									if(($time - start)/int'(`tCK) < (`BLn)) begin
										`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between RD16/RD32(with AP) and RD16/RD32 (different group)")
									end
								end
								if(CA==WR16 || CA==WR32 || CA==MWR) begin
									if(($time - start)/int'(`tCK) < (`BLn_min + `RL + $ceil(real'(`tWCKDQO_max)/`tCK) - `WL)) begin
										`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between RD16/RD32(with AP) and WR16/WR32/MWR (different group)")
									end
								end
							end 
						end 

						else if(CA==WR16 || CA==WR32 || CA==MWR) begin
							while(1) begin
								@(CA) begin
									if(!(CA == DES || CA == NOP)) break;
								end 
							end
							if(BA == prev_BA) begin
								if(CA==ACT1) begin
									if(($time - start)/int'(`tCK) < (`WL + `BLn_min + `nWR + 1 + $ceil(real'(`tRPpb)/real'(`tCK)))) begin
										`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between WR16/WR32/MWR(with AP) and ACT (same bank)")
									end
								end
								else if (CA==PRE) begin
									if(($time - start)/int'(`tCK) < (`WL + 1 + `BLn_min + `nWR)) begin
										`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between WR16/WR32/MWR(with AP) and PRE (same bank)")
									end
								end
							end 

							else if(BA[3:2] == prev_BA[3:2]) begin
								if(CA==RD16 || CA==RD32) begin
									if(($time - start)/int'(`tCK) < (`WL + `BLn_max + $ceil(`tWTR_L/real'(`tCK)))) begin
										`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between WR16/WR32/MWRD16/RD32(with AP) and RD16/RD32 (different bank)")
									end
								end
								if(CA==WR16 || CA==WR32 || CA==MWR) begin
									if(($time - start)/int'(`tCK) < (`BLn_max)) begin
										`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between WR16/WR32/MWR(with AP) and WR16/WR32/MWR (different bank)")
									end
								end
							end  

							else if(BA[3:2] == prev_BA[3:2]) begin
								if(CA==RD16 || CA==RD32) begin
									if(($time - start)/int'(`tCK) < (`WL + `BLn_min + $ceil(`tWTR_L/real'(`tCK)))) begin
										`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between WR16/WR32/MWRD16/RD32(with AP) and RD16/RD32 (different group)")
									end
								end
								if(CA==WR16 || CA==WR32 || CA==MWR) begin
									if(($time - start)/int'(`tCK) < (`BLn)) begin
										`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between WR16/WR32/MWR(with AP) and WR16/WR32/MWR (different group)")
									end
								end
							end  
						end 
					end 
				join_none
				`else
				fork : AUTO_PRECHARGE_checkers
					int start;
					if(AUTO_PRECHARGE == 1) begin
						if(CA==RD16 || CA==RD32) begin
							while(1) begin
								@(CA) begin
									if(!(CA == DES || CA == NOP)) break;
								end 
							end

							if(BA == prev_BA) begin
								if(CA==ACT1) begin
									if(($time - start)/int'(`tCK) < (`BLn + `nRBTP + $ceil(real'(`tRPpb)/real'(`tCK)))) begin
										`uvm_warning("AUTO_PRECHARGE_checkers", "Timing violation between RD16/RD32(with AP) and ACT (same bank)")
									end
								end
								else if (CA==PRE) begin
									if(($time - start)/int'(`tCK) < (`BLn + `nRBTP)) begin
										`uvm_warning("AUTO_PRECHARGE_checkers", "Timing violation between RD16/RD32(with AP) and PRE (same bank)")
									end
								end
							end 
							
							else begin
								if(CA==RD16 || CA==RD32) begin
									if(($time - start)/int'(`tCK) < (`BLn)) begin
										`uvm_warning("AUTO_PRECHARGE_checkers", "Timing violation between RD16/RD32(with AP) and RD16/RD32 (different group)")
									end
								end
								if(CA==WR16 || CA==WR32 || CA==MWR) begin
									if(($time - start)/int'(`tCK) < (`BLn + `RL + $ceil(real'(`tWCKDQO)/`tCK) - `WL)) begin
										`uvm_warning("AUTO_PRECHARGE_checkers", "Timing violation between RD16/RD32(with AP) and WR16/WR32/MWR (different group)")
									end
								end
							end 
						end 

						else if(CA==WR16 || CA==WR32 || CA==MWR) begin
							while(1) begin
								@(CA) begin
									if(!(CA == DES || CA == NOP)) break;
								end 
							end
							if(BA == prev_BA) begin
								if(CA==ACT1) begin
									if(($time - start)/int'(`tCK) < (`WL + `BLn + `nWR + 1 + $ceil(real'(`tRPpb)/real'(`tCK)))) begin
										`uvm_warning("AUTO_PRECHARGE_checkers", "Timing violation between WR16/WR32/MWR(with AP) and ACT (same bank)")
									end
								end
								else if (CA==PRE) begin
									if(($time - start)/int'(`tCK) < (`WL + 1 + `BLn + `nWR)) begin
										`uvm_warning("AUTO_PRECHARGE_checkers", "Timing violation between WR16/WR32/MWR(with AP) and PRE (same bank)")
									end
								end
							end 

							else if(BA[3:2] == prev_BA[3:2]) begin
								if(CA==RD16 || CA==RD32) begin
									if(($time - start)/int'(`tCK) < (`WL + `BLn + $ceil(`tWTR_L/real'(`tCK)))) begin
										`uvm_warning("AUTO_PRECHARGE_checkers", "Timing violation between WR16/WR32/MWRD16/RD32(with AP) and RD16/RD32 (different group)")
									end
								end
								if(CA==WR16 || CA==WR32 || CA==MWR) begin
									if(($time - start)/int'(`tCK) < (`BLn)) begin
										`uvm_warning("AUTO_PRECHARGE_checkers", "Timing violation between WR16/WR32/MWR(with AP) and WR16/WR32/MWR (different group)")
									end
								end
							end  
						end 
					end 
				join_none
				`endif
			end
			
			//Ziad's parallel checks
			begin
				forever begin
					@ (prev_CA) begin
						if (prev_CA==ACT2) begin
							BA_of_last_act2=BA;
							time_of_last_act2=$time;
						end
						else if ((prev_CA==WR32) || (prev_CA==WR16) || (prev_CA==MWR) || (prev_CA==RD32) || (prev_CA==RD16)) begin
							 BA_of_last_wr_or_rd=BA;
							time_of_last_wr_or_rd=$time;
						end
					end
				   /* wait (prev_CA==ACT2) begin
						BA_of_last_act2=BA;
						time_of_last_act2=$time;
					end*/
				end
			end
			begin
			forever @ (posedge ch0_vif.ck_t) begin//to handle tAAD
					if (bank_state[BA]==ACTIVATING) act1_to_act2_counter=act1_to_act2_counter+1;
					else act1_to_act2_counter=0;
				end
			end
		join_none
	
		phase.drop_objection(this);
		`uvm_info(get_name(), "LPDDR5 monitor finished, objection dropped.", UVM_NONE)
	endtask: run_phase
	
endclass