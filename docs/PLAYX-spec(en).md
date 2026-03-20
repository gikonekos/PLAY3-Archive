# PLAYX Specification (SHARP PC-E500, 1993)

PLAYX is a three-voice music driver for the SHARP PC-E500 series.  
It generates polyphonic sound using a single 1-bit internal buzzer.

Each command processes three independent MML streams simultaneously.

---

## Basic Usage

PLAYX "MML1 : MML2 : MML3"

- Three parts are written in a single string
- Parts are separated by ":"

Example (C major chord):

PLAYX "C : E : G"

---

## MML Format

A note is defined as:

[Octave][#]Note[Length]

Elements in brackets may be omitted.

Example:

O2C4

- O2 → octave
- C → note
- 4 → length

---

## Notes

C D E F G A B

Correspond to:

Do Re Mi Fa So La Ti

---

## Note Length

The length is specified by a digit (0–9).

| Value | Note Type              |
|------:|------------------------|
| 0     | 32nd note              |
| 1     | 16th note              |
| 2     | Dotted 16th note       |
| 3     | 8th note               |
| 4     | Dotted 8th note        |
| 5     | Quarter note           |
| 6     | Dotted quarter note    |
| 7     | Half note              |
| 8     | Dotted half note       |
| 9     | Whole note             |

If multiple notes share the same length, it can be omitted after the first note.

---

## Rest

R[length]

Example:

R5 → quarter rest

---

## Pitch Modifier

#[note]

Raises the note by one semitone.

Flat notes are not supported.

---

## Temporary Octave Shift

+ , - [note]

+ → one octave higher  
- → one octave lower  

This shift is temporary.

---

## Octave

O[value]

Range:

00–04

Higher value = higher pitch

---

### Relative Shift

< , >

< → down one octave  
> → up one octave  

This change persists until modified again.

---

## Tempo

T[value]

Supported values:

- T1 (slow)
- T2 (fast)

Fine adjustment is controlled by RAM address:

&H17

---

## Execution Behavior

- MML is parsed directly as a text stream
- No variables or string functions are supported
- The program performs minimal validation

---

## Stop Control

- After execution, PLAYX checks the ON key
- Hold ON to interrupt playback
- This generates a BREAK

---

## Notes and Limitations

- High frequencies are less accurate (8-bit counter limitation)
- Recommended octave range: O1–O3
- Higher notes tend to dominate lower ones

---

## Initialization Requirements

Before using PLAYX:

- Set a valid value at &H17
- Set octave explicitly for each part

---

## Summary

PLAYX enables 3-voice polyphony on a 1-bit buzzer by:

- Rapidly switching speaker output
- Maintaining independent counters per voice
- Mixing three square-wave signals in software
