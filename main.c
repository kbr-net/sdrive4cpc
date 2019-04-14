#include <stdio.h>
#include <stdlib.h>
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

int main () {
	unsigned char r;
	FileInfo.vDisk = &vDisk;

	if(!floppy_init()) {
		printf("error floppy init\r\n");
		return(1);
	}
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
		unsigned long offset;

		printf("\r\n[i] - (re)init SD Card\r\n[d] - directory\r\n[w] - write image to disc\r\n[q] - quit\r\n\r\n# ");
		c = getchar();
		printf("%c\r\n",c);
		switch(c) {
			case 'i':
				goto reset;
			case 'd':
				i = 0;
				while(fatGetDirEntry(i,1)) {
					printf("%02u %s\t%lu\r\n", i, file_buffer, FileInfo.vDisk->size);
					i++;
				}
				break;
			case 'w':
				printf("file index: ");
				i = 0;
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
					printf("Reading at 0x%05lx\r\n", offset);
					if(!faccess_offset(FILE_ACCESS_READ,offset,11*0x200))
						break;
					printf("Writing track %02u\r\n", file_buffer[0x18]);
					if(!write_track(file_buffer)) {
						printf("error writing track\r\n");
						break;
					}
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
