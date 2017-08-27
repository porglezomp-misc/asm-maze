	.text

WIDTH = 31
HEIGHT = 31

	.globl _start
_start:
	ldr	r0, =WIDTH*HEIGHT
	sub	sp, r0
	mov	r7, sp
	mov	r0, sp
	mov	r1, #32
	mov	r2, #32
	bl	maze_gen

	ldr	r0, =WIDTH*HEIGHT*3
	sub	sp, r0
	mov	r4, sp
	ldr	r5, =WIDTH*HEIGHT

grow_loop:
	ldrb	r0, [r7], #1
	strb	r0, [r4], #1
	strb	r0, [r4], #1
	strb	r0, [r4], #1

	subs	r5, #1
	bgt	grow_loop

	mov	r4, sp


write_image:
	mov	r0, #WIDTH
	mov	r1, #HEIGHT
	bl	bmp_write_header

	mov	r0, #1
	mov	r1, sp
	ldr	r2, =WIDTH*HEIGHT*3
	mov	r7, #4
	svc	#0

	mov	r0, #0
	mov	r7, #1
	svc	#0
