.globl _start
_start:
	mov	r0, #37
	mov	r1, #19
	subs	r2, r1, r0
	movpl	r3, r2
	rsbmi	r3, r2, #0

	mov	r0, r3
	bl	print_word

	mov	r0, #0
	mov	r7, #1
	svc	#0
