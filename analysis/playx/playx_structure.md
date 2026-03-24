# PLAYX Internal Structure

This document summarizes the reconstructed internal architecture of PLAYX,
a buzzer music driver for the SHARP PC-E500 series.

PLAYX is a BASIC extension command driver that provides three-voice polyphonic
playback using a single 1-bit internal speaker.

## Function Map

| Address | Function | Role |
|---------|----------|------|
| `BF000` | `PLAYX_ENTRY` | BASIC command registration entry |
| `BF013` | `PLAYX_CMD_TABLE` | Command name table (`"PLAYX"`) |
| `BF022` | `PLAYX_INIT` | Initialization and parameter validation |
| `BF08D` | `FIND_PARTS` | Split MML string into voice parts |
| `BF15F` | `MML_DISPATCH` | MML command parser |
| `BF1F4` | `PITCH_CALC` | Pitch and note length calculation |
| `BF26C` | `EXIT` | Return to BASIC |
| `BF272` | `VOICE_ROUTE` | Self-modifying code routing |
| `BF290` | `SOUND_GEN` | Three-voice sound generation loop |
| `BF2CA` | `DATA_TABLES` | Pitch tables and note length tables |

## Overall Design

PLAYX consists of the following major stages:

1. Register the BASIC extension command.
2. Validate parameters and initialize the work area.
3. Split the MML string into up to three parts.
4. Parse each MML command.
5. Calculate pitch and note duration values.
6. Route per-voice values into the sound generator.
7. Generate time-sliced three-voice buzzer output.
8. Return control to BASIC when finished.

## BASIC Integration

PLAYX is tightly integrated with the BASIC command environment.

The entry routine at `BF000` registers the command name table found at `BF013`.
The embedded command name confirmed in the binary is:

- `PLAYX`

This indicates that PLAYX is not just a raw playback routine, but a resident
BASIC extension command driver.

## MML Parsing

The routine `MML_DISPATCH` at `BF15F` handles MML command parsing.

Confirmed command categories include:

- Notes: `A B C D E F G`
- Octave: `O`
- Tempo: `T`
- Accidentals: `+ -`
- Octave shift: `< >`

The parser operates directly on the MML string after it has been split into
separate voice parts by `FIND_PARTS`.

## Pitch and Duration Processing

`PITCH_CALC` at `BF1F4` performs pitch lookup and note-length conversion.

This routine uses the data tables located near `BF2CA`, including:

- pitch-related tables
- note duration tables

These values are then passed into the voice routing and sound generation logic.

## Three-Voice Playback

PLAYX achieves three-voice playback by time-sliced processing.

Rather than mixing analog waveforms, the driver rapidly alternates among the
active voices, updating counters and generating short pulses on the single
1-bit buzzer output.

This produces the perceptual effect of polyphonic playback.

## Self-Modifying Code

A key feature of PLAYX is its use of self-modifying code.

The routine `VOICE_ROUTE` at `BF272` uses the SC62015 `D8` instruction to
rewrite operand bytes inside the `SOUND_GEN` routine.

The important point is:

- the rewritten target is a `CC`-family instruction
- the immediate operand field is modified dynamically
- per-voice pitch counter values are injected at runtime

This mechanism allows PLAYX to switch per-voice playback parameters efficiently
without heavy branching overhead.

## Sound Generator

`SOUND_GEN` at `BF290` is the core playback loop.

Its role is to:

- read the currently routed voice values
- update counters
- generate the buzzer pulse stream
- iterate among up to three voices

This is the central routine that produces audible output.

## Historical Significance

PLAYX is an important earlier driver in the lineage of SHARP pocket computer
music systems.

Its architecture shows:

- integrated BASIC command handling
- internal MML parsing
- table-driven pitch and duration handling
- self-modifying routing logic
- three-voice time-sliced playback on a single buzzer

These concepts appear to have influenced later designs such as PLAY3, even if
those later drivers were reimplemented rather than directly copied.
