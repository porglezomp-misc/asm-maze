.globl _start
.text

SYS_nanosleep = 0xA2
SYS_clock_gettime = 0x107
SYS_clock_nanosleep = 0x109

CLOCK_MONOTONIC = 0x1
TIMER_ABSTIME = 0x1

KILO = 1000
MEGA = 1000000
GIGA = 1000000000

_start:
	sub	sp, #8

	mov	r0, #CLOCK_MONOTONIC
	mov	r1, sp
	ldr	r7, =SYS_clock_gettime
	svc	#0

	ldr	r0, [sp]	// seconds
	ldr	r1, [sp, #4]	// nanoseconds

	// Increment time by 4.2 seconds
	add	r0, #4
	ldr	r2, =200 * MEGA
	add	r1, r2
	ldr	r2, =GIGA
	// Handle nanosecond overflow
	cmp	r1, r2
	subge	r1, r2
	addge	r0, #1

	str	r0, [sp]
	str	r1, [sp, #4]

sleep:
	mov	r0, #CLOCK_MONOTONIC
	mov	r1, #TIMER_ABSTIME
	mov	r2, sp
	mov	r3, #0
	ldr	r7, =SYS_clock_nanosleep
	svc	#0
	cmp	r0, #0
	blt	sleep

	mov	r0, #0
	mov	r7, #1
	svc	#0
