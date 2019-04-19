#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cpc.h"
#include "types.h"
#include "fat.h"
#include "mmc.h"
#include "floppy.h"

unsigned char file_buffer[11*0x200];
unsigned char mmc_sector_buffer[512];	// one sector
char linebuf[40];
struct GlobalSystemValues GS;
struct FileInfoStruct FileInfo;
virtual_disk_t vDisk;

unsigned char * getline() {
	unsigned char i = 0;
	unsigned char c = 0;

	while(c != '\r') {
		c = getchar();
		putchar(c);		//echo
		linebuf[i] = c;
		i++;
		if (i > sizeof(linebuf))	//buffer full?
			break;
	}
	i--;
	linebuf[i] = 0;		//mark end
	return(linebuf);
}

int main () {
	unsigned char r;
	FileInfo.vDisk = &vDisk;

	if(!floppy_init()) {
		printf("error floppy init\r\n");
		return(1);
	}
	//init structs
	memcpy(disc_info.label, "MV - CPCEMU Disk-File\r\nDisk-Info\r\n", sizeof(disc_info.label));
	memcpy(disc_info.creator, "sdrive4cpc\r\n", 12);
	memcpy(track_info.label, "Track-Info\r\n", sizeof(track_info.label));

	printf("SDrive for CPC --- (c) 2019 by KBr\r\n");	

reset:
	mmcInit();
	r = mmcReset();
	if (r) {
		//set pointers to debug values
		long *v1 = (long*) &mmc_sector_buffer[0];
		long *v2 = (long*) &mmc_sector_buffer[4];

		printf("error %i mmc_reset\r\n", r);
		//extract and join the values
		printf("%08lx %08lx\r\n", *v1, *v2);
	}
	else {
		r = fatInit();
		if (r) {
			printf("error %i fat_init\r\n", r);
		}
	}

	while(1) {	//mainloop
		unsigned char c,tracks;
		unsigned short i;
		unsigned char type;
		unsigned long offset;

		printf("\r\n[i] - (re)init SD Card\r\n[d] - directory\r\n[c] - change directory\r\n[w] - write image to disc    [r] - read image from disc\r\n[q] - quit\r\n\r\n# ");
		c = getchar();
		printf("%c\r\n",c);
		switch(c) {
			case 'i':
				goto reset;
			case 'd':
				printf("idx   length type name\r\n");
				i = 0;
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
					printf("%3u %9lu %c %s\r\n", i, FileInfo.vDisk->size, type, file_buffer);
					i++;
					if(i % 10 == 0) {
						printf("more?/[a]bort\r\n");
						c = getchar();
						if(c == 'a')
							break;
					}
				}
				break;
			case 'c':
				printf("dir index: ");
				getline();
				if(!fatGetDirEntry(atoi(linebuf),1) || !(FileInfo.Attr & ATTR_DIRECTORY))	//set values for dir
					break;
				FileInfo.vDisk->dir_cluster=FileInfo.vDisk->start_cluster;
				break;
			case 'r':
				printf("file name: ");
				getline();
				if(!fatFileNew(linebuf, 40*(9*0x200+0x100UL)+0x100))
					break;
				FileInfo.vDisk->current_cluster=FileInfo.vDisk->start_cluster;
				FileInfo.vDisk->ncluster=0;
				FileInfo.vDisk->flags=FLAGS_DRIVEON;

				offset = 0;
				//DSK header
				disc_info.ntracks = 40;
				disc_info.sides = 1;
				disc_info.track_size = 9*0x200+0x100;
				//copy to buffer
				memcpy(file_buffer, &disc_info, sizeof(disc_info));
				//write to image
				faccess_offset(FILE_ACCESS_WRITE,offset,0x100);
				offset += 0x100;
				for(i = 0; i < 40; i++) {
					unsigned char s;

					printf("Reading track %02u\r\n", i);
					if(!read_track(file_buffer, i))
						break;
					//add track header
					track_info.track = i;
					track_info.side = 0;
					track_info.ssize = 2;
					track_info.nsec = 9;
					track_info.gap3 = 0x4e;
					track_info.filler = 0xe5;
					for(s = 0; s < 9; s++) {
						track_info.sinfo[s].track = i;
						track_info.sinfo[s].side = 0;
						track_info.sinfo[s].id = s+0x41;
						track_info.sinfo[s].size = 2;
						//track_info.sinfo[s].gap = 2;
					}
					memcpy(file_buffer, &track_info, sizeof(track_info));
#ifdef DEBUG
					printf("Writing at 0x%05lx\r\n", offset);
#else
					printf("Writing at 0x%05lx", offset);
#endif
					faccess_offset(FILE_ACCESS_WRITE,offset,disc_info.track_size);
					printf("\r\n");
					if(readchar())
						break;
					offset += disc_info.track_size;
				}
				break;
			case 'w':
				printf("file index: ");
				getline();
				fatGetDirEntry(atoi(linebuf),1);	//set values for file
				printf("\nLoading %s...\r\n", file_buffer);
				FileInfo.vDisk->current_cluster=FileInfo.vDisk->start_cluster;
				FileInfo.vDisk->ncluster=0;
				FileInfo.vDisk->flags=FLAGS_DRIVEON;

				//read the DSK header
				offset = 0;
				faccess_offset(FILE_ACCESS_READ,offset,0x100);
				tracks = file_buffer[0x30];	//save nr. of tracks
				if(tracks < 39 || tracks > 43) {
					printf("%u tracks looks not like DSK!\r\n", tracks);
					break;
				}

				//read tracks
				offset += 0x100;
				for(;;) {
#ifdef DEBUG
					printf("Reading at 0x%05lx\r\n", offset);
#else
					printf("Reading at 0x%05lx", offset);
#endif
					if(!faccess_offset(FILE_ACCESS_READ,offset,11*0x200))
						break;
					printf("\r\nWriting track %02u\r\n", file_buffer[0x18]);
					if(!write_track(file_buffer)) {
						printf("error writing track\r\n");
						break;
					}
					if(readchar())
						break;
					offset += file_buffer[0x15]*0x200+0x100;
				}
				break;
			case 'q':
				return(0);
			default:
				printf("unknown command\r\n");
		}
	}
}
