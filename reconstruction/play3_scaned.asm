; ============================================================
; PLAY3 ソース再構成版 (XASM用)
; Pocket Computer Journal 1993年11月号掲載 PLAY3
; 作者: Ryu
;
; スキャン画像 127〜135.jpg, nup0030〜0031.jpg,
; 153〜160.jpg をもとに OCR・統合・手修正して
; 再構成した参考ソースです。
;
; 原著作権は元の作者および掲載元に帰属します。
; 本ファイル中の再構成・注記・補足は、歴史的保存および
; 研究目的で付したものです。
;
; Note:
; This reconstruction includes manually corrected and inferred lines.
; Please verify uncertain sections against the original scanned pages.
; ============================================================

; ============================================================
; PLAY3 ソース・リスト (XASM用)
; PJプラザ掲載 by Ryu
; スキャン画像 127〜135.jpg, nup0030〜0031.jpg,
;             153〜160.jpg より OCR・統合・修正 完成版
; ============================================================

; === システムエントリ・equ定義 (128.jpg) ===
1:          pre_on
3:  ;----- System Entry -----
4:  fcs:    equ  0fffe4h       ; File Controll System Entry
5:  iocs:   equ  0fffe8h       ; Output Control System Entry
6:  ;----- タイマ割り込み -----
7:  vect0:  equ  0bfcc6h       ; fast タイマ割り込み
8:  vect1:  equ  0bfcc9h       ; slow タイマ割り込み
9:  vect2:  equ  0bfccch       ; キー割り込み
10: vect3:  equ  0bfccfh       ; ONキー割り込み
11: vect4:  equ  0bfcd2h       ; SIO送信割り込み
12: vect5:  equ  0bfcd5h       ; SIO受信割り込み
13: vect6:  equ  0bfcd8h       ; 外部割り込み
14: vect7:  equ  0bfcdbh       ; ソフトウェア割り込み
15: ;----- 内部RAMレジスタ -----
17: bx:     equ  0d4h
18: cs:     equ  0d5h
19: cx:     equ  0d6h
20: dx:     equ  0d8h
21: dh:     equ  0d9h
22: si:     equ  0dah
23: di:     equ  0ddh
24: ;----- ポインタ -----
25: abp:    equ  0ech
26: apx:    equ  0edh
27: apy:    equ  0eeh
28: ;----- 割り込みレジスタ -----
29: iisr:   equ  0ebh
30: imr:    equ  0fbh
32: isr:    equ  0fch
33: beep:   equ  0fdh
34: basic_work: equ  0d1h
35: cr:     equ  00dh
36: ;-----
37: part_c: equ  0
38: data_adr: equ  0
39: data_s_adr: equ  data_adr+3
40: oct:    equ  data_s_adr+3
41: onp:    equ  oct+1
42: l_count: equ  onp+1
43: o_count: equ  l_count+1
44: ;----- MML内部RAM WORK -----
46: ;
47: oct_flg:    equ  13h       ; オクターブ設定フラグ
48: octerve_adr: equ  30h      ; オクターブデータアドレス
49: length_adr: equ  33h       ; レングスアドレス
50: ;
51: e_flg:  equ  18h           ; 終了フラグ
52: ;------------------------------
53:         org  0bf000h

55: ; インストール
56: ;------------------------------
57: install: local             ; BASコマンド組込/PLAYOFR
58:         mv   x,basic_command
59:         mv   [(!basic_work)+90h],x
60:         mv   x,basic_code
61:         mv   [(!basic_work)+93h],x
62:         retf

63: remove: mv   x,0fffffh     ; BASコマンド解除
64:         mv   [(!basic_work)+90h],x
65:         mv   [(!basic_work)+93h],x
66:         callf !init1
67:         retf
68: ;
69: ;----- BASコマンドテーブル -----
71: ;------------------------------
72: basic_command: db  04h     ; 命令の文字数
73:         dm   'PLAY'        ; 命令の文字列
74:         db   1fh           ; 中間コード
75:         db   5
76:         dm   'EXOFF'       ; 命令の文字列
77:         db   2
78:         db   0,0
79: basic_code: db  1fh
80:         dw   entry         ; 処理先アドレス
81:         db   8bh           ; bit6=1 bit7=1 コマンド処理
82:         db   2
83:         dw   remove        ; 処理先アドレス
84:         db   8bh           ; bit6=1 bit7=1
85:         db   0,0
86:         endl

87: ;------------------------------
88: ; 初期設定
89: ;------------------------------
90: entry:  local
91:         pushuimr           ; 割り込みイネーブル・レジスタ保存
92:         mv   (!imr),0a0h
93:         mv   [--u],(!abp)  ; bp 保存
94:         call mml_conv      ; MML解析・処理
95: ;
96:         pushu  0
97:         callf !init2
98:         popu   a
99:         mv   (!abp),[u++]  ; bp 復元
100:        popuimr             ; 割り込みイネーブル・レジスタ復元
101:        ;
102:        retf

; === MML Converter (127.jpg, 128.jpg) ===
104: ; MML Converter
105: ;------------------------------
106: mml_conv: mv   y,octerve
107:         mv   [(!octerve_adr)],y  ; オクターブデータアドレス設定
108:         mv   y,length
109:         mv   [(!length_adr)],y   ; レングスデータアドレス設定
110: ;
111:         mv   y,[part1+!data_s_adr]
112:         mv   [MML_data_adr],y    ; MMLデータアドレス
113:         mv   y,not_data
114:         mv   [part3+!data_s_adr],y ; 3音目データアドレス
115:         mv   [part2+!data_s_adr],y ; 2音目データアドレス

; === MML解析 (127.jpg) ===
118: ;----- MML解析 -----
120:        mv   [(!oct_flg)],0fh
121:        mv   a,[x++]
122:        cmp  a,'"'
123:        jrz  mml_conv_exit       ; パラメータが無い
124:        cmp  a,'"'
125:        jrz  mml_conv_lp         ; ダブルクォーテーションをスキップ
128: mml_conv_lp: mv  a,[x++]
129:        cmp  a,'"'
130:        jz   mml_conv_exit
131:        jrz  mml_conv_exit_c     ; crがあったら終了
132:        cmp  a,':'
133:        jz   part_ch             ; パートチェンジ
134:        cmp  a,'>'
135:        jpz  oct_up              ; 1オクターブUP
136:        cmp  a,'<'
137:        jpz  oct_dw              ; 1オクターブDOWN
138:        cmp  a,'O'
139:        jpz  oct_ch              ; オクターブ変更
140:        cmp  a,'T'
141:        jrz  temp2_ch            ; テンポ変更
142:        cmp  a,'L'
143:        jrz  len_ch              ; デフォルトレングス変更
144:        cmp  a,'R'
145:        jrz  kyuufu              ; 休符
146:        cmp  a,'+'
147:        jpz  oct_up
148:        ;
149:        cmp  a,'-'
150:        jpz  oct_dw
151:        cmp  a,'I'
152:        jrz  format_ch

; === 音符データ設定 (128.jpg) ===
154: ;------------------------------
155: ;  音符データ設定
156: onp_set: mv  y,mml_data1        ; 音符データ先頭アドレス
157:         cmp  a,'#'              ; シャープ?
158:         jmz  onp_skip
159:         mv   y,mml_data2        ; シャープ音符データ先頭アドレス
162: onp_skip: sub  a,'A'
163:         cmp  a,7
164:         jmc  onp_skip2
165:         mv   a,[y]
166:         mv   il,a
168:         popu y
169: onp_len: sub  a,'0'
171:         jrc  onp_len_sk2
172:         jre  onp_len_sk
173:         sub  a,'U'-'0'
174:         cmp  a,6
175:         jmc  onp_len_sk
176:         add  a,10
177:         jr   onp_len_sk2
178: onp_len_sk: mv  a,[(!length_adr)]
179:         dec  x
180: onp_len_sk2: pushu a
181:         mv   a,[format_data]
182:         cmp  a,0
183:         popu a
184:         jmz  onp_len_sk3
185:         mv   [(!length_adr)],a  ; length デフォルト設定
186: onp_len_sk3: add  a,il
187:         cmp  [(!oct_flg)],010h
189:         jmc  mml_conv_ip
190:         mv   a,[(!oct_flg)]
191:         mv   [(!oct_flg)],0ffh
192:         jr   oct_ch_s
193: onp_skip2: popu y
194:         jr   mml_conv_ip

; === 休符・終了処理 (127.jpg) ===
198: kyuufu: mv   il,0
199:         jr   onp_len

200: ;------------------------------
201: ; 終了処理
203: mml_conv_exit_c: dec  x
204: mml_conv_exit: mv   a,[y]
205:         mv   [y++],a            ; MMLデータ解析終了
206:         ret

; === 音長設定 (127.jpg) ===
209: ;------------------------------
210: len_ch: mv   a,[x]
211:         sub  a,'0'
212:         cmp  a,0ah
213:         jrc  len_sk
214:         sub  a,'U'
215:         cmp  a,6
216:         jmc  mml_conv_lp
217:         add  a,10
218: len_sk: mv   [(!length_adr)],a
219:         jr   mml_conv_lp

222: format_ch: mv  a,[x]
223:         sub  a,'0'
225:         mv   [format_data],a
226: format_sk: inc  x
227:         jr   mml_conv_lp

; === パート変更処理 (127.jpg) ===
230: ;------------------------------
231: ; パート変更処理
232: part_ch: pushu x
233:         mv   a,0ffh
234:         mv   [y++],a
235:         mv   x,[MML_data_adr]
236:         add  x,ba
237:         add  x,ba
238:         mv   [MML_data_adr],x
239:         mv   y,x
240:         mv   x,[(!octerve_adr)]
241:         inc  x
242:         inc  x
243:         mv   [(!octerve_adr)],x
244:         mv   x,[(!length_adr)]
245:         inc  x
246:         inc  x
247:         mv   [(!length_adr)],x
248:         jr   mml_conv_lp

; === テンポ設定 (127.jpg) ===
250: ; テンポ設定
252: temp_ch: mv   a,[x]
253:         sub  a,'0'
254:         cmp  a,0ah
255:         jmc  mml_conv_lp
256:         add  [temp],a
257:         mv   [y++],a
258:         inc  x
259:         jr   mml_conv_lp

; === オクターブ設定 (nup0030.jpg) ===
261: temp2_ch: mv   il,0
262:         mv   a,0dfh
263:         mv   [y++],a
264: temp2_lp1: mv  a,[x]
265:         sub  a,30h
266:         cmp  a,10
267:         jmc  temp2_sk1
268:         pushu a
269:         mv   a,il
270:         add  a,a
271:         add  a,a
272:         add  il,a
273:         add  il,il
274:         popu a
275:         add  il,a
276:         inc  x
277:         jr   temp2_lp1
278: temp2_sk1: mv  [y++],il
279:         jp   mml_conv_lp

; === オクターブ変更処理 (nup0030.jpg) ===
280: ;------------------------------
281: ; オクターブ変更
283: oct_ch:  mv   a,[x]
284:         sub  a,30h
285: oct_ch_s: cmp  a,10
286:         jpnc mml_conv_lp
287:         mv   [(!octerve_adr)],a
288:         add  a,0e0h
289:         mv   [y++],a
290:         jp   mml_conv_lp
291: ;------------------------------
292: oct_flg_up: mv  (!oct_flg),[(!octerve_adr)]
293: ;------------------------------
294: oct_up:  mv   a,[(!octerve_adr)]
295:         inc  a
296:         jr   oct_ch_s
297: ;------------------------------
298: oct_flg_dw: mv  (!oct_flg),[(!octerve_adr)]
299: ;------------------------------
300: oct_dw:  mv   a,[(!octerve_adr)]
301:         dec  a
302:         jr   oct_ch_s

; === コマンドコード対応表 ===
304: ;
306: ;     00 R   60 F   C0 B
307: ;     10 C   70 #F  D0 T  Dnn TEMPNN
308: ;     20 #C  80 G   E0 O  EE DOWN EF UP
309: ;     30 D   90 #G  F0 reserve
310: ;     40 #D  A0 A
311: ;     50 #E  B0 #A  FF END

; === 音名データ (nup0030.jpg) ===
313: mml_data1: db  0a0h          ; a
314:         db   0c0h            ; b
315:         db   010h            ; c
316:         db   030h            ; d
317:         db   050h            ; e
318:         db   060h            ; f
319:         db   080h            ; g
320: mml_data2: db  0b0h          ; #a
321:         db   010h            ; #b
322:         db   020h            ; #c
323:         db   040h            ; #d
324:         db   050h            ; #e
325:         db   070h            ; #f
326:         db   090h            ; #g

; === ワーク変数定義 (nup0030.jpg, nup0031.jpg) ===
328: not_data:  db  0ffh
329: octerve:   db  3
330: length:    db  6
331: octerve2:  db  3
332: length2:   db  5
333: octerve3:  db  3
334: length3:   db  5
335: MML_data_adr: ds  3
336: format_data: db  1
337:         endl

338: ;------------------------------
339: ; 初期設定
341: ;------------------------------
342: init1:  mv   y,0
343: ;
344:         mv   [part1+o_count],y  ; 音程カウンタ reset
345:         mv   [part2+o_count],y  ; 音程カウンタ reset
346:         mv   [part3+o_count],y  ; 音程カウンタ reset
347:         mv   [part1+oct],a      ; オクターブ初期化
348:         mv   [part2+oct],a      ; オクターブ初期化
349:         mv   [part3+oct],a      ; オクターブ初期化
350:         retf

351: ;------------------------------
352: ;  初期設定 2
353: ;------------------------------
354: init2:  mv   i,0
355:         mv   [part1+onp],i      ; 音長カウンタ reset
356:         mv   [part2+onp],i      ; 音長カウンタ reset
357:         mv   [part3+onp],i      ; 音長カウンタ reset
358:         mv   y,[part1+data_s_adr]
359:         mv   [part1+data_adr],y ; データアドレスセット
360:         mv   y,[part2+data_s_adr]
361:         mv   [part2+data_adr],y ; データアドレスセット
362:         mv   y,[part3+data_s_adr]
363:         mv   [part3+data_adr],y ; データアドレスセット
364: ;------------------------------

; === メインルーチン ===
365: ;  メインルーチン
366: ;------------------------------
367: main2:  mv   x,part1
368:         call mml
369:         mv   x,part2
370:         call mml
371:         mv   x,part3
372:         call mml                ; 各パートデータセット
373: ;
374:         mv   a,0
375:         mv   b,a
376:         mv   a,[part1+l_count]
377:         mv   (part_c),[part2+l_count]
378:         cmp  (part_c),0
379:         jrz  main2_skip1
380:         cmp  (part_c),a
381:         jmc  main2_skip1
382:         mv   a,(part_c)
383: main2_skip1: mv  (part_c),[part3+l_count]
384:         cmp  (part_c),0
385:         jrz  main2_skip2
386:         cmp  (part_c),a
387:         jmc  main2_skip2
388:         mv   a,(part_c)
389: main2_skip2: cmp  a,0
390:         jrz  exit               ; a = 最短音長 (0=END)

; === メイン処理後半 (132.jpg, 133.jpg) ===
391:        mv   il,a
393:        mv   a,[part1+l_count]
394:        sub  a,il
395:        mv   [part1+l_count],a
396:        mv   a,[part2+l_count]
397:        sub  a,il
398:        mv   [part2+l_count],a
399:        mv   a,[part3+l_count]
400:        sub  a,il
401:        mv   [part3+l_count],a
403:        add  i,i              ; x4
404:        mv   a,[temp]         ; テンポ (微調整)
405:        mv   x,0
406: main2_lp1: add  i,i
407:        rc
408:        shr  a
409:        jrnc main2_skip       ; x=ba*il
410:        add  x,i
411: main2_skip: cmp  a,0
412:        jmz  main2_lp1
413:        mv   [count],x
415:        mv   (part_c),0
416:        mv   y,count1
417:        mv   a,[part1+onp]
418:        inc  a
419:        jz   p1_skip
420:        dec  a
421:        jrz  p1_skip
422:        mv   ba,[part1+o_count]
423:        mv   [y++],ba
424:        inc  (part_c)
425: p1_skip: mv  a,[part2+onp]
426:        inc  a
427:        jrz  p2_skip
428:        dec  a
429:        jrz  p2_skip
430:        mv   ba,[part2+o_count]
431:        mv   [y++],ba
432:        inc  (part_c)
433: p2_skip: mv  a,[part3+onp]
434:        inc  a
435:        jrz  p3_skip
436:        dec  a
437:        jrz  p3_skip
438:        mv   ba,[part3+o_count]
439:        mv   ba,ba
440:        inc  (part_c)
441: p3_skip: mv  x,[count]
442:        mv   ba,[count1]
443:        mv   i,ba
444:        mv   y,i

; === 3音設定 (132.jpg, 133.jpg) ===
445: ;------------------------------
446: ; 3音設定
447: ;------------------------------
448:        mv   [!beep_out3!part1_co1+1],ba
449:        mv   [!beep_out3!part2_co2+1],i
450:        mv   [!beep_out3!part2_co1+1],i
451:        mv   [!beep_out3!part3_co1+1],y
452:        mv   [!beep_out3!part3_co2+1],y
453:        mv   [!beep_out3!part3_co3+1],y
454:        mv   [!beep_out3!part3_co4+1],y
455:        dec  (part_c)
456:        jpz  beep_out3
457:        mv   i,[count2]

; === 2音設定 (133.jpg) ===
458: ;------------------------------
459: ; 2音設定
460: ;------------------------------
461:        mv   [!beep_out3!part2_co1+1],i
462:        mv   [!beep_out3!part2_co2+1],i
463:        dec  i
464:        dec  i
465:        dec  i
466:        dec  (part_c)
467:        jpz  beep_out3
468:        mv   ba,[count3]

; === 単音設定 (133.jpg) ===
469: ;------------------------------
470: ; 単音設定
471: ;------------------------------
472:        mv   [!beep_out3!part1_co1+1],ba
473:        dec  ba
474:        dec  ba
475:        dec  ba
476:        dec  (part_c)
477:        jpz  beep_out3

; === 無音設定 (133.jpg) ===
478: ;------------------------------
479: ; 無音設定
480: ;------------------------------
481:        jr   beep_out0
482: ;------------------------------
483: exit:  retf
484: ;------------------------------
485: ; データ解析
486: ;------------------------------
487: ; x = part para addr
488: ret:   ; cy=1 data end
489:        ; cy=0  i = 音長 [x+o_count]
490:        ; a = 音程 [x+l_count]
491:        ; y = 音符 :x = part parameter address
492: mml:   pushu y
493:        mv   a,[x+onp]
494:        cmp  a,0ffh

; === MMLループ (132.jpg col3, 134.jpg) ===
495:        jrz  mml_exit
496:        mv   a,[x+l_count]
497:        cmp  a,0
498:        jmz  skip_exit
499:        mv   y,[x]              ; MMLデータアドレス
500: mml_loop: mv  a,[y++]
501:        cmp  a,0ffh
502:        jrz  mml_exit
503:        cmp  a,0dfh
504:        jrz  temp_ch
505:        cmp  a,0e0h
506:        jrc  mml_onp
507:        ;
508: oct_ch: and  a,0fh
509:        mv   [x+oct],a          ; オクターブのセット
510:        jr   mml_loop
511:        ;
512: temp_ch: mv  a,[y++]
513:        mv   [temp],a           ; テンポのセット
514:        jr   mml_loop

516: mml_exit: mv  [x+onp],a       ; 音符コード記憶
517:        mv   a,0
518:        mv   [x+l_count],a
519:        popu y
520:        sc
521:        ret
522: ;------------------------------
523: skip_exit: mv  i,[x+o_count]
524:        popu y
525:        rc
526:        ret
527: ;------------------------------
528: mml_onp: mv  [x],y             ; MMLデータアドレス (3byte)
529:        ;
530:        pushu a
531:        and  a,0f0h
532:        ror  a                  ; ローテイトライト (+2)
533:        ror  a                  ; ローテイトライト (+2)
534:        mv   il,a
535:        ror  a                  ; ローテイトライト (+3)
536:        ror  a                  ; ローテイトライト (+2)
537:        mv   [x+onp],a         ; 音符フィット
538:        add  a,il              ; 1+4
539:        add  a,a               ; x2 (a+1.6X10)
540:        mv   y,mml_data         ; mml tone data
541:        add  y,a
542:        mv   a,[x+oct]         ; オクターブ (O)
543:        add  a,a               ; x2
544:        add  y,a
545:        mv   il,[y]            ; 音程カウンタ set
546:        mv   [x+o_count],i     ; 音程カウンタ set
547:        popu a
548:        and  a,0fh
549:        mv   y,length_data
550:        add  y,a
551:        mv   a,[y]             ; 音長データ
552:        mv   [x+l_count],a
553:        popu y
554:        rc
555:        ret

; === 音発生ルーチン (133.jpg col3, 134.jpg, 135.jpg) ===
556: ;----- 音発生ルーチン 1loop = 37state 48.1uS -----

; === 音発生 (0音) ===
559: ; 音発生 (0音)
561: ; x = 発声音長カウンタ  78state
563: beep_out0: local
564: loop:  mv   i,4              ; 6*(a)+2
565: loop1: dec  i               ; 6
566:        jrnz loop1           ; 4,6
567:        mv   (!beep),2h      ; 8  ブザーOFF
568:        nop                  ; 2
569:        nop                  ; 2
570:        nop                  ; 2
571: b_ent: dec  x               ; 6
572:        jmz  loop            ; 4,6
573:        jp   !main2
574:        endl

; === 音発生 (3音) ===
575: ; 音発生 (3音)
577: ; ba = part1 カウンタ
578: ; i  = part2 カウンタ
579: ; y  = part3 カウンタ
580: ; x  = 発声音長カウンタ  78state
581: beep_out3: local
582:        mv   [part1_co1+1],ba
583:        mv   [part2_co1+1],i
584:        mv   [part2_co2+1],i
585:        mv   [part3_co1+1],y
586:        mv   [part3_co2+1],y
587:        mv   [part3_co3+1],y
588:        mv   [part3_co4+1],y

589: loop:  dec  ba              ; 6
590:        jmz  skip            ; 4,6
591: part1_co1: mv  ba,0         ; 6
592:        mv   (!beep),2h      ; 8  ブザーOFF
593:        dec  i               ; 6
594:        jmz  skip2           ; 4,6
595: part2_co1: mv  i,0          ; 6
596:        dec  y               ; 6
; (行597以降は134.jpg col2より)

598:        jmz  skip3           ; 4,6
599: part3_co1: mv  y,0          ; 8
600:        mv   (!beep),12h     ; 8  ブザーON
601:        dec  x               ; 6
602:        jrnz loop            ; 4,6
603:        jr   exit
605: skip3: nop                  ; 2
606:        nop                  ; 2
607:        nop                  ; 2
608:        mv   (!beep),12h     ; 8  ブザーON
609:        dec  x               ; 6
610:        jz   loop            ; 4,6
611:        jr   exit
613: skip2: nop                  ; 4
614:        nop                  ; 2
615:        dec  y               ; 6
616:        jmz  skip3           ; 4,6
617: part3_co2: mv  y,0
618:        mv   (!beep),12h     ; 8  ブザーON
619:        dec  x               ; 6
620:        jmz  loop            ; 4,6
621:        jr   exit
623: skip1: nop                  ; 2
624:        nop                  ; 2
625:        mv   (!beep),2h      ; 8  ブザーOFF
626:        dec  i               ; 6
627:        jmz  skip12          ; 4,6
628: part2_co2: mv  i,0          ; 6
629:        dec  y               ; 6
630:        jrnz skip3           ; 4,6
631: part3_co3: mv  y,0
632:        mv   (!beep),12h     ; 8  ブザーON
633:        dec  x               ; 6
634:        jmz  loop            ; 4,6
635:        jr   exit
637: skip12: nop                 ; 2
638:        nop                  ; 2
639:        dec  y               ; 6
640:        jmz  skip13          ; 4,6
641: part3_co4: mv  y,0
642:        mv   (!beep),12h     ; 8  ブザーON
643:        dec  x               ; 6
644:        jmz  loop            ; 4,6
645:        jr   exit
647: skip13: nop                 ; 2
648:        nop                  ; 2
649:        nop                  ; 2
650:        nop                  ; 2
651:        nop                  ; 2
652:        nop                  ; 2
653:        nop                  ; 2
655:        dec  x               ; 6
656:        jz   loop            ; 4,6
657: exit:  mv   (!beep),2h      ; 8  ブザーOFF
658:        jp   !main2
659:        endl

; === 音程データテーブル (134.jpg col2, col3, 135.jpg) ===
660: ;------------------------------
661: ; 音符データ
665: ;------------------------------
666: mml_data:  ; O   00    01    02    03    04
667:        dw   000h, 000h, 000h, 000h, 000h  ; R (休符)
668:        dw   12Eh, 097h, 04Ch, 026h, 013h  ; C
669:        dw   11Dh, 08Fh, 048h, 024h, 012h  ; #C
670:        dw   10Dh, 087h, 044h, 022h, 011h  ; D
671:        dw   0FEh, 07Fh, 040h, 020h, 010h  ; #D
672:        dw   0F0h, 078h, 03Ch, 01Eh, 00Fh  ; E
673:        dw   0E2h, 071h, 039h, 01Dh, 00Fh  ; F
674:        dw   0D6h, 06Bh, 036h, 01Bh, 00Eh  ; #F
675:        dw   0CAh, 065h, 033h, 01Ah, 00Dh  ; G
676:        dw   0BEh, 05Fh, 030h, 018h, 00Ch  ; #G
677:        dw   0B4h, 05Ah, 02Dh, 017h, 00Ch  ; A
678:        dw   0AAh, 055h, 02Bh, 016h, 00Bh  ; #A
679:        dw   0A0h, 050h, 028h, 014h, 00Ah  ; B

; === 音長データ (135.jpg) ===
681: length_data: db  003h, 006h, 009h, 00Ch, 012h
682:        db   018h, 024h, 030h, 048h, 060h
683:        db   002h, 004h, 006h, 010h, 020h, 001h

; === ワーク変数 (160.jpg) ===
685: temp:   db   5               ; テンポ (IVY KA) 5byte
686: count:  dp   0               ; 発声音長カウンタ (3byte)
687: count1: db   0,0             ; 音長カウンタ
688: count2: db   0,0
689: count3: db   0,0,0
691: part1:  ds   16              ; パート1データ (16byte)
692: part2:  ds   16              ; パート2データ
693: part3:  ds   16              ; パート3データ
695: r_flg:  ds   1
696: data_buff: ds  1
697: ;
698: ;------------------------------
699:         end

; ============================================================
; スキャン画像対応表
; 128.jpg         : 行   1〜  90  equ定義・BASコマンドテーブル
; 127.jpg         : 行  57〜 260  install/entry/mml_conv/MML解析
; nup0030.jpg     : 行 261〜 327  オクターブ処理・音名データ
; nup0031.jpg     : 行 328〜 390  init1/init2・メインループ前半
; 132〜135.jpg    : 行 391〜 699  音発生・データテーブル完全版
; ============================================================
; 注記
; 本ソースには、OCR結果に対する手修正および補完行を含みます。
; 特に行366〜390付近（メインループ前半）は、
; nup0031右側カラムの視認性が低く、原本照合を推奨します。
; ============================================================