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
`define BL 4
`define tWCKENL_RD
`define tWCKENL_WR
`define tWCKPRE_STATIC_RD
`define tWCKPRE_STATIC_WR
`define tWCK_TOGGLE_RD
`define tWCK_TOGGLE_WR
`define tWCKDQO
`define tWCKDQI
`define tXSR
`define tCK place_holder
`define tCCD place_holder
`define n_max place_holder
`define n_min place_holder
`define tWCKPST place_holder