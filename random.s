.globl random_word
.globl random_set_seed

/*
==[ XORSHIFT ]=========================================
This routine is an implementation of the XORShift that
can be found at http://en.wikipedia.org/wiki/xorshift.
It has a maximal period of 2^128 - 1. The state values
must be initialized so that they are not all zero, or
else you won't have good entropy.
*/
random_word:
	ldr	r7, =xorshift_state
	ldm	r7, {r0, r1, r2, r3}

	eor	r12, r0, r0, LSL #11
	eor	r12, r12, LSR #8
	eor	r0, r3, r3, LSR #19
	eor	r12, r0

	stm	r7, {r1, r2, r3, r12}
	mov	r0, r12
	mov	pc, lr

/*
This initial state vector was produced using
random.org. It is not necessarily a good initial seed,
but it is a random one.
*/
.data
xorshift_state:
.word 0x150E8455, 0x8B4CCABC, 0xD73EB53A, 0x5C6776B1

.text
/*
This routine allows you to set the state vector of the
random generator. The state vector will be set to the
values contained in r0, r1, r2, and r3.
*/
random_set_seed:
	ldr	r7, =xorshift_state
	stm	r7, {r0, r1, r2, r3}
	
	mov	pc, lr
