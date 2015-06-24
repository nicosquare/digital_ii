`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
module divisor_frecuencia_general(
		input clk, 
		input [25:0]lim, 
		output reg freq
    );
	 
	 integer cont;
	 
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
