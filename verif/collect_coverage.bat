CALL compile.bat -coverage

mkdir coverage_output
for /F "tokens=*" %%A in (testcases.txt) do vsim -coverage +UVM_TESTNAME=%%A -voptargs="+cover=becfst" -c work.wddr_tb_top -novopt -do "coverage save -onexit coverage_output/%%A.ucdb; run -all"
REM commented out this line, for /F "tokens=*" %%A in (testcases.txt) do vsim -viewcov coverage_output/%%A.ucdb -c -do "coverage report -html coverage_output/%%A.ucdb -details=abcdefgst -source -htmldir coverage_output/%%A -showcvggoalpcnt; exit"

(for /F "tokens=*" %%A in (testcases.txt) do @echo coverage_output/%%A.ucdb) > coverage_output/ucdb_files.txt
vsim -c -do "vcover merge -inputs coverage_output/ucdb_files.txt -out coverage_output/final.ucdb; exit"
vsim -viewcov coverage_output/final.ucdb -c -do "coverage report -html coverage_output/final.ucdb -details=abcdefgst -htmldir coverage_output/final -showcvggoalpcnt; exit"

