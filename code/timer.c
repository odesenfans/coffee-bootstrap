/**
 * @file timer.c
 * @brief Timer initialisation and control functions.
 */

#include "timer.h"

#include "ccb.h"
#include "interrupts.h"

#include <stdint.h>

extern CoffeeCCB_s* ccb;

#define TIMER0_DIVISOR_VALUE 99u
#define TIMER0_MAX_COUNTER_VALUE    999u

void init_system_timer(void)
{
    /* Stop timer 0 */
    ccb->TMR_CONF &= ~TMR0_CONF_EN;

    /* Disable watchdog behaviour */
    ccb->TMR_CONF &= ~TMR0_CONF_WDOG;

    /* Configure timer interrupt as interrupt 0 */
    ccb->TMR_CONF &= ~(7u << TMR0_CONF_INTN_OFFSET);

    /* Activate timer interrupt generation */
    ccb->TMR_CONF |= TMR0_CONF_GINT;

    /* Set timer in continuous mode */
    ccb->TMR_CONF |= TMR0_CONF_CONT;

    /* Set divisor value */
    ccb->TMR_CONF &= ~(0xFFu << TMR0_CONF_DIV_OFFSET);
    ccb->TMR_CONF |= TIMER0_DIVISOR_VALUE << TMR0_CONF_DIV_OFFSET;

    /* Set counter and max counter value */
    ccb->TMR0_CNT = 0u;
    ccb->TMR0_MAX_CNT = TIMER0_MAX_COUNTER_VALUE;

    /* Start timer */
    ccb-> TMR_CONF |= TMR0_CONF_EN;
}
