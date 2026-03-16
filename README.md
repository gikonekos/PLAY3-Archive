A historically verified reconstruction of the PLAY3 three-voice buzzer music driver, including scan-faithful source transcription and byte-level binary comparison.
# PLAY3 Archive

Archive and reconstruction of the PLAY3 three-voice buzzer music driver for the SHARP PC-E500 / PC-E550 pocket computers (1993)

Reconstruction and historical archive of **PLAY3**,  
a three-voice buzzer music driver for the **SHARP PC-E500 pocket computer series**.

PLAY3 produces **three-voice polyphonic music from a single 1-bit internal buzzer**
using software mixing.

The original program was published in:

**Pocket Computer Journal – November 1993**

---

## Demo

Demonstrations of music playback on the SHARP PC-E500 / PC-E550 pocket computers using the PLAY3 software music driver.  
These videos show reconstructed programs and example songs running on real hardware.

Watch the full playlist:

https://youtube.com/playlist?list=PL0MMNZ2b8g1aup5tHZkTpCn9zczGLA3Rw

---

## System overview

```
PC-E500 Pocket Computer
        │
        │ internal 1-bit piezo buzzer
        ▼
PLAY2 / PLAY2L / PLAY3 driver
        │
        │ software mixing (time-division multiplexing)
        ▼
3-voice polyphonic music
        │
        ├─ Dash! (1994 RPG floor BGM)
        ├─ Holy Night
        ├─ VEZAR
        └─ Bottakuri Shouten
              │
              ▼
      Later used in PC-98 game
      "Space Panicco" (1994)
```

---

## About PLAY3

PLAY3 is a software music routine that generates **three simultaneous voices**
using the internal piezo buzzer of the SHARP PC-E500 series.

Since the hardware only supports a single tone output, the driver rapidly
switches between notes in a time-division manner, creating the perception
of polyphonic sound.

---

## Repository contents

This repository contains reconstruction material and historical documents
related to the PLAY3 driver.

```
analysis/        technical analysis and algorithm notes
docs/            magazine scans and documentation
drivers/         related sound driver material
examples/        example music programs
reconstruction/  reconstructed XASM source code
```

---

## Example music

The `examples` directory contains original music programs written for the
PLAY-series buzzer drivers.

Included examples:

- **VEZAR** – demonstration program
- **Dash!** – RPG floor BGM (1994)
- **Holy Night** – Silent Night arrangement
- **Bottakuri Shouten** – early music later used in the PC-98 game  
  *Space Panicco (すぺーすぱにっ娘)*

These programs illustrate how music was composed for buzzer-based
polyphonic drivers on pocket computers.

Some example music programs originate from the 1990s,
while others were newly created in 2025 to demonstrate
the reconstructed PLAY3 driver.

---

## Authors

PLAY-series music driver authors:

- **PLAYX** — Keita Morita
- **PLAY2 / PLAY2L / PLAY3** — Ryu (Tatsuya Kobayashi / 小林龍也)

Example music in this repository:

- **Kenkichi Motoi (基建吉)**

---

## Historical context

Some example programs document music that later appeared in
**PC-98 MS-DOS games**, illustrating the relationship between
pocket computer music and early Japanese PC game soundtracks.

For example:

**"Bottakuri Shouten" (1994-05-11)**  
was later used as background music in the PC-9801 game:

**Space Panicco (すぺーすぱにっ娘)**  
Released: **1994-09-20**

---

## Purpose of this archive

This project aims to preserve:

- the original magazine publication
- reconstructed XASM source code
- working example music programs
- technical analysis of the driver

as historical documentation of **buzzer-based polyphonic music systems**
on pocket computers.

---

## Reconstruction status

The PLAY3 source code in this repository has been reconstructed from the
original magazine listing and verified against the scanned pages.

A byte-by-byte comparison was performed between the reconstructed XASM build
and the historical binary distributed with the magazine.

Results:

original body size   : 1360 bytes  
reconstructed build  : 1369 bytes  
difference           : +9 bytes  

Detailed analysis shows that the remaining difference is explained by three
independent factors:

- mml_conv routine difference     : -11 bytes
- beep_out3 initialization block  : +28 bytes
- trailing binary padding         : -8 bytes

Total difference: **+9 bytes**

The most significant discrepancy is the initialization block at the start
of `beep_out3`.

The printed source listing includes seven initialization instructions inside
the `beep_out3` routine, but the distributed historical binary begins the
routine directly with `dec ba`.

However, the same initialization sequence already exists earlier in the
`main2` routine and is present in both the printed source and the binary.

This strongly suggests that the printed listing and the distributed binary
represent slightly different revisions of the program, or that redundant
initialization code was removed in the distributed build.

For this reason:

- `play3_photo.asm` preserves the **scan-faithful transcription** of the magazine source listing
- `play3_pushu.asm` provides an **XASM-compatible reconstruction** of that printed source

The repository therefore preserves both the historical source listing and
the technical analysis of its relationship to the distributed binary.

---

## License

Original software and music remain the property of their respective authors.

This repository is intended as a **historical preservation archive**.

## Related Projects

Other SHARP PC-E500 projects:

- Building Rescue Archive  
  https://github.com/gikonekos/Building-Rescue-Archive
