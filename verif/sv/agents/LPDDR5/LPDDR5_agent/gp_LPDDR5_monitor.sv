//TODO we need to define tMRD, tRAS, tRP, tCK, RL, WL
`define tCKPGM_min 1.25ns
`define tCKPGM_max 200ns
`define tPGM 2000ms
`define tPGM_EXIT 15ns
`define tPGM_PST 500us
int place_holder = 1;
`define tMRD place_holder
`define tRAS place_holder
`define tRP place_holder
`define tCK place_holder
`define RL place_holder
`define WL place_holder
`define BLn place_holder
`define BLn_min place_holder
`define nWR place_holder
`define tRBTP place_holder
`define tWR place_holder
`define tWCQDQO place_holder
`define nRBTP place_holder
`define tRPpb place_holder
`define nRBTP place_holder
`define WR place_holder
`define tWTR_L place_holder

import uvm_pkg::*;
`include "uvm_macros.svh"
//FIXME These might be removed in the future when we organise the file structure

class gp_LPDDR5_monitor extends uvm_monitor;
	`uvm_component_utils(gp_LPDDR5_monitor)
	
	//-------------------Start of variable declarations-------------------------------
	typedef enum {	DES, NOP, PDE, ACT1, ACT2, PRE, REF, MWR, WR16, WR32, RD16, RD32,
					CAS, MPC, SRE, SRX, MRW1, MRW2, MRR, WFF, RFF, RDC
	} command;
	
	command CA, prev_CA, next_CA;
	bit [17:0] ROW;
	
	typedef enum {	POWER_ON, IDLE, ACTIVATING, BANK_ACTIVE, PER_BANK_REFRESH, SYNC_RD, READ, 
					READ_WITH_AP, WR_OR_MWR, SYNC_WR, WR_OR_MWR_WITH_AP, ACTIVE_POWER_DOWN,
					SELF_REFRESH, BUS_TRAINING, SELF_REFRESH_POWER_DOWN, ALL_BANK_REFRESH,
					DEEP_SLEEP_MODE, IDLE_POWER_DOWN, PRECHARGING
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
	bit WS_WR, WS_RD, WS_FS;

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
	int tWCK2CK, tWCKDQO, tWCKDQI, tCK, nWR, tCMDPD,tMRWPD, tESPD, tRFCab, tRFCpb, tpbR2pbR, delay, tRP, tRRD,
	tCSPD, tPDN, tXSR_DSM, tSR;
	int BL = 16;
	int time_refresh_all_bank, time_prev_CA, time_SRE,time_last_MRR, time_last_MRW, time_last_write, time_last_read, time_DSE, time_DSX,
	time_last_MW_with_auto, time_last_command, time_SRX, time_bank_precharge, time_bank_activate, time_WR_command, tWCKPRE_Static,
	tWCKPRE_Toggle_WR, time_SE, time_PDX, time_PDE, time_last_refresh_per_bank,flag_BG_refresh_commands_done;
	int nck, RL, RU, WL;
 	/*assign DQ = {ch0_vif.dq0_dq0, ch0_vif.dq0_dq1, ch0_vif.dq0_dq2, ch0_vif.dq0_dq3, ch0_vif.dq0_dq4, ch0_vif.dq0_dq5,
			ch0_vif.dq0_dq6, ch0_vif.dq0_dq7,ch1_vif.dq1_dq0, ch1_vif.dq1_dq1, ch1_vif.dq1_dq2, ch1_vif.dq1_dq3,
			ch1_vif.dq1_dq4, ch1_vif.dq1_dq5,ch1_vif.dq1_dq6, ch1_vif.dq1_dq7};*/
	uvm_analysis_port #(wav_DFI_write_transfer) recieved_transaction;
	wav_DFI_write_transfer item;

	//--------------------------------------------------------------------------

	//---------------------End of variable declarations------------------------

	virtual gp_LPDDR5_channel_intf ch0_vif;
	virtual gp_LPDDR5_channel_intf ch1_vif;

	function new(string name = "gp_LPDDR5_monitor", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(! uvm_config_db#(virtual gp_LPDDR5_channel_intf)::get(this, "", "ch0_vif", ch0_vif)) begin
			`uvm_fatal("gp_LPDDR5_monitor", "Failed to get virtual interface from config db")
		end
		recieved_transaction = new("recieved_transaction", this);

		//TODO get config db for ch1_vif 	
	endfunction: build_phase
	

	task run_phase(uvm_phase phase);
		item = wav_DFI_write_transfer::type_id::create("item", this);

		phase.raise_objection(this);
		`uvm_info(get_name(), "LPDDR5 monitor started, objection raised.", UVM_NONE)
		
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
					end
					{1'b1, 7'b0010xxx}: begin
						next_CA = WR32;
					end
					{1'b1, 7'b100xxxx}: begin
						next_CA = RD16;
					end
					{1'b1, 7'b101xxxx}: begin
						next_CA = RD32;
					end
					{1'b1, 7'b0011xxx}: begin
						next_CA = CAS;
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
					default: `uvm_error("gp_LPDDR5_monitor", "Recieved unknown command on CA bus")
				endcase
			end 
			@(negedge ch0_vif.ck_t) begin
				case(next_CA)
					PRE: begin
						prev_CA = CA;
						CA = next_CA;
						prev_BA = BA;
						BA={ch0_vif.ca3, ch0_vif.ca2, ch0_vif.ca1, ch0_vif.ca0};
						bank_state[BA] = PRECHARGING;
						ALL_BANKS = ch0_vif.ca6;
						assert(!$isunknown(ch0_vif.ca4) && !$isunknown(ch0_vif.ca4)) begin
							`uvm_error("gp_LPDDR5_monitor", "Invalid signals are supposed to be valid")
						end 
					end
					PDE:begin
						if((($time - time_SRE) <2*nck )
							|| ((CA != (REF || PRE)) && !AUTO_PRECHARGE)
							|| (($time - time_last_read) < (RL + RU*((tWCK2CK + tWCKDQO)/tCK) + BL/8 +1))
							|| (($time - time_last_write) < (WL + RU*((tWCK2CK + tWCKDQI)/tCK) + BL/8 +1)) 
							|| (($time - time_last_MW_with_auto) < ( WL + RU*((tWCK2CK + tWCKDQI)/tCK) + nWR + BL/8 +1))
							|| (($time - time_last_MRR) < (RL + RU*((tWCK2CK + tWCKDQO)/tCK) + nWR + BL/8 +1)) 
							|| (($time - time_last_command) < (tCMDPD)) 
							|| (($time - time_last_MRW) < (tMRWPD))
							|| (($time - time_SRE) < tESPD) )
								`uvm_error("gp_lpddr5_monitor", "Cannot enter power down")
							else
							begin
								time_PDE = $time;
								CA = PDE;
								if (CA == SRE) bank_state = '{default:SELF_REFRESH_POWER_DOWN};
								else bank_state = '{default:IDLE_POWER_DOWN};
								while(1) begin
									@(ch0_vif.cs)begin //wait for cs to toggle for DSX
										if( ($time - time_PDE) < tCSPD )
											`uvm_error("gp_lpddr5_monitor", "Cannot exit deep sleep mode too soon")
										else begin
											time_PDX = $time;
											bank_state = '{default:ACTIVE_POWER_DOWN};
											CA = SRE;
										end
									end
								end	
							end
					end
					ACT1:begin end
					ACT2:begin end
					PRE:begin end
					REF:begin
						if (ch0_vif.CA6 == 0) begin
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
						else if (ch0_vif.CA6 == 1) // ALL BANK refresh
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
								`uvm_error("gp_lpddr5_monitor", "Cannot refresh this bank untill all other banks are refreshed")
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
						if (flag_wck_off) begin
							while($time < (time_WR_command + tWCKPRE_Static + tWCKPRE_Toggle_WR)) 
							begin
								if($isunknown(ch0_vif.dq0_wck_t))
									`uvm_error("gp_lpddr5_monitor", "WCK error")
							end
						end
						i = 0;
						if(bank_mode == 8) begin
						repeat(16) begin
							@(posedge ch0_vif.dq0_wck_t)begin
								// item.data[j][i] = DQ[i];
								//TODO fix this @ Nada
								i++;
							end
						end
						end
						else begin
						repeat(16) begin
							@(posedge ch0_vif.dq0_wck_t)begin
								// item.data[j][i] = DQ[i];
								//TODO fix this @ Nada
								i++;
							end
						end
						end
						j++;
						if(j == 4)begin
							recieved_transaction.write(item); 
							i = 0; 
						end
					end
					WR16:begin
						if (flag_wck_off) begin
							while($time < (time_WR_command + tWCKPRE_Static + tWCKPRE_Toggle_WR)) 
							begin
								if($isunknown(ch0_vif.dq0_wck_t))
									`uvm_error("gp_lpddr5_monitor", "WCK error")
							end
						end
						i = 0;
						repeat(16) begin
							@(posedge ch0_vif.dq0_wck_t)begin
								// item.data[j][i] = DQ[i];
								//TODO fix this @ Nada
								i++;
							end
						end
						j++;
						if(j == 4)begin
							recieved_transaction.write(item); 
							i = 0; 
						end
					end
					WR32:begin
						/*
						if (flag_wck_off) begin
							while($time < (time_WR_command + tWCKPRE_Static + tWCKPRE_Toggle_WR)) 
							begin
								if($isunknown(ch0_vif.dq0_wck_t))
									`uvm_error("gp_lpddr5_monitor", "WCK error")
							end
						end
						assign i = 0;
						repeat(32) begin
							@(posedge ch0_vif.dq0_wck_t)begin
								item.data[j][i] = DQ[i];
								i++;
							end
						end
						j++;
						if(j == 4)begin
							recieved_transaction.write(item);  
							i = 0; 
						end*/
					end
					RD16:begin end
					RD32:begin end
					CAS:begin end
					MPC:begin end
					SRE: begin 
						if(CA == 'bxxxxx10) begin
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
										end
									end	
								end
							
							end
						end
						if(CA == 'bxxxxx01) begin		// deep sleep entry with self refresh
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
										end
									end	
								end
							
							end
						end
						
						else begin //self refresh
							if(bank_state != '{default:IDLE})
								`uvm_error("gp_lpddr5_monitor", "Cannot refresh this bank untill all other banks are refreshed")
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
						if(($time - time_DSX < tXSR_DSM) ||  ($time - time_SRE < tSR))
							`uvm_error("gp_lpddr5_monitor", "Cannot refresh this bank untill all other banks are refreshed")
						else begin
							flag_8_refresh_commands_done 	    = 1;
							flag_16_refresh_commands_done 	    = 1;
							flag_all_bank_refresh_commands_done = 1;
							time_SRX = $time;
							bank_state = '{default:SELF_REFRESH_POWER_DOWN};
						end
					end
					
					MRW1:begin end
					MRW2:begin end
					MRR:begin end
					WFF:begin end
					RFF:begin end
				endcase
			end 

			//Here we put all the checkers that need to be completed after the command detection

			//Shibiny's checkers:

			fork : PPR_checker
				if(CA==MRW2 && MA==41 && OP[4]==1) begin
					time start;
					if(bank_state!='{default: IDLE}) begin
						`uvm_error("PPR_checker", "Attempting to enter PPR mode while there are non-idle banks")
						disable PPR_checker;
					end
				
					start = $time;
					while(1) begin
						@(CA) begin
							if(!(CA == DES || CA == NOP)) break;
						end 
					end
					if((($time - start)/int'(`tCK) < `tMRD) || !(CA==MRW2 && MA==42 && OP==8'b1100_1111)) begin
						`uvm_error("PPR_checker", "Guard key not entered correctly during Post Package Repair entry")
						disable PPR_checker;
					end
				
					start = $time;
					while(1) begin
						@(CA) begin
							if(!(CA == DES || CA == NOP)) break;
						end 
					end
					if((($time - start)/int'(`tCK) < `tMRD) || !(CA==MRW2 && MA==42 && OP==8'b0111_0011)) begin
						`uvm_error("PPR_checker", "Guard key not entered correctly during Post Package Repair entry")
						disable PPR_checker;
					end
				
					start = $time;
					while(1) begin
						@(CA) begin
							if(!(CA == DES || CA == NOP)) break;
						end 
					end
					if((($time - start)/int'(`tCK) < `tMRD) || !(CA==MRW2 && MA==42 && OP==8'b1011_1011)) begin
						`uvm_error("PPR_checker", "Guard key not entered correctly during Post Package Repair entry")
						disable PPR_checker;
					end
				
					start = $time;
					while(1) begin
						@(CA) begin
							if(!(CA == DES || CA == NOP)) break;
						end 
					end
					if((($time - start)/int'(`tCK) < `tMRD) || !(CA==MRW2 && MA==42 && OP==8'b0011_1011)) begin
						`uvm_error("PPR_checker", "Guard key not entered correctly during Post Package Repair entry")
						disable PPR_checker;
					end
				
					start = $time;
					while(1) begin
						@(CA) begin
							if(!(CA == DES || CA == NOP)) break;
						end 
					end
					if((($time - start)/int'(`tCK) < `tMRD) || !(CA==ACT1)) begin
						`uvm_error("PPR_checker", "Guard key not entered correctly during Post Package Repair entry")
						disable PPR_checker;
					end
				
					@(CA) 
					if (!(CA==ACT2)) begin
						`uvm_error("PPR_checker", "Guard key not entered correctly during Post Package Repair entry")
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
						`uvm_error("PPR_checker", "Error during PPR")
						disable PPR_checker;
					end
				
					start = $time;
					while(1) begin
						@(CA) begin
							if(!(CA == DES || CA == NOP)) break;
						end 
					end
					if((($time - start)/int'(`tCK) < `tPGM_EXIT) || !(CA==MRW2 && MA==41 && OP[4]==0)) begin
						`uvm_error("PPR_checker", "Error during PPR")
						disable PPR_checker;
					end
				
					start = $time;
					while(1) begin
						@(CA) begin
							if(!(CA == DES || CA == NOP)) break;
						end 
					end
					if((($time - start)/int'(`tCK) < `tPGM_PST) || ch0_vif.reset_n) begin
						`uvm_error("PPR_checker", "Error during PPR")
						disable PPR_checker;
					end

					`uvm_info("PPR_checker", "PPR operation successful", UVM_LOW)
				end 
			join_none

			fork : TRR_checker
				if(CA==MRW2 && MA==27 && OP[7]==1) begin
					time start;
					if(bank_state!='{default: IDLE}) begin
						`uvm_error("TRR_checker", "Attempting to enter TRR mode while there are non-idle banks")
						disable TRR_checker;
					end
	
					start = $time;
					while(1) begin
						@(CA) begin
							if(!(CA == DES || CA == NOP)) break;
						end 
					end
					if((($time - start)/int'(`tCK) < `tMRD) || !(CA==ACT1)) begin
						`uvm_error("TRR_checker", "Error during TRR")
						disable TRR_checker;
					end
					@(CA) 
					if (!(CA==ACT2)) begin
						`uvm_error("TRR_checker", "ACT1 not followed by ACT2")
						disable TRR_checker;
					end
	
					start = $time;
					while(1) begin
						@(CA) begin
							if(!(CA == DES || CA == NOP)) break;
						end 
					end
					if((($time - start)/int'(`tCK) < `tRAS*1.5) || !(CA==PRE)) begin
						`uvm_error("TRR_checker", "Error during TRR")
						disable TRR_checker;
					end
	
					start = $time;
					while(1) begin
						@(CA) begin
							if(!(CA == DES || CA == NOP)) break;
						end 
					end
					if((($time - start)/int'(`tCK) < `tRP) || !(CA==ACT1)) begin
						`uvm_error("TRR_checker", "Error during TRR")
						disable TRR_checker;
					end
					@(CA) 
					if (!(CA==ACT2)) begin
						`uvm_error("TRR_checker", "ACT1 not followed by ACT2")
						disable TRR_checker;
					end
	
					start = $time;
					while(1) begin
						@(CA) begin
							if(!(CA == DES || CA == NOP)) break;
						end 
					end
					if((($time - start)/int'(`tCK) < `tRAS) || !(CA==PRE)) begin
						`uvm_error("TRR_checker", "Error during TRR")
						disable TRR_checker;
					end
	
					start = $time;
					while(1) begin
						@(CA) begin
							if(!(CA == DES || CA == NOP)) break;
						end 
					end
					if((($time - start)/int'(`tCK) < `tRP) || !(CA==ACT1)) begin
						`uvm_error("TRR_checker", "Error during TRR")
						disable TRR_checker;
					end
					@(CA) 
					if (!(CA==ACT2)) begin
						`uvm_error("TRR_checker", "ACT1 not followed by ACT2")
						disable TRR_checker;
					end
	
					start = $time;
					while(1) begin
						@(CA) begin
							if(!(CA == DES || CA == NOP)) break;
						end 
					end
					if((($time - start)/int'(`tCK) < `tRAS) || !(CA==PRE)) begin
						`uvm_error("TRR_checker", "Error during TRR")
						disable TRR_checker;
					end
	
					start = $time;
					while(1) begin
						@(CA) begin
							if(!(CA == DES || CA == NOP)) break;
						end 
					end
					if(($time - start)/int'(`tCK) < (`tRP+`tMRD)) begin
						`uvm_error("TRR_checker", "Error during TRR")
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
								`uvm_error("PRE_timing_checker", "Timing violation between ACT2 and PRE (same bank)")
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
								`uvm_error("PRE_timing_checker", "Timing violation between RD16/32 and PRE (same bank)")
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
								`uvm_error("PRE_timing_checker", "Timing violation between WR16/32 & MWR and PRE (same bank)")
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
								`uvm_error("PRE_timing_checker", "Timing violation between PRE and ACT1 (same bank)")
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
								if(($time - start)/int'(`tCK) < (`BLn_max + `RL + $ceil(real'(`tWCQDQO_max)/`tCK) - `WL)) begin
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
								if(($time - start)/int'(`tCK) < (`BLn_min + `RL + $ceil(real'(`tWCQDQO_max)/`tCK) - `WL)) begin
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
								if(($time - start)/int'(`tCK) < (`WR + 1 + `BLn_min + `nWR)) begin
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
									`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between RD16/RD32(with AP) and ACT (same bank)")
								end
							end
							else if (CA==PRE) begin
								if(($time - start)/int'(`tCK) < (`BLn + `nRBTP)) begin
									`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between RD16/RD32(with AP) and PRE (same bank)")
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
								if(($time - start)/int'(`tCK) < (`BLn + `RL + $ceil(real'(`tWCQDQO)/`tCK) - `WL)) begin
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
								if(($time - start)/int'(`tCK) < (`WL + `BLn + `nWR + 1 + $ceil(real'(`tRPpb)/real'(`tCK)))) begin
									`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between WR16/WR32/MWR(with AP) and ACT (same bank)")
								end
							end
							else if (CA==PRE) begin
								if(($time - start)/int'(`tCK) < (`WL + 1 + `BLn + `nWR)) begin
									`uvm_error("AUTO_PRECHARGE_checkers", "Timing violation between WR16/WR32/MWR(with AP) and PRE (same bank)")
								end
							end
						end 

						else if(BA[3:2] == prev_BA[3:2]) begin
							if(CA==RD16 || CA==RD32) begin
								if(($time - start)/int'(`tCK) < (`WL + `BLn + $ceil(`tWTR_L/real'(`tCK)))) begin
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
			`endif
		end 
	
		phase.drop_objection(this);
		`uvm_info(get_name(), "LPDDR5 monitor finished, objection dropped.", UVM_NONE)
	endtask: run_phase
	
endclass