; Friendly-monster detail-screen portrait tiles (bank $3c).
;
; Seven per-monster tile sets, 128 tiles ($800 bytes) each, laid out
; contiguously at $3c:$4000,$4800,..,$7000 (ids 0..6 of the SUMMON enum).
; LoadMonsterPortrait (src/monster_detail.asm) picks one via
; MonsterPortraitTileTable[[$cfd9]] and copies $800 bytes to VRAM $8800
; (OBJ tile $80+ / BG $8800 addressing). The portrait is then drawn as a
; metasprite over a BG body -- see docs/monster_detail_screen.md.
;
; Carved from analyzed.asm. The original static-pass sections were split
; mid-sheet with $00-padded gaps (blank tiles); re-cut here on the real
; $800 monster boundaries as editable 2bpp sheets.

SECTION "Monster portrait tiles", ROMX[$4000], BANK[$3c]

MonsterPortraitTiles_Tiger:
	INCBIN "assets/monster_portrait/tiger.2bpp"
MonsterPortraitTiles_Mocchi:
	INCBIN "assets/monster_portrait/mocchi.2bpp"
MonsterPortraitTiles_Hare:
	INCBIN "assets/monster_portrait/hare.2bpp"
MonsterPortraitTiles_Gali:
	INCBIN "assets/monster_portrait/gali.2bpp"
MonsterPortraitTiles_Golem:
	INCBIN "assets/monster_portrait/golem.2bpp"
MonsterPortraitTiles_Suezo:
	INCBIN "assets/monster_portrait/suezo.2bpp"
MonsterPortraitTiles_Phoenix:
	INCBIN "assets/monster_portrait/phoenix.2bpp"
