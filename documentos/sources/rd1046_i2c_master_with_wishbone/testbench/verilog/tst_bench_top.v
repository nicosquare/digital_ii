//   ==================================================================
//   >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
//   ------------------------------------------------------------------
//   Copyright (c) 2013 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED 
//   ------------------------------------------------------------------
//
//   Permission:
//
//      Lattice SG Pte. Ltd. grants permission to use this code
//      pursuant to the terms of the Lattice Reference Design License Agreement. 
//
//
//   Disclaimer:
//
//      This VHDL or Verilog source code is intended as a design reference
//      which illustrates how these types of functions can be implemented.
//      It is the user's responsibility to verify their design for
//      consistency and functionality through the use of formal
//      verification methods.  Lattice provides no warranty
//      regarding the use or functionality of this code.
//
//   --------------------------------------------------------------------
//
//                  Lattice SG Pte. Ltd.
//                  101 Thomson Road, United Square #07-02 
//                  Singapore 307591
//
//
//                  TEL: 1-800-Lattice (USA and Canada)
//                       +65-6631-2000 (Singapore)
//                       +1-503-268-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
//   --------------------------------------------------------------------
//  CVS Log
//
//  $Id: RD#RD1046#testbench#verilog#tst_bench_top.v,v 1.5 2013-10-10 07:47:09-07 vpatil Exp $
//
//  $Date: 2013-10-10 07:47:09-07 $
//  $Revision: 1.5 $
//  $Author: vpatil $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: RD#RD1046#testbench#verilog#tst_bench_top.v,v $
//               Revision 1.5  2013-10-10 07:47:09-07  vpatil
//               Updated header.
//
//               Revision 1.4  2013-07-04 02:56:28-07  lsccad
//               Automatically checked in.
//
//               Revision 1.8  2006/09/04 09:08:51  rherveille
//               fixed (n)ack generation
//
//               Revision 1.7  2005/02/27 09:24:18  rherveille
//               Fixed scl, sda delay.
//
//               Revision 1.6  2004/02/28 15:40:42  rherveille
//               *** empty log message ***
//
//               Revision 1.4  2003/12/05 11:04:38  rherveille
//               Added slave address configurability
//
//               Revision 1.3  2002/10/30 18:11:06  rherveille
//               Added timing tests to i2c_model.
//               Updated testbench.
//
//               Revision 1.2  2002/03/17 10:26:38  rherveille
//               Fixed some race conditions in the i2c-slave model.
//               Added debug information.
//               Added headers.
// 
//-------------------------------------------------------------------------
// Name:  tst_bench_top.v   
// 
// Description: This module is the top-level testbench, which controls the 
// flow of the wb v.s. i2c transmit and receive procedures. 
//   
//-------------------------------------------------------------------------
// LSC Code Revision History :
//-------------------------------------------------------------------------
// Ver: | Author	|Mod. Date	|Changes Made:
// V2.0 | cm		|12/2008        |rstn initialized to 0
//      |               		|use one i2c master for simulation
//      |                               |use 50MHz clock, prescaler to 100(h64)
//                                      |connect scl and sda instead of oe, i, o
//                                      |read memory within defined memory space (up to 03)
//	                                |replace q, qq with check_SR, data_rxr
//-------------------------------------------------------------------------

`include "timescale.v"

module tst_bench_top();

	//
	// wires && regs
	//
	reg  clk;  // master clock from wb
	reg  rstn; // async reset, not from wb

	wire [31:0] adr;
	wire [ 7:0] dat_i, dat_o, dat0_i; // dat1_i;
	wire we;
	wire stb;
	wire cyc;
	wire ack;
	wire inta;

	reg [7:0] check_SR, data_rxr;  // give meaningful names to q, and qq, respectively

	wire scl ; //scl0_o, scl0_oen,scl1_o, scl1_oen; cm - not using these signals
	wire sda ; //sda0_o, sda0_oen sda1_o, sda1_oen;

	parameter PRER_LO = 3'b000;
	parameter PRER_HI = 3'b001;
	parameter CTR     = 3'b010;
	parameter RXR     = 3'b011;
	parameter TXR     = 3'b011;
	parameter CR      = 3'b100;
	parameter SR      = 3'b100;

	parameter TXR_R   = 3'b101; // undocumented / reserved output
	parameter CR_R    = 3'b110; // undocumented / reserved output

	parameter RD      = 1'b1;
	parameter WR      = 1'b0;
	parameter SADR    = 7'b0010_000;

	//
	// Module body
	//

	// generate clock
	always #10 clk = ~clk;  // change to 50MHz clock

	// hookup wishbone master model
	wb_master_model #(8, 32) u0 (
		.clk(clk),
		.rst(rstn),
		.adr(adr),
		.din(dat_i),
		.dout(dat_o),
		.cyc(cyc),
		.stb(stb),
		.we(we),
		.sel(),
		.ack(ack),
		.err(1'b0),
		.rty(1'b0)
	);

	wire stb0 = stb & ~adr[3];
	//wire stb1 = stb &  adr[3];

	//assign dat_i = ({{8'd8}{stb0}} & dat0_i) | ({{8'd8}{stb1}} & dat1_i);
    assign dat_i = ({{8'd8}{stb0}} & dat0_i);

	// hookup wishbone_i2c_master core
	i2c_master_wb_top i2c_top (

		// wishbone interface
		.wb_clk_i(clk),
		.wb_rst_i(1'b0),
		.arst_i(rstn),
		.wb_adr_i(adr[2:0]),
		.wb_dat_i(dat_o),
		.wb_dat_o(dat0_i),
		.wb_we_i(we),
		.wb_stb_i(stb0),
		.wb_cyc_i(cyc),
		.wb_ack_o(ack),
		.wb_inta_o(inta),

		// i2c signals
		/*.scl_pad_i(scl),
		.scl_pad_o(scl0_o),
		.scl_padoen_o(scl0_oen),
		.sda_pad_i(sda),
		.sda_pad_o(sda0_o),
		.sda_padoen_o(sda0_oen)*/
         .scl(scl),
         .sda(sda)
	); //,
	/* i2c_top2 (

		// wishbone interface
		.wb_clk_i(clk),
		.wb_rst_i(1'b0),
		.arst_i(rstn),
		.wb_adr_i(adr[2:0]),
		.wb_dat_i(dat_o),
		.wb_dat_o(dat1_i),
		.wb_we_i(we),
		.wb_stb_i(stb1),
		.wb_cyc_i(cyc),
		.wb_ack_o(ack),
		.wb_inta_o(inta),

		// i2c signals
		.scl_pad_i(scl),
		.scl_pad_o(scl1_o),
		.scl_padoen_o(scl1_oen),
		.sda_pad_i(sda),
		.sda_pad_o(sda1_o),
		.sda_padoen_o(sda1_oen)
	); */


	// hookup i2c slave model
	i2c_slave_model #(SADR) i2c_slave (
		.scl(scl),
		.sda(sda)
	);

        // create i2c lines
	/*delay m0_scl (scl0_oen ? 1'bz : scl0_o, scl),
	      //m1_scl (scl1_oen ? 1'bz : scl1_o, scl),
	      m0_sda (sda0_oen ? 1'bz : sda0_o, sda); //,
	      //m1_sda (sda1_oen ? 1'bz : sda1_o, sda);
        */


	pullup p1(scl); // pullup scl line
	pullup p2(sda); // pullup sda line

	initial
	  begin
	      `ifdef WAVES
	         $shm_open("waves");
	         $shm_probe("AS",tst_bench_top,"AS");
	         $display("INFO: Signal dump enabled ...\n\n");
	      `endif

//	      force i2c_slave.debug = 1'b1; // enable i2c_slave debug information
	      force i2c_slave.debug = 1'b0; // disable i2c_slave debug information

	      $display("\nstatus: %t Testbench started\n\n", $time);

//	      $dumpfile("bench.vcd");
//	      $dumpvars(1, tst_bench_top);
//	      $dumpvars(1, tst_bench_top.i2c_slave);

	      // initially values
	      clk = 0;

	      // reset system
	      rstn = 1'b0; //cm: initialized to reset mode,1'b1; // negate reset
	      #2;
	      rstn = 1'b0; // assert reset
	      repeat(1) @(posedge clk);
	      rstn = 1'b1; // negate reset

	      $display("status: %t done reset", $time);

	      @(posedge clk);

	      //
	      // program core
	      //

	      // program internal registers
	      //u0.wb_write(1, PRER_LO, 8'hfa); // load prescaler lo-byte
	      //u0.wb_write(1, PRER_LO, 8'hc8); // load prescaler lo-byte
	      u0.wb_write(1, PRER_LO, 8'h64); // load prescaler lo-byte
	      u0.wb_write(1, PRER_HI, 8'h00); // load prescaler hi-byte
	      $display("status: %t programmed registers", $time);

	      //u0.wb_cmp(0, PRER_LO, 8'hc8); // verify prescaler lo-byte
		  u0.wb_cmp(0, PRER_LO, 8'h64); // verify prescaler lo-byte
	      u0.wb_cmp(0, PRER_HI, 8'h00); // verify prescaler hi-byte
	      $display("status: %t verified registers", $time);

	      u0.wb_write(1, CTR,     8'h80); // enable core
	      $display("status: %t core enabled", $time);

	      //
	      // access slave (write)
	      //

	      // drive slave address
	      u0.wb_write(1, TXR, {SADR,WR} ); // present slave address, set write-bit
	      u0.wb_write(0, CR,      8'h90 ); // set command (start, write)
	      $display("status: %t generate 'start', write cmd %0h (slave address+write)", $time, {SADR,WR} );

	      // check tip bit
	      u0.wb_read(1, SR, check_SR);
	      while(check_SR[1])
	           u0.wb_read(0, SR, check_SR); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // send memory address
	      u0.wb_write(1, TXR,     8'h01); // present slave's memory address
	      u0.wb_write(0, CR,      8'h10); // set command (write)
	      $display("status: %t write slave memory address 01", $time);

	      // check tip bit
	      u0.wb_read(1, SR, check_SR);
	      while(check_SR[1])
	           u0.wb_read(0, SR, check_SR); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // send memory contents
	      u0.wb_write(1, TXR,     8'ha5); // present data
	      u0.wb_write(0, CR,      8'h10); // set command (write)
	      $display("status: %t write data a5", $time);

              // emulate clock stretching
             while (scl) #1;
             force scl= 1'b0;
             #100000;
             release scl;

	      // check tip bit
	      u0.wb_read(1, SR, check_SR);
	      while(check_SR[1])
	           u0.wb_read(1, SR, check_SR); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // send memory contents for next memory address (auto_inc)
	      u0.wb_write(1, TXR,     8'h5a); // present data
	      u0.wb_write(0, CR,      8'h50); // set command (stop, write)
	      $display("status: %t write next data 5a, generate 'stop'", $time);

	      // check tip bit
	      u0.wb_read(1, SR, check_SR);
	      while(check_SR[1])
	           u0.wb_read(1, SR, check_SR); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      //
	      // delay
	      //
//	      #100000; // wait for 100us.
//	      $display("status: %t wait 100us", $time);

	      //
	      // access slave (read)
	      //

	      // drive slave address
	      u0.wb_write(1, TXR,{SADR,WR} ); // present slave address, set write-bit
	      u0.wb_write(0, CR,     8'h90 ); // set command (start, write)
	      $display("status: %t generate 'start', write cmd %0h (slave address+write)", $time, {SADR,WR} );

	      // check tip bit
	      u0.wb_read(1, SR, check_SR);
	      while(check_SR[1])
	           u0.wb_read(1, SR, check_SR); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // send memory address
	      u0.wb_write(1, TXR,     8'h01); // present slave's memory address
	      u0.wb_write(0, CR,      8'h10); // set command (write)
	      $display("status: %t write slave address 01", $time);

	      // check tip bit
	      u0.wb_read(1, SR, check_SR);
	      while(check_SR[1])
	           u0.wb_read(1, SR, check_SR); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // drive slave address
	      u0.wb_write(1, TXR, {SADR,RD} ); // present slave's address, set read-bit
	      u0.wb_write(0, CR,      8'h90 ); // set command (start, write)
	      $display("status: %t generate 'repeated start', write cmd %0h (slave address+read)", $time, {SADR,RD} );

	      // check tip bit
	      u0.wb_read(1, SR, check_SR);
	      while(check_SR[1])
	           u0.wb_read(1, SR, check_SR); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // read data from slave
	      u0.wb_write(1, CR,      8'h20); // set command (read, ack_read)
	      $display("status: %t read + ack", $time);

	      // check tip bit
	      u0.wb_read(1, SR, check_SR);
	      while(check_SR[1])
	           u0.wb_read(1, SR, check_SR); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // check data just received
	      u0.wb_read(1, RXR, data_rxr);
	      if(data_rxr !== 8'ha5)
	        $display("\nERROR: Expected a5, received %x at time %t", data_rxr, $time);
	      else
	        $display("status: %t received %x", $time, data_rxr);

	      // read data from slave
	      u0.wb_write(1, CR,      8'h20); // set command (read, ack_read)
	      $display("status: %t read + ack", $time);

	      // check tip bit
	      u0.wb_read(1, SR, check_SR);
	      while(check_SR[1])
	           u0.wb_read(1, SR, check_SR); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // check data just received
	      u0.wb_read(1, RXR, data_rxr);
	      if(data_rxr !== 8'h5a)
	        $display("\nERROR: Expected 5a, received %x at time %t", data_rxr, $time);
	      else
	        $display("status: %t received %x", $time, data_rxr);

	      // read data from slave
	      //u0.wb_write(1, CR,      8'h20); // set command (read, ack_read) cm - stop the simulation
	      u0.wb_write(1, CR,      8'h28); // set command (read, nack_read)
	      //$display("status: %t read + ack", $time); cm - stop the simulation
	      $display("status: %t read + nack", $time);

	      // check tip bit
	      u0.wb_read(1, SR, check_SR);
	      while(check_SR[1])
	           u0.wb_read(1, SR, check_SR); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // check data just received
	      u0.wb_read(1, RXR, data_rxr);
	      $display("status: %t received %x from 3rd read address", $time, data_rxr);

	      //
	      // check invalid slave memory address
	      //

	      // drive slave address
	      u0.wb_write(1, TXR, {SADR,WR} ); // present slave address, set write-bit
	      u0.wb_write(0, CR,      8'h90 ); // set command (start, write)
	      $display("status: %t generate 'start', write cmd %0h (slave address+write). Check invalid address", $time, {SADR,WR} );

	      // check tip bit
	      u0.wb_read(1, SR, check_SR);
	      while(check_SR[1])
	           u0.wb_read(1, SR, check_SR); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // send memory address
	      u0.wb_write(1, TXR,     8'h10); // present slave's memory address
	      u0.wb_write(0, CR,      8'h10); // set command (write)
	      $display("status: %t write slave memory address 10", $time);

	      // check tip bit
	      u0.wb_read(1, SR, check_SR);
	      while(check_SR[1])
	           u0.wb_read(1, SR, check_SR); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // slave should have send NACK
	      $display("status: %t Check for nack", $time);
	      if(!check_SR[7])
	        $display("\nERROR: Expected NACK, received ACK\n");

	      // read data from slave
	      u0.wb_write(1, CR,      8'h40); // set command (stop)
	      $display("status: %t generate 'stop'", $time);

	      // check tip bit
	      u0.wb_read(1, SR, check_SR);
	      while(check_SR[1])
	      u0.wb_read(1, SR, check_SR); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      #250000; // wait 250us
	      $display("\n\nstatus: %t Testbench done", $time);
	      $finish;
	  end

endmodule

/*module delay (in, out);
  input  in;
  output out;

  assign out = in; 

  specify
    (in => out) = (600,600);
  endspecify 
  
endmodule */


