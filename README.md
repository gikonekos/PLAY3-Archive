# PLAY3 Archive

Reconstruction and historical archive of **PLAY3**,  
a three-voice buzzer music driver for the **SHARP PC-E500 pocket computer series**.

PLAY3 produces **three-voice polyphonic music from a single 1-bit internal buzzer**  
using a software mixing technique.

Originally published in:

Pocket Computer Journal — November 1993

This repository preserves both:

- the **original magazine source listing**
- a **verified reconstructed assembly build**

---

# Overview

PLAY3 is a software music driver for the **SHARP PC-E500 / PC-E550 pocket computer series**.

The driver produces **three-voice polyphonic music** from the machine's  
single internal buzzer by using precise CPU timing and rapid  
time-division switching between notes.

The original program was published in:

Pocket Computer Journal – November 1993

This repository reconstructs the original assembler source code from  
magazine listings and verifies the result against the historical binary.

---

# Demo

Tested and verified on **real SHARP PC-E550 hardware**.

[![PLAY3 demo](https://img.youtube.com/vi/pbo1Mc-6PrA/0.jpg)](https://youtu.be/pbo1Mc-6PrA)

Demonstrations of music playback on the SHARP PC-E500 / PC-E550 pocket computers  
using the reconstructed PLAY3 driver.

The videos show example music programs running on **real hardware**.

Full playlist:

https://youtube.com/playlist?list=PL0MMNZ2b8g1aup5tHZkTpCn9zczGLA3Rw

---

# System overview

PC-E500 Pocket Computer  
↓  
internal 1-bit piezo buzzer  
↓  
PLAY2 / PLAY2L / PLAY3 driver  
↓  
software mixing (time-division multiplexing)  
↓  
3-voice polyphonic music

Example usage:

- Dash! (1994 RPG floor BGM)
- Holy Night
- SAMPLE
- VEZAR
- Bottakuri Shouten

Later used in the PC-98 game:

Space Panicco (1994)

PLAY3 belongs to the **PLAY-series buzzer music drivers**, which extend the  
BASIC PLAY command and allow polyphonic music on the SHARP PC-E500 series.

---

# About PLAY3

PLAY3 is a software routine that generates **three simultaneous voices**  
using the internal piezo buzzer.

Since the hardware only supports a **single tone output**, the driver rapidly  
switches between multiple note periods in a time-division manner, creating  
the perception of polyphonic sound.

This technique represents a form of **software sound synthesis** commonly  
used in Japanese pocket computer programming during the early 1990s.

---

# Repository structure

```
PLAY3-Archive
│
├─ analysis/
│
├─ docs/
│
├─ drivers/
│
├─ examples/
│   ├─ VEZAR/
│   ├─ botta/
│   ├─ dash/
│   ├─ holy/
│   └─ sample/
│
├─ reconstruction/
│
└─ work/
```

---

# Authors

PLAYX  
Keita Morita (森田敬太)

PLAY2 / PLAY2L / PLAY3  
Ryu (Tatsuya Kobayashi / 小林龍也)

Project archive and reconstruction and examples

Kenkichi Motoi (基建吉)

---

# Original sample music

Original sample music (1993)

- SAMPLE.bas — Kazusumi Matsuki (松樹一純)

Later music using PLAY-series drivers

- Dash!
- VEZAR
- Bottakuri Shouten

---

# Binary comparison

original body size : 1360 bytes  
reconstructed build : 1369 bytes  
difference : +9 bytes

Remaining difference explained by:

mml_conv routine difference : −11 bytes  
beep_out3 initialization block : +28 bytes  
trailing binary padding : −8 bytes  

Total difference : **+9 bytes**

---

# Research assistance

Parts of the reconstruction were assisted by AI systems used as research tools.

Claude (Anthropic)  
ChatGPT (OpenAI)

Final verification and editorial decisions were performed by the repository maintainer.

---

# Purpose of this archive

This project preserves:

- original magazine publication
- reconstructed XASM source code
- example music programs
- technical analysis of the driver

as documentation of **buzzer-based polyphonic music systems** on pocket computers.

---

# Historical significance

During the late 1980s and early 1990s, Japanese pocket computers such as the  
SHARP PC-E500 were widely used by hobbyist programmers and magazine readers.

Because these machines only provided a **single 1-bit internal buzzer**,  
polyphonic music was normally impossible on the hardware.

Drivers such as **PLAY2 / PLAY2L / PLAY3** solved this limitation by using  
precise CPU timing and rapid time-division switching between note periods,  
creating the perception of multiple simultaneous voices.

This technique represents an early form of **software sound synthesis** on  
limited hardware, similar in spirit to software audio techniques used on  
other contemporary systems.

Programs like PLAY3 illustrate an important aspect of the Japanese  
microcomputer hobbyist culture of the period:

- magazine-published program listings
- reader reconstruction and experimentation
- creative techniques to overcome hardware limitations

By reconstructing and verifying the original assembler source code,  
this archive preserves both the **technical implementation** and the  
**historical context** of buzzer-based polyphonic music systems on  
Japanese pocket computers.

---

# Related projects

Building Rescue Archive  
https://github.com/gikonekos/Building-Rescue-Archive
