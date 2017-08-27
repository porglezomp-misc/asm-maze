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
	w	.req r1
	h	.req r2
	x	.req r3
	y	.req r4
	idx	.req r5
	one	.req r6
	push	{y, idx, one, lr}
fill_ones:
	mov	one, #0xFF
	mov	idx, base
	mov	y, h
row:
	mov	x, w
cell:
	strb	one, [idx], #1
	subs	x, #1
	bgt	cell
	subs	y, #1
	bgt	row

	pop	{y, idx, one, pc}
	.unreq base
	.unreq w
	.unreq h
	.unreq x
	.unreq y
	.unreq idx
	.unreq one
