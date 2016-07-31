.globl _start

_start:
	bl	map_framebuffer
	mov	r4, r0
	mov	r5, r1
	mov	r6, r2			@width
	mov	r7, r3 			@height

	mov	r1, #0
	mov	r3, #0
row:
	mov	r2, #0
pix:
	push	{r1, r2, r3}
	bl	random_word
	pop	{r1, r2, r3}
	add	r8, r3, r2, LSL #1
	str	r0, [r4, r8]

	add	r2, #2
	cmp	r2, r6
	blt	pix

	add	r1, #1
	add	r3, r3, r6, LSL #1
	cmp	r1, r7
	blt	row

done:
	mov	r0, r4
	mov	r1, r5
	bl	unmap_framebuffer

	mov	r0, #0
	mov	r7, #1
	svc	#0
