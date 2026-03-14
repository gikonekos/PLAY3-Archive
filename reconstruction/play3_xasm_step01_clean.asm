

        pre_on
fcs:    equ  0fffe4h
iocs:   equ  0fffe8h
vect0:  equ  0bfcc6h
vect1:  equ  0bfcc9h
vect2:  equ  0bfccch
vect3:  equ  0bfccfh
vect4:  equ  0bfcd2h
vect5:  equ  0bfcd5h
vect6:  equ  0bfcd8h
vect7:  equ  0bfcdbh
bx:     equ  0d4h
cs:     equ  0d5h
cx:     equ  0d6h
dx:     equ  0d8h
dh:     equ  0d9h
si:     equ  0dah
di:     equ  0ddh
abp:    equ  0ech
apx:    equ  0edh
apy:    equ  0eeh
iisr:   equ  0ebh
imr:    equ  0fbh
isr:    equ  0fch
beep:   equ  0fdh
basic_work: equ  0d1h
cr:     equ  00dh
part_c: equ  0
data_adr: equ  0
data_s_adr: equ  data_adr+3
oct:    equ  data_s_adr+3
onp:    equ  oct+1
l_count: equ  onp+1
o_count: equ  l_count+1
oct_flg:    equ  13h
octerve_adr: equ  30h
length_adr: equ  33h
e_flg:  equ  18h
        org  0bf000h

install: local
        mv   x,basic_command
        mv   [(!basic_work)+90h],x
        mv   x,basic_code
        mv   [(!basic_work)+93h],x
        retf

remove: mv   x,0fffffh
        mv   [(!basic_work)+90h],x
        mv   [(!basic_work)+93h],x
        callf !init1
        retf
basic_command: db  04h
        dm   'PLAY'
        db   1fh
        db   5
        dm   'EXOFF'
        db   2
        db   0,0
basic_code: db  1fh
        dw   !entry
        db   8bh
        db   2
        dw   remove
        db   8bh
        db   0,0
        endl

entry:  local
        pushu imr
        mv   (!imr),0a0h
        mv   [--u],(!abp)
        call mml_conv
        mv   a,0
        pushu a
        callf !init2
        popu   a
        mv   (!abp),[u++]
        popu imr
        retf

mml_conv: mv   y,octerve
        mv   (!octerve_adr),y
        mv   y,length
        mv   (!length_adr),y
        mv   y,[(!part1)+3]
        mv   [MML_data_adr],y
        mv   y,not_data
        mv   [(!part3)+3],y
        mv   [(!part2)+3],y

        mv   (!oct_flg),0fh
        mv   a,[x++]
        cmp  a,'"'
        jrz  mml_conv_exit
        cmp  a,'"'
        jrz  mml_conv_lp
mml_conv_lp: mv  a,[x++]
        cmp  a,'"'
        jrz  mml_conv_exit
        jrz  mml_conv_exit_c
        cmp  a,':'
        jrz  part_ch
        cmp  a,'>'
        jpz  oct_up
        cmp  a,'<'
        jpz  oct_dw
        cmp  a,'O'
        jpz  oct_ch
        cmp  a,'T'
        jpz  temp2_ch
        cmp  a,'L'
        jrz  len_ch
        cmp  a,'R'
        jrz  kyuufu
        cmp  a,'+'
        jpz  oct_up
        cmp  a,'-'
        jpz  oct_dw
        cmp  a,'I'
        jrz  format_ch

onp_set: mv  y,mml_data1
        cmp  a,'#'
        jrz  onp_skip
        mv   y,mml_data2
onp_skip: sub  a,'A'
        cmp  a,7
        jrc  onp_skip2
        mv   a,[y]
        mv   il,a
        popu y
onp_len: sub  a,'0'
        jrc  onp_len_sk2
        jrnc  onp_len_sk
        sub  a,'U'-'0'
        cmp  a,6
        jrc  onp_len_sk
        add  a,10
        jr   onp_len_sk2
onp_len_sk: mv  a,[(!length_adr)]
        dec  x
onp_len_sk2: pushu a
        mv   a,[format_data]
        cmp  a,0
        popu a
        jrz  onp_len_sk3
        mv   [(!length_adr)],a
onp_len_sk3: add  a,il
        cmp  (!oct_flg),010h
        jrc  mml_conv_lp
        mv   a,(!oct_flg)
        mv   (!oct_flg),0ffh
        jr   oct_ch_s
onp_skip2: popu y
        jr   mml_conv_lp

kyuufu: mv   il,0
        jr   onp_len

mml_conv_exit_c: dec  x
mml_conv_exit: mv   a,[y]
        mv   [y++],a
        ret

len_ch: mv   a,[x]
        sub  a,'0'
        cmp  a,0ah
        jrc  len_sk
        sub  a,'U'
        cmp  a,6
        jrc  mml_conv_lp
        add  a,10
len_sk: mv   [(!length_adr)],a
        jr   mml_conv_lp

format_ch: mv  a,[x]
        sub  a,'0'
        mv   [format_data],a
format_sk: inc  x
        jr   mml_conv_lp

part_ch: pushu x
        mv   a,0ffh
        mv   [y++],a
        mv   x,[MML_data_adr]
        add  x,ba
        add  x,ba
        mv   [MML_data_adr],x
        mv   y,x
        mv   x,[(!octerve_adr)]
        inc  x
        inc  x
        mv   (!octerve_adr),x
        mv   x,[(!length_adr)]
        inc  x
        inc  x
        mv   (!length_adr),x
        jr   mml_conv_lp

temp_ch: mv   a,[x]
        sub  a,'0'
        cmp  a,0ah
        jrc  mml_conv_lp
        add  a,!temp
        mv   [y++],a
        inc  x
        jr   mml_conv_lp

temp2_ch: mv   il,0
        mv   a,0dfh
        mv   [y++],a
temp2_lp1: mv  a,[x]
        sub  a,30h
        cmp  a,10
        jrc  temp2_sk1
        pushu a
        mv   a,il
        add  a,a
        add  a,a
        add  il,a
        add  il,il
        popu a
        add  il,a
        inc  x
        jr   temp2_lp1
temp2_sk1: mv  [y++],il
        jp   mml_conv_lp

oct_ch:  mv   a,[x]
        sub  a,30h
oct_ch_s: cmp  a,10
        jpnc mml_conv_lp
        mv   [(!octerve_adr)],a
        add  a,0e0h
        mv   [y++],a
        jp   mml_conv_lp
oct_flg_up: mv  a,[(!octerve_adr)]
        mv   (!oct_flg),a
oct_up:  mv   a,[(!octerve_adr)]
        inc  a
        jr   oct_ch_s
oct_flg_dw: mv  a,[(!octerve_adr)]
        mv   (!oct_flg),a
oct_dw:  mv   a,[(!octerve_adr)]
        dec  a
        jr   oct_ch_s


mml_data1: db  0a0h
        db   0c0h
        db   010h
        db   030h
        db   050h
        db   060h
        db   080h
mml_data2: db  0b0h
        db   010h
        db   020h
        db   040h
        db   050h
        db   070h
        db   090h

not_data:  db  0ffh
octerve:   db  3
length:    db  6
octerve2:  db  3
length2:   db  5
octerve3:  db  3
length3:   db  5
MML_data_adr: ds  3
format_data: db  1
        endl

init1:  mv   y,0
        mv   [part1+o_count],y
        mv   [part2+o_count],y
        mv   [part3+o_count],y
        mv   [part1+oct],a
        mv   [part2+oct],a
        mv   [part3+oct],a
        retf

init2:  mv   i,0
        mv   [part1+onp],i
        mv   [part2+onp],i
        mv   [part3+onp],i
        mv   y,[(!part1)+3]
        mv   [part1+data_adr],y
        mv   y,[(!part2)+3]
        mv   [part2+data_adr],y
        mv   y,[(!part3)+3]
        mv   [part3+data_adr],y

main2:  mv   x,part1
        call mml
        mv   x,part2
        call mml
        mv   x,part3
        call mml
        mv   a,0
        mv   b,a
        mv   a,[part1+l_count]
        mv   (part_c),[part2+l_count]
        cmp  (part_c),0
        jrz  main2_skip1
        cmp  (part_c),a
        jrc  main2_skip1
        mv   a,(part_c)
main2_skip1: mv  (part_c),[part3+l_count]
        cmp  (part_c),0
        jrz  main2_skip2
        cmp  (part_c),a
        jrc  main2_skip2
        mv   a,(part_c)
main2_skip2: cmp  a,0
        jpz  exit

        mv   il,a
        mv   a,[part1+l_count]
        sub  a,il
        mv   [part1+l_count],a
        mv   a,[part2+l_count]
        sub  a,il
        mv   [part2+l_count],a
        mv   a,[part3+l_count]
        sub  a,il
        mv   [part3+l_count],a
        add  i,i
        mv   a,[temp]
        mv   x,0
main2_lp1: add  i,i
        rc
        shr  a
        jrnc main2_skip
        add  x,i
main2_skip: cmp  a,0
        jrz  main2_lp1
        mv   [count],x
        mv   (part_c),0
        mv   y,count1
        mv   a,[part1+onp]
        inc  a
        jrz  p1_skip
        dec  a
        jrz  p1_skip
        mv   ba,[part1+o_count]
        mv   [y++],ba
        inc  (part_c)
p1_skip: mv  a,[part2+onp]
        inc  a
        jrz  p2_skip
        dec  a
        jrz  p2_skip
        mv   ba,[part2+o_count]
        mv   [y++],ba
        inc  (part_c)
p2_skip: mv  a,[part3+onp]
        inc  a
        jrz  p3_skip
        dec  a
        jrz  p3_skip
        mv   ba,[part3+o_count]
        mv   ba,ba
        inc  (part_c)
p3_skip: mv  x,[count]
        mv   ba,[count1]
        mv   i,ba
        mv   y,i

        mv   [bo3p11+1],ba
        mv   [bo3p22+1],i
        mv   [bo3p21+1],i
        mv   [bo3p31+1],y
        mv   [bo3p32+1],y
        mv   [bo3p33+1],y
        mv   [bo3p34+1],y
        dec  (part_c)
        jpz  beep_out3
        mv   i,[count2]

        mv   [bo3p21+1],i
        mv   [bo3p22+1],i
        dec  i
        dec  i
        dec  i
        dec  (part_c)
        jpz  beep_out3
        mv   ba,[count3]

        mv   [bo3p11+1],ba
        dec  ba
        dec  ba
        dec  ba
        dec  (part_c)
        jpz  beep_out3

        jp   beep_out0
exit:  retf
ret:
mml:   pushu y
        mv   a,[x+onp]
        cmp  a,0ffh

        jrz  mml_exit
        mv   a,[x+l_count]
        cmp  a,0
        jrz  skip_exit
        mv   y,[x]
mml_loop: mv  a,[y++]
        cmp  a,0ffh
        jrz  mml_exit
        cmp  a,0dfh
        jrz  temp_ch
        cmp  a,0e0h
        jrc  mml_onp
oct_ch: and  a,0fh
        mv   [x+oct],a
        jr   mml_loop
temp_ch: mv  a,[y++]
        mv   [temp],a
        jr   mml_loop

mml_exit: mv  [x+onp],a
        mv   a,0
        mv   [x+l_count],a
        popu y
        sc
        ret
skip_exit: mv  i,[x+o_count]
        popu y
        rc
        ret
mml_onp: mv  [x],y
        pushu a
        and  a,0f0h
        ror  a
        ror  a
        mv   il,a
        ror  a
        ror  a
        mv   [x+onp],a
        add  a,il
        add  a,a
        mv   y,mml_data
        add  y,a
        mv   a,[x+oct]
        add  a,a
        add  y,a
        mv   il,[y]
        mv   [x+o_count],i
        popu a
        and  a,0fh
        mv   y,length_data
        add  y,a
        mv   a,[y]
        mv   [x+l_count],a
        popu y
        rc
        ret


beep_out0:
bo0lp: mv   i,4
bo0l1: dec  i
        jrnz bo0l1
        mv   (!beep),2h
        nop
        nop
        nop
bo0be: dec  x
        jrz  bo0lp
        jp   main2


beep_out3:
        mv   [bo3p11+1],ba
        mv   [bo3p21+1],i
        mv   [bo3p22+1],i
        mv   [bo3p31+1],y
        mv   [bo3p32+1],y
        mv   [bo3p33+1],y
        mv   [bo3p34+1],y

bo3lp: dec  ba
        jrz  sk1
bo3p11: mv  ba,0
        mv   (!beep),2h
        dec  i
        jrz  sk12
bo3p21: mv  i,0
        dec  y

        jrz  sk13
bo3p31: mv  y,0
        mv   (!beep),12h
        dec  x
        jrnz bo3lp
        jp   bo3ex
sk3: nop
        nop
        nop
        mv   (!beep),12h
        dec  x
        jrz  bo3lp
        jp   bo3ex
sk2: nop
        nop
        dec  y
        jrz  sk13
bo3p32: mv  y,0
        mv   (!beep),12h
        dec  x
        jrz  bo3lp
        jp   bo3ex
sk1: nop
        nop
        mv   (!beep),2h
        dec  i
        jrz  sk12
bo3p22: mv  i,0
        dec  y
        jrnz sk3
bo3p33: mv  y,0
        mv   (!beep),12h
        dec  x
        jrz  bo3lp
        jp   bo3ex
sk12: nop
        nop
        dec  y
        jrz  sk13
bo3p34: mv  y,0
        mv   (!beep),12h
        dec  x
        jrz  bo3lp
        jp   bo3ex
sk13: nop
        nop
        nop
        nop
        nop
        nop
        nop
        dec  x
        jrz  bo3lp
bo3ex: mv   (!beep),2h
        jp   main2


mml_data:
        dw   000h, 000h, 000h, 000h, 000h
        dw   12Eh, 097h, 04Ch, 026h, 013h
        dw   11Dh, 08Fh, 048h, 024h, 012h
        dw   10Dh, 087h, 044h, 022h, 011h
        dw   0FEh, 07Fh, 040h, 020h, 010h
        dw   0F0h, 078h, 03Ch, 01Eh, 00Fh
        dw   0E2h, 071h, 039h, 01Dh, 00Fh
        dw   0D6h, 06Bh, 036h, 01Bh, 00Eh
        dw   0CAh, 065h, 033h, 01Ah, 00Dh
        dw   0BEh, 05Fh, 030h, 018h, 00Ch
        dw   0B4h, 05Ah, 02Dh, 017h, 00Ch
        dw   0AAh, 055h, 02Bh, 016h, 00Bh
        dw   0A0h, 050h, 028h, 014h, 00Ah

length_data: db  003h, 006h, 009h, 00Ch
        db   012h, 018h, 024h, 030h
        db   048h, 060h, 002h, 004h
        db   006h, 010h, 020h, 001h

temp:   db   1
count:  db   0,0,0
count1: db   0,0
count2: db   0,0
count3: db   0,0,0
part1:  ds   16
part2:  ds   16
part3:  ds   16
r_flg:  ds   1
data_buff: ds  1
        end

