# PLAYX 解析

SHARP PC-E500用ブザー音楽ドライバ「PLAYX」の逆アセンブル解析結果です。

PLAYXは、1bit内蔵スピーカーで3声の和音再生を実現するBASIC拡張コマンドです。

---

## ファイル構成

- `playx_disassembly.asm`  
  構造重視の逆アセンブル

- `playx_annotated.asm`  
  コメント付き解析版

- `PLAYX_full_disasm.txt`  
  元の逆アセンブル出力（保存用）

- `playx_structure.md`  
  内部構造まとめ

- `playx_tables.md`  
  音程・音符長テーブル

- `playx_notes.md`  
  解析メモ

---

## 概要

PLAYXは以下の構成を持ちます：

- BASICコマンド登録
- MMLパーサ内蔵
- 音程・音符長計算
- 自己書き換えによる声部ルーティング
- 時分割3声再生

自己書き換えコードにより命令の即値を書き換え、
各声部の音程を高速に切り替えることで和音を実現しています。

---

## 注意

- オリジナルバイナリの解析に基づく
- CPU: SC62015
- 一部は推定を含む可能性があります

---
