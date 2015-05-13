//---------------------------------------------------------------------------
// LatticeMico32 System On A Chip
//
// Top Level Design for the Xilinx Spartan 3-200 Starter Kit
//---------------------------------------------------------------------------

module system
#(
	parameter   bootram_file     = "../firmware/boot0-serial/image.ram",
	parameter   clk_freq         = 100000000,
	parameter   uart_baud_rate   = 115200
) (
	input       clk,
	// Debug 
	output      led,
	input       rst,

	// UART
	input       uart_rxd, 
	output      uart_txd

);


wire sys_clk = clk;
wire sys_clk_n = ~clk;
	
//------------------------------------------------------------------
// Whishbone Wires
//------------------------------------------------------------------

// Ground wires
wire         gnd   =  1'b0;
wire   [3:0] gnd4  =  4'h0;
wire  [31:0] gnd32 = 32'h00000000;

// Address bus
wire [31:0]  lm32i_adr,
             lm32d_adr,
             bram0_adr,
             i2c0_adr,
             spi0_adr,
             gpio0_adr,
             timer0_adr,

// Read/Write bus
wire [31:0]  lm32i_dat_r,
             lm32i_dat_w,
             lm32d_dat_r,
             lm32d_dat_w,
             bram0_dat_r,
             bram0_dat_w,
             i2c0_dat_r,
             i2c0_dat_w,
             spi0_dat_w,
             spi0_dat_r,
             gpio0_dat_r,
             gpio0_dat_w,
             timer0_dat_r,
             timer0_dat_w,

// Selector bus             
wire [3:0]   lm32i_sel,
             lm32d_sel,
             bram0_sel,
             i2c0_sel,
             spi0_sel;
	     gpio0_sel,
             timer0_sel,

// Write enable 
wire         lm32i_we,
             lm32d_we,
             bram0_we,
             i2c0_we,
             spi0_we,
             gpio0_we,
             timer0_we,
             
// Clock cycle
wire         lm32i_cyc,
             lm32d_cyc,
             bram0_cyc,
             i2c0_cyc,
             spi0_cyc,
             gpio0_cyc,
             timer0_cyc,

// Strobe
wire         lm32i_stb,
             lm32d_stb,
             bram0_stb,
             i2c0_stb,
             spi0_stb,
             gpio0_stb,
             timer0_stb,
             
// Acknowledge
wire         lm32i_ack,
             lm32d_ack,
             bram0_ack,
             i2c0_ack,
             spi0_ack,
             gpio0_ack,
             timer0_ack,
             
// Only for Master 0,1 (LM32 Data/Interruption)
wire         lm32i_rty,
             lm32d_rty;

wire         lm32i_err,
             lm32d_err;

wire         lm32i_lock,
             lm32d_lock;

wire [2:0]   lm32i_cti,
             lm32d_cti;

wire [1:0]   lm32i_bte,
             lm32d_bte;

//---------------------------------------------------------------------------
// Interrupts
//---------------------------------------------------------------------------
wire [31:0]  intr_n;
wire         i2c0_intr = 0;
wire         spi0_intr = 0;
wire         gpio0_intr = 0;
wire [1:0]   timer0_intr;

assign intr_n = { 28'hFFFFFFF, ~timer0_intr[1], ~timer0_intr[0], ~gpio0_intr, ~spi0_intr, ~i2c0_intr };

//---------------------------------------------------------------------------
// Wishbone Interconnect
//---------------------------------------------------------------------------
conbus #(
	.s_addr_w(3),		// wishbone address bus
	.s0_addr(4'h0),		// bram     0x00000000 
	.s1_addr(4'h1),		// i2c      0x20000000 
	.s2_addr(4'h2),		// spi      0x40000000 
	.s3_addr(4'h3)  	// gpio     0x60000000
	.s3_addr(4'h4)	        // timer    0x80000000 

) conbus0(
	.sys_clk( clk ),
	.sys_rst( ~rst ),
	// Master0
	.m0_dat_i(  lm32i_dat_w  ),
	.m0_dat_o(  lm32i_dat_r  ),
	.m0_adr_i(  lm32i_adr    ),
	.m0_we_i (  lm32i_we     ),
	.m0_sel_i(  lm32i_sel    ),
	.m0_cyc_i(  lm32i_cyc    ),
	.m0_stb_i(  lm32i_stb    ),
	.m0_ack_o(  lm32i_ack    ),
	// Master1
	.m1_dat_i(  lm32d_dat_w  ),
	.m1_dat_o(  lm32d_dat_r  ),
	.m1_adr_i(  lm32d_adr    ),
	.m1_we_i (  lm32d_we     ),
	.m1_sel_i(  lm32d_sel    ),
	.m1_cyc_i(  lm32d_cyc    ),
	.m1_stb_i(  lm32d_stb    ),
	.m1_ack_o(  lm32d_ack    ),
	// Master2
	.m2_dat_i(  gnd32  ),
	.m2_adr_i(  gnd32  ),
	.m2_sel_i(  gnd4   ),
	.m2_cyc_i(  gnd    ),
	.m2_stb_i(  gnd    ),
	// Master3
	.m3_dat_i(  gnd32  ),
	.m3_adr_i(  gnd32  ),
	.m3_sel_i(  gnd4   ),
	.m3_cyc_i(  gnd    ),
	.m3_stb_i(  gnd    ),
	// Master4
	.m4_dat_i(  gnd32  ),
	.m4_adr_i(  gnd32  ),
	.m4_sel_i(  gnd4   ),
	.m4_cyc_i(  gnd    ),
	.m4_stb_i(  gnd    ),
	// Master5
	.m5_dat_i(  gnd32  ),
	.m5_adr_i(  gnd32  ),
	.m5_sel_i(  gnd4   ),
	.m5_cyc_i(  gnd    ),
	.m5_stb_i(  gnd    ),
	// Master6
	.m6_dat_i(  gnd32  ),
	.m6_adr_i(  gnd32  ),
	.m6_sel_i(  gnd4   ),
	.m6_cyc_i(  gnd    ),
	.m6_stb_i(  gnd    ),


	// Slave0  bram
	.s0_dat_i(  bram0_dat_r ),
	.s0_dat_o(  bram0_dat_w ),
	.s0_adr_o(  bram0_adr   ),
	.s0_sel_o(  bram0_sel   ),
	.s0_we_o(   bram0_we    ),
	.s0_cyc_o(  bram0_cyc   ),
	.s0_stb_o(  bram0_stb   ),
	.s0_ack_i(  bram0_ack   ),
	// Slave1 i2c
	.s1_dat_i(  i2c0_dat_r ),
	.s1_dat_o(  i2c0_dat_w ),
	.s1_adr_o(  i2c0_adr   ),
	.s1_sel_o(  i2c0_sel   ),
	.s1_we_o(   i2c0_we    ),
	.s1_cyc_o(  i2c0_cyc   ),
	.s1_stb_o(  i2c0_stb   ),
	.s1_ack_i(  i2c0_ack   ),
	// Slave2 spi
	.s2_dat_i(  spi0_dat_r ),
	.s2_dat_o(  spi0_dat_w ),
	.s2_adr_o(  spi0_adr   ),
	.s2_sel_o(  spi0_sel   ),
	.s2_we_o(   spi0_we    ),
	.s2_cyc_o(  spi0_cyc   ),
	.s2_stb_o(  spi0_stb   ),
	.s2_ack_i(  spi0_ack   ),
	// Slave3 gpio
	.s3_dat_i(  gpio0_dat_r ),
	.s3_dat_o(  gpio0_dat_w ),
	.s3_adr_o(  gpio0_adr   ),
	.s3_sel_o(  gpio0_sel   ),
	.s3_we_o(   gpio0_we    ),
	.s3_cyc_o(  gpio0_cyc   ),
	.s3_stb_o(  gpio0_stb   ),
	.s3_ack_i(  gpio0_ack   ),
	// Slave4 timer
	.s4_dat_i(  timer0_dat_r ),
	.s4_dat_o(  timer0_dat_w ),
	.s4_adr_o(  timer0_adr   ),
	.s4_sel_o(  timer0_sel   ),
	.s4_we_o(   timer0_we    ),
	.s4_cyc_o(  timer0_cyc   ),
	.s4_stb_o(  timer0_stb   ),
	.s4_ack_i(  timer0_ack   )
);


//---------------------------------------------------------------------------
// LM32 CPU 
//---------------------------------------------------------------------------
lm32_cpu lm0 (
	.clk_i(  clk  ),
	.rst_i(  ~rst  ),
	.interrupt_n(  intr_n  ),
	//
	.I_ADR_O(  lm32i_adr    ),
	.I_DAT_I(  lm32i_dat_r  ),
	.I_DAT_O(  lm32i_dat_w  ),
	.I_SEL_O(  lm32i_sel    ),
	.I_CYC_O(  lm32i_cyc    ),
	.I_STB_O(  lm32i_stb    ),
	.I_ACK_I(  lm32i_ack    ),
	.I_WE_O (  lm32i_we     ),
	.I_CTI_O(  lm32i_cti    ),
	.I_LOCK_O( lm32i_lock   ),
	.I_BTE_O(  lm32i_bte    ),
	.I_ERR_I(  lm32i_err    ),
	.I_RTY_I(  lm32i_rty    ),
	//
	.D_ADR_O(  lm32d_adr    ),
	.D_DAT_I(  lm32d_dat_r  ),
	.D_DAT_O(  lm32d_dat_w  ),
	.D_SEL_O(  lm32d_sel    ),
	.D_CYC_O(  lm32d_cyc    ),
	.D_STB_O(  lm32d_stb    ),
	.D_ACK_I(  lm32d_ack    ),
	.D_WE_O (  lm32d_we     ),
	.D_CTI_O(  lm32d_cti    ),
	.D_LOCK_O( lm32d_lock   ),
	.D_BTE_O(  lm32d_bte    ),
	.D_ERR_I(  lm32d_err    ),
	.D_RTY_I(  lm32d_rty    )
);
	
//---------------------------------------------------------------------------
// Block RAM
//---------------------------------------------------------------------------
wb_bram #(
	.adr_width( 12 ),
	.mem_file_name( bootram_file )
) bram0 (
	.clk_i(  clk  ),
	.rst_i(  ~rst  ),
	//
	.wb_adr_i(  bram0_adr    ),
	.wb_dat_o(  bram0_dat_r  ),
	.wb_dat_i(  bram0_dat_w  ),
	.wb_sel_i(  bram0_sel    ),
	.wb_stb_i(  bram0_stb    ),
	.wb_cyc_i(  bram0_cyc    ),
	.wb_ack_o(  bram0_ack    ),
	.wb_we_i(   bram0_we     )
);


//---------------------------------------------------------------------------
// i2c0
//---------------------------------------------------------------------------

wire	i2c0_scl;
wire	i2c0_sda;

i2c_master_wb_top #(
	.ARST_LVL(1'b1)
) i2c0 (
	//Whishbone connection
	.wb_clk_i( clk ),
	.wb_rst_i( ~rst ),
	//
	.arst_i( gnd ),
	.wb_adr_i( i2c0_adr[7:0] ),
	.wb_dat_i( i2c0_dat_w[7:0]),
	.wb_dat_o( i2c0_dat_r[7:0]),
	.wb_stb_i( i2c0_stb ),
	.wb_cyc_i( i2c0_cyc ),
	.wb_we_i(  i2c0_we ),
	.wb_sel_i( i2c0_sel ),
	.wb_ack_o( i2c0_ack ),
	// I2C connection
	.scl( i2c0_scl ),
	.sda( i2c0_sda )

);

//---------------------------------------------------------------------------
// General Purpose IO
//---------------------------------------------------------------------------

wire [7:0] 	gpio0_io;
wire        gpio0_irq;

wb_gpio gpio0 (
	.clk( clk ),
	.rst( ~rst ),
	//
	.wb_adr_i( gpio0_adr    ),
	.wb_dat_i( gpio0_dat_w  ),
	.wb_dat_o( gpio0_dat_r  ),
	.wb_stb_i( gpio0_stb    ),
	.wb_cyc_i( gpio0_cyc    ),
	.wb_we_i(  gpio0_we     ),
	.wb_ack_o( gpio0_ack    ), 
	// GPIO
	.gpio_io(gpio0_io)
);

//---------------------------------------------------------------------------
// timer0
//---------------------------------------------------------------------------
wb_timer #(
	.clk_freq(   clk_freq  )
) timer0 (
	.clk(      clk          ),
	.reset(    ~rst          ),
	//
	.wb_adr_i( timer0_adr   ),
	.wb_dat_i( timer0_dat_w ),
	.wb_dat_o( timer0_dat_r ),
	.wb_stb_i( timer0_stb   ),
	.wb_cyc_i( timer0_cyc   ),
	.wb_we_i(  timer0_we    ),
	.wb_sel_i( timer0_sel   ),
	.wb_ack_o( timer0_ack   ), 
	.intr(     timer0_intr  )
);

endmodule 
