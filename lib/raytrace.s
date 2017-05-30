	.text

FRAC = 12

/*
Sets the trace environment.

Arguments:
 - r0: the pointer to the trace data, it should point to an
   array of bytes.
 - r1: the width of the trace environment data
 - r2: the height of the trace environment data
*/
	.arm
	.align
	.globl	tr_set_env
tr_set_env:
	ldr	r3, =tr_data
	stm	r3, {r0, r1, r2}
	mov	pc, lr

/*
Trace to find the block where an intersection occurs.

This takes coordinates in 12 bit sub-grid precision. This means
0,0 is the upper left corner, and 256,256 is the next pixel
diagonally down.

NOTE: This won't bounds check to ensure that memory accesses
stay inside the grid. Some good solutions are to entirely
surround your map with solid blocks, or to ensure that the end
point of your line segments are in-bounds.

Arguments:
 - r0, r1: the origin of the line segment in sub-grid coordinates
 - r2, r3: the second vertex of the line segment

Return:
 - r0, r1: the grid coordinates of the intersection
 - r2: 0 if no intersection, 1 if it intersected horizontally,
   2 if vertically. That is, 1 for | edges, 2 for _ edges.
*/
	.arm
	.align
	.globl	tr_trace_block
tr_trace_block:
	push	{r4-r12, lr}

	x0 .req r0
	y0 .req r1
	x1 .req r2
	y1 .req r3
	base .req r4
	w .req r5
	h .req r6
	dx .req r7
	dy .req r8

	ldr	r4, =tr_data
	ldm	r4, {base, w, h}

	xinc .req r2
	yinc .req r3

	lsr	r11, x1, #FRAC
	lsr	r12, y1, #FRAC

	// We want dy & dx to be absolute offset, and
	// xinc and yinc are the sign of the offset.
	subs	dx, x1, x0
	rsbmi	dx, dx, #0	// abs(dx)
	movmi	xinc, #-1
	movpl	xinc, #1
	subs	dy, y1, y0
	rsbmi	dy, dy, #0	// abs(dy)
	movmi	yinc, #-1
	movpl	yinc, #1
	cmp	dx, dy
	blt	vert

	.unreq x1
	.unreq y1
	// @Performance: Strength reduction on pixel address

// Horizontal drawing
horiz:
	yerr .req r9
	xend .req r11
	// @Todo: Make sure that this error is in the
	//        correct direction...
	// We use 12 bits of sub-tile positioning
	mov	r12, #0x0FF
	orr	r12, #0xF00
	and	yerr, y0, r12
	lsr	y0, #FRAC
	lsr	x0, #FRAC
hloop:
	add	yerr, dy
	cmp	yerr, dx
	ble	hinc
hyoff:
	sub	yerr, dx
	add	y0, yinc
	// r10 = base[y0 * w + x0]
	mla	r10, y0, w, x0
	add	r10, base, r10
	ldrb	r10, [r10]

	cmp	r10, #0
	lslne	r0, x0, #FRAC
	lslne	r1, y0, #FRAC
	movne	r2, #2
	bne	ret
hinc:
	add	x0, xinc
	// r10 = base[y0 * w + x0]
	mla	r10, y0, w, x0
	add	r10, base, r10
	ldrb	r10, [r10]

	// Only trace inside the line-segment
	cmp	xinc, #1
	cmpne	xend, x0
	cmpeq	x0, xend
	lslgt	r0, x0, #FRAC
	lslgt	r1, y0, #FRAC
	movgt	r2, #0
	bgt	ret

	cmp	r10, #0
	lslne	r0, x0, #FRAC
	lslne	r1, y0, #FRAC
	movne	r2, #1
	bne	ret

	b	hloop
	.unreq yerr
	.unreq xend
	
// Vertical drawing
vert:
	xerr .req r9
	yend .req r12
	// We use 12 bits of sub-tile positioning
	mov	r11, #0x0FF
	orr	r11, #0xF00
	and	xerr, x0, r11
	lsr	x0, #FRAC
	lsr	y0, #FRAC
vloop:
	add	xerr, dx
	cmp	xerr, dy
	ble	vinc
vxoff:
	sub	xerr, dy
	add	x0, xinc
	// r10 = base[y0 * w + x0]
	mla	r10, y0, w, x0
	add	r10, base, r10
	ldrb	r10, [r10]

	cmp	r10, #0
	lslne	r0, x0, #FRAC
	lslne	r1, y0, #FRAC
	movne	r2, #1
	bne	ret
vinc:
	add	y0, yinc
	// r10 = base[y0 * w + x0]
	mla	r10, y0, w, x0
	add	r10, base, r10
	ldrb	r10, [r10]

	// Check that we haven't gone past the end of our segment
	cmp	yinc, #1
	cmpne	yend, y0
	cmpeq	y0, yend
	lslgt	r0, x0, #FRAC
	lslgt	r1, y0, #FRAC
	movgt	r2, #0
	bgt	ret

	cmp	r10, #0
	lslne	r0, x0, #FRAC
	lslne	r1, y0, #FRAC
	movne	r2, #2
	bne	ret

	b	vloop
	.unreq xerr
	.unreq yend

ret:
	pop	{r4-r12, pc}

	.unreq x0
	.unreq y0
	.unreq base
	.unreq w
	.unreq h
	.unreq dx
	.unreq dy

	.data
tr_data:
	.space	4
	.space	4
	.space	4
