; Friendly-monster detail-screen portrait tiles (bank $3c).
;
; Seven per-monster tile sets, 128 tiles ($800 bytes) each, laid out
; contiguously at $3c:$4000,$4800,..,$7000 (ids 0..6 of the SUMMON enum).
; LoadMonsterPortrait (src/monster_detail.asm) picks one via
; MonsterPortraitTileTable[[$cfd9]] and copies $800 bytes to VRAM $8800
; (OBJ tile $80+ / BG $8800 addressing). The portrait is then drawn as a
; metasprite over a BG body -- see docs/monster_detail_screen.md.
;
; Editable source: assets/monster_portrait/monster_<name>/<...>.png --
; indexed sheets (each tile shown in its detail-screen palette); the 7x7
; BG maps in monster_detail.asm are DERIVED from them (layout monster7x7,
; docs/asset_source_model.md family G).

SECTION "Monster portrait tiles", ROMX[$4000], BANK[$3c]

MonsterPortraitTiles_Tiger:
	INCBIN "assets/monster_tiger/tiles.bin"
MonsterPortraitTiles_Mocchi:
	INCBIN "assets/monster_mocchi/tiles.bin"
MonsterPortraitTiles_Hare:
	INCBIN "assets/monster_hare/tiles.bin"
MonsterPortraitTiles_Gali:
	INCBIN "assets/monster_gali/tiles.bin"
MonsterPortraitTiles_Golem:
	INCBIN "assets/monster_golem/tiles.bin"
MonsterPortraitTiles_Suezo:
	INCBIN "assets/monster_suezo/tiles.bin"
MonsterPortraitTiles_Phoenix:
	INCBIN "assets/monster_phoenix/tiles.bin"
