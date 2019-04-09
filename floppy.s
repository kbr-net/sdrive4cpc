;dsk2disc (c) 2019 by KBr

	.module floppy
	.globl sec_tbl
	.globl trk_hdr
	.globl sec_buf

driveno	=	0

	.area _DATA

	;; storage
sec_tbl:	.ds	4 * 12
trk_hdr:	.ds	2
sec_buf:	.ds	2

	;; this is initialised when the "BIOS: FORMAT TRACK" RSX has been found.
bios_format_track:
	.dw 0		;; address of function
	.db 0		;; "rom select" for function

bios_write_sector:
	.dw 0		;; address of function
	.db 0		;; "rom select" for function

cmd_bios_write_sector:
	.db 5+0x80	;; this is the "BIOS: WRITE SECTOR" RSX

cmd_bios_format_track:
	.db 6+0x80	;; this is the "BIOS: FORMAT TRACK" RSX

	.area _CODE

;; firmware function to find a RSX
kl_find_command	=	0xbcd4

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

	ld hl,#(cmd_bios_format_track)
	call kl_find_command
	jr nc,err

	;; command found, store address of command
	ld (bios_format_track),hl

	;; store "rom select" of command
	ld a,c
	ld (bios_format_track+2),a

	ld hl,#cmd_bios_write_sector
	call kl_find_command
	jr nc,err

	;; command found, store address of command
	ld (bios_write_sector),hl

	;; store "rom select" of command
	ld a,c
	ld (bios_write_sector+2),a

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

	;;;format track
	call format

	;;;write sector data
	call write

err:
	pop ix
	ret

format:
	;; HL = address of C,H,R,N table 
	ld hl,(sec_tbl)

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
	inc ix		;next sector id
	inc ix
	inc ix
	inc ix
	ld bc,#0x200
	add hl,bc	;next sector buffer
	dec a		;next sector
	jr nz,w_sec

	ret

