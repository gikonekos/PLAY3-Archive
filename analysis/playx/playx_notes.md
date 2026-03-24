# PLAYX Analysis Notes

This file records technical notes and interpretation points for the PLAYX
reverse engineering work.

## Binary Layout

PLAYX is loaded at:

- `BF000`

The original BASIC loader installs the machine code and then calls:

- `CALL &BF000`

This confirms that PLAYX is an installer plus resident BASIC extension driver.

## Confirmed Structural Points

The following major routines have been identified:

- `PLAYX_ENTRY` at `BF000`
- `PLAYX_CMD_TABLE` at `BF013`
- `PLAYX_INIT` at `BF022`
- `FIND_PARTS` at `BF08D`
- `MML_DISPATCH` at `BF15F`
- `PITCH_CALC` at `BF1F4`
- `EXIT` at `BF26C`
- `VOICE_ROUTE` at `BF272`
- `SOUND_GEN` at `BF290`
- data tables from `BF2CA`

## SC62015 Instruction Interpretation

The corrected analysis is based on primary SC62015 instruction documentation.

Important resolved points include:

- prebytes such as `30` are addressing modifiers, not standalone instructions
- `CC` is an `MV (m),n` family instruction
- `D8` is used for writing from internal RAM to external memory space
- `D8` is used in PLAYX for self-modifying code

## Self-Modifying Code

The original assumption that `FD` was the main self-modified target was revised.

Current understanding:

- `VOICE_ROUTE` uses `D8`
- the rewritten target is inside `SOUND_GEN`
- the rewritten target is a `CC` instruction operand field
- pitch counter values are injected dynamically

This is central to the three-voice design.

## MML Support

Confirmed MML-related elements include:

- note letters `A-G`
- octave command `O`
- tempo command `T`
- accidental handling `+ -`
- octave shift `< >`

Further extraction of the complete MML specification should be done from the
final disassembly source.

## Relationship to PLAY3

PLAYX appears to be an earlier design that influenced PLAY3.

Important differences already observed:

- PLAYX is tightly coupled to the BASIC command environment
- PLAY3 introduces improved command control, including `EXOFF`
- PLAY3 is larger and appears more strongly reworked

This supports the idea that PLAY3 was informed by analysis of PLAYX, while being
reimplemented for practical improvement.

## Caution

The final authority for exact instruction-by-instruction behavior should be the
actual disassembly source and primary SC62015 documentation.

Earlier analyses based on other CPU families were incorrect and should not be
used as authoritative references.
