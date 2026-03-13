# PLAY3 Sound Generation Algorithm

This document describes the internal sound generation algorithm used
by PLAY3.

The original article in Pocket Computer Journal explains the concept,
but the exact implementation can be understood by analyzing the source
code.

---

# Hardware Limitation

The SHARP PC-E500 series provides only a single sound output.

The hardware register is:

```
beep
```

This means the machine can only output a single square wave.

True polyphony is therefore impossible.

---

# Pseudo Polyphony

PLAY3 produces polyphonic sound using **time division multiplexing**.

Instead of generating three tones simultaneously, the driver rapidly
switches the beep output between multiple tone generators.

If this switching happens fast enough, the human ear perceives the
result as simultaneous tones.

---

# Main Loop Timing

The PLAY3 source code contains the following comment:

```
1loop = 37state 48.1uS
```

This indicates that one loop of the sound generator takes approximately
48 microseconds.

This corresponds to roughly:

```
about 20,000 iterations per second
```

This very fast loop makes pseudo polyphony possible.

---

# Tone Counters

Each voice has its own tone counter.

```
part1 counter
part2 counter
part3 counter
```

These counters correspond to the tone period of each note.

Example:

```
C  -> 12Eh
E  -> 0F0h
G  -> 0CAh
```

These values are stored in the table:

```
mml_data
```

---

# Sound Mixing

During each loop iteration the driver performs:

```
decrement counter
check if counter reached zero
toggle beep output
reload counter
```

Simplified pseudocode:

```
loop:
    dec voice1_counter
    dec voice2_counter
    dec voice3_counter

    if voice1_counter == 0 toggle beep
    if voice2_counter == 0 toggle beep
    if voice3_counter == 0 toggle beep
```

This effectively mixes three square waves.

---

# Waveform Example

Example for a C–E–G chord:

```
time →

C  █   █   █   █
E    █   █   █
G      █   █
```

The resulting waveform is a combination of all three frequencies.

Although only one bit is output, the ear interprets the signal as
multiple tones.

---

# Specialized Output Routines

The driver includes several sound output routines:

```
beep_out0
beep_out3
```

These routines are optimized for different numbers of active voices.

This improves performance and ensures stable timing.

---

# Why Three Voices?

The number of voices is limited by CPU speed.

Increasing the number of voices would require additional counter
processing inside the 48µs loop.

This would introduce timing errors and distort the pitch.

Three voices appear to be the practical limit for the PC-E500.

---

# Conclusion

PLAY3 effectively implements a **software polyphonic sound generator**
using only the PC-E500 beep output.

This technique allows the machine to produce convincing three-voice
music despite the hardware limitation of a single sound channel.
