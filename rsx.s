	.module rsx
	.globl _rsx_init
	.globl _nosup
	.globl _cat
	.globl _in_open
	.globl _in_close
	.globl _in_direct

kl_log_ext .equ 0xbcd1

	.area _DATA

work_space:			;Space for kernel to use
	.ds 4

	.area _CODE

_rsx_init::
	ld hl,#work_space	;;address of a 4 byte workspace useable by Kernel
	ld bc,#jump_table	;;address of command name table and routine handlers
	jp kl_log_ext		;;Install RSX's

jump_table:
	.dw #name_table            ;address pointing to RSX commands 

	jp set_pointers           ;routine for COMMAND1 RSX
	;jp RSX_2_routine           ;routine for COMMAND2 RSX

;; the table of RSX function names
;; the names must be in capitals.

name_table:
	.db "S","D"+0x80     ;the last letter of each RSX name must have bit 7 set to 1.
	;.db "C","D"+0x80     ;This is used by the Kernel to identify the end of the name.

	.db 0                     ;end of name table marker

; Code for the example RSXs

set_pointers:
	ld de,#0xbc77		;real vectors
	ld hl,#cas_vectors
	ld bc,#cas_vectors_end-cas_vectors
	ldir

	ret

cas_vectors:
;Cassette (or Diskette) Input

; BC77 CAS_IN_OPEN       ;in: HL=fname, B=fnamelen, DE=workbuf,
;                        ;out: HL=header, DE=dest, BC=siz, A=type, cy=err, zf
	jp _in_open
; BC7A CAS_IN_CLOSE      ;out: DE=workbuf, cy=0=failed (no open file)
	jp _in_close
; BC7D CAS_IN_ABANDON    ;out: DE=workbuf, cy=1, z=0, A=all_closed (FFh=yes)
	jp _in_close
; BC80 CAS_IN_CHAR       ;out: A=char, cy=0=error, zf=errtype
	jp _nosup
; BC83 CAS_IN_DIRECT     ;in: HL=dest, out: HL=entrypoint, cy=0=err, zf=errtype
	jp _in_direct
; BC86 CAS_RETURN        ;in: A=char (undo CAS_IN_CHAR, char back to buffer)
	jp _nosup
; BC89 CAS_TEST_EOF      ;out: CY=0=eof (end of file)
	jp _nosup

;Cassette (or Diskette) Output

; BC8C CAS_OUT_OPEN      ;in: HL=fname, B=fnamelen, DE=workbuf, out: HL,cy,zf
	jp _nosup
; BC8F CAS_OUT_CLOSE     ;out: DE=workbuf, cy=0=failed (zf=errtype)
	jp _in_close
; BC92 CAS_OUT_ABANDON   ;out: DE=workbuf, cy=1, z=0, A=all_closed (FFh=yes)
	jp _in_close
; BC95 CAS_OUT_CHAR      ;in: A=char, out: cy=0=error, zf=errtype
	jp _nosup
; BC98 CAS_OUT_DIRECT    ;in: HL=src, DE=len, BC=entrypoint, A=type, out: cy/zf
	jp _nosup

;Cassette (or Diskette) Catalog

; BC9B CAS_CATALOG       ;in: DE=workbuf, out: DE=workbuf, cy=0=error
	jp _cat

cas_vectors_end:
