/**
 * @file ccb.h
 * @brief Definition of the Coffee Core Control Block structure.
 */

#ifndef DEF_CCB_H
#define DEF_CCB_H

#include <stdint.h>

/** @brief Base address of the CCB on reset. */
#define CCB_BASE_ADDRESS 0x10000u

/* Timer bit fields */
#define TMR0_CONF_EN    (1u << 15)
#define TMR0_CONF_CONT  (1u << 14)
#define TMR0_CONF_GINT  (1u << 13)
#define TMR0_CONF_WDOG  (1u << 12)
#define TMR0_CONF_INTN_OFFSET   8
#define TMR0_CONF_DIV_OFFSET    0

/**
 * @brief CCB (Core Control Block) memory map.
 *
 * The Core Control Block (CCB) is used to control numerous core-level parameters.
 * It is used to configure interrupts, exceptions, memory protection, timers...
 */
typedef struct
{
    uint32_t CCB_BASE;      /**< CCB base address register. */
    uint32_t PCB_BASE;      /**< Peripheral address space base register. */
    uint32_t PCB_END;       /**< Peripheral address space end register. */
    uint32_t PCB_AMASK;     /**< Mask for peripheral addresses register. */
    uint32_t COP0_INT_VEC;      /**< Coprocessor 0 interrupt service. */
    uint32_t COP1_INT_VEC;      /**< Coprocessor 1 interrupt service. */
    uint32_t COP2_INT_VEC;      /**< Coprocessor 2 interrupt service. */
    uint32_t COP3_INT_VEC;      /**< Coprocessor 3 interrupt service. */
    uint32_t EXT_INT0_VEC;      /**< External interrupt 0 service routine base address. */
    uint32_t EXT_INT1_VEC;      /**< External interrupt 1 service routine base address. */
    uint32_t EXT_INT2_VEC;      /**< External interrupt 2 service routine base address. */
    uint32_t EXT_INT3_VEC;      /**< External interrupt 3 service routine base address. */
    uint32_t EXT_INT4_VEC;      /**< External interrupt 4 service routine base address. */
    uint32_t EXT_INT5_VEC;      /**< External interrupt 5 service routine base address. */
    uint32_t EXT_INT6_VEC;      /**< External interrupt 6 service routine base address. */
    uint32_t EXT_INT7_VEC;      /**< External interrupt 7 service routine base address. */
    uint32_t INT_MODE_IL;       /**< 16/32 bit execution of ISRs. */
    uint32_t INT_MODE_UM;       /**< Privileged/unprivileged execution of ISRs. */
    uint32_t INT_MASK;          /**< Interrupt mask register. */
    const uint32_t INT_SERV;    /**< Serviced interrupts register (R-O). */
    const uint32_t INT_PEND;    /**< Pending interrupts register (R-O). */
    uint32_t EXT_INT_PRI;       /**< External interrupt priority register. */
    uint32_t COP_INT_PRI;       /**< Coprocessor interrupt priority register. */
    const uint32_t EXCEPTION_CS;    /**< Cause of exception register (R-O). */
    const uint32_t EXCEPTION_PC;    /**< Memory address of faulty instruction. (R-O) */
    const uint32_t EXCEPTION_PSR;   /**< PSR flags at exception time. (R-O). */
    uint32_t DMEM_BOUND_LO;     /**< Lower limit of continuous data address space. */
    uint32_t DMEM_BOUND_HI;     /**< Upper limit of continuous data address space. */
    uint32_t IMEM_BOUND_LO;     /**< Lower limit of continuous instruction address space. */
    uint32_t IMEM_BOUND_HI;     /**< Upper limit of continuous instruction address space. */
    uint32_t MEM_CONF;      /**< Memory configuration register. */
    uint32_t SYSTEM_ADDR;   /**< System call handler address register. */
    uint32_t EXCEP_ADDR;    /**< Exception handler address register. */
    uint32_t BUS_CONF;      /**< Number of wait cycles per bus access. */
    uint32_t COP_CONF;      /**< Coprocessor interface configuration register. */
    uint32_t TMR0_CNT;      /**< Timer 0 counter value. */
    uint32_t TMR0_MAX_CNT;  /**< Timer 0 maximum counter value. */
    uint32_t TMR1_CNT;      /**< Timer 1 counter value. */
    uint32_t TMR1_MAX_CNT;  /**< Timer 1 maximum counter value. */
    uint32_t TMR_CONF;      /**< Timers configuration register. */
    uint32_t RETI_ADDR;     /**< Return address of the 'reti' instruction. */
    uint32_t RETI_PSR;      /**< PSR value after executing the 'reti' instruction. */
    uint32_t RETI_CR0;      /**< CR0 value after executiing the 'reti' instruction. */
    uint32_t FPU_STATUS;    /**< FPU status register. */
    const uint32_t Core_VER_ID; /**< Version number of the core. */
} CoffeeCCB_s;

#endif /* DEF_CCB_H */
