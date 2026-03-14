# PLAY3 Archive

Reconstruction and historical archive of **PLAY3**, a 1993 software music
driver that produces **three-voice polyphonic music on the single 1-bit
buzzer of the SHARP PC-E500 pocket computer**.

Originally published in:

Pocket Computer Journal  
November 1993 issue

---

## Demo

PLAY3 running on a SHARP PC-E500.

The video shows the PLAY3 driver playing the example music **"VEZAR"**.

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

The goal of this project is to create a **complete archival reconstruction**
of the PLAY3 music driver.

This includes:

- exact transcription of the magazine listing  
- XASM compatible assembly reconstruction  
- binary generation  
- verification against real machine RAM dumps  
- documentation of the driver architecture

The reconstructed binary has been verified against RAM dumps taken from a
real SHARP PC-E500.

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

# Driver Memory Map (Approximate)

BF000  driver entry / command installation  
BF020  BASIC command table  
BF040  driver initialization  
BF080  MML parser  
BFA00  voice playback routines  
BFC00  internal tables and data  

This map will be refined as the **XASM reconstruction progresses**.

---

## Technical Overview

PLAY3 is a software music driver for the **SHARP PC-E500** pocket computer,
originally published in *Pocket Computer Journal* (1993).

The program demonstrates an advanced technique for generating
**three-voice polyphonic music using only the internal piezo buzzer**, which
normally supports only single-tone output.

---

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

PLAY3 converts MML commands into note events and schedules them across three
independent voices using a **minimum-length event scheduler**.

Although the SHARP PC-E500 provides only a single piezo buzzer, PLAY3
generates polyphonic sound by rapidly switching between three frequency
counters inside a high-speed software mixing loop running at roughly
**20 kHz**.

This technique allows the listener to perceive simultaneous tones, effectively
implementing a **three-voice software sound generator** entirely in software.

---

### MML Playback Engine

PLAY3 interprets a simplified **Music Macro Language (MML)** format embedded
in the BASIC `PLAY` command.

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

These values are translated using lookup tables (`mml_data` and `length_data`)
stored in the program.

---

### Event Scheduler

PLAY3 uses an **event-driven scheduler** rather than stepping each voice
independently.

For each playback cycle:

1. Remaining note lengths of all voices are compared  
2. The **minimum length** is selected  
3. All counters are reduced by that value  
4. The resulting time slice is rendered by the sound generator

This approach keeps all voices synchronized while minimizing interpreter
overhead.

---

### Three-Voice Software Mixer

The SHARP PC-E500 provides only a **single piezo buzzer**, so PLAY3 implements
a software mixer.

The mixer works as follows:

- each voice maintains its own **frequency counter**  
- a high-speed loop (~48 µs per iteration) updates these counters  
- when a counter reaches zero, the buzzer output toggles and reloads

Because the loop runs at roughly **20 kHz**, the rapid toggling of multiple
square waves is perceived as simultaneous tones.

This effectively creates a **three-voice software PSG**.

---

### Self-Modifying Sound Routine

To improve performance, PLAY3 dynamically writes frequency values directly
into the sound routine.

During event setup:

- frequency counters are written into the instruction stream  
- the mixer loop reads them without additional memory lookups

This **self-modifying code** reduces CPU overhead.

---

### Timing Characteristics

The core sound loop operates at roughly:

- **37 CPU states per iteration**  
- **≈48 µs loop time**

This yields an update rate of approximately:

- **~20 kHz**

Such a high refresh rate allows stable multi-voice audio despite the
single-bit buzzer hardware.

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
hardware originally designed for simple beeps.

---

# Status

BASIC loader   : preserved  
RAM binary     : preserved  
XASM source    : reconstruction in progress  
Documentation  : in progress

---

## Historical Sources

Some PC-E500 materials were recovered from archived websites.

Internet Archive (Wayback Machine):

https://web.archive.org/web/20160303221141/http://www46.atpages.jp/~qptn/cgi-bin/up/stored/E500.zip

The archive contains preserved PC-E500 binaries that helped verify the
reconstructed PLAY3 driver.

---

# Quick Start

To run PLAY3 on a real **SHARP PC-E500**:

1. Load the BASIC loader program  
2. Execute the loader  
3. The driver installs at:

BF000h

4. After installation the following commands are available:

PLAY  
EXOFF  

Example:

PLAY "T5O3CDEFG"

---

# Running on Real Hardware

Compatible models include:

- PC-E500  
- PC-E500S  
- PC-E550  
- PC-E650  

Because the driver relies on **cycle-accurate timing**, behaviour may vary
on emulators.

Testing in this project was performed using:

- real PC-E500 hardware  
- RAM dump comparison

---

# Reconstruction Method

The reconstruction process includes:

1. magazine listing transcription  
2. OCR verification against scans  
3. manual correction of OCR errors  
4. XASM assembly reconstruction  
5. binary generation  
6. RAM dump comparison with real hardware

---

# Why This Project Matters

Japanese pocket computers represent a unique programming culture that is
poorly documented outside Japan.

Many programs were distributed only through magazine listings and have
never been preserved digitally.

PLAY3 demonstrates advanced techniques used by hobbyist programmers to
overcome severe hardware limitations.

Despite having only a **single piezo buzzer**, PLAY3 achieves three-voice
polyphonic music playback entirely in software.

Projects like this help preserve an important part of computing history.

---

# Contributing

Contributions are welcome.

Possible areas:

- improving the assembly reconstruction  
- refining the driver memory map  
- documenting timing behaviour  
- adding PLAY3 music examples

---

# Related Projects

PLAYX  
PLAY2  
PLAY2L  

PLAYX appears to have been written by a different author.

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

# Credits

Original program  
PLAY3  
(C) 1993 Ryu (Tatsuya Kobayashi / 小林龍也)

Archive and reconstruction  
Kenkichi Motoi (gikonekos)

Source publication  
Pocket Computer Journal, 1993

---

# Original Author

PLAY3 was written by **Ryu (Tatsuya Kobayashi / 小林龍也)**.

He was an active contributor to Japanese pocket computer magazines and a
user of the **Pocket Communication BBS** community in the early 1990s.

PLAY3 is a notable example of advanced software techniques for the
SHARP PC-E500 platform.

---

# Author

Archive project by:

Kenkichi Motoi  
(gikonekos)

Dedicated to preserving the history of Japanese pocket computer software.
