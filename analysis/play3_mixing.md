# PLAY3 Mixing Algorithm

This document describes the currently understood mixing mechanism used by the **PLAY3 music driver** for the **SHARP PC-E500** pocket computer.

PLAY3 generates **three-voice polyphonic music using only the internal 1-bit piezo buzzer**.  
Because the hardware provides only a single binary output, the driver must implement polyphony entirely in software.

---

# Overview

PLAY3 does **not** appear to use rapid arpeggio or simple time-division multiplexing.

Instead, the driver uses a **pulse-trigger mixing method** that resembles **Wave Peak Modulation (WPM)**.

Each voice maintains its own internal phase state representing the position of a conceptual waveform.  
When the phase reaches the waveform peak, the routine emits a **short trigger pulse** to the buzzer output.

If multiple channels reach their peak within the same cycle, the pulses are **combined before the final buzzer output**.

As a result, the audible waveform is formed from the **superposition of peak pulses from multiple voices**.

---

# Conceptual Model

Each channel behaves conceptually like this:

    phase += frequency
    if phase reaches peak:
        trigger pulse

For three channels:

    ch1 peak → pulse
    ch2 peak → pulse
    ch3 peak → pulse

The pulses are then merged into the final 1-bit output.

Conceptually:

    output = pulse_ch1 OR pulse_ch2 OR pulse_ch3

The resulting pulse density approximates a composite waveform produced by multiple voices.

---

# Voice-Count Specific Routines

The PLAY3 playback engine contains **separate routines depending on the number of active voices**.

This avoids conditional branching inside the timing-critical inner loop.

    beep_out0 : no active voice
    beep_out1 : single voice
    beep_out2 : two-voice mixing
    beep_out3 : three-voice mixing

This design ensures:

- stable timing  
- minimal branching overhead  
- predictable CPU cycle usage  

which is critical when driving the buzzer directly from software.

---

# Relation to WPM (Wave Peak Modulation)

The PLAY3 technique resembles **Wave Peak Modulation**, where very short pulses are emitted at waveform peaks in order to approximate analog waveforms using a 1-bit output device.

Key properties:

- pulse-based waveform synthesis  
- multiple voices combined at pulse level  
- higher perceived sound quality than simple square-wave toggling  
- avoids rapid arpeggio tricks  

Thus, PLAY3 behaves as a **software polyphonic mixer for a 1-bit audio device**.

---

# Timing Characteristics

During playback the driver typically:

- disables interrupts  
- dedicates the CPU almost entirely to sound generation  
- executes tightly timed loops for buzzer output  

This allows precise control of pulse timing despite the extremely limited audio hardware.

---

# Notes

The interpretation above is derived from:

- reconstructed XASM source code  
- binary comparison with the original program  
- observed runtime behaviour on real hardware  

Some internal implementation details may still evolve as reconstruction progresses.
