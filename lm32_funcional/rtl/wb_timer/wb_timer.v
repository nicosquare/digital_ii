//---------------------------------------------------------------------------
//
// Wishbone Timer
//
// Register Description:
//
//    0x00 TCR0
//    0x04 COMPARE0
//    0x08 COUNTER0
//    -------------
//    0x0C TCR1
//    0x10 COMPARE1
//    0x14 COUNTER1
//    -------------
//    0x18 TCR2
//    0x1C COMPARE2
//    0x20 COUNTER2
//    -------------
//    0x24 TCR3
//    0x28 COMPARE3
//    0x2C COUNTER3
//    -------------
//    0x30 TCR4
//    0x34 COMPARE4
//    0x38 COUNTER4
//    -------------
//    0x3C TCR5
//    0x40 COMPARE5
//    0x44 COUNTER5
//    -------------
//    0x48 TCR6
//    0x4C COMPARE6
//    0x50 COUNTER6
//    -------------
//    0x54 TCR7
//    0x58 COMPARE7
//    0x5C COUNTER7
//
// TCRx:  
//    +-------------------+-------+-------+-------+-------+
//    |     28'b0         |  EN   |  AR   | IRQEN |  TRIG |
//    +-------------------+-------+-------+-------+-------+
//
//   EN i  (rw)   if set to '1', COUNTERX counts upwards until it reaches
//                COMPAREX
//   AR    (rw)   AutoRecwstartload -- if COUNTER reaches COMPAREX, shall we 
//                restart at 1, or disable this counter?
//   IRQEN (rw)   Indicate interrupt condition when triggered?
//   TRIG  (ro)   
//
//---------------------------------------------------------------------------

module wb_timer #(
	parameter          clk_freq = 50000000
) (
	input              clk,
	input              reset,
	// Wishbone interface
	input              wb_stb_i,
	input              wb_cyc_i,
	output             wb_ack_o,
	input              wb_we_i,
	input       [31:0] wb_adr_i,
	input        [3:0] wb_sel_i,
	input       [31:0] wb_dat_i,
	output reg  [31:0] wb_dat_o,
	//
	output       [7:0] intr
);

//---------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------

reg irqen0, irqen1, irqen2, irqen3, irqen4, irqen5, irqen6, irqen7;
reg trig0, trig1, trig2, trig3, trig4, trig5, trig6, trig7;
reg en0, en1, en2, en3, en4, en5, en6, en7;
reg ar0, ar1, ar2, ar3, ar4, ar5, ar6, ar7;

wire [31:0] tcr0 = { 28'b0, en0, ar0, irqen0, trig0 };
wire [31:0] tcr1 = { 28'b0, en1, ar1, irqen1, trig1 };
wire [31:0] tcr2 = { 28'b0, en2, ar2, irqen2, trig2 };
wire [31:0] tcr3 = { 28'b0, en3, ar3, irqen3, trig3 };
wire [31:0] tcr4 = { 28'b0, en4, ar4, irqen4, trig4 };
wire [31:0] tcr5 = { 28'b0, en5, ar5, irqen5, trig5 };
wire [31:0] tcr6 = { 28'b0, en5, ar6, irqen6, trig6 };
wire [31:0] tcr7 = { 28'b0, en7, ar7, irqen7, trig7 };

reg  [31:0] counter0;
reg  [31:0] counter1;
reg  [31:0] counter2;
reg  [31:0] counter3;
reg  [31:0] counter4;
reg  [31:0] counter5;
reg  [31:0] counter6;
reg  [31:0] counter7;

reg  [31:0] compare0;
reg  [31:0] compare1;
reg  [31:0] compare2;
reg  [31:0] compare3;
reg  [31:0] compare4;
reg  [31:0] compare5;
reg  [31:0] compare6;
reg  [31:0] compare7;

wire match0 = (counter0 == compare0);
wire match1 = (counter1 == compare1);
wire match2 = (counter2 == compare2);
wire match3 = (counter3 == compare3);
wire match4 = (counter4 == compare4);
wire match5 = (counter5 == compare5);
wire match6 = (counter6 == compare6);
wire match7 = (counter7 == compare7);

assign intr = { trig7, trig6, trig5, trig4, trig3, trig2, trig1, trig0 };

reg  ack;
assign wb_ack_o = wb_stb_i & wb_cyc_i & ack;

wire wb_rd = wb_stb_i & wb_cyc_i & ~wb_we_i;
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i;

always @(posedge clk)
begin
	if (reset) begin
		ack      <= 0;
		en0      <= 0;
		en1      <= 0;
		en2      <= 0;
		en3      <= 0;
		en4      <= 0;
		en5      <= 0;
		en6      <= 0;
		en7      <= 0;
		ar0      <= 0;
		ar1      <= 0;
		ar2      <= 0;
		ar3      <= 0;
		ar4      <= 0;
		ar5      <= 0;
		ar6      <= 0;
		ar7      <= 0;
		trig0    <= 0;
		trig1    <= 0;
		trig2    <= 0;
		trig3    <= 0;
		trig4    <= 0;
		trig5    <= 0;
		trig6    <= 0;
		trig7    <= 0;
		counter0 <= 0;
		counter1 <= 0;
		counter2 <= 0;
		counter3 <= 0;
		counter4 <= 0;
		counter5 <= 0;
		counter6 <= 0;
		counter7 <= 0;
		compare0 <= 32'hFFFFFFFF;
		compare1 <= 32'hFFFFFFFF;
		compare2 <= 32'hFFFFFFFF;
		compare3 <= 32'hFFFFFFFF;
		compare4 <= 32'hFFFFFFFF;
		compare5 <= 32'hFFFFFFFF;
		compare6 <= 32'hFFFFFFFF;
		compare7 <= 32'hFFFFFFFF;
	end else begin

		// Handle counter 0
		if ( en0 & ~match0) counter0 <= counter0 + 1;
		if ( en0 &  match0) trig0    <= 1;
		if ( ar0 &  match0) counter0 <= 1;
		if (~ar0 &  match0) en0      <= 0;

		// Handle counter 1
		if ( en1 & ~match1) counter1 <= counter1 + 1;
		if ( en1 &  match1) trig1    <= 1;
		if ( ar1 &  match1) counter1 <= 1;
		if (~ar1 &  match1) en1      <= 0;

		// Handle counter 2
		if ( en2 & ~match2) counter2 <= counter2 + 1;
		if ( en2 &  match2) trig2    <= 1;
		if ( ar2 &  match2) counter2 <= 1;
		if (~ar2 &  match2) en2      <= 0;

		// Handle counter 3
		if ( en3 & ~match3) counter3 <= counter3 + 1;
		if ( en3 &  match3) trig3    <= 1;
		if ( ar3 &  match3) counter3 <= 1;
		if (~ar3 &  match3) en3      <= 0;

		// Handle counter 4
		if ( en4 & ~match4) counter4 <= counter4 + 1;
		if ( en4 &  match4) trig4    <= 1;
		if ( ar4 &  match4) counter4 <= 1;
		if (~ar4 &  match4) en4      <= 0;

		// Handle counter 5
		if ( en5 & ~match5) counter5 <= counter5 + 1;
		if ( en5 &  match5) trig5    <= 1;
		if ( ar5 &  match5) counter5 <= 1;
		if (~ar5 &  match5) en5      <= 0;

		// Handle counter 6
		if ( en6 & ~match6) counter6 <= counter6 + 1;
		if ( en6 &  match6) trig6    <= 1;
		if ( ar6 &  match6) counter6 <= 1;
		if (~ar6 &  match6) en6      <= 0;

		// Handle counter 7
		if ( en7 & ~match7) counter7 <= counter7 + 1;
		if ( en7 &  match7) trig7    <= 1;
		if ( ar7 &  match7) counter7 <= 1;
		if (~ar7 &  match7) en7      <= 0;

		// Handle WISHBONE access
		ack    <= 0;

		if (wb_rd & ~ack) begin           // read cycle
			ack <= 1;

			case (wb_adr_i[7:0])
			'h00: wb_dat_o <= tcr0;
			'h04: wb_dat_o <= compare0;
			'h08: wb_dat_o <= counter0;
			'h0c: wb_dat_o <= tcr1;
			'h10: wb_dat_o <= compare1;
			'h14: wb_dat_o <= counter1;
			'h18: wb_dat_o <= tcr2;
			'h1c: wb_dat_o <= compare2;
			'h20: wb_dat_o <= counter2;
			'h24: wb_dat_o <= tcr3;
			'h28: wb_dat_o <= compare3;
			'h2c: wb_dat_o <= counter3;
			'h30: wb_dat_o <= tcr4;
			'h34: wb_dat_o <= compare4;
			'h38: wb_dat_o <= counter4;
			'h3c: wb_dat_o <= tcr5;
			'h40: wb_dat_o <= compare5;
			'h44: wb_dat_o <= counter5;
			'h48: wb_dat_o <= tcr5;
			'h4c: wb_dat_o <= compare6;
			'h50: wb_dat_o <= counter6;
			'h54: wb_dat_o <= tcr7;
			'h58: wb_dat_o <= compare7;
			'h5c: wb_dat_o <= counter7;
			default: wb_dat_o <= 32'b0;
			endcase
		end else if (wb_wr & ~ack ) begin // write cycle
			ack <= 1;

			case (wb_adr_i[7:0])
			'h00: begin
				trig0   <= 0;
				irqen0  <= wb_dat_i[1];
				ar0     <= wb_dat_i[2];
				en0     <= wb_dat_i[3];
			end
			'h04: compare0 <= wb_dat_i;
			'h08: counter0 <= wb_dat_i;
			'h0c: begin
				trig1   <= 0;
				irqen1  <= wb_dat_i[1];
				ar1     <= wb_dat_i[2];
				en1     <= wb_dat_i[3];
			end
			'h10: compare1 <= wb_dat_i;
			'h14: counter1 <= wb_dat_i;
			'h18: begin
				trig2   <= 0;
				irqen2  <= wb_dat_i[1];
				ar2     <= wb_dat_i[2];
				en2     <= wb_dat_i[3];
			end
			'h1c: compare2 <= wb_dat_i;
			'h20: counter2 <= wb_dat_i;
			'h24: begin
				trig3   <= 0;
				irqen3  <= wb_dat_i[1];
				ar3     <= wb_dat_i[2];
				en3     <= wb_dat_i[3];
			end
			'h28: compare3 <= wb_dat_i;
			'h2c: counter3 <= wb_dat_i;
			'h30: begin
				trig4   <= 0;
				irqen4  <= wb_dat_i[1];
				ar4     <= wb_dat_i[2];
				en4     <= wb_dat_i[3];
			end
			'h34: compare4 <= wb_dat_i;
			'h38: counter4 <= wb_dat_i;
			'h3c: begin
				trig5   <= 0;
				irqen5  <= wb_dat_i[1];
				ar5     <= wb_dat_i[2];
				en5     <= wb_dat_i[3];
			end
			'h40: compare5 <= wb_dat_i;
			'h44: counter5 <= wb_dat_i;
			'h48: begin
				trig6   <= 0;
				irqen6  <= wb_dat_i[1];
				ar6     <= wb_dat_i[2];
				en6     <= wb_dat_i[3];
			end
			'h4c: compare6 <= wb_dat_i;
			'h50: counter6 <= wb_dat_i;
			'h54: begin
				trig7   <= 0;
				irqen7  <= wb_dat_i[1];
				ar7     <= wb_dat_i[2];
				en7     <= wb_dat_i[3];
			end
			'h58: compare7 <= wb_dat_i;
			'h5C: counter7 <= wb_dat_i;
			endcase
		end
	end
end


endmodule
