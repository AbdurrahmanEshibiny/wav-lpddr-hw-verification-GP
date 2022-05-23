`ifndef WAV_DFI_DEFS
`define WAV_DFI_DEFS

// ctrlupd time constraints
`define tctrlupd_min 3
`define tctrlupd_max 10

// phyupd time constraints
`define tphyupd_resp 200
`define tphyupd_type0 500
`define tphyupd_type1 1000
`define tphyupd_type2 1500
`define tphyupd_type3 2000

// lp time constraints
`define tlp_resp 5

// phymstr time constraints
`define tphymstr_resp
`define tphymstr_type0 5
`define tphymstr_type1 10
`define tphymstr_type2 15
`define tphymstr_type3 20

// TODO: ALL THE DEFS BELOW NEED TO BE PROPERLY DEFINED

// signal widths for command interface
`define WAV_DFI_BANK_WIDTH 8
`define WAV_DFI_BG_WIDTH 8
`define WAV_DFI_CID_WIDTH 8
`define WAV_DFI_CKE_WIDTH 8
`define WAV_DFI_CS_WIDTH 8
`define WAV_DFI_DRAM_CLK_DISABLE_WIDTH 8
`define WAV_DFI_ODT_WIDTH 8
`define WAV_DFI_RESET_WIDTH 8

// signal widths for read interface
// TODO: group defs that are common to read & write together
// NOTE: All data in this section is correct
`define WAV_DFI_DATA_WIDTH 64
`define WAV_DFI_PHYSICAL_RANK_WIDTH 2
`define WAV_DFI_DBI_WIDTH WAV_DFI_DATA_WIDTH/8
`define WAV_DFI_DATA_EN_WIDTH 1
`define WAV_READ_DATA_VALID_WIDTH `WAV_DFI_DATA_EN_WIDTH

// write time constraints
`define tphy_wrcsgap 0
`define tphy_wrcslat 0
`define tphy_wrdata 0
`define tphy_wrlat 0
`define tphy_wrdatadelay 0

`define phydpi_mode 0

`define twck_dis 0
`define twck_fast_toggle 0
`define twck_toggle 0
`define twck_toggle_cs 0
`define twck_toggle_post 0
`define twck_toggle_rd 0
`define twck_toggle_wr 0

`define frequency 1



`endif 