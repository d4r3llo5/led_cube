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
	LDI r16, ( 1 << PCINT13 );		Enable the interrupt for pin 28 (PCINT13)
	STS PCMSK1, r16;
	
									; Set the I/O Pins for PCINT[14:8]
SET_IO_PINS:
	CLR r16;
	LDI r16, 0x1F;					Set PinC[4:0] as output, PinC5 as input
	OUT DDRC, r16;					

	CLR r16;
	LDI r16, ( 1 << PORTC5 );		Enable the internal pull-up resistor for PinC5
	OUT PORTC, r16;

	SEI;							Enable Interrupts

									; Do nothing forever
LOOP:
	RJMP LOOP;

									; Turn on the lights
PCI1_INT:
	CLI;							Disable interrupts

	CLR r16;
	CLR r17;						Mask for reading PinC5

	LDI r17, 0x20;					Set it to only be the 6th pin in PCINT[14:8]
	IN r16, PINC;					Read in the PinC Register

	ANDI r16, 0x20;			MASK off what we don't care about

	CPI r16, 0x20;					If PinC5 is high
	BREQ SET_HIGH;					Turn on all of the lights

SET_LOW:
	RJMP END_PCI1_INT;				Go to the end

SET_HIGH:
	ORI r17, 0x1F;					Turn on all of the lights
	
END_PCI1_INT:
	OUT PORTC, r17;
	SEI;							Enable interrupts again
	RETI;