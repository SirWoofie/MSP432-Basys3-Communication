# MSP432-Basys3-Communication
Implement a bus-based communications protocol between an MSP432 and Basys-3 to compute values on a hardware ALU. The MSP432 provides a terminal interface to enter values and view results.

## Equipment used:
TI MSP432 P401R Launchpad Development Kit

Digilent Basys-3 featuring Xilinx Artix-7 FPGA (XC7A35T-1CPG236C)

Dupont Wires

## Software used:
TI Code Composer Studio (CCS) 11.2.0

Vivado 2023.2

## Software Demo
https://youtu.be/hbpixFBOUNE

## Hardware Setup:
![MSP432 and Basys-3 Communications Image](https://github.com/SirWoofie/MSP432-Basys3-Communication/assets/15528008/4180508e-b0ba-456d-b556-6867fe075ea9)

## Connection Guide:
|Address Bus		||    Output Bus		 ||   Input Bus		   ||   Special Command Wires||	
|---|---|---|---|---|---|---|---|
|MSP432	|Basys-3	  |MSP432	|Basys-3	  |MSP432	|Basys-3	  |MSP432	|Basys-3|
|P2.3	|  JB1	  |    P4.0	 | JC1	 |     P5.0	 | JA1	  |    P3.5	| JB8|
|P2.4	|  JB2	 |     P4.1	|  JC2	  |    P5.1	 | JA2	  |    P3.6	 | JB9|
|P2.5	|  JB3	 |     P4.2	|  JC3	 |     P5.2	 | JA3	  |    P3.7	 | JB10|
|P2.6	|  JB4	 |     P4.3	|  JC4	|      P5.3	|  JA4		||
|P2.7	|  JB7	 |     P4.4	|  JC7	 |     P5.4	|  JA7		||
|		 |        |     P4.5	|  JC8	 |     P5.5	|  JA8		||
|		 |        |     P4.6	|  JC9	 |     P5.6	|  JA9		||
|		|         |     P4.7	|  JC10	 |   P5.7	|  JA10		||

## How to use:
### Part 1: Basys-3 FPGA Board
1.	Open Vivado
2.	Create a new project.
    -	Import or create new files for
        - Sources
        - Simulation
        - Constraints
3.	Create code and/or modify imported code as needed.
4.	Run Synthesis, Implementation, and Generate Bitstream
5.	Open Hardware Manager
    - Plug in the Basys-3 board to your computer.
    - Select “Auto Connect”
    - Program the Basys-3 board.

### Part 2: MSP432 Microprocessor Board
1.	Open TI Code Composer Studio
2.	Create a new project.
    - Import or create new files for
        - main.c
3.	Create code and/or modify imported code as needed.
4.	Run the code.
    - Plug in the MSP432 board to your computer.
    - CCS will automatically connect to the board.
    - Choose “Debug” to program the device.
    - Click “Run” or press F5 to run the program once the device has been programmed.

### Part 3: Assembling the System
1.	Ensure that both the MSP432 and Basys-3 are unplugged and unpowered.
    - Note: If you are using different boards than the ones selected in this report, please note that both the MSP432 and Basys-3 boards selected operate at 3.3V logic levels. They do not support 5V logic. Connecting a 5V logic device to either of these boards may damage them. If you need to connect a 5V logic device with a 3.3V logic device, consider not connecting them or utilizing a logic level converter between the two devices.
2.	Follow the connection guide found above.
3.	Connect both boards to a power source and common ground.
    - Note: If using two USB ports from the same computer, you may not need to connect both devices’ GND on their own. The USB ports on a computer likely already have a common ground. This is necessary for accurate communication between the two devices.
4.	Run the program on the MSP432.
    - Use CCS to open a debug terminal when running the program to interact with it.
    - Follow the instructions in the terminal from the program:
        - Enter the first value.
        - Enter the second value.
        - Select the operation from the list by entering in the associated number.
    - The program will then output the FPGA’s response and output the response it expects.
    - After that, it will complete its loop and run again.
