/*********************************************************************************
Copyright (c) 2021 Wavious LLC

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*********************************************************************************/
import wddr_pkg::*;
import ddr_global_pkg::*;


//************Added for compilation purposes*********************
import uvm_pkg::*;
import wav_APB_pkg::*;
import wav_DFI_pkg::*;

`include "uvm_macros.svh"
`include "DFI/DFI_agent/wav_DFI_defines.svh"

`include "ddr_global_define.vh"
`include "ddr_cmn_csr_defs.vh"
`include "ddr_fsw_csr_defs.vh"
`include "ddr_cmn_wrapper_define.vh"
`include "wav_reg_model_mvp_pll.svh"
`include "ddr_ctrl_csr_defs.vh"
`include "ddr_ca_csr_defs.vh"
`include "ddr_dfi_csr_defs.vh"
`include "ddr_dfich_csr_defs.vh"
`include "ddr_dq_csr_defs.vh"
`include "wav_mcu_csr_defs.vh"
`include "wav_mcuintf_csr_defs.vh"
`include "wav_mcutop_csr_defs.vh"

//--REGISTER MODEL FOR ddr_phy TOP
`include "register/wddr_reg_model.svh"
`include "register/wddr_reg_model.sv"

//--ENV INCLUDES
`include "tb_top/wddr_tb.sv"
//***************************************************************


`include "sv/sequences/wddr_config.sv"
`include "sv/sequences/wddr_base_seq.sv"
`include "sv/sequences/wddr_bringup_seq.sv"
`include "sv/sequences/wddr_mcu_load_mem.sv"
`include "sv/sequences/regs/wddr_reg_reset_seq.sv"
`include "sv/sequences/regs/wddr_reg_bitbash_seq.sv"
`include "sv/sequences/regs/wddr_reg_access_seq.sv"
`include "sv/sequences/regs/wddr_reg_direct_seq.sv"
`include "sv/sequences/dt/wddr_dt_pll_seq.sv"
`include "sv/sequences/dt/wddr_dt_ddr_seq.sv"
`include "sv/sequences/dt/wddr_dt_ddr_spice_seq.sv"
`include "sv/sequences/dt/wddr_dt_dfistatus_seq.sv"
`include "sv/sequences/dt/wddr_dt_mcu_seq.sv"
`include "sv/sequences/dt/wddr_dt_freqsw_seq.sv"
//`include "sv/sequences/dfimc/dfiSeqlib.sv"


`include "sv/sequences/dfi/wddr_DFI_phymstr_seq.sv"
`include "sv/sequences/dfi/wddr_DFI_phyupd_seq.sv"
`include "sv/sequences/dfi/wddr_DFI_ctrlupd_seq.sv"
`include "sv/sequences/dfi/wddr_DFI_lp_ctrl_seq.sv"
`include "sv/sequences/dfi/wddr_DFI_lp_data_seq.sv"
`include "sv/sequences/dfi/wddr_DFI_write_seq.sv"
`include "sv/sequences/dfi/wddr_DFI_lp_seq.sv"
`include "sv/sequences/dfi/wddr_DFI_several_lp_seq.sv"
`include "sv/sequences/dfi/wddr_DFI_several_lp_small_wakeup_seq.sv"
`include "sv/sequences/dfi/wddr_DFI_several_phymstr_seq.sv"
`include "sv/sequences/dfi/wddr_DFI_several_phyupd_seq.sv"