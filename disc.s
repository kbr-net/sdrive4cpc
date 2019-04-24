;amsdos disc functions, dsk image, track read/write (c) 2019 by KBr

	.module disc
	.globl sec_tbl
	.globl trk_hdr
	.globl sec_buf

driveno	=	0

	.area _DATA

	;; storage
sec_tbl:	.ds	4 * 12
trk_hdr:	.ds	2
sec_buf:	.ds	2

	;; this is initialised when the "BIOS: *" RSX has been found.
commands_store:		;; must be in order with command!!!
bios_select_format:
	.dw 0		;; address of function
	.db 0		;; "rom select" for function

bios_read_sector:
	.dw 0		;; address of function
	.db 0		;; "rom select" for function

bios_write_sector:
	.dw 0		;; address of function
	.db 0		;; "rom select" for function

bios_format_track:
	.dw 0		;; address of function
	.db 0		;; "rom select" for function

	.area _INITIALIZED
commands:
cmd_bios_select_format:
	.db 3+0x80	;; this is the "BIOS: SELECT FORMAT" RSX

cmd_bios_read_sector:
	.db 4+0x80	;; this is the "BIOS: READ SECTOR" RSX

cmd_bios_write_sector:
	.db 5+0x80	;; this is the "BIOS: WRITE SECTOR" RSX

cmd_bios_format_track:
	.db 6+0x80	;; this is the "BIOS: FORMAT TRACK" RSX
nocommands:

	.area _CODE

;; firmware function to find a RSX
kl_rom_walk	=	0xbccb
kl_find_command	=	0xbcd4

_disc_init::
	;;;init roms - needed if started directly with RUN"...
	ld de,#0x0040
	ld hl,#0xa6fb
	call kl_rom_walk

	;;;find commands
	ld hl,#commands
	ld de,#commands_store
	ld b,#nocommands-commands		;no. of commands
next_command:
	push bc
	push hl
	push de
	call kl_find_command
	pop de
	jr nc,err
	;; command found, store address of command
	ld a,l
	ld (de),a
	ld a,h
	inc de
	ld (de),a
	;; store "rom select" of command
	ld a,c
	inc de
	ld (de),a
	inc de
	pop hl
	inc hl
	pop bc
	djnz next_command
	ld l,#1
	jr exit

err:
	pop hl		;adjust stack
	pop bc
	ld l,#0
exit:
	ret

_read_track::
	push ix
	ld ix,#0
	add ix,sp
	;; store buffer pointers
	;; first 2 byte are from "push ix", next 2 return adress from call, so first
	;;  parameter starts at offset 4
	ld l,4(ix)	;buf lo
	ld h,5(ix)	;buf hi
	ld (trk_hdr),hl
	ld bc,#0x100	;size of track header
	add hl,bc	;to skip
	ld (sec_buf),hl

	call read
	ld l,#1

	pop ix
	ret

_write_track::
	push ix
	ld ix,#0
	add ix,sp
	;; store buffer pointers
	;; first 2 byte are from "push ix", next 2 return adress from call, so first
	;;  parameter starts at offset 4
	ld l,4(ix)	;from stack
	ld h,5(ix)	;from stack
	ld (trk_hdr),hl
	ld bc,#0x100	;size of track header
	add hl,bc	;to skip
	ld (sec_buf),hl

	;;;copy sector data to sector header table
	ld hl,(trk_hdr)
	ld bc,#0x14		;offset starting sector info
	add hl,bc
	ld de,#sec_tbl
	ld ix,(trk_hdr)
	ld a,0x15(ix)		;no. sectors
tt:	ld bc,#4
	add hl,bc
	ldir
	dec a
	jr nz,tt

	;;;set format (not sure, if really needed here?)
	call select

	;;;format track
	call format

	;;;write sector data
	call write

	pop ix
	ld l,#1		;return ok
	ret

select:
	ld a,(sec_tbl + 2)
	;; execute command
	rst 3*8
	.dw bios_select_format

	ret

format:
	;; HL = address of C,H,R,N table 
	ld hl,#sec_tbl

	;; D = track number
	;; (change this value to define the track to write to )
	ld d,(hl)

	;; E = drive number (0 or 1)
	;; (change this value to define the disc drive to write to)
	ld e,#driveno

	;; execute command
	rst 3*8
	.dw bios_format_track

	ret

read:
	ld hl,(sec_buf)	;buf
	ld ix,(trk_hdr)
	ld b,0x15(ix)	; no. sectors
rloop:
	ld c,0x18+2(ix)	;sector
	ld d,0x18(ix)	;track
	ld e,#driveno
	push hl	;should be preserved on no error
	push bc
	push ix
	;; execute command
	rst #(3*8)
	.dw #bios_read_sector
	pop ix
	pop bc
	pop hl
	;ret nc		;return on error?
	ld de,#0x200
	add hl,de	;next buffer
	ld de,#8
	add ix,de	;next sector id
	djnz rloop
	ret

write:
	;; D = track number
	;; (change this value to define the track to write to)
	ld a,(sec_tbl)
	ld d,a

	;; HL = address of buffer
	;; (change this value to define a different buffer address)
	ld hl,(sec_buf)

	;; E = drive number (0 or 1)
	;; (change this value to define the disc drive to write to)
	ld e,#driveno

	ld ix,(trk_hdr)
	ld a,0x15(ix)	; no. sectors

	ld ix,#(sec_tbl + 2)	;sector id

w_sec:
	;; C = sector id
	;; 
	;; sector ids for DATA format disc: &C1, &C2, &C3, &C4, &C5, &C6, &C7, &C8, &C9
	;; sector ids for SYSTEM/VENDOR format disc: &41, &42, &43, &44, &45, &46, &47, &48, &49
	;;
	;; (change this value to define the id of the sector to write to)
	ld c,(ix)

	push af
	push de
	push hl
	push ix
	;; execute command
	rst #(3*8)
	.dw #bios_write_sector
	pop ix
	pop hl
	pop de
	pop af
	ld bc,#4
	add ix,bc	;next sector id
	ld bc,#0x200
	add hl,bc	;next sector buffer
	dec a		;next sector
	jr nz,w_sec

	ret

