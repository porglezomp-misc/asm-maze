	.text

	.globl _start
_start:
	mov	r0, #0x0
	bl	icos12
	bl	print_word
	bl	newline

	mov	r0, #0x1000
	bl	icos12
	bl	print_word
	bl	newline

	mov	r0, #0x2000
	bl	icos12
	bl	print_word
	bl	newline

	mov	r0, #0x3000
	bl	icos12
	bl	print_word
	bl	newline

	mov	r0, #0x4000
	bl	icos12
	bl	print_word
	bl	newline

	ldr	r0, =-0x1000
	bl	icos12
	bl	print_word
	bl	newline

	// cos(pi/4)
	mov	r0, #0x0800
	bl	icos12
	bl	print_word
	bl	newline

	mov	r0, #0
	mov	r7, #1
	svc	#0
