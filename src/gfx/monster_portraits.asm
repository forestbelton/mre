; Friendly-monster detail-screen portrait tiles (bank $3c).
;
; Seven per-monster tile sets, 128 tiles ($800 bytes) each, laid out
; contiguously at $3c:$4000,$4800,..,$7000 (ids 0..6 of the SUMMON enum).
; LoadMonsterPortrait (src/monster_detail.asm) picks one via
; MonsterPortraitTileTable[[$cfd9]] and copies $800 bytes to VRAM $8800
; (OBJ tile $80+ / BG $8800 addressing). The portrait is then drawn as a
; metasprite over a BG body -- see docs/monster_detail_screen.md.
;
; Editable source: assets/summon/<name>.png (indexed sheet, each tile in its
; detail-screen palette) + <name>.tmx (the 7x7 BG arrangement and the static
; OBJ overlays as Tiled layers -- open it to see the complete portrait; the
; maps and metasprite lists in monster_detail.asm compile from it).
; See docs/asset_source_model.md.

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
