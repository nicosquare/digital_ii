set PROJ_DIR "D:\RD_Work_Area\rd1046_i2c_master_with_wishbone\rd1046\simulation\ecp3\verilog"

cd $PROJ_DIR

if {![file exists work]} {
    vlib work 
}
endif

design create work .
design open work
adel -all

cd $PROJ_DIR

vlog -dbg ../../../project/ecp3/verilog/ecp3_verilog/ecp3_verilog_ecp3_verilog_vo.vo


vlog -dbg +define+ecp3_TEST ../../../TestBench/Verilog/i2c_slave_model.v
vlog -dbg +define+ecp3_TEST ../../../TestBench/Verilog/timescale.v
vlog -dbg +define+ecp3_TEST ../../../TestBench/Verilog/tst_bench_top.v
vlog -dbg +define+ecp3_TEST ../../../TestBench/Verilog/wb_master_model.v



vsim -L ovi_ecp3 -PL pmi_work +access +r tst_bench_top -noglitch +no_tchk_msg -sdfmax i2c_top = "../../../project/ecp3/verilog/ecp3_verilog/ecp3_verilog_ecp3_verilog_vo.sdf"

add wave *

run -all