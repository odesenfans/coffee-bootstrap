; exceptions.S
; Low-level exception handling.

; Push all registers on the stack, including the stack pointer.
.macro	pusha 
	addi r27, r27, -132
	st r0, r27, 4
	st r1, r27, 8
	st r2, r27, 12
	st r3, r27, 16
	st r4, r27, 20
	st r5, r27, 24
	st r6, r27, 28
	st r7, r27, 32
	st r8, r27, 36
	st r9, r27, 40
	st r10, r27, 44
	st r11, r27, 48
	st r12, r27, 52
	st r13, r27, 56
	st r14, r27, 60
	st r15, r27, 64
	st r16, r27, 68
	st r17, r27, 72
	st r18, r27, 76
	st r19, r27, 80
	st r20, r27, 84
	st r21, r27, 88
	st r22, r27, 92
	st r23, r27, 96
	st r24, r27, 100
	st r25, r27, 104
	st r26, r27, 108
	st r27, r27, 112
	st r28, r27, 116
	st r29, r27, 120
	st r30, r27, 124
	st r31, r27, 128
.endm

; Restores a context stored on the stack, including the value of the stack.
.macro	popa
	ld r0, r27, 4
	ld r1, r27, 8
	ld r2, r27, 12
	ld r3, r27, 16
	ld r4, r27, 20
	ld r5, r27, 24
	ld r6, r27, 28
	ld r7, r27, 32
	ld r8, r27, 36
	ld r9, r27, 40
	ld r10, r27, 44
	ld r11, r27, 48
	ld r12, r27, 52
	ld r13, r27, 56
	ld r14, r27, 60
	ld r15, r27, 64
	ld r16, r27, 68
	ld r17, r27, 72
	ld r18, r27, 76
	ld r19, r27, 80
	ld r20, r27, 84
	ld r21, r27, 88
	ld r22, r27, 92
	ld r23, r27, 96
	ld r24, r27, 100
	ld r25, r27, 104
	ld r26, r27, 108
	;;ld r27, r27, 112
	ld r28, r27, 116
	ld r29, r27, 120
	ld r30, r27, 124
	ld r31, r27, 128
	addi r27, r27, 132
.endm

.global asm_timer_isr_wrapper
asm_timer_isr_wrapper:
    pusha               ; Save all registers on the stack
    jal timer_isr       ; Execute timer ISR code
    nop
    popa                ; Restore all registers
    reti                ; Return from interrupt
    nop                 ; 3 nop instructions required after reti
    nop
    nop

; Dummy timer ISR. If the user does not redefine the ISR,
; a timer interrupt will cause the processor to enter an infinite loop.
.weak timer_isr
timer_isr:
    jmp timer_isr
    nop

