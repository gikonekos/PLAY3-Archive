# PLAY3 Archive

Archive of the **PLAY3 three-voice music routine**  
for the **SHARP PC-E500 pocket computer series**.

Originally published in:

Pocket Computer Journal  
November 1993 issue

---

# Documentation

Original magazine article transcription and translation:

- **Japanese transcription**  
  docs/scanned_readme(jp).md

- **English translation**  
  docs/scanned_readme(en).md

Original scans are preserved in:

docs/scans

---

# Contents

This repository contains:

- PLAY3 BASIC loader  
- PLAY3 machine code (RAM dump)  
- XASM source reconstruction  
- Example music (VEZAR)  
- Original article scans  
- Article transcription (JP / EN)

---

# Purpose

This repository preserves historical **pocket computer music software**.

PLAY3 is a **three-voice time-division polyphonic music routine** for the  
SHARP PC-E500 series.

The goal of this project is to:

- preserve the original magazine material  
- reconstruct the driver from the listing  
- analyze the internal architecture  
- document the driver for historical and technical reference

---

# Project Goals

The goal of this project is to create a **complete archival reconstruction** of
the PLAY3 music driver.

This includes:

- exact transcription of the magazine listing  
- XASM compatible assembly reconstruction  
- binary generation  
- verification against real machine RAM dumps  
- documentation of the driver architecture

---

# Driver Architecture

PLAY3 is installed as a **machine code extension to BASIC**.

The BASIC loader writes the driver into RAM starting at:

BF000h

After loading, the loader executes:

CALL &BF000

This routine installs new BASIC commands:

PLAY  
EXOFF

---

# PLAY Command Syntax

PLAY3 provides a BASIC command for music playback using an **MML-like string**.

Example:

PLAY "T5O3CDEFG"

Typical parameters include:

T   tempo  
O   octave  
C D E F G A B   notes  
R   rest  
L   note length  

Multiple voices are handled internally by the driver using  
**time-division polyphony**.

---

# Memory Layout (Approximate)

BF000  command installation entry  
BF020  command table  
BF040  initialization routine  
BFxxx  MML parser  
BFxxx  voice playback routines  
BFxxx  driver tables  

---

# PLAY3 Driver Memory Map (Analysis)

BF000  driver entry / command installation  
BF020  BASIC command table  
BF040  driver initialization  
BF080  MML parser  
BFA00  voice playback routines  
BFC00  internal tables and data  

This map will be refined as the **XASM reconstruction progresses**.

---

# Driver Evolution

PLAYX  (PJ 1992)  
↓  
PLAY2  
↓  
PLAY3  (PJ 1993)

PLAYX was written by a different author and represents a separate
implementation lineage.

PLAY2 and PLAY3 appear to belong to the same driver architecture family.

---

# Pocket Computer Music Driver History

The SHARP PC-E500 series has a long history of software music drivers
developed by magazine authors and hobby programmers.

Because the hardware only provides a **single piezo buzzer**, polyphonic
sound must be simulated in software.

Typical techniques include:

- rapid time-division waveform switching  
- cycle-accurate buzzer toggling  
- software scheduling of virtual voices  

PLAY3 demonstrates that **three-voice polyphonic playback** is possible on
hardware originally designed for simple single-tone beeps.

---

# Technical Overview

PLAY3 implements **three-voice polyphony using time-division sound generation**.

The driver:

- parses MML data  
- schedules note timing for each voice  
- toggles the buzzer according to combined timing events  

Because this method depends on precise instruction timing,
the driver is tuned to the **2.3 MHz system clock**.

---

# Driver Internal Architecture (Analysis)

command_hook  
    installs PLAY and EXOFF into BASIC command table

mml_parser  
    reads MML string following PLAY command  
    converts notes into internal timing data

voice_scheduler  
    manages three independent voice streams

tone_generator  
    toggles piezo buzzer using cycle-accurate timing

driver_tables  
    note frequency table  
    duration table

---

# Encoding Note

Some files preserve the **original Japanese source encoding**
(CP932 with half-width katakana).

Viewing them as UTF-8 may cause garbled characters.

---

# Status

BASIC loader   : preserved  
RAM binary     : preserved  
XASM source    : reconstruction in progress  
Documentation  : in progress  

---

# Copyright

The original PLAY3 program was published in:

Pocket Computer Journal  
November 1993 issue

All original program rights belong to the respective authors and publishers.

This repository is intended for:

- historical preservation  
- technical research  
- educational purposes
