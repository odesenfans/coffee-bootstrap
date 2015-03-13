/**
 * @file main.c
 * @brief Boot and application code.
 */

#include "ccb.h"
#include "interrupts.h"
#include "timer.h"

#include <stdint.h>

CoffeeCCB_s* ccb = (CoffeeCCB_s*) CCB_BASE_ADDRESS;

static uint32_t system_time = 0;

extern void asm_timer_isr_wrapper(void);

char msg[16] = "Hello world!";
unsigned int var = 0xdeadbeef;

void main(void)
{
	var = 0x12345678;
    while(1)
        ;
}

void c_entry(void)
{
    init_system_timer();

    /* Sets priority and ISR for the timer interrupt */
    set_interrupt_service_routine(EXT_INT0, &asm_timer_isr_wrapper);
    set_interrupt_priority(EXT_INT0, 0u);
    ENABLE_INTERRUPTS();

    main();
}

void timer_isr(void)
{
    system_time++;
}

