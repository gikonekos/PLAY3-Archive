## Sample Music Program

The following BASIC program is the sample music included with **PLAY3 Ver.1.00**, published in:

**Pocket Computer Journal – November 1993**

The program displays the following credit on screen:

PLAY3 サンプルミュージック  
COMPOSED BY KAZUMI MATSUNOKI  
(C) 1993.9.12

This indicates that the sample music was composed by **Kazumi Matsunoki**.

The music data is written as a sequence of `PLAY` statements and organized into labeled sections:

- `*A`
- `*B1`
- `*B2`
- `*C1`
- `*C2`

Each section contains musical phrases written for the PLAY3 driver.

### Musical Structure

The program follows the musical structure below:

```
A → B1 → B2 → C1 → C2 → (loop back to A)
```

At the end of the program the following statement appears:

```
GOTO *A
```

This causes the music to loop indefinitely, making the program a continuous demonstration of PLAY3 playback.

The piece serves as a practical example of PLAY3 running on the **SHARP PC-E500 / PC-E550 pocket computer series**, producing **three-voice polyphonic music from the internal 1-bit buzzer** through software mixing.

### Real Hardware Demonstration

Example playback of the sample music running on a SHARP PC-E550:

https://youtube.com/shorts/h5b-ItGam78



