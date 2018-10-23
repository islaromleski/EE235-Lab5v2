; Author : Matthew Romleski
; Tech ID: 12676184
; Program that gets the dot product the matrices A*B.
; Stores the result in the data memory at 0x2000 to 0x2003.

		.include <atxmega128a1udef.inc>

		.dseg
		.def	mulRes		= r0
		.def	A1			= r2
		.def	A2			= r3
		.def	B1			= r4
		.def	B2			= r5
		.def	tempRes		= r14
		.def	lp1Con		= r16
		.def	lp2Con		= r17
		.def	junk		= r25

		.cseg
		.org	0x00
		rjmp	start
		.org	0xF6


start:		ldi		lp1Con, 1 ; Instaniate the loop condition.

			ldi		junk, low(RAMEND) ; Loads the stack pointer.
			out		CPU_SPL, junk ; ^^
			ldi		junk, high(RAMEND) ; ^^
			out		CPU_SPH, junk ; ^^
			ldi		YL, 0x00 ; Loads the data memory location we'll be storing stuff at.
			ldi		YH, 0x20 ; ^^
			ldi		ZL, low(ArrayA << 1) ; Loads the memory location of array A into the Z pointer.
			ldi		ZH, high(ArrayA << 1) ; ^^
			rjmp	loopStart ; jumps over loopSetup

loopSetup:	pop		ZH ; loads the memory location from the stack.
			pop		ZL ; ^^
			inc		lp1Con ; Increments loop counter.

loopStart:	cpi		lp1Con, 3 ; Checks if the program has already looped twice.
			brlt	outLoop ; Branches if it HASN'T.
			rjmp	done ; Otherwise, it ends the program.

outLoop:	lpm		A1, Z+ ; Loads the first 2 elements of A.
			lpm		A2, Z+ ; ^^
			ldi		lp2Con, 1 ; Sets/resets the inner loop condition.
			push	ZL ; stores the memory location for the third element of Array A into the stack.
			push	ZH ; ^^
			ldi		ZL, low(ArrayB << 1) ; Loads the memory location of array B into the Z pointer.
			ldi		ZH, high(ArrayB << 1) ; ^^

innerLoop:	cpi		lp2Con, 3 ; Checks if the loop has occured 2 times.
			brge	loopSetup ; If it has, goes to loop setup.
			sbrs	lp2Con, 0 ; If the last bit is 1 (aka when lp2Con = 1), skips the next line.
			sbiw	ZL, 1 ; Decrements pgrm mem location by 1.
			lpm		B1, Z+ ; Loads 1st(lp 1) or 2nd(lp 2) element of the array.
			adiw	ZL, 1 ; Increments pgrm mem location by 1.
			lpm		B2, Z ; Loads 3rd(lp 1) or 4th(lp 2) element of the array WITHOUT incrementing.
			mul		A1, B1 ; Normal matrix multiplication.
			mov		tempRes, mulRes ; Stores the result elsewhere.
			mul		A2, B2 ; Normal matrix multiplication.
			add		tempRes, mulRes ; Adds the results together.
			st		Y+, tempRes ; Stores that final result in data memory.
			inc		lp2Con ; Increments the loop counter.
			rjmp	innerLoop ; Loops.

done:		rjmp	done

ArrayA:		.db		2,  3,  4,  5
ArrayB:		.db		7,  8,  9, 10