set PROJ_DIR "ENTER THE simulation DIRECTORY PATH HERE"
#eg
#set PROJ_DIR "D:\RD_Work_Area\rd1046_i2c_master_with_wishbone\rd1046\simulation\xp2\vhdl"

cd $PROJ_DIR

if {![file exists work]} {
    vlib work 
}
endif

design create work .
design open work
adel -all

cd $PROJ_DIR

acom ../../../source/vhdl/i2c_master_bit_ctrl.vhd
acom ../../../source/vhdl/i2c_master_byte_ctrl.vhd
acom ../../../source/vhdl/i2c_master_registers.vhd
acom ../../../source/vhdl/i2c_master_wb_top.vhd

acom ../../../testbench/vhdl/i2c_slave_model.vhd
acom ../../../testbench/vhdl/tst_bench_top.vhd



asim +access +r tst_bench_top -PL pmi_work -L ovi_xp2

add wave *
add wave top_inst/*

run 1494033 ns

