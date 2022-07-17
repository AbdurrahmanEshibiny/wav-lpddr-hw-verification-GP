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
`define tRBTP (`max(7.5ns,4*`tCK)-4*`tCK)
`define tWR (`max(34ns, 3*`tCK))
// tWCKDQO is assumed to be 0 because it is DRAM dependant and we assumed an ideal
// case where the date is output immediately
`define tWCKDQO 0
`define nRBTP 0
`define tRPpb (`max(18ns, 2*`tCK))
`define tWTR_L (`max(12ns, 4*`tCK))
`define tPPD 2
`define tMRR 2*`tCK
`define tWTR (`max(12ns,4*`tCK))
`define n 4//in case 2:1 & n=8 in case 4:1
`define BL_nmax `BL/`n
`define BL_nmin `BL/`n

`define tAAD 8
`define tcas_wr 1*`tCK
`define tcas_rd 1*`tCK
`define tRRD (`max(5ns,2*`tCK)) //2*10//4//between ACT2 commands for two different banks
`define tRC (`tRAS+`tRP)
`define tRCD (`max(18ns,2*`tCK))
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

//Ziad's timing params
`define max_WR16_after_WR16_ANB (`WL+`BL_nmax+$floor(`tWCKPST/`tCK))*`tCK//(4+4+0)=8*tCK
`define min_WR16_after_WR16_ANB `BL_nmax*`tCK//4*tCK
`define max_MWR_after_WR16_SB /*20*`tCK*/(`WL+`BL_nmax+$floor(`tWCKPST/`tCK))*`tCK//(4+4+0)=8*tCK
`define min_MWR_after_WR16_SB 4*`BL_nmax*`tCK//4*4*tCK=16*tCK
`define max_MWR_after_WR16_DB (`WL+`BL_nmax+$floor(`tWCKPST/`tCK))*`tCK//(4+4+0)=8*tCK
`define min_MWR_after_WR16_DB `BL_nmax*`tCK//4*tCK
`define min_RD16_after_WR16_ANB (`WL+`BL_nmax+$ceil(`tWTR/`tCK))*`tCK//(4+4+4)=12*tCK
//current command is MWR
`define max_WR16_after_MWR_ANB (`WL+`BL_nmax+$floor(`tWCKPST/`tCK))*`tCK//(4+4+0)=8*tCK
`define min_WR16_after_MWR_ANB `BL_nmax*`tCK//4*tCK
`define max_MWR_after_MWR_SB /*20*`tCK*/(`WL+`BL_nmax+$floor(`tWCKPST/`tCK))*`tCK//(4+4+0)=8*tCK
`define min_MWR_after_MWR_SB 4*`BL_nmax*`tCK//4*4*tCK=16*tCK
`define max_MWR_after_MWR_DB (`WL+`BL_nmax+$floor(`tWCKPST/`tCK))*`tCK//(4+4+0)=8*tCK
`define min_MWR_after_MWR_DB `BL_nmax*`tCK//4*tCK
`define min_RD16_after_MWR_ANB (`WL+`BL_nmax+$ceil(`tWTR/`tCK))*`tCK//(4+4+1)=9*tCK
//current command is RD16
`define max_WR16_after_RD16_ANB (`RL+`BL_nmax+$floor(`tWCKPST/`tCK))*`tCK//(6+4+0)*tCK=10*tCK
`define min_WR16_after_RD16_ANB (`RL+`BL_nmax+$ceil(`tWCKDQO/`tCK)-`WL)*`tCK//(6+4+0-4)*tCK=6*TCK
`define max_MWR_after_RD16_ANB (`RL+`BL_nmax+$floor(`tWCKPST/`tCK))*`tCK//(6+4+0)*tCK=10*tCK
`define min_MWR_after_RD16_ANB (`RL+`BL_nmax+$ceil(`tWCKDQO/`tCK)-`WL)*`tCK//(6+4+0-4)*tCK=6*TCK
`define max_RD16_after_RD16_ANB (`RL+`BL_nmax+$floor(`tWCKPST/`tCK))*`tCK//(6+4+0)*tCK=10*tCK
`define min_RD16_after_RD16_ANB `BL_nmax*`tCK//4*tCK
///////////////////////
//current command is MRR
`define max_WR16orMWR_after_MRR_ANB (`RL+`BL_nmax+$floor(`tWCKPST/`tCK))*`tCK//(6+4+0)*tCK=10*tCK
`define min_WR16orMWR_after_MRR_ANB (`RL+`BL_nmax+$ceil(`tWCKDQO/`tCK)-`WL+2)*`tCK//(6+4+-4+2)*tCK=8*tCK
`define min_RD16_after_MRR_ANB (`RL+`BL_nmax+$floor(`tWCKPST/`tCK)+2)*`tCK//(6+4+0+2)*tCK=12*tCK
`define max_MRR_after_MRR_ANB (`RL+`BL_nmax+$floor(`tWCKPST/`tCK))*`tCK//(6+4+0)*tCK=10*tCK
`define min_MRR_after_MRR_ANB`tMRR*`tCK//*tCK
`define min_MRR_after_WR16orMWR_ANB (`WL+`BL_nmax+$ceil(`tWTR/`tCK))*`tCK
`define min_MRR_after_RD_ANB (`RL+`BL_nmax+$floor(`tWCKPST/`tCK)+2)*`tCK