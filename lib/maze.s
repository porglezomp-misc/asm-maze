	.text

/*
This populates a byte array with a maze, where 1 represents
a solid block and 0 represents an empty space.

Requires:
  width and height must be odd numbers

Args:
  - r0: starting address of mase
  - r1: width
  - r2: height

Results:
  The array is modified to fill the maze
*/

	.arm
	.align
	.globl maze_gen
maze_gen:
	base	.req r0
	w	.req r4
	h	.req r5
	x	.req r6
	y	.req r7
	idx	.req r8
	val	.req r9
	w2	.req r10
	h2	.req r12

	push	{w, h, x, y, idx, val, w2, fp, h2, lr}
	mov	w, r1
	mov	h, r2
	mov	fp, sp

	# Fill the grid with solid matter
fill_ones:
	mov	val, #0xAA
	mov	idx, base
	mov	y, h
row:
	mov	x, w
cell:
	strb	val, [idx], #1
	subs	x, #1
	bgt	cell
	subs	y, #1
	bgt	row

	# Set up the state
	add	idx, base, w
	add	idx, #1
	lsr	w2, w, #1
	lsr	h2, h, #1
	mov	x, #0
	mov	y, #0

	mov	val, #0
	strb	val, [idx]

	# Carve the maze
	bl	random_word

	mov	sp, fp
	pop	{w, h, x, y, idx, val, w2, fp, h2, pc}
	.unreq	base
	.unreq	w
	.unreq	h
	.unreq	x
	.unreq	y
	.unreq	idx
	.unreq	val
	.unreq	w2
	.unreq	h2
