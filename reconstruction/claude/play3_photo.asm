1:		pre_on				; プレバイト自動生成機能ON
2:	;================================================================
3:	;	System エントリ -----
4:	fcs:		equ	0fffe4h		; File Controll System エントリ
5:	iocs:		equ	0fffe8h		; Input Output Control System エントリ
6:	;----- 割り込みベクタ -----
7:	vect0:		equ	0bfcc6h		; fast タイマ割り込み
8:	vect1:		equ	0bfcc9h		; slow タイマ割り込み
9:	vect2:		equ	0bfccch		; キー割り込み
10:	vect3:		equ	0bfccfh		; ONキー割り込み
11:	vect4:		equ	0bfcd2h		; SIO送信割り込み
12:	vect5:		equ	0bfcd5h		; SIO受信割り込み
13:	vect6:		equ	0bfcd8h		; 外部割り込み
14:	vect7:		equ	0bfcdbh		; ソフトウェア割り込み
15:	;----- 内部RAMレジスタ -----
16:	bx:		equ	0d4h
17:	bh:		equ	0d5h
18:	cx:		equ	0d6h
19:	ch:		equ	0d7h
20:	dx:		equ	0d8h
21:	dh:		equ	0d9h
22:	si:		equ	0dah
23:	di:		equ	0ddh
24:	;----- ポインタ -----
25:	abp:		equ	0ech
26:	apx:		equ	0edh
27:	apy:		equ	0eeh
28:	;----- 割り込みレジスタ -----
29:	iisr:		equ	0ebh		; 割り込みサービス中・レジスタ
30:	imr:		equ	0fbh		; 割り込みイネーブル・レジスタ
31:	isr:		equ	0fch		; 割り込みステータス・レジスタ
32:	;-----  -----
33:	beep:		equ	0fdh
34:	basic_work:	equ	0d1h
35:	cr:		equ	00dh
36:	;-----  -----
37:	part_c:		equ	0		; パートカウンタ
38:	data_adr:	equ	0		; MMLデータアドレス(3byte)
39:	data_s_adr:	equ	data_adr+3	; MMLデータ先頭アドレス(3byte)
40:	oct:		equ	data_s_adr+3	; オクターブ（O）(1byte)
41:	onp:		equ	oct+1		; 音符コード(1byte)
42:	l_count:	equ	onp+1		; 音長カウンタ(1byte)
43:	o_count:	equ	l_count+1	; 音程カウンタ(3byte)
44:	;================================================================
45:	;		MML 内部RAM WORK
46:	;----------------------------------------------------------------
47:	oct_flg:	equ	13h		; オクターブ設定フラグ
48:	octerve_adr:	equ	30h		; オクターブアドレス
49:	length_adr:	equ	33h		; レングスアドレス
50:	;
51:	e_flg:		equ	18h		; 終了フラグ
52:	;----------------------------------------------------------------
53:			org	0bf000h
54:	;----------------------------------------------------------------
55:	;	インストール
56:	;----------------------------------------------------------------
57:	install:	local			; BASICコマンド組込(PLAY/EXOFF)
58:			mv	x,basic_command
59:			mv	[(!basic_work)+90h],x
60:			mv	x,basic_code
61:			mv	[(!basic_work)+93h],x
62:			retf
63:	remove:		mv	x,0fffffh	; BASICコマンド解除
64:			mv	[(!basic_work)+90h],x
65:			mv	[(!basic_work)+93h],x
66:			callf	!init1
67:			retf
68:	;
69:	;----------------------------------------------------------------
70:	;	BASICコマンドテーブル
71:	;----------------------------------------------------------------
72:	basic_command:	db	04h		; 命令の文字数
73:			dm	'PLAY'		; 命令の文字列
74:			db	1fh		; 中間コード
75:			db	5		; 命令の文字数
76:			dm	'EXOFF'		; 命令の文字列
77:			db	2		; 中間コード
78:			db	0,0		; コマンドテーブル終了コード
79:	basic_code:	db	1fh		; 中間コード
80:			dw	!entry		; 処理先アドレス
81:			db	8bh		; bit6=1 関数 bit7=1 コマンド処理
82:			db	2		; 中間コード
83:			dw	remove		; 処理先アドレス
84:			db	8bh		; bit6=1 関数 bit7=1 コマンド処理
85:			db	0,0		; 処理先テーブル終了コード
86:			endl
87:	;----------------------------------------------------------------
88:	;	初期設定
89:	;----------------------------------------------------------------
90:	entry:		local
91:			pushuimr		; 割り込みイネーブル・レジスタ保存
92:			mv	(!imr),0a0h	; 割り込み禁止
93:			mv	[--u],(!abp)	; bp 保存
94:			call	mml_conv	; MML解析、処理
95:	;
96:			pushu	x
97:			callf	!init2		; 初期化
98:			popu	x
99:			mv	(!abp),[u++]	; bp 復帰
100:			popuimr			; 割り込みイネーブル・レジスタ復帰
101:	;					; 割り込み許可
102:			retf
103:	;----------------------------------------------------------------
104:	;	MML Converter
105:	;----------------------------------------------------------------
106:	mml_conv:	mv	y,octerve
107:			mv	(!octerve_adr),y	; オクターブデータアドレス設定
108:			mv	y,length
109:			mv	(!length_adr),y		; レングスデータアドレス設定
110:	;
111:			mv	y,!part1+!data_s_adr
112:			mv	[MML_data_adr],y	; MML解析データ設定アドレス
113:			mv	y,not_data
114:			mv	[!part3+!data_s_adr],y	; 3音目データアドレス
115:			mv	[!part2+!data_s_adr],y	; 2音目データアドレス
116:			mv	y,!data_buff
117:			mv	[!part1+!data_s_adr],y	; 1音目データアドレス
118:	;----------------------------------------------------------------
119:	;	MML 解析
120:	;----------------------------------------------------------------
121:			mv	(!oct_flg),0ffh
122:			mv	a,[x++]
123:			cmp	a,!cr		; MMLデータ読み込み
124:			jrz	mml_conv_exit_c	; パラメータが無い
125:			cmp	a,'"'
126:			jrz	mml_conv_lp	; ダブルクォーテーションをスキップ
127:			dec	x
128:	;----------------------------------------------------------------
129:	mml_conv_lp:
130:	;----------------------------------------------------------------
131:			cmp	a,!cr
132:			jrz	mml_conv_exit_c	; crがあったら終了
133:			cmp	a,':'
134:			jrz	part_ch		; part チェンジ
135:			cmp	a,'>'
136:			jpz	oct_up		; 1オクターブUP
137:			cmp	a,'<'
138:			jpz	oct_dw		; 1オクターブDOWN
139:			cmp	a,'O'
140:			jpz	oct_ch		; オクターブ変更
141:			cmp	a,'T'
142:			jrz	temp2_ch	; テンポ変更
143:			cmp	a,'L'
144:			jrz	len_ch		; デフォルトレングス変更
145:			cmp	a,'R'
146:			jrz	kyuufu		; 休符
147:			cmp	a,'+'
148:			jpz	oct_1up
149:			cmp	a,'-'
150:			jpz	oct_1dw
151:			cmp	a,'I'
152:			jrz	format_ch
153:	;================================================================
154:	;	音符データ設定
155:	;================================================================
156:	onp_set:	pushu	y
157:			mv	y,mml_data1	; 音程データ先頭アドレス
158:			cmp	a,'#'
159:			jmz	onp_skip	; シャープ？
160:			mv	y,mml_data2	; シャープ音程データ先頭アドレス
161:			mv	a,[x++]
162:	onp_skip:	sub	a,'A'
163:			cmp	a,7
164:			jmc	onp_skip2
165:			add	y,a
166:			mv	a,[y]
167:			mv	il,a		; 音符に対応した音程データを計算
168:			popu	y
169:	onp_len:	mv	a,[x++]
170:			sub	a,'0'
171:			cmp	a,10
172:			jrc	onp_len_sk2	; 音符の後に音長の指定がある
173:			sub	a,'U'-'0'
174:			cmp	a,6
175:			jmc	onp_len_sk
176:			add	a,10
177:			jr	onp_len_sk2
178:	onp_len_sk:	mv	a,[(!length_adr)]
179:			dec	x		; デフォルトの音長
180:	onp_len_sk2:	pushu	a		; 音長取得
181:			mv	a,[format_data]
182:			cmp	a,0
183:			popu	a
184:			jmz	onp_len_sk3
185:			mv	[(!length_adr)],a	; length デフォルト設定
186:	onp_len_sk3:	add	a,il
187:			mv	[y++],a		; データセット
188:			cmp	(!oct_flg),010h
189:			jmc	mml_conv_lp
190:			mv	a,(!oct_flg)
191:			mv	(!oct_flg),0ffh
192:			jr	oct_ch_s
193:	onp_skip2:	popu	y
194:			jr	mml_conv_lp
195:	;----------------------------------------------------------------
196:	;	休符設定
197:	;----------------------------------------------------------------
198:	kyuufu:		mv	il,0
199:			jr	onp_len
200:	;----------------------------------------------------------------
201:	;	終了処理
202:	;----------------------------------------------------------------
203:	mml_conv_exit_c:dec	x
204:	mml_conv_exit:	mv	a,0ffh
205:			mv	[y++],a
206:			ret			; MMLデータ解析終了
207:	;----------------------------------------------------------------
208:	;	音長設定
209:	;----------------------------------------------------------------
210:	len_ch:		mv	a,[x]
211:			sub	a,'0'
212:			cmp	a,0ah
213:			jrc	len_sk
214:			sub	a,'U'
215:			cmp	a,6
216:			jmc	mml_conv_lp
217:			add	a,10
218:	len_sk:		mv	[(!length_adr)],a
219:			inc	x
220:			jr	mml_conv_lp
221:	;----------------------------------------------------------------
222:	format_ch:	mv	a,[x]
223:			sub	a,'0'
224:			jrc	format_sk
225:			mv	[format_data],a
226:	format_sk:	inc	x
227:			jr	mml_conv_lp
228:	;----------------------------------------------------------------
229:	;	パート変更処理
230:	;----------------------------------------------------------------
231:	part_ch:	pushu	x
232:			mv	a,0ffh
233:			mv	[y++],a
234:			mv	x,[MML_data_adr]
235:			add	x,ba,16
236:			add	x,ba
237:			mv	[MML_data_adr],x
238:			mv	[x],y
239:			mv	x,(!octerve_adr)
240:			inc	x
241:			inc	x
242:			mv	(!octerve_adr),x
243:			mv	x,(!length_adr)
244:			inc	x
245:			inc	x
246:			mv	(!length_adr),x
247:			popu	x
248:			jr	mml_conv_lp
249:	;----------------------------------------------------------------
250:	;	テンポ設定
251:	;----------------------------------------------------------------
252:	temp_ch:	mv	a,[x]
253:			sub	a,30h
254:			cmp	a,0ah
255:			jmc	mml_conv_lp
256:			add	a,0d0h
257:			mv	[y++],a
258:			inc	x
259:			jr	mml_conv_lp
260:	;----------------------------------------------------------------
261:	temp2_ch:	mv	il,0
262:			mv	a,0dfh
263:			mv	[y++],a
264:	temp2_lp1:	mv	a,[x]
265:			sub	a,30h
266:			cmp	a,10
267:			jrnc	temp2_sk1
268:			pushu	a
269:			mv	a,il
270:			add	a,a
271:			add	a,a
272:			add	il,a
273:			add	il,il
274:			popu	a
275:			add	il,a
276:			inc	x
277:			jr	temp2_lp1
278:	temp2_sk1:	mv	[y++],il
279:			jp	mml_conv_lp
280:	;----------------------------------------------------------------
281:	;	オクターブ設定
282:	;----------------------------------------------------------------
283:	oct_ch:		mv	a,[x++]
284:			sub	a,30h
285:	oct_ch_s:	cmp	a,10
286:			jpnc	mml_conv_lp
287:			mv	[(!octerve_adr)],a
288:			add	a,0e0h
289:			mv	[y++],a
290:			jp	mml_conv_lp
291:	;----------------------------------------------------------------
292:	oct_1up:	mv	(!oct_flg),[(!octerve_adr)]
293:	;----------------------------------------------------------------
294:	oct_up:		mv	a,[(!octerve_adr)]
295:			inc	a
296:			jr	oct_ch_s
297:	;----------------------------------------------------------------
298:	oct_1dw:	mv	(!oct_flg),[(!octerve_adr)]
299:	;----------------------------------------------------------------
300:	oct_dw:		mv	a,[(!octerve_adr)]
301:			dec	a
302:			jr	oct_ch_s
303:	;================================================================
304:	;	データ
305:	;================================================================
306:	;		00 R	60 F	C0 B
307:	;		10 C	70 #F	D0 T	DF nn TEMPNN
308:	;		20 #C	80 G	E0 O	EE DOWN EF UP
309:	;		30 D	90 #G	F0 reserve
310:	;		40 #D	A0 A
311:	;		50 #E	B0 #A	FF END
312:	;----------------------------------------------------------------
313:	mml_data1:	db	0a0h		;a
314:			db	0c0h		;b
315:			db	010h		;c
316:			db	030h		;d
317:			db	050h		;e
318:			db	060h		;f
319:			db	080h		;g
320:	mml_data2:	db	0b0h		;#a
321:			db	010h		;#b
322:			db	020h		;#c
323:			db	040h		;#d
324:			db	050h		;#e
325:			db	070h		;#f
326:			db	090h		;#g
327:	;----------------------------------------------------------------
328:	not_data:	db	0ffh
329:	octerve:	db	3
330:	length:		db	5
331:	octerve2:	db	3
332:	length2:	db	5
333:	octerve3:	db	3
334:	length3:	db	5
335:	MML_data_adr:	ds		3
336:	format_data:	db	1
337:			endl
338:	;----------------------------------------------------------------
339:	;	初期設定 1
340:	;----------------------------------------------------------------
341:			jr	init2
342:	init1:		mv	y,0
343:			mv	[part1+o_count],y	; 音程カウンタ reset
344:			mv	[part2+o_count],y	; 音程カウンタ reset
345:			mv	[part3+o_count],y	; 音程カウンタ reset
346:			mv	a,2
347:			mv	[part1+oct],a		; オクターブ初期化
348:			mv	[part2+oct],a		; オクターブ初期化
349:			mv	[part3+oct],a		; オクターブ初期化
350:			retf
351:	;----------------------------------------------------------------
352:	;	初期設定 2
353:	;----------------------------------------------------------------
354:	init2:		mv	i,0
355:			mv	[part1+onp],i		; 音長カウンタ reset
356:			mv	[part2+onp],i		; 音長カウンタ reset
357:			mv	[part3+onp],i		; 音長カウンタ reset
358:			mv	y,[part1+data_s_adr]
359:			mv	[part1+data_adr],y	; データアドレスセット
360:			mv	y,[part2+data_s_adr]
361:			mv	[part2+data_adr],y	; データアドレスセット
362:			mv	y,[part3+data_s_adr]
363:			mv	[part3+data_adr],y	; データアドレスセット
364:	;----------------------------------------------------------------
365:	;	メインルーチン
366:	;----------------------------------------------------------------
367:	main2:		mv	x,part1
368:			call	mml
369:			mv	x,part2
370:			call	mml
371:			mv	x,part3
372:			call	mml		; 各パートデータセット
373:	;
374:			mv	a,0
375:			mv	b,a
376:			mv	a,[part1+l_count]
377:			mv	(part_c),[part2+l_count]
378:			cmp	(part_c),0
379:			jrz	main2_skip1
380:			cmp	(part_c),a
381:			jrnc	main2_skip1
382:			mv	a,(part_c)
383:	main2_skip1:	mv	(part_c),[part3+l_count]
384:			cmp	(part_c),0
385:			jrz	main2_skip2
386:			cmp	(part_c),a
387:			jrnc	main2_skip2
388:			mv	a,(part_c)
389:	main2_skip2:	cmp	a,0
390:			jrz	exit		; a = 最短音長（0＝END）
391:			mv	il,a
392:	;
393:			mv	a,[part1+l_count]
394:			sub	a,il
395:			mv	[part1+l_count],a
396:			mv	a,[part2+l_count]
397:			sub	a,il
398:			mv	[part2+l_count],a
399:			mv	a,[part3+l_count]
400:			sub	a,il
401:			mv	[part3+l_count],a
402:	;					; 最短分減算
403:			add	i,i		; ×4
404:			mv	a,[temp]	; テンポ（微調整）
405:			mv	x,0
406:	main2_lp1:	add	i,i
407:			rc
408:			shr	a
409:			jrnc	main2_skip	; x = ba * il
410:			add	x,i
411:	main2_skip:	cmp	a,0
412:			jmz	main2_lp1
413:			mv	[count],x
414:	;
415:			mv	(part_c),0
416:			mv	y,count1
417:			mv	a,[part1+onp]
418:			inc	a
419:			jrz	p1_skip
420:			dec	a
421:			jrz	p1_skip
422:			mv	ba,[part1+o_count]
423:			mv	[y++],ba
424:			inc	(part_c)
425:	p1_skip:	mv	a,[part2+onp]
426:			inc	a
427:			jrz	p2_skip
428:			dec	a
429:			jrz	p2_skip
430:			mv	ba,[part2+o_count]
431:			mv	[y++],ba
432:			inc	(part_c)
433:	p2_skip:	mv	a,[part3+onp]
434:			inc	a
435:			jrz	p3_skip
436:			dec	a
437:			jrz	p3_skip
438:			mv	ba,[part3+o_count]
439:			mv	[y++],ba
440:			inc	(part_c)
441:	p3_skip:	mv	x,[count]
442:			mv	ba,[count1]
443:			mv	i,ba
444:			mv	y,i
445:	;----------------------------------------------------------------
446:	;	3音処理設定
447:	;----------------------------------------------------------------
448:			mv	[!beep_out3!part1_co1+1],ba
449:			mv	[!beep_out3!part2_co2+1],i
450:			mv	[!beep_out3!part2_co1+1],i
451:			mv	[!beep_out3!part3_co1+1],y
452:			mv	[!beep_out3!part3_co2+1],y
453:			mv	[!beep_out3!part3_co3+1],y
454:			mv	[!beep_out3!part3_co4+1],y
455:			dec	(part_c)
456:			jpz	beep_out3
457:			mv	i,[count2]
458:	;----------------------------------------------------------------
459:	;	2音処理設定
460:	;----------------------------------------------------------------
461:			mv	[!beep_out3!part2_co2+1],i
462:			mv	[!beep_out3!part2_co1+1],i
463:			dec	i
464:			dec	i
465:			dec	i
466:			dec	(part_c)
467:			jpz	beep_out3
468:			mv	ba,[count3]
469:	;----------------------------------------------------------------
470:	;	単音処理設定
471:	;----------------------------------------------------------------
472:			mv	[!beep_out3!part1_co1+1],ba
473:			dec	ba
474:			dec	ba
475:			dec	ba
476:			dec	(part_c)
477:			jpz	beep_out3
478:	;----------------------------------------------------------------
479:	;	無音処理設定
480:	;----------------------------------------------------------------
481:			jr	beep_out0
482:	;----------------------------------------------------------------
483:	exit:		retf
484:	;----------------------------------------------------------------
485:	;	データ解析
486:	;----------------------------------------------------------------
487:	;
488:	;ret:		x = part parameter address
489:	;		cy = 1  data end
490:	;		cy = 0i = 音程 [x+o_count]  テンポ [temp]
491:	;		a = 音長 [x+l_count]  音符 [x+onp]
492:	mml:		pushu	y		; y = 保存 :x = part paramater address  オクターブ [x+oct]
493:			mv	a,[x+onp]
494:			cmp	a,0ffh
495:			jrz	mml_exit
496:			mv	a,[x+l_count]
497:			cmp	a,0
498:			jrnz	skip_exit
499:			mv	y,[x]		; MMLデータアドレス
500:	mml_loop:	mv	a,[y++]
501:			cmp	a,0ffh
502:			jrz	mml_exit
503:			cmp	a,0dfh
504:			jrz	temp_ch
505:			cmp	a,0e0h
506:			jrc	mml_onp
507:	;----------------------------------------------------------------
508:	oct_ch:		and	a,0fh
509:			mv	[x+oct],a	; オクターブのセット
510:			jr	mml_loop
511:	;----------------------------------------------------------------
512:	temp_ch:	mv	a,[y++]
513:			mv	[temp],a	; テンポのセット
514:			jr	mml_loop
515:	;----------------------------------------------------------------
516:	mml_exit:	mv	[x+onp],a	; 音符コード記憶
517:			mv	a,0
518:			mv	[x+l_count],a
519:			popu	y
520:			sc
521:			ret
522:	;----------------------------------------------------------------
523:	skip_exit:	mv	i,[x+o_count]
524:			popu	y
525:			rc
526:			ret
527:	;----------------------------------------------------------------
528:	mml_onp:	mv	[x],y		; MMLデータアドレス
529:	;(3byte)
530:			pushu	a
531:			and	a,0f0h
532:			ror	a		; ローテイトライト（÷2）
533:			ror	a		; ローテイトライト（÷2）
534:			mv	il,a
535:			ror	a		; ローテイトライト（÷2）
536:			ror	a		; ローテイトライト（÷2）
537:			mv	[x+onp],a	; 音符コード記憶
538:			add	a,il		; 1+4
539:			add	a,a		; ×2（a÷16×10）
540:			mv	y,mml_data	; mml tone data
541:			add	y,a
542:			mv	a,[x+oct]	; オクターブ（O）
543:			add	a,a		; ×2
544:			add	y,a
545:			mv	i,[y]		; 音程カウンタset
546:			mv	[x+o_count],i	; 音程カウンタset
547:	;----------------------------------------------------------------
548:			popu	a
549:			and	a,0fh
550:			mv	y,length_data
551:			add	y,a
552:			mv	a,[y]		; 音長カウンタ
553:			mv	[x+l_count],a
554:			popu	y
555:			rc
556:			ret
557:	;================================================================
558:	;	音発生ルーチン　1loop = 37state 48.1uS
559:	;================================================================
560:	;	音発生（0音）
561:	;----------------------------------------------------------------
562:	;		x = 発声音長カウンタ　78state
563:	beep_out0:	local
564:	loop:		mv	i,4		;6 6*(a)+2
565:	loop1:		dec	i		;6
566:			jrnz	loop1		;4,6
567:			mv	(!beep),2h	;8 ブザーOFF
568:			nop			;2
569:			nop			;2
570:			nop			;2
571:	b_ent:		dec	x		;6
572:			jrnz	loop		;4,6
573:			jp	!main2
574:			endl
575:	;----------------------------------------------------------------
576:	;	音発生（3音）
577:	;----------------------------------------------------------------
578:	;		ba= part1 カウンタ
579:	;		i = part2 カウンタ
580:	;		y = part3 カウンタ
581:	;		x = 発声音長カウンタ　78state
582:	beep_out3:	local
583:	;
584:			mv	[part1_co1+1],ba
585:			mv	[part2_co1+1],i
586:			mv	[part2_co2+1],i
587:			mv	[part3_co1+1],y
588:			mv	[part3_co2+1],y
589:			mv	[part3_co3+1],y
590:			mv	[part3_co4+1],y
591:	loop:		dec	ba		;6
592:			jrnz	skip1		;4,6
593:	part1_co1:	mv	ba,0		;6
594:			mv	(!beep),2h	;6 ブザーOFF
595:			dec	i		;6
596:			jrnz	skip2		;4,6
597:	part2_co1:	mv	i,0		;6
598:			dec	y		;6
599:			jrnz	skip3		;4,6
600:	part3_co1:	mv	y,0		;8
601:			mv	(!beep),12h	;8 ブザーON
602:			dec	x		;6
603:			jrnz	loop		;4,6
604:			jr	exit
605:	;
606:	skip3:		nop			;2
607:			nop			;2
608:			nop			;2
609:			mv	(!beep),12h	;8 ブザーON
610:			dec	x		;6
611:			jrnz	loop		;4,6
612:			jr	exit
613:	;
614:	skip2:		nop			;2
615:			nop			;2
616:			dec	y		;6
617:			jrnz	skip3		;4,6
618:	part3_co2:	mv	y,0		;8
619:			mv	(!beep),12h	;8 ブザーON
620:			dec	x		;6
621:			jrnz	loop		;4,6
622:			jr	exit
623:	;
624:	skip1:		nop			;2
625:			nop			;2
626:			mv	(!beep),2h	;8 ブザーOFF
627:			dec	i		;6
628:			jrnz	skip12		;4,6
629:	part2_co2:	mv	i,0		;6
630:			dec	y		;6
631:			jrnz	skip3		;4,6
632:	part3_co3:	mv	y,0		;8
633:			mv	(!beep),12h	;8 ブザーON
634:			dec	x		;6
635:			jrnz	loop		;4,6
636:			jr	exit
637:	;
638:	skip12:		nop			;2
639:			nop			;2
640:			dec	y		;6
641:			jrnz	skip13		;4,6
642:	part3_co4:	mv	y,0		;8
643:			mv	(!beep),12h	;8 ブザーON
644:			dec	x		;6
645:			jrnz	loop		;4,6
646:			jr	exit
647:	;
648:	skip13:		nop			;2
649:			nop			;2
650:			nop			;2
651:			nop			;2
652:			nop			;2
653:			nop			;2
654:	;
655:			dec	x		;6
656:			jrnz	loop		;4,6
657:	exit:		mv	(!beep),2h	;8 ブザーOFF
658:			jp	!main2
659:			endl
660:	;================================================================
661:	;	データ
662:	;================================================================
663:	;----------------------------------------------------------------
664:	;	音程データ
665:	;----------------------------------------------------------------
666:	mml_data:	;	O0	O1	O2	O3	O4
667:			dw	000h,000h,000h,000h,000h	;R
668:			dw	12Eh,097h,04Ch,026h,013h	;C
669:			dw	11Dh,08Fh,048h,024h,012h	;#C
670:			dw	10Dh,087h,044h,022h,011h	;D
671:			dw	0FEh,07Fh,040h,020h,010h	;#D
672:			dw	0F0h,078h,03Ch,01Eh,00Fh	;E
673:			dw	0E2h,071h,039h,01Dh,00Fh	;F
674:			dw	0D6h,06Bh,036h,01Bh,00Eh	;#F
675:			dw	0CAh,065h,033h,01Ah,00Dh	;G
676:			dw	0BEh,05Fh,030h,018h,00Ch	;#G
677:			dw	0B4h,05Ah,02Dh,017h,00Ch	;A
678:			dw	0AAh,055h,02Bh,016h,00Bh	;#A
679:			dw	0A0h,050h,028h,014h,00Ah	;B
680:	;
681:	length_data:	db	003h,006h,009h,00Ch,012h
682:			db	018h,024h,030h,048h,060h
683:			db	002h,004h,006h,010h,020h,001h
684:	;----------------------------------------------------------------
685:	temp:		db	1		; テンポ（コマンド内）
686:	count:		dp	0		; 発声音長カウンタ(3byte)
687:	count1:		db	0,0		; 音程カウンタ１
688:	count2:		db	0,0		; 音程カウンタ２
689:	count3:		db	0,0,0		; 音程カウンタ３
690:	;
691:	part1:		ds	16		; 音長カウンタ
692:	part2:		ds	16		; 音長カウンタ
693:	part3:		ds	16		; 音長カウンタ
694:	;
695:	r_flg:		ds	1
696:	data_buff:	ds	1		;
697:	;
698:	;----------------------------------------------------------------
699:			end
