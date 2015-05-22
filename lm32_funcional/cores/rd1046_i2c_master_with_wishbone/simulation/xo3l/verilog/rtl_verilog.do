set PROJ_DIR "ENTER THE simulation DIRECTORY PATH HERE"

# Example: 
#set PROJ_DIR "D:/RD_XO3/rd1046_i2c_master_with_wishbone/rd1046/simulation/xo3l/verilog"

cd $PROJ_DIR

if {![file exists rtl_verilog_sim]} {
    vlib rtl_verilog_sim 
}
endif

design create rtl_verilog_sim .
design open rtl_verilog_sim
adel -all
#cd $PROJ_DIR
cd ..
cd ..

alog -O2 -sve -work rtl_verilog_sim ../../../testbench/verilog/i2c_slave_model.v \
../../../source/verilog/i2c_master_registers.v \
../../../source/verilog/i2c_master_bit_ctrl.v \
../../../source/verilog/i2c_master_byte_ctrl.v \
../../../source/verilog/i2c_master_wb_top.v \
../../../testbench/verilog/wb_master_model.v \
../../../testbench/verilog/tst_bench_top.v \
../../../source/verilog/i2c_master_defines.v \
../../../testbench/verilog/timescale.v

vsim +access +r tst_bench_top -PL pmi_work -L ovi_machxo3l

#add wave *
add wave /tst_bench_top/*

run 1494032 ns










