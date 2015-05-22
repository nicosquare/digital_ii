set PROJ_DIR "ENTER THE simulation DIRECTORY PATH HERE"

# Example: 
#set PROJ_DIR "D:/RD_XO3/rd1046_i2c_master_with_wishbone/rd1046/simulation/xo3l/vhdl"

cd $PROJ_DIR

if {![file exists timing_vhdl_sim]} {
    vlib timing_vhdl_sim 
}
endif

design create timing_vhdl_sim .
design open timing_vhdl_sim
adel -all

cd $PROJ_DIR


acom -dbg  ../../../project/xo3l/vhdl/xo3l_vhdl/xo3l_vhdl_xo3l_vhdl_vho.vho 
acom -dbg ../../../TestBench/Vhdl/i2c_slave_model.vhd
acom -dbg  ../../../TestBench/Vhdl/tst_bench_top.vhd

entity ben
vsim +access +r tst_bench_top -sdfmax /tst_bench_top/i2c_top=../../../project/xo3l/vhdl/xo3l_vhdl/xo3l_vhdl_xo3l_vhdl_vho.sdf -PL pmi_work -L ovi_machxo3l +transport_path_delays +transport_int_delays -vhdlassertignore warning

#add wave *
add wave /tst_bench_top/*

run 1282380 ns