set PROJ_DIR "D:\RD_Work_Area\rd1046_i2c_master_with_wishbone\rd1046\simulation\ecp5\verilog" 

##"Enter Simulation Directory Path Here"

cd $PROJ_DIR

if {![file exists work]} {
    vlib work 
}
endif

design create work .
design open work
adel -all

cd $PROJ_DIR

vlog ../../../Source/Verilog/i2c_master_bit_ctrl.v
vlog ../../../Source/Verilog/i2c_master_byte_ctrl.v
vlog ../../../Source/Verilog/i2c_master_defines.v
vlog ../../../Source/Verilog/i2c_master_registers.v
vlog ../../../Source/Verilog/i2c_master_wb_top.v

vlog ../../../Testbench/Verilog/i2c_slave_model.v
vlog ../../../Testbench/Verilog/timescale.v
vlog ../../../Testbench/Verilog/tst_bench_top.v
vlog ../../../Testbench/Verilog/wb_master_model.v



vsim +access +r tst_bench_top -PL pmi_work -L ovi_machecp5

add wave *
add wave top_inst/*

run -all