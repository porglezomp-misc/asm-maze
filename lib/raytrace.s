	.text

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

This takes coordinates in 8 bit sub-grid precision. This means
0,0 is the upper left corner, and 256,256 is the next pixel
diagonally down.

NOTE: For simplicity, this requires that the map be entirely
surrounded by solid walls, or else this will run off in an
infinite loop outside of the grid. If this becomes a problem,
then you should add bounds checking in the search loop.

Arguments:
 - r0, r1: the origin point for the ray in sub-grid coordinates
 - r2, r3: a second point on the ray to produce the direction

Return:
 - r0, r1: the grid coordinates of the intersection
 - r2: 0 if it intersected horizontally, 1 if vertically.
   That is, for 0 the edge is |, for 1 the edge is _
*/
	.arm
	.align
	.globl	tr_trace_block
tr_trace_block:
	push	{r4-r10, lr}

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
	// @Todo: Make sure that this error is in the
	//        correct direction...
	// We use 8 bits of sub-tile positioning
	and	yerr, y0, #0xFF
	lsr	y0, #8
	lsr	x0, #8
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
	movne	r2, #1
	bne	ret
hinc:
	add	x0, xinc
	// r10 = base[y0 * w + x0]
	mla	r10, y0, w, x0
	add	r10, base, r10
	ldrb	r10, [r10]

	cmp	r10, #0
	movne	r2, #0
	bne	ret

	b	hloop
	.unreq yerr
	
// Vertical drawing
vert:
	xerr .req r9
	// We use 8 bits of sub-tile positioning
	and	xerr, x0, #0xFF
	lsr	x0, #8
	lsr	y0, #8
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
	movne	r2, #0
	bne	ret
vinc:
	add	y0, yinc
	// r10 = base[y0 * w + x0]
	mla	r10, y0, w, x0
	add	r10, base, r10
	ldrb	r10, [r10]

	cmp	r10, #0
	movne	r2, #1
	beq	vloop
	.unreq xerr

ret:
	pop	{r4-r10, pc}

	.unreq x0
	.unreq y0
	.unreq base
	.unreq w
	.unreq h
	.unreq dx
	.unreq dy

/*
Trace to find the exact intersection on a specific block.

Arguments:
 - r0, r1: the origin point for the ray in sub-grid coordinates
 - r2, r3: a second point on the ray to produce the direction
 - r4, r5: the grid coordinates of the hit tile
 - r6: whether the collision was horizontal or vertical

Return:
 - r0: the distance to the intersection point
 - r1: the texture coordinate of the intersection point
       from 0 to 256
*/
	.arm
	.align
	.globl	tr_trace
tr_trace:
	mov	pc, lr

	.data
tr_data:
	.space	4
	.space	4
	.space	4
