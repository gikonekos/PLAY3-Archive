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

### Sample Music Listing

```basic
1000 CLEAR :CLS :WAIT 0
1010 LOCATE 0,0:PRINT "PLAY3 ｻﾝﾌﾟﾙﾐｭｰｼﾞｯｸ":PRINT "COMPOSED BY KAZUMI MATSUNOKI":PRINT "(C) 1993.9.12"
1020 PLAY "T80O1:O1"
1030 *A:PRINT "*A ";
1040 PLAY "L3>C<RL8R:O1L3CC#DL1CFL5FL1#F#FGG"
1050 PLAY "O1L8RL5G:L3CC#DL1C<#AL5#AL1#AG#A>B"
1060 PLAY "L9>C<:O1L3CC#DL1CFL5FL1#F#FGG"
1070 PLAY "L3#AR#AR#A#AL1#AG#AB:L3CC#DL1C<#AL5#AL1#AG#A>B"
1080 *B1:PRINT "*B1 ";
1090 PLAY "O1L3R>C<#AGL4#A>C<L3G:O1L3CC#DL1CFL5FL1#F#FGG"
1100 PLAY "L3>#D#DL5DL4<#A>C<L3#A:L3CC#DL1C<#AL5#AL1#AG#A>B"
1110 PLAY "L3R>C<#AGL4#A>C<L3G:L3CC#DL1CFL5FL1#F#FGG"
1120 PLAY "L3FFFRGL1GGG#AR#A:L3CC#DL1C<#AL5#AL1#AG#A>B"
1130 *B2:PRINT "*B2 ";
1140 PLAY "O1L3R>C<#AGL4#A>C<L3G:O1L3CC#DL1CFL5FL1#F#FGG"
1150 PLAY "L3>#D#DL5D<L4#A>C<L3#A:L3CC#DL1C<#AL5#AL1#AG#A>B"
1160 PLAY "L3R>C<#AGL4#A>C<L3G:L3CC#DL1CFL5FL1#F#FGG"
1170 PLAY "O2L1#DL3CL1#DL3CL1FL3CL1#FL3CL1GFG#A:L1CL3#DL1CL3#DL1CL3<#A>L1<GL3#AL1GG#A>D"
1180 *C1:PRINT "*C1 ";
1190 PLAY "O2L9>C<:O1L3CC#DL1CFL5FL1#F#FGG"
1200 PLAY "L3#AR#GRGRFR:L3CC#DL1C<#AL5#AL1#AG#A>B"
1210 PLAY "L1#DFGL3C>C<L1G#AG#AL3>C<L1G:L3CC#DL1C<#AL5#AL1#AG#A>B"
1220 PLAY "L1F#DF#DF#DF#DF#DFL3G#AL1G:L3CC#DL1C<#AL5#AL1#AG#A>B"
1230 *C2:PRINT "*C2 ";
1240 PLAY "O3L9G:L3CC#DL1CFL5FL1#F#FGG"
1250 PLAY "L3FR#DRDR<#A>R:L3CC#DL1C<#AL5#AL1#AG#A>B"
1260 PLAY "O2L1#A#AB>C<L3RL1#A#AB>C<L3RL1#A#AB>C<:L3CC#DL1CFL5FL1#F#FGG"
1270 PLAY "L1RGGRGRGRGR FFF#AR#A:L1CL3#DL1CL3#DL1CL3<#AL1GL3#AL1GG#A>D"
1280 GOTO *A
```
