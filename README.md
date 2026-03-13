# PLAY3 Archive

Archive of the PLAY3 three-voice music routine  
for the SHARP PC-E500 pocket computer series.

Originally published in:

Pocket Computer Journal  
November 1993 issue

## Contents

- PLAY3 BASIC loader  
- PLAY3 machine code (RAM dump)  
- XASM source reconstruction  
- Example music (VEZAR)

## Purpose

This repository preserves historical pocket computer music software.

PLAY3 is a three-voice time-division polyphonic music routine for the  
SHARP PC-E500 series.

The goal of this project is to reconstruct the original driver from the
magazine listing and preserved binaries, and document its internal structure.

## Project goals

The goal of this project is to create a complete archival reconstruction of
the PLAY3 music driver.

This includes:

- Exact transcription of the magazine listing
- XASM compatible assembly reconstruction
- Binary generation
- Verification against real machine RAM dumps

## Driver architecture

PLAY3 is installed as a machine code extension to BASIC.

The BASIC loader writes the driver into RAM starting at:

    BF000h

After loading, the loader executes:

    CALL &BF000

This routine installs new BASIC commands such as:

    PLAY
    EXOFF

## PLAY command syntax

PLAY3 provides a BASIC command for music playback using an MML-like string.

Example:

    PLAY "T5O3CDEFG"

Typical parameters include:

    T   tempo
    O   octave
    C D E F G A B   notes
    R   rest
    L   note length

The exact command syntax and parameter ranges should follow the original
implementation and magazine listing.

Multiple voices are handled internally by the driver using
time-division polyphony.

## Memory layout (approximate)

The internal structure of the PLAY3 driver is roughly organized as follows:

    BF000  command installation entry
    BF020  command table
    BF040  initialization routine
    BFxxx  MML parser
    BFxxx  voice playback routines
    BFxxx  driver tables

This structure is currently under analysis.

## PLAY3 driver memory map (analysis)

Current reverse engineering suggests the following approximate layout:

    BF000  driver entry / command installation
    BF020  BASIC command table
    BF040  driver initialization
    BF080  MML parser
    BFA00  voice playback routines
    BFC00  internal tables and data

This map will be refined as the XASM reconstruction progresses.

## Related drivers

Other three-voice music drivers for the PC-E500 series include:

- PLAYX  
- PLAY2  
- PLAY2L  

PLAYX was written by a different author and represents a separate
implementation lineage.

PLAY2 and PLAY3 appear to belong to the same driver architecture family.

## Encoding note

Some files preserve the original Japanese source encoding  
(CP932 with half-width katakana). Viewing them as UTF-8 may cause garbled text.

## Status

- BASIC loader : preserved  
- RAM binary : preserved  
- XASM source : reconstruction in progress

## Copyright

The original PLAY3 program was published in Pocket Computer Journal  
(November 1993 issue).

All original program rights belong to the respective authors and publishers.

This repository is intended for historical preservation, research, and
educational purposes.

If there are any copyright concerns, please contact the repository owner.
