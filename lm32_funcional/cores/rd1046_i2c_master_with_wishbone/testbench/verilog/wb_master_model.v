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
//  $Id: RD#RD1046#testbench#verilog#wb_master_model.v,v 1.5 2013-10-10 07:47:05-07 vpatil Exp $
//
//  $Date: 2013-10-10 07:47:05-07 $
//  $Revision: 1.5 $
//  $Author: vpatil $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//   
//-------------------------------------------------------------------------
// LSC Code Revision History :
//-------------------------------------------------------------------------
// Ver: | Author	|Mod. Date	|Changes Made:
// V2.0 | cm		|12/2008        |change initial state from x to known logic
//      |               |		|change abitrary time to #2 to avoid timing error
//-------------------------------------------------------------------------
`include "timescale.v"

module wb_master_model(clk, rst, adr, din, dout, cyc, stb, we, sel, ack, err, rty);

parameter dwidth = 32;
parameter awidth = 32;

input                  clk, rst;
output [awidth   -1:0]	adr;
input  [dwidth   -1:0]	din;
output [dwidth   -1:0]	dout;
output                 cyc, stb;
output       	        	we;
output [dwidth/8 -1:0] sel;
input		                ack, err, rty;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	[awidth   -1:0]	adr;
reg	[dwidth   -1:0]	dout;
reg		               cyc, stb;
reg		               we;
reg [dwidth/8 -1:0] sel;

reg [dwidth   -1:0] q;

////////////////////////////////////////////////////////////////////
//
// Memory Logic
//

initial
	begin
		//adr = 32'hxxxx_xxxx;
		//adr = 0;
		adr  = {awidth{1'bx}};
		dout = {dwidth{1'bx}};
		cyc  = 1'b0;
		stb  = 1'b1; //1'bx; cm - initiallize to inactive state
		we   = 1'b0; //1'hx; cm - initiallize to inactive state
		sel  = {dwidth/8{1'bx}};
		#1;
		$display("\nINFO: WISHBONE MASTER MODEL INSTANTIATED (%m)\n");
	end

////////////////////////////////////////////////////////////////////
//
// Wishbone write cycle
//

task wb_write;
	input   delay;
	integer delay;

	input	[awidth -1:0]	a;
	input	[dwidth -1:0]	d;

	begin

		// wait initial delay
		repeat(delay) @(posedge clk);

		// assert wishbone signal
		#2;  // wait 2ns instead of 1
		adr  = a;
		dout = d;
		cyc  = 1'b1;
		stb  = 1'b1;
		we   = 1'b1;
		sel  = {dwidth/8{1'b1}};
		@(posedge clk);

		// wait for acknowledge from slave
		while(~ack)	@(posedge clk);

		// negate wishbone signals
		#2;
		cyc  = 1'b0;
		stb  = 1'b0; //1'bx; cm - chagne to inactive state
		adr  = {awidth{1'bx}};
		dout = {dwidth{1'bx}};
		we   = 1'b0; //1'hx; cm - change to inactive state
		sel  = {dwidth/8{1'bx}};

	end
endtask

////////////////////////////////////////////////////////////////////
//
// Wishbone read cycle
//

task wb_read;
	input   delay;
	integer delay;

	input	 [awidth -1:0]	a;
	output	[dwidth -1:0]	d;

	begin

		// wait initial delay
		repeat(delay) @(posedge clk);

		// assert wishbone signals
		#2;  // wait 2 ns instead of 1
		adr  = a;
		dout = {dwidth{1'bx}};
		cyc  = 1'b1;
		stb  = 1'b1;
		we   = 1'b0;
		sel  = {dwidth/8{1'b1}};
		@(posedge clk);

		// wait for acknowledge from slave
		while(~ack)	@(posedge clk);

		// negate wishbone signals
		#2;
		cyc  = 1'b0;
		stb  = 1'b0; //1'bx; cm - change to inactive state
		adr  = {awidth{1'bx}};
		dout = {dwidth{1'bx}};
		we   = 1'b0; //1'hx; cm - change to inactive state
		sel  = {dwidth/8{1'bx}};
		d    = din;

	end
endtask

////////////////////////////////////////////////////////////////////
//
// Wishbone compare cycle (read data from location and compare with expected data)
//

task wb_cmp;
	input   delay;
	integer delay;

	input [awidth -1:0]	a;
	input	[dwidth -1:0]	d_exp;

	begin
		wb_read (delay, a, q);

		if (d_exp !== q)
			$display("Data compare error. Received %h, expected %h at time %t", q, d_exp, $time);
	end
endtask

endmodule


