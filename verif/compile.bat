set RTL=../rtl
set VERIF=.
set APB_PKG=${VERIF}/sv/agents/APB/wav_APB_pkg.sv
set DFI_PKG=${VERIF}/sv/agents/DFI/wav_DFI_pkg.sv
set WDDR_PKG=${VERIF}/sv/wddr_pkg.sv
set LPDDR5_PKG=${VERIF}/sv/agents/LPDDR5/gp_lpddr5_pkg.sv

IF "%1"=="-coverage" (
vlog 	-sv09compat -O0 ^
		-f .\flist\ddr_phy.behav.f -f .\flist\ddr_phy.f -f .\flist/wddr_verif.f ^
		-timescale 1ns/1ps +cover -coveropt 1
) ELSE (
vlog 	-sv09compat -O0 ^
		-f .\flist\ddr_phy.behav.f -f .\flist\ddr_phy.f -f .\flist/wddr_verif.f ^
		-timescale 1ns/1ps
)