	.text

CLOCK_MONOTONIC = 0x1
TIMER_ABSTIME = 0x1

SYS_clock_gettime = 0x107
SYS_clock_nanosleep = 0x109

GIGA = 1000000000

/*
This routine takes the address of a timespec in r0
and fills it with the current time.
*/
	.arm
	.align
	.globl clock_init
clock_init:
	mov	r2, r7
	mov	r1, r0

	mov	r0, #CLOCK_MONOTONIC
	ldr	r7, =SYS_clock_gettime
	svc	#0

	mov	r7, r2
	mov	pc, lr


/*
This routine takes the address of a timespec in r0,
the number of seconds to increment in r1, and the
number of nanoseconds to increment in r2. It increments
the timespec correctly accounting for nanosecond
overflow.
*/
	.arm
	.align
	.globl clock_inctime
clock_inctime:
	push	{r4, r5}

	ldr	r3, =GIGA
	ldm	r0, {r4, r5}

	add	r4, r1
	add	r5, r2
	cmp	r5, r3
	addge	r4, #1
	subge	r5, r3

	stm	r0, {r4, r5}

	pop	{r4, r5}
	mov	pc, lr


/*
This routine takes the address of the timespec in r0.
*/
	.arm
	.align
	.globl clock_sleep
clock_sleep:
	push	{r7}

	mov	r1, #TIMER_ABSTIME
	mov	r2, r0
	mov	r3, #0
sleeploop:
	mov	r0, #CLOCK_MONOTONIC
	ldr	r7, =SYS_clock_nanosleep
	svc	#0
	// Continue interrupted sleeps
	cmp	r0, #0
	blt	sleeploop

	pop	{r7}
	mov	pc, lr
