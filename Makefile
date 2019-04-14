#CC=sdcc
CC=/media/soft/historic/cpc/cross/sdcc/bin/sdcc
#AS=sdasz80
AS=/media/soft/historic/cpc/cross/sdcc/bin/sdasz80

CCFLAGS=-mz80#-DDEBUG
LDFLAGS=--code-loc 0x120 --data-loc 0 --no-std-crt0

TARGET=sdrive

OBJS=	crt0.rel stdio.rel fat.rel spi.rel mmc.rel floppy.rel main.rel

all:	$(OBJS) $(TARGET).hex $(TARGET).bin $(TARGET).dsk $(TARGET).cdt

$(TARGET).hex: $(OBJS)
	$(CC) $(CCFLAGS) $(LDFLAGS) -o $@ $(OBJS)

$(TARGET).bin: $(TARGET).hex
	sdobjcopy -I ihex -O binary $(TARGET).hex $@
	/media/soft/historic/cpc/cross/hideur_maikeur-master/hideur $@ -o $@ -t 2 -x "&100" -l "&100"

$(TARGET).dsk:	$(TARGET).bin
	/media/soft/historic/cpc/cross/cpcxfs/cpcxfs -f -nd $@ -p $(TARGET).bin

$(TARGET).cdt:	$(TARGET).bin
	/media/soft/historic/cpc/cross/2cdt/2cdt -n -r $(TARGET) $(TARGET).bin $@

%.rel:	%.s
	$(AS) -o $<

%.rel:	%.c
	$(CC) $(CCFLAGS) -c $<

clean:
	rm *.rel *.sym *.lk *.map *.noi *.asm *.lst $(TARGET).hex $(TARGET).bin $(TARGET).dsk $(TARGET).cdt
