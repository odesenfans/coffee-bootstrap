/**
 * @file interrupts.h
 * @brief Interrupts configuration.
 */

#ifndef DEF_INTERRUPTS_H
#define DEF_INTERRUPTS_H

#include <stdint.h>

typedef void (*isr_ptr_t)(void);

typedef enum
{
    COP0_INT = 0,
    COP1_INT = 1,
    COP2_INT = 2,
    COP3_INT = 3,
    EXT_INT0 = 4,
    EXT_INT1 = 5,
    EXT_INT2 = 6,
    EXT_INT3 = 7,
    EXT_INT4 = 8,
    EXT_INT5 = 9,
    EXT_INT6 = 10,
    EXT_INT7 = 11
} interrupt_id_e;

void set_interrupt_service_routine(interrupt_id_e id, isr_ptr_t isr_ptr);

void set_interrupt_priority(interrupt_id_e id, unsigned int priority);

#define DISABLE_INTERRUPTS()    __asm__ volatile("di")

#define ENABLE_INTERRUPTS()     __asm__ volatile("ei")

#endif /* DEF_INTERRUPTS_H */
