                    I2C Master with WISHBONE Reference Design
===============================================================================

File List (54 files)
 1. /RD1046/docs/rd1046.pdf                           	 --> I2C master with WISHBONE design document
    /RD1046/docs/rd1046_readme.txt                    	 --> Read me file (this file)
    /RD1046/docs/I2C_Bus_specification.pdf            	 --> I2C spec version 2.1

 2. /RD1046/Project/ECP3/verilog/ecp3_verilog.ldf                    /*
     /RD1046/Project/LXP2/verilog/lxp2_verilog.ldf		
     /RD1046/Project/ecp5/ecp5_verilog.ldf
    /RD1046/Project/XO2/verilog/xo2_verilog.ldf
    /RD1046/Project/XO/verilog/xo_verilog.ldf                             Lattice Diamond Design files to open diamond project

    /RD1046/Project/ECP3/vhdl/ecp3_vhdl.ldf
    /RD1046/Project/LXP2/vhdl/lxp2_vhdl.ldf
    /RD1046/Project/ecp5/vhdl/ecp5_vhdl.ldf
    /RD1046/Project/XO2/vhdl/xo2_vhdl.ldf
    /RD1046/Project/XO/vhdl/xo_vhdl.ldf                                   */

    /RD1046/Project/ECP3/verilog/ecp3_verilog.lpf		/*
    /RD1046/Project/LXP2/verilog/lxp2_verilog.lpf
    /RD1046/Project/ecp5/ecp5_verilog.lpf
    /RD1046/Project/XO2/verilog/xo2_verilog.lpf		Lattice Diamond Preference files
    /RD1046/Project/XO/verilog/xo_verilog.lpf

    /RD1046/Project/ECP3/vhdl/ecp3_vhdl.lpf
    /RD1046/Project/LXP2/vhdl/lxp2_vhdl.lpf
    /RD1046/Project/ecp5/ecp5_vhdl.lpf
    /RD1046/Project/XO2/vhdl/xo2_vhdl.lpf
    /RD1046/Project/XO/vhdl/xo_vhdl.lpf			*/

    /RD1046/Project/ECP3/verilog/ecp3_verilog1.sty		/*
    /RD1046/Project/LXP2/verilog/lxp2_verilog1.sty
    /RD1046/Project/ecp5/ecp5_verilog1.sty
    /RD1046/Project/XO2/verilog/xo2_verilog1.sty		
    /RD1046/Project/XO/verilog/xo_verilog1.sty
						Lattice Diamond Startegy files
    /RD1046/Project/ECP3/vhdl/ecp3_vhdl1.sty
    /RD1046/Project/LXP2/vhdl/lxp2_vhdl1.sty
    /RD1046/Project/ecp5/ecp5_vhdl1.sty
    /RD1046/Project/XO2/vhdl/xo2_vhdl1.sty
   /RD1046/Project/XO/vhdl/xo_vhdl1.sty			*/


 3. /RD1046/Simulation/Verilog/rtl_verilog.do		 --> verilog rtl simulation script 
    /RD1046/Simulation/Verilog/timing_verilog.do	 --> verilog timing simulation script 
    /RD1046/Simulation/Vhdl/rtl_vhdl.do		         --> vhdl rtl simulation script 
    /RD1046/Simulation/Vhdl/timing_vhdl.do		 --> vhdl timing simulation script 

 4. /RD1046/source/verilog/i2c_master_wb_top.v         	--> source file - top level
    /RD1046/source/verilog/i2c_master_byte_ctrl.v      	--> source file
    /RD1046/source/verilog/i2c_master_bit_ctrl.v      		 --> source file
    /RD1046/source/verilog/i2c_master_registers.v     	 --> source file
    /RD1046/source/verilog/i2c_master_defines.v       	 --> source file
    /RD1046/source/verilog/timescale.v                 		--> source file
    /RD1046/source/vhdl/i2c_master_wb_top.vhd          	--> source file - top level
    /RD1046/source/vhdl/i2c_master_byte_ctrl.vhd       	--> source file
    /RD1046/source/vhdl/i2c_master_bit_ctrl.vhd      		  --> source file
    /RD1046/source/vhdl/i2c_master_registers.vhd      	 --> source file
 5. /RD1046/testbench/verilog/tst_bench_top.v         		 --> Testbench for simulation - top-level
    /RD1046/testbench/verilog/i2c_slave_model.v        	--> Testbench for simulation
    /RD1046/testbench/verilog/wb_master_model.v       	--> Testbench for simulation
    /RD1046/testbench/verilog/timescale.v               --> Testbench for simulation
    /RD1046/testbench/verilog/mem_init.txt              --> Memory initialization file for simulation
    /RD1046/testbench/vhdl/tst_bench_top.vhd          	--> Testbench for simulation - top-level
    /RD1046/testbench/vhdl/i2c_slave_model.vhd      	--> Testbench for simulation
    /RD1046/testbench/vhdl/mem_init.txt                 --> Memory initialization file for simulation

===================================================================================================  
!!IMPORTANT NOTES:!!
1. Unzip the RD1046_revyy.y.zip file using the existing folder names, where yy.y is the current
   version of the zip file
2. Must copy the memory file, mem_init.txt, to the local directories for successful simulation
3. If there is lpf file or lct file available for the reference design:
	3.1 copy the content of the provided lpf file to the <project_name>.lpf file under your ispLEVER project, 
	3.2 use Constraint Files >> Add >> Exiting File to import the lpf to Diamond project and set it to be active,
	3.3 copy the content of the provided lct file to the <project_name>.lct under your cpld project.  
4. If there is sty file (strategy file for Diamond) available for the design, go to File List tab on the left 
   side of the GUI. Right click on Strategies >> Add >> Existing File. Then right click on the imported file 
   name and select "Set as Active Strategy".

===================================================================================================  
Using ispLEVER or ispLEVER Classic software
---------------------------------------------------------------------------------------------------
HOW TO CREATE A ISPLEVER OR ISPLEVER CLASSIC PROJECT:
1. Bring up ISPLEVER OR ISPLEVER CLASSIC software, in the GUI, select File >> New Project
2. In the New Project popup, select the Project location, provide a Project name, select Design Entry Type 
   and click Next.
3. Use RD1046.pdf to see which device /speedgrade should be selected to achieve the desired timing result
4. Add the necessary source files from the RD1046\source directory, click Next
5. Click Finish. Now the project is successfully created. 
6. Make sure the provided lpf or lct is used in the current directory. 

---------------------------------------------------------------------------------------------------
HOW TO RUN SIMULATION FROM ISPLEVER OR ISPLEVER CLASSIC PROJECT:
0. Make sure the mem_init.txt is in the same directory as the project file (.syn)
1. Import the top-level testbench into the project as test fixture and associate with the device
	1.1 Import the rest as Testbench Dependency File by highlight and right click on the test bench file
2. In the Project Navigator, highlight the testbench file on the left-side panel, user will see 3 
   simulation options on the right panel.
3. For functional simulation, double click on Verilog (or VHDL) Functional Simulation with Aldec 
   Active-HDL. Aldec simulator will be brought up, click yes to overwrite the existing file. The 
   simulator will initialize and run for 1us.
4. Type "run 1500us" for vhdl or "run -all" for verilog in the Console panel. A script similar to this 
   will be in the Console panel:

       status:                    0 Testbench started

       INFO: WISHBONE MASTER MODEL INSTANTIATED (tst_bench_top.u0)

       status:                 1000 done reset
       status:                13200 programmed registers
       status:                21200 verified registers
       status:                27200 core enabled
       status:                37200 generate 'start', write cmd 20 (slave address+write)
       status:             10339200 tip==0
       status:             10349200 write slave memory address 01
       status:             19427200 tip==0
       status:             19437200 write data a5
       status:             37933200 tip==0
       status:             37943200 write next data 5a, generate 'stop'
       status:             48029200 tip==0
       status:             48039200 generate 'start', write cmd 20 (slave address+write)
       status:             58335200 tip==0
       status:             58345200 write slave address 01
       status:             67423200 tip==0
       status:             67433200 generate 'repeated start', write cmd 21 (slave address+read)
       status:             77723200 tip==0
       status:             77729200 read + ack
       status:             86813200 tip==0
       status:             86819200 received a5
       status:             86825200 read + ack
       status:             95903200 tip==0
       status:             95909200 received 5a
       status:             95915200 read + nack
       status:            104993200 tip==0
       status:            104999200 received 11 from 3rd read address
       status:            105009200 generate 'start', write cmd 20 (slave address+write). Check invalid address
       status:            115299200 tip==0
       status:            115309200 write slave memory address 10
       status:            124387200 tip==0
       status:            124387200 Check for nack
       status:            124393200 generate 'stop'
       status:            124399200 tip==0

       status:            149399200 Testbench done

5. For timing simulation, double click on Verilog (or VHDL) Post-Route Timing Simulation with Aldec 
   Active-HDL. Similar message will be shown in the console panel of the Aldec Active-HDL simulator.
   4.1 Run 1500us to see the complete simulation
   4.1 In timing simulation you may see some warnings about narrow widths or vital glitches. These 
       warnings can be ignored. 
   
===================================================================================================  
Using Diamond Software
---------------------------------------------------------------------------------------------------  
HOW TO CREATE A PROJECT IN DIAMOND:
1. Launch Diamond software, in the GUI, select File >> New Project, click Next
2. In the New Project popup, select the Project location and provide a Project name and implementation 
   name, click Next.
3. Add the necessary source files from the RD1046\source directory, click Next
4. Select the desired part and speedgrade. You may use RD1046.pdf to see which device and speedgrade 
   can be selected to achieve the published timing result 
5. Click Finish. Now the project is successfully created. 
6. MAKE SURE the provided lpf and/or sty files are used in the current directory. 
      
----------------------------------------------------------------------------------------------------      
HOW TO RUN SIMULATION UNDER DIAMOND:
0. Make sure the mem_init.txt is in the same directory as the project file (.ldf)
1. Bring up the Simulation Wizard under the Tools menu 
2. Next provide a name for simulation project, and select RTL or post-route simulation
	2.1 For post-route simulation, must export verilog or vhdl simulation file after Place and Route
3. Next add the test bench files from the RD1046\TestBench directory 
	3.1 For VHDL, make sure the top-level test bench is last to be added
4. Next click Finish, this will bring up the Aldec simulator automatically
5. In Aldec environment, you can manually activate the simulation or you can use a script
	5.1 Use the provided script in the RD1046\Simulation\<language> directory
	  a. For functional simulation, change the library name to the device family
	  	i) MachXO2: ovi_machxo2 for verilog, machxo2 for vhdl
	  	ii) MachXO: ovi_machxo for verilog, machxo for vhdl
	  	iii) XP2: ovi_xp2 for verilog, xp2 for vhdl
	  	iv)  ECP3: ovi_ecp3 for veriog, ecp3 for vhdl
		v) 	ECP5 : ovi_ecp5u for verilog. ecp5u for vhdl 
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
		   -sdfmax i2c_top="./final_xo2/final_xo2_final_xo2_vo.sdf"
		   into the asim or vsim command. Use the command in timing_xxx.do as an example
6. The simulation result will be similar to the one described in ispLEVER simulation section. 

------------------------------------------------------------------------------------------------------------------
HOW TO RUN  SIMULATION IN STAND-ALONE MODE:

RTL SIMULATION 
1. In simulation directory open file RD1046/Simulation/<language>/rtl_<language>.do
2. In rtl_<language>.do set the path to your current simulation directory.
3. Open ALDEC Active HDL simulator in stand-alone mode and click on Tools-->Execute Macro.
4. Select RD1046/Simulation/<language>/rtl_<language>.do.The RTL simulation will commence, if not then recheck the simulation directory path in rtl_<language>.do file.

TIMING SIMULATION 
1. In simulation directory open file RD1046/Simulation/<language>/timing_<language>.do
2. In timing_<language>.do set the path to your current simulation directory.
3. Open ALDEC Active HDL simulator in stand-alone mode and click on Tools-->Execute Macro.
4. Select RD1046/Simulation/<language>/timing_<language>.do.The timing simulation will commence, if not then recheck the simulation directory path in timing_<language>.do file.




   
