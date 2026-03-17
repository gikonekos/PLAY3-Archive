# PLAY3 XASM Output Format Check

This document tests whether the current mismatch between the historical `PLAY3` binary and the reconstructed `play3_xasm.obj` can be explained only by XASM output format options.

---

## Purpose

A plausible hypothesis was that the remaining size difference between `PLAY3` and `play3_xasm.obj` might be caused only by the XASM output format setting.

To test this, the following files were compared:

- `PLAY3`
- `play3_xasm.obj`
- `play3_rebuilt_bin.bin`

---

## Compared files

| File | Size |
|------|-----:|
| PLAY3 | 1376 bytes |
| play3_xasm.obj | 1407 bytes |
| play3_rebuilt_bin.bin | 1397 bytes |

---

## Key result

The body of `play3_xasm.obj` and the body of `play3_rebuilt_bin.bin` are identical after removing their different outer headers.

Specifically:

- `play3_xasm.obj[16:]`
- `play3_rebuilt_bin.bin[6:]`

are byte-for-byte identical.

This means:

- the default XASM object output and the binary output contain the same machine-code body
- the difference between those two files is only the outer file wrapper

---

## Interpretation

This is important because it rules out a simple explanation.

If the mismatch with `PLAY3` were caused only by object format selection, then changing the XASM output type should also change the body comparison result.

But that does not happen.

Instead:

- XASM object header format changes
- XASM binary header format changes
- the generated code body remains the same

Therefore the remaining mismatch between `PLAY3` and `play3_xasm.obj` is **not explained only by output format options**.

---

## What output-format difference actually changes

Observed structures:

### play3_xasm.obj

```text
[16-byte machine-language file header]
[1391-byte body]
```

### play3_rebuilt_bin.bin

```text
[6-byte binary header]
[1391-byte body]
```

The common body proves that output type affects only the file container.

---

## Comparison with PLAY3

### PLAY3

```text
[16-byte machine-language file header]
[1360-byte body]
```

### play3_xasm.obj

```text
[16-byte machine-language file header]
[1391-byte body]
```

Body size difference:

```text
1391 - 1360 = 31 bytes
```

Since output-format selection does not change the generated body, this 31-byte difference must come from the body generation itself.

---

## Strong conclusion

The remaining mismatch is not a simple “OBJ vs BIN” problem.

It is more likely caused by one of the following:

- assembler code generation behavior
- source reconstruction differences
- automatic pre-byte generation behavior
- directive expansion differences
- reserved area / padding differences
- other assembly-time behavior affecting the actual body

---

## Additional observation

The body relationship is now clearer:

- `play3_xasm.obj[16:] == play3_rebuilt_bin.bin[6:]`
- `PLAY3[16:] != play3_xasm.obj[16:]`

So the investigation should now focus on **body generation**, not outer file format.

---

## Conclusion

The hypothesis that the mismatch is caused only by an XASM output option difference is not supported.

What has been confirmed instead is:

1. XASM output format changes only the outer header/wrapper.
2. The generated body is the same between `play3_xasm.obj` and `play3_rebuilt_bin.bin`.
3. The remaining 31-byte difference with `PLAY3` lies in the machine-code body itself.

The next step should therefore be a section-by-section body comparison to determine where those 31 bytes are introduced and whether they are caused by source differences or XASM assembly behavior.
