# PLAY3 Memory Map

Approximate memory map of the **PLAY3** driver  
for the **SHARP PC-E500** series.

This document is based on:

- PLAY3.BAS
- PLAY3 binary
- reconstructed XASM source
- preserved RAM/binary comparison

---

## Overview

PLAY3 is loaded by the BASIC loader into RAM starting at:

```text
BF000h
```

The driver body size is:

```text
0550h = 1360 bytes
```

Therefore the occupied range is approximately:

```text
BF000h - BF54Fh
```

---

## Top-Level Layout

```text
BF000-BF012  install routine
BF013-BF018  remove routine
BF019-BF025  BASIC command string table
BF026-BF03E  BASIC command dispatch table
BF03F-....   main driver code
....
BF479-BF4FA  tone table (mml_data)
BF4FB-BF50A  length table (length_data)
BF50B-BF54F  work area / runtime variables
```

---

## Detailed Map

## BF000-BF012 : install routine

This is the routine called to install the PLAY3 BASIC extension.

Source label:

```text
install
```

Function:

- writes BASIC command table pointer
- writes BASIC command dispatch pointer
- returns to BASIC

Approximate role:

```text
BASIC command installation
```

---

## BF013-BF018 : remove routine

Source label:

```text
remove
```

Function:

- removes installed BASIC commands
- clears table pointers
- calls initialization
- returns

Approximate role:

```text
BASIC command removal / EXOFF support
```

---

## BF019-BF025 : BASIC command string table

Source label:

```text
basic_command
```

Contents:

```text
04 'PLAY' 1F
05 'EXOFF' 02
00 00
```

Installed BASIC commands:

```text
PLAY
EXOFF
```

---

## BF026-BF03E : BASIC command dispatch table

Source label:

```text
basic_code
```

Approximate decoded structure:

```text
1F  -> PLAY   -> entry
8B  -> command-processing flag

02  -> EXOFF  -> remove
8B  -> command-processing flag
```

Resolved addresses:

```text
PLAY  -> BF03F
EXOFF -> BF013
```

---

## BF03F-.... : entry routine

Source label:

```text
entry
```

Function:

- saves interrupt state
- modifies interrupt mask
- saves BP/ABP-related work
- calls MML conversion
- calls initialization
- restores state
- returns to BASIC

Approximate role:

```text
PLAY command entry point
```

---

## BF040-BF0FF : initialization and MML conversion front-end

Main labels in this area:

```text
entry
mml_conv
mml_conv_lp
part_ch
temp2_ch
oct_ch
oct_up
oct_dw
```

Approximate functions:

- initialize conversion tables
- prepare MML destination buffers
- parse PLAY string
- process `:`
- process `T`
- process `O`
- process `<` / `>`
- process `L`
- process rests and note events

This area is the front-end parser that converts BASIC-side
MML-like input into internal driver data.

---

## BF100-BF1FF : MML event conversion area

Main labels likely located in this range:

```text
onp_set
onp_len
kyuufu
mml_conv_exit
len_ch
format_ch
part_ch
temp_ch
temp2_ch
oct_ch
```

Approximate functions:

- note conversion
- sharp/natural note handling
- default length handling
- tempo handling
- octave update
- part switching
- end-of-string handling

This region appears to be the core of the MML conversion stage.

---

## BF200-BF2FF : initialization and part setup

Main labels associated with this region:

```text
init1
init2
```

Approximate functions:

- reset per-part counters
- initialize octave defaults
- initialize length counters
- copy source data addresses for each part

This section prepares internal part state before playback begins.

---

## BF300-BF3FF : main playback control

Main labels associated with this region:

```text
main2
mml
mml_loop
mml_exit
mml_onp
```

Approximate functions:

- per-part event fetch
- shortest-length arbitration
- part activity tracking
- tone counter setup
- note length countdown
- loop control and return conditions

This is the main playback scheduler.

---

## BF400-BF478 : beep output / polyphonic timing routines

Main labels associated with this region:

```text
beep_out0
beep_out3
loop
loop1
part1_co1
part2_co1
part2_co2
part3_co1
part3_co2
part3_co3
part3_co4
```

Approximate functions:

- 0-voice silent delay loop
- 1/2/3 voice output timing
- software-mixed time-division polyphony
- direct writes to the beep register

This area contains the timing-critical sound generation loops.

---

## BF479-BF4FA : tone table (mml_data)

Source label:

```text
mml_data
```

Table type:

```text
pitch period / tone counter table
```

Structure:

- grouped by note
- each note contains values for octave 0-4

Beginning of table:

```text
000h 000h 000h 000h 000h   ; R
12Eh 097h 04Ch 026h 013h   ; C
11Dh 08Fh 048h 024h 012h   ; #C
10Dh 087h 044h 022h 011h   ; D
...
```

This table matches the reconstructed XASM source.

---

## BF4FB-BF50A : length table (length_data)

Source label:

```text
length_data
```

Values:

```text
03 06 09 0C 12
18 24 30 48 60
02 04 06 10 20 01
```

This table matches the reconstructed source listing.

---

## BF50B-BF54F : work area

This region appears to contain initialized and zeroed driver work variables.

Reconstructed source variables in this area:

```text
temp
count
count1
count2
count3
part1
part2
part3
r_flg
data_buff
```

Observed beginning:

```text
BF50B: 01 00 00 00 00 00 ...
```

Important note:

- reconstructed source currently says `temp: db 5`
- binary currently shows `01h` at the start of this area

This should be verified against the original listing.

---

## Functional Grouping

The PLAY3 memory map can be summarized as follows:

```text
BF000-BF03E  BASIC extension install/remove and dispatch
BF03F-BF1FF  MML conversion and command preprocessing
BF200-BF2FF  initialization and part setup
BF300-BF3FF  main playback control
BF400-BF478  timing-critical beep output routines
BF479-BF50A  static lookup tables
BF50B-BF54F  runtime work area
```

---

## Notes on Confidence

### Confirmed

The following are confirmed by direct binary/source comparison:

- load address `BF000h`
- body size `0550h`
- command strings `PLAY`, `EXOFF`
- dispatch targets `BF03F`, `BF013`
- tone table location `BF479`
- length table location `BF4FB`

### High confidence

The following are strongly supported by source structure and binary layout:

- install/remove regions
- entry region
- parser region
- main playback control region
- beep output region

### Tentative

The exact boundaries of some internal code regions remain approximate:

- sub-block divisions inside parser code
- exact start/end of scheduler internals
- exact split between playback logic and timing loops before the table area

These should be refined as label-to-address mapping progresses.

---

## Next Step

The next useful step is a full **label-to-address map**, for example:

```text
install   = BF000
remove    = BF013
entry     = BF03F
mml_conv  = ....
main2     = ....
beep_out3 = ....
mml_data  = BF479
length_data = BF4FB
```

This will allow one-to-one comparison between:

- reconstructed XASM source
- PLAY3 binary
- real RAM image
