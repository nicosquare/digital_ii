set PROJ_DIR "ENTER THE simulation DIRECTORY PATH HERE"
#eg
#set PROJ_DIR "D:\RD_Work_Area\rd1046_i2c_master_with_wishbone\rd1046\simulation\xo\verilog"

cd $PROJ_DIR

if {![file exists work]} {
    vlib work 
}
endif

design create work .
design open work
adel -all

cd $PROJ_DIR

vlog -dbg ../../../project/xo/verilog/xo_verilog/xo_verilog_xo_verilog_vo.vo


vlog -dbg +define+XO_TEST ../../../TestBench/Verilog/i2c_slave_model.v
vlog -dbg +define+XO_TEST ../../../TestBench/Verilog/timescale.v
vlog -dbg +define+XO_TEST ../../../TestBench/Verilog/tst_bench_top.v
vlog -dbg +define+XO_TEST ../../../TestBench/Verilog/wb_master_model.v



vsim -L ovi_machxo -PL pmi_work +access +r tst_bench_top -noglitch +no_tchk_msg -sdfmax i2c_top = "../../../project/xo2/verilog/xo_verilog/xo_verilog_xo_verilog_vo.sdf"

add wave *

run -all
