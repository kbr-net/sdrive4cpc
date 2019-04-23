struct s_list * get_sector_info(unsigned char track);

struct s_list {
	unsigned char stat0;
	unsigned char stat1;
	unsigned char stat2;
	unsigned char track;
	unsigned char head;
	unsigned char id;
	unsigned char size;
};
