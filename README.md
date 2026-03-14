# PLAY3 Archive

Reconstruction and historical archive of **PLAY3**,  
a three-voice buzzer music driver for the **SHARP PC-E500 pocket computer**.

PLAY3 generates **three-voice polyphonic music from a single 1-bit internal buzzer**
using software mixing.

The original program was published in:

**Pocket Computer Journal – November 1993**

---

## Demo

PLAY3 running on a real **SHARP PC-E500**.

https://youtu.be/T1-_uG7e5Q0

The music in the video is an original RPG floor BGM titled **"Dash!"**
composed by **Kenkichi Motoi (1994)**.

---

## About PLAY3

PLAY3 is a software music routine that produces **three simultaneous voices**
using the internal piezo buzzer of the PC-E500 series.

Since the hardware only supports a single tone output, the driver performs
rapid time-division switching of multiple notes to create the perception of
polyphony.

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

Examples include:

- **VEZAR** – example program used in demonstrations
- **Dash!** – RPG floor BGM (1994)
- **Holy Night** – Silent Night arrangement
- **Bottakuri Shouten** – early music later used in the PC-98 game  
  *Space Panicco (すぺーすぱにっ娘)*

These programs illustrate how music was composed for buzzer-based
polyphonic drivers on pocket computers.

---

## Authors

PLAY-series driver authors:

- **PLAYX** – Keita Morita  
- **PLAY2 / PLAY2L / PLAY3** – Ryu (Tatsuya Kobayashi / 小林龍也)

Example music:

- **Kenkichi Motoi (基建吉)**

---

## Purpose of this archive

This project aims to preserve:

- the original magazine publication
- reconstructed XASM source code
- working example programs
- technical analysis of the driver

for historical documentation of **buzzer-based polyphonic music systems**
on pocket computers.

---

## Related historical material

Some example programs also document music that later appeared in
PC-98 games, showing the relationship between **pocket computer music**
and **1990s Japanese PC game soundtracks**.

---

## License

Original software and music remain the property of their respective authors.
This repository serves as a historical archive.
