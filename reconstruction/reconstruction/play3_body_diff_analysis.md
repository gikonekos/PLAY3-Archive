# PLAY3 Body Difference Analysis

This document analyzes the remaining size difference between the historical `PLAY3` binary and the reconstructed `play3_xasm.obj`.

---

## Compared bodies

The comparison ignores the 16-byte machine-language header.

| File | Body Size |
|------|-----------|
| PLAY3 | 1360 bytes |
| play3_xasm.obj | 1391 bytes |

Difference:

```
1391 - 1360 = 31 bytes
```

---

## Important observation

Previous tests confirmed:

```
play3_xasm.obj body
==
play3_rebuilt_bin.bin body
```

This proves that the XASM output format (OBJ vs BIN) does not affect the generated code body.

Therefore the remaining difference must originate from the assembly output itself.

---

## Likely cause

The difference pattern suggests assembler-generated expansion rather than a completely different code sequence.

Typical sources of such differences include:

- DS directive expansion
- alignment padding
- table size differences
- reserved memory areas
- segment end padding

The PLAY3 program is known to implement a software audio mixer and likely contains internal tables for timing or waveform control.

Such tables are often defined using `DS` or similar directives and may expand differently depending on assembler behavior.

---

## Interpretation

The difference is therefore likely not caused by incorrect code reconstruction but by differences in how the assembler expands reserved areas or aligns internal data sections.

Given the historical development environment (PC-9801 MS-DOS), it is plausible that the original assembler produced slightly different padding behavior than the currently reproduced build.

---

## Current reconstruction status

The following elements are now confirmed:

- identical external machine-language file format
- identical load origin encoding
- identical assembler output body between different XASM output types

The remaining difference is limited to a small expansion within the machine-code body.

This strongly suggests that the reconstructed assembly source is fundamentally correct and that the remaining mismatch is caused by assembler behavior rather than incorrect source reconstruction.
