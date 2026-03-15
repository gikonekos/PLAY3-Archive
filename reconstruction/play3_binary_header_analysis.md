# PLAY3 Header Format Analysis

Reference binaries used for header comparison are included in `reconstruction/arc`.

This document analyzes the machine-language file header used by the historical PLAY3 binary and compares it with other real SHARP PC-E500 series binary files.

The purpose is to determine whether the difference between `PLAY3` and the reconstructed `play3_xasm.obj` is caused by file format or by the machine code body itself.

---

## Files compared

The following real machine-language files were compared:

| File | Size |
|------|------:|
| PLAY3 | 1376 bytes |
| play3_xasm.obj | 1407 bytes |
| YM | 3504 bytes |
| 3D | 1681 bytes |

For reference, ASCII BASIC files were also provided, but they are not part of the machine-language header comparison:

- `BOTTA2.BAS`
- `HOLY.BAS`
- `DASH2.BAS`

---

## Common header structure

The first 16 bytes of each machine-language file are:

### PLAY3

```hex
FF 00 06 01 10 50 05 00 00 F0 0B FF FF FF 00 0F
```

### play3_xasm.obj

```hex
FF 00 06 01 10 6F 05 00 00 F0 0B FF FF FF 00 0F
```

### YM

```hex
FF 00 06 01 10 A0 0D 00 00 E0 0B FF FF FF 00 0F
```

### 3D

```hex
FF 00 06 01 10 81 06 00 00 E0 0B FF FF FF 00 0F
```

These files clearly share the same header format.

---

## Confirmed result: 16-byte common machine-language header

All compared machine-language files begin with the same 16-byte header structure.

This means that `play3_xasm.obj` is not merely an assembler-internal object file format unrelated to the real machine; it already uses the same external machine-language file structure as the historical binaries.

Therefore, the difference between `PLAY3` and `play3_xasm.obj` is **not** caused by a different header format.

---

## Confirmed result: body size is stored in the header

A strong pattern appears in bytes 5-6 of the header.

### PLAY3

- total size: `1376`
- body size excluding 16-byte header: `1360`
- `1360 = 0x0550`
- header bytes 5-6: `50 05`

### play3_xasm.obj

- total size: `1407`
- body size excluding 16-byte header: `1391`
- `1391 = 0x056F`
- header bytes 5-6: `6F 05`

### YM

- total size: `3504`
- body size excluding 16-byte header: `3488`
- `3488 = 0x0DA0`
- header bytes 5-6: `A0 0D`

### 3D

- total size: `1681`
- body size excluding 16-byte header: `1665`
- `1665 = 0x0681`
- header bytes 5-6: `81 06`

This confirms that:

- bytes **5-6** store the machine-code body length
- encoding is **little-endian**
- the header length itself is **16 bytes**

---

## Provisional header interpretation

Based on the compared files, the header can be described as:

| Offset | Bytes | Meaning |
|--------|-------|---------|
| 00 | `FF` | file marker |
| 01 | `00` | file type or fixed value |
| 02-04 | `06 01 10` | constant field, exact meaning not yet confirmed |
| 05-06 | length | machine-code body length (little-endian) |
| 07-08 | `00 00` | reserved or fixed field |
| 09-10 | address-like value | likely entry point or execution-related address |
| 11-15 | `FF FF FF 00 0F` | fixed trailer or loader metadata |

This interpretation is still provisional for some fields, but the body-length field is now strongly confirmed.

---

## Entry-point-like field

Bytes 9-10 differ between files:

- PLAY3: `F0 0B`
- play3_xasm.obj: `F0 0B`
- YM: `E0 0B`
- 3D: `E0 0B`

This strongly suggests that bytes 9-10 are an address-related field, most likely:

- execution start address, or
- machine-language start/load address

The exact semantics still require further validation, but this field is clearly meaningful.

---

## What this means for PLAY3 reconstruction

This comparison changes the interpretation of the previous binary mismatch.

Earlier it was possible to suspect that `PLAY3` and `play3_xasm.obj` had different outer file container formats.

That is now unlikely.

Instead:

- `PLAY3` and `play3_xasm.obj` use the same 16-byte machine-language file header format
- the mismatch is mainly in the machine-code body length and body contents

Therefore the current reconstruction status is:

| Item | Status |
|------|------|
| Common real-machine file format identified | confirmed |
| Header length | confirmed as 16 bytes |
| Body length field | confirmed |
| Header-vs-body distinction | confirmed |
| Full binary identity between PLAY3 and play3_xasm.obj | not yet achieved |

---

## Important implication

This means the reconstruction project has already solved one major archival question:

> the historical PLAY3 binary and the reconstructed play3_xasm.obj belong to the same external SHARP pocket computer machine-language file format.

So the remaining problem is narrower and better defined:

> reconstruct the machine-code body exactly.

This is much easier to reason about than a mixed “format vs code” problem.

---

## BASIC files

The uploaded BASIC files:

- `BOTTA2.BAS`
- `HOLY.BAS`
- `DASH2.BAS`

are plain ASCII BASIC source files and do not use the machine-language binary header format.

They are useful as related program materials, but they do not directly help identify the machine-language header layout.

---

## Conclusion

Comparison with additional real machine-language binaries shows that the PLAY3 file header is not unique.

The following points are now strongly established:

1. SHARP PC-E500 machine-language files use a common 16-byte header.
2. Header bytes 5-6 store the body size in little-endian format.
3. `PLAY3` and `play3_xasm.obj` use the same file format.
4. The remaining mismatch is in the machine-code body, not in the outer file header.

This is an important step toward a complete reconstruction, because it isolates the remaining problem to exact code recovery rather than file container reproduction.

---

## Future work

The next useful step is:

1. analyze the exact meaning of bytes `02-04`
2. confirm the semantics of bytes `09-10`
3. compare the body of `PLAY3` and `play3_xasm.obj` in functional sections
4. determine whether the current reconstructed source is:
   - an expanded variant,
   - a corrected/rearranged version,
   - or still divergent from the historical original
