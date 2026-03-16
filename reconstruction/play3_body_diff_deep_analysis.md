# PLAY3 Body Deep Difference Analysis

This document refines the previous body comparison between the historical `PLAY3` binary and the reconstructed `play3_xasm.obj`.

---

## Scope

The comparison excludes the common 16-byte machine-language file header and focuses only on the body.

| File | Body Size |
|------|----------:|
| PLAY3 | 1360 bytes |
| play3_xasm.obj | 1391 bytes |

Net difference:

```text
+31 bytes
```

---

## Main result

The remaining difference is **not** explained by a single padding block or by output-wrapper differences alone.

Instead, the body mismatch is composed of multiple insertions, deletions, and value substitutions distributed across the file.

This means that the current mismatch is structurally more complex than a simple “extra trailing bytes” explanation.

---

## Observed structure of the mismatch

Large matching blocks still exist, confirming that both files are closely related.

However, the non-matching regions include several separate size-changing operations, for example:

- small positive expansions
- small negative contractions
- one larger inserted region in the later part of the body
- a small deleted region near the end

This pattern suggests a mixture of:

- internal table differences
- address recalculation effects
- possible assembler expansion differences
- possible source-content differences

---

## Important observation: late inserted address-like block

A particularly important difference appears in the later part of the reconstructed body, where `play3_xasm.obj` contains an extra block of 28 bytes not present in `PLAY3`.

This inserted region contains several values that look like absolute addresses in the `0x0BF4xx` range.

That strongly suggests that the differing region may be:

- a pointer table,
- a jump/data reference table,
- or another address-bearing structure.

This is more specific than simple end padding.

---

## Revised interpretation

Earlier hypotheses considered whether the remaining 31-byte mismatch might be caused only by XASM output-format or padding behavior.

The deeper comparison does not support that as a complete explanation.

A more accurate interpretation is:

1. output wrapper differences are already ruled out,
2. body differences are real and distributed,
3. at least one later difference looks like an inserted address table or reference structure,
4. assembler behavior may still contribute,
5. but source-level divergence must also be considered.

---

## What is still strongly supported

Despite the remaining mismatch, the following points are still well supported:

- `PLAY3` and `play3_xasm.obj` use the same outer machine-language file format
- the common header structure is correct
- the body contains large matching code/data blocks
- the reconstructed source is clearly in the correct family of binaries

So the project has not failed; rather, it has been narrowed to a smaller and more precise remaining problem.

---

## Most likely remaining problem

The remaining mismatch is now best described as a difference in one or more internal data/code structures, possibly involving address-bearing tables.

The cause may be one of the following, or a combination:

- XASM environment-dependent expansion behavior
- differences between DOS-era and current assembly output
- differences introduced during scan reconstruction
- a surviving discrepancy in table definitions or label layout
- divergence between PLAY3 and related ancestor sources such as PLAYX

---

## Final discrepancy candidate

Manual comparison with the original magazine scan revealed a likely transcription error
in the `mml_onp` routine.

The printed listing shows:

    pushua
    ...
    popu a
    ...
    popu y

while the reconstructed source used:

    pushs a
    ...
    pops a
    ...
    pops y

This difference may produce a binary mismatch depending on how the assembler
encodes these instructions.

Further verification will determine whether this accounts for the remaining
binary size difference.

---

## Confirmed branch-size discrepancy

Further investigation revealed a concrete source-level cause for part of the binary mismatch.

The reconstructed source currently contains six occurrences of:

    jp mml_conv_lp

However, analysis suggests that the original magazine source used a shorter relative branch (`jr`) in these locations.

Instruction size difference:

| instruction | size |
|-------------|------|
| jr          | 2 bytes |
| jp          | 3 bytes |

As a result, each `jp` introduces an extra byte.

Total confirmed difference:

    6 occurrences × 1 byte = 6 bytes

This accounts for part of the overall body size difference:

Original code size:      1360 bytes  
Reconstructed code size: 1391 bytes  
Difference:              +31 bytes

The remaining 25-byte difference is still under investigation.

The reason `jp` was introduced during reconstruction was that the assembler reported:

    Branch too far

indicating that the relative jump range had been exceeded.

This suggests that the original code may have used one of the following techniques:

* intermediate labels ("branch trampolines")
* different code layout
* alternative conditional branching structures

Further investigation is required to determine how the original code kept the branches within relative range.

---

## Confirmed instruction-encoding discrepancy

Further binary inspection identified another concrete source-level cause of the mismatch.

The reconstructed source uses XASM forms such as `pushs imr`, `pops imr`, `pushs x`, and `pops x`, but the original binary uses shorter one-byte opcodes for the corresponding operations.

Observed examples:

| operation | reconstructed bytes | size | original bytes | size |
|-----------|---------------------|------|----------------|------|
| pushs imr | `30 e8 37 fb` | 4 | `2f` | 1 |
| pops imr  | `30 e0 27 fb` | 4 | `3f` | 1 |
| pushs x   | `b4 37`       | 2 | `2c` | 1 |
| pops x    | `94 27`       | 2 | `3c` | 1 |

This accounts for 8 bytes of the remaining difference:

- `pushs/pops imr`: 6 bytes
- `pushs/pops x`: 2 bytes

This strongly suggests that the historical source used shorter native opcodes (or different assembler mnemonics) rather than the longer XASM-expanded `pushs/pops` forms used in the current reconstruction.

---

## Confirmed mnemonic conversion error

Further reconstruction work identified a concrete source-conversion error.

The original PLAY3 source used the short native forms:

- `pushu imr`
- `popu imr`

which assemble to one-byte opcodes:

- `pushu imr` = `2f`
- `popu imr`  = `3f`

During reconstruction these were incorrectly converted to:

- `pushs imr`
- `pops imr`

which XASM assembles into longer multi-byte sequences:

- `pushs imr` = `30 e8 37 fb`
- `pops imr`  = `30 e0 27 fb`

Correcting this conversion reduced the reconstructed code size difference significantly.

After this correction:

- reconstructed code size: 1368 bytes
- original code size: 1360 bytes
- remaining difference: +8 bytes

Of this remaining difference, 6 bytes are explained by six `jp` instructions that appear to correspond to shorter `jr` branches in the original source.

This leaves only 2 bytes still unidentified.

---

## Major structural mismatch located in `beep_out3`

Section-by-section comparison now shows that most major routines match structurally, including `init1`, `init2`, `main2`, `mml`, `beep_out0`, and `mml_data`.

The remaining large structural difference is concentrated in `beep_out3`.

The reconstructed version includes a 28-byte initialization block at the start of `beep_out3`:

- `mv [partN_coX+1], reg` ×7

but the original binary appears to begin the routine directly at `loop:` without this block.

In addition, the `skip13` delay padding differs by one byte (`nop` count).

This strongly suggests that the current reconstruction has misidentified the true boundary of `beep_out3`, and that the initialization logic may belong to a different location in the original program structure.

This suggests that the reconstruction process likely absorbed
a separate initialization sequence into the `beep_out3` routine,
resulting in a misidentified routine boundary.

---

## Final byte-level comparison results

After verifying the scanned source listing and reconstructing the XASM-compatible source,  
a byte-by-byte comparison was performed between:

- the original PLAY3 binary extracted from the magazine distribution
- the newly assembled `play3_pushu.asm`

Fresh assembly was confirmed using the `-O` output flag to ensure that the object file was regenerated.

### Binary sizes

| Item | Size |
|-----|------|
| Original body | 1360 bytes |
| Reconstructed body | 1369 bytes |
| Difference | +9 bytes |

First mismatch occurs at:

```
offset = 0x0022
orig = 0xFA
ours = 0xEF
```

---

# Detailed difference breakdown

The remaining **+9 bytes** can be fully explained by three independent sources.

---

# 1. `mml_conv` structural difference (-11 bytes)

Three sub-regions in the `mml_conv` routine differ between the original binary and the reconstructed XASM output.

### DIFF 1A – `mml_conv_lp` entry structure (-6B)

Address range:

```
orig  0xbf091 – 0xbf0c7  (55 bytes)
ours  0xbf091 – 0xbf0c1  (49 bytes)
```

Bytes present only in the original:

```
90 24    mv  a,[x++]
60 22    cmp a,'"'
18 8f    jrz +0x8f
```

These correspond to the original loop entry sequence for `mml_conv_lp`.

The reconstructed source uses a slightly different control flow structure due to XASM label handling.

---

### DIFF 1B – internal instruction encoding (-1B)

Address range:

```
orig  0xbf0c8 – 0xbf123
ours  0xbf0c2 – 0xbf11c
```

This region contains several encoding differences (including the branch around `jp@0xbf10a`).

Individual differences cancel each other out, producing a net size difference of:

```
-1 byte
```

---

### DIFF 1C – later part of `mml_conv` (-4B)

Address range:

```
orig  0xbf124 – 0xbf1f9  (214 bytes)
ours  0xbf11d – 0xbf1ee  (210 bytes)
```

Observed causes:

```
extra jp instructions in reconstruction: +3B
shorter instruction encodings elsewhere: -7B
---------------------------------------------
net result: -4B
```

---

### Total `mml_conv` difference

```
DIFF 1A  -6B
DIFF 1B  -1B
DIFF 1C  -4B
----------------
TOTAL   -11B
```

---

# 2. `beep_out3` initialization block (+28 bytes)

Address range:

```
0xbf3e4 – 0xbf3ff
```

Bytes present only in the reconstructed binary:

```
aa 05 f4 0b  mv [0xbf405], ba
ab 10 f4 0b  mv [0xbf410], i
ab 50 f4 0b  mv [0xbf450], i
ad 17 f4 0b  mv [0xbf417], y
ad 38 f4 0b  mv [0xbf438], y
ad 57 f4 0b  mv [0xbf457], y
ad 6b f4 0b  mv [0xbf46b], y
```

These correspond exactly to the seven initialization instructions printed in the magazine listing:

```
beep_out3:  local

    mv [part1_co1+1],ba
    mv [part2_co1+1],i
    mv [part2_co2+1],i
    mv [part3_co1+1],y
    mv [part3_co2+1],y
    mv [part3_co3+1],y
    mv [part3_co4+1],y
```

The scans clearly confirm these instructions (magazine lines 584–590).

However, the original binary begins directly with:

```
dec ba
```

Therefore this **28-byte block appears only in the printed source**, not in the distributed binary.

Possible explanations include:

- a difference between the printed listing and the distributed program
- conditional assembly in the original environment
- or assembler/linker output differences.

---

# 3. Trailing zero padding in the original binary (-8 bytes)

At the end of the original program, the following padding appears:

```
00 00 00 00 00 00 00 00
```

This block exists in the original binary but is not emitted by XASM.

Important observations:

- all declared variables in `length_data+` match exactly (61 bytes)
- the extra 8 bytes are **not associated with any printed declaration**

Therefore this padding most likely originates from:

- assembler alignment
- linker behavior
- or implicit segment padding in the original PC-9801/MS-DOS toolchain.

---

# Final size equation

```
mml_conv structural difference     -11B
beep_out3 initialization block     +28B
trailing padding                   -8B
---------------------------------------
TOTAL                               +9B
```

---

# Reconstruction status

The printed PLAY3 source listing has now been fully verified against the magazine scans.

The remaining **+9 byte difference** is no longer attributable to OCR or transcription errors.  
Instead, it results from differences between:

1. the printed source listing,
2. the original PC-9801/MS-DOS assembly environment,
3. and the modern XASM reconstruction workflow.

From a historical reconstruction perspective, the source transcription can now be considered **scan-verified**.

---

Current comparison results strongly suggest that the published PLAY3 source listing and the distributed historical binary are not perfectly identical representations of the same assembled output.

At least part of the remaining difference appears to reflect either:
1. source-level divergence between the printed listing and the distributed program, or
2. code-generation differences caused by the original PC-9801/MS-DOS assembly environment.

The `beep_out3` initialization block is the strongest evidence for this discrepancy, because it is clearly present in the printed source but absent at the corresponding location in the original binary.

---

## Conclusion

The project has progressed beyond file-format uncertainty.

The remaining gap is no longer “what format is this file?” but rather:

> which internal structure differs between the historical PLAY3 binary and the reconstructed XASM source?

That is a much narrower and more tractable problem.

At this stage, the best next source of evidence is the PLAYX scan.
