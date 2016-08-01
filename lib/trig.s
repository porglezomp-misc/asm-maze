	.text

/*
Derived that for cos(x) ~= Ax^6 + Bx^4 + Cx^2 + 1,
our constants times 2^12 (fixed point factor) are
A = -75, B = 1029, C = -5050.
Takes x in r0, a 20.12 fixed point number, with 1.0
representing one quadrant.
*/
	.arm
	.align
	.globl isin12
	.globl icos12

.macro	abs reg
cmp	\reg, #0
rsblt	\reg, \reg, #0
.endm

isin12:
	sub	r0, #0x1000
icos12:
	abs	r0
	mov	r1, #0xff
	orr	r1, #0x3f00
	// Domain is mod 4
	and	r0, r1 

	// Shift over the domain if necessary
	mov	r3, #0
	cmp	r0, #0x1000
	// Quadrants II, III, and IV
	subgt	r0, #0x2000
	movgt	r3, #1
	cmp	r0, #0x1000
	// Quadrant IV
	subgt	r0, #0x2000
	movgt	r3, #0

	// Ax^6 >> 72 + Bx^4 >> 48 + Cx^2 >> 24 + 2^12,
	// x^2 (Ax^4 >> 48 + Bx^2 >> 24 + C) >> 24 + 2^12,
	// x^2 (x^2 (Ax^2 >> 24 + B) >> 24 + C) >> 24 + 2^12
	mul	r0, r0			// x^2
	asr	r0, #12
	// Load A = -75
	mov	r2, #-75
	mul	r1, r0, r2		// Ax^2
	// Load B = 1029
	mov	r2, #1024
	orr	r2, #5
	add	r1, r2, r1, ASR #12	// Ax^2 >> 24 + B
	mul	r1, r0			// x^2 (Ax^2 >> 24 + B)
	// Load C = -5050
	mvn	r2, #0x1300
	bic	r2, #0xB9
	// (x^2 (Ax^2 >> 24 + B) >> 24) + C
	add	r1, r2, r1, ASR #12
	// x^2 (x^2 (Ax^2 >> 24 + B) >> 24) + C
	mul	r0, r1
	mov	r1, #0x1000
	add	r0, r1, r0, ASR #12	// final result

	// Negate if it wasn't in quadrants II or III
	tst	r3, #1
	rsbne	r0, #0
	
	mov	pc, lr

