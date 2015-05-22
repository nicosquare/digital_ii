set PROJ_DIR "ENTER THE simulation DIRECTORY PATH HERE"

# Example: 
#set PROJ_DIR "D:/RD_XO3/rd1046_i2c_master_with_wishbone/rd1046/simulation/xo3l/verilog"

cd $PROJ_DIR

if {![file exists work]} {
    vlib work 
}
endif

design create work .
design open work
adel -all

cd $PROJ_DIR

vlog -dbg  ../../../project/xo3l/verilog/xo3l_verilog/xo3l_verilog_xo3l_verilog_vo.vo

vlog -dbg +define+XO2_TEST ../../../TestBench/Verilog/i2c_slave_model.v
vlog -dbg +define+XO2_TEST ../../../TestBench/Verilog/timescale.v
vlog -dbg +define+XO2_TEST ../../../TestBench/Verilog/tst_bench_top.v
vlog -dbg +define+XO2_TEST ../../../TestBench/Verilog/wb_master_model.v

vsim +access +r tst_bench_top -noglitch +no_tchk_msg -sdfmax /tst_bench_top/i2c_top="../../../project/xo3l/verilog/xo3l_verilog/xo3l_verilog_xo3l_verilog_vo.sdf" -PL pmi_work -L ovi_machxo3l +transport_path_delays +transport_int_delays

#add wave *
add wave /tst_bench_top/*

run 1494032 ns