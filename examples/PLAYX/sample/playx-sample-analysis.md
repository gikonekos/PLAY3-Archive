# PLAYX Sample Music Analysis

## Overview

The sample program is not a single continuous MML string.

Instead, it is composed of multiple 3-voice phrase blocks, where:

- PLAYX handles sound generation (3-voice playback)
- BASIC controls the song structure (flow, repetition, ending)

This creates a simple layered architecture:

- Machine code → audio engine (PLAYX)
- MML → musical data
- BASIC → sequence control

---

## Basic Structure
```
Initialization
↓
Section A
↓
Section B
↓
Branch
├─ first pass → transition → Section A (repeat)
└─ second pass → ending
```
---

## Flow Control (BASIC)
```basic
90  *A

100–170  Section A

180 *B

190–250  Section B

260 IF Z=1 THEN 290
270 PLAYX (transition phrase)
280 Z=1:GOTO *A

290 PLAYX (ending)
300 END
```
---

## Playback Sequence
```
1st pass:
A → B → transition → A

2nd pass:
A → B → ending
```
---

## Phrase Design

Each PLAYX command contains:

PLAYX "Voice1 : Voice2 : Voice3"

So each line is a complete 3-voice unit.

Voice roles:
```
Voice1 → melody
Voice2 → harmony
Voice3 → bass
```
---

## Key Insight

PLAYX = playback engine  
MML   = note data  
BASIC = sequence logic

Structure:

[Phrase playback] + [Flow control]

---

## Technical Significance

This design enables:

- Multi-voice composition
- Phrase reuse
- Conditional branching
- Structured music (A/B sections)

---

## Conclusion

The PLAYX sample program demonstrates:

- software-based polyphonic synthesis
- text-based music representation (MML)
- programmatic sequencing using BASIC
