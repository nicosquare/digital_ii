set PROJ_DIR "ENTER simulation DIRECTORY PATH HERE"

# Example:
# set PROJ_DIR "D:\rd1044_spi_controller_with_wishbone_interface\rd1044\simulation"

cd $PROJ_DIR/xo3l/verilog

if {![file exists rtl_verilog]} {
    vlib rtl_verilog
}
endif

design create rtl_verilog .
design open rtl_verilog
adel -all

cd $PROJ_DIR/xo3l/verilog


alog ../../../source/verilog/spi_wb.v \
../../../testbench/verilog/spi_wb_tb1.v

vsim +access +r spi_tf -PL pmi_work -L ovi_machxo3l

add wave /spi_tf/*

run -all