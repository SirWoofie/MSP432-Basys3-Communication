# MSP432-Basys3-Communication
Implement a bus-based communications protocol between an MSP432 and Basys-3 to compute values on a hardware ALU. The MSP432 provides a terminal interface to enter values and view results.

## Equipment used:
TI MSP432 P401R Launchpad Development Kit

Digilent Basys-3 featuring Xilinx Artix-7 FPGA (XC7A35T-1CPG236C)

Dupont Wires

## Software used:
TI Code Composer Studio (CCS)

Vivado 2023.2

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
