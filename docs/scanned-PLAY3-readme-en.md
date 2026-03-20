# PLAY3 Ver1.00 English Translation

> Source: *Pocket Computer Journal*, November 1993 issue, “PLAY3 Ver1.00”  
> Policy: **Program listings are omitted**, and only the article text is transcribed.  
> Note: Due to the condition of the original scan, a few characters may be uncertain, but the text is reproduced as faithfully as possible.

---

## PC-E500/E550/E650/1480U/1490U(II)/U6000
## Graphics & Sound
# PLAY3 Ver1.00

**●Ryu**

The program previewed in Matsuki's “Let's Go Live” column in the August 1993 issue of PJ — a program capable of playing chords on a pocket computer by itself — has finally been completed.  
Naturally, it also supports the PC-E650.

## Operating Environment

It should work on all Sharp PC-E500 / 1480 series models.  
In practice, operation has been confirmed on the following machines:

- PC-E500 : ROM Version 3
- PC-1490U : ROM Version 6
- PC-E650 : ROM Version 8

## Program Installation

First, reserve at least 4 KB of machine language area.  
To secure 4 KB, execute:

`POKE &BFE03,&1A,&FD,&B,0,&10,0`  
`CALL &FFFD8`

Next, either enter the BASIC listing as printed, or directly input the machine language data contained in the `DATA` statements using a machine language monitor (such as SI-MON).

Once the BASIC listing has been entered, switch to RUN mode and execute:

`RUN`

When executed, the program (machine code) will be written into memory.  
If `Error` appears during the process, check the line number displayed on the screen and correct the corresponding data.  
If `Completed` appears, the installation is finished.

Finally, save the program with:

`SAVEM"E:PLAY3",&BF000,&BF54F`

Save it to a RAM file if possible.  
It is also recommended to save it to cassette tape or floppy disk, or transfer it to a PC using tools such as PLINK for backup.

## Startup

After installation is complete, execute:

`CALL &BF000`

This runs the machine language program.

Two BASIC commands will then be added:

- `PLAY`
- `EXOFF`

You can now use the `PLAY` command.  
When `EXOFF` is executed, the PLAY extension is removed from BASIC. At that moment, a `Syntax error` will always occur. This error is intentional, so there is no need to worry.

## Important Notes

Once the PLAY command has been installed, please avoid the following as much as possible:

1. Releasing the machine language area  
2. Loading or saving other machine language programs  

In particular, **never release the machine language area**.

Doing so may erase the BASIC command extension data and, in the worst case, cause the system to behave unpredictably.

If you need to perform such operations, always execute `EXOFF` first to detach the PLAY command.

If the system behaves strangely because the machine language area was modified without executing `EXOFF`, press the reset switch.

## Usage

Extending BASIC with the PLAY command is meaningless if you do not know how to use it.  
Generally, the PLAY command is written as:

`PLAY"Part 1:Part 2:Part 3"`

The three parts (voices) are separated by `:` (colon).  
For example:

`PLAY"O2L5C:E:G"`

This will produce the chord C-E-G.

## Restrictions and Notes

- Three parts are not mandatory. One or two parts are also acceptable.
- MML data is read directly following the PLAY command, so variables cannot be used.  
  Support for variables may be added in a future version.
- To stop playback during performance, hold down the `ON` key for a while.  
  Interrupts are disabled during sound generation, so `BRK` is only checked when notes change.
- Multi-statements are possible, but should be avoided if possible.
- Only the standard clock speed (2.3 MHz) is supported. At higher speeds such as 4.8 MHz, notes become higher and shorter.

## Command Description

Each part of the PLAY command uses MML (Music Macro Language) to describe musical data to be played.  
The basic format is:

`[#]note[length]`

Elements in `[]` are optional.

## MML Commands

The following MML commands are supported in PLAY3:

- `C–B` : Note names, corresponding to Do through Ti
- `#` : Sharp (raise by a semitone)
- `R` : Rest
- `T` : Tempo
- `L` : Default note length
- `O` : Octave
- `>` : Raise one octave
- `<` : Lower one octave

### Note Names

The note symbols correspond as follows:

- `C` : Do
- `D` : Re
- `E` : Mi
- `F` : Fa
- `G` : So
- `A` : La
- `B` : Ti

Placing `#` before a note raises it by one semitone.

### Note Length

The note length values correspond to:

- `0` : 32nd note
- `1` : 16th note
- `2` : dotted 16th note
- `3` : 8th note
- `4` : dotted 8th note
- `5` : quarter note
- `6` : dotted quarter note
- `7` : half note
- `8` : dotted half note
- `9` : whole note

A length value can be specified after a note name, or after the `L` command.

### Tempo

Specify a value from `1` to `255` after `T`.  
In this system, `1` is the fastest and `255` is the slowest.

### Octave

Specify a value from `0` to `4` after `O`.  
Here, `0` is the lowest and `4` is the highest.

## Principle of Sound Generation

Did you know that sound is heard because air vibrates and reaches the human ear?  
With the PC-E500's `BEEP` command, sound is produced by turning the built-in piezo buzzer on and off at regular intervals, causing it to vibrate.

For example, to produce a 440 Hz tone (A), one cycle is approximately 2 ms, which means the buzzer must be switched on and off every 1.1 ms.

To produce three notes simultaneously, one would ideally output a waveform obtained by combining the three individual waveforms.  
Put more simply, for a single note, the buzzer is turned on and off in accordance with that waveform; for three notes, the actual buzzer state is inverted whenever the timing for one of the parts requires an on/off transition.

However, implementing this directly in a program is quite difficult, and processing also becomes slower.

Therefore, in the actual program, instead of inverting the buzzer, the buzzer is turned on whenever a sound should occur and then turned off immediately afterward.  
As a result, the buzzer is only on for the first instant of the waveform.

---

## The Story Behind PLAY3

PLAY3 was created with reference to an earlier three-voice PLAY extension called **PLAYX** (written by Toshita Morita), published in the February 1992 issue of PJ.

When I entered and ran PLAYX, I was amazed:  
“Wow, the PC-E500 itself can actually play three-note chords. This is incredible.”

However, when I tried making music data of my own, I noticed that the pitch sometimes sounded wrong, and errors would appear even when nothing seemed incorrect.  
It became clear that something about PLAYX was not quite right.

Later, I casually thought about trying to remove the bugs in PLAYX, so I disassembled and analyzed it using a reverse assembler.  
When I tried fixing the bugs, I found that correcting the pitch would require reviewing almost the entire program.  
So I gave up and left it alone for a while.

Then Matsuki said, “I wonder if it would be possible to make a program that can play chords using only the pocket computer itself.”  
When I told him about all this, he said, “Please make it.”  
That is how PLAY3 came to be.

So I analyzed PLAYX again, studied how it generated three-note chords, and rewrote the entire program from scratch.

During this rewrite, I also created a two-voice PLAY command called **PLAY2**.  
This happened because, at first, when I was making three-voice data, processing took too long, and the higher the note, the larger the timing error in the sound cycle became, so the sound quality was not very good.  
I thought, “If the sound is cleaner with two voices, maybe that would be enough...”

But once I started writing three-note chords, two voices alone felt unsatisfying, so I decided to go for full three-note harmony.

However, in order to make the sound quality as close as possible to PLAY2, I repeated many trials and errors, and eventually the processing speed per cycle became almost the same as PLAY2.  
By that point, almost nothing of the original PLAYX program remained.

At first I thought it was complete.  
But although I had written the sound generation routine while checking the cycle counts of each machine instruction listed in *PC-E500 / 1480U Practical Research*, the higher the pitch became, the more the actual pitch deviated from the cycle data calculated from theory.

I thought, “Well, it is impossible for the cycles to match perfectly anyway, so perhaps it cannot be helped.”  
Still, it bothered me, so I tried counting the machine instruction cycles myself — and discovered that the data in *Practical Research* was actually wrong.

After correcting the sound generation routine, the pitch deviation in the higher notes was improved to some extent.

## About the Program and Future Plans

In order to increase processing speed, I sacrificed program size to some degree.  
As a result, the sound quality is better than PLAYX.

The pitch is matched by calculation from the frequency of each note.  
Also, because the machine instruction cycle counts are taken into account, I believe that, for now, sound quality beyond this level is impossible.

In this version, the MML specification differs slightly from the forms now commonly used for note length, tempo, and so on.  
In future upgrades, I would like to make it as close as possible to the MML used on personal computers and similar systems.

I would also like to port it, if possible, to machines other than the PC-E500, such as:

- PC-E200 / G801
- PI-ET1
- FX-890P / Z-1

Among these, I plan to port it to the PC-E200 / G801 in the near future  
(though this is only a plan, so please do not expect too much).

## Conclusion

If you look at the source listing, you may notice that there are a few MML commands that have not been made public.

These were used during development while Matsuki and Motoi helped test the program, and while we were adjusting whether to keep the MML commands the same as PLAYX or to change them.  
In the end, we decided not to publish ambiguous commands.

That does not necessarily mean that they must never be used, but if compatibility of MML data is lost in a future version upgrade (whenever that may be...), correcting such data would probably become difficult.

So when publishing music data in PJ, please do not use undocumented commands.

With that said, everyone, please create lots of music with PLAY3 and present it in PJ! `(^^)`

## References

1. *PC-E500 / 1480U Practical Research*, Kogakusha  
2. Toshita Morita, “PLAYX,” PJ, February 1992  

---

# Small Tips for PLAY3

**●Kazumi Matsuki**

To help you make full use of Ryu's impressive work, PLAY3, I have put together some small pieces of knowledge that may be useful to know.

## Small MML Tips for PLAY3

### A Note on Using the Abbreviated PRINT Command

Once the PLAY command is added (that is, once PLAY3 is installed), `P.` — which had previously been the abbreviated form of the PRINT command — becomes the abbreviated form of the PLAY command instead.

From that point on, until the PLAY command is removed with `EXOFF`, the abbreviated form of PRINT must be written as `PR.`.

Be careful when entering programs.

### Adding Headings at Key Points in a Listing

As in the sample music programs, if you place headings (strings following `*`) or display commands indicating sections at key points in your music program, it becomes easier to play the piece from any point you like, which is convenient for checking the program.

Also, after placing these headings, try to put initial settings such as octave (`O`) and note length (`L`) at the beginning of the MML as much as possible.

This is to prevent the music from being played incorrectly when the program is executed from the middle, starting at one of those headings.

### The Length of an MML Statement Is Flexible

The content of the MML following a PLAY command does not have to be exactly four quarter notes (that is, 4/4 time).

For example, you may freely write it as three quarter notes (3/4 time), six quarter notes, and so on.

As an extreme example, one MML statement could represent the length of twelve quarter notes, or as little as a single sixteenth note.

### Parts Can Be Omitted with Blank Data

In PLAY3, data for three parts is normally written separated by `:` in order to produce three simultaneous notes (for details, see Ryu's PLAY3 usage page).

For example:

`10:PLAY"C5:E5:G5"`

However, if your piece uses only two parts, or even just one part, the unused parts may be omitted in the notation.

For example, if the `E` part is omitted from the above:

`10:PLAY"C5::G5"`

This is valid.  
The following forms are also possible:

`10:PLAY"C5:G5"`

or

`10:PLAY"C5:G5:"`

These notations are convenient when you want to add another part later, or when you want to enter and play the existing parts first.

However, be careful: if the MML begins with `:` as in

`10:PLAY":C5:G5"`

it will not play correctly.

### When the Total Note Length Differs Between Parts

If the total note length of each part differs within a single PLAY command (that is, within a single MML statement), the shorter parts remain silent, as if resting, until the longest part finishes, and only then does execution proceed to the next PLAY statement.

For example:

`10:PLAY"C5:E3:G5"`  
`20:PLAY"C5:E5:G5"`

In the first line, the `E` and `G` parts are only half as long as the `C` part, leaving a blank duration of one eighth note.  
In such a case, the playback is the same as writing:

`10:PLAY"C5:E3R3:G3R3"`  
`20:PLAY"C5:E5:G5"`

### A Note on Playing the Same Pitch Class in Different Octaves Simultaneously

If the same note in different octaves is played at the same time, they apparently do not combine very well: the sounds blend into one another, and compared with playing different notes together, the result becomes thinner (quieter).

When listening to a whole piece, only those places may sound noticeably weak, so when composing, it is a good idea to reinforce them by layering in other notes.

### Adding More Contrast to the Flow of a Piece

Because beep tones are monotonous, simply playing notes by themselves can make a piece sound rather flat.

As one simple way to add accent, consider the following example:

`10:PLAY"L5CGEG:L5CGCCC"`

If you want to make each note in the first part (the melody) feel more distinct, insert rests between them like this:

`10:PLAY"L3CRGRERGR:L5CGCCC"`

This makes each individual note easier to perceive.

It is a very simple trick, but surprisingly effective.

### Using Pseudo-Chords to Add One More Effective Part

This is admittedly a rather forced technique, but depending on the tempo value, alternating short notes can make them sound like a chord.

For example, suppose you want “a chord of C and E in octave 2, with a duration of one quarter note”:

`10:PLAY"L5O2C:L5O2E"`

This normally uses two parts.  
If you want to imitate it with only one part, you can rewrite it as:

`10:PLAY"L0O2CECECECE:L5R"`

This can produce a sound that feels somewhat similar to the intended harmony.

However, this is only a kind of trick made by rapidly alternating short notes, so compared with playing a real chord, the sound feels slightly unsteady.

On the other hand, that instability itself may be used as an effect when you want a vibrato-like wavering tone.

PLAY3 is a performance tool capable of interesting expression depending on how creatively it is used.  
Also, because it is implemented as a BASIC extension command, it is easy to use casually.

Please make good use of this software and try your hand at pocket computer music as well.

## Recording PLAY3 Performances

Just as with recording an ordinary BASIC program to tape, if you connect the main unit, the cassette interface, and a tape recorder, you can record the sound produced by PLAY3 onto tape.

## Listening to PLAY3 at Higher Volume (Unofficial Trick)

This trick is strictly an unofficial one, so please use your own judgment when trying it.  
If any loss or damage should result from this method, we cannot accept responsibility.

First, connect a cassette interface for the E500 (such as the CE-124) to the main unit, and connect the pin jack (microphone side, red) to the `LINE-IN` terminal of a radio-cassette recorder, amplifier, or similar audio device.

Then, with all volume controls set to minimum, start PLAY3 playback on the E500 side, and gradually raise the volume until it reaches a comfortable listening level.

Be careful: if you start playback with the connected audio equipment already set to high volume, you may damage the equipment.  
Also, be careful when turning power on and off during connection.

If you have MIDI-related equipment, try connecting various effects units and enjoy pocket computer performances with a different character.  
In particular, adding reverb (echo effect) is recommended, because it gives the sound more depth.

## Call for Music Programs

As previously announced in the magazine, we plan to begin a relay-style series on pocket computer music in the near future.

Accordingly, we are inviting readers to submit music programs.

Please submit your work in the form of music programs using sound playback routines that have appeared in PJ so far, including Ryu's newly released **PLAY3**.

We are also continuously accepting ambitious new music playback tools that could become the next standard.

As for the content of music programs, original compositions are preferred if possible, but in some cases submissions based on existing game music are also acceptable.

In such cases, however, please be sure to clearly state the original source.

Also, for original pieces, contributions from those who would like their music to be freely used in everyone's pocket computer games are most welcome.  
Please state this clearly when submitting.

For the time being, the music corner will take the form of an irregular series, similar to *Game Design Course*, while we wait for music program submissions from all of you.

Fun ideas to help enliven the music corner are also very welcome.  
We look forward to your submissions.
