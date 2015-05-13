    SPI Wishbone Reference Design
=====================================================================================

File List :

1.  \RD1044\docs\rd1044.pdf                                        									--> PCI Target design document
    \RD1044\docs\rd1044_readme.txt                                 									--> read me file (this file)
	\RD1044\docs\revision_history.xls																--> Revision History
	
2.  \RD1044\project\<Device_name>\verilog\<Device_name>_verilog.ldf									--> Lattice Diamond Design files to open diamond project	
	\RD1044\project\<Device_name>\verilog\<Device_name>_verilog.lpf                                	--> Preference constraint file for Diamond
    \RD1044\project\<Device_name>\verilog\<Device_name>_verilog.sty                                 --> Lattice Diamond Startegy file
	\RD1044\project\<Device_name>\verilog\<Device_name>_vhdl.ldf									--> Lattice Diamond Design files to open diamond project	
	\RD1044\project\<Device_name>\verilog\<Device_name>_vhdl.lpf                                	--> Preference constraint file for Diamond
    \RD1044\project\<Device_name>\verilog\<Device_name>_vhdl.sty                                    --> Lattice Diamond Startegy file
	\RD1044\Project\xo3l\verilog\xo3l_verilog_lse.lpf                 								-->  Lattice Diamond preference file for Lattice LSE        
    \RD1044\Project\xo3l\verilog\xo3l_verilog_lse.ldf                 								-->  The Lattice Diamond Project file for Lattice LSE
    \RD1044\Project\xo3l\verilog\xo3l_verilog_lse1.sty                								-->  Project strategy file for Lattice LSE
    \RD1044\Project\xo3l\verilog\xo3l_verilog_syn.lpf                 								-->  Lattice Diamond preference file for synplify pro        
    \RD1044\Project\xo3l\verilog\xo3l_verilog_syn.ldf                 								-->  The Lattice Diamond Project file for synplify pro
    \RD1044\Project\xo3l\verilog\xo3l_verilog_syn1.sty                								-->  Project strategy file for synplify pro
    \RD1044\Project\xo3l\vhdl\xo3l_vhdl_lse.lpf                       								-->  Lattice Diamond preference file for Lattice LSE        
    \RD1044\Project\xo3l\vhdl\xo3l_vhdl_lse.ldf                       								-->  The Lattice Diamond Project file for Lattice LSE
    \RD1044\Project\xo3l\vhdl\xo3l_vhdl_lse1.sty                      								-->  Project strategy file for Lattice LSE
    \RD1044\Project\xo3l\vhdl\xo3l_vhdl_syn.lpf                       								-->  Lattice Diamond preference file for synplify pro        
    \RD1044\Project\xo3l\vhdl\xo3l_vhdl_syn.ldf                       								-->  The Lattice Diamond Project file for synplify pro
    \RD1044\Project\xo3l\vhdl\xo3l_vhdl_syn1.sty                      								-->  Project strategy file for synplify pro

3.  \RD1044\simulation\<Device_name>\verilog\rtl_verilog.do				 		          			--> RTL simulation script file for verilog
	\RD1044\simulation\<Device_name>\verilog\timing_verilog.do			 		          			--> Timing simulation script file for verilog  
	\RD1044\simulation\<Device_name>\vhdl\rtl_vhdl.do				 			 		          	--> RTL simulation script file for vhdl
	\RD1044\simulation\<Device_name>\vhdl\timing_vhdl.do						 		          	--> Timing simulation script file for vhdl
		
4.  \RD1044\Source\verilog\spi_wb.v                                   								-->  Verilog source code file
    \RD1044\Source\vhdl\spi.vhd                                       								-->  VHDL source code file
	
5.  \RD1044\Testbench\verilog\spi_wb_tb1.v                            								-->  Verilog testbench for simulation
    \RD1044\Testbench\vhdl\spi_wb_tb1.v                               								-->  Verilog testbench
    \RD1044\Testbench\vhdl\spi_wb_tb1_vhdl_wrapper.vhd                								-->  wrapper for verilog testbench
    \RD1044\Testbench\vhdl\spi_top_vhdl.vhd                           								-->  VHDL top module for simulation



===================================================================================================  
Using Diamond Software
---------------------------------------------------------------------------------------------------  
HOW TO CREATE A PROJECT IN DIAMOND:
1. Launch Diamond software, in the GUI, select File >> New Project, click Next
2. In the New Project popup, select the Project location and provide a Project name and implementation 
   name, click Next.
3. Add the necessary source files from the RD1044\source\<language> directory, click Next
4. Select the desired part and speedgrade. You may use RD1044.pdf to see which device and speedgrade 
   can be selected to achieve the published timing result 
5. Click Finish. Now the project is successfully created. 
6. MAKE SURE the provided lpf and/or sty files are used in the current directory. 
      
----------------------------------------------------------------------------------------------------      
HOW TO RUN SIMULATION UNDER DIAMOND:
1. Bring up the Simulation Wizard under the Tools menu 
2. Next provide a name for simulation project, and select RTL or post-route simulation
	2.1 For post-route simulation, must export verilog or vhdl simulation file after Place and Route
3. Next add the test bench files form the RD1044\TestBench\<language> directory 
	3.1 For VHDL, make sure the top-level test bench is last to be added
4. Next click Finish, this will bring up the Aldec simulator automatically
5. In Aldec environment, you can manually activate the simulation or you can use a script
	5.1 Use the provided script in the RD1044\Simulation\xo3l\<language> directory
	  a. For functional simulation, change the library name to the device family
	  	i) MachXO2: ovi_machxo2 for verilog, machxo2 for vhdl
	  	ii) MachXO: ovi_machxo for verilog, machxo for vhdl
	  	iii)XP2: ovi_xp2 for verilog, xp2 for vhdl
		iv) MachXO3L: ovi_machxo3l for both vhdl and verilog
		b. For POST-ROUTE simulation, open the script and change the following:
			i) The sdf file name and the path pointing to your sdf file.
		   The path usually looks like "./<implementation_name>/<sdf_file_name>.sdf"
		  ii) Change the library name using the library name described above
		c. Click Tools > Execute Macro and select the xxx.do file to run the simulation
		d. This will run the simulation until finish
	5.2 Manually activate the simulation
		a. Click Simulation > Initialize Simulation
		b. Click File > New > Waveform, this will bring up the Waveform panel
		c. Click on the top-level testbench, drag all the signals into the Waveform panel
		d. At the Console panel, type "run 1500us" for VHDL simulation, or "run -all" for Verilog 
		   simulation
		e. For timing simulation, you must manually add 
		   -sdfmax UUT="./xo3l_verilog_syn/xo3l_verilog_syn_xo3l_verilog_syn_vo.sdf"
		   into the asim or vsim command. Use the command in timing_xxx.do as an example
6. The simulation result will be similar to the one described below. 


# KERNEL: ******* SPI in Master Mode *******
# KERNEL:    
# KERNEL: ******* Read SPI status register *******
# KERNEL:    
# KERNEL:     >>> SPI Transmit register EMPTY!    
# KERNEL:    
# KERNEL:    
# KERNEL: ******* Write 0x8B to Control register *******
# KERNEL:    
# KERNEL: ******* Read from Control register *******
# KERNEL:    
# KERNEL:     >>> Bit[0]: receive overrun error interrupt enabled   
# KERNEL:     >>> Bit[1]: transmit overrun error interrupt enabled   
# KERNEL:     >>> Bit[3]: transmitter ready interrupt enabled    
# KERNEL:     >>> Bit[8]: receiver ready interrupt enabled  
# KERNEL:    
# KERNEL:    
# KERNEL: ******* Read SPI status register *******
# KERNEL:    
# KERNEL:     >>> SPI Transmit register EMPTY!    
# KERNEL:    
# KERNEL:    
# KERNEL: ******* Slave Select Enable *******
# KERNEL:    
# KERNEL: ******* Read SPI status register *******
# KERNEL:    
# KERNEL:     >>> SPI Transmit register EMPTY!    
# KERNEL:    
# KERNEL:    
# KERNEL: ******* 1. Transmit data = 8'b11011010 *******
# KERNEL:     >>> SPI Transmit SUCCESSFUL = 11011010 
# KERNEL:    
# KERNEL: ******* Read SPI status register *******
# KERNEL:    
# KERNEL:     >>> SPI Transmit register EMPTY!    
# KERNEL:    
# KERNEL:    
# KERNEL: ******* 2. Transmit data = 8'b11110111 *******
# KERNEL:     >>> SPI Transmit SUCCESSFUL = 11110111 
# KERNEL:    
# KERNEL: ******* Read SPI status register *******
# KERNEL:    
# KERNEL:     >>> SPI Transmit register EMPTY!    
# KERNEL:    
# KERNEL:    
# KERNEL: ******* 3. Transmit data = 8'b11100111 *******
# KERNEL:     >>> SPI Transmit SUCCESSFUL = 11100111 
# KERNEL:    
# KERNEL: ******* Read SPI status register *******
# KERNEL:    
# KERNEL:     >>> SPI Transmit register EMPTY!    
# KERNEL:    
# KERNEL:    
# KERNEL: ******* 4. Transmit data = 8'b11100011 *******
# KERNEL:     >>> SPI Transmit SUCCESSFUL = 11100011 
# KERNEL:    
# KERNEL: ******* Read SPI status register *******
# KERNEL:    
# KERNEL:     >>> SPI Transmit register EMPTY!    
# KERNEL:    
# KERNEL:    
# KERNEL: ******* 5. Transmit data = 8'b11000011 *******
# KERNEL:     >>> SPI Transmit SUCCESSFUL = 11000011 
# KERNEL:    
# KERNEL: ******* Read SPI status register *******
# KERNEL:    
# KERNEL:     >>> SPI Transmit register EMPTY!    
# KERNEL:    
# KERNEL:    
# KERNEL: ******* 6. Transmit data = 8'b11000001 *******
# KERNEL:     >>> SPI Transmit SUCCESSFUL = 11000001 
# KERNEL:    
# KERNEL: ******* Read SPI status register *******
# KERNEL:    
# KERNEL:     >>> SPI Transmit register EMPTY!    
# KERNEL:    
# KERNEL:    
# KERNEL: ******* 7. Transmit data = 8'b10000001 *******
# KERNEL:     >>> SPI Transmit SUCCESSFUL = 10000001 
# KERNEL:    
# KERNEL: ******* Read SPI status register *******
# KERNEL:    
# KERNEL:     >>> SPI Transmit register EMPTY!    
# KERNEL:    
# KERNEL:    
# KERNEL: ******* 8. Transmit data = 8'b10001001 *******
# KERNEL:     >>> SPI Transmit SUCCESSFUL = 10001001 
# KERNEL:    
# KERNEL: ******* Read SPI status register *******
# KERNEL:    
# KERNEL:     >>> SPI Transmit register EMPTY!    
# KERNEL:    
# KERNEL:    
# KERNEL: ******* Wait for TMT status bit *******
# KERNEL:    
# KERNEL: ******* Slave Select Disable *******
# KERNEL:    
# KERNEL: ******* SPI transactions complete *******

   
===================================================================================================  
Using ispLEVER or ispLEVER Classic software
---------------------------------------------------------------------------------------------------
HOW TO CREATE A ISPLEVER OR ISPLEVER CLASSIC PROJECT:
1. Bring up ISPLEVER OR ISPLEVER CLASSIC software, in the GUI, select File >> New Project
2. In the New Project popup, select the Project location, provide a Project name, select Design Entry Type 
   and click Next.
3. Use RD1044.pdf to see which device /speedgrade should be selected to achieve the desired timing result
4. Add the necessary source files from the RD1044\source\<language> directory, click Next
5. Click Finish. Now the project is successfully created. 
6. Make sure the provided lpf or lct is used in the current directory. 

---------------------------------------------------------------------------------------------------
HOW TO RUN SIMULATION FROM ISPLEVER OR ISPLEVER CLASSIC PROJECT:
1. Import the top-level testbench into the project as test fixture and associate with the device
	1.1 Import the rest as Testbench Dependency File by highlighting and right click on the test bench file
2. In the Project Navigator, highlight the testbench file on the left-side panel, user will see 3 
   simulation options on the right panel.
3. For functional simulation, double click on Verilog (or VHDL) Functional Simulation with Aldec 
   Active-HDL. Aldec simulator will be brought up, click yes to overwrite the existing file. The 
   simulator will initialize and run for 1us.
4. Type "run 8200ns" for vhdl or "run -all" for verilog in the Console panel.The waveform is same as Figure 5; 
    
5. For timing simulation, double click on Verilog (or VHDL) Post-Route Timing Simulation with Aldec 
   Active-HDL. Similar message will be shown in the console panel of the Aldec Active-HDL simulator.
   5.1 "Run 8200ns" for vhdl or "run -all" for verilog to see the complete simulation
   5.1 In timing simulation you may see some warnings about narrow widths or vital glitches. These 
       warnings can be ignored. 
   5.2 Vital glitches can be removed by adding a vsim command in the udo file. Use the udo.example 
       under the \project directory
   
---------------------------------------------------------------------------------------------------














































