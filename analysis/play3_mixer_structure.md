# PLAY3 software mixer structure

PLAY3 generates three-voice polyphonic music using only the internal 1-bit buzzer  
of the SHARP PC-E500 series.  

Because the hardware has no sound channels, all voices are mixed in software.

The driver rapidly switches between voices inside a tight timing loop and
outputs short pulses to the buzzer.

---

## Conceptual structure

```
            Voice A sequence
                 │
                 ▼
            note timing
                 │
                 ▼
            frequency control
                 │
                 │
Voice B sequence ├──────► Software mixer loop ◄────── Voice C sequence
                 │              │
                 │              │
                 │              ▼
                 │        pulse generation
                 │              │
                 │              ▼
                 │        buzzer output
                 │              │
                 └──────────────┘
                         │
                         ▼
                Internal 1-bit buzzer
```

---

## Operation

The PLAY3 driver performs the following steps repeatedly:

1. Read the current state of each voice
2. Update note timing counters
3. Determine whether a pulse should be generated
4. Combine the three voice states
5. Output a short pulse to the buzzer
6. Repeat the loop at high speed

Because the loop runs very quickly, the ear perceives multiple tones
simultaneously even though the buzzer can output only a single bit signal.

---

## Characteristics

* Three simultaneous voices
* Implemented entirely in software
* Uses time-division mixing
* Designed for the SHARP PC-E500 internal buzzer
* Requires a tight CPU loop for stable timing

---

## Historical context

PLAY3 was published in:

Pocket Computer Journal  
November 1993 issue

It demonstrates how polyphonic music can be produced on hardware that
normally supports only simple beep output.
