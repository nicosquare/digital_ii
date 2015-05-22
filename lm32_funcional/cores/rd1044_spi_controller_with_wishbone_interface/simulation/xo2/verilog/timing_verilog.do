set PROJ_DIR "ENTER simulation DIRECTORY PATH"

# Example:
# set PROJ_DIR "D:\rd1044_spi_controller_with_wishbone_interface\rd1044\simulation"

cd $PROJ_DIR/xo2/verilog

if {![file exists timing_verilog]} {
    vlib timing_verilog 
}
endif

design create timing_verilog .
design open timing_verilog
adel -all

cd $PROJ_DIR/xo2/verilog

vlog ../../../project/xo2/verilog/xo2_verilog/xo2_verilog_xo2_verilog_vo.vo
vlog ../../../testbench/verilog/spi_wb_tb1.v

vsim +access +r spi_tf -noglitch +no_tchk_msg -sdfmax /spi_tf/UUT="../../../project/xo2/verilog/xo2_verilog/xo2_verilog_xo2_verilog_vo.sdf" -PL pmi_work -L ovi_machxo2 +transport_path_delays +transport_int_delays

add wave /spi_tf/*

run -all
