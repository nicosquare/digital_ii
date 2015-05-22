--   ==================================================================
--   >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
--   ------------------------------------------------------------------
--   Copyright (c) 2013 by Lattice Semiconductor Corporation
--   ALL RIGHTS RESERVED 
--   ------------------------------------------------------------------
--
--   Permission:
--
--      Lattice SG Pte. Ltd. grants permission to use this code
--      pursuant to the terms of the Lattice Reference Design License Agreement. 
--
--
--   Disclaimer:
--
--      This VHDL or Verilog source code is intended as a design reference
--      which illustrates how these types of functions can be implemented.
--      It is the user's responsibility to verify their design for
--      consistency and functionality through the use of formal
--      verification methods.  Lattice provides no warranty
--      regarding the use or functionality of this code.
--
--   --------------------------------------------------------------------
--
--                  Lattice SG Pte. Ltd.
--                  101 Thomson Road, United Square #07-02 
--                  Singapore 307591
--
--
--                  TEL: 1-800-Lattice (USA and Canada)
--                       +65-6631-2000 (Singapore)
--                       +1-503-268-8001 (other locations)
--
--                  web: http://www.latticesemi.com/
--                  email: techsupport@latticesemi.com
--
--   --------------------------------------------------------------------
--
-- --------------------------------------------------------------------
-- Code Revision History :
-- --------------------------------------------------------------------
-- Ver: | Author |Mod. Date |Changes Made:
-- V1.0 | J.D.   |01/28/09  |Ported design from LatticeMico32 wb_spi.v
--                          |Modified parameter values and bus widths
--                          |for use with 8 bit bus from Mico8
-- V1.1 | S.R    | 21/07/09 |Added the preserve attributeon used ports for 4KZE
--                          |timing simulation
-- V1.2 | Peter	 | 06/08/09 |Add VHDL version
-- V1.3 | H.C.   | 11/02/10 |Added the asynchronous reset signal to n_status
--                          |Removed (c_status = ST_IDLE) from the asynchronous 
--                          |reset for clock_cnt, and used (n_status = ST_IDLE) as
--                          |the synchronous reset for clock_cnt  
-- --------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
ENTITY spi IS
   GENERIC (
      SHIFT_DIRECTION                :  std_logic := '0';
      CLOCK_PHASE                    :  std_logic := '0';
      CLOCK_POLARITY                 :  std_logic := '0';
      CLOCK_SEL                      :  integer := 1;
      MASTER                         :  boolean := True;
      SLAVE_NUMBER                   :  integer := 1;
      DATA_LENGTH                    :  integer := 8;
      DELAY_TIME                     :  integer := 2;
      CLKCNT_WIDTH                   :  integer := 5;
      INTERVAL_LENGTH                :  integer := 2);
   PORT (
      SPI_ADR_I               : IN std_logic_vector(7 DOWNTO 0);
      SPI_DAT_I               : IN std_logic_vector(7 DOWNTO 0);
      SPI_WE_I                : IN std_logic;
      SPI_CYC_I               : IN std_logic;
      SPI_STB_I               : IN std_logic;
      SPI_SEL_I               : IN std_logic_vector(3 DOWNTO 0);
      SPI_CTI_I               : IN std_logic_vector(2 DOWNTO 0);
      SPI_BTE_I               : IN std_logic_vector(1 DOWNTO 0);
      SPI_LOCK_I              : IN std_logic;
      SPI_DAT_O               : OUT std_logic_vector(7 DOWNTO 0);
      SPI_ACK_O               : OUT std_logic;
      SPI_INT_O               : OUT std_logic;
      SPI_ERR_O               : OUT std_logic;
      SPI_RTY_O               : OUT std_logic;
      MISO_MASTER             : IN std_logic;
      MOSI_MASTER             : OUT std_logic;
      SS_N_MASTER             : OUT std_logic_vector(SLAVE_NUMBER - 1 DOWNTO 0);
      --SS_N_MASTER             : OUT std_logic;
       --
      SCLK_MASTER             : OUT std_logic;
      MISO_SLAVE              : OUT std_logic;
      MOSI_SLAVE              : IN std_logic;
      SS_N_SLAVE              : IN std_logic;
      SCLK_SLAVE              : IN std_logic;
      CLK_I                   : IN std_logic;
      RST_I                   : IN std_logic);
Attribute Syn_keep :boolean;
Attribute Syn_keep of SPI_SEL_I,SPI_CTI_I,SPI_BTE_I,SPI_LOCK_I,MOSI_SLAVE,SS_N_SLAVE,SCLK_SLAVE : signal is true;
Attribute opt :string;
Attribute opt of SPI_SEL_I,SPI_CTI_I,SPI_BTE_I,SPI_LOCK_I,MOSI_SLAVE,SS_N_SLAVE,SCLK_SLAVE : signal is "keep";
END spi;

ARCHITECTURE translated OF spi IS
   CONSTANT  UDLY                  :  integer := 1;
   CONSTANT  ST_IDLE               :  std_logic_vector(2 DOWNTO 0) := "000";
   CONSTANT  ST_LOAD               :  std_logic_vector(2 DOWNTO 0) := "001";
   CONSTANT  ST_WAIT               :  std_logic_vector(2 DOWNTO 0) := "010";
   CONSTANT  ST_TRANS              :  std_logic_vector(2 DOWNTO 0) := "011";
   CONSTANT  ST_TURNAROUND         :  std_logic_vector(2 DOWNTO 0) := "100";
   CONSTANT  ST_INTERVAL           :  std_logic_vector(2 DOWNTO 0) := "101";
   SIGNAL dw00_cs                  :  std_logic;
   SIGNAL dw04_cs                  :  std_logic;
   SIGNAL dw08_cs                  :  std_logic;
   SIGNAL dw0c_cs                  :  std_logic;
   SIGNAL dw10_cs                  :  std_logic;
   SIGNAL reg_wr                   :  std_logic;
   SIGNAL reg_rd                   :  std_logic;
   SIGNAL read_wait_done           :  std_logic;
   SIGNAL latch_s_data             :  std_logic_vector(7 DOWNTO 0);
   SIGNAL reg_rxdata               :  std_logic_vector(DATA_LENGTH - 1 DOWNTO 0);
   SIGNAL reg_txdata               :  std_logic_vector(DATA_LENGTH - 1 DOWNTO 0);
   SIGNAL rx_shift_data            :  std_logic_vector(DATA_LENGTH - 1 DOWNTO 0);
   SIGNAL tx_shift_data            :  std_logic_vector(DATA_LENGTH - 1 DOWNTO 0);
   SIGNAL rx_latch_flag            :  std_logic;
   SIGNAL reg_control              :  std_logic_vector(7 DOWNTO 0);
   SIGNAL reg_iroe                 :  std_logic;
   SIGNAL reg_itoe                 :  std_logic;
   SIGNAL reg_itrdy                :  std_logic;
   SIGNAL reg_irrdy                :  std_logic;
   SIGNAL reg_ie                   :  std_logic;
   SIGNAL reg_sso                  :  std_logic;
   SIGNAL reg_status               :  std_logic_vector(7 DOWNTO 0);
   SIGNAL reg_toe                  :  std_logic;
   SIGNAL reg_roe                  :  std_logic;
   SIGNAL reg_trdy                 :  std_logic;
   SIGNAL reg_rrdy                 :  std_logic;
   SIGNAL reg_tmt                  :  std_logic;
   SIGNAL reg_e                    :  std_logic;
   SIGNAL reg_ssmask               :  std_logic_vector(SLAVE_NUMBER - 1 DOWNTO 0);
   --SIGNAL reg_ssmask               :  std_logic;
   SIGNAL clock_cnt                :  integer range 0 to (2**CLKCNT_WIDTH - 1);
   SIGNAL data_cnt                 :  integer range 0 to 63;--(5 DOWNTO 0);
   SIGNAL pending_data             :  std_logic;
   SIGNAL c_status                 :  std_logic_vector(2 DOWNTO 0);
   SIGNAL n_status                 :  std_logic_vector(2 DOWNTO 0);
--
   SIGNAL ACTUAL_MAX               :  integer range 0 to 63; --std_logic_vector(5 DOWNTO 0);
   SIGNAL wait_one_tick_done       :  std_logic;
--
   SIGNAL tx_done                  :  std_logic;
   SIGNAL rx_done                  :  std_logic;
   SIGNAL rx_done_flip1            :  std_logic;
   SIGNAL rx_done_flip2            :  std_logic;
   SIGNAL rx_data_cnt              :  std_logic_vector(5 DOWNTO 0):="000000";
   SIGNAL tx_data_cnt              :  integer range  0 to 63 :=0;
	 SIGNAL SPI_ACK_O_temp				 		:	std_logic;	
	 SIGNAL SCLK_MASTER_temp								: std_logic;		

BEGIN
   --
   	SPI_ACK_O <=SPI_ACK_O_temp;
   	SPI_ERR_O 			<= '0';
   	SPI_RTY_O 			<= '0';
   	SCLK_MASTER  <= SCLK_MASTER_temp;
  --
--
   	PROCESS(CLK_I,RST_I)
   	BEGIN
      	IF (RST_I = '1') THEN
         	dw00_cs <= '0';
         	dw04_cs <= '0';
         	dw08_cs <= '0';
         	dw0c_cs <= '0';
         	dw10_cs <= '0';
        ELSIF(CLK_I'EVENT AND CLK_I = '1') THEN
						case(SPI_ADR_I) is
         		when x"00" =>
         						dw00_cs <= '1';
         						dw04_cs <= '0';
         						dw08_cs <= '0';
         						dw0c_cs <= '0';
         						dw10_cs <= '0';
         		when x"04" =>
         						dw00_cs <= '0';
         						dw04_cs <= '1';
         						dw08_cs <= '0';
         						dw0c_cs <= '0';
         						dw10_cs <= '0';
         		when x"08" =>
         						dw00_cs <= '0';
         						dw04_cs <= '0';
         						dw08_cs <= '1';
         						dw0c_cs <= '0';
         						dw10_cs <= '0';
         		when x"0c" =>
         						dw00_cs <= '0';
         						dw04_cs <= '0';
         						dw08_cs <= '0';
         						dw0c_cs <= '1';
         						dw10_cs <= '0';
         		when x"10" =>
         						dw00_cs <= '0';
         						dw04_cs <= '0';
         						dw08_cs <= '0';
         						dw0c_cs <= '0';
         						dw10_cs <= '1';
         		when others =>
         			dw00_cs <= '0';
         			dw04_cs <= '0';
         			dw08_cs <= '0';
         			dw0c_cs <= '0';
         			dw10_cs <= '0';
         		end case;
      	END IF;
   	END PROCESS;
--
   	PROCESS(CLK_I,RST_I)
   	BEGIN
       	IF (RST_I = '1') THEN
         	reg_wr <= '0' ;
         	reg_rd <= '0' ;
       	ELSIF(CLK_I'EVENT AND CLK_I = '1')THEN
         	reg_wr <= (SPI_WE_I AND SPI_STB_I) AND SPI_CYC_I;-- AFTER to_time(UDLY);
         	reg_rd <= (NOT SPI_WE_I AND SPI_STB_I) AND SPI_CYC_I;-- AFTER to_time(UDLY);
       	END IF;
   	END PROCESS;
--
   	PROCESS(CLK_I,RST_I)
   	BEGIN
       	IF (RST_I = '1') THEN
         	latch_s_data <= "00000000";--AFTER to_time(UDLY);
       	ELSIF(CLK_I'EVENT AND CLK_I = '1') THEN
         	latch_s_data <= SPI_DAT_I;-- AFTER to_time(UDLY);
      	END IF;
   	END PROCESS;
--
   	PROCESS(CLK_I,RST_I)
   	BEGIN
       	IF (RST_I = '1') THEN
         	reg_rxdata <= (OTHERS => '0');
      	ELSIF(CLK_I'EVENT AND CLK_I = '1') THEN
         		IF (rx_latch_flag = '1') THEN
            		reg_rxdata <= rx_shift_data;-- AFTER to_time(UDLY);
         		END IF;
      	END IF;
   	END PROCESS;
--
   	PROCESS(CLK_I,RST_I)
   	BEGIN
       	IF (RST_I = '1') THEN
         		reg_txdata <= (OTHERS => '0');
       	ELSIF(CLK_I'EVENT AND CLK_I = '1')Then
         		IF (((reg_wr AND dw04_cs) AND reg_trdy) = '1') THEN
            	reg_txdata <= latch_s_data;-- AFTER to_time(UDLY);
         		END IF;
      	END IF;
   	END PROCESS;
   	reg_e <= reg_toe OR reg_roe ;
   	reg_status <= reg_e & reg_rrdy & reg_trdy & reg_tmt & reg_toe & reg_roe & "00" ;
--
   	PROCESS(CLK_I,RST_I)
   	BEGIN
       	IF (RST_I = '1') THEN
         		reg_iroe <= '0';
         		reg_itoe <= '0';
         		reg_itrdy <= '0';
         		reg_irrdy <= '0';
         		reg_ie <= '0';
         		reg_sso <= '0';
      	ELSIF(CLK_I'EVENT AND CLK_I = '1')THEN
         	IF ((reg_wr AND dw0c_cs) = '1') THEN
            reg_iroe <= latch_s_data(0);
            reg_itoe <= latch_s_data(1);
            reg_itrdy <= latch_s_data(3);
            reg_irrdy <= latch_s_data(4);
            reg_ie <= latch_s_data(5);
            reg_sso <= latch_s_data(7);
         	END IF;
      	END IF;
   	END PROCESS;
   	--
   	SPI_INT_O <= (reg_ie AND ((reg_iroe AND reg_roe) OR (reg_itoe AND reg_toe))) OR (reg_itrdy AND reg_trdy) OR (reg_irrdy AND reg_rrdy) ;
--
   	PROCESS(RST_I,CLK_I)
   	BEGIN
      	IF (RST_I = '1') THEN
         		SPI_ACK_O_temp <= '0';
      	ELSIF(CLK_I'EVENT AND CLK_I = '1')THEN
         		IF (SPI_ACK_O_temp = '1') THEN
            	SPI_ACK_O_temp <= '0';
         		ELSIF (((SPI_STB_I AND SPI_CYC_I) AND (SPI_WE_I OR read_wait_done)) = '1') THEN
               		SPI_ACK_O_temp <= '1';
         		END IF;
      	END IF;
   	END PROCESS;
--
   PROCESS(RST_I,CLK_I)
   BEGIN
       	IF (RST_I = '1') THEN
         	read_wait_done <= '0';
      	ELSIF(CLK_I'EVENT AND CLK_I = '1') THEN
         		IF (SPI_ACK_O_temp = '1') THEN
            	read_wait_done <= '0';
         		ELSIF (((SPI_STB_I AND SPI_CYC_I) AND NOT SPI_WE_I) = '1') THEN
              		 	read_wait_done <= '1';            		
         		END IF;
      	END IF;
   END PROCESS;

master1:IF (MASTER = true) GENERATE
		reg_control <= reg_sso & '0' & reg_ie & reg_irrdy & reg_itrdy & '0' & reg_itoe & reg_iroe ;
		PROCESS(CLK_I,RST_I)
		BEGIN
	  		if( RST_I ='1') THEN
	  				pending_data <='0';
	  		elsif(clk_i'event and clk_i ='1' ) then
	  	 			if((reg_wr and dw04_cs ) ='1') then
	  	 		 			pending_data <='1';
	  	 			elsif(c_status = ST_LOAD) then
	  	  	 			pending_data  <= '0';
	  	 			end if;
	  		end if;
		END PROCESS;
---
		PROCESS(CLK_I,RST_I)
		BEGIN
	  		if( RST_I = '1') Then
	  				SPI_DAT_O <= x"00";
	  		elsif ( clk_i'event and clk_i ='1') Then
	  				if( reg_rd = '1') then
	  			 				--SPI_DAT_O <= "00000000";
	  						if( dw00_cs ='1') then
	  		  					SPI_DAT_O <= reg_rxdata;
	  						elsif(dw04_cs ='1') then
	  		  					SPI_DAT_O <= reg_txdata;
	  						elsif (dw08_cs ='1') then
	  								SPI_DAT_O <= reg_status;
	  						elsif(dw0c_cs ='1')	then
	  			 					SPI_DAT_O <= reg_control;
	  						elsif(dw10_cs = '1') then
	  			 					SPI_DAT_O(SLAVE_NUMBER - 1 DOWNTO 0) <= reg_ssmask;
	  						else
	  		  					SPI_DAT_O <= x"00";
	  						end if;
	    			end if;
	  		end if;
		end PROCESS;
--
		Process(CLK_I,RST_I)
		BEGIN
	  		if( RST_I ='1') Then
	  				reg_ssmask <= (OTHERS => '0');
	  		elsif(CLK_I' event and CLK_I = '1') Then
	  				if(( reg_wr and dw10_cs )='1') then
	  		 			reg_ssmask <=latch_s_data(SLAVE_NUMBER - 1 DOWNTO 0);
	    			end if;
	  		end if;
		end PROCESS;
--
		PROCESS(CLK_I,RST_I)
		begin
	  		if( RST_I = '1') then
	  				SCLK_MASTER_temp <= CLOCK_POLARITY;
	  		elsif ( CLK_I'EVENT and CLK_I = '1') Then
	  				if(( c_status = ST_TRANS ) and ( clock_cnt = CLOCK_SEL )) then
	  			  		SCLK_MASTER_temp <= not SCLK_MASTER_temp;
	  				end if;
	 			end if;
		END PROCESS;
--
		PROCESS(CLK_I,RST_I)
		BEGIN
	  		IF(RST_I ='1') THEN
	  				SS_N_MASTER <= (OTHERS => '1');
	   		ELSIF(CLK_I'EVENT and CLK_I ='1') Then
	   	 			IF( reg_sso = '1') then
	   	 	 				--SS_N_MASTER <= (Not reg_ssmask(7)) &(Not reg_ssmask(6)) & (Not reg_ssmask(5)) &(Not reg_ssmask(4))&(Not reg_ssmask(3)) &(Not reg_ssmask(2))&(Not reg_ssmask(1)) &(Not reg_ssmask(0));
	   	 						SS_N_MASTER <= (Not reg_ssmask);
	   	 			elsif((c_status = ST_TRANS) or (c_status = ST_WAIT) or (c_status = ST_TURNAROUND)) then
	   	   				--SS_N_MASTER <=(Not reg_ssmask(7)) &(Not reg_ssmask(6)) & (Not reg_ssmask(5)) &(Not reg_ssmask(4))&(Not reg_ssmask(3)) &(Not reg_ssmask(2))&(Not reg_ssmask(1)) &(Not reg_ssmask(0));
	   	 						SS_N_MASTER <= (Not reg_ssmask);
	   	 			else
	   	 	 				SS_N_MASTER <= (OTHERS => '1');
	   				END IF;
	  		END IF;
		END PROCESS;
--
		PROCESS(RST_I, CLK_I)
		begin
	  		if( rst_i = '1') then
	     			rx_shift_data <= x"00";
	  		elsif( CLK_I'EVENT and CLK_I = '1') Then
	  				if(( clock_cnt = CLOCK_SEL ) and (CLOCK_PHASE = SCLK_MASTER_temp ) and (c_status = ST_TRANS)) then
	  					if( SHIFT_DIRECTION = '1' ) then
	  		 					rx_shift_data <=  MISO_MASTER & rx_shift_data(7)& rx_shift_data(6)& rx_shift_data(5)& rx_shift_data(4)& rx_shift_data(3)& rx_shift_data(2)& rx_shift_data(1);
	  					else
	  		 					rx_shift_data <=  rx_shift_data(6)& rx_shift_data(5)& rx_shift_data(4)& rx_shift_data(3)& rx_shift_data(2)& rx_shift_data(1)& rx_shift_data(0)&MISO_MASTER;
	  					end if;
	  				end if;
	  		end if;
		end process;
--
		PROCESS(RST_I,CLK_I)
		begin
				if( rst_i = '1') then
						rx_latch_flag <= '0';
			  elsif ( CLK_I'event and clk_i = '1') then
			  		if(( c_status = ST_TRANS ) and (n_status /= ST_TRANS)) then
			  				rx_latch_flag <= '1';
			    	elsif( rx_latch_flag = '1') then
			    			rx_latch_flag <= '0';
			    	end if;
			  end if;
		end process;
--
		process ( clk_i, rst_i)
		begin
				if( rst_i ='1') then
			 			clock_cnt <= 0;
				elsif( clk_i'event and clk_i ='1') then
						if(( clock_cnt = CLOCK_SEL ) or n_status = ST_IDLE) then
							clock_cnt <=0;
						else
			  			clock_cnt <= clock_cnt + 1;
						end if;
				end if;
		end process;
				
--
		process( clk_i, rst_i)
		begin
			  if( RST_I = '1') then
			  	 c_status <= ST_IDLE;
			  elsif ( CLK_I' event  and CLK_I = '1') then
			     c_status <= n_status;
			  end if;
		end process;
--
		ACTUAL_MAX <= (DATA_LENGTH - 1) when (CLOCK_POLARITY = CLOCK_PHASE) else (DATA_LENGTH);
--
		Process (clk_i,rst_i)
		begin
			  if( rst_i = '1') then
			  	 n_status <= ST_IDLE;
			  elsif(clk_i' event and clk_i = '0') then
			  		case(c_status)       is
			  		when ST_IDLE =>
			  					if( pending_data ='1') then
			  						n_status <= ST_LOAD;
			  					else
			  					 n_status <= ST_IDLE;
			  					end if;
			   		when ST_LOAD =>
			            if(DELAY_TIME = 0) then
			            	n_status <= ST_TRANS;
			            else
			             n_status <= ST_WAIT;
			            end if;
			  		when ST_WAIT =>
			             if ((clock_cnt = CLOCK_SEL ) and ( data_cnt = DELAY_TIME -1)) then
			               	n_status <= ST_TRANS;
			             else
			            		 n_status <= ST_WAIT;
			            end if;
			  		when ST_TRANS =>
			             if((clock_cnt = CLOCK_SEL )and (data_cnt = ACTUAL_MAX ) and (SCLK_MASTER_temp /= CLOCK_POLARITY)) then
			             			n_status <= ST_TURNAROUND;
		               else
		                  	n_status <= ST_TRANS;
		               end if ;
		    		when ST_TURNAROUND =>
		             if (clock_cnt = CLOCK_SEL) then
		                 if (INTERVAL_LENGTH = 2) then
		                    n_status <= ST_INTERVAL;
		                 else
		                    n_status <= ST_IDLE;
		                 end if;
		             end if;
		    		when ST_INTERVAL =>
		    				if ((clock_cnt = CLOCK_SEL) and (data_cnt=INTERVAL_LENGTH)) then
		               	n_status <= ST_IDLE;
		            else
		                n_status <= ST_INTERVAL;
		            end if;
		   			when others => n_status <= ST_IDLE;
			 			end case;
			  end if;
		end process;
--
					process( clk_i, rst_i)
					begin
							if( rst_i ='1') then
								data_cnt <= 0;
						  elsif (clk_i'event and clk_i ='1') then
						  	if((c_status = ST_WAIT)and(clock_cnt = CLOCK_SEL) and (data_cnt = DELAY_TIME -1)) then
						  		data_cnt <=0;
						  	elsif((c_status = ST_TRANS) and (clock_cnt = CLOCK_SEL) and (data_cnt = ACTUAL_MAX) and (CLOCK_POLARITY /= SCLK_MASTER_temp)) then
						  	  data_cnt <= 0;
						  	elsif((c_status = ST_INTERVAL)and(clock_cnt = CLOCK_SEL) and (data_cnt = INTERVAL_LENGTH)) then
						  		data_cnt <=0;
						  	elsif(((c_status =ST_WAIT )and (clock_cnt = CLOCK_SEL )) or ((c_status =ST_TRANS)and (clock_cnt = CLOCK_SEL ) and (CLOCK_PHASE /= SCLK_MASTER_temp)) or ((c_status =ST_INTERVAL )and (clock_cnt = CLOCK_SEL ))) then
						  	   data_cnt <= data_cnt + 1;
						  	end if;
						 end if;
					end process;
--
					process(clk_i,rst_i)
					begin
							if(rst_i ='1') then
								wait_one_tick_done <= '0';
							elsif(clk_i'event and clk_i ='1') then
								if( CLOCK_PHASE = CLOCK_POLARITY) then
									wait_one_tick_done <='1';
								elsif(( c_status =ST_TRANS )and (clock_cnt = CLOCK_SEL) and (data_cnt =1)) then
							    wait_one_tick_done <='1';
							  elsif (data_cnt = 0) then
							  	wait_one_tick_done <= '0';
							  end if;
							end if;
					end process;
--
					PROCESS(CLK_I,RST_I)
					begin
							if(RST_I ='1') then
								   MOSI_MASTER <= '0';
								   tx_shift_data <= x"00";
						  elsif(CLK_I'EVENT and CLK_I ='1') then
						  	if(((c_status = ST_LOAD) and (n_status = ST_TRANS)) or
									 ((c_status = ST_WAIT) and (n_status = ST_TRANS))) then
									 		if( SHIFT_DIRECTION = '1') then
									 			 MOSI_MASTER 		<= reg_txdata(0);
									 			 tx_shift_data 	<=('0'&reg_txdata(DATA_LENGTH-1 downto 1));
									 		else
									 		   MOSI_MASTER <= reg_txdata(DATA_LENGTH -1);
									 		   tx_shift_data <=reg_txdata(DATA_LENGTH-2 downto 0)&'0';
									 		end if;
							  elsif((c_status = ST_TRANS ) and (clock_cnt = CLOCK_SEL) and( (CLOCK_PHASE = '1') xor (SCLK_MASTER_temp ='1'))) then
											if( SHIFT_DIRECTION = '1') then
									 			 MOSI_MASTER 		<= tx_shift_data(0);
									 			 tx_shift_data 	<=('0'&tx_shift_data(DATA_LENGTH-1 downto 1));
									 		else
									 		   MOSI_MASTER <= tx_shift_data(DATA_LENGTH -1);
									 		   tx_shift_data <=(tx_shift_data(DATA_LENGTH-2 downto 0)&'0');
									 		end if;
								end if;
							end if;
					end process;
--
					process(CLK_I,RST_I)
					begin
						  if(RST_I = '1') then
						  	reg_trdy <= '1';
						  elsif(CLK_I'EVENT and CLK_I = '1') then
						  	if((c_status/=ST_TRANS) and (n_status =ST_TRANS)) then
						  	  reg_trdy	<= '1';
						  	elsif(( reg_wr and dw04_cs and SPI_ACK_O_temp )='1')then
						  		reg_trdy  <= '0';
						    end if;
						  end if;
					end process;
--
					process(CLK_I,RST_I)
					begin
							if( RST_I ='1') then
								 reg_toe <='0';
							elsif(CLK_I'EVENT and CLK_I ='1') then
								if(((not reg_trdy) and reg_wr and dw04_cs and SPI_ACK_O_temp )='1')then
									reg_toe <= '1';
								elsif((reg_wr and dw08_cs and SPI_ACK_O_temp )= '1')then
									reg_toe <= '0';
								end if;
							end if;
					end process;
--
					process(CLK_I,RST_I)
					begin
							if(RST_I = '1') then
								reg_rrdy <= '0';
								reg_roe <='0';
							elsif (CLK_I'event and CLK_I ='1') then
								if((c_status= ST_TURNAROUND) and (clock_cnt = CLOCK_SEL)) then
									if(reg_rrdy = '1') then
										reg_roe <= '1';
									else
									 reg_rrdy <='1';
									end if;
								elsif((reg_rd and dw00_cs and SPI_ACK_O_temp)='1')then
									reg_rrdy <='0';
									reg_roe <= '0';
								end if;
							end if;
					end process;
--
					process(CLK_I,RST_I)
					begin
						  if(RST_I = '1') then
						  	reg_tmt <='1';
						  elsif(clk_i'event and clk_i ='1')then
						   	if((c_status/=ST_IDLE) or (pending_data='1')) then
						   	 	reg_tmt <='0';
						   	else
						   	  reg_tmt <= '1';
						   	end if;
						  end if;
					end process;
--
END GENERATE master1;
--
master0: IF (MASTER = false) GENERATE
					process(CLK_I,RST_I)
					BEGIN
						  if( RST_I = '1') Then
						  	SPI_DAT_O <= x"00";
						  elsif ( clk_i'event and clk_i ='1') Then
						  	if( reg_rd = '1' ) then
						  		if( dw00_cs= '1' ) then
						  		  SPI_DAT_O <= reg_rxdata;
						  		elsif(dw04_cs= '1') then
						  		  SPI_DAT_O <= reg_txdata;
						  		elsif (dw08_cs= '1') then
						  			SPI_DAT_O <= reg_status;
						  		elsif(dw0c_cs= '1')	then
						  			 SPI_DAT_O <= reg_control;
						  		else
						  		  	SPI_DAT_O <= x"00";
						  		end if;
						    end if;
						  end if;
					end PROCESS;
--
CLOCK_PHASE_equal0: if(CLOCK_PHASE ='0') GENERATE
					process(SCLK_SLAVE,RST_I)
					begin
							if( RST_I = '1') then
								rx_shift_data  <= x"00";
							elsif(SCLK_SLAVE'EVENT and SCLK_SLAVE='1') then
								if(( not SS_N_SLAVE) = '1')	then
									if(SHIFT_DIRECTION ='1')then
											rx_shift_data <= MOSI_SLAVE & rx_shift_data(DATA_LENGTH-1 downto 1);
					        else
					            rx_shift_data <= rx_shift_data(DATA_LENGTH-2 downto 0) & MOSI_SLAVE;
					        end if;
					      end if;
					    end if;
					end process;
--
					process(SCLK_SLAVE,RST_I)
					begin
						  if( RST_I ='1') then
						  	rx_data_cnt     <= "000000";
						  elsif(SCLK_SLAVE'EVENT and SCLK_SLAVE ='1') then
						  	if( rx_data_cnt = DATA_LENGTH -1) then
						  		rx_data_cnt <= "000000";
						    elsif(( not SS_N_SLAVE )='1') then
						    	rx_data_cnt <= rx_data_cnt + 1;
						    end if;
						  end if;
					end process;
--
					process( SCLK_SLAVE,RST_I)
					begin
							if( RST_I = '1') then
								rx_done		<='0';
						 elsif(SCLK_SLAVE'EVENT and SCLK_SLAVE = '1') then
						 	 if(rx_data_cnt = DATA_LENGTH - 1) then
						 	 	 rx_done			<= '1';
						 	 else
						 	   rx_done			<= '0';
						 	 end if;
						 end if;
					end process;
end generate CLOCK_PHASE_equal0;
---
CLOCK_PHASE_equal1: if(CLOCK_PHASE ='1') Generate
					process( SCLK_SLAVE,RST_I)
					begin
							if(RST_I ='1') then
								rx_shift_data <= "00000000";
						 	elsif(SCLK_SLAVE'EVENT and SCLK_SLAVE ='1') then
					       if(( not SS_N_SLAVE )='1') then
					       	 if(SHIFT_DIRECTION = '1') then
					       	 	 rx_shift_data <=MOSI_SLAVE & rx_shift_data(DATA_LENGTH-1 downto 1);
					       	 else
					       	   rx_shift_data  <= rx_shift_data(DATA_LENGTH-2 downto 0) & MOSI_SLAVE;
					       	 end if;
					       end if;
					    end if;
					end process;
					---
					process(SCLK_SLAVE,RST_I)
					begin
							if( RST_I = '1') then
								rx_data_cnt	<= "000000";
							elsif(SCLK_SLAVE'EVENT and SCLK_SLAVE ='1' ) then
								if( rx_data_cnt = DATA_LENGTH -1) then
									rx_data_cnt <= "000000";
							  elsif(( not SS_N_SLAVE ) = '1') then
							     rx_data_cnt <= rx_data_cnt + 1;
							  end if;
						 end if;
					end process;
---
				 process(SCLK_SLAVE, RST_I)
				 begin
				 		if( RST_I = '1') then
				 			rx_done <= '0';
				 	  elsif(SCLK_SLAVE'EVENT and SCLK_SLAVE ='1') then
				 	  	if( rx_data_cnt = DATA_LENGTH -1) then
				 	  		rx_done <= '1';
				 	  	else
				 	  	 rx_done <= '0';
				 	    end if;
				 	  end if;
				 end process;
end generate CLOCK_PHASE_equal1;
--
			process(CLK_I,RST_I)
			begin
					if(RST_I = '1') then
						 rx_done_flip1                <= '0';
			 			 rx_done_flip2                <= '0';
			 		elsif(CLK_I'event and CLK_I = '1') then
			 			  rx_done_flip1                <= rx_done;
							rx_done_flip2                <= rx_done_flip1;
					end if;
			end process;
			--
			process(CLK_I,RST_I)
			begin
					if(RST_I = '1') then
						 rx_latch_flag                <= '0';
			 		elsif(CLK_I'event and CLK_I = '1') then
			 			if( (rx_done_flip1 = '1') and ((not( rx_done_flip2))= '1')) then
			 			  rx_latch_flag                <= '1';
			 			else
			 			  rx_latch_flag <= '0';
			 			end if;
					end if;
			end process;
			--
			process(CLK_I,RST_I)
			begin
					if(RST_I = '1') then
						reg_rrdy			<= '0';
					elsif(CLK_I'EVENT and CLK_I ='1') then
						if( (rx_done_flip1 = '1') and ((not (rx_done_flip2))= '1'))	then
							reg_rrdy				<= '1';
						elsif(( reg_rd and dw00_cs and SPI_ACK_O_temp) = '1') then
							reg_rrdy	<= '0';
						end if;
					end if;
			end process;
			--
			process(CLK_I,RST_I)
			begin
			    if( RST_I = '1') then
			    	reg_roe <= '0';
			    elsif(CLK_I'event and CLK_I = '1') then
			    	if( (rx_done_flip1 ='1') and ((not (rx_done_flip2))='1') and (reg_rrdy ='1')) then
			    		reg_roe <= '1';
			      elsif (( reg_wr and dw08_cs and SPI_ACK_O_temp)='1') then
			      	reg_roe <= '0';
			      end if;
			    end if;
			end process;
--------------
----------------
CLOCK_PHASE_CLOCK0_PARITY :if( CLOCK_PHASE = '0') GENERATE
			CLOCK_POLARITY1: if( CLOCK_POLARITY = '1') GENERATE
											process( SCLK_SLAVE, RST_I )
											begin
													if(RST_I = '1') then
														MISO_SLAVE <= '0';
													elsif( SCLK_SLAVE'EVENT and SCLK_SLAVE = '0') then
														if( SHIFT_DIRECTION ='1' ) then
																MISO_SLAVE <=  reg_txdata(tx_data_cnt);
														else
																MISO_SLAVE	<=	reg_txdata( DATA_LENGTH- tx_data_cnt -1);
														end if;
													end if;
											end process;
											end generate CLOCK_POLARITY1;
--
			CLOCK_POLARITY0: if( CLOCK_POLARITY = '0') GENERATE
											MISO_SLAVE <= reg_txdata(tx_data_cnt) when (SHIFT_DIRECTION ='1') else reg_txdata( DATA_LENGTH- tx_data_cnt -1);
--
			end GENERATE CLOCK_POLARITY0;

			process(SCLK_SLAVE,RST_I)
			begin
			    if( RST_I = '1') then
			    	tx_data_cnt <= 0;
			    elsif(SCLK_SLAVE'EVENT and SCLK_SLAVE ='0') then
			    		if( tx_data_cnt = DATA_LENGTH -1 ) then
			    			tx_data_cnt <= 0;
			    		elsif(( not(SS_N_SLAVE)) = '1') then
			    			tx_data_cnt <= tx_data_cnt + 1;
			      	end if;
			    end if;
			end process;
------
			process(SCLK_SLAVE,RST_I)
			begin
			    if( RST_I = '1') then
			    	tx_done <= '0';
			    elsif(SCLK_SLAVE'EVENT and SCLK_SLAVE ='0') then
			    		if( tx_data_cnt = DATA_LENGTH -1 ) then
			    		 		tx_done     <='1';
			      	else
			    				tx_done <= '0';
			      	end if;
			    end if;
			end process;
end GENERATE CLOCK_PHASE_CLOCK0_PARITY;
----
CLOKE_PHASE_CLOCK1_PARITY : if( CLOCK_PHASE = '1') generate
			CLOCK_POLARITY11: if( CLOCK_POLARITY = '1') GENERATE
							MISO_SLAVE <= reg_txdata(tx_data_cnt) when (SHIFT_DIRECTION = '1') else reg_txdata( DATA_LENGTH- tx_data_cnt -1);
			end generate CLOCK_POLARITY11;
--
			CLOCK_POLARITY01: if( CLOCK_POLARITY = '0') GENERATE
--
			process( SCLK_SLAVE, RST_I )
			begin
					if(RST_I = '1') then
						MISO_SLAVE <= '0';
					elsif( SCLK_SLAVE'EVENT and SCLK_SLAVE = '1') then
							if( SHIFT_DIRECTION ='1' ) then
									MISO_SLAVE <=  reg_txdata(tx_data_cnt);
							else
									MISO_SLAVE	<=	reg_txdata( DATA_LENGTH- tx_data_cnt -1);
							end if;
					end if;
			end process;
			end generate CLOCK_POLARITY01;
--
			process(SCLK_SLAVE,RST_I)
			begin
			    if( RST_I = '1') then
			    	tx_data_cnt <= 0;
			    elsif(SCLK_SLAVE'EVENT and SCLK_SLAVE ='1') then
			    	if( tx_data_cnt = DATA_LENGTH -1 ) then
			    		tx_data_cnt <= 0;
			    	elsif(( not(SS_N_SLAVE))='1') then
			    		tx_data_cnt <= tx_data_cnt + 1;
			      end if;
			    end if;
			end process;
			--
			process(SCLK_SLAVE,RST_I)
			begin
			    if( RST_I = '1') then
			    	tx_done <= '0';
			    elsif(SCLK_SLAVE'EVENT and SCLK_SLAVE ='1') then
			    	if( tx_data_cnt = DATA_LENGTH -1 ) then
			    	 tx_done     <='1';
			      else
			    			tx_done <= '0';
			      end if;
			    end if;
			end process;
end generate CLOKE_PHASE_CLOCK1_PARITY;
--
			process( clk_I, RST_I)
			begin
					if( RST_I = '1') then
						reg_trdy <= '1' ;
					elsif( CLK_I'event and CLK_I = '1') then
						if(( reg_wr and dw04_cs and SPI_ACK_O_temp ) ='1') then
							reg_trdy <= '0';
						elsif( tx_done ='1' ) then
							reg_trdy <= '1';
						end if;
					end if;
			end process;
			--
			process( CLK_I,RST_I)
			begin
					if(RST_I = '1') then
						reg_tmt <= '1';
					elsif( CLK_I'EVENT and CLK_I ='1') then
						if(( reg_wr and dw04_cs and SPI_ACK_O_temp ) ='1') then
						    reg_tmt <= '0';
					  elsif( tx_done = '1' ) then
					     reg_tmt <= '1';
					  end if;
					end if;
			end process;
--
			process(CLK_I,RST_I)
			begin
				  if(RST_I = '1') then
				  	reg_toe <= '0';
				  elsif( clk_I'EVENT and clk_I ='1') then
				  	if(( not(reg_trdy) and reg_wr and dw04_cs and SPI_ACK_O_temp )= '1') then
				  		reg_toe <='1';
				  	elsif(( reg_wr and dw08_cs and SPI_ACK_O_temp )='1') then
				  		reg_toe <= '0';
				  	end if;
				  end if;
			end process;
--
end GENERATE master0;
--
END translated;
