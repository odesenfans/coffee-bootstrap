; startup.S
; Startup configuration of the Coffee core.

.extern c_entry

.global _start
_start:
    ldra r27, kernel_stack_start    ; Load stack value
    jmp c_entry                     ; Jump to C configuration code

infinite_loop:
    jmp infinite_loop
    nop
