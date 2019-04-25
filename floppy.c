#include <stdio.h>
#include "floppy.h"

struct s_list sl[9];
unsigned char buf[7];

__sfr __banked __at 0xfa7e fdc_motor;
__sfr __banked __at 0xfb7f fdc_data;
__sfr __banked __at 0xfb7e fdc_status;

//fdc commands
#define FDC_READ	0x06
#define FDC_READ_ID	0x0a
#define FDC_SEEK	0x0f
#define FDC_SENSE_INT	0x08
#define MF	0x40	//mfm command flag
#define SE	0x20	//seek end in S0
#define IC	0x40	//seek error in S0

//main status register flags
#define RQM	0x80	//request for master
#define BUSY	0x0f	//busy flags(4 drives)
#define EXM	0x20	//in execution phase

			      // HU  TR  HD  SC  SZ  LS  GP  SL
const unsigned char param[] = "\x00\x00\x00\x00\x02\x00\x2a\xff";

void sleep(unsigned char s) {	//seconds
	unsigned char i;
	unsigned int wait;

	s <<= 1;	//x2
	//one loop is about 0.5s
	for(i = 0; i < s; i++) {
		for(wait = 0; wait < 0xffff; wait++);
	}

}
void fdc_send_byte (unsigned char b) {
	//wait ready
	while(!(fdc_status & RQM));
	fdc_data = b;
}

unsigned char fdc_read_byte () {
	//wait ready
	while(!(fdc_status & RQM));
	return(fdc_data);
}

unsigned char seek(unsigned char track) {
	unsigned char S0;
	unsigned char TR;

	//send command seek
	fdc_send_byte(FDC_SEEK);
	fdc_send_byte(0x00);	//head, unit
	fdc_send_byte(track);	//track
	//wait seek
	for(;;) {
		fdc_send_byte(FDC_SENSE_INT);
		//read result
		S0 = fdc_read_byte();
		TR = fdc_read_byte();
#ifdef DEBUG
		printf("%02x %02x\r\n", S0, TR);
#endif
		if(S0 & SE)
			break;
	}
	if(S0 & IC) {
		printf("seek error: %02x\r\n", S0);
		return(1);
	}
	return(0);
}

struct s_list * get_sector_info (unsigned char track) {
	unsigned char sec;
	unsigned short i;
	unsigned char *bp = buf;

	fdc_motor = 1;
	sleep(1);		//wait 1s motor spin-up

	//send command seek
	if (seek(track))
		return(0);

	//send command read with an illegal sector-id(0)
	//to get returned after index hole for start positioning
	fdc_send_byte(FDC_READ | MF);
	//send parameters
	for(i = 0; i < 8; i++) {
		fdc_send_byte(param[i]);
	}
	//read result
	for(i = 0; i < 7; i++) {
		*bp++ = fdc_read_byte();
	}

	//read sector id's
	bp = (unsigned char *) &sl;
	for(sec = 0; sec < 9; sec++) {
		//send command read-id
		fdc_send_byte(FDC_READ_ID | MF);
		//send parameter
		fdc_send_byte(0x00);	//head, unit
		//wait execution
		while(fdc_status & EXM);
		//read result
		for(i = 0; i < 7; i++) {
			*bp++ = fdc_read_byte();
		}
	}

	fdc_motor = 0;
	return(sl);
}
