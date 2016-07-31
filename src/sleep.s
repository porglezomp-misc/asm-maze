	.text

MEGA = 1000000

	.globl _start
_start:
	sub	sp, #8
	mov	r0, sp
	bl	clock_init

	mov	r0, sp
	mov	r1, #4
	ldr	r2, =200 * MEGA
	bl	clock_inctime

	mov	r0, sp
	bl	clock_sleep

	mov	r0, #0
	mov	r7, #1
	svc	#0
