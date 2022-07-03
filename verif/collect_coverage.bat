REM set %1
set instances=
set testcases=testcases.txt

for %%x in (%*) do (
    if "%%x" == "-short" (set instances=-instance /wddr_tb_top/u_phy_1x32 -du work.wddr_pkg) 
REM    if "%%x" == "-append" (set testcases=appendcases.txt)
)

REM if NOT "%old%" == "" (set old=coverage_output/%old%)
CALL compile.bat -coverage

mkdir coverage_output
REM for /F "tokens=*" %%A in (%testcases%) do vsim -coverage +UVM_TESTNAME=%%A -voptargs="+cover=becfst" -c work.wddr_tb_top -novopt -do simulate.do
for /F "tokens=*" %%A in (%testcases%) do vsim -coverage +UVM_TESTNAME=%%A -voptargs="+cover=becfst" -c work.wddr_tb_top -novopt -do "coverage save -onexit coverage_output/%%A.ucdb %instances%" -do simulate.do
REM commented out this line, for /F "tokens=*" %%A in (%testcases%) do vsim -viewcov coverage_output/%%A.ucdb -c -do "coverage report -html coverage_output/%%A.ucdb -details=abcdefgst -source -htmldir coverage_output/%%A -showcvggoalpcnt; exit"

(for /F "tokens=*" %%A in (%testcases%) do @echo coverage_output/%%A.ucdb) > coverage_output/ucdb_files.txt
vsim -c -do "vcover merge -inputs coverage_output/ucdb_files.txt -out coverage_output/final.ucdb; exit"
vsim -viewcov coverage_output/final.ucdb -c -do "coverage report -html coverage_output/final.ucdb -details=abcdefgst -htmldir coverage_output/final -showcvggoalpcnt; exit"

