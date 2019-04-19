unsigned char floppy_init();
unsigned char read_track(unsigned char *buf, unsigned char track);
unsigned char write_track(unsigned char *buf);

struct sector_info {
	unsigned char track;
	unsigned char side;
	unsigned char id;
	unsigned char size;
	unsigned char FDC_status1;
	unsigned char FDC_status2;
	unsigned char unused[2];
};

struct {
	char label[12];
	char unused[4];
	unsigned char track;
	unsigned char side;
	char unused2[2];
	unsigned char ssize;
	unsigned char nsec;
	unsigned char gap3;
	unsigned char filler;
	struct sector_info sinfo[11];
} track_info;

struct {
	char label[34];
	char creator[14];
	unsigned char ntracks;
	unsigned char sides;
	unsigned short track_size;
	unsigned char unused[204];
} disc_info;
