	.text

# Note, this must be one less than a multiple of 4
WIDTH = 127
HEIGHT = 127

	.globl _start
_start:
	bl	random_seed_dev

	ldr	r0, =WIDTH*HEIGHT
	sub	sp, r0
	mov	r7, sp
	mov	r0, sp
	ldr	r1, =WIDTH
	ldr	r2, =HEIGHT
	bl	maze_gen

	ldr	r0, =(WIDTH+1)*HEIGHT*3
	sub	sp, r0
	mov	r4, sp

	ldr	r6, =HEIGHT
row:
	ldr	r5, =WIDTH
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
	ldr	r0, =WIDTH
	ldr	r1, =HEIGHT
	bl	bmp_write_header

	mov	r0, #1
	mov	r1, sp
	ldr	r2, =(WIDTH+1)*HEIGHT*3
	mov	r7, #4
	svc	#0

	mov	r0, #0
	mov	r7, #1
	svc	#0
