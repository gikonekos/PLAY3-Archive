; ============================================================
; PLAY3 - SHARP PC-E500 3-voice buzzer music driver
; Published in Pocket Computer Journal 1993  Author: Ryu
; English-commented source (based on play3_pushu.asm)
; ============================================================

	pre_on				; Assembler pre-processing directive


; --- System entry points ---
fcs:		equ	0fffe4h		; File Control System entry
iocs:		equ	0fffe8h		; I/O Control System entry

; --- Interrupt vector addresses ---
vect0:		equ	0bfcc6h		; Interrupt vector 0
vect1:		equ	0bfcc9h		; Interrupt vector 1
vect2:		equ	0bfccch		; Interrupt vector 2
vect3:		equ	0bfccfh		; Interrupt vector 3
vect4:		equ	0bfcd2h		; Interrupt vector 4
vect5:		equ	0bfcd5h		; Interrupt vector 5
vect6:		equ	0bfcd8h		; Interrupt vector 6
vect7:		equ	0bfcdbh		; Interrupt vector 7

; --- Internal RAM register alias definitions ---
bx:		equ	0d4h		; BX register address
bh:		equ	0d5h		; BH register address
cx:		equ	0d6h		; CX register address
ch:		equ	0d7h		; CH register address
dx:		equ	0d8h		; DX register address
dh:		equ	0d9h		; DH register address
si:		equ	0dah		; SI register address
di:		equ	0ddh		; DI register address

; --- Pointer registers ---
abp:		equ	0ech		; ABP pointer
apx:		equ	0edh		; APX pointer
apy:		equ	0eeh		; APY pointer

; --- Interrupt control registers ---
iisr:		equ	0ebh		; Interrupt service register
imr:		equ	0fbh		; Interrupt mask register
isr:		equ	0fch		; Interrupt status register

; --- Hardware registers / BASIC workspace ---
beep:		equ	0fdh		; Buzzer control register
basic_work:	equ	0d1h		; BASIC workspace base address
cr:		equ	00dh		; Carriage return character code

; --- Part data structure offset definitions ---
part_c:		equ	0		; Part counter (zero-page work area)
data_adr:	equ	0		; Current data address offset
data_s_adr:	equ	data_adr+3	; Start data address offset
oct:		equ	data_s_adr+3	; Octave value offset
onp:		equ	oct+1		; Note code offset
l_count:	equ	onp+1		; Length counter offset
o_count:	equ	l_count+1	; Pitch counter offset



; --- MML parser internal RAM constants ---
oct_flg:	equ	13h		; Temporary octave change flag address
octerve_adr:	equ	30h		; Octave data pointer storage address
length_adr:	equ	33h		; Note length data pointer storage address

e_flg:		equ	18h		; End flag address

	org	0bf000h			; Load address: 0BF000h



; ============================================================
; install / remove - BASIC command registration and removal
; ============================================================
install:	local			; Begin local scope
	mv	x,basic_command		; Command table start address -> X
	mv	[(!basic_work)+90h],x	; Register in BASIC command table pointer
	mv	x,basic_code		; Command code table address -> X
	mv	[(!basic_work)+93h],x	; Register in BASIC code table pointer
	retf				; Far return
remove:		mv	x,0fffffh	; Invalid address (for command removal)
	mv	[(!basic_work)+90h],x	; Clear command table pointer
	mv	[(!basic_work)+93h],x	; Clear code table pointer
	callf	!init1			; Initialize playback state
	retf				; Far return



; ============================================================
; BASIC command table definition
; Registers PLAY command and EXOFF command
; ============================================================
basic_command:	db	04h		; Number of command characters (4)
	dm	'PLAY'			; Command name string
	db	1fh			; Intermediate code
	db	5			; Next command character count (5)
	dm	'EXOFF'			; Command name string
	db	2			; Code length
	db	0,0			; Terminator
basic_code:	db	1fh		; Code flag
	dw	!entry			; PLAY command handler address
	db	8bh			; Attribute byte (bit6=1, bit7=1)
	db	2			; Code length
	dw	remove			; EXOFF command handler address
	db	8bh			; Attribute byte
	db	0,0			; Terminator
	endl				; End local scope



; ============================================================
; entry - PLAY command entry point
; Disables interrupts, runs MML parsing/playback, then restores state
; ============================================================
entry:		local			; Begin local scope
	pushu imr			; Save interrupt mask register onto stack
	mv	(!imr),0a0h		; Set interrupt mask (disable all but timer)
	mv	[--u],(!abp)		; Save ABP pointer onto stack
	call	mml_conv		; Call MML string parsing routine

	pushu	x			; Save X register
	callf	!init2			; Call playback init and main loop
	popu	x			; Restore X register
	mv	(!abp),[u++]		; Restore ABP pointer
	popu imr			; Restore interrupt mask register

	retf				; Far return (back to BASIC)



; ============================================================
; mml_conv - MML string parsing routine
; X: MML string pointer
; Parses the MML string and builds playback data buffers for each part
; ============================================================
mml_conv:	mv	y,octerve	; Default octave data address -> Y
	mv	(!octerve_adr),y	; Store octave pointer in internal RAM
	mv	y,length		; Default note length data address -> Y
	mv	(!length_adr),y		; Store length pointer in internal RAM

	mv	y,!part1+!data_s_adr	; Part 1 data start address -> Y
	mv	[MML_data_adr],y	; Save MML data write address
	mv	y,not_data		; Terminator data address -> Y
	mv	[!part3+!data_s_adr],y	; Initialize part 3 data address to terminator
	mv	[!part2+!data_s_adr],y	; Initialize part 2 data address to terminator
	mv	y,!data_buff		; Data buffer address -> Y
	mv	[!part1+!data_s_adr],y	; Set part 1 data write destination



	mv	(!oct_flg),0ffh		; Set octave flag to initial value (unused)
	mv	a,[x++]			; Read first MML character and advance X
	cmp	a,!cr			; CR (string terminator)?
	jrz	mml_conv_exit_c		; If CR, go to exit processing
	cmp	a,'"'			; Double quote '"'?
	jrz	mml_conv_lp		; If quote, skip it and go to loop
	dec	x			; Not a quote, back X up by 1

mml_conv_lp:
	; --- Main parsing loop ---
	cmp	a,!cr			; CR?
	jrz	mml_conv_exit_c		; If CR, go to exit processing
	cmp	a,':'			; ':' ? (part separator)
	jrz	part_ch			; Go to part change processing
	cmp	a,'>'			; '>' ? (octave up)
	jpz	oct_up			; Go to octave +1 processing
	cmp	a,'<'			; '<' ? (octave down)
	jpz	oct_dw			; Go to octave -1 processing
	cmp	a,'O'			; 'O' ? (octave specification)
	jpz	oct_ch			; Go to octave change processing
	cmp	a,'T'			; 'T' ? (tempo specification)
	jrz	temp2_ch		; Go to tempo change processing
	cmp	a,'L'			; 'L' ? (default length specification)
	jrz	len_ch			; Go to note length change processing
	cmp	a,'R'			; 'R' ? (rest)
	jrz	kyuufu			; Go to rest processing
	cmp	a,'+'			; '+' ? (semitone up)
	jpz	oct_1up			; Go to temporary octave +1
	cmp	a,'-'			; '-' ? (semitone down)
	jpz	oct_1dw			; Go to temporary octave -1
	cmp	a,'I'			; 'I' ? (format specification)
	jrz	format_ch		; Go to format change processing



; --- Note data setup ---
; A: note name character (A-G or #A-#G)
onp_set:	pushu	y		; Save Y register
	mv	y,mml_data1		; Standard note table start address -> Y
	cmp	a,'#'			; Sharp '#'?
	jrz	onp_skip		; If sharp, go to onp_skip (Y unchanged)
	mv	y,mml_data2		; Sharp note table start address -> Y
	mv	a,[x++]			; Read next character (note name)
onp_skip:	sub	a,'A'		; Calculate relative index from 'A'
	cmp	a,7			; In range 0-6 (A-G)?
	jrnc	onp_skip2		; Out of range, skip note processing
	add	y,a			; Add note name offset to table address
	mv	a,[y]			; Fetch note code
	mv	il,a			; Set note code in IL register
	popu	y			; Restore Y register
onp_len:	mv	a,[x++]		; Read next character (length digit)
	sub	a,'0'			; Convert ASCII digit to binary
	cmp	a,10			; In range 0-9?
	jrc	onp_len_sk2		; If digit, go to length setup
	sub	a,'U'-'0'		; Convert extended character code
	cmp	a,6			; Range check
	jrnc	onp_len_sk		; Out of range, use default length
	add	a,10			; Convert to extended length value (10-15)
	jr	onp_len_sk2		; Go to length setup
onp_len_sk:	mv	a,(!length_adr)	; Default length pointer -> A
	dec	x			; Back X up by 1 (no explicit length)
onp_len_sk2:	pushu	a		; Save A (length value) onto stack
	mv	a,[format_data]		; Read format flag
	cmp	a,0			; Format = 0?
	popu	a			; Restore A
	jrz	onp_len_sk3		; If format=0, do not update default length
	mv	(!length_adr),a		; Update default note length
onp_len_sk3:	add	a,il		; Combine length + note code
	mv	[y++],a			; Write to data buffer and advance Y
	cmp	(!oct_flg),010h		; Octave flag already set (>=10h)?
	jp	mml_conv_lp		; If set, go to main loop
	mv	a,(!oct_flg)		; Fetch temporary octave flag value
	mv	(!oct_flg),0ffh		; Reset flag
	jr	oct_ch_s		; Go to octave setting processing
onp_skip2:	popu	y		; Restore Y register
	jr	mml_conv_lp		; Return to main loop



; --- Rest processing ---
kyuufu:		mv	il,0		; Note code = 0 (rest)
	jr	onp_len			; Go to length processing



; --- MML parsing termination ---
mml_conv_exit_c:dec	x		; Back X up by 1 (return to CR position)
mml_conv_exit:	mv	a,0ffh		; End marker 0FFh
	mv	[y++],a			; Write end marker to data buffer
	ret				; Return



; --- Default note length change ('L' command) ---
len_ch:		mv	a,[x]		; Read character at current position
	sub	a,'0'			; ASCII to binary conversion
	cmp	a,0ah			; In range 0-9?
	jrc	len_sk			; If digit, go to length setting
	sub	a,'U'			; Extended character conversion
	cmp	a,6			; Range check
	jp	mml_conv_lp		; Out of range, skip
	add	a,10			; Extended value conversion
len_sk:		mv	(!length_adr),a	; Update default note length
	inc	x			; Advance X to next character
	jr	mml_conv_lp		; Return to main loop

; --- Format specification processing ('I' command) ---
format_ch:	mv	a,[x]		; Read character at current position
	sub	a,'0'			; ASCII to binary conversion
	jrc	format_sk		; Not a digit, skip
	mv	[format_data],a		; Update format flag
format_sk:	inc	x		; Advance X to next character
	jr	mml_conv_lp		; Return to main loop



; --- Part change processing (':' command) ---
; Terminates current part data and sets the write address for the next part
part_ch:	pushu	x		; Save X register
	mv	a,0ffh			; End marker
	mv	[y++],a			; Terminate current part data buffer
	mv	x,[MML_data_adr]	; Fetch MML data address table pointer
	mv	ba,16			; Next part struct offset = 16
	add	x,ba			; Advance to next part structure address
	mv	[MML_data_adr],x	; Update MML data address pointer
	mv	[x],y			; Store data write destination in next part struct
	mv	x,(!octerve_adr)	; Fetch octave pointer
	inc	x			; Advance to next part octave storage address
	inc	x
	mv	(!octerve_adr),x	; Update octave pointer
	mv	x,(!length_adr)		; Fetch length pointer
	inc	x			; Advance to next part length storage address
	inc	x
	mv	(!length_adr),x		; Update length pointer
	popu	x			; Restore X register
	jr	mml_conv_lp		; Return to main loop



; --- Tempo setting processing (direct value, inside mml_conv) ---
temp_ch:	mv	a,[x]		; Read character at current position
	sub	a,30h			; ASCII to binary conversion
	cmp	a,0ah			; In range 0-9?
	jp	mml_conv_lp		; Out of range, skip
	add	a,0d0h			; Convert to tempo internal code
	mv	[y++],a			; Write tempo code to data buffer
	inc	x			; Advance X to next character
	jr	mml_conv_lp		; Return to main loop

; --- Tempo setting processing ('T' command, multi-digit value) ---
temp2_ch:	mv	il,0		; Clear tempo accumulator
	mv	a,0dfh			; Tempo control code 0DFh
	mv	[y++],a			; Write code to data buffer
temp2_lp1:	mv	a,[x]		; Read character at current position
	sub	a,30h			; ASCII to binary conversion
	cmp	a,10			; In range 0-9?
	jrnc	temp2_sk1		; Not a digit, end loop
	pushu	a			; Save digit value
	mv	a,il			; Current accumulator -> A
	add	a,a			; A * 2
	add	a,a			; A * 4
	add	il,a			; IL = IL + A*4 (= IL*5)
	add	il,il			; IL = IL * 2 (= IL*10)
	popu	a			; Restore digit value
	add	il,a			; IL = IL * 10 + digit
	inc	x			; Advance X to next character
	jr	temp2_lp1		; Process next digit
temp2_sk1:	mv	[y++],il	; Write final tempo value to data buffer
	jp	mml_conv_lp		; Return to main loop



; --- Octave change processing ('O' command) ---
oct_ch:		mv	a,[x++]		; Read octave digit and advance X
	sub	a,30h			; ASCII to binary conversion
oct_ch_s:	cmp	a,10		; In range 0-9?
	jp	mml_conv_lp		; Out of range, skip
	mv	(!octerve_adr),a	; Update octave value
	add	a,0e0h			; Convert to octave control code (0E0h-0E9h)
	mv	[y++],a			; Write octave code to data buffer
	jp	mml_conv_lp		; Return to main loop

; --- Temporary octave +1 ('+' command) ---
oct_1up:	mv	(!oct_flg),(!octerve_adr) ; Save current octave to flag

oct_up:		mv	a,(!octerve_adr); Fetch current octave value
	inc	a			; Octave + 1
	jr	oct_ch_s		; Go to octave setting processing

; --- Temporary octave -1 ('-' command) ---
oct_1dw:	mv	(!oct_flg),(!octerve_adr) ; Save current octave to flag

oct_dw:		mv	a,(!octerve_adr); Fetch current octave value
	dec	a			; Octave - 1
	jr	oct_ch_s		; Go to octave setting processing



; ============================================================
; Note code table
; mml_data1: Standard notes (C D E F G A B and rest)
; mml_data2: Sharp notes (#C #D #F #G #A)
; ============================================================
mml_data1:	db	0a0h		; A
	db	0c0h		; B
	db	010h		; C
	db	030h		; D
	db	050h		; E
	db	060h		; F
	db	080h		; G
mml_data2:	db	0b0h		; #A
	db	010h		; #B -> equivalent to C
	db	020h		; #C
	db	040h		; #D
	db	050h		; #E -> equivalent to F
	db	070h		; #F
	db	090h		; #G

; --- Terminator data / default initial values ---
not_data:	db	0ffh		; End marker (when part is unused)
octerve:	db	3		; Default octave value (part 1)
length:		db	5		; Default note length value (part 1)
octerve2:	db	3		; Default octave value (part 2)
length2:	db	5		; Default note length value (part 2)
octerve3:	db	3		; Default octave value (part 3)
length3:	db	5		; Default note length value (part 3)
MML_data_adr:	ds		3	; MML data write address pointer (3 bytes)
format_data:	db	1		; Format flag (1 = update default length)
	endl				; End local scope



; ============================================================
; init1 - Reset part playback state (counter reset)
; ============================================================
	jr	init2			; Jump to init2 (skip past init1 entry)
init1:		mv	y,0		; Y = 0
	mv	[part1+o_count],y	; Clear part 1 pitch counter
	mv	[part2+o_count],y	; Clear part 2 pitch counter
	mv	[part3+o_count],y	; Clear part 3 pitch counter
	mv	a,2			; Initial octave value = 2
	mv	[part1+oct],a		; Initialize part 1 octave
	mv	[part2+oct],a		; Initialize part 2 octave
	mv	[part3+oct],a		; Initialize part 3 octave
	retf				; Far return



; ============================================================
; init2 - Initialize playback data pointers
; Resets each part's data address to the start, then enters the play loop
; ============================================================
init2:		mv	i,0		; I = 0 (clear note code)
	mv	[part1+onp],i		; Clear part 1 note code
	mv	[part2+onp],i		; Clear part 2 note code
	mv	[part3+onp],i		; Clear part 3 note code
	mv	y,[part1+data_s_adr]	; Fetch part 1 data start address
	mv	[part1+data_adr],y	; Set part 1 current data address to start
	mv	y,[part2+data_s_adr]	; Fetch part 2 data start address
	mv	[part2+data_adr],y	; Set part 2 current data address to start
	mv	y,[part3+data_s_adr]	; Fetch part 3 data start address
	mv	[part3+data_adr],y	; Set part 3 current data address to start



; ============================================================
; main2 - Main playback loop
; Reads MML data for each part, determines note/length, and
; passes control to the buzzer output routine
; ============================================================
main2:		mv	x,part1		; Part 1 parameter address -> X
	call	mml			; Process part 1 MML data
	mv	x,part2			; Part 2 parameter address -> X
	call	mml			; Process part 2 MML data
	mv	x,part3			; Part 3 parameter address -> X
	call	mml			; Process part 3 MML data

	; --- Find minimum note length across 3 parts ---
	mv	a,0			; A = 0 (minimum length candidate)
	mv	b,a			; B = 0
	mv	a,[part1+l_count]	; Fetch part 1 remaining length counter
	mv	(part_c),[part2+l_count]; Fetch part 2 remaining length counter
	cmp	(part_c),0		; Part 2 = 0 (finished)?
	jrz	main2_skip1		; If 0, skip comparison
	cmp	(part_c),a		; Part 2 < part 1?
	jrnc	main2_skip1		; If part 2 >= part 1, skip
	mv	a,(part_c)		; Part 2 value is smaller -> adopt in A
main2_skip1:	mv	(part_c),[part3+l_count]; Fetch part 3 remaining length counter
	cmp	(part_c),0		; Part 3 = 0 (finished)?
	jrz	main2_skip2		; If 0, skip comparison
	cmp	(part_c),a		; Part 3 < current minimum?
	jrnc	main2_skip2		; If part 3 >= current minimum, skip
	mv	a,(part_c)		; Part 3 value is smaller -> adopt in A
main2_skip2:	cmp	a,0		; Minimum length = 0? (all parts finished)
	jrz	exit			; If 0, end playback
	mv	il,a			; Set minimum length in IL

	; --- Subtract minimum value from each part's remaining length ---
	mv	a,[part1+l_count]	; Fetch part 1 remaining length
	sub	a,il			; Subtract minimum length
	mv	[part1+l_count],a	; Update part 1 remaining length
	mv	a,[part2+l_count]	; Fetch part 2 remaining length
	sub	a,il			; Subtract minimum length
	mv	[part2+l_count],a	; Update part 2 remaining length
	mv	a,[part3+l_count]	; Fetch part 3 remaining length
	sub	a,il			; Subtract minimum length
	mv	[part3+l_count],a	; Update part 3 remaining length

	; --- Calculate buzzer output counter ---
	add	i,i			; Shift I left (prepare for bit operations)
	mv	a,[temp]		; Fetch tempo value
	mv	x,0			; X = 0 (accumulation counter)
main2_lp1:	add	i,i		; Shift I left with carry
	rc				; If no carry, continue to next bit
	shr	a			; Shift tempo bit right
	jrnc	main2_skip		; If tempo bit = 0, skip
	add	x,i			; If tempo bit = 1, add I to X
main2_skip:	cmp	a,0		; Tempo value processing complete?
	jrz	main2_lp1		; If not, process next bit
	mv	[count],x		; Save calculated counter value

	; --- Select buzzer output routine based on number of active parts ---
	mv	(part_c),0		; Clear active part counter
	mv	y,count1		; Pitch counter storage -> Y
	mv	a,[part1+onp]		; Fetch part 1 note code
	inc	a			; Increment for 0FFh check (+1 makes it 0)
	jrz	p1_skip			; 0FFh (terminator/invalid), skip
	dec	a			; Restore value
	jrz	p1_skip			; 0 (rest/silent), skip
	mv	ba,[part1+o_count]	; Fetch part 1 pitch counter
	mv	[y++],ba		; Store pitch counter in count1, advance Y
	inc	(part_c)		; Active part count + 1
p1_skip:	mv	a,[part2+onp]	; Fetch part 2 note code
	inc	a			; Increment for 0FFh check
	jrz	p2_skip			; 0FFh, skip
	dec	a			; Restore value
	jrz	p2_skip			; 0, skip
	mv	ba,[part2+o_count]	; Fetch part 2 pitch counter
	mv	[y++],ba		; Store pitch counter in count2, advance Y
	inc	(part_c)		; Active part count + 1
p2_skip:	mv	a,[part3+onp]	; Fetch part 3 note code
	inc	a			; Increment for 0FFh check
	jrz	p3_skip			; 0FFh, skip
	dec	a			; Restore value
	jrz	p3_skip			; 0, skip
	mv	ba,[part3+o_count]	; Fetch part 3 pitch counter
	mv	[y++],ba		; Store pitch counter in count3, advance Y
	inc	(part_c)		; Active part count + 1
p3_skip:	mv	x,[count]	; Fetch sound duration counter
	mv	ba,[count1]		; Fetch count1 (part 1 pitch counter)
	mv	i,ba			; I = count1 (candidate initial value for part 2)
	mv	y,i			; Y = I (candidate initial value for part 3)



	; --- Patch immediate values in beep_out3 with pitch counter values ---
	mv	[!beep_out3!part1_co1+1],ba	; Set part 1 pitch reload value
	mv	[!beep_out3!part2_co2+1],i	; Set part 2 pitch reload value (2)
	mv	[!beep_out3!part2_co1+1],i	; Set part 2 pitch reload value (1)
	mv	[!beep_out3!part3_co1+1],y	; Set part 3 pitch reload value (1)
	mv	[!beep_out3!part3_co2+1],y	; Set part 3 pitch reload value (2)
	mv	[!beep_out3!part3_co3+1],y	; Set part 3 pitch reload value (3)
	mv	[!beep_out3!part3_co4+1],y	; Set part 3 pitch reload value (4)
	dec	(part_c)		; Active part count - 1
	jpz	beep_out3		; If >= 0 (1+ parts), go to beep_out3
	mv	i,[count2]		; Fetch count2 (actual pitch counter for part 2)



	; --- 2+ parts active: update part 2 pitch counter ---
	mv	[!beep_out3!part2_co2+1],i	; Re-set part 2 pitch reload value (2)
	mv	[!beep_out3!part2_co1+1],i	; Re-set part 2 pitch reload value (1)
	dec	i			; I -= 1 (timing adjustment)
	dec	i			; I -= 1
	dec	i			; I -= 1
	dec	(part_c)		; Active part count - 1
	jpz	beep_out3		; If remaining >= 0, go to beep_out3
	mv	ba,[count3]		; Fetch count3 (actual pitch counter for part 3)



	; --- 3 parts active: update part 1 pitch counter ---
	mv	[!beep_out3!part1_co1+1],ba	; Re-set part 1 pitch reload value
	dec	ba			; BA -= 1 (timing adjustment)
	dec	ba			; BA -= 1
	dec	ba			; BA -= 1
	dec	(part_c)		; Active part count - 1
	jpz	beep_out3		; Go to beep_out3



	; --- 0 parts (all rests or all finished): go to silent output ---
	jr	beep_out0		; Go to silent buzzer output routine

exit:		retf			; Playback complete, far return (back to BASIC)



; ============================================================
; mml - MML data read routine
; X: part parameter address
; Return: CY=1 data end, CY=0 I=pitch counter
; ============================================================
mml:		pushu	y		; Save Y register
	mv	a,[x+onp]		; Read part note code
	cmp	a,0ffh			; 0FFh (data terminator)?
	jrz	mml_exit		; If terminator, go to exit processing
	mv	a,[x+l_count]		; Read length counter
	cmp	a,0			; Length counter = 0?
	jrnz	skip_exit		; If not 0 (still sounding), go to skip_exit
	mv	y,[x]			; Fetch data address pointer
mml_loop:	mv	a,[y++]		; Read data byte and advance Y
	cmp	a,0ffh			; 0FFh (data terminator)?
	jrz	mml_exit		; If terminator, go to exit processing
	cmp	a,0dfh			; 0DFh (tempo code)?
	jrz	temp_ch			; Go to tempo processing
	cmp	a,0e0h			; >= 0E0h? (0E0h-0E9h: octave codes)
	jrc	mml_onp			; If < 0E0h, go to note data processing

	; --- Octave setting code processing (0E0h-0E9h) ---
oct_ch:		and	a,0fh		; Extract lower 4 bits (octave value)
	mv	[x+oct],a		; Update part octave value
	jr	mml_loop		; Return to data read loop

	; --- Tempo setting code processing (0DFh) ---
temp_ch:	mv	a,[y++]		; Read tempo value byte and advance Y
	mv	[temp],a		; Update tempo variable
	jr	mml_loop		; Return to data read loop

	; --- Data terminator processing ---
mml_exit:	mv	[x+onp],a	; Record terminator value (0FFh) as note code
	mv	a,0			; A = 0
	mv	[x+l_count],a		; Clear length counter
	popu	y			; Restore Y register
	sc				; Set carry (indicates data end)
	ret				; Return

	; --- Sustain: return current pitch counter ---
skip_exit:	mv	i,[x+o_count]	; Read pitch counter into I
	popu	y			; Restore Y register
	rc				; Clear carry (indicates sustain)
	ret				; Return

	; --- Note data processing ---
	; Calculates and sets pitch counter and length counter from note code
mml_onp:	mv	[x],y		; Update data address pointer (3 bytes)

	pushu	a			; Save note code
	and	a,0f0h			; Extract upper 4 bits (note name index)
	ror	a			; Rotate right 1st time
	ror	a			; Rotate right 2nd time -> index/4
	mv	il,a			; IL = index/4
	ror	a			; Rotate right 3rd time
	ror	a			; Rotate right 4th time -> index/16
	mv	[x+onp],a		; Store compressed note code in parameter
	add	a,il			; a = index/4 + index/16
	add	a,a			; a = (index/4 + index/16) * 2
	mv	y,mml_data		; Pitch data table start address -> Y
	add	y,a			; Advance to entry for this note name
	mv	a,[x+oct]		; Fetch part octave value
	add	a,a			; Octave * 2 (2 bytes per entry offset)
	add	y,a			; Advance to entry for this octave
	mv	i,[y]			; Read pitch counter value
	mv	[x+o_count],i		; Set pitch counter in parameter

	popu	a			; Restore note code
	and	a,0fh			; Extract lower 4 bits (length index)
	mv	y,length_data		; Note length data table start address -> Y
	add	y,a			; Advance to entry for this length index
	mv	a,[y]			; Read note length value
	mv	[x+l_count],a		; Set length counter in parameter
	popu	y			; Restore Y register
	rc				; Clear carry (note set complete)
	ret				; Return



; ============================================================
; beep_out0 - Silent buzzer output routine
; Generates timing for intervals where no sound is playing
; 1 loop = approx. 78 states (48.1 us)
; X: sound duration counter
; ============================================================
beep_out0:	local			; Begin local scope
loop:		mv	i,4		; Inner loop counter = 4
loop1:		dec	i		; Counter - 1 (6 states)
	jrnz	loop1			; Repeat if not zero (4 or 6 states)
	mv	(!beep),2h		; Buzzer OFF (8 states)
	nop				; 2 states (timing pad)
	nop				; 2 states (timing pad)
	nop				; 2 states (timing pad)
b_ent:		dec	x		; Sound duration counter - 1 (6 states)
	jrnz	loop			; If not zero, continue loop (4 or 6 states)
	jp	!main2			; Return to main playback loop
	endl				; End local scope



; ============================================================
; beep_out3 - 3-voice buzzer output routine
; Manages pitch counters for 3 parts and toggles the buzzer
; to generate pseudo 3-voice chords
; ba: part 1 pitch counter
; i:  part 2 pitch counter
; y:  part 3 pitch counter
; x:  sound duration counter
; ============================================================
beep_out3:	local			; Begin local scope
	; --- Write each part's pitch reload value into immediate fields ---
	mv	[part1_co1+1],ba	; Set part 1 reload value
	mv	[part2_co1+1],i		; Set part 2 reload value (1)
	mv	[part2_co2+1],i		; Set part 2 reload value (2)
	mv	[part3_co1+1],y		; Set part 3 reload value (1)
	mv	[part3_co2+1],y		; Set part 3 reload value (2)
	mv	[part3_co3+1],y		; Set part 3 reload value (3)
	mv	[part3_co4+1],y		; Set part 3 reload value (4)
	; --- Main buzzer loop ---
loop:		dec	ba		; Part 1 counter - 1 (6 states)
	jrnz	skip1			; If not zero, go to skip1 (4 or 6 states)
part1_co1:	mv	ba,0		; Reload part 1 counter (immediate field) (6 states)
	mv	(!beep),2h		; Buzzer OFF (part 1 toggle) (8 states)
	dec	i			; Part 2 counter - 1 (6 states)
	jrnz	skip2			; If not zero, go to skip2 (4 or 6 states)
part2_co1:	mv	i,0		; Reload part 2 counter (immediate field) (6 states)
	dec	y			; Part 3 counter - 1 (6 states)
	jrnz	skip3			; If not zero, go to skip3 (4 or 6 states)
part3_co1:	mv	y,0		; Reload part 3 counter (immediate field) (8 states)
	mv	(!beep),12h		; Buzzer ON (parts 1+3 simultaneous toggle) (8 states)
	dec	x			; Sound duration counter - 1 (6 states)
	jrnz	loop			; If not zero, continue loop (4 or 6 states)
	jr	exit			; Go to exit processing

	; --- Part 3 count reaches zero (part 2 continues) ---
skip3:		nop			; 2 states (timing pad)
	nop				; 2 states (timing pad)
	nop				; 2 states (timing pad)
	mv	(!beep),12h		; Buzzer ON (8 states)
	dec	x			; Sound duration counter - 1 (6 states)
	jrnz	loop			; If not zero, continue loop (4 or 6 states)
	jr	exit			; Go to exit processing

	; --- Part 2 count reaches zero ---
skip2:		nop			; 4 states (timing pad)
	nop				; 2 states (timing pad)
	dec	y			; Part 3 counter - 1 (6 states)
	jrnz	skip3			; If not zero, go to skip3 (4 or 6 states)
part3_co2:	mv	y,0		; Reload part 3 counter (immediate field) (8 states)
	mv	(!beep),12h		; Buzzer ON (parts 2+3 simultaneous toggle) (8 states)
	dec	x			; Sound duration counter - 1 (6 states)
	jrnz	loop			; If not zero, continue loop (4 or 6 states)
	jr	exit			; Go to exit processing

	; --- Part 1 is not zero ---
skip1:		nop			; 2 states (timing pad)
	nop				; 2 states (timing pad)
	mv	(!beep),2h		; Buzzer OFF (part 1 still running) (8 states)
	dec	i			; Part 2 counter - 1 (6 states)
	jrnz	skip12			; If not zero, go to skip12 (4 or 6 states)
part2_co2:	mv	i,0		; Reload part 2 counter (immediate field) (6 states)
	dec	y			; Part 3 counter - 1 (6 states)
	jrnz	skip3			; If not zero, go to skip3 (4 or 6 states)
part3_co3:	mv	y,0		; Reload part 3 counter (immediate field) (8 states)
	mv	(!beep),12h		; Buzzer ON (parts 2+3 toggle) (8 states)
	dec	x			; Sound duration counter - 1 (6 states)
	jrnz	loop			; If not zero, continue loop (4 or 6 states)
	jr	exit			; Go to exit processing

	; --- Part 2 only reaches zero (part 1 running, part 3 running) ---
skip12:		nop			; 2 states (timing pad)
	nop				; 2 states (timing pad)
	dec	y			; Part 3 counter - 1 (6 states)
	jrnz	skip13			; If not zero, go to skip13 (4 or 6 states)
part3_co4:	mv	y,0		; Reload part 3 counter (immediate field) (8 states)
	mv	(!beep),12h		; Buzzer ON (part 3 toggle) (8 states)
	dec	x			; Sound duration counter - 1 (6 states)
	jrnz	loop			; If not zero, continue loop (4 or 6 states)
	jr	exit			; Go to exit processing

	; --- All parts running (parts 1, 2, 3 are all non-zero) ---
skip13:		nop			; 2 states (timing pad)
	nop				; 2 states (timing pad)
	nop				; 2 states (timing pad)
	nop				; 2 states (timing pad)
	nop				; 2 states (timing pad)
	nop				; 2 states (timing pad)

	dec	x			; Sound duration counter - 1 (6 states)
	jrnz	loop			; If not zero, continue loop (4 or 6 states)
exit:		mv	(!beep),2h	; Buzzer OFF (duration end)
	jp	!main2			; Return to main playback loop
	endl				; End local scope



; ============================================================
; mml_data - Pitch counter value table
; Pitch counter values per note name x octave (0-4), 2 bytes/entry
; Notes: R C #C D #D E F #F G #G A #A B (13 notes + rest)
; Octaves: 0 (lowest) - 4 (highest)
; ============================================================
mml_data:	
	dw	000h,000h,000h,000h	; R (rest) octave 0-3
	dw	000h			; R octave 4
	dw	12eh,097h,04ch,026h	; C  octave 0-3
	dw	013h			; C  octave 4
	dw	11dh,08fh,048h,024h	; #C octave 0-3
	dw	012h			; #C octave 4
	dw	10dh,087h,044h,022h	; D  octave 0-3
	dw	011h			; D  octave 4
	dw	0feh,07fh,040h,020h	; #D octave 0-3
	dw	010h			; #D octave 4
	dw	0f0h,078h,03ch,01eh	; E  octave 0-3
	dw	00fh			; E  octave 4
	dw	0e2h,071h,039h,01dh	; F  octave 0-3
	dw	00fh			; F  octave 4
	dw	0d6h,06bh,036h,01bh	; #F octave 0-3
	dw	00eh			; #F octave 4
	dw	0cah,065h,033h,01ah	; G  octave 0-3
	dw	00dh			; G  octave 4
	dw	0beh,05fh,030h,018h	; #G octave 0-3
	dw	00ch			; #G octave 4
	dw	0b4h,05ah,02dh,017h	; A  octave 0-3
	dw	00ch			; A  octave 4
	dw	0aah,055h,02bh,016h	; #A octave 0-3
	dw	00bh			; #A octave 4
	dw	0a0h,050h,028h,014h	; B  octave 0-3
	dw	00ah			; B  octave 4

; ============================================================
; length_data - Note length counter value table
; Note length counter values for indices 0-15
; ============================================================
length_data:	db	003h,006h,009h,00ch,012h ; Length 1/32 1/16 1/12 1/8 1/6
	db	018h,024h,030h,048h	; Length 1/4  1/3  1/2  1/1
	db	060h			; Dotted half note
	db	002h,004h,006h,010h	; Extended lengths
	db	020h,001h		; Extended lengths

; --- Work variable area ---
temp:		db	1		; Tempo value (initial = 1)
count:		dp	0		; Sound duration counter (3-byte pointer)
count1:		db	0,0		; Part 1 pitch counter storage
count2:		db	0,0		; Part 2 pitch counter storage
count3:		db	0,0,0		; Part 3 pitch counter storage

; --- Part parameter area ---
part1:		ds	16		; Part 1 parameter structure (16 bytes)
part2:		ds	16		; Part 2 parameter structure (16 bytes)
part3:		ds	16		; Part 3 parameter structure (16 bytes)

r_flg:		ds	1		; Reserved flag
data_buff:	ds	1		; MML data buffer (1 byte, used for single part)


	end
