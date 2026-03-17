# SC62015 Reverse Engineering Reference

Minimal reference for reverse engineering programs written for the  
**Sharp SC62015 CPU**, used in pocket computers such as the **SHARP PC-E500 series**.

This document is intended to assist automated or AI-assisted disassembly  
of binary programs such as **PLAYX**.

---

# CPU overview

SC62015 is an 8-bit microprocessor used in several SHARP pocket computers.

Characteristics:

- 8-bit CPU
- extended architecture derived from the SC61860 family
- used in SHARP PC-E500 / PC-E550 series
- optimized for BASIC interpreter integration

Programs loaded by BASIC loaders typically execute through:

```
CALL address
```

The address given in the CALL statement usually corresponds to the start  
of the machine code routine.

---

# Typical program loading pattern

Many programs published in Japanese magazines use a BASIC loader.

Example structure:

```
10 FOR I=0 TO N
20 READ A
30 POKE BASE+I,A
40 NEXT
50 CALL BASE
```

Result:

```
memory[BASE] → machine code routine
```

The **BASE address becomes the ORG address for disassembly.**

Example:

```
CALL 32768
```

Disassembly origin:

```
ORG 8000h
```

---

# Registers

SC62015 uses a small register set typical of pocket computer CPUs.

Common registers:

```
A   accumulator

B
C
D
E
H
L
```

Register pairs may also be used depending on the instruction.

---

# Basic instruction types

Typical instruction categories:

```
data transfer
arithmetic
logic
branch
call / return
I/O operations
```

Examples (representative):

```
LD
ADD
SUB
AND
OR
XOR
INC
DEC
JP
JR
CALL
RET
```

Exact opcode values depend on the SC62015 instruction table.

---

# Typical structures in pocket computer programs

Programs interacting with BASIC often contain:

### BASIC command hooks

Machine code that modifies the BASIC interpreter command table.

Typical pattern:

```
insert new command
↓
interpreter calls machine routine
```

Example:

```
PLAYX "CDEFG"
```

The command parser forwards the string to a machine code routine.

---

# Timing-sensitive routines

Music drivers typically include:

```
frequency loop
tone generation
delay loops
```

Common structure:

```
load period
toggle buzzer
wait loop
repeat
```

---

# Buzzer control

Pocket computers such as the PC-E500 use a **1-bit internal piezo buzzer**.

Sound is produced by toggling a hardware bit.

Typical structure:

```
set output
delay
clear output
delay
repeat
```

Polyphonic drivers simulate multiple voices through **time-division switching**.

---

# Reverse engineering workflow

Recommended workflow for programs such as PLAYX:

```
1. extract binary from BASIC loader
2. determine CALL address
3. set ORG to load address
4. disassemble instructions
5. identify loops and tables
6. locate sound generation routines
7. identify BASIC integration code
```

---

# Expected program sections

Typical layout:

```
entry point
initialization
command parser
MML parser
tone generator
data tables
```

---

# Notes

Because SC62015 tools are rare, reverse engineering is often performed by:

```
hex dump
↓
manual instruction decoding
↓
iterative analysis
```

AI systems can assist by converting opcode streams into likely instruction sequences.

---

# Related documentation

PLAY3 Archive

https://github.com/gikonekos/PLAY3-Archive
