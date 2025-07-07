	device zxspectrum128
	page 0
	org #7800 - 97 ; last param is pause between smoke and mooh

page0s	ei
	ld sp, $-2

	; chunked background
	ld hl, #4000 
	push hl
	ld de, #4001
	ld (hl), %01010101
	ld b, e : ld c, l ; ld bc, #0100
	ldir
	ld (hl), %10101010
	dec c
	ldir
	pop hl ; ld hl, #4000
	ld b, #16
	ldir

	; bg
	ld h, #80 ; ld hl, #8000
	push hl ; restoring in `showing full image`
	ld bc, 32 * 24 - 1
	push bc
	ld a, %00000001
	call DrawLine

	; botton
	ld hl, #8000 + 32 * 19
	pop bc ; ld bc, 32 * 4 - 1
	ld a, %00000100
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
	
	; showing full image
	pop hl ; ld hl, #8000
	ld de, #5800
	ld b, #03 ; ld bc, #300
	ldir

	ld b, 29 ; smoke duration
smokeLoop	push bc
	ld de, #59cb
	ld b, 10
srloop	call RND8
	cp d ; smoke intensivity
	ld a, %01000110
	jr c, 1f
	ld a, %00000001
1	ld (de), a
	inc de
	djnz srloop

	ld a, 4 : call SmokeShift
	pop bc : djnz smokeLoop

	; ld a, 32*13 % 256
	; ld (SmkShftLen + 1), a

	ld hl, SmkShftLen + 1
	ld (hl), 32*13 % 256

	ld a, l ; ld a, 43 
	call SmokeShift

	ld b, 104
	ld hl, #5800 + 32 * 12
mooh	ld (hl), %00000001
	inc hl
	ld (hl), e ; ld (hl), %00000000
	
	; mooh snd
	ld d, 16
1	ld a, (de)
	and %00010000
	out (#fe), a
	dec de
	ld a, d : or e
	jr nz, 1b

	djnz mooh

	jr $

SmokeShift	ld hl, #5860
	ld de, #5840
SmkShftLen	ld bc, 32 * 12
	ldir
	ld b, 8 : halt : djnz $-1
	dec a : jr nz, SmokeShift
	ret

RndLoop	ld b, 101
mainLoop	push bc
	ld bc, #5800
	ld hl, #8000	

oneIterr	ld a, (bc)
RndLpChk	nop // cp (hl) ; #be 
	jr z, 1f
	ex de, hl

	call RND8
	and %00010111
	
	ex de, hl
	ld (bc), a

1	out (#fe), a 

	inc hl
	inc bc
	ld a, b : cp #61 : jr nz, oneIterr

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
DrawLine	ld e, l : ld d, h : inc e
	ld (hl), a
	ldir
	ret

page0e	display /d, 'BIN size: ', $ - page0s
	display /d, 'Oversize: ', $ - page0s - 256
	include "src/builder.asm"
