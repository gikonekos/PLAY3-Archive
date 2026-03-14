# Holy Night – Example Music for PLAY3

Example music program for the **PLAY3 buzzer music driver**  
running on the **SHARP PC-E500 pocket computer series**.

This program plays a three-voice arrangement of **"Silent Night"**  
using the internal piezo buzzer through the PLAY3 software mixing routine.

## File

- `HOLY.BAS` – music program

## Description

"HOLY.BAS" is a small demonstration program written in BASIC that uses the
PLAY3 music routine to generate **three-voice polyphonic music** from the
PC-E500’s single internal buzzer.

The piece is an arrangement of the well-known Christmas carol:

**Silent Night (Holy Night)**

The program displays the title and author name on the screen while playing.

## Encoded strings in the source

The title and author strings in the BASIC source are lightly obfuscated
using simple XOR decoding.

Decoded strings:

- `Holy Night`
- `By K.Motoi!`

## Original context

This program was written around **1994** as a small demonstration piece
for the PLAY3 music routine.

## Hardware

Tested on real hardware:

- SHARP PC-E500
- SHARP PC-E550

## Video demonstration

A real hardware recording will be added here after recording.

## Related project

PLAY3 driver reconstruction and archive:

https://github.com/gikonekos/PLAY3-Archive
