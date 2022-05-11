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
	logic [17:0] ROW;
	
	typedef enum {	POWER_ON, IDLE, BANK_ACTIVE, PER_BANK_REFRESH, SYNC_RD, READ, 
					READ_WITH_AP, WR_OR_MWR, SYNC_WR, WR_OR_MWR_WITH_AP, ACTIVE_POWER_DOWN,
					SELF_REFRESH, BUS_TRAINING, SELF_REFRESH_POWER_DOWN, ALL_BANK_REFRESH,
					DEEP_SLEEP_MODE, IDLE_POWER_DOWN, PRECHARGING
	} state;
	
	`ifdef BG_MODE
	logic [1:0] BA; 
	logic [1:0] BG;
	state bank_state [4][4];  //[BG][BA]
	`elsif B8_MODE
	logic [2:0] BA;
	state bank_state [8];
	`else 
	logic [3:0] BA;
	state bank_state [16];
	`endif
	
	logic [5:0] COL;
	logic [7:0] OP;
	logic [6:0] MA;
	logic WS_WR, WS_RD, WS_FS;

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
		//TODO get config db for ch1_vif 

		//TODO Create analysis port to send data to scoreboard and subscriber 
	
	endfunction: build_phase
	

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		`uvm_info(get_name(), "LPDDR5 monitor started, objection raised.", UVM_NONE)
		
		forever begin
			@(posedge ch0_vif.ck_t) begin
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
				// case(next_CA)
					
				// endcase
			end 
		end 
	
		phase.drop_objection(this);
		`uvm_info(get_name(), "LPDDR5 monitor finished, objection dropped.", UVM_NONE)
	endtask: run_phase
	
endclass