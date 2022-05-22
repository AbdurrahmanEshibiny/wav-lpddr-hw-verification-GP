`include "LPDDR5/LPDDR5_agent/gp_LPDDR5_channel_intf.sv"

package gp_lpddr5_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "DFI/DFI_agent/wav_DFI_transfer.sv"	
	`include "LPDDR5/LPDDR5_agent/gp_LPDDR5_monitor.sv"
endpackage