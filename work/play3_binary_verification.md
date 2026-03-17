# PLAY3 Binary Reconstruction Analysis

This document analyzes the relationship between the historical **PLAY3 binary** and the reconstructed assembly built with **XASM**.

The goal of this analysis is to determine whether the reconstructed source produces the **same executable code** as the original program distributed with Pocket Computer Journal (Nov 1993).

---

# Files Compared

| File | Description |
|-----|-------------|
| PLAY3 | Original historical binary |
| play3_xasm.obj | XASM assembled object |
| play3_rebuilt_bin.bin | Raw binary output from XASM |

File sizes:

| File | Size |
|-----|------|
| PLAY3 | 1376 bytes |
| XASM object | 1407 bytes |
| XASM raw binary | 1397 bytes |

At first glance the files are different sizes and therefore **not byte-identical**.

However deeper analysis reveals that the **code body largely matches**.

---

# Initial Code Alignment

The first significant matching block appears at:

```
PLAY3 offset: 16
XASM binary offset: 6
match length: 34 bytes
```

Matching instruction sequence:

```
F0 0B 0C 26 F0 0B 30 BC 80 ...
```

This indicates that the executable code in the reconstructed binary is **very likely the same program body**.

The difference occurs at the **file header level**, not in the code itself.

---

# Large Matching Region

A much larger matching region was also detected:

```
PLAY3 offset: 1160
XASM binary offset: 1189
match length: 208 bytes
```

This confirms that large sections of the driver code are identical between the two binaries.

---

# Header Difference

The first bytes of each file differ significantly.

## PLAY3 header

```
FF 00 06 01 10 50 05 00 00 F0 0B FF FF FF 00 0F
```

## XASM raw binary

```
6F 05 00 00 F0 0B ...
```

The PLAY3 file clearly contains **additional metadata before the executable code**.

This strongly suggests that the PLAY3 file is not a raw assembler output but a **Pocket Computer machine-language program file**.

---

# Likely File Structure

The original PLAY3 file likely has the structure:

```
[PC-E500 program header]
[driver machine code]
```

The reconstructed XASM output corresponds only to:

```
[driver machine code]
```

Therefore the binaries differ at the file level even though the program body matches.

---

# Interpretation

The reconstruction has likely succeeded in recovering the **actual machine code of the PLAY3 driver**.

The remaining difference is due to the **distribution format used by the pocket computer environment**, not the driver code itself.

Possible explanations include:

* BASIC machine-language loader format
* pocket computer binary program header
* relocation or load address metadata

Further analysis of the PLAY3 header would be required to fully reconstruct the original file format.

---

# Reconstruction Status

| Item | Status |
|-----|------|
| Assembly reconstruction | complete |
| XASM build reproducibility | confirmed |
| Instruction sequence match | confirmed |
| File-level binary identity | not yet confirmed |

The reconstructed source appears to generate the same machine code body as the original program, but the distributed PLAY3 file contains additional header information specific to the pocket computer system.

---

# Historical Significance

PLAY3 is notable because it produces **three-voice polyphonic music using only the internal piezo buzzer** of the SHARP PC-E500.

The driver implements a **software mixing technique in pure assembly language**, allowing multiple musical voices to be simulated on a single 1-bit output device.

This represents a typical example of early 1990s Japanese pocket computer programming techniques.

---

# Conclusion

Binary comparison strongly indicates that the reconstructed assembly source correctly reproduces the PLAY3 driver machine code.

Remaining differences are likely caused by the **program container format used by the pocket computer system**, rather than errors in the reconstructed assembly.

Further work would involve reverse-engineering the PLAY3 header format to reproduce the original distribution file exactly.
