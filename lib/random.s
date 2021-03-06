	.text

O_RDONLY = 0x0

SYS_read = 0x3
SYS_open = 0x5
SYS_close = 0x6

/*
==[ XORSHIFT ]=========================================
This routine is an implementation of the XORShift that
can be found at http://en.wikipedia.org/wiki/xorshift.
It has a maximal period of 2^128 - 1. The state values
must be initialized so that they are not all zero, or
else you won't have good entropy.
*/
	.arm
	.align
	.globl random_word
random_word:
	push	{r4, r5}
	ldr	r4, =xorshift_state
	ldm	r4, {r0, r1, r2, r3}

	eor	r5, r0, r0, LSL #11
	eor	r5, r12, LSR #8
	eor	r0, r3, r3, LSR #19
	eor	r5, r0

	stm	r4, {r1, r2, r3, r5}
	mov	r0, r5
	pop	{r4, r5}
	mov	pc, lr

/*
This routine allows you to set the state vector of the
random generator. The state vector will be set to the
values contained in r0, r1, r2, and r3.
*/
	.arm
	.align
	.globl random_set_seed
random_set_seed:
	ldr	r12, =xorshift_state
	stm	r12, {r0, r1, r2, r3}
	
	mov	pc, lr

/*
This routine seeds from /dev/urandom
*/

	.arm
	.align
	.globl random_seed_dev
random_seed_dev:
	push	{r4, r7}

	ldr	r0, =random_dev_path
	mov	r1, #O_RDONLY
	mov	r7, #SYS_open
	svc	#0
	mov	r4, r0

	ldr	r1, =xorshift_state
	mov	r2, #16
	mov	r7, #SYS_read
	svc	#0

	mov	r0, r4
	mov	r7, #SYS_close
	svc	#0

	pop	{r4, r7}
	mov	pc, lr

random_dev_path:
	# @Todo: Size, /dev/random is smaller
	.asciz	"/dev/urandom"


	.data
/*
This initial state vector was produced using
random.org. It is not necessarily a good initial seed,
but it is a random one.
*/
xorshift_state:
	.word	0x150E8455, 0x8B4CCABC, 0xD73EB53A, 0x5C6776B1
