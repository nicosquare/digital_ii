set PROJ_DIR "ENTER simulation DIRECTORY PATH HERE"

# Example:
# set PROJ_DIR "D:\rd1044_spi_controller_with_wishbone_interface\rd1044\simulation"

cd $PROJ_DIR/xo3l/verilog

if {![file exists timing_verilog_lse]} {
    vlib timing_verilog_lse 
}
endif

design create timing_verilog_lse .
design open timing_verilog_lse
adel -all

cd $PROJ_DIR/xo3l/verilog

alog ../../../project/xo3l/verilog/xo3l_verilog_lse/xo3l_verilog_lse_xo3l_verilog_lse_vo.vo \
../../../testbench/verilog/spi_wb_tb1.v

vsim +access +r spi_tf -noglitch +no_tchk_msg -sdfmax /spi_tf/UUT="../../../project/xo3l/verilog/xo3l_verilog_lse/xo3l_verilog_lse_xo3l_verilog_lse_vo.sdf" -PL pmi_work -L ovi_machxo3l +transport_path_delays +transport_int_delays

add wave /spi_tf/*

run -all