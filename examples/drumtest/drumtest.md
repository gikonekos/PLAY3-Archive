# DRUMTEST

DRUMTEST is a demonstration program for the **PLAY3 driver** on the SHARP PC-E500 series pocket computers.

The program demonstrates simple **pseudo drum patterns** using the BASIC `PLAY` command.
The playback patterns are selected randomly to create continuously changing rhythms.

```
Drums test 1995 K.Motoi
```

Author  
Kenkichi Motoi

---

# System Requirements

Hardware

- SHARP PC-E500
- PC-E550
- compatible models

Software

- PLAY3 driver

Install PLAY3:

```
CALL &BF000
```

Run the program:

```
RUN
```

---

# Program Overview

The program repeatedly selects one of eight rhythm patterns.

Program flow:

```
Initialize
↓
Random pattern selection
↓
Bass / Snare / Hi-hat playback
↓
Repeat
```

---

# Pattern Selection

The next rhythm is chosen randomly.

```basic
A=INT(RND 8)+3
GOTO A
```

Eight pattern routines are provided.

```
*A1
*A2
*A3
*A4
*A5
*A6
*A7
*A8
```

---

# PLAY Command Structure

PLAY3 uses three parts separated by `:`.

```
PLAY "part1:part2:part3"
```

Each routine combines different rhythmic phrases.

---

# Drum Parts

Subroutines:

| Label | Function |
|------|------|
| *B | Bass drum pattern |
| *S | Snare pattern |
| *H | Hi-hat pattern |
| *R | Rest |

The main routines call these subroutines in different orders.

Example:

```basic
GOSUB *B
GOSUB *H
GOSUB *S
```

---

# Musical Characteristics

DRUMTEST demonstrates:

- random rhythm generation
- reusable PLAY subroutines
- compact BASIC programming
- simple percussion sequencing

It is an original PLAY3 demonstration program and is not based on any commercial game or music.

---

# BASIC Source

**DRUMTEST.BAS**

```basic
1 CLS :PRINT "Drums test 1995 K.Motoi"
2 PLAY "T5"
3 A=INT (RND 8)+3:GOTO A
4 *A1:GOSUB *B:GOSUB *H:GOSUB *H:GOSUB *H:GOTO 3
5 *A2:GOSUB *S:GOSUB *H:GOSUB *B:GOSUB *H:GOTO 3
6 *A3:GOSUB *B:GOSUB *H:GOSUB *S:GOSUB *B:GOTO 3
7 *A4:GOSUB *B:GOSUB *S:GOSUB *H:GOSUB *S:GOTO 3
8 *A5:GOSUB *B:GOSUB *H:GOSUB *B:GOSUB *H:GOTO 3
9 *A6:GOSUB *S:GOSUB *S:GOSUB *B:GOSUB *S:GOTO 3
10 *A7:GOSUB *B:GOSUB *S:GOSUB *S:GOSUB *H:GOTO 3
11 *A8:GOSUB *B:GOSUB *B:GOSUB *H:GOSUB *S:GOTO 3
13 '*S:PLAY "L1O3BAGFEDC<BAGFEDC<BR:O2L2BAGFEDC<BAGFEDC<BR:O0L2FFFFCCCCCCCCRRRR":RETURN
14 *S:PLAY "L1O3BAGFEDC<BAGFEDC<BR:O2L2BAGFEDC<BAGFEDC<BR:O1L0R3FGABDCFE":RETURN F
15 *B:PLAY "L1O1BAGFEDC<BAGFEDCRR:L1O1BAGFEDCR:L1O2BAGFEDCR":RETURN
16 *H:PLAY "L1O0BRCRBRCRBCRRBRCR:L1O1BRRRRRRR:L1O2BRRRRRRR":RETURN
17 *R:PLAY "R9R5":RETURN
```

---

# File Layout

```
examples
 └─ DRUMTEST
     ├─ DRUMTEST.BAS
     └─ README.md
```

---

# License

Program

© 1995 Kenkichi Motoi
