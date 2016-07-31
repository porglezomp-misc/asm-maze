.text

/*
==[ BMP HEADER LAYOUT ]=================================

OFFSET	SIZE	FIELD				VALUE
--------------------------------------------------------
0x00	2	HEADER				(0x4D42)
0x02	4	SIZE OF BMP
0x06	2	RESERVED			(0)
0x08	2	RESERVED			(0)
0x0A	4	OFFSET TO IMAGE			(54)
0x0E	4	SIZE OF BITMAPINFOHEADER STRUCT (40)
0x12	4	IMAGE WIDTH
0x16	4	IMAGE HEIGHT
0x1A	2	NUMBER OF PLANES		(1)
0x1C	2	BITS PER PIXEL (1, 4, 8, or 24) (24)
0x1E	4	COMPRESSION TYPE (NONE)		(0)
0x22	4	SIZE OF IMAGE DATA IN BYTES
0x26	4	HORIZONTAL RESOLUTION PX/M	(0x0EC3)
0x2A	4	VERTICAL RESOLUTION PX/M	(0x0EC3)
0x2E	4	NUM COLORS IN IMAGE, OR 0	(0)
0x32	4	NUM IMPORTANT COLORS, OR 0	(0)
--------------------------------------------------------

Args:
  - r0: width
  - r1: height
Usage: Call this and then print the body seperately.
*/
	.arm
	.align
	.globl bmp_write_header
bmp_write_header:
	sub	sp, #54

	/* Set all the constant values in the header */
	ldr	r2, =#0x4D42
	strh	r2, [sp]
	mov	r2, #0
	strh	r2, [sp, #0x06]
	strh	r2, [sp, #0x08]
	str	r2, [sp, #0x1E]
	str	r2, [sp, #0x2E]
	str	r2, [sp, #0x32]
	mov	r2, #54
	str	r2, [sp, #0x0A]
	mov	r2, #40
	str	r2, [sp, #0x0E]
	mov	r2, #1
	str	r2, [sp, #0x1A]
	mov	r2, #24
	str	r2, [sp, #0x1C]
	ldr	r2, =#0x0EC3
	str	r2, [sp, #0x26]
	str	r2, [sp, #0x2A]

	/* Width and height */
	str	r0, [sp, #0x12]
	str	r1, [sp, #0x16]

	/* Data size, multiply by 3 */
	add	r0, r0, LSL #1
	/* Round up to the nearest multiple of 4 */
	add	r0, #3
	bic	r0, #0x3
	mul	r0, r1
	str	r0, [sp, #0x22]
	add	r0, #54
	str	r0, [sp, #0x02]

	/* Print the header to stdout */
	mov	r0, #1
	mov	r1, sp
	mov	r2, #54
	mov	r7, #4
	svc	#0

	add	sp, #54
	mov	pc, lr
