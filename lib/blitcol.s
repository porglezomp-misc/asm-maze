	.text


/*
Takes the screen column in r0, the texture column in r1,
the screen height in r2, and a texture pointer in r3.
The texture pointer should point to the data, with the
size stored in the 4 bytes immediately before it.
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
	wscr .req r4
	hscr .req r5
	base .req r6
	ldr	r4, =fb_data
	ldm	r4, {wscr, hscr, base}

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
