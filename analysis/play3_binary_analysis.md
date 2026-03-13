# PLAY3 Binary Analysis

Binary analysis of the **PLAY3 three-voice music driver**  
for the **SHARP PC-E500** series.

Sources used for this analysis:

- PLAY3.BAS (BASIC loader)
- PLAY3 binary
- reconstructed XASM source
- *Pocket Computer Journal* (November 1993 issue)

---

## Binary Structure

The PLAY3 binary consists of a header followed by the driver body.

```
PLAY3 binary
├ header (16 bytes)
└ driver body (1360 bytes)
```

The driver body corresponds exactly to the DATA block written by `PLAY3.BAS`.

```
PLAY3.BAS DATA → written to RAM BF000h
```

---

## Header Format

First 16 bytes of the PLAY3 binary:

```
FF 00 06 01 10 50 05 00
00 F0 0B FF FF FF 00 0F
```

Important value:

```
50 05 = 0550h = 1360
```

This matches the size of the PLAY3 driver body.

Therefore:

```
total file size = header (16) + driver body (1360)
```

---

## BASIC Command Installation

PLAY3 installs two BASIC commands:

```
PLAY
EXOFF
```

These commands are inserted into the BASIC command table.

Command dispatch table:

```
PLAY  → entry  BF03F
EXOFF → remove BF013
```

---

## Driver Memory Layout

Approximate structure of the PLAY3 driver in RAM:

```
BF000  install routine
BF013  remove routine
BF03F  entry routine

BFxxx  MML parser
BFxxx  playback routines

BF479  tone table (mml_data)
BF4FB  length table (length_data)
BF50B  work area
```

---

## Tone Table (mml_data)

Location:

```
BF479
```

Example values:

```
000h 000h 000h 000h 000h   ; rest
12Eh 097h 04Ch 026h 013h   ; C
11Dh 08Fh 048h 024h 012h   ; #C
```

These values match the reconstructed XASM source.

---

## Length Table (length_data)

Location:

```
BF4FB
```

Values:

```
03 06 09 0C 12
18 24 30 48 60
02 04 06 10 20 01
```

These values match the reconstructed source listing.

---

## Work Area

Immediately after the length table appears the driver work area.

Example:

```
BF50B: 01 00 00 00 00 00 ...
```

This area corresponds to variables defined in the reconstructed source:

```
temp
count
count1
count2
count3
part1
part2
part3
```

---

## Difference Found

Reconstructed source:

```
temp: db 5
```

Binary value:

```
temp = 01h
```

This value should be verified against the original magazine listing.

---

## Comparison with PLAY2

Driver sizes:

```
PLAY2 body  = 986 bytes
PLAY3 body  = 1360 bytes
```

PLAY3 appears to be an expanded evolution of the PLAY2 architecture.

Common elements:

- BASIC command installation
- MML parser concept
- tone tables
- length tables

PLAY3 includes additional routines and larger internal structures.

---

## Notes

This analysis is based on preserved binaries and reconstructed source code.

Some addresses are approximate and may be refined as the reconstruction
process continues.
