## PLAYX Internal Architecture (Reconstructed)

PLAYX is a resident buzzer music driver for the SHARP PC-E500 series, providing
three-voice polyphonic playback using a single 1-bit internal speaker.

This reconstruction is based on disassembly and analysis of the original binary.

---

### Overview

PLAYX is structured as a BASIC extension command driver.

| Address | Function            | Description |
|--------|---------------------|------------|
| BF000  | PLAYX_ENTRY         | BASIC command registration entry |
| BF013  | PLAYX_CMD_TABLE     | Command name table ("PLAYX") |
| BF022  | PLAYX_INIT          | Initialization and parameter setup |
| BF08D  | FIND_PARTS          | Splits MML string into voice parts |
| BF15F  | MML_DISPATCH        | MML command parser |
| BF1F4  | PITCH_CALC          | Pitch and duration calculation |
| BF26C  | EXIT                | Return to BASIC |
| BF272  | VOICE_ROUTE         | Self-modifying routing logic |
| BF290  | SOUND_GEN           | 3-voice sound generation loop |
| BF2CA  | Data tables         | Pitch tables and duration tables |

---

### MML Command Support

PLAYX includes a built-in MML parser.

Confirmed commands:

- Notes: `A B C D E F G`
- Octave: `O`
- Tempo: `T`
- Accidentals: `+ -`
- Octave shift: `< >`

The parser is implemented in `MML_DISPATCH`, which interprets the string directly.

---

### Three-Voice Sound Generation

PLAYX produces polyphonic sound using time-division multiplexing.

Each voice is processed sequentially in a loop:

1. Load pitch value
2. Generate pulse
3. Advance counters
4. Switch to next voice

This creates the illusion of simultaneous playback on a single 1-bit buzzer.

---

### Self-Modifying Code Mechanism

A key feature of PLAYX is its use of self-modifying code.

The routine `VOICE_ROUTE` dynamically rewrites instructions inside `SOUND_GEN`.

Specifically:

- The SC62015 `D8` instruction is used to write into program memory
- Target instructions are `CC`-family operations (memory/immediate operations)
- Only the immediate operand field is modified

This allows:

- Per-voice pitch values (VREG) to be injected at runtime
- Dynamic control of timing loops without conditional branching overhead

This mechanism is central to the three-voice mixing technique.

---

### Data Tables

Located near BF2CA:

- Pitch tables (frequency values)
- Note duration tables (e.g. 03, 06, 09, 0C, 12...)

These tables are used by `PITCH_CALC`.

---

### Design Characteristics

PLAYX can be characterized as:

- BASIC-integrated command driver
- Single-buzzer polyphonic engine
- Time-sliced multi-voice playback
- Heavy use of self-modifying code
- Table-driven pitch and timing system

---

### Historical Note

PLAYX is believed to have influenced later drivers such as PLAY3.

While PLAY3 is a redesigned implementation, it likely inherits key concepts:

- MML-based control
- Software mixing of multiple voices
- Table-driven sound generation

PLAY3 improves usability by introducing better control mechanisms (e.g. EXOFF),
indicating a refinement of PLAYX’s tightly coupled BASIC integration.

---
