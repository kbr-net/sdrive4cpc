;; added getchar and renamed to stdio.s by KBr 2019
;; original FILE: putchar.s
;; Modified to suit execution on the Amstrad CPC
;; by H. Hansen 2003
;; Original lines has been marked out!

	.module stdio
	.area _CODE
_putchar::       
_putchar_rr_s:: 
        	ld      hl,#2
        	add     hl,sp
        
        	ld      a,(hl)
        	call    0xBB5A
        	ret
           
_putchar_rr_dbs::

        	ld      a,e
        	call    0xBB5A
        	ret

;; end original file

;; added by KBr

_getchar::
		call	0xBB06
		ld	l,a
		ret
