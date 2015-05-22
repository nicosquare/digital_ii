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
--                  web: http:--www.latticesemi.com/
--                  email: techsupport@latticesemi.com
--
--   --------------------------------------------------------------------
--  CVS Log
--
--  $Id: RD#RD1046#testbench#vhdl#i2c_slave_model.vhd,v 1.6 2013-10-11 00:34:48-07 vpatil Exp $
--
--  $Date: 2013-10-11 00:34:48-07 $
--  $Revision: 1.6 $
--  $Author: vpatil $
--  $Locker:  $
--  $State: Exp $
--
-- Change History:
--               $Log: RD#RD1046#testbench#vhdl#i2c_slave_model.vhd,v $
--               Revision 1.6  2013-10-11 00:34:48-07  vpatil
--               ...No comments entered during checkin...
--
--               Revision 1.5  2013-10-10 07:47:56-07  vpatil
--               Updated header.
--
--               Revision 1.4  2013-07-04 02:56:34-07  lsccad
--               Automatically checked in.
--
--               Revision 1.7  2006/09/04 09:08:51  rherveille
--               fixed (n)ack generation
--
--               Revision 1.6  2005/02/28 11:33:48  rherveille
--               Fixed Tsu:sta timing check.
--               Added Thd:sta timing check.
--
--               Revision 1.5  2003/12/05 11:05:19  rherveille
--               Fixed slave address MSB='1' bug
--
--               Revision 1.4  2003/09/11 08:25:37  rherveille
--               Fixed a bug in the timing section. Changed 'tst_scl' into 'tst_sto'.
--
--               Revision 1.3  2002/10/30 18:11:06  rherveille
--               Added timing tests to i2c_model.
--               Updated testbench.
--
--               Revision 1.2  2002/03/17 10:26:38  rherveille
--               Fixed some race conditions in the i2c-slave model.
--               Added debug information.
--               Added headers.
--
---------------------------------------------------------------------------
-- Code Revision History :
---------------------------------------------------------------------------
-- Ver: | Author |Mod. Date |Changes Made:                                           
-- V1.0 |J.T.    | 8/09     | Initial ver for VHDL                                       
-- 			    | converted from LSC ref design RD1046    
-- V1.1 |C.M.    |10/10     | move mem_init.txt to local directory               
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

package wb_master_model is
	
	type mem_type is array (3 downto 0) of std_logic_vector(7 downto 0);
	constant dwidth:integer:=8;
	constant awidth:integer:=4;
	function xcha_slv4 (inp: CHARACTER) return STD_LOGIC_VECTOR; 
	function xstr_slv8 (inp: STRING (1 to 2)) return STD_LOGIC_VECTOR;

	
	procedure ReadData (signal data : out mem_type;
                      file DF : TEXT   );
                      
  function slv8_xstr (inp: STD_LOGIC_VECTOR(7 downto 0)) return STRING;
  function slv4_xcha (inp: STD_LOGIC_VECTOR(3 downto 0)) return CHARACTER;   
  
  procedure initial_start(
	  signal adr:out std_logic_vector(awidth-1 downto 0); 
	  signal dout:out std_logic_vector(dwidth-1 downto 0); 
	  signal cyc:out std_logic;
	  signal stb:out std_logic;
	  signal we:out std_logic);                     
                      
                      

-- Wishbone write cycle	
	
	procedure wb_write(
	  constant delay: in integer;
	  constant a:in std_logic_vector(awidth-1 downto 0);                
	  constant d:in std_logic_vector(dwidth-1 downto 0);
	  signal clk:in std_logic;
	  signal ack:in std_logic;
	  signal adr:out std_logic_vector(awidth-1 downto 0); 
	  signal dout:out std_logic_vector(dwidth-1 downto 0); 
	  signal cyc:out std_logic;
	  signal stb:out std_logic;
	  signal we:out std_logic);  
	  
	procedure wb_read(
	  constant delay: in integer;
	  constant a:in std_logic_vector(awidth-1 downto 0);                
	  signal d:out std_logic_vector(dwidth-1 downto 0);
	  signal clk:in std_logic;
	  signal ack:in std_logic;
	  signal din:in std_logic_vector(dwidth-1 downto 0);
	  signal adr:out std_logic_vector(awidth-1 downto 0); 
	  signal dout:out std_logic_vector(dwidth-1 downto 0); 
	  signal cyc:out std_logic;
	  signal stb:out std_logic;
	  signal we:out std_logic);  
	  	  
end wb_master_model;

--------------------------------------------------------------------

package body wb_master_model is	  
	
function slv4_xcha (inp: STD_LOGIC_VECTOR(3 downto 0)) return CHARACTER is
variable result: character;

begin
  case inp is
    when "0000" => result := '0';
    when "0001" => result := '1';
    when "0010" => result := '2';
    when "0011" => result := '3';
    when "0100" => result := '4';
    when "0101" => result := '5';
    when "0110" => result := '6';
    when "0111" => result := '7';
    when "1000" => result := '8';
    when "1001" => result := '9';
    when "1010" => result := 'a';
    when "1011" => result := 'b';
    when "1100" => result := 'c';
    when "1101" => result := 'd';
    when "1110" => result := 'e';
    when "1111" => result := 'f';
    when others => result := 'x';
  end case;
return result;
end;

-- converts slv byte to two char hex-string
function slv8_xstr (inp: STD_LOGIC_VECTOR(7 downto 0)) return STRING is
variable result : string (1 to 2);

begin
  result := slv4_xcha(inp(7 downto 4)) & slv4_xcha(inp(3 downto 0)); 
  return result;
end;	
	
	
function xcha_slv4 (inp: CHARACTER) return STD_LOGIC_VECTOR is
variable result: std_logic_vector(3 downto 0);

begin
case inp is
  when '0' => result := "0000";
  when '1' => result := "0001";
  when '2' => result := "0010";
  when '3' => result := "0011";
  when '4' => result := "0100";
  when '5' => result := "0101";
  when '6' => result := "0110";
  when '7' => result := "0111";
  when '8' => result := "1000";
  when '9' => result := "1001";
  when 'a'|'A' => result :=  "1010";
  when 'b'|'B' => result :=  "1011";
  when 'c'|'C' => result :=  "1100";
  when 'd'|'D' => result :=  "1101";
  when 'e'|'E' => result :=  "1110";
  when 'f'|'F' => result :=  "1111";
  when 'x'|'X' => result :=  "XXXX";
  when 'z'|'Z' => result :=  "ZZZZ";
  when '-'     => result :=  "----";
  when  others  => result := "XXXX";
end case;
return result;
end;

function xstr_slv8 (inp: STRING (1 to 2)) return STD_LOGIC_VECTOR is
variable result : std_logic_vector(7 downto 0);

begin
  result := xcha_slv4(inp(1)) & xcha_slv4(inp(2));
  return result;
end;


procedure ReadData (signal data : out mem_type;
                    file DF : TEXT   )  is
  variable L : LINE;
  variable B_str : string(1 to 2);
  
  begin

  ext_loop: for I in 0 to 3 loop
    readline (DF, L);
    read (L, B_str);    
    data(I) <= xstr_slv8(B_str);

  end loop ext_loop;

  end;
  
  
  procedure initial_start(
	  signal adr:out std_logic_vector(awidth-1 downto 0); 
	  signal dout:out std_logic_vector(dwidth-1 downto 0); 
	  signal cyc:out std_logic;
	  signal stb:out std_logic;
	  signal we:out std_logic) is
	  	
	 begin
	 	adr<="XXXX";	
    dout<= "XXXXXXXX";
    cyc<= '0';
		stb<= '0';
		we <= '0';    
	 end;	
		
  

procedure wb_write(
	  constant delay: in integer;
	  constant a:in std_logic_vector(awidth-1 downto 0);                
	  constant d:in std_logic_vector(dwidth-1 downto 0);
	  signal clk:in std_logic;
	  signal ack:in std_logic;
	  signal adr:out std_logic_vector(awidth-1 downto 0); 
	  signal dout:out std_logic_vector(dwidth-1 downto 0); 
	  signal cyc:out std_logic;
	  signal stb:out std_logic;
	  signal we:out std_logic) is
	  	
	 begin
	 	 -- wait initial delay
	 	 if(delay/=0) then
	 	   for I in 0 to delay-1 loop
	  	   wait until clk'event and clk = '1';
	     end loop;
     end if;
     -- assert wishbone signal
     wait for 2 ns;-- wait 2ns instead of 1
     adr<=a;
     dout<=d;
     cyc<='1';
     stb<='1';
     we<='1';
     wait until clk'event and clk = '1';
     
     -- wait for acknowledge from slave
     while(ack='0') loop
     	 wait until clk'event and clk = '1';
     end loop;
     	
     -- negate wishbone signals	
     wait for 2 ns;
     cyc <= '0';
		 stb <= '0'; --'x'; cm - chagne to inactive state
		 adr <= "XXXX";
		 dout<= "XXXXXXXX";       
		 we  <= '0'; --'x'; cm - change to inactive state
   end;

  procedure wb_read(
	  constant delay: in integer;
	  constant a:in std_logic_vector(awidth-1 downto 0);                
	  signal d:out std_logic_vector(dwidth-1 downto 0);
	  signal clk:in std_logic;
	  signal ack:in std_logic;
	  signal din:in std_logic_vector(dwidth-1 downto 0);
	  signal adr:out std_logic_vector(awidth-1 downto 0); 
	  signal dout:out std_logic_vector(dwidth-1 downto 0); 
	  signal cyc:out std_logic;
	  signal stb:out std_logic;
	  signal we:out std_logic) is

    begin
    	-- wait initial delay
    if(delay/=0) then
	 	 for I in 0 to delay-1 loop
	  	 wait until clk'event and clk = '1';
	   end loop;
	  end if; 	
	   	
	   -- assert wishbone signal
     wait for 2 ns;-- wait 2ns instead of 1
     adr<=a;
     dout<="XXXXXXXX";       
     cyc<='1';
     stb<='1';
     we<='0';
     wait until clk'event and clk = '1';	
     
      -- wait for acknowledge from slave
     while(ack='0') loop
     	 wait until clk'event and clk = '1';
     end loop;
     	
      -- negate wishbone signals	
     wait for 2 ns;
     cyc <= '0';
		 stb <= '0'; --'x'; cm - chagne to inactive state
		 adr <= "XXXX";
		 dout<= "XXXXXXXX";       
		 we  <= '0'; --'x'; cm - change to inactive state
		 d   <= din;
		 wait for 1 ns;
   end;
       
end wb_master_model;	




library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use work.wb_master_model.all;

entity i2c_slave_model is
generic(debug:std_logic;
        I2C_ADR:std_logic_vector(6 downto 0));
port (
       scl: in std_logic;
       sda:inout std_logic
);         
end i2c_slave_model;

architecture ben of i2c_slave_model is
	--type mem_type is array (3 downto 0) of std_logic_vector(7 downto 0);
	signal mem:mem_type; 
	--constant I2C_ADR:std_logic_vector(6 downto 0):="0010000";
	--constant debug:std_logic:='1';
	signal mem_adr:std_logic_vector(7 downto 0);
	signal mem_do:std_logic_vector(7 downto 0);--:="00000000";
	
	signal sta:std_logic;
	signal d_sta:std_logic;
	signal sto:std_logic;
	signal sr:std_logic_vector(7 downto 0);
	signal rw:std_logic;
	
	signal my_adr:std_logic;
	signal i2c_reset:std_logic;
	signal bit_cnt:std_logic_vector(2 downto 0);
	signal acc_done:std_logic;
	signal ld:std_logic;
	
	signal sda_o:std_logic:='1';
	signal sda_dly:std_logic;
	
	constant idle:std_logic_vector(2 downto 0):="000";
	constant slave_ack:std_logic_vector(2 downto 0):="001";
	constant get_mem_adr:std_logic_vector(2 downto 0):="010";
	constant gma_ack:std_logic_vector(2 downto 0):="011";
	constant data:std_logic_vector(2 downto 0):="100";
	constant data_ack:std_logic_vector(2 downto 0):="101";
	
	signal state:std_logic_vector(2 downto 0):=idle;  
		
	file buff_rd  : TEXT open read_mode is "../../../testbench/vhdl/mem_init.txt";  
	--file buff_rd  : TEXT open read_mode is "mem_init.txt";  
	signal bool:std_logic:='1';  	

	begin
		  
  -- generate shift register 
   process
    begin
     wait until scl'event and scl='H';
    	sr<=(sr(6 downto 0) & sda) after 1 ns;
    end process;
    
  --detect my_address    
   my_adr<='1' when sr(7 downto 1)= I2C_ADR else '0';	   
  -- FIXME: This should not be a generic assign, but rather
	-- qualified on address transfer phase and probably reset by stop

	--generate bit-counter   
	 process
	  begin  
	   wait until scl'event and scl='H';
	   	if ld='1' then
	   		bit_cnt<="111" after 1 ns;
	   	else
	   	  bit_cnt<=bit_cnt-"001" after 1 ns;
	    end if;
	  end process;
	  
   --generate access done signal
	  acc_done<= not(bit_cnt(2) or bit_cnt(1) or bit_cnt(0));	  
	  
	-- generate delayed version of sda
	-- this model assumes a hold time for sda after the falling edge of scl.
	-- According to the Phillips i2c spec, there s/b a 0 ns hold time for sda
	-- with regards to scl. If the data changes coincident with the clock, the
	-- acknowledge is missed
	-- Fix by Michael Sosnoski
	sda_dly<='1' when sda='H' else '0' after 1 ns; 
	 
  process(sda)
   begin
   	 	--detect start condition
   	 if(sda'event and sda='0') then
   	 	 if(scl='H') then 
   	 	 	  sta<='1' after 1 ns;       	 	 	 
   	 	 	  sto<='0' after 1 ns;     
   	 	    if debug='1' then
   		     	report "DEBUG i2c_slave; start condition detected";
   	      end if;
   	   else   
           sta <= '0' after 1 ns;
       end if;
      end if;
      
      -- detect stop condition
      if(sda'event and sda='H') then
        if(scl='H') then 
            sta<='0' after 1 ns;
  		      sto<='1' after 1 ns; 
  		      if debug='1' then
   		   	   report "DEBUG i2c_slave; stop condition detected";
  		      end if;
  		  else
    		  sto<='0' after 1 ns;
        end if; 
      end if; 
  	end process;	    
  		    
  	process(sda,scl)
  	 begin
  	 	if(sda'event and sda='0') then
   	 	 if(scl='H') then  	
  		   d_sta<='0' after 1 ns;
  		 end if;
  		end if;
  		
  		if(scl'event and scl='H') then
  			 d_sta<=sta after 1 ns;
  	  end if;
  	end process;
  		    
	 
	 --generate i2c_reset signal
   i2c_reset<= sta or sto;
   
  -- generate statemachine
   process
    begin 
    if (bool='1') then
    	ReadData (mem, buff_rd);
    	file_close(buff_rd); 
    	bool<='0';
    end if; 
     
    wait until scl'event and scl='H';
    	if(acc_done='0' and rw='H') then
    	 mem_do <= mem_do(6 downto 0) & '1' after 1 ns; -- insert 1'b1 for host ack generation
    	end if; 
    	
    wait until (scl'event and scl='0') or (sto'event and sto='1');
      if ((sta='1' and d_sta='0') or sto='1'  ) then     
       state <= idle after 1 ns; -- reset statemachine
	     sda_o  <= '1'  after  1 ns;
	     ld     <= '1'  after  1 ns;
	    else
	     sda_o <= '1' after 1 ns;
	     ld    <= '0'after 1 ns;
	     
	     case state is
	     	 when idle=>
	     	     if (acc_done='1' and my_adr='1') then
	                      state <= slave_ack after 1 ns;
	                      rw <= sr(0) after 1 ns;
	                      sda_o <='0' after 1 ns; -- generate i2c_ack
      
	                      wait for 2 ns;
	                      if(debug='1' and rw='H') then
	                        report "DEBUG i2c_slave; command byte received (read)";
	                      end if;
	                      if(debug='1' and rw='0') then
	                        report "DEBUG i2c_slave; command byte received (write)";
                        end if;
	                      if (rw='H') then
	                            mem_do <= mem(conv_integer(mem_adr)) after 1 ns;
      
	                            if(debug='1') then
	                                  wait for 2 ns;
 	                                  report "DEBUG i2c_slave; data block read:" & slv8_xstr(mem_do) & "from address:" & slv8_xstr(mem_adr) & "(1)";
	                                  wait for 2 ns;
	                                  report "DEBUG i2c_slave; memcheck [0]=" & slv8_xstr(mem(0)) & "[1]=" & slv8_xstr(mem(1)) &"[2]=" & slv8_xstr(mem(2)) & "[3]=" & slv8_xstr(mem(3));
	                            end if;
	                      end if;
	             end if;
	       when slave_ack=>	             
	                   if(rw='H') then	                    
	                          state <= data after 1 ns;
	                          --sda_o <= mem_do(7) after 1 ns;	                    
	                          if(mem_do(7)='H') then
	                            sda_o <='1'  after 1 ns;
	                          else
	                           sda_o <=mem_do(7)  after 1 ns; 
	                          end if;
	                    else
	                      state <= get_mem_adr after 1 ns;
                      end if;
                      ld<='1' after 1 ns;
	       when get_mem_adr=>   
	         if(acc_done='1') then
	                      state <= gma_ack after 1 ns;
	                      mem_adr <= sr after 1 ns; -- store memory address
	                      if(sr<= "00001111") then
	                        sda_o <='0' after 1 ns; -- generate i2c_ack, for valid address
	                      else
	                        sda_o <='1' after 1 ns; -- generate i2c_ack, for valid address  
	                      end if;
	                      if(debug='1') then
	                        wait for 1 ns;
	                        report "DEBUG i2c_slave; address received. adr=" & slv8_xstr(sr);
	                      end if;
	         end if;
	       when gma_ack=>
	                    state <= data after 1 ns;
	                    ld    <= '1' after 1 ns;
         when data=>
	                    if(rw='H') then
	                    	if(mem_do(7)='H') then
	                        sda_o <='1'  after 1 ns;
	                      else
	                        sda_o <=mem_do(7)  after 1 ns; 
	                      end if;
                      end if;
	                    if(acc_done='1') then
	                          state <= data_ack after 1 ns;
	                          mem_adr <= mem_adr + "00000001" after 2 ns;
	                          if(rw='H' and (mem_adr <= "00001111")) then
	                             sda_o <='1'  after 1 ns; -- send ack on write, receive ack on read
	                          else   
                               sda_o <='0'  after 1 ns; -- send ack on write, receive ack on read
                            end if;
	                          if(rw='H') then                        
	                                wait for 3 ns;
	                                if(conv_integer(mem_adr)>3) then
	                                  mem_do <="XXXXXXXX";
	                                else 	
	                                  mem_do <= mem(conv_integer(mem_adr));
                                  end if;
	                                if(debug='1') then 
	                                  wait for 5 ns;
	                                  report "DEBUG i2c_slave; data block read " & slv8_xstr(mem_do) & "from address" & slv8_xstr(mem_adr);
	                                end if;  
	                          end if;
      
	                          if(rw='0') then	        
	                                mem( conv_integer(mem_adr(3 downto 0)) ) <= sr after 1 ns; -- store data in memory
	                                if(debug='1') then
	                                  wait for 2 ns;
	                                  report "DEBUG i2c_slave; data block write " & slv8_xstr(sr) & "to address" &  slv8_xstr(mem_adr);
                                  end if;
	                          end if;
	                      end if;
	       when data_ack=>
	                    ld <= '1' after 1 ns;
      
	                    if(rw='H') then
	                      if(sr(0)='1' or sr(0)='H') then -- read operation && master send NACK
	                            state <= idle after 1 ns;
	                            sda_o <= '1' after 1 ns;	                     
	                      else
      
	                            state <=data after 1 ns;
	                        --    sda_o <=mem_do(7) after 1 ns;
	                            if(mem_do(7)='H') then
	                              sda_o <='1'  after 1 ns;
	                            else
	                              sda_o <=mem_do(7)  after 1 ns; 
	                            end if;
	                      end if;
	                    else
      
	                          state <= data after 1 ns;
	                          sda_o <= '1' after 1 ns;
	                    end if; 
	        when others=>
	                state <= idle after 1 ns;                
	        end case;
	      end if;
--	    end if;
	  end process;
	     
	  -- generate tri-states
	 sda<= 'Z' when sda_o='1' else '0' ;
	 	 
end ben;	   	 
	   	   