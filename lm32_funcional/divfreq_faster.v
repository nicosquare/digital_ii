`timescale 1ns / 1ps

module divfreq_faster(	
	input clk,
	output reg freq
    );
	 
	 integer cont;
	 parameter lim=1200000;
	 
	 initial
		begin
			cont=0;
			freq = 0;
		end
	 
	 always @(posedge clk)
		begin
			if(cont<lim) cont=cont+1;
			else
				begin
					cont=0;
					freq=~freq;
				end
		end

endmodule
