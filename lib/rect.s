	.text

/*
Draws a rect starting from the upper left corner at
the point (r0, r1) with width r2 and height r3.
This routine will misbehave if called not entirely
within the bounds of the framebuffer.
*/
	.arm
	.align
	.globl draw_rect
draw_rect:
	push	{r4}
	base .req r0
	w .req r4

	ldr	r12, =fb_data
	ldr	r4, [r12, #8]
	add	base, r4, r0, LSL #1
	ldr	w, [r12]
	mul	r1, w
	add	base, r1, LSL #1

	lsl	r2, #1
	ldr	r12, =rect_color
	ldr	r12, [r12]
row:
	mov	r1, #0
pix:
	strh	r12, [base, r1]
	add	r1, #2

	cmp	r1, r2
	blt	pix

	add	base, w, LSL #1
	subs	r3, #1
	bgt	row

done:
	pop	{r4}
	mov	pc, lr

	.arm
	.align
	.globl	rect_set_color
rect_set_color:
	ldr	r1, =rect_color
	str	r0, [r1]
	mov	pc, lr

	.data
rect_color:
	.word	0xFFFF
