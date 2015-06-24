`timescale 1ns / 1ps

module antibounce (
	 input clk,
    input control,
    output reg clean
    );
	 
	 reg [7:0]r;
	 
	 initial
		begin
			clean=0;
		end
	 
	 always @(posedge clk)
		begin
			r[7:0]<={r[6:0],control};
			if(r[7:0]==8'b00000000) clean<=1'b0;
			else
				begin
					if(r[7:0]==8'b11111111) clean<=1'b1;
					else clean<=clean;
				end
		end
					
endmodule
