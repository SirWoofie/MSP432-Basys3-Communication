#include "msp.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/*
    new! Port Map:
    P2.3 to P2.7: Address Bus to FPGA | Connects to JB (0 to 4)
    P4.0 to P4.7: Output Bus to FPGA | Connects to JC (0 to 7)
    P5.0 to P5.7: Input Bus from FPGA | Connects to JA (0 to 7)

    P3.5 to P3.7: Special Command Wires | Connects to JB (5 to 7)
        P3.7: FPGA: data_send
        P3.6: FPGA: input_or_output
        P3.5: FPGA: data_load

    Sorry in advance if you try to replicate the hardware setup. There are 24 wires running between the MSP432 and Basys-3.
    Don't forget to tie together the GND for both devices if you are not using a common ground (an example of a common ground might be two USB ports on the same computer)
*/

//List of operations (unused)
#define uAddition 0b00000
#define sAddition 0b00001
#define uSubtraction 0b00010
#define sSubtraction 0b00011
#define uMultiplication 0b00100
#define sMultiplication 0b00101
#define uDivision 0b00110
#define sDivision 0b00111
#define EqualTo 0b11110

//Function definitions

void P2Input(void); // Address Bus
void P3Input(void); // Special Command Bus
void P4Input(void); // Output Bus
void P5Input(void); // Input Bus

void P2Output(void);
void P3Output(void);
void P4Output(void);
void P5Output(void);

void CmdSet(uint8_t n); //P3.(n+(2^5)) set (output)
void CmdReset(uint8_t n); //P3.(n+(2^5)) reset (input)

void AddrSet(uint8_t n); //P2.n set (output address)
void AddrReset(uint8_t n); //P2.n reset (clear address)

void DataSet(uint8_t n); //P4 = n

uint8_t DataRead(); //return P5

void DataSend(int data, uint8_t which); //Send a packet of data to an address

void delayus(int n); //Wait for n microseconds (unused)

void delayms(int n); //Wait for n milliseconds (unused)

void main(void)
 {
	WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD;		// stop watchdog timer

	//Encase this program in a while loop
	while(1) {

	//Initialize the ports
	P2Output(); //Address Output
	P3Output(); //Special Command Output
	P4Output(); //Output output
	P5Input(); //Input input

	//Create placeholder values
	int value1 = 81245;
	int value2 = 52;
	uint8_t opcode;

	//User input
	printf("Enter value 1: ");
	scanf("%d", &value1);

	printf("\nEnter value 2: ");
	scanf("%d", &value2);

	printf("\nList of operations: \nunsigned     Addition        0\nsigned       Addition        1\nunsigned     Subtraction     2\nsigned       Subtraction     3\nunsigned     Multiplication  4\nsigned       Multiplication  5\nunsigned     Division        6\nsigned       Division        7\n             EqualTo         30");

	printf("\nEnter the operation code: ");
	scanf("%d", &opcode);
//	printf("\nEntered: %d\n", opcode);

	//Send first value
	DataSend(value1, 0);
	//Send second value
	DataSend(value2, 1);

	//Tell ALU to do the entered operation
	AddrSet(opcode);
	//Enable ALU
	CmdSet(2); //Set P3.6 HIGH (input_or_output = '1')

	//Read result - BIG NOTE: The FPGA responds so quickly to my changes so I need to leave the data bus configured while I read the result!
	CmdReset(2); //Set P3.6 LOW (input_or_output = '0')
	CmdSet(4); //Set P3.7 HIGH (data_send = '1')

	int result[4]; //Results buffer
	//Read first byte
	uint8_t addr = 0b10001;
	uint8_t x;
	for (x=0; x < 4; x++) {
	    AddrSet(addr);
	    result[x] = DataRead();
	    addr = addr + 1;
	}

	int comboResult = result[3]<<24 | result[2]<<16 | result[1]<<8 | result[0];

	printf("Result: %x %x %x %x\n", result[3], result[2], result[1], result[0]);
	printf("Combined: %d\n", comboResult);

	//Determine what the actual value should be based on the inputted opcode
	int actual;
	switch (opcode) {
	case 0:
	        actual = value1 + value2;
	        break;
	case 1:
	        actual = value1 + value2;
	        break;
	case 2:
	        actual = value1 - value2;
	        break;
	case 3:
	        actual = value1 - value2;
	        break;
	case 4:
	        actual = value1 * value2;
	        break;
	case 5:
	        actual = value1 * value2;
	        break;
	case 6:
	        actual = value1 / value2;
	        break;
	case 7:
	        actual = value1 / value2;
	        break;
	case 30:
	        actual = value1 == value2;
	        break;
	default:
	        actual = value1 + value2;
	        break;
	}

	printf("Should be: %d\n\nProgram complete! Looping...\n", actual);
	} //End of while loop

}

//Address Bus
void P2Input(void) {
    //Port 2 as Input 0b1111 1000 = 0xF8
    P2SEL0 &= ~0xF8; //GPIO
    P2SEL1 &= ~0xF8;
    P2DIR &= ~0xF8; //Input
    P2REN |= 0xF8; //Resistor enabled
    P2OUT &= ~0xF8; //Pulldown resistor enabled
}

void P2Output(void) {
    //Port 2 as Output
    P2SEL0 &= ~0xF8; //GPIO
    P2SEL1 &= ~0xF8;
    P2DIR |= 0xF8; //Output
}

//Special Command Wires
void P3Input(void) {
    //Port 3 as Input 0b1110 0000 = 0xE0
    P3SEL0 &= ~0xE0; //GPIO
    P3SEL1 &= ~0xE0;
    P3DIR &= ~0xE0; //Input
    P3REN |= 0xE0; //Resistor enabled
    P3OUT &= ~0xE0; //Pulldown resistor enabled
}

void P3Output(void) {
    //Port 3 as Output
    P3SEL0 &= ~0xE0; //GPIO
    P3SEL1 &= ~0xE0;
    P3DIR |= 0xE0; //Output
}

//Output Bus
void P4Input(void) {
    //Port 4 as Input 0b1111 1111 = 0xFF
    P4SEL0 &= ~0xFF; //GPIO
    P4SEL1 &= ~0xFF;
    P4DIR &= ~0xFF; //Input
    P4REN |= 0xFF; //Resistor enabled
    P4OUT &= ~0xFF; //Pull-down resistor enabled
}

void P4Output(void) {
    //Port 4 as Output
    P4SEL0 &= ~0xFF; //GPIO
    P4SEL1 &= ~0xFF;
    P4DIR |= 0xFF; //Output
}

//Input Bus
void P5Input(void) {
    //Port 5 as Input 0b1111 1111 = 0xFF
    P5SEL0 &= ~0xFF; //GPIO
    P5SEL1 &= ~0xFF;
    P5DIR &= ~0xFF; //Input
    P5REN |= 0xFF; //Resistor enabled
    P5OUT &= ~0xFF; //Pull-down resistor enabled
}

void P5Output(void) {
    //Port 5 as Output
    P5SEL0 &= ~0xFF; //GPIO
    P5SEL1 &= ~0xFF;
    P5DIR |= 0xFF; //Output
}

void CmdSet(uint8_t n) {
    P3OUT |= (n << 5); //Set HIGH: 10 << 5 = 0b0100 0000
}
void CmdReset(uint8_t n) {
    P3OUT &= ~(n << 5); //Set LOW
}

//Set the address to a value
void AddrSet(uint8_t n) {
    uint8_t hold;
    hold = P2OUT & 0b00000111;
    P2OUT = ((n) << 3); //Overwrite P2OUT with new 5-bit address
    //P2.0 - P2.2 were reset already, so only need to set the 1s
    P2OUT |= hold;

}
//Zero out the address
void AddrReset(uint8_t n) {
    uint8_t hold;
    hold = P2OUT & 0b00000111;
    P2OUT &= ~(n << 3); //Reset P2OUT to zero
    //P2.0 - P2.2 were reset already, so only need to set the 1s
    P2OUT |= hold;
}

//Output data on P4
void DataSet(uint8_t n) {
    P4OUT = n;
}

//Input data on P5
uint8_t DataRead() {
    return P5IN;
}

//Send a packet of data with an address
void DataSend(int data,  uint8_t which) {
    //"which" chooses either first or second int to send
    uint8_t value;
    uint8_t x;
    uint8_t addr;
    uint8_t prevAddr = P2IN;
    CmdSet(1); //Set P3.5 HIGH (data_load = '1')
    if (which) {
        //Send data2
        addr = 0b00101;
        for (x=0; x < 4; x++) {
            AddrSet(addr);
            value = ((data >> (x * 8)) & 0xFF);
            DataSet(value);
            addr = addr + 1;

        }
    } else {
        //Send data1
        addr = 0b00001;
        for (x=0; x < 4; x++) {
            AddrSet(addr);
            value =  ((data >> (x*8)) & 0xFF);
            DataSet(value);
            addr = addr + 1;
//            printf("%d: %d ", x, value);
        }
    }
    P2IN = prevAddr;
    CmdReset(1); //Set P3.5 LOW (data_load = '0')
//    printf("Data %d sent\n", which);
}

void delayus(int n) {
    int i;
    SysTick->LOAD = 3-1; //1 second delay.
    SysTick->VAL = 0;
    SysTick->CTRL = 0x5;

    for (i=0; i < n; i++) {
    while((SysTick->CTRL & 0x10000) == 0) {}
    }
    SysTick->CTRL = 0;
}

void delayms(int n) {
    int i;
    SysTick->LOAD = 3000-1; //1 second delay.
    SysTick->VAL = 0;
    SysTick->CTRL = 0x5;

    for (i=0; i < n; i++) {
    while((SysTick->CTRL & 0x10000) == 0) {}
    }
    SysTick->CTRL = 0;
}
