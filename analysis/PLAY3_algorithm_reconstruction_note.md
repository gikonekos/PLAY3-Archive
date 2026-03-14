# PLAY3 reconstruction notes: algorithm-focused summary

## Scope

This note summarizes what can now be stated from the reconstructed magazine source and the photographed XASM listing of PLAY3 for the SHARP PC-E500.

It is intentionally focused on reconstruction findings and implementation structure, rather than repeating a broad historical article.

## High-level structure

PLAY3 is organized as:

1. installation / removal hooks for the BASIC command table
2. entry routine
3. MML conversion
4. per-part event fetch (`rmml`)
5. scheduler in `main2`
6. software sound output routines (`beep_out0`, `beep_out3`, and related branches)
7. data / work area

The overall control flow is:

`PLAY/EXOFF command -> entry -> mml_conv -> init2 -> main2 -> rmml(part1/2/3) -> choose shortest active duration -> software mixer -> return to main2`

## BASIC integration

The listing shows two commands in the BASIC command table:

- `PLAY`
- `EXOFF`

`install` writes pointers to the BASIC work table, and `remove` restores them and calls initialization.

This means PLAY3 is not just a player routine; it is a command-extension style resident routine integrated into the BASIC environment.

## Entry routine

The photographed listing confirms the following behavior in `entry`:

- save interrupt state / registers
- disable interrupts through `(!imr)`
- save `abp`
- call `mml_conv`
- call `init2`
- restore `abp`
- restore interrupt state
- return with `retf`

This matches a design where conversion and preparation are done atomically before playback proceeds.

## MML conversion

`mml_conv` builds internal event data from textual MML.

Confirmed command handling includes:

- part switch: `;`
- octave up/down: `>` `<`
- octave set: `O`
- tempo: `T`
- default length: `L`
- rest: `R`
- accidental / note modifiers: `+`, `-`, `#`
- formatting / note-length handling

### Internal note coding

The listing around the control table and `mml_data1` / `mml_data2` shows that notes are converted into compact internal codes:

- `00` = R
- `10` = C
- `20` = #C
- `30` = D
- `40` = #D
- `50` = E
- `60` = F
- `70` = #F
- `80` = G
- `90` = #G
- `A0` = A
- `B0` = #A
- `FF` = end

`mml_data1` and `mml_data2` are used to map note letters and accidentals into this internal format.

### Output of conversion

For each part, converted note events are written into per-part data areas. The converter also writes:

- note code (`onp`)
- length count (`l_count`)
- octave-dependent pitch counter (`o_count`)

## Scheduler (`main2`)

`main2` calls `rmml` for:

- `part1`
- `part2`
- `part3`

Then it computes the minimum active duration among the three `l_count` values.

That minimum duration is the event quantum for the next output segment.

In effect:

- `tick = min(length1, length2, length3)`
- subtract `tick` from each active part
- derive output duration from `tick` and `temp`
- collect active pitch counters
- branch to the appropriate sound routine depending on active voice count

This is a clean event-synchronous scheduler, not a naive per-note blocking player.

## Tempo handling

The photographed listing around `main2_lp1` shows that duration is scaled by tempo using repeated shifts/additions rather than a general multiply routine.

So PLAY3 computes playback time from:

- shortest note duration
- tempo value in `temp`

This is an efficient implementation choice for the target machine.

## Voice counting and active-part collection

The code around the "3音処理設定" section confirms that PLAY3:

1. checks whether each part is currently active
2. copies active pitch counters into temporary counters (`count1`, `count2`, `count3`)
3. counts how many voices are active
4. selects a specialized output routine

This means the player does not treat every frame identically. It explicitly distinguishes 0, 1, 2, and 3 active voices and prepares the output path accordingly.

## Software sound generator

The photographed listing identifies the output loop timing:

- **1 loop = 37 states ≈ 48.1 µs**

This is the key to the whole design.

At roughly 48 µs per loop, the routine runs fast enough to time-division-multiplex several square-wave style counters through a single piezo buzzer.

### `beep_out0`

`beep_out0` handles the silent / zero-voice case by keeping the buzzer off for the required duration.

### `beep_out3`

`beep_out3` is the core three-voice routine.

The listing explicitly documents the input registers:

- `ba = part1` counter
- `i = part2` counter
- `y = part3` counter
- `x = playback duration counter`

The routine decrements these counters inside a tightly balanced loop and flips the buzzer state at the relevant moments.

A crucial reconstruction finding is that PLAY3 writes values into locations like:

- `part1_co1+1`
- `part2_co1+1`
- `part2_co2+1`
- `part3_co1+1`
- `part3_co2+1`
- `part3_co3+1`
- `part3_co4+1`

before entering `beep_out3`.

That is strong evidence of **self-modifying code**: the program patches immediate operands in the output routine so the mixer loop can run with minimal overhead.

## Data tables

### Pitch table (`mml_data`)

The photographed final page confirms a five-column pitch table (`O0`..`O4`) used for octave-scaled pitch counters.

### Length table (`length_data`)

The listing confirms:

- `03 06 09 0C 12`
- `18 24 30 48 60`
- `02 04 06 10 20 01`

This is the note-length conversion table used by the parser.

### Work area

The final photographed page confirms:

- `temp` = tempo
- `count` = playback duration counter (3 bytes)
- `count1`, `count2`, `count3` = pitch counters
- `part1`, `part2`, `part3` = part work areas (`ds 16`)
- `r_flg`
- `data_buff`

## What is now certain

From the photographed source and reconstruction work, the following are now effectively established:

- PLAY3 is a BASIC-integrated resident extension, not just a standalone sound routine
- it parses textual MML into compact internal event data
- it schedules playback by the shortest active note duration
- it derives playback time from note length and tempo
- it supports 0/1/2/3 voice handling with specialized routines
- the three-voice routine uses a fast fixed-time loop
- self-modifying code is used to minimize loop overhead
- the machine produces apparent three-voice polyphony through time-division software mixing on a single buzzer

## Reconstruction status note

Algorithm analysis is now essentially complete.

What remains on the reconstruction side is not understanding of the design, but exact binary-identical reassembly:
- XASM syntax details
- short/long branch encoding
- indirect-addressing forms such as `(!label)` and `[(!label)]`
- exact operand encoding in self-modifying sections
