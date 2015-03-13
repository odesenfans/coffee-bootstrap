; startup.S
; Startup configuration of the Coffee core.

.extern c_entry

.global _start
_start:
    ldra r27, kernel_stack_start    ; Load stack value
    st r27, r27, 0                  ; Debug: store the stack top address on the stack
    jal c_entry                     ; Jump to C configuration code
    nop

infinite_loop:
    jmp infinite_loop
    nop
