# PLAY3 Binary Header Analysis

This document analyzes the machine-language file header used by the historical `PLAY3` binary and compares it with other real SHARP PC-E500 series machine-language binaries.

Reference comparison files used here are included in:

- `reconstruction/arc/3D`
- `reconstruction/arc/YM`

The purpose of this analysis is to determine which parts of the file format are fixed header metadata and which parts belong to the actual machine-code body.

---

## Files compared

| File | Size |
|------|-----:|
| PLAY3 | 1376 bytes |
| play3_xasm.obj | 1407 bytes |
| YM | 3504 bytes |
| 3D | 1681 bytes |

---

## Common 16-byte header

All compared machine-language binaries begin with the same 16-byte outer structure.

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

This confirms that the files belong to the same external machine-language file format.

---

## Confirmed field: body length

Bytes 5-6 store the machine-code body length in little-endian order.

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

This field is now strongly confirmed.

---

## Strong hypothesis: byte 4 indicates header size

All compared binaries contain `10` at byte 4.

The executable body begins immediately after the first 16 bytes in all observed cases.

This strongly suggests that byte 4 (`0x10`) represents the header size or data-start offset.

That is:

- byte 4 = `0x10`
- header length = `16 bytes`

This interpretation matches all compared files.

---

## Strong hypothesis: bytes 9-10 encode the load address in 256-byte units

The most important new observation comes from `play3_xasm.asm`.

The reconstructed source contains:

```asm
org 0bf000h
```

The generated `play3_xasm.obj` contains the following header bytes at positions 9-10:

```hex
F0 0B
```

Interpreted as a little-endian value:

```text
0x0BF0
```

If this value is multiplied by `0x100`, the result is:

```text
0x0BF0 << 8 = 0x0BF000
```

This exactly matches the `ORG` address used in the source.

Therefore, bytes 9-10 are very likely an address field representing the machine-code load origin in 256-byte units.

This interpretation also fits the other binaries:

- PLAY3: `F0 0B` -> `0x0BF000`
- YM: `E0 0B` -> `0x0BE000`
- 3D: `E0 0B` -> `0x0BE000`

The exact semantics still need further confirmation, but this field is clearly address-related and is very likely the load origin.

---

## Provisional header interpretation

Based on the currently available evidence, the 16-byte header can be described as follows:

| Offset | Bytes | Interpretation |
|--------|-------|----------------|
| 00 | `FF` | file marker |
| 01 | `00` | fixed value / file type |
| 02-03 | `06 01` | unknown fixed field |
| 04 | `10` | header length or body offset |
| 05-06 | length | machine-code body length (little-endian) |
| 07-08 | `00 00` | reserved or fixed field |
| 09-10 | address | likely load origin in 256-byte units |
| 11-15 | `FF FF FF 00 0F` | fixed trailer / loader metadata |

Some fields remain unknown, but the overall structure is now much clearer.

---

## What this means for PLAY3 reconstruction

This comparison narrows the remaining problem significantly.

The mismatch between `PLAY3` and `play3_xasm.obj` is not caused by a different external file format.

The following points are now strongly supported:

1. `PLAY3` and `play3_xasm.obj` use the same machine-language file format.
2. The header length is 16 bytes.
3. Bytes 5-6 store body size.
4. Bytes 9-10 likely store the load origin in 256-byte units.
5. The remaining mismatch is in the machine-code body itself, or in assembler output options affecting body layout.

This is important because it isolates the reconstruction problem to code generation rather than container format.

---

## Note on XASM option differences

The current size mismatch is:

- PLAY3 body: `1360 bytes`
- play3_xasm.obj body: `1391 bytes`

Difference:

- `31 bytes`

At this stage, one plausible explanation is that the difference may be caused by assembler output behavior or option selection rather than by a totally different source body.

This remains a hypothesis and is not yet proven.

---

## Conclusion

Comparison with additional real machine-language binaries shows that the PLAY3 header is part of a common SHARP PC-E500 machine-language binary format.

The strongest conclusions so far are:

- the file header is 16 bytes long
- byte 4 is very likely the header-size field
- bytes 5-6 store body length
- bytes 9-10 very likely encode the load origin in 256-byte units
- `PLAY3` and `play3_xasm.obj` share the same outer file format

The next step is to determine whether the remaining body mismatch is caused by source differences or by XASM output options and layout behavior.
