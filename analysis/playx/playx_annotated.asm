; PLAYX disassembly (SC62015) reconstructed from original PLAYX.BIN
; =============================================================
; PLAYX — Complete SC62015 Disassembly (Final)
; Load address: $BF000, Size: 824 bytes ($BF000-$BF337)
; Generated: 2026-03-24
; Reference: "PC-E650/PC-U6000 Practical Research", Chapter 6
; =============================================================
;
; iRAM variable map ($30 page):
;   PITCH1 = (13H)  Voice 3 countdown counter
;   PITCH2 = (14H)  Voice 1 countdown counter
;   PITCH3 = (15H)  Voice 2 countdown counter
;   NPART  = (16H)  Number of active parts (1-3)
;   TEMPO  = (17H)  Tempo value
;   LFLAG  = (18H)  Loop counter / flag
;   VCODE1 = (1BH)  Voice 1 processed flag
;   VREG1  = (1DH)  Voice 1 pitch counter initial value (self-modified target)
;   DLEN1  = (1EH)  Voice 1 default note length
;   VOFS1  = (23H)  Voice 1 MML pointer (20-bit, 3 bytes)
;   OCT1   = (26H)  Voice 1 octave value
;   VREG2  = (28H)  Voice 2 pitch counter initial value
;   DLEN2  = (29H)  Voice 2 default note length
;   VOFS2  = (2EH)  Voice 2 MML pointer
;   OCT2   = (31H)  Voice 2 octave value
;   VREG3  = (33H)  Voice 3 pitch counter initial value
;   DLEN3  = (34H)  Voice 3 default note length
;   VOFS3  = (35H/39H) Voice 3 MML pointer
;   OCT3   = (3CH)  Voice 3 octave value
;   BP     = (ECH)  Base pointer ($1C = voice 1, +$0B stride for voices 2 and 3)
;   IMR    = (FBH)  Interrupt mask register
;   SPK    = (FDH)  Speaker port (bit 4 = audio output)
;
; Voice data structure (BP=ECH, stride=0BH):
;   Start of voice k = BP + k*$0B ($1CH, $27H, $32H)
;   +$00 = MML pointer low byte
;   +$03 = Processing flag
;   +$04 = MML pointer (20-bit)
;   +$07 = Pitch table pointer
;   +$0A = Octave adjustment value
;
; =============================================================

; ----- BASIC command registration ($BF000-$BF021) ------------

PLAYX_ENTRY:  ; $BF000
  $BF000: 0C 13 F0 0B         MV X,$BF013H      ; X = command table address
  $BF004: 30                  PRE $30
  $BF005: BC 80 D1 90         MV [(D1H)+90H],X  ; Register address in OS function table[90H]
  $BF009: 0C 1C F0 0B         MV X,$BF01CH      ; X = command execution address
  $BF00D: 30                  PRE $30
  $BF00E: BC 80 D1 93         MV [(D1H)+93H],X  ; Register execution entry in OS function table[93H]
  $BF012: 07                  RETF

PLAYX_CMD_TABLE:  ; $BF013
  $BF013: 05                  DB 5              ; Command name length
  $BF014: 50 4C 41 59 58      DB "PLAYX"        ; Command name (ASCII)
  $BF019: 7C 00               DW $007C          ; Flags / attributes
  $BF01B: 00                  DB 0

PLAYX_CMD_ADDR:  ; $BF01C
  $BF01C: 7C 22 F0 0B         DD $0BF022H       ; Execution entry point (= PLAYX_INIT)
  $BF020: 00 00               DW 0

; ----- Initialization routine INIT ($BF022-$BF08C) -----------
; Called from BASIC as: PLAYX mml1[,mml2[,mml3]]

PLAYX_INIT:  ; $BF022
  ; Disable interrupts and save registers
  $BF022: 2F                  PUSHU IMR         ; Save IMR on U stack
  $BF023: 30                  PRE $30
  $BF024: CC FB A0            MV (IMR),$A0H     ; Set interrupt mask
  $BF027: 30                  PRE $30
  $BF028: E8 36 EC            MV [--U],(BP)     ; Save BP on U stack

  ; Initialize iRAM
  $BF02B: 30                  PRE $30
  $BF02C: CC EC 00            MV (BP),$00H      ; BP = 0 (absolute-address mode)
  $BF02F: 30                  PRE $30
  $BF030: CC 1F 00            MV (1FH),$00H
  $BF033: 30                  PRE $30
  $BF034: CC 2A 00            MV (2AH),$00H
  $BF037: 30                  PRE $30
  $BF038: CC 35 00            MV (VOFS3),$00H
  $BF03B: 30                  PRE $30
  $BF03C: CC 1B 00            MV (VCODE1),$00H

  ; Initialize pitch-table pointers for each voice work area
  ; MVP = 3-byte copy
  $BF03F: 30                  PRE $30
  $BF040: DC 23 C1 F2 0B      MVP (VOFS1),[$BF2C1H]  ; Voice 1 table pointer initial value
  $BF045: 30                  PRE $30
  $BF046: DC 2E B1 F2 0B      MVP (VOFS2),[$BF2B1H]  ; Voice 2
  $BF04B: 30                  PRE $30
  $BF04C: DC 39 A1 F2 0B      MVP (VOFS3),[$BF2A1H]  ; Voice 3

  ; Clear self-modified locations to $00
  $BF051: 08 00               MV A,$00H
  $BF053: A8 C1 F2 0B         MV [$BF2C1H],A    ; Voice 1 self-modified byte = 0
  $BF057: A8 B1 F2 0B         MV [$BF2B1H],A    ; Voice 2
  $BF05B: A8 A1 F2 0B         MV [$BF2A1H],A    ; Voice 3

  ; Validate NPART (number of parts) -> maximum 3
  $BF05F: 30                  PRE $30
  $BF060: 61 16 03            CMP (NPART),$03H
  $BF063: 1C 04               JRC +4            ; -> $BF069H (continue if <= 3)
  $BF065: 30                  PRE $30
  $BF066: CC 16 01            MV (NPART),$01H   ; If invalid, clamp to 1

  ; Validate DLEN (default note length) -> maximum $0A
  $BF069: 30                  PRE $30
  $BF06A: 61 1E 0A            CMP (DLEN1),$0AH
  $BF06D: 1C 0C               JRC +12           ; -> $BF07BH (continue if valid)
  $BF06F: 30                  PRE $30
  $BF070: CC 1E 05            MV (DLEN1),$05H   ; Clamp default note length to 5
  $BF073: 30                  PRE $30
  $BF074: CC 29 05            MV (DLEN2),$05H
  $BF077: 30                  PRE $30
  $BF078: CC 34 05            MV (DLEN3),$05H

  ; Validate OCT (octave) -> maximum 5
  $BF07B: 30                  PRE $30
  $BF07C: 61 26 05            CMP (OCT1),$05H
  $BF07F: 1C 0C               JRC +12           ; -> $BF08DH (continue if valid)
  $BF081: 30                  PRE $30
  $BF082: CC 26 02            MV (OCT1),$02H    ; Clamp default octave to 2
  $BF085: 30                  PRE $30
  $BF086: CC 31 02            MV (OCT2),$02H
  $BF089: 30                  PRE $30
  $BF08A: CC 3C 02            MV (OCT3),$02H

; ----- Part start detection FIND_PARTS ($BF08D-$BF15E) -------

FIND_PARTS:  ; $BF08D
  $BF08D: 30                  PRE $30
  $BF08E: CC EC 1C            MV (BP),$1CH      ; BP = start of voice 1 work area
  $BF091: 09 03               MV IL,$03H        ; IL = 3 (three-voice loop)

  ; Scan the MML string and look for ':' separators
SCAN_LOOP:  ; $BF093
  $BF093: 90 04               MV A,[X]          ; Read character from X
  $BF095: 60 0D               CMP A,$0DH        ; CR?
  $BF097: 18 2D               JRZ +45           ; -> $BF0C6H (end of string)
  $BF099: 60 3A               CMP A,$3AH        ; ':' ?
  $BF09B: 18 08               JRZ +8            ; -> $BF0A5H (next part boundary)
  $BF09D: A4 04               MV (04H),X        ; Save current position
  $BF09F: CC 00 00            MV (00H),$00H
  $BF0A2: CC 03 01            MV (03H),$01H     ; Flag = active
  $BF0A5: 30                  PRE $30
  $BF0A6: 41 EC 0B            ADD (BP),$0BH     ; Advance to next voice (+$0B)
  $BF0A9: 04 B4 F0            CALL $F0B4H       ; Subroutine: find next separator
  $BF0AC: 1C 18               JRC +24           ; -> $BF0C6H
  $BF0AE: 7C 01               DEC IL            ; Voice counter--
  $BF0B0: 1B 1F               JRNZ -31          ; -> $BF093H (process next voice)
  $BF0B2: 12 12               JR +18            ; -> $BF0C6H

  ; Subroutine: search for ':' or CR
  ; C=0: found ':'
  ; C=1: found CR (end)
  ; $F0B4 = $BF0B4
  $BF0B4: 90 04               MV A,[X]          ; Read character
  $BF0B6: 6C 04               INC X
  $BF0B8: 60 0D               CMP A,$0DH        ; CR?
  $BF0BA: 97                  SC                ; C=1 (CR = end)
  $BF0BB: 1A 01               JRNZ +1           ; -> $BF0BEH
  $BF0BD: 06                  RET
  $BF0BE: 60 3A               CMP A,$3AH        ; ':' ?
  $BF0C0: 9F                  RC                ; C=0 (':' found)
  $BF0C1: 1A 01               JRNZ +1           ; -> $BF0C4H
  $BF0C3: 06                  RET
  $BF0C4: 13 12               JR -18            ; -> $BF0B4H (next character)

  ; Main MML processing loop
  $BF0C6: 30                  PRE $30
  $BF0C7: 61 1B 00            CMP (VCODE1),$00H
  $BF0CA: 15 6C F2            JPNZ $F26CH       ; -> EXIT (all voices finished)
  $BF0CD: 04 D2 F0            CALL $F0D2H       ; Process one note/event
  $BF0D0: 13 0C               JR -12            ; -> $BF0C6H (loop)

  ; One-note processing subroutine ($F0D2 = $BF0D2)
  $BF0D2: 30                  PRE $30
  $BF0D3: CC 1B 01            MV (VCODE1),$01H  ; Processing flag = active
  $BF0D6: 30                  PRE $30
  $BF0D7: CC EC 1C            MV (BP),$1CH
  $BF0DA: 09 03               MV IL,$03H        ; Three-voice loop

PROC_VOICES:  ; $BF0DC
  $BF0DC: 61 03 00            CMP (03H),$00H    ; Is this voice active?
  $BF0DF: 18 0C               JRZ +12           ; -> $BF0EDH
  $BF0E1: 61 00 00            CMP (00H),$00H    ; Remaining MML data?
  $BF0E4: 1A 03               JRNZ +3           ; -> $BF0E9H
  $BF0E6: 04 5F F1            CALL $F15FH       ; MML processing -> pitch calculation
  $BF0E9: 30                  PRE $30
  $BF0EA: CC 1B 00            MV (VCODE1),$00H  ; Clear flag
  $BF0ED: 30                  PRE $30
  $BF0EE: 41 EC 0B            ADD (BP),$0BH     ; Next voice
  $BF0F1: 7C 01               DEC IL
  $BF0F3: 1B 19               JRNZ -25          ; -> $BF0DCH

  ; Compute minimum PITCH value (tempo normalization)
  $BF0F6: 30                  PRE $30
  $BF0F6: CC 13 FF            MV (PITCH1),$FFH
  $BF0FA: 30                  PRE $30
  $BF0FA: CC EC 1C            MV (BP),$1CH
  $BF0FD: 09 03               MV IL,$03H

MIN_PITCH:  ; $BF0FF
  $BF0FF: 61 03 00            CMP (03H),$00H
  $BF102: 18 0A               JRZ +10           ; -> $BF10EH
  ; ... minimum-value calculation
  $BF10E: 30                  PRE $30
  $BF10F: 41 EC 0B            ADD (BP),$0BH
  $BF112: 7C 01               DEC IL
  $BF114: 1B 17               JRNZ -23          ; -> $BF0FFH

  ; Shift / scale PITCH value into LFLAG
  $BF117: 30                  PRE $30
  $BF117: 6D 13               INC (PITCH1)
  $BF119: 1A 01               JRNZ +1           ; -> $BF11CH
  $BF11B: 06                  RET
  $BF11C: 30                  PRE $30
  $BF11D: 7D 13               DEC (PITCH1)

  ; Normalize each voice pitch against PITCH1
  $BF120: 30                  PRE $30
  $BF120: CC EC 1C            MV (BP),$1CH
  $BF123: 09 03               MV IL,$03H

NORM_PITCH:
  $BF125: 80 00               MV A,(00H)
  $BF127: 30                  PRE $30
  $BF128: 4A 13               SUB A,(PITCH1)
  $BF12A: 1C 02               JRC +2            ; -> $BF12EH
  $BF12C: A0 00               MV (00H),A
  $BF12E: 30                  PRE $30
  $BF12F: 41 EC 0B            ADD (BP),$0BH
  $BF132: 7C 01               DEC IL
  $BF134: 1B 11               JRNZ -17          ; -> $BF125H

  ; Compute LFLAG (X = PITCH * TEMPO)
  $BF136: 0C 00 00 00         MV X,$00000H
  $BF13A: 30                  PRE $30
  $BF13B: CC 14 00            MV (PITCH2),$00H
  $BF13E: 9F                  RC
  $BF13F: 30                  PRE $30
  $BF140: F7 13               SHL (PITCH1)      ; PITCH1 <<= 1
  $BF142: 30                  PRE $30
  $BF143: F7 14               SHL (PITCH2)
  $BF145: 9F                  RC
  $BF146: 30                  PRE $30
  $BF147: F7 13               SHL (PITCH1)
  $BF149: 30                  PRE $30
  $BF14A: F7 14               SHL (PITCH2)
  $BF14C: 30                  PRE $30
  $BF14D: 82 13               MV BA,(PITCH1)    ; BA = PITCH1:PITCH2 (16-bit)
  $BF14F: 30                  PRE $30
  $BF150: 81 17               MV IL,(TEMPO)

MULT_LOOP:  ; $BF152
  $BF152: 45 42               ADD X,BA          ; X += BA (repeat IL times)
  $BF154: 7C 01               DEC IL
  $BF156: 1B 06               JRNZ -6           ; -> $BF152H
  ; X = PITCH * TEMPO -> loop count

  $BF158: 30                  PRE $30
  $BF159: A4 18               MV (LFLAG),X      ; Store into LFLAG
  $BF15B: 04 72 F2            CALL $F272H       ; -> VOICE_ROUTE + SOUND_GEN
  $BF15E: 06                  RET

; ----- MML command handling MML_DISPATCH ($BF15F-$BF1F3) -----

MML_DISPATCH:  ; $BF15F
  $BF15F: 2B                  PUSHU I
  $BF160: 84 04               MV X,(04H)        ; X = MML pointer
  $BF162: 30                  PRE $30
  $BF163: CC 15 00            MV (PITCH3),$00H  ; Clear sharp/flat state

PARSE_LOOP:  ; $BF166
  $BF166: 90 04               MV A,[X]          ; Read MML character
  $BF168: 60 0D               CMP A,$0DH        ; CR (end)?
  $BF16A: 18 38               JRZ +56           ; -> $BF1A4H
  $BF16C: 60 3A               CMP A,$3AH        ; ':' (part separator)?
  $BF16E: 18 34               JRZ +52           ; -> $BF1A4H
  $BF170: 60 2B               CMP A,$2BH        ; '+' (sharp)?
  $BF172: 18 57               JRZ +87           ; -> $BF1CBH
  $BF174: 60 2D               CMP A,$2DH        ; '-' (flat)?
  $BF176: 18 5B               JRZ +91           ; -> $BF1D3H
  $BF178: 60 3C               CMP A,$3CH        ; '<' (octave down)?
  $BF17A: 18 43               JRZ +67           ; -> $BF1BFH
  $BF17C: 60 3E               CMP A,$3EH        ; '>' (octave up)?
  $BF17E: 18 45               JRZ +69           ; -> $BF1C5H
  $BF180: 60 4F               CMP A,$4FH        ; 'O' (explicit octave)?
  $BF182: 18 2B               JRZ +43           ; -> $BF1AFH
  $BF184: 60 54               CMP A,$54H        ; 'T' (tempo)?
  $BF186: 18 53               JRZ +83           ; -> $BF1DBH

  ; Note handling (A-G): reference pitch table
  $BF188: 60 23               CMP A,$23H        ; '#' (sharp symbol)?
  $BF18A: 0D CA F2 0B         MV Y,$BF2CAH      ; Y = base pitch table
  $BF18E: 1A 06               JRNZ +6           ; -> $BF196H
  $BF190: 0D FA F2 0B         MV Y,$BF2FAH      ; If '#', use sharp pitch table
  $BF194: 6C 04               INC X             ; Advance past '#'

PITCH_LOOKUP:  ; $BF196
  $BF196: 04 F4 F1            CALL $F1F4H       ; -> PITCH_CALC
  $BF199: 1D 35               JRC -53           ; -> $BF166H (note not found -> continue)
  $BF19B: A0 00               MV (00H),A        ; Save note length / result
  $BF19D: A4 04               MV (04H),X        ; Update MML pointer
  $BF19F: 04 5F F2            CALL $F25FH       ; Output note
  $BF1A2: 3B                  POPU I
  $BF1A3: 06                  RET

  ; End-of-part processing
  $BF1A4: 85 07               MV Y,(07H)        ; Speaker pointer / port pointer
  $BF1A6: 08 00               MV A,$00H
  $BF1A8: B0 05               MV [Y],A          ; Speaker = 0 (silence)
  $BF1AA: CC 03 00            MV (03H),$00H     ; Clear voice-active flag
  $BF1AD: 13 0D               JR -13            ; -> $BF1A2H

  ; 'O' command: explicit octave setting O1-O5
  $BF1AF: 6C 04               INC X
  $BF1B1: 90 04               MV A,[X]
  $BF1B3: 48 30               SUB A,$30H        ; ASCII -> numeric value
  $BF1B5: 60 05               CMP A,$05H
  $BF1B7: 1F 53               JRNC -83          ; -> $BF166H (invalid value)
  $BF1B9: A0 0A               MV (0AH),A        ; Store octave value
  $BF1BB: 6C 04               INC X
  $BF1BD: 13 59               JR -89            ; -> $BF166H

  ; '<' : octave down
  $BF1BF: 6D 0A               INC (0AH)         ; NOTE: uses INC for octave-down? needs confirmation
  $BF1C1: 6C 04               INC X
  $BF1C3: 13 5F               JR -95            ; -> $BF166H

  ; '>' : octave up
  $BF1C5: 7D 0A               DEC (0AH)
  $BF1C7: 6C 04               INC X
  $BF1C9: 13 65               JR -101           ; -> $BF166H

  ; '+' : sharp
  $BF1CB: 30                  PRE $30
  $BF1CC: CC 15 01            MV (PITCH3),$01H  ; Sharp/flat flag = +1
  $BF1CF: 6C 04               INC X
  $BF1D1: 13 6D               JR -109           ; -> $BF166H

  ; '-' : flat
  $BF1D3: 30                  PRE $30
  $BF1D4: CC 15 FF            MV (PITCH3),$FFH  ; Sharp/flat flag = -1
  $BF1D7: 6C 04               INC X
  $BF1D9: 13 75               JR -117           ; -> $BF166H

  ; 'T' : tempo setting T1-T3
  $BF1DB: 6C 04               INC X
  $BF1DD: 90 04               MV A,[X]
  $BF1DF: 48 31               SUB A,$31H        ; ASCII '1' -> 0
  $BF1E1: 1D 7D               JRC -125          ; -> $BF166H (invalid)
  $BF1E3: 60 02               CMP A,$02H
  $BF1E5: 1F 81               JRNC -129         ; -> $BF166H
  $BF1E7: 68 FF               XOR A,$FFH        ; Invert (0->FF, 1->FE, 2->FD)
  $BF1E9: 6C 00               INC A             ; +1
  $BF1EB: 40 02               ADD A,$02H        ; +2 -> T1=3, T2=2, T3=1
  $BF1ED: 30                  PRE $30
  $BF1EE: A0 16               MV (NPART),A      ; NOTE: stored into NPART, not TEMPO? needs confirmation
  $BF1F0: 6C 04               INC X
  $BF1F2: 13 8E               JR -142           ; -> $BF166H

; ----- Pitch / duration calculation PITCH_CALC ($BF1F4-$BF26B) -----

PITCH_CALC:  ; $BF1F4
; Search note letter (A-G) in table Y and return pitch value
; Input : A = MML character, X = MML pointer, Y = pitch table
; Output: A = note length, C=0: success, C=1: not found
  $BF1F4: 09 08               MV IL,$08H        ; Search 8 note entries

SEARCH_LOOP:  ; $BF1F6
  $BF1F6: 90 04               MV A,[X]          ; MML character
  $BF1F8: 30                  PRE $30
  $BF1F9: E0 05 13            MV (PITCH1),[Y]   ; Read note name from table
  $BF1FC: 6C 05               INC Y
  $BF1FE: 30                  PRE $30
  $BF1FF: 63 13               CMP (PITCH1),A    ; Match?
  $BF201: 18 12               JRZ +18           ; -> $BF215H (found)
  $BF203: 6C 05               INC Y             ; Skip ahead by one table entry
  $BF205: 6C 05               INC Y
  $BF207: 6C 05               INC Y
  $BF209: 6C 05               INC Y
  $BF20B: 6C 05               INC Y
  $BF20D: 7C 01               DEC IL
  $BF20F: 1B 19               JRNZ -25          ; -> $BF1F8H
  $BF211: 97                  SC                ; C=1 (not found)
  $BF212: 6C 04               INC X
  $BF214: 06                  RET

  ; Note found: apply octave and sharp/flat adjustment
  $BF215: 80 0A               MV A,(0AH)        ; Octave value
  $BF217: 30                  PRE $30
  $BF218: 42 15               ADD A,(PITCH3)    ; + sharp/flat offset
  $BF21A: 60 05               CMP A,$05H        ; Maximum octave?
  $BF21C: 1C 02               JRC +2            ; -> $BF220H
  $BF21E: 08 04               MV A,$04H         ; Clamp upper bound
  $BF220: 45 50               ADD Y,A           ; Table offset += octave
  $BF222: 30                  PRE $30
  $BF223: E0 05 13            MV (PITCH1),[Y]   ; Load pitch value into PITCH1
  $BF226: 22                  PRE $22
  $BF227: C8 01 13            MV (01H),(PITCH1) ; Save pitch value

  ; Parse note length (digit or omitted/default)
  $BF22A: 6C 04               INC X             ; Next character
  $BF22C: 90 04               MV A,[X]
  $BF22E: 60 55               CMP A,$55H        ; 'U' (dotted note?)
  $BF230: 1A 04               JRNZ +4           ; -> $BF236H
  $BF232: 08 0A               MV A,$0AH         ; Dotted = 10
  $BF234: 12 0C               JR +12            ; -> $BF242H
  $BF236: 48 30               SUB A,$30H        ; ASCII -> numeric value
  $BF238: 1C 04               JRC +4            ; -> $BF23EH (not a digit)
  $BF23A: 60 0A               CMP A,$0AH
  $BF23C: 1C 04               JRC +4            ; -> $BF242H (valid digit)
  $BF23E: 80 02               MV A,(02H)        ; Use default note length
  $BF240: 12 02               JR +2             ; -> $BF244H
  $BF242: 6C 04               INC X             ; Consume digit
  $BF244: A0 02               MV (02H),A        ; Save note length

  ; Look up actual duration from note-length table
  $BF246: 0D 2A F3 0B         MV Y,$BF32AH      ; Duration table
  $BF24A: 45 50               ADD Y,A           ; Y += duration index
  $BF24C: 30                  PRE $30
  $BF24D: E0 05 13            MV (PITCH1),[Y]   ; Read duration value from table

  ; Compute total duration across all active voices
  $BF250: 30                  PRE $30
  $BF251: 81 16               MV IL,(NPART)     ; Loop NPART times
  $BF253: 08 00               MV A,$00H

DURLEN_SUM:  ; $BF255
  $BF255: 30                  PRE $30
  $BF256: 42 13               ADD A,(PITCH1)
  $BF258: 7C 01               DEC IL
  $BF25A: 1B 07               JRNZ -7           ; -> $BF255H
  $BF25C: 60 00               CMP A,$00H
  $BF25E: 06                  RET               ; If Z=1, this is silence/rest

  ; Speaker output
  $BF25F: 85 07               MV Y,(07H)        ; Speaker pointer / port pointer
  $BF261: 80 01               MV A,(01H)        ; Pitch value
  $BF263: 60 00               CMP A,$00H
  $BF265: 18 02               JRZ +2            ; -> $BF269H (rest)
  $BF267: 08 10               MV A,$10H         ; Speaker ON value
  $BF269: B0 05               MV [Y],A          ; Output to speaker
  $BF26B: 06                  RET

; ----- Program exit EXIT ($BF26C-$BF271) ---------------------

EXIT:  ; $BF26C
  $BF26C: 30                  PRE $30
  $BF26D: C8 FB 00            MV (IMR),(00H)    ; Restore IMR from work area
  $BF270: 3F                  POPU IMR          ; Restore IMR from stack
  $BF271: 07                  RETF              ; Return to BASIC

; ----- Voice routing VOICE_ROUTE ($BF272-$BF28F) -------------
; Write each voice's VREG value into SOUND_GEN instruction immediates
; (self-modifying code)

VOICE_ROUTE:  ; $BF272
  ; Voice 3: write iRAM[VREG3] into $BF29D (immediate byte of MV instruction)
  $BF272: 30                  PRE $30
  $BF273: D8 9D F2 0B 33      MV [$BF29DH],(VREG3)   ; Self-modifying write
  $BF278: 32                  PRE $32
  $BF279: C8 13 33            MV (PITCH1),(VREG3)    ; PITCH1 = copy of VREG3

  ; Voice 2: write iRAM[VREG2] into $BF2AD
  $BF27C: 30                  PRE $30
  $BF27D: D8 AD F2 0B 28      MV [$BF2ADH],(VREG2)   ; Self-modifying write
  $BF282: 32                  PRE $32
  $BF283: C8 15 28            MV (PITCH3),(VREG2)    ; PITCH3 = copy of VREG2

  ; Voice 1: write iRAM[VREG1] into $BF2BD
  $BF286: 30                  PRE $30
  $BF287: D8 BD F2 0B 1D      MV [$BF2BDH],(VREG1)   ; Self-modifying write
  $BF28C: 32                  PRE $32
  $BF28D: C8 14 1D            MV (PITCH2),(VREG1)    ; PITCH2 = copy of VREG1

; ----- Sound generation loop SOUND_GEN ($BF290-$BF2C9) -------
; Three-voice pitch countdown and speaker bit control
; X = loop count (LFLAG value)

SOUND_GEN:  ; $BF290
  $BF290: 08 EF               MV A,$EFH         ; A = 11101111b (bit 4 clear mask)
  $BF292: 30                  PRE $30
  $BF293: 84 18               MV X,(LFLAG)      ; Set loop count into X

SG_LOOP:  ; $BF295  <- target of JRNZ -52
  ; ---- Voice 3 (PITCH1 / VREG3) ----
  $BF295: 30                  PRE $30
  $BF296: 7D 13               DEC (PITCH1)      ; Countdown
  $BF298: 1A 08               JRNZ +8           ; -> $BF2A2H (not yet zero)
  ; Reached zero: emit pulse
  $BF29A: 30                  PRE $30
  $BF29B: CC 13 ??            MV (PITCH1),<VREG3>    ; Reinitialize counter <- D8 rewrites ??
  $BF29E: 30                  PRE $30
  $BF29F: 79 FD 10            OR (SPK),$10H     ; bit 4 ON
  $BF2A2: 30                  PRE $30
  $BF2A3: 73 FD               AND (SPK),A       ; bit 4 OFF (A=$EF)

  ; ---- Voice 2 (PITCH3 / VREG2) ----
  $BF2A5: 30                  PRE $30
  $BF2A6: 7D 15               DEC (PITCH3)
  $BF2A8: 1A 08               JRNZ +8           ; -> $BF2B2H
  $BF2AA: 30                  PRE $30
  $BF2AB: CC 15 ??            MV (PITCH3),<VREG2>    ; <- D8 rewrites this byte
  $BF2AE: 30                  PRE $30
  $BF2AF: 79 FD 10            OR (SPK),$10H
  $BF2B2: 30                  PRE $30
  $BF2B3: 73 FD               AND (SPK),A

  ; ---- Voice 1 (PITCH2 / VREG1) ----
  $BF2B5: 30                  PRE $30
  $BF2B6: 7D 14               DEC (PITCH2)
  $BF2B8: 1A 08               JRNZ +8           ; -> $BF2C2H
  $BF2BA: 30                  PRE $30
  $BF2BB: CC 14 ??            MV (PITCH2),<VREG1>    ; <- D8 rewrites this byte
  $BF2BE: 30                  PRE $30
  $BF2BF: 79 FD 10            OR (SPK),$10H
  $BF2C2: 30                  PRE $30
  $BF2C3: 73 FD               AND (SPK),A

  ; Loop counter
  $BF2C5: 7C 04               DEC X             ; Countdown X
  $BF2C7: 1B 34               JRNZ -52          ; -> $BF295H (SG_LOOP)
  $BF2C9: 06                  RET

; =============================================================
; Data tables ($BF2CA-$BF337)
; =============================================================

PITCH_TABLE:  ; $BF2CA  Normal pitch table (7 notes x 5 octaves)
; Each entry: [note ASCII][oct0][oct1][oct2][oct3][oct4]
; Order = C, D, E, F, G, A, B; values = countdown periods
  $BF2CA: 43 ...              ; 'C'
  $BF2CF: 44 ...              ; 'D'
  ; ... (8 entries x 6 bytes = 48 bytes)
  ; $BF2CA-$BF2F9

  ; $BF2FA-  Sharp pitch table (C#, D#, F#, G#, A#)
  ; ...

DURLEN_TABLE:  ; $BF32A  Note-length table
; Length values corresponding to index 0-10
  $BF32A: ...                 ; 11 bytes

; =============================================================
; Self-modifying code notes:
;
; Before VOICE_ROUTE:
;   $BF29B: CC 13 00  -> MV (PITCH1),$00H  (silent)
;   $BF2AB: CC 15 00  -> MV (PITCH3),$00H
;   $BF2BB: CC 14 00  -> MV (PITCH2),$00H
;
; After VOICE_ROUTE (example: VREG3 = A4 pitch value, say $28):
;   $BF29B: CC 13 28  -> MV (PITCH1),$28H  (countdown at A4 period)
;   $BF2AB: CC 15 ??  -> MV (PITCH3),<VREG2 value>
;   $BF2BB: CC 14 ??  -> MV (PITCH2),<VREG1 value>
;
; Effect:
;   The speaker bit is toggled at a frequency determined by each voice pitch
;   value, producing time-sliced three-part playback on a single buzzer.
; =============================================================
