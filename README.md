Reconstruction and historical archive of PLAY3, a 1993 software music driver that produces three-voice polyphonic music on the single 1-bit buzzer of the SHARP PC-E500 pocket computer.

Originally published in Pocket Computer Journal (November 1993).

# PLAY3 Archive

Archive of the **PLAY3 three-voice music routine**  
for the **SHARP PC-E500 pocket computer series**.

Originally published in:

Pocket Computer Journal  
November 1993 issue
---
## Demo

PLAY3 running on a SHARP PC-E500.
The video shows the PLAY3 driver playing the example music "VEZAR".

[![PLAY3 demo](https://img.youtube.com/vi/pbo1Mc-6PrA/0.jpg)](https://youtu.be/pbo1Mc-6PrA)

Video demonstration of the reconstructed PLAY3 driver running on real hardware.
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

The reconstructed binary has been verified against RAM dumps
taken from a real SHARP PC-E500.
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

## Technical Overview

PLAY3 is a software music driver for the **SHARP PC-E500** pocket computer, originally published in *Pocket Computer Journal* (1993).  
The program demonstrates an advanced technique for generating **three-voice polyphonic music using only the internal piezo buzzer**, which normally supports only single-tone output.

## PLAY3 Architecture

```
MML text (PLAY command)
        │
        ▼
+--------------------+
|  MML Parser        |
|  (note / command)  |
+--------------------+
        │
        ▼
+--------------------+
|  Event Scheduler   |
|  (minimum length)  |
+--------------------+
        │
        ▼
+--------------------+
|  Voice Manager     |
|  part1 part2 part3 |
+--------------------+
        │
        ▼
+--------------------+
|  Software Mixer    |
|  ~20 kHz loop      |
+--------------------+
        │
        ▼
   PC-E500 Buzzer
```

PLAY3 converts MML commands into note events, schedules them using the minimum
remaining duration among all voices, and generates sound using a high-speed
software mixer loop.

Despite the PC-E500 having only a single piezo buzzer, the mixer rapidly
switches between three independent frequency counters, allowing the ear to
perceive simultaneous tones.

### MML Playback Engine

PLAY3 interprets a simplified **Music Macro Language (MML)** format embedded in the BASIC `PLAY` command.

Supported commands include:

- Note letters (`C D E F G A B`)
- Sharp (`#`)
- Octave control (`O`, `<`, `>`)
- Note length (`L`)
- Tempo (`T`)
- Rest (`R`)

The MML parser converts the text stream into internal note events consisting of:

- pitch index
- octave
- length value

These values are translated using lookup tables (`mml_data` and `length_data`) stored in the program.

### Event Scheduler

PLAY3 uses an **event-driven scheduler** rather than stepping each voice independently.

For each playback cycle:

1. The remaining note lengths of all active voices are compared.
2. The **minimum length** among the voices is selected.
3. All voice counters are reduced by that value.
4. The resulting time slice is rendered by the sound generator.

This approach keeps all voices synchronized while minimizing interpreter overhead.

### Three-Voice Software Mixer

The SHARP PC-E500 provides only a **single piezo buzzer**, so PLAY3 implements a software mixer.

The mixer works as follows:

- Each voice maintains its own **frequency counter**.
- A high-speed loop (~48 µs per iteration) repeatedly updates these counters.
- When a counter reaches zero, the buzzer output toggles and the counter reloads.

Because the loop runs at approximately **20 kHz**, the rapid toggling of multiple square waves is perceived by the human ear as simultaneous tones.

This technique effectively creates a **three-voice software PSG (Programmable Sound Generator)**.

### Self-Modifying Sound Routine

To improve performance, PLAY3 dynamically writes frequency values directly into the sound routine.

During event setup:

- voice frequency counters are written into the instruction stream
- the mixer loop reads these values without additional memory lookups

This **self-modifying code** significantly reduces the CPU cost of the mixer.

### Timing Characteristics

The core sound loop operates at roughly:

- **37 CPU states per iteration**
- **≈48 µs loop time**

This yields a loop frequency of approximately:

- **~20 kHz update rate**

Such a high refresh rate allows the time-division multiplexing method to produce stable multi-voice audio on hardware designed for single-tone output.

### Significance

PLAY3 represents an impressive example of late-era pocket computer programming:

- efficient MML interpretation
- event-based sequencing
- real-time multi-voice sound synthesis
- careful cycle-level timing optimization

Despite the extremely limited hardware of the PC-E500, PLAY3 achieves expressive polyphonic music entirely through software techniques.

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

Despite having only a single 1-bit piezo buzzer output,
PLAY3 achieves three-voice polyphonic music using
cycle-accurate time-division sound synthesis.
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

## Historical sources

Some historical PC-E500 materials were recovered from archived websites.

Internet Archive (Wayback Machine):
https://web.archive.org/web/20160303221141/http://www46.atpages.jp/~qptn/cgi-bin/up/stored/E500.zip

The archive contains preserved PC-E500 binaries that helped verify
the reconstructed PLAY3 driver.

# Copyright

The original PLAY3 program was published in:

Pocket Computer Journal  
November 1993 issue

All original program rights belong to the respective authors and publishers.

This repository is intended for:

- historical preservation  
- technical research  
- educational purposes

---

# Quick Start

To run PLAY3 on a real **SHARP PC-E500**:

1. Load the BASIC loader program.
2. Execute the loader to write the driver into RAM.
3. The loader installs the PLAY3 driver at:

BF000h

4. After installation, the following commands become available:

PLAY  
EXOFF  

Example:

PLAY "T5O3CDEFG"

The driver interprets the MML string and generates three-voice music
using software time-division sound synthesis.

---

# Running on Real Hardware

PLAY3 was designed specifically for the **SHARP PC-E500 series**.

Compatible models include:

- PC-E500  
- PC-E500S  
- PC-E550  
- PC-E650  

Because the driver relies on **cycle-accurate timing**, behaviour may vary
on emulators unless the CPU timing is accurately reproduced.

Testing in this project was performed using:

- real PC-E500 hardware  
- RAM dump comparison with reconstructed binaries

---

# Reconstruction Method

The reconstruction process used in this archive includes several stages:

1. Magazine listing transcription  
2. OCR verification against original scans  
3. Manual correction of OCR errors  
4. Assembly reconstruction using XASM syntax  
5. Binary generation  
6. Verification against RAM dumps from real hardware  

This process ensures that the reconstructed driver matches the behaviour
of the original program as closely as possible.

---

# Why This Project Matters

Japanese pocket computers represent a unique programming culture that is
poorly documented outside Japan.

Many programs were distributed only through magazine listings and have
never been preserved digitally.

PLAY3 is an example of advanced programming techniques used by hobbyist
programmers to overcome hardware limitations.

Despite having only a **single piezo buzzer**, PLAY3 achieves
three-voice polyphonic music playback entirely in software.

Projects like this help preserve an important part of computing history.

This archive contains the reconstruction of PLAY3 for the SHARP PC-E500,
originally published in Pocket Computer Journal (1993).

The binary used for verification was obtained directly from the original
author. The project aims to reconstruct the original XASM source so that
the reassembled binary matches the original program.

---

# Contributing

Contributions are welcome.

Possible areas for improvement include:

- improving the assembly reconstruction  
- refining the driver memory map  
- documenting the internal timing model  
- adding additional PLAY3 music examples  
- locating additional magazine material related to PLAY2 / PLAY3  

If you have historical information about **Pocket Computer Journal**
music drivers, please open an issue.

---

# Related Projects

Other historical software sound drivers for the SHARP pocket computer
series include:

PLAYX  
PLAY2  
PLAY2L  

PLAYX appears to have been written by a different author and represents
a separate implementation lineage.

Further research is ongoing.

---

# License

This repository contains archival material originally published in a
commercial magazine.

The included materials are provided for:

- historical preservation  
- research and documentation  
- educational purposes  

If you are the original author or copyright holder and have concerns,
please contact the repository maintainer.

---

## Credits

Original program  
PLAY3  
(C) 1993 Ryu (Tatsuya Kobayashi / 小林龍也)

Archive and reconstruction  
Kenkichi Motoi (gikonekos)

Source publication  
Pocket Computer Journal, 1993

---

## Original Author

PLAY3 was originally written by **Ryu (Tatsuya Kobayashi / 小林龍也)**.

He was an active contributor to Japanese pocket computer magazines and
a user of the "Pocket Communication" BBS community during the early 1990s.

Kobayashi was known for his deep understanding of pocket computer hardware
and for developing advanced software techniques that pushed the limits
of the SHARP PC-E500 series.

PLAY3 is a notable example: it produces three-voice polyphonic music
using only the internal piezo buzzer through carefully timed software mixing.

---

# Author

Archive project by:

Kenkichi Motoi  
(gikonekos)

Dedicated to preserving the history of Japanese pocket computer software.
