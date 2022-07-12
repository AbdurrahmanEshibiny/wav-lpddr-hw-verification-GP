(for /F "tokens=*" %%A in (%testcases%) do @echo coverage_output/%%A.ucdb) > coverage_output/ucdb_files.txt
vsim -c -do "vcover merge -inputs coverage_output/ucdb_files.txt -out coverage_output/final.ucdb; exit"
vsim -viewcov coverage_output/final.ucdb -c -do "coverage report -html coverage_output/final.ucdb -details=abcdefgst -htmldir coverage_output/final -showcvggoalpcnt; exit"