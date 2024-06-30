+++
title = 'Arduino Due and Clang'
date = 2017-06-02T04:00:00
tags = ['freebsd', 'clang', 'llvm', 'arduino']
+++

Since October last year I've been trying to get my FreeBSD box compile working
binary for Arduino Due. For some reason, GCC produced binary is missing a
section which I observed through readelf. I tried to debug this, but I'm not
even novice kernel developer, let alone bare metal embeded programmer. All that
changed tonight (or should I say in the 4am today) when I stumbled upon
[just the right post](http://hannobraun.de/embedded/2015-04-30-building-with-llvm/).
I want to be clear, Hanno Braun did all the work, I just want to point out how
to get it working on your FreeBSD box.

I use -STABLE branch currently so system compiler is Clang 4.0. Beside that
you'll need few extra packages.

```sh
pkg install bossa arm-none-eabi-gcc
```

Bossa is used to upload the binary to Arduno and GNU linker for ARM is used as
LLDB is not ready, yet (or I didn't find example how to use it with Arduino).
Also, you'll need to add your user into dialer group.

```sh
pw group mod dialer -m <user>
```

Let's say we have `blink.c` file with the code which blinks the onboard LED and
`linker-script.ld` mentioned in the Hanno's post. Just for reference, this is
how he compiles the binary:

```sh
cc -nostdlib -ffreestanding -target arm-none-eabi -march=armv7-m -Tlinker-script.ld -Wl,--entry=start blink.c -o blink.elf
arm-none-eabi-objcopy -O binary blink.elf blink.bin
```

On my box, resulting `blink.bin` is 332 bytes! Not bad!

The flashing part is a bit different on FreeBSD. First, you have to issue soft
erase by connecting to serial port provided by Arduino using 1200 baud. You just
have to connect, so nothing extra is needed.

```sh
cu -l /dev/cuaU0 -s 1200
```

Also, you'll have to tell Bossa utility which device file to use.

```sh
bossac --write --verify -p /dev/cuaU0 --boot -R blink.bin
```

Your Arduino Due should be blinking, now. Just for the sake of completeness, I'll
show what Hanno wrote in .c and .ld file.

blink.c:
```C
// This is the top of the stack, as provided to us by the linker.
extern unsigned int _estack;


// This is a partial definition of the vector table. It only defines the
// first two entries which, as far as I can tell, are the minimum needed
// for a program to work at all.
// Space for the other interrupt handlers is reserved. I'm not sure if this
// is necessary, but I can imagine that the vector table not having the
// right length could cause all kinds of problems (imagine if it was too
// short, and the linker would place something else directly after it).
typedef struct {
	void *initial_stack_pointer_value;
	void *reset_handler;

	char other_interrupt_vectors[44 * 4]; // space for 44 32-bit pointers
} VectorTable;


void start();


// The vector table. We're using GCC-specific functionality to place this
// into the .vectors section, not where it would normally go (I suppose
// .rodata). The linker script makes sure that the .vectors section is at
// the right place.
__attribute__ ((section(".vectors")))
const VectorTable vector_table = {
	(void *)(&_estack),
	(void *)start,
};



// Addresses of several registers used to control parallel I/O.
static volatile int * const pb_pio_enable          = (int *)0x400E1000;
static volatile int * const pb_output_enable       = (int *)0x400E1010;
static volatile int * const pb_set_output_data     = (int *)0x400E1030;
static volatile int * const pb_clear_output_data   = (int *)0x400E1034;

// Bit mask for PB27. This is pin 13 (the built-in LED) on the Arduino Due.
static const int pb27_mask = 0x08000000;

// Addresses of several registers used to control the real-time timer.
static volatile int * const timer_mode_register  = (int *)0x400E1A30;
static volatile int * const timer_value_register = (int *)0x400E1A38;


// As the name suggests, this function sleeps for a given number of
// milliseconds. Our replacement for Arduino's delay function.
void sleep_ms(int milliseconds) {
	int sleep_until = *timer_value_register + milliseconds;
	while (*timer_value_register < sleep_until) {}
}

// This function is the entry point for our application and the handler
// function for the reset interrupt.
void start() {
	// Enable PB27 (pin 13) and configure it for output.
	*pb_pio_enable    = pb27_mask;
	*pb_output_enable = pb27_mask;

	// Set the timer to a resolution of a millisecond.
	*timer_mode_register = 0x00000020;

	// Continuously set and clear output on PB27 (pin 13). This blinks
	// the Due's built-in LED, which is the single purpose of this
	// program.
	while (1) {
		*pb_set_output_data = pb27_mask;
		sleep_ms(200);
		*pb_clear_output_data = pb27_mask;
		sleep_ms(200);
	}
}

```

linker-script.ld:
```
/* ----------------------------------------------------------------------------
 *         SAM Software Package License
 * ----------------------------------------------------------------------------
 * Copyright (c) 2012, Atmel Corporation
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following condition is met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the disclaimer below.
 *
 * Atmel's name may not be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * DISCLAIMER: THIS SOFTWARE IS PROVIDED BY ATMEL "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT ARE
 * DISCLAIMED. IN NO EVENT SHALL ATMEL BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * ----------------------------------------------------------------------------
 */

OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
SEARCH_DIR(.)

/* Memory Spaces Definitions */
MEMORY
{
	rom (rx)    : ORIGIN = 0x00080000, LENGTH = 0x00080000 /* Flash, 512K */
	sram0 (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00010000 /* sram0, 64K */
	sram1 (rwx) : ORIGIN = 0x20080000, LENGTH = 0x00008000 /* sram1, 32K */
	ram (rwx)   : ORIGIN = 0x20070000, LENGTH = 0x00018000 /* sram, 96K */
}

/* Section Definitions */
SECTIONS
{
    .text :
    {
        . = ALIGN(4);
        _sfixed = .;
        KEEP(*(.vectors .vectors.*))
        *(.text .text.* .gnu.linkonce.t.*)
        *(.glue_7t) *(.glue_7)
        *(.rodata .rodata* .gnu.linkonce.r.*)
        *(.ARM.extab* .gnu.linkonce.armextab.*)

        /* Support C constructors, and C destructors in both user code
           and the C library. This also provides support for C++ code. */
        . = ALIGN(4);
        KEEP(*(.init))
        . = ALIGN(4);
        __preinit_array_start = .;
        KEEP (*(.preinit_array))
        __preinit_array_end = .;

        . = ALIGN(4);
        __init_array_start = .;
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array))
        __init_array_end = .;

        . = ALIGN(0x4);
        KEEP (*crtbegin.o(.ctors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
        KEEP (*(SORT(.ctors.*)))
        KEEP (*crtend.o(.ctors))

        . = ALIGN(4);
        KEEP(*(.fini))

        . = ALIGN(4);
        __fini_array_start = .;
        KEEP (*(.fini_array))
        KEEP (*(SORT(.fini_array.*)))
        __fini_array_end = .;

        KEEP (*crtbegin.o(.dtors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
        KEEP (*(SORT(.dtors.*)))
        KEEP (*crtend.o(.dtors))

        . = ALIGN(4);
        _efixed = .;            /* End of text section */
    } > rom

    /* .ARM.exidx is sorted, so has to go in its own output section.  */
    PROVIDE_HIDDEN (__exidx_start = .);
    .ARM.exidx :
    {
      *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > rom
    PROVIDE_HIDDEN (__exidx_end = .);

    . = ALIGN(4);
    _etext = .;

    .relocate : AT (_etext)
    {
        . = ALIGN(4);
        _srelocate = .;
        *(.ramfunc .ramfunc.*);
        *(.data .data.*);
        . = ALIGN(4);
        _erelocate = .;
    } > ram

    /* .bss section which is used for uninitialized data */
    .bss ALIGN(4) (NOLOAD) :
    {
        . = ALIGN(4);
        _sbss = . ;
        _szero = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = . ;
        _ezero = .;
    } > ram

    . = ALIGN(4);
    _end = . ;

    /* .stack_dummy section doesn't contains any symbols. It is only
       used for linker to calculate size of stack sections, and assign
       values to stack symbols later */
    .stack_dummy :
    {
        *(.stack*)
    } > ram

    /* Set stack top to end of ram, and stack limit move down by
     * size of stack_dummy section */
    __StackTop = ORIGIN(ram) + LENGTH(ram);
    __StackLimit = __StackTop - SIZEOF(.stack_dummy);
    PROVIDE(_sstack = __StackLimit);
    PROVIDE(_estack = __StackTop);
}
```
