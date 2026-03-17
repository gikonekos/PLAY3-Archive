# PLAY3 Archive

**PLAY3** generates three-voice polyphonic music from the internal 1-bit buzzer using software mixing.

**PLAY3 Ver1.00** — A 3-voice harmony PLAY command extension for Sharp PC-E500/E550/E650/1480U/1490U(II)/U6000 pocket computers, originally published in **Pocket Computer Journal (PJ)** magazine, August 1993 issue, by **Ryu**.

This repository preserves the complete assembler source code (XASM format) of PLAY3, reconstructed from magazine scans after over 30 years.

play3_xasm.asm has all inline comments stripped for XASM parser compatibility. See play3_photo.asm for the fully annotated version.

---

## Files

| File | Description |
|------|-------------|
| `play3_photo.asm` | Complete source transcribed directly from photographs, with original line numbers and Japanese comments preserved |
| `play3_xasm.asm` | XASM-compatible version (converted for actual assembly) |
| `play3_xasm.obj` | Assembled object file (1391 bytes, 0BF000h–0BF56Eh) |

---

## How to Assemble

Use **XASM Ver1.40** (SC62015 cross assembler for Unix/DOS).

```
xasm play3_xasm.asm
```

Build XASM from source (Linux):
```
cd xasm140
cp XASM.H xasm.h
make
```

---

## The OCR Adventure — How This Source Was Recovered

Recovering this source was far from straightforward. Here is an honest account of the journey, in hopes it helps anyone attempting similar preservation work.

### Stage 1: PDF Scan (Low Resolution)

The initial source was a scanned PDF of the original magazine pages. Running OCR (Tesseract, `jpn+eng`) on the 3-column small-font layout produced something that *looked* like assembler source — but was riddled with errors:

- `0` and `O` confused constantly
- `1` and `l` (lowercase L) indistinguishable
- Japanese comments mangled into garbage characters
- Multi-column layout caused lines from different columns to merge
- Line numbers occasionally misread or dropped entirely

The result was a rough skeleton, not a usable source.

### Stage 2: Multiple ZIP Batches of Rescans

The magazine owner generously rescanned the relevant pages and uploaded them in batches (`scan01.zip`, `scan02.zip`, `scan03.zip`, etc.), each containing 3 high-resolution JPEGs.

This improved accuracy significantly. A column-splitting technique (dividing each image into left/center/right thirds before OCR) helped preserve the 3-column layout. However, some images were still too dark — particularly pages covering lines 261–390 — and OCR accuracy remained poor for those sections.

**Key lesson:** Even "high-resolution" scans of a dark or uneven page yield surprisingly poor OCR results.

### Stage 3: Targeted Rescans for Problem Areas

Specific pages were rescanned to address the remaining gaps:

- `nup0030.jpg` / `nup0031.jpg` — Lines 261–390 (octave processing, init routines)
- `nup0030__1_.jpg` — A clearer close-up of lines 344–390 (main loop), photographed flat and bright, which proved dramatically more readable than the earlier scans

One photograph taken on a smartphone under good lighting resolved ambiguities that hours of OCR tuning could not.

### Stage 4: The Decisive Smartphone Photos

After multiple rounds of targeted rescans, 13 sharp smartphone photos of the original magazine were uploaded. These were taken flat-on, in good lighting, and covered the entire source listing.

The difference was night and day. Lines that had been `[?]` for weeks were instantly readable. The entire source was retranscribed from these photos in a single pass, reducing uncertainty markers from dozens to zero.

**Key lesson:** A clear smartphone photo beats a flatbed scanner if the scanner produces dark or skewed results.

---

## XASM Compatibility Notes

The original source targets **XASM Ver1.40** for the SC62015 CPU. Several non-obvious issues were encountered during assembly:

### Instruction Differences

| Original | XASM equivalent | Reason |
|----------|----------------|--------|
| `pushuimr` | `pushs imr` | XASM uses `pushs`/`pops` |
| `popuimr` | `pops imr` | Same |
| `pushu x` | `pushs x` | Same |
| `popu x` | `pops x` | Same |
| `jmz label` | `jrz label` | SC62015 mnemonic |
| `jmc label` | `jrnc label` | SC62015 mnemonic |
| `jpnc label` | `jrnc label` | SC62015 mnemonic |

### Addressing Mode Differences

| Original | XASM equivalent | Reason |
|----------|----------------|--------|
| `[(!sym)]` | `(sym)` | Internal RAM addressing |
| `(octerve_adr)` | `(!octerve_adr)` | equ symbol needs `!` prefix for internal RAM |
| `(length_adr)` | `(!length_adr)` | Same |

### Data Directive Limits

XASM has undocumented limits on operands per line:
- `dw` — maximum **4 values** per line
- `db` — maximum **4 values** per line (5 sometimes works, but unreliable with comments)
- Inline comments on `dw`/`db` lines can cause parse errors — strip them to be safe

### Local Scope Rules

XASM's `local`/`endl` blocks enforce strict scoping:
- Labels defined inside a `local` block are not visible from outside
- To reference a label in an outer scope from inside a `local` block, prefix with `!`: `!global_label`
- To reference an inner label from outside: `!outer_block!inner_label`
- Label *definitions* inside a local block must **not** have `!` prefixed — only references do

### Branch Range

`jrnc` (relative jump if not carry) has a limited range. If the target label is too far away, use `jp` (absolute jump) instead:
```
; jrnc mml_conv_lp  ; may fail with "Branch too far"
jp    mml_conv_lp   ; use absolute jump for distant targets
```

### One Mysterious Fix

Line 235 in the original source reads:
```
add  ba,16
add  x,ba
```
The SC62015 does not support `add ba,immediate`. The correct form is:
```
mv   ba,16
add  x,ba
```
This was likely a typo or OCR artifact in all prior recovered versions, and was only confirmed correct by reading the clear photograph.

---

## About PLAY3

PLAY3 extends the built-in `PLAY` command of the PC-E500 BASIC to support **3-voice simultaneous tone generation** using the internal piezo buzzer. It works by rapidly cycling the buzzer ON/OFF state across three independent timing counters — effectively synthesizing chords from a single 1-bit speaker.

The technique, and the program itself, were inspired by an earlier work **PLAYX** by Toshio Morita (森田敏太), published in PJ February 1992.

PLAY3 is written entirely in SC62015 assembly language and installs itself as a BASIC extension command via the XASM assembler's `local`/`endl` scope mechanism.

---

## Acknowledgements

- **Ryu** — Original author of PLAY3
- **Toshio Morita (森田敏太)** — Author of PLAYX, the inspiration for PLAY3
- **N.Kon and E.Kako** — Authors of XASM Ver1.40
- **Claude (Anthropic)** — OCR extraction, source reconstruction, and XASM debugging assistance
- The magazine owner who patiently rescanned pages multiple times and finally photographed them clearly under good light

---

*Preserved 2026. Originally published PJ Plaza, August 1993.*
