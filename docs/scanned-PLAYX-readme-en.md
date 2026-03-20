```

PC-E500 / E550 / 1480U / 1490U (II)

[Three-Voice Polyphonic Program PLAYX]
● Keita Morita

■ Introduction

This is a program that enables three-voice polyphonic performance on the E500.
If you think “there’s no way that’s possible,” please try typing it in once.
It will definitely stimulate your sense of hearing.

---

■ How to Input

Please secure at least 4 KB of machine language area appropriately.
If you are unsure, do as follows:

POKE &BFE03,&1A,&FD,&0B,&0,&10,&0
CALL &FFFD8

After that, input the program carefully without mistakes,
and be sure to save it to cassette or floppy disk.

Since this uses machine language, if you make a typing error,
it may run out of control and destroy the program.

When you RUN the program, it writes the machine language
and sets up the PLAYX command.
Once executed, this BASIC program is no longer needed.

---

■ Usage

PLAYX "MML1 : MML2 : MML3"

Use it as shown above.
Since three parts are written within a single part,
use ":" (colon) to separate each part.

For example, a C major chord (Do-Mi-So) is:

PLAYX "C : E : G"

The PLAYX command can also be executed directly.

---

■ Notes

MML data is processed by directly reading text,
so the use of string variables or string functions is not possible.

When the PLAYX command finishes, it checks the ON key.
If you want to stop playback midway, press the ON key slightly longer.
This generates a BREAK and stops execution.

---

■ MML Data (Music Macro Language)

A single note is determined by specifying:
which octave, which pitch, and how long it lasts.

In general form:

One note … [Octave specification] [#] Note name [Length]

Items in [ ] may be omitted.

Below is the explanation of MML commands
(almost identical to "PLAY" in PJ July 1990 issue).

---

■ Note Names

The letters "CDEFGAB" correspond respectively to:

Do Re Mi Fa So La Ti

---

■ Note Length

The length is specified by a number (0–9) following the note name.
The relationship between numbers and note values is shown in Figure 1.

When the same note length continues,
the length specification can be omitted from the second note onward.

---

■ Note Length and Symbols (Figure 1)

Symbol : Name

0 : 32nd note  
1 : 16th note  
2 : Dotted 16th note  
3 : 8th note  
4 : Dotted 8th note  
5 : Quarter note  
6 : Dotted quarter note  
7 : Half note  
8 : Dotted half note  
9 : Whole note  

---

■ Rest

R [Length]

A rest.
The length is specified in the same way as for notes.

---

■ Pitch Specification

# [Note]

Raises the note by one semitone.
Since flats are not available, use "#" instead.

+ , - [Note]

"+" plays the note one octave higher,
"-" plays the note one octave lower.

However, this only changes the octave temporarily.
If "+" or "-" is omitted, it returns to the original octave.

---

■ Octave

O [Octave value]

Specifies the octave.
Octaves range from 00 to 04,
and larger values correspond to higher pitch.

< , >

Raises or lowers the octave by one.

Once changed, the octave remains until changed again
by the O command or < > command.

---

■ Tempo

T [Tempo value]

Sets the tempo.

However, only T1 and T2 are supported.
T2 is faster than T1.

Fine tempo adjustment is achieved by setting
the value of internal RAM address &H17.

---

■ Caution

When using PLAYX, as in the sample program,
be sure to write some value to &H17
and set the octave for each part.

Since this program was written somewhat casually by the author,
it does not perform thorough checks.

It will not run out of control,
but it may produce strange sounds,
or if a large value is assigned to &H17,
it may perform extremely slow playback.

---

■ Drawbacks

Higher-pitched notes are out of tune.

Although a range of 5 octaves is provided,
better sound quality is obtained if kept within O1–O3.

The reason high notes are inaccurate
is that the pitch counter is 8-bit.

Also, higher-pitched sounds tend to stand out more than lower ones,
so it is better to use higher notes for the melody
compared to other parts.

---

■ Principle of Three-Voice Polyphony

A BEEP sound is produced by turning the speaker ON and OFF
at a fixed interval.

If the ON/OFF interval becomes longer,
the period increases and the pitch becomes lower.

To achieve three-voice polyphony,
the same process as BEEP is executed simultaneously
for three parts.

Each of the three parts has its own counter
with an initial value corresponding to its pitch,
and each part switches ON/OFF independently.

If the waveform changes are illustrated,
they appear as shown in Figure 2.

---

■ Hidden Feature

Actually, "U" can be used for specifying note length.

The initial value corresponds to triplet eighth notes.

By rewriting the value of "U",
the user can freely define note lengths.

The address where "U" is stored is &BF334H.

Since the values for 16th, 8th, and quarter notes are
6, 12, and 24 respectively,
calculate proportionally to obtain the desired length
and write it (maximum value is 127).

Also, slightly opening the gap between the E500’s cover and body
may make the sound easier to hear.

---

■ External RAM Memory Map

BF000–BF021 : PLAYX command registration  
BF022–BF08C : Initial settings such as pitch  
BF08D–BF0D1 : Locate start addresses of each part  
BF15F–BF1F3 : MML command processing  
BF1F4–BF26B : Pitch and length processing  
BF26C–BF271 : Program termination processing  
BF272–BF2C9 : Sound generation processing  
BF2CA–BF329 : Pitch table  
BF32A–BF334 : Length table  

---

■ Final Remarks

This program has grown through both praise and criticism from many people.
I would like to take this opportunity to express my gratitude.

---

■ References

1) COR.: “PLAY”, PJ July 1990 issue  
2) Tomohisa Konno: “Let’s Make Music with Three-Voice Harmony”, oh! MZ July 1984 issue  
3) Yoichiro Hirano, Koji Yamamoto: “Three-Voice Harmony Program”, oh! MZ October 1984 issue  
4) PC-E500 / PC-1480U Practical Study, Kogakusha

```
