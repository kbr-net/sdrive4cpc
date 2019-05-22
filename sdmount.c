#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "types.h"
#include "fat.h"
#include "mmc.h"
#include "rsx.h"

unsigned char file_buffer[0x100];
unsigned char mmc_sector_buffer[512];	// one sector
struct GlobalSystemValues GS;
struct FileInfoStruct FileInfo;
virtual_disk_t vDisk;

unsigned short len;
unsigned char *name;
unsigned char *buf;
unsigned char *load;
unsigned char *entry;
unsigned char *vector;

void nosup () {
	__asm
		ld hl,#0
		add hl,sp
		ld e,(hl)	//last return address on stack
		inc hl
		ld d,(hl)
		ex de,hl
		dec hl
		ld b,(hl)	//last call adress
		dec hl
		ld c,(hl)
		ld (_vector),bc
	__endasm;
	printf("vector %p not supported\n\r", vector);
}

void in_open () {
	unsigned char found = 0;
	unsigned short i = 0;
	unsigned long offset = 0;

	__asm
		ld a,b
		ld (_len),a
		ld (_name),hl
		ld (_buf),de
	__endasm;

	while(fatGetDirEntry(i,0)) {
		unsigned char b = 0;
		unsigned char l = len;

		if(FileInfo.Attr & ATTR_DIRECTORY)
			continue;
		while(l) {
			if(file_buffer[b] != toupper(name[b]))
				break;
			b++;
			l--;
		}
		if(l == 0) {	//found?
			found = 1;
			break;
		}
		i++;
	}

	if(!found) {
		printf("%s not found\n\r", name);
		__asm	//clear carry and set zero for err
			ld b,#0b00
			rr b
		__endasm;
		return;
	}

	//load file
	printf("Opening %s", file_buffer);
	FileInfo.vDisk->current_cluster=FileInfo.vDisk->start_cluster;
	FileInfo.vDisk->ncluster=0;
	FileInfo.vDisk->flags=FLAGS_DRIVEON;

	//read
	faccess_offset(FILE_ACCESS_READ,buf,offset,0x800);
	printf("\n\r");

	len = FileInfo.vDisk->size;
	load = (unsigned char *) ((buf[22] << 8) + buf[21]);
	entry = (unsigned char *) ((buf[27] << 8) + buf[26]);

	__asm	//set return registers for ok
		ld hl,(_buf)
		ld de,#0x12	//file type
		add hl,de
		ld a,(hl)	//A

		ld de,(_load)	//DE

		ld hl,(_buf)	//header HL

		//set carry, clear zero for ok
		ld b,#0b11
		rr b
		//the last 1 is in carry, b is 0x01, so zero should be 0

		ld bc,(_len)	//file length BC
	__endasm;
}

void in_close() {
	FileInfo.vDisk->flags = 0;

	__asm
		//set carry, clear zero for ok
		ld b,#0b11
		rr b
	__endasm;
}

void in_direct() {

	__asm
		ld (_buf),hl
	__endasm;

	printf("Loading");
	//read data, skip AMSDOS header(0x80)
	faccess_offset(FILE_ACCESS_READ,buf,0x80,len-0x80);
	printf("\n\r");

	__asm	//set carry, clear zero for ok
		ld b,#0b00000011
		rr b
		//the last 1 is in carry, b is 0x01, so zero should be 0
		ld hl,(_entry)
	__endasm;
}

void cat () {
	unsigned char i = 0;
	unsigned char type;

	printf("length type name\n\r");
	while(fatGetDirEntry(i,1)) {
		type = 'f';
		if(FileInfo.Attr & ATTR_SYSTEM) {
			type = 's';
		}
		else if(FileInfo.Attr & ATTR_HIDDEN) {
			type = 'h';
		}
		else if(FileInfo.Attr & ATTR_DIRECTORY) {
			type = 'd';
		}
		printf("%9lu %c %s\n\r", FileInfo.vDisk->size, type, file_buffer);
		i++;
	}
	__asm	//set carry, clear zero for ok
		ld b,#0b00000011
		rr b
		//the last 1 is in carry, b is 0x01, so zero should be 0
	__endasm;
}


int main () {
	unsigned char r;
	FileInfo.vDisk = &vDisk;

	printf("SDrive-RSX for CPC V0.1 (c) 2019 by KBr\r\n\n");

	mmcInit();
	r = mmcReset();
	if (r) {
		//set pointers to debug values
		long *v1 = (long*) &mmc_sector_buffer[0];
		long *v2 = (long*) &mmc_sector_buffer[4];

		printf("error %i mmc_reset\n\r", r);
		//extract and join the values
		printf("%08lx %08lx\n\r", *v1, *v2);
	}
	else {
		r = fatInit();
		if (r) {
			printf("error %i fat_init\n\r", r);
		}
	}

	//init RSX
	rsx_init();

	printf("RSX installed, type |sd to switch\n\r");

	return(0);
}
