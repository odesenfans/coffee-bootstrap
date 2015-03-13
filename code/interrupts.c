/**
 * @file interrupts.c
 * @brief Implementation of interrupt-related functions.
 */

#include "interrupts.h"

#include "ccb.h"

extern CoffeeCCB_s* ccb;

void set_interrupt_service_routine(InterruptId_e id, isr_ptr_t isr_ptr)
{
    unsigned int index = (unsigned int) id;
    isr_ptr_t* isr_ptr_table = (isr_ptr_t*) &(ccb->COP0_INT_VEC);

    isr_ptr_table[index] = isr_ptr;
}

void set_interrupt_priority(InterruptId_e id, unsigned int priority)
{
    uint32_t bit_shift = 0;

    /* Priorities are encoded on 4 bits */
    priority = priority & 0xFu;

    /* Coprocessor interrupts */
    if (id < 4) {
        bit_shift = id * 4;

        ccb->COP_INT_PRI &= ~(0xFu << bit_shift);
        ccb->COP_INT_PRI |= priority << bit_shift;
    }
    /* External interrupts */
    else {
        bit_shift = (id - 4) * 4;

        ccb->EXT_INT_PRI &= ~(0xFu << bit_shift);
        ccb->EXT_INT_PRI |= priority << bit_shift;
    }
}
