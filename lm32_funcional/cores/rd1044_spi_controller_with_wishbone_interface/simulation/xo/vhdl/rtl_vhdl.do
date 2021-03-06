set PROJ_DIR "ENTER simulation DIRECTORY PATH"

# Example:
# set PROJ_DIR "D:\rd1044_spi_controller_with_wishbone_interface\rd1044\simulation"

cd $PROJ_DIR/xo/vhdl

if {![file exists rtl_vhdl]} {
    vlib rtl_vhdl 
}
endif

design create rtl_vhdl .
design open rtl_vhdl
adel -all

cd $PROJ_DIR/xo/vhdl

acom -O3 -2008 ../../../source/vhdl/spi.vhd
alog -O2 -sve ../../../testbench/vhdl/spi_wb_tb1.v
acom -O3 -2008 ../../../testbench/vhdl/spi_wb_tb1_vhdl_wrapper.vhd \
../../../testbench/vhdl/spi_top_vhdl.vhd

entity behavior
asim +access +r top -PL pmi_work -L ovi_machxo -vhdlassertignore warning

add wave /top/*

run 1274708 ns