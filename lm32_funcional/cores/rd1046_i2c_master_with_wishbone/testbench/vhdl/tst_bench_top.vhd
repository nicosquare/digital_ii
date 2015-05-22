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
--  $Id: RD#RD1046#testbench#vhdl#tst_bench_top.vhd,v 1.5 2013-10-10 07:47:49-07 vpatil Exp $
--
--  $Date: 2013-10-10 07:47:49-07 $
--  $Revision: 1.5 $
--  $Author: vpatil $
--  $Locker:  $
--  $State: Exp $
--
-- Change History:
--               $Log: RD#RD1046#testbench#vhdl#tst_bench_top.vhd,v $
--               Revision 1.5  2013-10-10 07:47:49-07  vpatil
--               Updated header.
--
--               Revision 1.4  2013-07-04 02:56:37-07  lsccad
--               Automatically checked in.
--
--               Revision 1.8  2006/09/04 09:08:51  rherveille
--               fixed (n)ack generation
--
--               Revision 1.7  2005/02/27 09:24:18  rherveille
--               Fixed scl, sda delay.
--
--               Revision 1.6  2004/02/28 15:40:42  rherveille
--               *** empty log message ***
--
--               Revision 1.4  2003/12/05 11:04:38  rherveille
--               Added slave address configurability
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
-- Name:  tst_bench_top.v   
-- 
-- Description: This module is the top-level testbench, which controls the 
-- flow of the wb v.s. i2c transmit and receive procedures. 
--   
---------------------------------------------------------------------------
-- Code Revision History :
---------------------------------------------------------------------------
-- Ver: | Author |Mod. Date |Changes Made:                                           
-- V1.0 |J.T.    | 8/09     | Initial ver for VHDL                                       
-- 			    | converted from LSC ref design RD1046   
---------------------------------------------------------------------------







library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use work.wb_master_model.all;  	

entity tst_bench_top is
end tst_bench_top;

architecture ben of tst_bench_top is
	 
	 component i2c_master_wb_top port(
		-- wishbone interface
		wb_clk_i:in std_logic;
		wb_rst_i:in std_logic;
		arst_i:in std_logic;
		wb_adr_i:in std_logic_vector(2 downto 0);
		wb_dat_i:in std_logic_vector(7 downto 0);
		wb_dat_o:out std_logic_vector(7 downto 0);
		wb_we_i:in std_logic;
		wb_stb_i:in std_logic;
		wb_cyc_i:in std_logic;
		wb_ack_o:out std_logic;
		wb_inta_o:out std_logic;

		-- i2c signals
    scl:inout std_logic;
    sda:inout std_logic
	); 
end component;

component i2c_slave_model generic(debug:std_logic;
                                  I2C_ADR:std_logic_vector(6 downto 0));
    port (
       scl: inout std_logic;
       sda:inout std_logic
);         
end component;

signal clk:std_logic; --master clock from wb
signal rstn:std_logic;--async reset, not from wb
signal adr:std_logic_vector(3 downto 0);
signal dat_i,dat_o,dat0_i:std_logic_vector(7 downto 0);
signal we:std_logic;
signal stb:std_logic;
signal cyc:std_logic;
signal ack:std_logic;
signal inta:std_logic;

signal check_SR,data_rxr:std_logic_vector(7 downto 0);--give meaningful names to q, and qq, respectively
signal scl:std_logic;--scl0_o, scl0_oen,scl1_o, scl1_oen; cm - not using these signals
signal sda:std_logic;--sda0_o, sda0_oen sda1_o, sda1_oen;

constant PRER_LO:std_logic_vector(2 downto 0):="000";
constant PRER_HI:std_logic_vector(2 downto 0):="001";
constant CTR:std_logic_vector(2 downto 0):="010";
constant RXR:std_logic_vector(2 downto 0):="011";
constant TXR:std_logic_vector(2 downto 0):="011";
constant CR:std_logic_vector(2 downto 0):="100";
constant SR:std_logic_vector(2 downto 0):="100";

constant TXR_R:std_logic_vector(2 downto 0):="101";--undocumented / reserved output
constant CR_R:std_logic_vector(2 downto 0):="110";--undocumented / reserved output

constant RD:std_logic:='1';
constant WR:std_logic:='0';
constant SADR:std_logic_vector(6 downto 0):="0010000";

signal stb0 : std_logic;
signal sda_pullup_ctrl : std_logic;
signal scl_pullup_ctrl : std_logic;
signal readout_data:std_logic_vector(7 downto 0);

signal bool:std_logic:='0';

begin
	
	-- generate clock	
	clk_gen:process
	 begin
	 	 clk<='0';
	 	 wait for 10 ns;
	 	 loop
	 	 	 clk<=not clk;
	 	 	 wait for 10 ns;
	 	 end loop;
	end process;
	
  stb0<=stb and (not adr(3));
	
	dat_i<=(stb0,stb0,stb0,stb0,stb0,stb0,stb0,stb0) and dat0_i;
 	
  i2c_top:i2c_master_wb_top port map(
      -- wishbone interface
  		wb_clk_i=>clk,
  		wb_rst_i=>'0',
  		arst_i=>rstn,
  		wb_adr_i=>adr(2 downto 0),
  		wb_dat_i=>dat_o,
  		wb_dat_o=>dat0_i,
  		wb_we_i=>we,
  		wb_stb_i=>stb0,
  		wb_cyc_i=>cyc,
  		wb_ack_o=>ack,
  		wb_inta_o=>inta,
  
  		-- i2c signals
      scl=>scl,
      sda=>sda
  	); 
  	
  	i2c_slave: i2c_slave_model generic map('0',SADR)
  	     port map(
  		      scl=>scl,
  		      sda=>sda
  	);
  
  --pullup sda line
  process (sda)
  begin
    case sda is
      when '0'  =>
        sda_pullup_ctrl <= '0';
      when others =>
        sda_pullup_ctrl <= '1';
    end case;
  
  end process;
  
  sda_pullup: process (sda_pullup_ctrl)
  begin
    if sda_pullup_ctrl = '1' then
      sda <= 'H';
    end if;
  end process;	
 
  --pullup scl line 
  process (scl)
  begin
    case scl is
      when '0'  =>
        scl_pullup_ctrl <= '0';
      when others =>
        scl_pullup_ctrl <= '1';
    end case;
  
  end process;
  
 --  --pullup scl line 
 -- process (scl,bool)
 -- begin  
 -- 	if(bool='1') then
 -- 		scl_pullup_ctrl<='0';
 --   else
 --     case scl is
 --       when '0'  =>
 --         scl_pullup_ctrl <= '0';
 --       when others =>
 --         scl_pullup_ctrl <= '1';
 --     end case;
 --   end if;
 -- end process;
  
  
  
  --scl_pullup: process (scl_pullup_ctrl)
  --begin
  --  if scl_pullup_ctrl = '1' then
  --    scl <= 'H';
  --  end if;
  --end process;
   scl_pullup: process (scl_pullup_ctrl,bool)
   begin    
   	 if(bool='1') then  
   	 	 scl <= '0';                                
     elsif scl_pullup_ctrl = '1' then      
       scl <= 'H';                      
     elsif (bool='0') then
     	 scl<='Z';
     end if;     
                            
   end process;                         
  
  	                                     
          	                                      	                                       	                                     
  initial:process
   begin 
   	initial_start(adr,dat_o,cyc,stb,we);	
   	report "status:  Testbench started";	
   	-- reset system
   	rstn<='0';--//cm: initialized to reset mode,1'b1; // negate reset
   	wait for 2 ns;
   	rstn<='0'; --// assert reset

--	  	 wait until clk'event and clk = '1';
    wait for 8 ns;
	  rstn<= '1'; --// negate reset 	
	  report "status: done reset";
	  wait until clk'event and clk = '1';
	  
	  --// program core
  	
  	--// program internal registers	  
	  wb_write(1, '0' & PRER_LO,"01100100",clk,ack,adr,dat_o,cyc,stb,we); --/ load prescaler lo-byte
	  wb_write(1, '0' & PRER_HI,"00000000",clk,ack,adr,dat_o,cyc,stb,we); --// load prescaler hi-byte
	  report "status:  programmed registers";
	  
	  --// verify prescaler lo-byte
	  wb_read(0, '0' & PRER_LO,readout_data,clk,ack,dat_i,adr,dat_o,cyc,stb,we);
--	  wait for 1 ns; 
	  if (readout_data /= "01100100") then
			report "Data compare error. Received:" & slv8_xstr(readout_data) &", expected:64  ";
	  end if;
	  --verify prescaler hi-byte
	  wb_read(0, '0' & PRER_HI,readout_data,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
--	  wait for 1 ns;
	  if (readout_data /= "00000000") then
			report "Data compare error. Received :" & slv8_xstr(readout_data) & ", expected:00 ";
	  end if;
	  report "status: verified registers";
	  
	  wb_write(1,'0' & CTR,"10000000",clk,ack,adr,dat_o,cyc,stb,we); -- enable core
	  report "status: core enabled";
	  
	  --// access slave (write)
	  
	  --// drive slave address
	  wb_write(1,'0' & TXR,(SADR & WR),clk,ack,adr,dat_o,cyc,stb,we); --/ present slave address, set write-bit
	  wb_write(0,'0' & CR,"10010000",clk,ack,adr,dat_o,cyc,stb,we); --// set command (start, write)
	  report "status: generate 'start', write cmd 20 (slave address+write)";
	  
	  --// check tip bit
	  wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
	  while(check_SR(1)='1') loop
	  	 wb_read(0,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); --// poll it until it is zero
	  end loop;
	  report "status:  tip==0";
	  
	  --// send memory address
	  wb_write(1,'0' & TXR,"00000001",clk,ack,adr,dat_o,cyc,stb,we); --/ // present slave's memory address
	  wb_write(0,'0' & CR,"00010000",clk,ack,adr,dat_o,cyc,stb,we); --/ // set command (write)
	  report "status:  write slave memory address 01";
	  
	  -- check tip bit
	  wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
	  while(check_SR(1)='1') loop
	  	 wb_read(0,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); --// poll it until it is zero
	  end loop;
	  report "status:  tip==0";
	  
	  --// send memory contents
	  wb_write(1,'0' & TXR,"10100101",clk,ack,adr,dat_o,cyc,stb,we); --/ // present data
	  wb_write(0,'0' & CR,"00010000",clk,ack,adr,dat_o,cyc,stb,we); --/ // set command (write)
	  report "status:  write slave memory address a5";
	  
	  --// emulate clock stretching
	  while(scl='H') loop
	  	 wait for 1 ns;
	  end loop;
	  bool<='1';
	  wait for 100000 ns;
	  bool<='0';
	  
	  --// check tip bit
	  wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
	  while(check_SR(1)='1') loop
	  	 wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); --// poll it until it is zero
	  end loop;
	  report "status:  tip==0";
	  
	  --// send memory contents for next memory address (auto_inc)
	  wb_write(1,'0' & TXR,"01011010",clk,ack,adr,dat_o,cyc,stb,we); --/ // present data
	  wb_write(0,'0' & CR,"01010000",clk,ack,adr,dat_o,cyc,stb,we); --/ // set command (stop, write)
	  report "status:  write next data 5a, generate 'stop'";
	  
	  --// check tip bit
	  wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
	  while(check_SR(1)='1') loop
	  	 wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); --// poll it until it is zero
	  end loop;
	  report "status:  tip==0";
	  
	  --
	  -- access slave (read)
	  --
	  
	  --// drive slave address
	  wb_write(1,'0' & TXR,(SADR & WR),clk,ack,adr,dat_o,cyc,stb,we); --/ // present slave address, set write-bit
	  wb_write(0,'0' & CR,"10010000",clk,ack,adr,dat_o,cyc,stb,we); --/ // set command (start, write)
	  report "status:  generate 'start', write cmd 20 (slave address+write)";
	  
	   --// check tip bit
	  wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
	  while(check_SR(1)='1') loop
	  	 wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); --// poll it until it is zero
	  end loop;
	  report "status:  tip==0";
	  
	  --// send memory address
	  wb_write(1,'0' & TXR,"00000001",clk,ack,adr,dat_o,cyc,stb,we); --/ //  present slave's memory address
	  wb_write(0,'0' & CR,"00010000",clk,ack,adr,dat_o,cyc,stb,we); --/ // sset command (write)
	  report "status:  write slave address 01";
	  
	  --// check tip bit
	  wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
	  while(check_SR(1)='1') loop
	  	 wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); --// poll it until it is zero
	  end loop;
	  report "status:  tip==0";
	  
	  --// drive slave address
	  wb_write(1,'0' & TXR,(SADR & RD),clk,ack,adr,dat_o,cyc,stb,we); --/ //  present slave's address, set read-bit
	  wb_write(0,'0' & CR,"10010000",clk,ack,adr,dat_o,cyc,stb,we); --/ // set command (start, write)
	  report "status:  generate 'repeated start', write cmd 21 (slave address+read)";
	  
	  --// check tip bit
	  wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
	  while(check_SR(1)='1') loop
	  	 wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); --// poll it until it is zero
	  end loop;
	  report "status:  tip==0";
	  
	   --// read data from slave
	   wb_write(1,'0' & CR,"00100000",clk,ack,adr,dat_o,cyc,stb,we); --/ //  set command (read, ack_read)
	   report "status:  read + ack";
	   
	   --// check tip bit
	   wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
	   while(check_SR(1)='1') loop
	  	 wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); --// poll it until it is zero
	   end loop;
	   report "status:  tip==0";
   
	   --// check data just received
	   wb_read(1,'0' & RXR,data_rxr,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
	   if(data_rxr/="10100101") then
	   	 report "ERROR: Expected a5, received:" & slv8_xstr(data_rxr)  ;
	   else
	     report "status:  received: " & slv8_xstr(data_rxr)  ;
     end if;
     
     --// read data from slave	     
	   wb_write(1,'0' & CR,"00100000",clk,ack,adr,dat_o,cyc,stb,we); --/ //  set command (read, ack_read) 
	   report "status:  read + ack";
	   
	   --// check tip bit
	   wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
	   while(check_SR(1)='1') loop
	  	 wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); --// poll it until it is zero
	   end loop;
	   report "status:  tip==0";
	   
	   --// check data just received
	   wb_read(1,'0' & RXR,data_rxr,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
	   if(data_rxr/="01011010") then
	   	 report "ERROR: Expected 5a, received :" & slv8_xstr(data_rxr)  ;
	   else
	     report "status:  received :" & slv8_xstr(data_rxr);
     end if;
	   
	   --// read data from slave
	   wb_write(1,'0' & CR,"00101000",clk,ack,adr,dat_o,cyc,stb,we); --/ //  set command (read, nack_read)
	   report "status:  read + nack";
	   
     --// check tip bit
     wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
     while(check_SR(1)='1') loop
    	 wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); --// poll it until it is zero
     end loop;
     report "status:  tip==0";
	    
	    --// check data just received
	    wb_read(1,'0' & RXR,data_rxr,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
	    report "status:  received:" & slv8_xstr(data_rxr) & " from 3rd read address";
	   
	   --// check invalid slave memory address
	    
     
	   -- // drive slave address
	   wb_write(1,'0' & TXR,(SADR & WR),clk,ack,adr,dat_o,cyc,stb,we); --/ // present slave address, set write-bit
	   wb_write(0,'0' & CR,"10010000",clk,ack,adr,dat_o,cyc,stb,we); --/ //set command (start, write)
	   report "status: generate 'start', write cmd 20 (slave address+write). Check invalid address";
	   
	   --// check tip bit
	   wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
	   while(check_SR(1)='1') loop
	  	 wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); --// poll it until it is zero
	   end loop;
	   report "status:  tip==0";
	   
	   --// send memory address
	   wb_write(1,'0' & TXR,"00010000",clk,ack,adr,dat_o,cyc,stb,we); --/ // present slave's memory address
	   wb_write(0,'0' & CR,"00010000",clk,ack,adr,dat_o,cyc,stb,we); --/ //set command (write)
	   report "status:  write slave memory address 10";
	   
	   --// check tip bit
	   wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
	   while(check_SR(1)='1') loop
	  	 wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); --// poll it until it is zero
	   end loop;
	   report "status:  tip==0";
	   
	   --// slave should have send NACK
	   report "status:  Check for nack";
	   if(check_SR(7)='0') then
	   	 report "ERROR: Expected NACK, received ACK";
	   end if;
	   
	   --// read data from slave
	   wb_write(1,'0' & CR,"01000000",clk,ack,adr,dat_o,cyc,stb,we); --/ set command (stop)
	   report "status:  generate 'stop'";
	   
	   --// check tip bit
	   wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); 
	   while(check_SR(1)='1') loop
	  	 wb_read(1,'0' & SR,check_SR,clk,ack,dat_i,adr,dat_o,cyc,stb,we); --// poll it until it is zero
	   end loop;
	   report "status:  tip==0";
	   
	   wait for 250000 ns; --// wait 250us   
	   report "status:  Testbench done";
	   
	  wait;
	  
 end process;	  
end ben;	  	 
	  	 
	  	 
	  	 
 
	  	 
