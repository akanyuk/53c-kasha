	device zxspectrum128
	page 0
	org #6000
page0s	ei
	xor a : out (#fe), a 

	; chunked background
	ld hl, #4000 
	ld de, #4001
	ld (hl), #55
	ld bc, #0100
	ldir
	ld (hl), #AA
	dec c
	ldir
	ld hl, #4000
	ld b, #16
	ldir

	; bg
	ld hl, #8000
	ld bc, 32 * 24 - 1
	ld a, %00000001
	call DrawLine

	; botton
	ld hl, #8000 + 32 * 20
	ld bc, 32 * 4 - 1
	ld a, %01000100
	call DrawLine

	; plate
	ld hl, #8000 + 32 * 19 + 10
	ld bc, 11
	ld a, %00000111
	call DrawLine

	ld hl, #8000 + 32 * 18 + 9
	ld bc, 13
	ld a, %00000111
	call DrawLine

	ld hl, #8000 + 32 * 17 + 8
	ld bc, 15
	ld a, %01000111
	call DrawLine

	ld hl, #8000 + 32 * 16 + 8
	ld bc, 15
	ld a, %01000111
	call DrawLine

	ld a, 200
mainLoop	push af
	ld bc, #5800
	ld hl, #8000	

oneIterr	ld a, (bc)
	cp (hl)
	jr z, 1f
	ex de, hl
	call RND8
	ex de, hl
	ld (bc), a

1	and %00010111
	out (#fe), a 

	inc hl
	inc bc
	ld a, b : cp #5c : jr nz, oneIterr

	halt

	pop af
	dec a : jr nz, mainLoop
	
	out (#fe), a

	ld hl, #8000
	ld de, #5800
	ld bc, #300
	ldir

	jr $

RND8	ld a, 42
	ld hl, RND_TAB
	dup 5: add a, (hl): ld (hl), a: inc hl: edup
	ld (RND8 + 1), a
	and %01011111
	ret
RND_TAB 	
DrawLine	ld d, h : ld e, l : inc e
	ld (hl), a
	ldir
	ret

page0e	display /d, 'BIN size: ', $ - page0s
	include "src/builder.asm"
