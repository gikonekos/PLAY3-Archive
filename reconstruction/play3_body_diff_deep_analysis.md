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

## Conclusion

The project has progressed beyond file-format uncertainty.

The remaining gap is no longer “what format is this file?” but rather:

> which internal structure differs between the historical PLAY3 binary and the reconstructed XASM source?

That is a much narrower and more tractable problem.

At this stage, the best next source of evidence is the PLAYX scan.
