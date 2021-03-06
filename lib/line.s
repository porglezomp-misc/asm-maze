        .text


/*
Draws a line between (r0,r1) and (r2,r3), using a screen
specified at the top of the stack, with width, height,
and pointer.
*/
        .arm
        .align
        .globl draw_line
draw_line:
	push	{r4-r11, lr}

	x0 .req r0
	y0 .req r1
	x1 .req r2
	y1 .req r3
	w .req r4
	h .req r5
	base .req r6
	dx .req r7
	dy .req r8

        ldr     r4, =fb_data
        ldm     r4, {w, h, base}

	mov	r10, #0x00FF
	orr	r10, #0xFF00

	subs	dx, x0, x1
	rsbmi	dx, dx, #0	// abs(dx)
	subs	dy, y0, y1
	rsbmi	dy, dy, #0	// abs(dy)
	cmp	dx, dy 
	blt	vert

horiz:
	// We want to work from left to right
	cmp	x0, x1

.macro swapop op a b tmp
\op	\tmp, \a
\op	\a, \b
\op	\b, \tmp
.endm

	swapop	movgt, x0, x1, r9
	swapop	movgt, y0, y1, r9

	subs	dy, y1, y0
	rsbmi	dy, dy, #0
	movmi	r9, #-1
	movpl	r9, #1
	// We use y1 to store the y_err
	mov	y1, #0
hloop:
	// base[y0 * w + x0] = r10
	mla	r11, y0, w, x0
	add	r11, base, r11, LSL #1
	strh	r10, [r11]

	add	y1, dy
	cmp	y1, dx
        // This is for the every-touched-pixel line,
        // but we'll use standard Bresenham here.
        // bgt     hyoff
	subgt	y1, dx
	addgt	y0, r9
hinc:
	add	x0, #1
	cmp	x0, x1
	ble	hloop
	b end

        /*
hyoff:
	sub	y1, dx
	add	y0, r9
	mla	r11, y0, w, x0
	add	r11, base, r11, LSL #1
	strh	r10, [r11]
        b       hinc
        */

vert:
	// We want to work from top to bottom
	cmp	y0, y1
	swapop	movgt, x0, x1, r9
	swapop	movgt, y0, y1, r9

	subs	dx, x1, x0
	rsbmi	dx, dx, #0
	movmi	r9, #-1
	movpl	r9, #1
	// We use x1 to store the x_err
	mov	x1, #0

vloop:
	// base[y0 * w + x0] = r10
	mla	r11, y0, w, x0
	add	r11, base, r11, LSL #1
	strh	r10, [r11]

	add	x1, dx
	cmp	x1, dy
        // bgt     vxoff
	subgt	x1, dy
	addgt	x0, r9
vinc:
	add	y0, #1
	cmp	y0, y1
	ble	vloop
        b end

        /*
vxoff:
	sub	x1, dy
	add	x0, r9
	mla	r11, y0, w, x0
	add	r11, base, r11, LSL #1
	strh	r10, [r11]
        b       vinc
        */

end:
	pop	{r4-r11, pc}

	.unreq x0
	.unreq y0
	.unreq x1
	.unreq y1
	.unreq w
	.unreq h
	.unreq base
	.unreq dx
	.unreq dy
