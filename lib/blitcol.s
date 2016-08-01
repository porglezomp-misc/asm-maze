	.text

	
/*
Takes the screen column in r0, the texture column in r1,
the screen height in r2, and a texture pointer in r3.
The texture pointer should point to the data, with the
size stored in the 4 bytes immediately before it.
The screen information is stored on the stack in the
same format as the the line rendering work:
sp+8: width
sp+4: height
sp+0: pointer
*/
	.arm
	.align
	.globl blit_col
blit_col:
	push	{r4-r10}

	// Find the base address of the texture column
	hdrw .req r2
	tcol .req r1
	tex .req r3
	htex .req r10
	ldr	htex, [tex, #-4]
	lsl	tcol, #1
	add	tex, tex, tcol, LSL htex
	// Compute the end address of the texture column
	end .req r8
	mov	end, #2
	add	end, tex, end, LSL htex

	// Load the screen dimensions
	wscr .req r6
	hscr .req r5
	base .req r4
	add	r4, sp, #4 * 7
	ldm	r4, {base, hscr, wscr}

	// Point base at the middle of the screen column
	add	base, base, r0, LSL #1
	mla	base, wscr, hscr, base
	.unreq hscr

	// Then put it at the top of the drawn column
	rsb	r7, hdrw, #0
	mla	base, wscr, r7, base
	lsl	wscr, #1

	ldrh	r7, [tex], #2
	mov	r0, #1
	lsl	htex, r0, htex
	mov	r0, #0
loop:
	strh	r7, [base], wscr

	add	r0, htex
	cmp	r0, hdrw
	subge	r0, hdrw
	ldrgeh	r7, [tex], #2

	cmp	tex, end
	ble	loop

	.unreq tcol
	.unreq wscr
	.unreq base
	.unreq end
	.unreq htex

	pop	{r4-r10}
	mov	pc, lr
