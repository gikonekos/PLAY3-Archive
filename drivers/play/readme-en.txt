This directory contains the early two-voice PLAY driver by Ryu
for the SHARP PC-E500 series (1992).

-------------------------------------------------------------------------------
                               "PLAY"
                        For PC-E500 / PC-1480U
                   Programmed by T. Kobayashi (Ryu)
-------------------------------------------------------------------------------

This program was created with reference to PLAYX and provides
two-voice simultaneous sound output.


☆★☆  Operating Environment  ☆★☆

 SHARP PC-E500 / PC-1480U series
 (Confirmed to work on PC-E500 ROM Version 3)


☆★☆  Included Files  ☆★☆

    ----name----     -start-     --end--
    PLAYC            0BF000h     0BF1C7h     Auxiliary program for BASIC integration
    PLAY             0BF200h     0BF3D9h     PLAY main program


☆★☆  How to Start  ☆★☆

Load the two programs into the PC-E500 using PLINK, ISH, or a similar tool.

Then execute:

    CALL &BF000 [RET]

This installs the 'PLAY' command into BASIC so that it can be used.

Executing the 'EXOFF' command will detach PLAYX from BASIC.


☆★☆  Differences from PLAYX  ☆★☆

• Only two voices are supported, so the second part does not produce sound.
• Tempo setting previously done with "POKE &17,xxx" can now be set using
  the MML command "Txxx".
• Because of this change, the PLAYX tempo setting method has been removed.
• The octave change symbols "<" and ">" have been reversed.
  ("<" lowers the octave, ">" raises it.)
• Other aspects remain compatible with PLAYX.


☆★☆  Future Plans  ☆★☆

The program has only just reached a working stage, so it is possible
that many bugs still exist. Please try using it so that these bugs
can be discovered and fixed.

The 'PLAY' program contains the main routine. In order to increase
processing speed, it uses a dedicated data format. Because of this,
'PLAYC' is used to integrate the command into BASIC and convert MML
data so that it can be used from BASIC.

Some changes to the MML specification are also planned. For example,
the 'L' command will be added. In PLAYX, if the note length was omitted,
the previously specified length was used. In the future, the default
note length will be determined by the 'L' command instead.

Please keep this in mind when composing music.


☆★☆  Usage, Redistribution, Transfer, and Modification  ☆★☆

The copyright of this document and program belongs to
Tatsuya Kobayashi.

This program was created as a test for the ADV-X project.

Therefore, distribution, use, or transfer of this program to anyone
outside the ADV-X project participants is strictly prohibited.


☆★☆  History  ☆★☆

Ver. 0.10
    Created an original PLAY routine with reference to PLAYX.
    The main program and the BASIC integration program
    (MML converter) were separated.

                                                1992/10/09
