# Holy Night – Example Music for PLAY3

Example music program for the **PLAY3 buzzer music driver**  
running on the **SHARP PC-E500 pocket computer series**.

This program plays a three-voice arrangement of **"Silent Night"**  
using the internal piezo buzzer through the PLAY3 software mixing routine.

## File

- `HOLY.BAS` – music program OLD Ver.
- `HOLY1.BAS` – music program

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

---

# BASIC Source

**HOLY.BAS**

```basic
1 'HOLY NIGHT FOR PLAY3
100 CLS :CLEAR :DIM B$(0),D$(0)
110 A$="Wpsf?Qvxwk"
120 B$(0)="Bj}}v/W(bn|."
130 FOR X=1 TO LEN A$:C$=C$+CHR$ (ASC (MID$ (A$,X,1)) XOR &1F):NEXT X
140 FOR X=1 TO LEN B$(0):D$(0)=D$(0)+CHR$ (ASC (MID$ (B$(0),X,1)) XOR &0F):NEXT X
150 LOCATE 15,1:PRINT C$
160 PLAY "T100O3:O3
170 PLAY "+C5G5E5G6F3D5:E7C8-G5
180 PLAY "C9C8:-G9-G8
190 PLAY "G6A3G5E8:E6F3E5C8
200 PLAY "G6A3G5E8:E6F3E5C8
210 PLAY "+D7+D5B8:O1B7B5F8
220 PLAY "+C7+C5G8:G7G5E8
230 PLAY "A7A5+C6B3A5:D8A6F3D5
240 PLAY "G6A3G5E8:E6F3E5-G8
250 PLAY "A7A5+C6B3A5:D8A6F3D5
260 PLAY "G6A3G5E8:E6F3E5-G8
270 PLAY "+D7+D5+F6+D3B5:O1F7F5D6F3#G5
280 PLAY "+C8+E8:E8C8
290 PLAY "+C5G5E5G6F3D5:E7C8-G5
300 LOCATE 14,1:PRINT D$(0)
310 PLAY "C9:-G9
```

**HOLY1.BAS**

```basic
1 'HOLY NIGHT FOR PLAY3
100 CLS :CLEAR :DIM B$(0),D$(0)
110 A$="Wpsf?Qvxwk"
120 B$(0)="Bj}}v/W(bn|."
130 FOR X=1 TO LEN A$:C$=C$+CHR$ (ASC (MID$ (A$,X,1)) XOR &1F):NEXT X
140 FOR X=1 TO LEN B$(0):D$(0)=D$(0)+CHR$ (ASC (MID$ (B$(0),X,1)) XOR &0F):NEXT X
150 LOCATE 15,1:PRINT C$
160 PLAY "T100O3:O3
170 PLAY "+C5G5E5G6F3D5:E7C8-G5
180 PLAY "C9C8:-G9-G8
190 PLAY "G6A3G5E8:E6F3E5C8
200 PLAY "G6A3G5E8:E6F3E5C8
210 PLAY "+D7+D5B8:O1B7B5F8
220 PLAY "+C7+C5G8:G7G5E8
230 PLAY "A7A5+C6B3A5:D8A6F3D5
240 PLAY "G6A3G5E8:E6F3E5-G8
250 PLAY "A7A5+C6B3A5:D8A6F3D5
260 PLAY "G6A3G5E8:E6F3E5-G8
270 PLAY "+D7+D5+F6+D3B5:O1F7F5D6F3#G5
280 PLAY "+C8+E8:E8C8
290 PLAY "+C5G5E5G6F3D5:E7C8-G5
300 LOCATE 14,1:PRINT D$(0)
310 PLAY "C9:-G9
```
