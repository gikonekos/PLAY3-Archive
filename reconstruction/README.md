# PLAY3 Reconstruction

Binary reconstruction attempt of a historical pocket computer music driver.

This directory contains the reconstruction work for **PLAY3**, a three-voice music driver for the **SHARP PC-E500** series pocket computers.

The purpose of this reconstruction is to recreate the original assembly source and verify whether the generated binary matches the historical program distributed with the magazine article.

Original publication:

Pocket Computer Journal  
November 1993 issue

Author: Ryu (Tatsuya Kobayashi / 小林龍也)

---

# Reconstruction Overview

The reconstruction process used multiple sources:

* magazine article scans
* photograph-based OCR of the printed assembly listing
* manual correction and normalization for the XASM assembler
* binary comparison against the original PLAY3 program

The goal is **binary identity** with the original program.

---

# Files

## PLAY3

Original program binary.

This file represents the historical PLAY3 driver distributed with the magazine program.  
It is used as the **reference binary** for reconstruction verification.

---

## play3photo.asm

Assembly source reconstructed from **photographs of the magazine listing** using OCR.

Characteristics:

* direct transcription from the printed source
* contains OCR corrections
* formatting may differ from the original listing
* not directly suitable for assembly without further normalization

---

## play3_xasm.asm

Normalized assembly source prepared for the **XASM assembler**.

Changes from the photo transcription include:

* syntax normalization
* label formatting adjustments
* directives adapted for XASM compatibility

This file is intended to assemble successfully with **XASM 1.40**.

---

## play3_xasm.obj

Object file produced by assembling `play3_xasm.asm` using XASM.

The assembly process can be reproduced with:

```
xasm play3_xasm.asm
```

The resulting object file is deterministic and reproducible with XASM 1.40.

---

# Verification Results

Reassembly using **XASM 1.40** successfully produces the object file without errors.

Reproduced object file:

```
play3_xasm.asm → play3_xasm.obj
```

The generated object file matches the distributed `play3_xasm.obj`.

However, comparison against the historical program binary shows that the files are **not identical**.

Observed values:

| File | Size |
|-----|------|
| PLAY3 | 1376 bytes |
| play3_xasm.obj | 1407 bytes |

This indicates that at least one of the following is true:

* the magazine-distributed `PLAY3` binary was processed after assembly
* the reconstructed source still differs slightly from the original
* the XASM object format differs from the final executable layout used in the magazine program

Further investigation is required to determine the exact transformation between the assembled object and the distributed binary.

---

# Reconstruction Status

Current status:

* assembly reconstruction: **complete**
* XASM build: **reproducible**
* binary identity with PLAY3: **not yet confirmed**

The reconstruction source is considered stable, but additional analysis may be required to determine the final binary layout used in the original distribution.

---

# Historical Notes

PLAY3 is notable for producing **three-voice polyphonic music using only the internal 1-bit piezo buzzer** of the SHARP PC-E500.

The program achieves this through a **software mixing technique implemented entirely in assembly language**, using precise timing and CPU-controlled pulse output.

This type of software sound synthesis was a characteristic technique in Japanese pocket computer programming during the early 1990s.

---

# Related Materials

Additional documentation and analysis can be found in:

```
analysis/
docs/
drivers/
```

These directories contain technical explanations, translated magazine text, and related driver programs.

## Binary verification

Detailed comparison between the reconstructed binary and the original PLAY3 program:

- [Binary verification report](play3_binary_verification.md)
