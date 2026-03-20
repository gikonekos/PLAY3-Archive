# VEZAR

VEZAR is a background music program for the **PLAY3 driver** on the SHARP PC-E500 series pocket computers.

The program demonstrates **three-voice pseudo-polyphonic playback** using the BASIC `PLAY` command.

```
 ---VEZAR--- (C)2025 KENKICHI MOTOI
```

Author  
Kenkichi Motoi

---

# System Requirements

Hardware

- SHARP PC-E500
- PC-E550
- compatible models

Software

- PLAY3 driver

Install PLAY3:

```
CALL &BF000
```

Run the program:

```
RUN
```

---

# Song Structure

The music is organized into four sections.

```
Intro
Main loop (×2)
Ending
Final phrase
```

Program labels:

| Label | Section |
|------|--------|
| *A | Intro |
| *B | Main loop |
| *C | Ending |
| *D | Final phrase |

---

# Chord Progression

Approximate harmonic structure:

```
Intro
Am → F → G → Am

Main loop
A → G → A

Ending
A → G

Final
C → D → E
```

The structure resembles a typical **game background music loop**.

---

# PLAY Command Structure

PLAY3 uses three parts separated by `:`.

```
PLAY "part1:part2:part3"
```

Example:

```
PLAY "O2A5R3A2R1A2R1
     :O2E5R3E2R1E2R1
     :O1F5R3F2R1F2R1"
```

| Channel | Role |
|-------|------|
| Part1 | melody |
| Part2 | harmony |
| Part3 | bass |

---

# PLAY String Breakdown

Example phrase:

```
O2A5R3A2R1A2R1
```

Interpretation:

| Token | Meaning |
|------|--------|
| O2 | octave 2 |
| A5 | note A |
| R3 | rest |
| A2 | note A |
| R1 | short rest |

---

# MML Conversion

The PLAY syntax can be approximated as modern MML.

Original PLAY:

```
O2A5R3A2R1A2R1
```

MML equivalent:

```
O2 A4 R8 A8 R4 A8
```

Example full phrase:

```
CH1  O3A4E8E8R4
CH2  O2A4R8A8R4
CH3  O1E4R8E8R4
```

Note  
Exact timing differs because PLAY3 uses internal timing units.

---

# MIDI Conversion

A MIDI version was created by ear.

Differences from the original BASIC playback:

| Feature | BASIC PLAY | MIDI |
|------|------|------|
| Timing | internal PLAY timing | quantized |
| Velocity | none | velocity applied |
| Instruments | square wave | MIDI instrument |
| Channels | PLAY string | MIDI tracks |

The MIDI version is intended for **listening reference**.

---

# Simplified Score

Approximate melodic contour.

```
Intro
A  A  A
E  E  E
F  F  F

Main
A E E
A E E

Ending
A A G

Final
C D E
```

Bass pattern:

```
E E E E
A A A A
```

---

# PLAY Syntax Reference

Commands used in the program:

| Command | Meaning |
|------|------|
| A–G | notes |
| R | rest |
| O | octave |
| T | tempo |
| L | default length |
| : | channel separator |
| < > | octave shift |

---

# PLAY3 Polyphony Technique

The PC-E500 has only a **single beeper**.

PLAY3 simulates chords by:

```
rapidly switching frequencies
between three notes
```

This creates a **time-division multiplexed pseudo-polyphony**.

Example timing concept:

```
note1
note2
note3
note1
note2
note3
```

The switching is fast enough that the ear perceives a chord.

---

# Program Structure (Simplified)

```
100 initialization
105 *A intro
230 *B main loop
300 *C ending
340 *D final phrase
```

Loop control:

```
A=A+1
IF A=2 GOTO *C
```

---

# Musical Characteristics

VEZAR demonstrates:

- pseudo-polyphonic composition
- compact BASIC music code
- repeating rhythmic patterns
- simple harmonic progression

The piece resembles **background music used in retro games**.

---

# File Layout

```
examples
 └─ VEZAR
     ├─ VEZAR.BAS
     ├─ VEZAR.mid
     └─ README.md
```

---

# Related

PLAY driver series

```
PLAY2
PLAY2L
PLAY3
```

---
# Composition Techniques Used in VEZAR

VEZAR demonstrates several techniques commonly used when composing music
for the PLAY3 driver on the SHARP PC-E500 series.

Due to the hardware limitations of the internal beeper,
special composition strategies are required.

---

# 1. Pseudo Polyphony

The PC-E500 hardware can generate only **one tone at a time**.

PLAY3 simulates polyphony by rapidly switching between three notes.

Conceptually:

```
note1
note2
note3
note1
note2
note3
```

This process is repeated fast enough that the human ear perceives
the sound as a chord.

---

# 2. Three-Part Arrangement

The PLAY command divides music into three channels.

```
PLAY "part1:part2:part3"
```

Typical role assignment:

| Part | Function |
|----|----|
| Part1 | Melody |
| Part2 | Harmony |
| Part3 | Bass |

Example:

```
PLAY "O3A7E9E9R5
     :O2A5R3A2R1
     :O1E5R3E2R1"
```

---

# 3. Short Repeating Bass Patterns

Instead of long bass lines,
VEZAR uses repeating rhythmic fragments.

Example pattern:

```
E5 R3 E2 R1
```

Advantages:

- small memory usage
- clear rhythm
- stable harmony

This approach is common in pocket computer music programs.

---

# 4. Loop-Based Composition

Memory on pocket computers is extremely limited.

Therefore music is structured using loops.

Example:

```
Intro
Main pattern ×2
Ending
```

Program control:

```
A=A+1
IF A=2 GOTO *C
```

This allows longer music while keeping the program compact.

---

# 5. Arpeggio-Style Harmony

Because real chords cannot be played simultaneously,
VEZAR relies on **arpeggio-like structures**.

Example:

```
A  E  A
```

instead of

```
[A C E]
```

This technique is also widely used in early game consoles.

---

# 6. Tempo Selection

The program uses:

```
PLAY "T30"
```

A moderate tempo helps mask the switching between notes,
making the pseudo-polyphony sound more natural.

---

# 7. Efficient MML Usage

VEZAR keeps the PLAY strings short and repetitive.

Benefits:

- faster BASIC execution
- smaller memory footprint
- easier editing

This was an important consideration when composing
music on pocket computers.

---

# Historical Note

Music programs like VEZAR demonstrate how composers adapted
to extremely limited hardware.

Despite having only a simple beeper,
creative programming techniques allowed surprisingly rich music.

Such techniques were commonly used in:

- pocket computers
- early home computers
- early game consoles

VEZAR is a good example of this style of composition.

---

# BASIC Source

**VEZAR.BAS**

```basic
100 CLS :PRINT "   ---VEZAR--- (C)2025 KENKICHI MOTOI":B=0:PLAY "T30"
105 *A
110 FOR A=1 TO 28
120 PLAY "O2A5R3A2R1A2R1:O2E5R3E2R1E2R1:O1F5R3F2R1F2R1"
130 NEXT A
140 FOR A=1 TO 2
150 PLAY "O2F5R3F2R1F2R1:O2C5R3C2R1C2R1:O1A5R3A2R1A2R1"
160 NEXT A
170 FOR A=1 TO 2
180 PLAY "O2G5R3G2R1G2R1:O2D5R3D2R1D2R1:O1B5R3B2R1B2R1"
190 NEXT A
200 FOR A=1 TO 8
210 PLAY "O2A5R3A2R1A2R1:O2E5R3E2R1E2R1:O1F5R3F2R1F2R1"
220 NEXT A:A=0
230 *B:A=A+1
240 PLAY "O3A7E9E9R5:O2A5R3A2R1A2R1A5R3A2R1A2R1A5R3A2R1A2R1A5R3A2R1A2R1:O2E5R3E2R1E2R1E5R3E2R1E2R1E5R3E2R1E2R1E5R3E2R1E2R1"
250 PLAY "O3B7G9G9D5:O2G5R3G2R1G2R1G5R3G2R1G2R1G5R3G2R1G2R1G5R3G2R1G2R1:O2D5R3D2R1D2R1D5R3D2R1D2R1D5R3D2R1D2R1D5R3D2R1D2R1"
260 PLAY "O3E7E9E9E5:O2A5R3A2R1A2R1A5R3A2R1A2R1A5R3A2R1A2R1A5R3A2R1A2R1:O2E5R3E2R1E2R1E5R3E2R1E2R1E5R3E2R1E2R1E5R3E2R1E2R1"
270 PLAY "O3E7E9E9E5:O2A5R3A2R1A2R1A5R3A2R1A2R1A5R3A2R1A2R1A5R3A2R1A2R1:O2E5R3E2R1E2R1E5R3E2R1E2R1E5R3E2R1E2R1E5R3E2R1E2R1"
280 PLAY "O3A7E9E9R5:O2A5R3A2R1A2R1A5R3A2R1A2R1A5R3A2R1A2R1A5R3A2R1A2R1:O2E5R3E2R1E2R1E5R3E2R1E2R1E5R3E2R1E2R1E5R3E2R1E2R1"
290 PLAY "O3B7G9G9G5:O2G5R3G2R1G2R1G5R3G2R1G2R1G5R3G2R1G2R1G5R3G2R1G2R1:O2D5R3D2R1D2R1D5R3D2R1D2R1D5R3D2R1D2R1D5R3D2R1D2R1"
300 PLAY "O3A7A9A9A5:O2A5R3A2R1A2R1A5R3A2R1A2R1A5R3A2R1A2R1A5R3A2R1A2R1:O2E5R3E2R1E2R1E5R3E2R1E2R1E5R3E2R1E2R1E5R3E2R1E2R1"
310 IF A=2 GOTO *C
320 PLAY "O3A7A9A9A5:O2A5R3A2R1A2R1A5R3A2R1A2R1A5R3A2R1A2R1A5R3A2R1A2R1:O2E5R3E2R1E2R1E5R3E2R1E2R1E5R3E2R1E2R1E5R3E2R1E2R1"
330 GOTO *B
340 *C
350 PLAY "O3A5R2A5R2A5R2G9G2:O2A5R2A5R2A5R2G9G2:O2E5R2E5R2E5R2D9D2"
360 *D
370 PLAY "O3C5C2D5D2E5E2E5E2E5E2D7D3D1D1:R5R2R5R2O2E5E2R5R2R5R2D5D2R5R2R7R3R1R1:R5R2R5R2O2C5C2R5R2R5R2O1B5B2R5R2R7R3R1R1"
380 PLAY "O3E7E2D5D2C5C2O2B5B2A5A2B5B2B7B3B1B1:R7R2R5R2C5C2R5R2R5R2D5D2R5R2R7R3R1R1:R7R2R5R2O1E5E2R5R2R5R2O1A5A2R5R2R7R3R1R1"
390 PLAY "O3C5C2D5D2E5E2E5E2E5E2D7D3D1D1:R5R2R5R2O2E5E2R5R2R5R2D5D2R5R2R7R3R1R1:R5R2R5R2O2C5C2R5R2R5R2O1B5B2R5R2R7R3R1R1"
400 PLAY "O3G7G2F5F2E5E2D5D2C5C2O2B5B2B7B2B7B2B2B1:R7R2R5R2O2A5A2R5R2R5R2#G5#G2R5R2R7R2R7R2R2R1:R7R2R5R2O2F5F2R5R2R5R2E5E5R5R2R7R2R7R2R2R1"
410 A=0:B=B+1:IF B<2 GOTO *B
420 B=0:GOTO *A
```


# License

Program and music

© 2025 Kenkichi Motoi
