`include "LPDDR5/LPDDR5_agent/gp_LPDDR5_channel_intf.sv"

package gp_lpddr5_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	typedef enum {	DES, NOP, PDE, ACT1, ACT2, PRE, REF, MWR, WR16, WR32, RD16, RD32,
					CAS_WR,CAS_RD,CAS_FS,CAS_OFF, MPC, SRE, SRX, MRW1, MRW2, MRR, WFF, RFF, RDC
	} command;

	// `include "DFI/DFI_agent/wav_DFI_transfer.sv"	
	import wav_DFI_pkg::wav_DFI_write_transfer;
	`include "LPDDR5/LPDDR5_agent/gp_LPDDR5_monitor.sv"
	`include "LPDDR5/LPDDR5_agent/gp_LPDDR5_agent.sv"
endpackage