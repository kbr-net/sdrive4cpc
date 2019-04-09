
;; FILE: crt0.s
;; Generic crt0.s for a Z80
;; From SDCC..
;; Modified to suit execution on the Amstrad CPC!
;; by H. Hansen 2003
;; Original lines has been marked out!

    	.module crt0
	.globl	_main

	.area _HEADER (ABS)
;; Reset vector
	.org 	0x100 ;; Start from address &100
	call	_main
	ret

	;; Ordering of segments for the linker.
	.area	_HOME
	.area	_CODE
        
	.area	_DATA
    	.area   _BSS
    	.area   _HEAP

   	.area   _CODE
