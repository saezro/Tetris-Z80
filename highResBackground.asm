;--------------------------------------------------------------------------------------------
; Function hrBKG -  fills the full screen with a char pattern (blockgraph)
;--------------------------------------------------------------------------------------------
hrBKG:			push af
                push bc
                push de
                push hl
                push ix
				
				ld hl, $4000
				ld d, 0
				ld BC, $1800
hrLp:			ld ix, blockgraph
                ld a, h
                and 7
                ld e, a
				add ix, de
				ld a, (ix)
				ld (hl),a
                inc hl
                dec bc
                ld a, b
                or c
                jr nz, hrLp

                pop ix
                pop hl
                pop de
                pop bc
                pop af
                ret

blockgraph:	DEFB $FF, $81, $81, $85, $85, $9D, $81, $FF