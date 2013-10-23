/*
 * LED_Cube.asm
 *
 *  Created: 10/16/2013 6:15:25 PM
 *   Author: tjbell
 */ 


.include "m328pdef.inc"

.org $0000
	RJMP RESET;						Reset vector for the program

									; Interrupt handler for PCI1
.org PCI1addr
	RJMP PCI1_INT;					Go to this label for interrupt handler

									; What is run on start up
RESET:
	CLI;							Disable interrupts
	LDI r16, low(RAMEND);			Create the STACK
	OUT SPL, r16;
	LDI r16, high(RAMEND);
	OUT SPH, r16;

									; Enable the interrupt for PCINT[14:8]
SET_INTERRUPT:
	CLR r16;						Set the interrupt flag for PCI1
	LDI r16, ( 1 << PCIE1 );		PCIE1 enabled, the rest disabled
	STS PCICR, r16;

	CLR r16;
	LDI r16, ( 1 << PCINT13 ) | ( 1 << PCINT12 ) | ( 1 << PCINT11 ) | ( 1 << PCINT10 ) | ( 1 << PCINT9 );		Enable the interrupt for pin 28 (PCINT13)
	STS PCMSK1, r16;
	
									; Set the I/O Pins for PCINT[14:8] and PCINT[23:16]
SET_IO_PINS:
	CLR r16;
	LDI r16, 0x01;					Set PinC[0] as output, PinC[5:1] as input
	OUT DDRC, r16;

	CLR r16;
	LDI r16, 0xFF;					Set PinD[7:0] as output
	OUT DDRD, r16;

	CLR r16;
	LDI r16, 0x3E;		Enable the internal pull-up resistor for PinC5
	OUT PORTC, r16;

									; Turn off all outputs by default
	CLR r16;
	LDI r16, 0x00;
	OUT PORTD, r16;

	SEI;							Enable Interrupts

									; Do nothing forever
LOOP:
	RJMP LOOP;

									; Turn on the lights
PCI1_INT:
	CLI;							Disable interrupts

	CLR r16;
	CLR r17;
	CLR r18;

	IN r16, PINC;					Read in the PinC Register

	ANDI r16, 0x3E;					MASK off what we don't care about

SET_LEDS:
	OR r17, r16;
	LSR r17;						; Shift to send to the PortD [4:0]
	LSR r17;						; Shift to send to the PortD [4:0]
	OUT PORTD, r17;

									; Check to see if we should enable on the ground
	CLR r17;
	OR r17, r16;					; Use r17 as the input of PinC[5:1]
	ANDI r17, 0x02;					; Only read PinC[1]
	CPI r17, 0x02;					If PinC[1] is high
	BREQ SET_GROUND_HIGH;			Do not enable ground

SET_GROUND_LOW:
	CLR r17;
	ORI r17, 0x3E;					Turn on ground
	OUT PORTC, r17;
	RJMP END_PCI1_INT;

SET_GROUND_HIGH:
	CLR r17;
	ORI r17, 0x3F;					Enable the ground connection
	OUT PORTC, r17;

END_PCI1_INT:
	SEI;							Enable interrupts again
	RETI;