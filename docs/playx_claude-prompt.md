PROJECT CONTEXT: PLAYX Reverse Engineering

You are assisting with reverse engineering a historical machine code program
for the SHARP PC-E500 pocket computer.

CPU architecture:
SC62015

The program being analyzed is called:

PLAYX

This program was originally distributed in a Japanese magazine as a BASIC installer.

The BASIC program loads machine code into memory using POKE statements
and then executes it with a CALL instruction.

No original assembler source code exists.

The goal of this task is to reconstruct a readable assembly listing.

---

INPUT FILES

You will receive the following files.

1. PLAYX.bin

Binary extracted from the BASIC installer.

2. SC62015_reverse_reference.md

Minimal instruction overview for the SC62015 CPU.

3. pc-e500_memory_map.md

General memory layout and hardware behavior of the PC-E500.

4. (optional) PLAY3.asm

A related buzzer music driver used on the same platform.

---

TASK

Perform a reverse engineering analysis of PLAYX.bin.

Your objective is NOT only to decode instructions,
but also to identify the internal structure of the program.

Produce:

1. A full assembly listing
2. Labels for important routines
3. Comments explaining program behavior

---

EXPECTED PROGRAM COMPONENTS

Programs of this type typically contain the following parts:

entry point  
initialization routine  
BASIC command hook or interface  
string / MML parser  
tone generation routine  
frequency tables  
timing loops

Try to identify these components.

---

BUZZER DRIVER BEHAVIOR

The PC-E500 has only a single 1-bit buzzer.

Music drivers generate sound by toggling a hardware output bit.

Typical structure:

toggle buzzer  
delay loop  
toggle buzzer  
delay loop  

Polyphonic drivers simulate multiple voices by rapidly switching
between frequency periods.

Look for tight timing loops and period tables.

---

DISASSEMBLY GUIDELINES

Follow these principles:

1. Determine the entry point from the CALL address in the BASIC loader.

2. Use that address as the ORG value.

3. Decode instructions sequentially.

4. Identify jump targets and assign labels.

5. Detect loops and mark them clearly.

6. Identify tables of frequency values or note data.

7. Separate code from data where possible.

---

OUTPUT FORMAT

Produce the following sections.

1. Program overview

Explain what the program appears to do.

2. Memory layout

Describe major sections of the binary.

3. Assembly listing

Example format:

ORG 8000h

entry_point:
    LD A,xx
    CALL init_driver
    JP main_loop

init_driver:
    ...

main_loop:
    ...

4. Identified routines

Example:

init_driver  
parse_mml  
tone_generator  
delay_loop  

5. Data tables

Frequency tables or note tables should be separated from code.

---

IMPORTANT

If some instructions cannot be decoded with certainty,
mark them clearly.

Example:

; possible opcode
; uncertain instruction

Accuracy is more important than guessing.

---

GOAL

Reconstruct the internal structure of the PLAYX driver
and produce a readable assembly representation.

The result will be used for historical documentation
of buzzer-based music drivers on Japanese pocket computers.
