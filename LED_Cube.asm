/*
 * LED_Cube.asm
 *
 *  Created: 10/16/2013 6:15:25 PM
 *   Author: tjbell
 */ 


.include "m328pdef.inc"

.org $0000
	RJMP RESET;						Reset vector for the program

.org PCI1addr
	RJMP PCI1_INT;

RESET:
	LDI r16, low(RAMEND);			Create the STACK
	OUT SPL, r16;
	LDI r16, high(RAMEND);
	OUT SPH, r16;

SET_INTERRUPT:
	CLI r16;						Set the interrupt flag for the PCI
	LDI r16, ( 1 << PCIE1 );		Interrupt Register
	OUT PCICR, r16;					SHIP IT

	CLI r16;
	LDI r16, ( 1 << PCIFR1 );		Enable the interrupt for the PCI
	OUT PCIFR, r16;					PCINT[14:8]

	

LOOP:
	RJMP LOOP;

PCI1_INT:
	RETI;