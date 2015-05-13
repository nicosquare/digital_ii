set PROJ_DIR "ENTER THE simulation DIRECTORY PATH HERE"
#eg
#set PROJ_DIR "D:\RD_Work_Area\rd1046_i2c_master_with_wishbone\rd1046\simulation\ecp3\vhdl"

cd $PROJ_DIR

if {![file exists work]} {
    vlib work 
}
endif

design create work .
design open work
adel -all

cd $PROJ_DIR

acom -dbg ../../../project/ecp3/vhdl/ecp3_vhdl/ecp3_vhdl_ecp3_vhdl_vho.vho


acom -dbg ../../../TestBench/Vhdl/i2c_slave_model.vhd

acom -dbg  ../../../TestBench/Vhdl/tst_bench_top.vhd



vsim +access +r tst_bench_top ben -noglitch -L machecp3 -PL pmi_work +no_tchk_msg -sdfmax i2c_top = "../../../project/ecp3/vhdl/ecp3_vhdl/ecp3_vhdl_ecp3_vhdl_vho.sdf"

add wave *

run 1494033 ns
