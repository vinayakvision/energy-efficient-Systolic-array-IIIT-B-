# ============================================================
# JasperGold Formal Verification  systolic_top
# ============================================================

# ------------------------------------------------------------
# Clean previous session
# ------------------------------------------------------------
clear -all

# ------------------------------------------------------------
# Engine settings (safe for beginners)
# ------------------------------------------------------------
# set_engine_mode {BMC PDR}
set_max_trace_length 120

# ------------------------------------------------------------
# Design & Property paths
# (Relative to tcl/ directory)
# ------------------------------------------------------------
set design_path ../rtl
set prop_path   ../properties

# ------------------------------------------------------------
# Analyze RTL (Design Under Verification)
# ------------------------------------------------------------
analyze -sv \
    $design_path/block.sv \
     $design_path/sram.sv \
     $design_path/compression.sv \
     $design_path/decompressor.sv \
     $design_path/systolic_core.sv \
     $design_path/control.sv \
     $design_path/systolic_top.sv

# ------------------------------------------------------------
# Analyze SystemVerilog Assertions
# ------------------------------------------------------------
analyze -sv09 \
    $prop_path/block_prop.sva \
    $prop_path/compressor_prop.sva \
    $prop_path/decompressor_prop.sva \
    $prop_path/core_prop.sva \
    $prop_path/env_assump.sva \
    $prop_path/fsm_prop.sva \
    $prop_path/sram_assump.sva \
    $prop_path/top_prop.sva \
    $prop_path/binding.sva

# ------------------------------------------------------------
# Elaborate top module
# ------------------------------------------------------------
elaborate -top systolic_top

# ------------------------------------------------------------
# Clock and Reset
# ------------------------------------------------------------
clock clk -both_edges
reset rst

# ------------------------------------------------------------
# Run proofs
# ------------------------------------------------------------
prove -all

# ------------------------------------------------------------
# Reports
# ------------------------------------------------------------
report -summary


