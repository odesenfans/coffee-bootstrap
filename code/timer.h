/**
 * @file timer.h
 * @brief Declaration of timer control header functions.
 */

#ifndef DEF_TIMER_H
#define DEF_TIMER_H

/**
 * @brief Initialises and starts the system timer (timer 0).
 *
 * Loads the timer counter values, sets up the timer interrupt as external
 * interrupt 0 and starts the timer.
 */
void init_system_timer(void);

#endif /* DEF_TIMER_H */

