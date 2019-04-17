/*! \file spi.c \brief SPI interface driver. */
//*****************************************************************************
//
// File Name	: 'spi.c'
// Title		: SPI interface driver
// Author		: Pascal Stang - Copyright (C) 2000-2002
// Created		: 11/22/2000
// Revised		: 06/06/2002
// Version		: 0.6
// Target MCU	: Atmel AVR series
// Editor Tabs	: 4
//
// NOTE: This code is currently below version 1.0, and therefore is considered
// to be lacking in some functionality or documentation, or may not be fully
// tested.  Nonetheless, you can expect most functions to work.
//
// ----------------------------------------------------------------------------
// 17.8.2008
// Bob!k & Raster, C.P.U.
// Original code was modified especially for the SDrive device. 
// Some parts of code have been added, removed, rewrited or optimized due to
// lack of MCU AVR Atmega8 memory.
// ----------------------------------------------------------------------------
// 19.05.2014
// enhanced by kbr
// ----------------------------------------------------------------------------
// 05.04.2019
// ported to cpc zx80 parallel port by kbr
// ----------------------------------------------------------------------------
//
// This code is distributed under the GNU Public License
//		which can be found at http://www.gnu.org/licenses/gpl.txt
//
//*****************************************************************************

#include "types.h"
#include "spi.h"

#define	SCK	0b00000001
#define	MOSI	0b00000010
#define	SS	0b00000100
#define	MISO	0b01000000

__sfr __banked __at 0xef00 SPI_PORT_OUT;
__sfr __banked __at 0xf500 SPI_PORT_IN;

unsigned char portval;

void spiSetCS () {
	portval &= ~SS;	//set chip select
	SPI_PORT_OUT = portval;
}

void spiResetCS () {
	portval |= SS;	//reset chip select
	SPI_PORT_OUT = portval;
}

// access routines
void spiInit()
{
	//save the port value in a global, because the parallel port latch
	//can only be written!!!
	portval = MOSI | SS;	//init with MOSI and SS high for inactiv
	SPI_PORT_OUT = portval;
}

u08 spiTransferByte(u08 data)
{
	__asm
		;;;get value from stack
		ld hl,#2
		add hl,sp
		ld a,(hl)
		ld c,a		;save it in c
		ld b,#>_SPI_PORT_OUT	;set out port
		ld d,#8		;bitcounter
		ld l,#0		;input value to return
	loop:
		xor a		;clear all bits
		;;;process data bit
		rl c		;shift last(msb first!) bit into carry
		jr nc,zero
		ld a,#MOSI	;set MOSI
		;;;clock bit
	zero:	or #SCK		;add clock high
		ld e,a
		ld a,(_portval)	;load old port value
		and #~MOSI	;clear old data value
		or e		;add new value
		out (c),a	;value of c does not matter here, only msb byte in b!

		;;;input bit
		ld a,#>_SPI_PORT_IN
		in a,(<_SPI_PORT_IN)
		neg		;invert it due to hardware inverter
		rla		;we need bit 6, so
		rla		;shift it 2 times into carry
		rl l		;and shift carry into l

		;;;clock low
		ld a,(_portval)
		and #~SCK
		out (c),a	;value of c does not matter here, only msb byte in b!

		dec d
		jr nz,loop	;next bit
				;l was returned
	__endasm;
}

u08 spiTransferFF()
{
	return spiTransferByte(0xFF);
}

