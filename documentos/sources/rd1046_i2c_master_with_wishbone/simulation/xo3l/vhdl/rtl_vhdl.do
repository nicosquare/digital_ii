set PROJ_DIR "ENTER THE simulation DIRECTORY PATH HERE"

# Example: 
#set PROJ_DIR "D:/RD_XO3/rd1046_i2c_master_with_wishbone/rd1046/simulation/xo3l/vhdl"

cd $PROJ_DIR

if {![file exists rtl_vhdl_sim]} {
    vlib rtl_vhdl_sim 
}
endif

design create rtl_vhdl_sim .
design open rtl_vhdl_sim
adel -all

cd $PROJ_DIR

acom ../../../source/vhdl/i2c_master_bit_ctrl.vhd
acom ../../../source/vhdl/i2c_master_byte_ctrl.vhd
acom ../../../source/vhdl/i2c_master_registers.vhd
acom ../../../source/vhdl/i2c_master_wb_top.vhd

acom ../../../testbench/vhdl/i2c_slave_model.vhd
acom ../../../testbench/vhdl/tst_bench_top.vhd

asim +access +r tst_bench_top -PL pmi_work -L ovi_machxo3l

add wave *
add wave /tst_bench_top/*

run 1274708 ns

