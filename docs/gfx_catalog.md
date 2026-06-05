# Traced graphics catalog

49 unidentified graphics sheets the analyzer classified as `gfx` (~239 KB), plus
1 already named. All 16 tiles (128 px) wide. Browse them together in
**`build/gfx_catalog.png`** (each scaled 3x and labelled). Fill in **Identification**
as you recognise them; once named we promote each from the analyzer's raw tiles
(`src/raw_gfx/`, INCBIN'd by `analyzed.asm`) into a named, hand-authored asset
under `src/gfx/` (e.g. `gfx/portrait/` or `gfx/screen/`).

| PNG | bank:addr | tiles | px | Notes / guess | Identification |
|---|---|---:|---|---|---|
| Data_02_40b1.png | $02:$40b1 | 256 | 128x128 |  |  |
| Data_0e_4000.png | $0e:$4000 | 318 | 128x160 |  |  |
| Data_0e_5800.png | $0e:$5800 | 24 | 128x16 |  |  |
| Data_0f_4d38.png | $0f:$4d38 | 128 | 128x64 |  |  |
| Data_0f_63ce.png | $0f:$63ce | 72 | 128x40 |  |  |
| Data_10_40b7.png | $10:$40b7 | 256 | 128x128 |  |  |
| Data_10_53b7.png | $10:$53b7 | 80 | 128x40 |  |  |
| Data_11_415c.png | $11:$415c | 144 | 128x72 |  |  |
| Data_11_4d5c.png | $11:$4d5c | 192 | 128x96 |  |  |
| Data_11_5c5c.png | $11:$5c5c | 192 | 128x96 |  |  |
| Data_11_6b5c.png | $11:$6b5c | 48 | 128x24 |  |  |
| Data_11_745c.png | $11:$745c | 144 | 128x72 |  |  |
| Data_14_436b.png | $14:$436b | 459 | 128x232 |  |  |
| Data_16_407f.png | $16:$407f | 800 | 128x400 |  |  |
| Data_17_6918.png | $17:$6918 | 128 | 128x64 |  |  |
| Data_19_46cb.png | $19:$46cb | 512 | 128x256 |  |  |
| Data_1a_4000.png | $1a:$4000 | 384 | 128x192 | sprite/character tiles (not a font) |  |
| Data_1a_5ae8.png | $1a:$5ae8 | 384 | 128x192 |  | PROMOTED -> assets/portrait/naji/ |
| Data_1b_4000.png | $1b:$4000 | 384 | 128x192 |  | PROMOTED -> assets/portrait/pashute/ |
| Data_1b_5c5d.png | $1b:$5c5d | 89 | 128x48 |  |  |
| Data_1b_645d.png | $1b:$645d | 231 | 128x120 |  |  |
| Data_1d_5b19.png | $1d:$5b19 | 384 | 128x192 |  | PROMOTED -> assets/portrait/rafaga/ |
| Data_1e_5be7.png | $1e:$5be7 | 128 | 128x64 |  | PROMOTED -> assets/portrait/tempest/ |
| Data_1e_64e8.png | $1e:$64e8 | 239 | 128x120 |  |  |
| Data_20_4000.png | $20:$4000 | 768 | 128x384 | VRAM tileset — full font + UI/decor tiles (confirmed) |  |
| Data_21_4000.png | $21:$4000 | 768 | 128x384 | likely VRAM tileset+font (768-tile, same shape as $20/$28) — confirm? |  |
| Data_22_4000.png | $22:$4000 | 768 | 128x384 | likely VRAM tileset+font (768-tile, same shape as $20/$28) — confirm? |  |
| Data_23_4000.png | $23:$4000 | 768 | 128x384 | likely VRAM tileset+font (768-tile, same shape as $20/$28) — confirm? |  |
| Data_24_4000.png | $24:$4000 | 384 | 128x192 |  |  |
| Data_25_4000.png | $25:$4000 | 384 | 128x192 |  |  |
| Data_26_4000.png | $26:$4000 | 69 | 128x40 |  |  |
| Data_26_4800.png | $26:$4800 | 256 | 128x128 |  |  |
| Data_26_6008.png | $26:$6008 | 255 | 128x128 |  |  |
| IntroBlankTiles.png | $27:$4000 | 256 | 128x128 | already named | IntroBlankTiles |
| Data_27_5ade.png | $27:$5ade | 338 | 128x176 |  |  |
| Data_28_4000.png | $28:$4000 | 768 | 128x384 | VRAM tileset — full font + UI/decor tiles (confirmed) |  |
| Data_29_4000.png | $29:$4000 | 768 | 128x384 | likely VRAM tileset+font (768-tile, same shape as $20/$28) — confirm? |  |
| Data_2a_4000.png | $2a:$4000 | 320 | 128x160 |  |  |
| Data_2a_5410.png | $2a:$5410 | 128 | 128x64 |  |  |
| Data_32_4613.png | $32:$4613 | 46 | 128x24 |  |  |
| Data_32_5613.png | $32:$5613 | 87 | 128x48 |  |  |
| Data_32_5dd3.png | $32:$5dd3 | 132 | 128x72 |  |  |
| Data_33_4000.png | $33:$4000 | 768 | 128x384 | likely VRAM tileset+font (768-tile, same shape as $20/$28) — confirm? |  |
| Data_38_501a.png | $38:$501a | 128 | 128x64 |  |  |
| Data_38_5c1a.png | $38:$5c1a | 64 | 128x32 |  |  |
| Data_38_641a.png | $38:$641a | 64 | 128x32 |  |  |
| Data_3b_4034.png | $3b:$4034 | 320 | 128x160 |  |  |
| Data_3c_68a1.png | $3c:$68a1 | 81 | 128x48 |  |  |
| Data_3d_5bcd.png | $3d:$5bcd | 143 | 128x72 |  |  |
| Data_3d_67ed.png | $3d:$67ed | 128 | 128x64 |  |  |
