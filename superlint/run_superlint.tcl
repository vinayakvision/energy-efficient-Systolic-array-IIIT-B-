# Initialize
check_superlint -init

# Read RTL
analyze -sv -f filelist.f

# Elaborate top
elaborate -top block

# Clock & reset
clock clk
reset rst

# Extract checks
check_superlint -extract

# Prove checks
check_superlint -prove

# Report
check_superlint -report -file lint_report.txt

