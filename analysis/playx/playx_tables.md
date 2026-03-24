# PLAYX Data Tables

This document summarizes the data tables identified in the PLAYX binary.

## Main Data Area

The main table region begins around:

- `BF2CA`

This region contains pitch-related values and note duration values used by the
playback routines.

## Note Length Table

A confirmed note duration table appears near the end of the data region.

Example sequence:

`03 06 09 0C 12 18 24 30 48 60`

This table is interpreted as note-length timing values used by `PITCH_CALC`.

These values likely correspond to internal timing units for different MML note
lengths.

## Pitch Tables

Pitch-related tables are also located in the `BF2CA`-and-later range.

These are used to convert parsed note information into playback counter values.

The exact table layout should be checked against the final disassembly source,
but the role of this region as pitch-related lookup data is established.

## Usage

The tables are used by:

- `PITCH_CALC` for note and duration conversion
- `VOICE_ROUTE` for preparing per-voice playback values
- `SOUND_GEN` for actual playback timing

## Notes

These data regions must not be treated as executable code.

Earlier linear disassembly attempts incorrectly decoded some table bytes as
instructions. The corrected analysis separates them as data.

## Summary

The PLAYX table region provides the following core resources:

- pitch lookup values
- note duration values
- playback parameter constants

Together, these tables support PLAYX’s table-driven three-voice buzzer engine.
