/* Default linker script, for normal executables */
OUTPUT_FORMAT("elf32-coffee", "elf32-coffee",
	      "elf32-coffee")
OUTPUT_ARCH(coffee)
ENTRY(_start)
/* SEARCH_DIR("/usr/oma/garzia/local/coffee-tools/coffee-bin/coffee-elf/lib"); */

MEMORY
{
/*changed by guoqing: as our memory is small*/
  rom(rx) : ORIGIN = 0x100000, LENGTH = 64K
  ram(wx) : org = 0, l = 64k
}

kernel_stack_start = 0x1000;

SECTIONS
{

  	/* Read-only sections, merged into text segment: */
  	PROVIDE (__executable_start = 0x0); . = 0x0;
  	.text           :
  	{
    		*(.text .stub .text.* .gnu.linkonce.t.*)
    		KEEP (*(.text.*personality*))
    		/* .gnu.warning sections are handled specially by elf32.em.  */
    		*(.gnu.warning)
  	} =0
  	.data          :
  	{
    		*(.data  .data.* .rodata* .gnu.linkonce.d.*)
    		KEEP (*(.gnu.linkonce.d.*personality*))
    		SORT(CONSTRUCTORS)
  	}
  	__bss_start = .;
  	.sbss           :
  	{
    		*(.dynsbss)
   		*(.sbss .sbss.* .gnu.linkonce.sb.*)
    		*(.scommon)
  	}
  	.bss            :
  	{
   		*(.dynbss)
   		*(.bss .bss.* .gnu.linkonce.b.*)
   		*(COMMON)
   		/* Align here to ensure that the .bss section occupies space up to
      		_end.  Align after .bss to ensure correct alignment even if the
   	   	.bss section disappears because there are no input sections.
   	   	FIXME: Why do we need it? When there is no .bss section, we don't
   	   	pad the .data section.  */
   		. = ALIGN(. != 0 ? 32 / 8 : 1);
  	}
	. = ALIGN(32 / 8);
  	. = ALIGN(32 / 8);
  	_end = .; PROVIDE (end = .);
	
	ROM : { *(.text) } >rom 
	RAM : { *(.data) } >ram 
}

