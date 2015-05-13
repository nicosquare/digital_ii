

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY spi_wb_tb1_wrapper IS
PORT ( 
	  SPI_ADR_I               : OUT std_logic_vector(7 DOWNTO 0);
      SPI_DAT_I               : OUT std_logic_vector(7 DOWNTO 0);
      SPI_WE_I                : OUT std_logic;
      SPI_CYC_I               : OUT std_logic;
      SPI_STB_I               : OUT std_logic;
      SPI_SEL_I               : OUT std_logic_vector(3 DOWNTO 0);
      SPI_CTI_I               : OUT std_logic_vector(2 DOWNTO 0);
      SPI_BTE_I               : OUT std_logic_vector(1 DOWNTO 0);
      SPI_LOCK_I              : OUT std_logic;
	  MISO_MASTER             : OUT std_logic;
	  MOSI_SLAVE			  : OUT std_logic;
	  SS_N_SLAVE			  : OUT std_logic; 	
	  SCLK_SLAVE			  : OUT std_logic;
	  CLK_I					  : OUT std_logic;
	  RST_I			 		  : OUT std_logic;
	  SPI_DAT_O               : IN std_logic_vector(7 DOWNTO 0);
      SPI_ACK_O               : IN std_logic;
      SPI_INT_O               : IN std_logic;
      SPI_ERR_O               : IN std_logic;
      SPI_RTY_O               : IN std_logic;
	  MOSI_MASTER             : IN std_logic;
      SS_N_MASTER             : IN std_logic_vector(0 DOWNTO 0);
	  SCLK_MASTER             : IN std_logic;
      MISO_SLAVE              : IN std_logic);




END spi_wb_tb1_wrapper; 


architecture spi_wb_tb1_wrapper of spi_wb_tb1_wrapper is

	component spi_tf
		port ( 
			SPI_ADR_I               : OUT std_logic_vector(7 DOWNTO 0);
      SPI_DAT_I               : OUT std_logic_vector(7 DOWNTO 0);
      SPI_WE_I                : OUT std_logic;
      SPI_CYC_I               : OUT std_logic;
      SPI_STB_I               : OUT std_logic;
      SPI_SEL_I               : OUT std_logic_vector(3 DOWNTO 0);
      SPI_CTI_I               : OUT std_logic_vector(2 DOWNTO 0);
      SPI_BTE_I               : OUT std_logic_vector(1 DOWNTO 0);
      SPI_LOCK_I              : OUT std_logic;
	  MISO_MASTER             : OUT std_logic;
	  MOSI_SLAVE			  : OUT std_logic;
	  SS_N_SLAVE			  : OUT std_logic; 	
	  SCLK_SLAVE			  : OUT std_logic;
	  CLK_I					  : OUT std_logic;
	  RST_I			 		  : OUT std_logic;
	  SPI_DAT_O               : IN std_logic_vector(7 DOWNTO 0);
      SPI_ACK_O               : IN std_logic;
      SPI_INT_O               : IN std_logic;
      SPI_ERR_O               : IN std_logic;
      SPI_RTY_O               : IN std_logic;
	  MOSI_MASTER             : IN std_logic;
      SS_N_MASTER             : IN std_logic_vector(0 DOWNTO 0);
	  SCLK_MASTER             : IN std_logic;
      MISO_SLAVE              : IN std_logic);
	  
	end component;
	
	begin
	
	uut :	spi_tf port map(
	
	  SPI_ADR_I     =>	SPI_ADR_I,
      SPI_DAT_I     =>  SPI_DAT_I,
      SPI_WE_I      =>  SPI_WE_I,
      SPI_CYC_I     =>  SPI_CYC_I,
      SPI_STB_I     =>  SPI_STB_I,
      SPI_SEL_I     =>  SPI_SEL_I,
      SPI_CTI_I     =>  SPI_CTI_I,
      SPI_BTE_I     =>  SPI_BTE_I,
      SPI_LOCK_I    =>  SPI_LOCK_I,
	  MISO_MASTER   =>  MISO_MASTER,
	  MOSI_SLAVE	=>	MOSI_SLAVE,
	  SS_N_SLAVE	=>	SS_N_SLAVE,
	  SCLK_SLAVE	=>	SCLK_SLAVE,
	  CLK_I			=>	CLK_I,
	  RST_I			=> 	RST_I,
	  SPI_DAT_O     =>  SPI_DAT_O,
      SPI_ACK_O     =>  SPI_ACK_O,
      SPI_INT_O     =>  SPI_INT_O,
      SPI_ERR_O     =>  SPI_ERR_O,
      SPI_RTY_O     =>  SPI_RTY_O,
	  MOSI_MASTER   =>  MOSI_MASTER,
      SS_N_MASTER   =>  SS_N_MASTER,
	  SCLK_MASTER   =>  SCLK_MASTER,
      MISO_SLAVE    =>  MISO_SLAVE );
					
					
end spi_wb_tb1_wrapper;