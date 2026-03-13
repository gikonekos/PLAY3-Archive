# PLAY3 Voice Mixing

PLAY3 produces three-voice pseudo polyphony using a time-division
mixing algorithm.

Instead of switching voices at fixed time slices, PLAY3 uses a
counter-driven event system.

---

## Voice Counters

Each voice has its own counter:

```
voice1 counter
voice2 counter
voice3 counter
```

These counters correspond to the waveform period.

---

## Mixing Loop

During each iteration of the sound loop the counters are decremented.

```
loop:
    dec voice1
    dec voice2
    dec voice3

    if voice1 == 0 toggle beep
    if voice2 == 0 toggle beep
    if voice3 == 0 toggle beep
```

When a counter reaches zero the waveform is toggled and the counter
is reloaded.

---

## Resulting Waveform

Example for a C–E–G chord:

```
time →

C  █     █     █
E    █     █     █
G      █     █
```

The combined waveform contains the frequency components of all
voices.

Although the PC-E500 only outputs a single bit signal, the human ear
perceives the mixture as multiple simultaneous tones.

---

## Advantages of the Method

This event-driven mixing algorithm has several advantages:

* stable pitch
* minimal CPU overhead
* efficient multi-voice synthesis

The design effectively turns the PC-E500 into a small software
polyphonic synthesizer.
