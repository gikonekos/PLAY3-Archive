# PLAY3 Timing Analysis

The PLAY3 driver uses a timing-critical loop to generate sound.

Because the SHARP PC-E500 has only a single beep output, the driver
must generate multiple tones using software timing.

---

## Loop Timing

The source code contains the following comment:

```
1loop = 37state 48.1uS
```

This indicates that a single iteration of the sound generation loop
takes approximately **48.1 microseconds**.

This corresponds to:

```
about 20,800 loops per second
```

---

## CPU Cycle Budget

Within each loop the driver must:

- update tone counters
- check zero crossings
- toggle the beep output
- reload counters

All of this must complete within the fixed loop time.

A simplified structure of the loop is:

```
loop:
    decrement voice1 counter
    decrement voice2 counter
    decrement voice3 counter

    check voice1 edge
    check voice2 edge
    check voice3 edge

    update beep register
```

Because this loop is carefully tuned, each instruction contributes
to the final timing.

---

## Pitch Generation

Pitch is produced by counting loop iterations.

Each note has a counter value stored in the tone table:

```
mml_data
```

Example:

```
C  -> 12Eh
E  -> 0F0h
G  -> 0CAh
```

These values represent the number of loop iterations before the
waveform toggles.

Frequency can therefore be approximated as:

```
frequency ≈ loop_rate / (2 × tone_value)
```

Because the loop timing is fixed, the pitch remains stable.

---

## Time-Division Polyphony

During each loop iteration the driver processes all active voices.

Example for three voices:

```
loop:
    dec v1
    dec v2
    dec v3

    if v1 == 0 toggle beep
    if v2 == 0 toggle beep
    if v3 == 0 toggle beep
```

This creates a combined waveform that contains the frequencies of
all active voices.

Although only a single bit is output, the ear interprets the signal
as multiple simultaneous tones.

---

## Performance Limit

The number of voices is limited by the available CPU time.

Increasing the number of voices would require more operations inside
the timing loop.

This would cause:

- timing jitter
- pitch instability
- distortion

For the PC-E500, three voices appear to be the practical limit.

---

## Engineering Insight

The PLAY3 driver effectively implements a small **software sound
synthesizer**.

Key design features include:

- fixed-time sound loop
- counter-based pitch generation
- time-division multiplexed voices
- optimized assembly timing

This design allows the PC-E500 to produce convincing three-voice
music despite having only a single sound output.
