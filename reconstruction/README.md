# PLAY3 Reconstruction

Reconstruction of the **PLAY3** three-voice buzzer music driver for the  
**SHARP PC-E500** pocket computer series.

Originally published in:

Pocket Computer Journal  
November 1993 issue

Author: **Ryu (Tatsuya Kobayashi / 小林龍也)**

---

# Purpose

The goal of this reconstruction is to recreate a readable and verifiable
assembly source for the historical PLAY3 driver while preserving the
structure of the original program.

The reconstruction process included:

- transcription of the magazine assembly listing
- OCR and manual correction
- normalization for the XASM assembler
- binary comparison against historical program data
- addition of explanatory comments

The resulting sources aim to preserve the original program logic while
making the code understandable for modern readers and researchers.

---

# Files

| File | Description |
|-----|-------------|
| play3_pushu.asm | Base reconstructed assembly source |
| play3_jp.asm | Japanese commented version |
| play3_en.asm | English commented version |

The commented versions were created to make the internal structure of
PLAY3 easier to understand without altering the original logic.

Only comments were added — the program code itself is identical.

---

# Reconstruction Process

The reconstruction involved several steps:

1. Magazine listing transcription
2. OCR correction from photographs
3. Syntax normalization for the XASM assembler
4. Structural verification through binary analysis
5. Comment annotation (Japanese and English)

The resulting sources represent the most readable reconstruction of the
original PLAY3 driver currently available.

---

# Historical Context

PLAY3 generates **three-voice polyphonic music using only the internal
1-bit piezo buzzer** of the SHARP PC-E500.

The program achieves this through a **software mixing technique**
implemented entirely in assembly language.

By precisely controlling CPU timing and pulse output, PLAY3 produces the
illusion of multiple simultaneous sound channels from a single digital
buzzer.

This technique represents a distinctive form of software sound synthesis
found in Japanese pocket computer programming of the early 1990s.

---

# Related Documentation

Additional technical analysis and documentation can be found in:

analysis/  
docs/  
drivers/

These directories contain:

- algorithm analysis
- binary comparison reports
- translated magazine documentation
- related driver programs

---

# Project

PLAY3 Archive  
https://github.com/gikonekos/PLAY3-Archive
