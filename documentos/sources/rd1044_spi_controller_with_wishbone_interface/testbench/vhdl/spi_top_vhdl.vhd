

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY top IS
END top;
 
ARCHITECTURE behavior OF top IS 
 
    COMPONENT spi_wb_tb1_wrapper
    PORT(
         SPI_ADR_I : OUT  std_logic_vector(7 downto 0);
         SPI_DAT_I : OUT  std_logic_vector(7 downto 0);
         SPI_WE_I : OUT  std_logic;
         SPI_CYC_I : OUT  std_logic;
         SPI_STB_I : OUT  std_logic;
         SPI_SEL_I : OUT  std_logic_vector(3 downto 0);
         SPI_CTI_I : OUT  std_logic_vector(2 downto 0);
         SPI_BTE_I : OUT  std_logic_vector(1 downto 0);
         SPI_LOCK_I : OUT  std_logic;
         MISO_MASTER : OUT  std_logic;
         MOSI_SLAVE : OUT  std_logic;
         SS_N_SLAVE : OUT  std_logic;
         SCLK_SLAVE : OUT  std_logic;
         CLK_I : OUT  std_logic;
         RST_I : OUT  std_logic;
         SPI_DAT_O : IN  std_logic_vector(7 downto 0);
         SPI_ACK_O : IN  std_logic;
         SPI_INT_O : IN  std_logic;
         SPI_ERR_O : IN  std_logic;
         SPI_RTY_O : IN  std_logic;
         MOSI_MASTER : IN  std_logic;
         SS_N_MASTER : IN  std_logic_vector(0 downto 0);
         SCLK_MASTER : IN  std_logic;
         MISO_SLAVE : IN  std_logic
        );
    END COMPONENT;
    
	 
	 
	  COMPONENT spi
    PORT(
         SPI_ADR_I : IN  std_logic_vector(7 downto 0);
         SPI_DAT_I : IN  std_logic_vector(7 downto 0);
         SPI_WE_I : IN  std_logic;
         SPI_CYC_I : IN  std_logic;
         SPI_STB_I : IN  std_logic;
         SPI_SEL_I : IN  std_logic_vector(3 downto 0);
         SPI_CTI_I : IN  std_logic_vector(2 downto 0);
         SPI_BTE_I : IN  std_logic_vector(1 downto 0);
         SPI_LOCK_I : IN  std_logic;
         SPI_DAT_O : OUT  std_logic_vector(7 downto 0);
         SPI_ACK_O : OUT  std_logic;
         SPI_INT_O : OUT  std_logic;
         SPI_ERR_O : OUT  std_logic;
         SPI_RTY_O : OUT  std_logic;
         MISO_MASTER : IN  std_logic;
         MOSI_MASTER : OUT  std_logic;
         SS_N_MASTER : OUT  std_logic_vector(0 downto 0);
         SCLK_MASTER : OUT  std_logic;
         MISO_SLAVE : OUT  std_logic;
         MOSI_SLAVE : IN  std_logic;
         SS_N_SLAVE : IN  std_logic;
         SCLK_SLAVE : IN  std_logic;
         CLK_I : IN  std_logic;
         RST_I : IN  std_logic
        );
    END COMPONENT;
	 
	 
	 

   signal SPI_DAT_O : std_logic_vector(7 downto 0) := (others => '0');
   signal SPI_ACK_O : std_logic := '0';
   signal SPI_INT_O : std_logic := '0';
   signal SPI_ERR_O : std_logic := '0';
   signal SPI_RTY_O : std_logic := '0';
   signal MOSI_MASTER : std_logic := '0';
   signal SS_N_MASTER : std_logic_vector(0 downto 0) := (others => '0');
   signal SCLK_MASTER : std_logic := '0';
   signal MISO_SLAVE : std_logic := '0';


   signal SPI_ADR_I : std_logic_vector(7 downto 0);
   signal SPI_DAT_I : std_logic_vector(7 downto 0);
   signal SPI_WE_I : std_logic;
   signal SPI_CYC_I : std_logic;
   signal SPI_STB_I : std_logic;
   signal SPI_SEL_I : std_logic_vector(3 downto 0);
   signal SPI_CTI_I : std_logic_vector(2 downto 0);
   signal SPI_BTE_I : std_logic_vector(1 downto 0);
   signal SPI_LOCK_I : std_logic;
   signal MISO_MASTER : std_logic;
   signal MOSI_SLAVE : std_logic;
   signal SS_N_SLAVE : std_logic;
   signal SCLK_SLAVE : std_logic;
   signal CLK_I : std_logic;
   signal RST_I : std_logic;

  
 
BEGIN
 

   uut1: spi_wb_tb1_wrapper PORT MAP (
          SPI_ADR_I => SPI_ADR_I,
          SPI_DAT_I => SPI_DAT_I,
          SPI_WE_I => SPI_WE_I,
          SPI_CYC_I => SPI_CYC_I,
          SPI_STB_I => SPI_STB_I,
          SPI_SEL_I => SPI_SEL_I,
          SPI_CTI_I => SPI_CTI_I,
          SPI_BTE_I => SPI_BTE_I,
          SPI_LOCK_I => SPI_LOCK_I,
          MISO_MASTER => MISO_MASTER,
          MOSI_SLAVE => MOSI_SLAVE,
          SS_N_SLAVE => SS_N_SLAVE,
          SCLK_SLAVE => SCLK_SLAVE,
          CLK_I => CLK_I,
          RST_I => RST_I,
          SPI_DAT_O => SPI_DAT_O,
          SPI_ACK_O => SPI_ACK_O,
          SPI_INT_O => SPI_INT_O,
          SPI_ERR_O => SPI_ERR_O,
          SPI_RTY_O => SPI_RTY_O,
          MOSI_MASTER => MOSI_MASTER,
          SS_N_MASTER => SS_N_MASTER,
          SCLK_MASTER => SCLK_MASTER,
          MISO_SLAVE => MISO_SLAVE
        );



uut: spi PORT MAP (
          SPI_ADR_I => SPI_ADR_I,
          SPI_DAT_I => SPI_DAT_I,
          SPI_WE_I => SPI_WE_I,
          SPI_CYC_I => SPI_CYC_I,
          SPI_STB_I => SPI_STB_I,
          SPI_SEL_I => SPI_SEL_I,
          SPI_CTI_I => SPI_CTI_I,
          SPI_BTE_I => SPI_BTE_I,
          SPI_LOCK_I => SPI_LOCK_I,
          SPI_DAT_O => SPI_DAT_O,
          SPI_ACK_O => SPI_ACK_O,
          SPI_INT_O => SPI_INT_O,
          SPI_ERR_O => SPI_ERR_O,
          SPI_RTY_O => SPI_RTY_O,
          MISO_MASTER => MISO_MASTER,
          MOSI_MASTER => MOSI_MASTER,
          SS_N_MASTER => SS_N_MASTER,
          SCLK_MASTER => SCLK_MASTER,
          MISO_SLAVE => MISO_SLAVE,
          MOSI_SLAVE => MOSI_SLAVE,
          SS_N_SLAVE => SS_N_SLAVE,
          SCLK_SLAVE => SCLK_SLAVE,
          CLK_I => CLK_I,
          RST_I => RST_I
        );


END;
