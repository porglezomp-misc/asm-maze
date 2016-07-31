.globl _start
.text

base .req r10
len .req r11
x .req r0
y .req r1
w .req r4
h .req r5

_start:
	bl	map_framebuffer
	mov	base, r0
	mov	len, r1
	mov	w, r2
	mov	h, r3

	mov	y, #0
row:
	mov	x, #0
loop:
	mul	r6, y, w
	add	r6, x
	add	r6, base, r6, LSL #1
	ldrh	r7, [r6]
	ldrh	r8, [r6, #2]
	add	r6, w, LSL #1
	ldrh	r9, [r6]
	ldrh	r12, [r6, #2]
	strh	r12, [r6]
	strh	r8, [r6, #2]
	sub	r6, w, LSL #1
	strh	r9, [r6]
	strh	r7, [r6, #2]

	add	x, #2
	cmp	x, w
	blt	loop

	add	y, #2
	cmp	y, h
	blt	row
	

	mov	r0, base
	mov	r1, len
	bl	unmap_framebuffer

	mov	r0, #0
	mov	r7, #1
	svc	#0
