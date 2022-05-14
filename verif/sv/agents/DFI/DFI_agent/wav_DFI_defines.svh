`ifndef WAV_DFI_DEFS
`define WAV_DFI_DEFS

// ctrlupd time constraints
`define tctrlupd_min 3
`define tctrlupd_max 10

// phyupd time constraints
`define tphyupd_resp 3
`define tphyupd_type0 5
`define tphyupd_type1 10
`define tphyupd_type2 15
`define tphyupd_type3 20

// lp time constraints
`define tlp_resp 5

// phymstr time constraints
`define tphymstr_resp
`define tphymstr_type0 5
`define tphymstr_type1 10
`define tphymstr_type2 15
`define tphymstr_type3 20

// signal widths for command interface
`define WAV_DFI_BANK_WIDTH 8 
`define WAV_DFI_BG_WIDTH 8 
`define WAV_DFI_CID_WIDTH 8 
`define WAV_DFI_CKE_WIDTH 8 
`define WAV_DFI_CS_WIDTH 8 
`define WAV_DFI_DRAM_CLK_DISABLE_WIDTH 8 
`define WAV_DFI_ODT_WIDTH 8 
`define WAV_DFI_RESET_WIDTH 8 
`define WAV_DFI_DATA_WIDTH 8 
`define WAV_DFI_PHYSICAL_RANK_WIDTH 8 
`define WAV_DFI_DBI_WIDTH WAV_DFI_DATA_WIDTH/8 


`endif 