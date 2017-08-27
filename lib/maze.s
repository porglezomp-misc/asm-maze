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

	push	{w, h, x, y, idx, val, fp, lr}
	mov	w, r1
	mov	h, r2
	mov	fp, sp

	# Fill the grid with solid matter
fill_ones:
	mov	val, #0xFF
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
	.unreq	base

	mov	x, #0
	mov	y, #0
	mov	val, #0
	strb	val, [idx]

	# Carve the maze
maze:
	b	random_neighbor
neighbor_ret:
	cmp	r0, #0
	beq	pop_state
	mov	idx, r1
	push	{x, y, idx}
	strb	val, [r1]
	strb	val, [r2]
	b	maze

pop_state:
	cmp	sp, fp
	popne	{x, y, idx}
	bne	maze

	pop	{w, h, x, y, idx, val, fp, pc}


/*
Select a random neighbor.
If there was a
*/
random_neighbor:
	# Pick a random direction
	bl	random_word
	and	r1, r0, #0x3

	w_bound	.req r3
	h_bound	.req r10
	asr	w_bound, w, #1
	sub	w_bound, #1
	asr	h_bound, h, #1
	sub	h_bound, #1

	# This counter only lets us run through once.
	# Once it runs to zero, it returns.
	# This doubles as the result code.
	mov	r0, #4
	# @Todo: Jump table?
	cmp	r1, #1
	beq	east
	cmp	r1, #2
	beq	south
	cmp	r1, #3
	beq	west
	# Cycle through the directions clockwise
north:
	# If we're on the boundary we don't use this side
	cmp	y, #0
	beq	sub_north

	# Generate the address of the adjacent cell
	sub	r1, idx, w, LSL #1
	# Check if the cell is occupied
	ldrb	r2, [r1]
	cmp	r2, #0
	# Store the secondary result
	subne	r2, idx, w
	subne	y, #1
	bne	neighbor_ret
sub_north:
	# Subtract one, we've visited them all when we reach 0
	subs	r0, #1
	beq	neighbor_ret

	# The pattern repeats in each of the other cases
east:
	cmp	x, w_bound
	beq	sub_east

	add	r1, idx, #2
	ldrb	r2, [r1]
	cmp	r2, #0
	addne	r2, idx, #1
	addne	x, #1
	bne	neighbor_ret
sub_east:
	subs	r0, #1
	beq	neighbor_ret

south:
	cmp	y, h_bound
	beq	sub_south

	add	r1, idx, w, LSL #1
	ldrb	r2, [r1]
	cmp	r2, #0
	addne	r2, idx, w
	addne	y, #1
	bne	neighbor_ret
sub_south:
	subs	r0, #1
	beq	neighbor_ret

west:
	cmp	x, #0
	beq	sub_west

	sub	r1, idx, #2
	ldrb	r2, [r1]
	cmp	r2, #0
	subne	r2, idx, #1
	subne	x, #1
	bne	neighbor_ret
sub_west:
	subs	r0, #1
	beq	neighbor_ret
	# Cycle back to north
	b	north

	.unreq	w_bound
	.unreq	h_bound

	.unreq	w
	.unreq	h
	.unreq	x
	.unreq	y
	.unreq	idx
	.unreq	val
