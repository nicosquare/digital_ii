set PROJ_DIR "ENTER simulation DIRECTORY PATH"

# Example:
# set PROJ_DIR "D:\rd1044_spi_controller_with_wishbone_interface\rd1044\simulation"

cd $PROJ_DIR/xo/vhdl

if {![file exists timing_vhdl]} {
    vlib timing_vhdl 
}
endif

design create timing_vhdl .
design open timing_vhdl
adel -all

cd $PROJ_DIR/xo/vhdl

vcom ../../../project/xo/vhdl/xo_vhdl/xo_vhdl_xo_vhdl_vho.vho
vlog ../../../testbench/vhdl/spi_wb_tb1.v
vcom ../../../testbench/vhdl/spi_wb_tb1_vhdl_wrapper.vhd
vcom ../../../testbench/vhdl/spi_top_vhdl.vhd


asim -sdfmax /top/uut=../../../project/xo/vhdl/xo_vhdl/xo_vhdl_xo_vhdl_vho.sdf +transport_path_delays +transport_int_delays -O5 -L ovi_machxo -PL pmi_work +access +r +m+top top behavior -vhdlassertignore warning

add wave /top/*

run 1494032 ns


