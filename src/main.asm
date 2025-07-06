	device zxspectrum128
	page 0
	org #6000
page0s	ei
	; xor a : out (#fe), a 

	; chunked background
	ld hl, #4000 
	push hl
	ld de, #4001
	ld (hl), #55
	ld b, e : ld c, l ; ld bc, #0100
	ldir
	ld (hl), #AA
	dec c
	ldir
	pop hl ; ld hl, #4000
	ld b, #16
	ldir

	; bg
	ld hl, #8000
	ld bc, 32 * 24 - 1
	push bc
	ld a, %00000001
	call DrawLine

	; botton
	ld hl, #8000 + 32 * 20
	pop bc ; ld bc, 32 * 4 - 1
	ld a, %00100000
	call DrawLine

	; plate
	ld hl, #8000 + 32 * 19 + 10
	ld bc, 11
	ld a, %00000111
	call DrawLine

	ld hl, #8000 + 32 * 18 + 9
	ld bc, 13
	; ld a, %00000111  // already here
	call DrawLine

	ld hl, #8000 + 32 * 17 + 8
	ld bc, 15
	push bc
	; ld a, %00000111  // already here
	call DrawLine

	ld hl, #8000 + 32 * 16 + 8
	pop bc // ld bc, 15
	ld a, %00010111
	call DrawLine

	call RndLoop
	ld a, #be : ld (RndLpChk), a
	call RndLoop
	
	ld hl, #8000
	ld de, #5800
	ld bc, #300
	ldir

	ld b, 33
smokeLoop	push bc
	ld de, #59ca
	ld b, 12
srloop	call RND8
	cp 59 ; smoke intensivity
	ld a, %01000110
	jr c, 1f
	ld a, %00000001
1	ld (de), a
	inc de
	djnz srloop

	ld b, 4 : call SmokeShift
	pop bc : djnz smokeLoop

	ld a, 32*13 % 256
	ld (SmkShftLen + 1), a
	ld b, 50 : call SmokeShift

	ld b, 104
	ld hl, #5800 + 32 * 12
mooh	ld (hl), %00000001
	inc hl
	ld (hl), %00000000
	
	; mooh snd
	ld d, 0
1	ld a, (de)
	and %00010000
	out (#fe), a
2	inc de
	ld a, d : cp 16
	jr nz, 1b

	djnz mooh

	jr $

SmokeShift	push bc
	ld hl, #5860
	ld de, #5840
SmkShftLen	ld bc, 32 * 12
	ldir
	ld b, 8 : halt : djnz $-1
	pop bc : djnz SmokeShift
	ret

RndLoop	
	ld b, 119
mainLoop	push bc
	ld bc, #5800
	ld hl, #8000	

oneIterr	ld a, (bc)
RndLpChk	nop // #be cp (hl)
	jr z, 1f
	ex de, hl

	call RND8
	and %00110111
	
	ex de, hl
	ld (bc), a

1	;and %00010111
	out (#fe), a 

	inc hl
	inc bc
	ld a, b : cp #5c : jr nz, oneIterr

	halt

	pop bc : djnz mainLoop
	ret

RND8	ld a, 49
	ld hl, RND_TAB
	
	dup 5
	add a, (hl): ld (hl), a: inc hl
	edup

	ld (RND8 + 1), a
	ret
RND_TAB 	
DrawLine	ld d, h : ld e, l : inc e
	ld (hl), a
	ldir
	ret

page0e	display /d, 'BIN size: ', $ - page0s
	display /d, 'Oversize: ', $ - page0s - 256
	include "src/builder.asm"
