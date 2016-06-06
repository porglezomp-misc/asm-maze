.globl _start

WIDTH	= 64
HEIGHT	= 64

_start:
	mov 	r0, #WIDTH
	mov	r1, #HEIGHT
	bl	bmp_write_header

	sub	sp, #4
	mov	r4, sp
	sub	sp, #WIDTH * HEIGHT * 3
loop:
	bl	random_word
	and	r0, #0xFF
	sub	r4, #3
	strb	r0, [r4, #0]
	strb	r0, [r4, #1]
	strb	r0, [r4, #2]
	cmp	r4, sp
	bne	loop

	mov	r0, #1
	mov	r1, r4
	mov	r2, #WIDTH * HEIGHT * 3
	mov	r7, #4
	svc	#0

_exit:
	mov	r0, #0
	mov	r7, #1
	svc	#0
