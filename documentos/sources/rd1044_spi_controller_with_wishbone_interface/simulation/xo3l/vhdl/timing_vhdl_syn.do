set PROJ_DIR "ENTER simulation DIRECTORY PATH HERE"

# Example:
# set PROJ_DIR "D:\rd1044_spi_controller_with_wishbone_interface\rd1044\simulation"

cd $PROJ_DIR/xo3l/vhdl

if {![file exists timing_vhdl_syn]} {
    vlib timing_vhdl_syn 
}
endif

design create timing_vhdl_syn .
design open timing_vhdl_syn
adel -all

cd $PROJ_DIR/xo3l/vhdl

acom ../../../project/xo3l/vhdl/xo3l_vhdl_syn/xo3l_vhdl_syn_xo3l_vhdl_syn_vho.vho 
alog ../../../testbench/vhdl/spi_wb_tb1.v
acom ../../../testbench/vhdl/spi_wb_tb1_vhdl_wrapper.vhd \
../../../testbench/vhdl/spi_top_vhdl.vhd

entity behavior
asim -sdfmax /top/uut=../../../project/xo3l/vhdl/xo3l_vhdl_syn/xo3l_vhdl_syn_xo3l_vhdl_syn_vho.sdf +transport_path_delays +transport_int_delays -O5 -L ovi_machxo3l -PL pmi_work +access +r +m+top top behavior -vhdlassertignore warning

add wave /top/*

run 1494032 ns