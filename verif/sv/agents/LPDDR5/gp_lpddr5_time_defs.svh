`define tCKPGM_min 1.25ns
`define tCKPGM_max 200ns
`define tPGM 2000ms
`define tPGM_EXIT 15ns
`define tPGM_PST 500us

int place_holder = 1;

`define max(a, b) (``a`` > ``b``)? ``a``:``b``
`define min(a, b) (``a`` < ``b``)? ``a``:``b``

`define BL 16
`define tMRD (`max(14ns, 5*`tCK))
`define tRAS (`max(42ns, 3*`tCK))
`define tRP (`max(21ns, 2*`tCK))
`define tCK 1.27
`define RL 6
`define WL 4
`define BLn 16
`define BLn_min 8
`define nWR 5
// FIXME
`define tRBTP place_holder
`define tWR (`max(34ns, 3*`tCK))
// tWCKDQO is assumed to be 0 because it is DRAM dependant and we assumed an ideal
// case where the date is output immediately
`define tWCKDQO 0
`define nRBTP 0
`define tRPpb (`max(18ns, 2*`tCK))
`define tWTR_L (`max(12ns, 4*`tCK))

//Ziad's timing params
/// defines
`define max_WR32_after_WR32_ANB 16
`define min_WR32_after_WR32_ANB 4
`define max_WR16_after_WR32_ANB 16
`define min_WR16_after_WR32_ANB 4
`define max_MWR_after_WR32_SB 16
`define min_MWR_after_WR32_SB 16
`define max_MWR_after_WR32_DB 16
`define min_MWR_after_WR32_DB 16
`define max_RD32_after_WR32_ANB 16
`define min_RD32_after_WR32_ANB 4
`define max_RD16_after_WR32_ANB 16
`define min_RD16_after_WR32_ANB 4
//current command is WR16
`define max_WR32_after_WR16_ANB 16
`define min_WR32_after_WR16_ANB 4
`define max_WR16_after_WR16_ANB 16
`define min_WR16_after_WR16_ANB 4
`define max_MWR_after_WR16_SB 16
`define min_MWR_after_WR16_SB 16
`define max_MWR_after_WR16_DB 16
`define min_MWR_after_WR16_DB 16
`define max_RD32_after_WR16_ANB 16
`define min_RD32_after_WR16_ANB 4
`define max_RD16_after_WR16_ANB 16
`define min_RD16_after_WR16_ANB 4
//current command is MWR
`define max_WR32_after_MWR_ANB 16
`define min_WR32_after_MWR_ANB 4
`define max_WR16_after_MWR_ANB 16
`define min_WR16_after_MWR_ANB 4
`define max_MWR_after_MWR_SB 16
`define min_MWR_after_MWR_SB 16
`define max_MWR_after_MWR_DB 16
`define min_MWR_after_MWR_DB 16
`define max_RD32_after_MWR_ANB 16
`define min_RD32_after_MWR_ANB 4
`define max_RD16_after_MWR_ANB 16
`define min_RD16_after_MWR_ANB 4
//current command is RD32
`define max_WR32_after_RD32_ANB 16
`define min_WR32_after_RD32_ANB 4
`define max_WR16_after_RD32_ANB 16
`define min_WR16_after_RD32_ANB 4
`define max_MWR_after_RD32_ANB 16
`define min_MWR_after_RD32_ANB 16
`define max_RD32_after_RD32_ANB 16
`define min_RD32_after_RD32_ANB 4
`define max_RD16_after_RD32_ANB 16
`define min_RD16_after_RD32_ANB 4
//current command is RD16
`define max_WR32_after_RD16_ANB 16
`define min_WR32_after_RD16_ANB 4
`define max_WR16_after_RD16_ANB 16
`define min_WR16_after_RD16_ANB 4
`define max_MWR_after_RD16_ANB 16
`define min_MWR_after_RD16_ANB 16
`define max_RD32_after_RD16_ANB 16
`define min_RD32_after_RD16_ANB 4
`define max_RD16_after_RD16_ANB 16
`define min_RD16_after_RD16_ANB 4
`define tAAD 8
`define tRRD 4
`define tRC 12
`define tWCKENL_RD 0
`define tWCKENL_WR 0
`define tWCKPRE_STATIC_RD 2
`define tWCKPRE_STATIC_WR 2
`define tWCK_TOGGLE_RD 6
`define tWCK_TOGGLE_WR 2
`define tWCKDQI 0
`define tRFCab (`max(7.5ns, 2*`tCK))
`define tXSR 210 + `tRFCab
`define tCCD 0
`define n_max (1/`tCK)
`define n_min (1/`tCK)
`define tWCKPST (2.5*(`tCK/4))