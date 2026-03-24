# PLAYX Analysis

Reverse engineering results of the PLAYX buzzer music driver for the SHARP PC-E500 series.

PLAYX is a BASIC extension command that enables three-voice polyphonic playback using a single 1-bit internal speaker.

---

## Files

- `playx_disassembly.asm`  
  Clean disassembly (structural reference)

- `playx_annotated.asm`  
  Annotated disassembly with analysis comments

- `PLAYX_full_disasm.txt`  
  Original raw disassembly output (archival)

- `playx_structure.md`  
  Reconstructed internal architecture

- `playx_tables.md`  
  Data tables (pitch, duration)

- `playx_notes.md`  
  Analysis notes and technical observations

---

## Summary

PLAYX consists of:

- BASIC command registration
- Internal MML parser
- Pitch and duration calculation
- Self-modifying voice routing
- Time-sliced three-voice sound generation

The driver achieves polyphonic playback by dynamically rewriting instruction operands
and processing each voice in a high-speed loop.

---

## Notes

- Based on analysis of the original PLAYX.BIN
- CPU: SC62015
- Some interpretations are inferred from disassembly and may require further verification

---
