;; other firmware functions for CPC

	.module cpc
	.area _CODE

_readchar::
		call	0xBB09
		ld	l,#0
		ret	nc
		ld	l,a
		ret
