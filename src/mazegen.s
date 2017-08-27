	.text

# Note, this must be one less than a multiple of 4
WIDTH = 127
HEIGHT = 127

	.globl _start
_start:
	ldr	r0, =WIDTH*HEIGHT
	sub	sp, r0
	mov	r7, sp
	mov	r0, sp
	mov	r1, #WIDTH
	mov	r2, #HEIGHT
	bl	maze_gen

	ldr	r0, =(WIDTH+1)*HEIGHT*3
	sub	sp, r0
	mov	r4, sp

	mov	r6, #HEIGHT
row:
	mov	r5, #WIDTH
pix:
	ldrb	r0, [r7], #1
	strb	r0, [r4], #1
	strb	r0, [r4], #1
	strb	r0, [r4], #1

	subs	r5, #1
	bgt	pix

	# Write the extra padding byte
	strb	r0, [r4], #1
	strb	r0, [r4], #1
	strb	r0, [r4], #1

	subs	r6, #1
	bgt	row

	mov	r4, sp


write_image:
	mov	r0, #WIDTH
	mov	r1, #HEIGHT
	bl	bmp_write_header

	mov	r0, #1
	mov	r1, sp
	ldr	r2, =(WIDTH+1)*HEIGHT*3
	mov	r7, #4
	svc	#0

	mov	r0, #0
	mov	r7, #1
	svc	#0
