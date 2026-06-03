; Tower in-room action engine -- bank $03 ($4000-$7fff).
;
; This is everything that runs *while you are inside a room*: the player
; avatar, monster AI, projectiles/FX, and breakable-crate handling. The static
; floor LAYOUT (walls, item placements) is built by src/layout.asm from the
; per-floor records in src/layout/roomNN.asm; this file animates what lives on
; top of it. See docs/room_engine.md for the full architecture.
;
; Architecture -- a tiny per-entity script VM:
;   * Up to 28 entities live in `wEntities` ($c7f9 / walked from $cc67), each a
;     $2a-byte (42) record. Byte +0 is the occupied/state flag.
;   * UpdateEntities ($4000, the public per-frame entry) walks all 28 slots; for
;     each occupied slot RunEntity swaps the record into the $ffb0.. HRAM shadow
;     (LoadEntityRegs) and enters RunEntityScript ($4042).
;   * RunEntityScript is a threaded interpreter: a=[de] (the script PC at field
;     +$18); `jp [EntityOpcodeTable + a*2]`. The 41-entry EntityOpcodeTable
;     ($4098) dispatches to the EntityOp_* handlers below; each reads its
;     operands, advances de, and tail-jumps back. EndEntityFrame ($404f) is the
;     per-frame "yield" that saves the record back. The bytecode the handlers
;     interpret is carved as readable source in src/entity_scripts.asm
;     ($71eb-$7d25) -- see docs/entity_scripts.md. The selectors below load a
;     script with `ld de, $7xxx` (the matching label is in entity_scripts.asm).
;   * SpawnEntity ($4593: A=type, D=Ypx, E=Xpx, BC=param) allocates a free slot
;     (FindFreeEntitySlot) and initialises it. The long run of routines from
;     ~$5938 on are per-type/per-state behaviour selectors that probe the world
;     (player position, floor tiles) and return the address of the next script
;     to run -- monster AI when they read tiles, the player avatar when they
;     read the joypad.
;
; Public API (called cross-bank via CallBankedHL):
;   UpdateEntities ($4000), BreakTileAtPixel ($44bb) / BreakTileAtCell ($44cb)
;   -- destroy a breakable crate cell and spawn its shard -- and RequestFloorExit
;   ($4a58), which sets the $c2d5 bit-7 floor-exit flag the main loop polls.
;
; Routines whose purpose is confidently identified carry curated names (in
; map.json labels[]); the rest keep auto-generated Func_03_xxxx / Data_03_xxxx
; names and are honest about being undecoded. This file is hand-editable: extract
; only appends map.json sections not already covered by a SECTION here.

SECTION "room_00c000", ROMX[$4000], BANK[$03]

UpdateEntities:
	ld a, [$c2db]
	ld [$c2dc], a
	ld c, $1c
	ld hl, $cc67
Func_03_400b:
	ld a, [hl]
	or a
	jr z, Func_03_4030
	call Func_00_1290
	ld b, a
	ld a, [$c2dc]
	or a
	jr nz, Func_03_4026
	ld a, [$c2e2]
	cp $03
	jr nz, Func_03_402a
	bit 3, b
	jr z, Func_03_402a
	jr Func_03_4030
Func_03_4026:
	bit 5, b
	jr z, Func_03_4030
Func_03_402a:
	ld a, b
	ldh [$ffe4], a
	call RunEntity
Func_03_4030:
	ld a, $2a
	rst $08
	dec c
	jr nz, Func_03_400b
	ret
RunEntity:
	push bc
	push hl
	call LoadEntityRegs
	ld hl, $ffc8
	ld a, [hl+]
	ld e, a
	ld d, [hl]
RunEntityScript:
	ld a, [de]
	add a, a
	ld c, a
	ld b, $00
	ld hl, $4098
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp hl
EndEntityFrame:
	ld hl, $ffc8
	ld a, e
	ld [hl+], a
	ld [hl], d
	ldh a, [$ffb0]
	or a
	jr z, Func_03_408c
	ld a, [$c2db]
	or a
	jr nz, Func_03_4071
	ldh a, [$ffd0]
	bit 7, a
	jr z, Func_03_4077
	ldh a, [$ffb3]
	cp $ff
	jr z, Func_03_4077
	call Func_03_590e
	jr Func_03_4077
Func_03_4071:
	ldh a, [$ffe4]
	bit 5, a
	jr z, Func_03_407f
Func_03_4077:
	ld a, $01
	ld hl, Func_01_6d48
	call CallBankedHL
Func_03_407f:
	ldh a, [$ffb1]
	or a
	jr z, Func_03_408c
	ld a, $04
	ld hl, Func_04_4000
	call CallBankedHL
Func_03_408c:
	ldh a, [$ffe5]
	ld l, a
	ldh a, [$ffe6]
	ld h, a
	call SaveEntityRegs
	pop hl
	pop bc
	ret

SECTION "room_00c098", ROMX[$4098], BANK[$03]

EntityOpcodeTable:
	db $ea, $40, $f1, $40, $f9, $40, $02, $41, $0e, $41, $27, $41, $43, $41, $93, $41
	db $a4, $41, $ac, $41, $c8, $41, $b9, $41, $8b, $42, $37, $42, $46, $42, $5b, $42
	db $68, $42, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $6f, $42, $7b, $42
	db $01, $42, $0e, $42, $1d, $42, $2a, $42, $e0, $41, $ec, $41, $00, $00, $00, $00
	db $8f, $42, $99, $42, $a5, $42, $b1, $42, $bd, $42, $c9, $42, $d4, $42, $df, $42
	db $ed, $42

SECTION "room_00c0ea", ROMX[$40ea], BANK[$03]

EntityOp_Despawn:
	ld a, $00
	ldh [$ffb0], a
	jp EndEntityFrame
EntityOp_SetType:
	inc de
	ld a, [de]
	ldh [$ffb3], a
	inc de
	jp RunEntityScript
EntityOp_VelXZero:
	inc de
	xor a
	ldh [$ffbf], a
	ldh [$ffc0], a
	jp RunEntityScript
EntityOp_SetVelX:
	inc de
	ld a, [de]
	ldh [$ffbf], a
	inc de
	ld a, [de]
	ldh [$ffc0], a
	inc de
	jp RunEntityScript
EntityOp_VelXIndexed:
	inc de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	ldh a, [$ffd1]
	and $07
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hl+]
	ldh [$ffbf], a
	ld a, [hl]
	ldh [$ffc0], a
	jp RunEntityScript
EntityOp_SetXFlip:
	inc de
	ld hl, $ffb6
	ld a, [de]
	inc de
	cp $00
	jr z, Func_03_413e
	cp $01
	jr z, Func_03_4139
	bit 7, [hl]
	jr nz, Func_03_413e
Func_03_4139:
	set 7, [hl]
	jp RunEntityScript
Func_03_413e:
	res 7, [hl]
	jp RunEntityScript
EntityOp_SetFacing:
	inc de
	ld hl, $ffb6
	ld a, [de]
	inc de
	cp $ff
	jr z, Func_03_4160
	cp $fe
	jr z, Func_03_415a
	ld b, a
	ld a, [hl]
	and $fc
	or b
	ld [hl], a
	jp RunEntityScript
Func_03_415a:
	bit 7, [hl]
	jr z, Func_03_416f
	jr Func_03_4178
Func_03_4160:
	ld a, [hl]
	and $03
	cp $02
	jr z, Func_03_4181
	cp $03
	jr z, Func_03_418a

SECTION "room_00c16b", ROMX[$416b], BANK[$03]

Data_03_416b:
	db $fe, $00, $28, $09

SECTION "room_00c16f", ROMX[$416f], BANK[$03]

Func_03_416f:
	ld a, [hl]
	and $fc
	or $00
	ld [hl], a
	jp RunEntityScript
Func_03_4178:
	ld a, [hl]
	and $fc
	or $01
	ld [hl], a
	jp RunEntityScript
Func_03_4181:
	ld a, [hl]
	and $fc
	or $03
	ld [hl], a
	jp RunEntityScript
Func_03_418a:
	ld a, [hl]
	and $fc
	or $02
	ld [hl], a
	jp RunEntityScript
EntityOp_Gfx:
	inc de
	ld a, [de]
	ld b, a
	push de
	ld a, $04
	ld hl, Func_04_40e2
	call CallBankedHL
	pop de
	inc de
	jp RunEntityScript
EntityOp_SetTimer:
	inc de
	ld a, [de]
	ldh [$ffc6], a
	inc de
	jp RunEntityScript

SECTION "room_00c1ac", ROMX[$41ac], BANK[$03]

EntityOp_TimerTick:
	inc de
	ld c, $c6
	ldh a, [c]
	or a
	jp z, RunEntityScript
	dec a
	ldh [c], a
	jp EndEntityFrame

SECTION "room_00c1b9", ROMX[$41b9], BANK[$03]

EntityOp_WaitTimer:
	ld c, $c6
	ldh a, [c]
	or a
	jr z, Func_03_41c4
	dec a
	ldh [c], a
	jp EndEntityFrame
Func_03_41c4:
	inc de
	jp RunEntityScript
EntityOp_LoopTimer:
	inc de
	ld c, $c6
	ldh a, [c]
	or a
	jp z, Func_03_41db
	dec a
	ldh [c], a
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld d, a
	ld e, b
	jp EndEntityFrame
Func_03_41db:
	inc de
	inc de
	jp RunEntityScript

SECTION "room_00c1e0", ROMX[$41e0], BANK[$03]

EntityOp_SetVelY:
	inc de
	ld a, [de]
	ldh [$ffc1], a
	inc de
	ld a, [de]
	ldh [$ffc2], a
	inc de
	jp RunEntityScript

SECTION "room_00c1ec", ROMX[$41ec], BANK[$03]

EntityOp_WaitCounter:
	ld hl, $ffc1
	ld a, [hl+]
	ld c, a
	ld a, [hl-]
	ld b, a
	or c
	jr z, Func_03_41fd
	dec bc
	ld a, c
	ld [hl+], a
	ld [hl], b
	jp EndEntityFrame
Func_03_41fd:
	inc de
	jp RunEntityScript
EntityOp_LoadB8:
	inc de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	ld a, [hl]
	ldh [$ffb8], a
	jp RunEntityScript

SECTION "room_00c20e", ROMX[$420e], BANK[$03]

EntityOp_AndB8:
	inc de
	ld c, $b8
	ld a, [de]
	ld b, a
	ldh a, [c]
	and b
	ldh [c], a
	call Func_03_42fb
	inc de
	jp RunEntityScript

SECTION "room_00c21d", ROMX[$421d], BANK[$03]

EntityOp_TestB8:
	inc de
	ld a, [de]
	ld b, a
	ldh a, [$ffb8]
	and b
	call Func_03_42fb
	inc de
	jp RunEntityScript

SECTION "room_00c22a", ROMX[$422a], BANK[$03]

EntityOp_CmpB8:
	inc de
	ld a, [de]
	ld b, a
	ldh a, [$ffb8]
	cp b
	call Func_03_42fb
	inc de
	jp RunEntityScript

SECTION "room_00c237", ROMX[$4237], BANK[$03]

EntityOp_SpawnRel:
	inc de
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	inc de
	call SpawnEntityRelative
	jp RunEntityScript

SECTION "room_00c246", ROMX[$4246], BANK[$03]

EntityOp_SetFlag2:
	inc de
	ld hl, $ffb6
	ld a, [de]
	cp $01
	jr z, Func_03_4255
	res 2, [hl]
	inc de
	jp RunEntityScript
Func_03_4255:
	set 2, [hl]
	inc de
	jp RunEntityScript

SECTION "room_00c25b", ROMX[$425b], BANK[$03]

EntityOp_BeginAction:
	inc de
	ld hl, $ffb4
	set 7, [hl]
	ld a, $14
	ldh [$ffc7], a
	jp RunEntityScript
EntityOp_UpdateAction:
	inc de
	call UpdateActionTimer
	jp RunEntityScript
EntityOp_Call:
	inc de
	ld hl, $4042
	push hl
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	jp hl
EntityOp_CallBank0:
	inc de
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	call Func_00_1150
	jp RunEntityScript
EntityOp_Yield:
	inc de
	jp EndEntityFrame
EntityOp_Jump:
	inc de
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld d, a
	ld e, b
	jp RunEntityScript
EntityOp_JrBusy:
	ldh a, [$ffb7]
	bit 0, a
	jr nz, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript
EntityOp_JrFree:
	ldh a, [$ffb7]
	bit 0, a
	jr z, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript
EntityOp_JrHit:
	ldh a, [$ffb7]
	bit 1, a
	jr nz, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript

SECTION "room_00c2bd", ROMX[$42bd], BANK[$03]

EntityOp_JrNoHit:
	ldh a, [$ffb7]
	bit 1, a
	jr z, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript
EntityOp_JrTimer0:
	ldh a, [$ffc6]
	or a
	jr z, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript
EntityOp_JrTimerNz:
	ldh a, [$ffc6]
	or a
	jr nz, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript

SECTION "room_00c2df", ROMX[$42df], BANK[$03]

EntityOp_JrB8Eq:
	inc de
	ldh a, [$ffb8]
	ld b, a
	ld a, [de]
	cp b
	jr z, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript

SECTION "room_00c2ed", ROMX[$42ed], BANK[$03]

EntityOp_JrB8Ne:
	inc de
	ldh a, [$ffb8]
	ld b, a
	ld a, [de]
	cp b
	jr nz, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript

SECTION "room_00c2fb", ROMX[$42fb], BANK[$03]

Func_03_42fb:
	ld a, $00
	jr nc, Func_03_4301
	set 1, a
Func_03_4301:
	jr nz, Func_03_4305
	set 0, a
Func_03_4305:
	ldh [$ffb7], a
	ret
LoadEntityRegs:
	ld a, l
	ldh [$ffe5], a
	ld a, h
	ldh [$ffe6], a
	ld a, [hl+]
	ldh [$ffb0], a
	ld a, [hl+]
	ldh [$ffb1], a
	ld a, [hl+]
	ldh [$ffb2], a
	ld a, [hl+]
	ldh [$ffb3], a
	ld a, [hl+]
	ldh [$ffb4], a
	ld a, [hl+]
	ldh [$ffb5], a
	ld a, [hl+]
	ldh [$ffb6], a
	ld a, [hl+]
	ldh [$ffb7], a
	ld a, [hl+]
	ldh [$ffb8], a
	ld a, [hl+]
	ldh [$ffb9], a
	ld a, [hl+]
	ldh [$ffba], a
	ld a, [hl+]
	ldh [$ffbb], a
	ld a, [hl+]
	ldh [$ffbc], a
	ld a, [hl+]
	ldh [$ffbd], a
	ld a, [hl+]
	ldh [$ffbe], a
	ld a, [hl+]
	ldh [$ffbf], a
	ld a, [hl+]
	ldh [$ffc0], a
	ld a, [hl+]
	ldh [$ffc1], a
	ld a, [hl+]
	ldh [$ffc2], a
	ld a, [hl+]
	ldh [$ffc3], a
	ld a, [hl+]
	ldh [$ffc4], a
	ld a, [hl+]
	ldh [$ffc5], a
	ld a, [hl+]
	ldh [$ffc6], a
	ld a, [hl+]
	ldh [$ffc7], a
	ld a, [hl+]
	ldh [$ffc8], a
	ld a, [hl+]
	ldh [$ffc9], a
	ld a, [hl+]
	ldh [$ffca], a
	ld a, [hl+]
	ldh [$ffcb], a
	ld a, [hl+]
	ldh [$ffcc], a
	ld a, [hl+]
	ldh [$ffcd], a
	ld a, [hl+]
	ldh [$ffce], a
	ld a, [hl+]
	ldh [$ffcf], a
	ld a, [hl+]
	ldh [$ffd0], a
	ld a, [hl+]
	ldh [$ffd1], a
	ld a, [hl+]
	ldh [$ffd2], a
	ld a, [hl+]
	ldh [$ffd3], a
	ld a, [hl+]
	ldh [$ffd4], a
	ld a, [hl+]
	ldh [$ffd5], a
	ld a, [hl+]
	ldh [$ffd6], a
	ld a, [hl+]
	ldh [$ffd7], a
	ld a, [hl+]
	ldh [$ffd8], a
	ld a, [hl+]
	ldh [$ffd9], a
	ret
SaveEntityRegs:
	ldh a, [$ffb0]
	ld [hl+], a
	ldh a, [$ffb1]
	ld [hl+], a
	ldh a, [$ffb2]
	ld [hl+], a
	ldh a, [$ffb3]
	ld [hl+], a
	ldh a, [$ffb4]
	ld [hl+], a
	ldh a, [$ffb5]
	ld [hl+], a
	ldh a, [$ffb6]
	ld [hl+], a
	ldh a, [$ffb7]
	ld [hl+], a
	ldh a, [$ffb8]
	ld [hl+], a
	ldh a, [$ffb9]
	ld [hl+], a
	ldh a, [$ffba]
	ld [hl+], a
	ldh a, [$ffbb]
	ld [hl+], a
	ldh a, [$ffbc]
	ld [hl+], a
	ldh a, [$ffbd]
	ld [hl+], a
	ldh a, [$ffbe]
	ld [hl+], a
	ldh a, [$ffbf]
	ld [hl+], a
	ldh a, [$ffc0]
	ld [hl+], a
	ldh a, [$ffc1]
	ld [hl+], a
	ldh a, [$ffc2]
	ld [hl+], a
	ldh a, [$ffc3]
	ld [hl+], a
	ldh a, [$ffc4]
	ld [hl+], a
	ldh a, [$ffc5]
	ld [hl+], a
	ldh a, [$ffc6]
	ld [hl+], a
	ldh a, [$ffc7]
	ld [hl+], a
	ldh a, [$ffc8]
	ld [hl+], a
	ldh a, [$ffc9]
	ld [hl+], a
	ldh a, [$ffca]
	ld [hl+], a
	ldh a, [$ffcb]
	ld [hl+], a
	ldh a, [$ffcc]
	ld [hl+], a
	ldh a, [$ffcd]
	ld [hl+], a
	ldh a, [$ffce]
	ld [hl+], a
	ldh a, [$ffcf]
	ld [hl+], a
	ldh a, [$ffd0]
	ld [hl+], a
	ldh a, [$ffd1]
	ld [hl+], a
	ldh a, [$ffd2]
	ld [hl+], a
	ldh a, [$ffd3]
	ld [hl+], a
	ldh a, [$ffd4]
	ld [hl+], a
	ldh a, [$ffd5]
	ld [hl+], a
	ldh a, [$ffd6]
	ld [hl+], a
	ldh a, [$ffd7]
	ld [hl+], a
	ldh a, [$ffd8]
	ld [hl+], a
	ldh a, [$ffd9]
	ld [hl+], a
	ret
SpawnEntityRelative:
	push de
	push af
	ldh a, [$ffbc]
	add a, c
	ld e, a
	ldh a, [$ffbe]
	add a, b
	ld d, a
	ld bc, $0000
	pop af
	call SpawnEntity
	pop de
	ret
UpdateActionTimer:
	ld hl, $ffb4
	bit 7, [hl]
	jr z, Func_03_442c
	ldh a, [$ffc7]
	cp $15
	jr c, Func_03_443a
Func_03_442c:
	ldh a, [$ffb6]
	bit 3, a
	jr z, Func_03_443a
	res 7, [hl]
	xor a
	ldh [$ffc7], a
	ldh [$ffb7], a
	ret
Func_03_443a:
	xor a
	set 0, a
	ldh [$ffb7], a
	ret
	ld hl, $ffb4
	bit 7, [hl]
	jr z, Func_03_444d
	ldh a, [$ffc7]
	cp $1f
	jr c, Func_03_445b
Func_03_444d:
	ldh a, [$ffb6]
	bit 3, a
	jr z, Func_03_445b
	res 7, [hl]
	xor a
	ldh [$ffc7], a
	ldh [$ffb7], a
	ret
Func_03_445b:
	xor a
	set 0, a
	ldh [$ffb7], a
	ret
	push de
	ldh a, [$ffbe]
	add a, $08
	swap a
	and $0f
	ld b, a
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_4477
	ldh a, [$ffbc]
	sub $10
	jr Func_03_447b
Func_03_4477:
	ldh a, [$ffbc]
	add a, $10
Func_03_447b:
	add a, $08
	swap a
	and $0f
	ld c, a
	call BreakTileAtCell
	pop de
	ret
	push de
	ldh a, [$ffbe]
	sub $10
	add a, $08
	swap a
	and $0f
	ld b, a
	ldh a, [$ffbc]
	add a, $08
	swap a
	and $0f
	ld c, a
	call BreakTileAtCell
	pop de
	ret
	push de
	ldh a, [$ffbe]
	add a, $10
	add a, $08
	swap a
	and $0f
	ld b, a
	ldh a, [$ffbc]
	add a, $08
	swap a
	and $0f
	ld c, a
	call BreakTileAtCell
	pop de
	ret
BreakTileAtPixel:
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
BreakTileAtCell:
	push bc
	call TryBreakCrateCell
	pop bc
	or a
	ret z
	ld a, c
	swap a
	and $f0
	sub $08
	add a, $08
	ld e, a
	ld a, b
	swap a
	and $f0
	sub $08
	add a, $08
	ld d, a
	ld bc, $0000
	ld a, $0d
	call SpawnEntity
	ld a, $01
	ret
TryBreakCrateCell:
	push bc
	call ReadFloorCell
	cp $22
	jr z, Func_03_44fd
	cp $23
	jr nz, Func_03_4519
Func_03_44fd:
	ld b, $00
	ld hl, wFloorCollision
	add hl, bc
	ld [hl], $00
	ld hl, wFloorGrid
	add hl, bc
	pop bc
	ld a, [hl]
	bit 7, a
	jr z, Func_03_4513
	call Func_00_11dc
	ld [hl], a
Func_03_4513:
	call DrawFloorPiece
	ld a, $01
	ret
Func_03_4519:
	pop bc
	xor a
	ret
BreakOrChainCrateCell:
	ld a, b
	ld [$cf70], a
	ld a, c
	ld [$cf6f], a
	push bc
	call Func_00_101b
	cp $22
	jr z, Func_03_4534
	cp $23
	jr z, Func_03_4544
Func_03_4530:
	ld a, $02
	pop bc
	ret
Func_03_4534:
	ld b, $00
	ld hl, wFloorCollision
	add hl, bc
	ld a, $23
	ld [hl], a
	pop bc
	call DrawFloorPiece
	ld a, $01
	ret
Func_03_4544:
	push bc
	ld a, [$cf70]
	ld b, a
	ld a, [$cf6f]
	ld c, a
	call Func_00_103d
	pop bc
	cp $c0
	jr z, Func_03_4530
	cp $80
	jr z, Func_03_4530
	ld b, $00
	ld hl, wFloorCollision
	add hl, bc
	ld [hl], $00
	ld hl, wFloorGrid
	add hl, bc
	pop bc
	ld a, [hl]
	bit 7, a
	jr z, Func_03_456f
	call Func_00_11dc
	ld [hl], a
Func_03_456f:
	call DrawFloorPiece
	ld a, $00
	ret
FindFreeEntitySlot:
	push bc
	push de
	ld c, $1c
	ld hl, $c7f9
	ld de, $002a
	xor a
Func_03_4580:
	cp [hl]
	jr z, Func_03_458e
	add hl, de
	dec c
	jr nz, Func_03_4580

SECTION "room_00c587", ROMX[$4587], BANK[$03]

Data_03_4587:
	db $d1, $c1, $21, $00, $00, $af, $c9

SECTION "room_00c58e", ROMX[$458e], BANK[$03]

Func_03_458e:
	pop de
	pop bc
	ld a, $01
	ret
SpawnEntity:
	push af
	call FindFreeEntitySlot
	or a
	jr nz, Func_03_45a0

SECTION "room_00c59a", ROMX[$459a], BANK[$03]

Data_03_459a:
	db $f1, $21, $00, $00, $af, $c9

SECTION "room_00c5a0", ROMX[$45a0], BANK[$03]

Func_03_45a0:
	pop af
	push hl
	ld [hl+], a
	push af
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld a, c
	ld [hl+], a
	ld a, b
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, e
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, d
	ld [hl+], a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	pop af
	ld c, a
	ld b, $00
	push de
	push hl
	ld a, $01
	ld hl, Func_01_7b24
	call CallBankedHL
	pop hl
	pop de
	ld a, [$cf65]
	ld [hl+], a
	ld a, [$cf66]
	ld [hl+], a
	ld a, [$cf67]
	ld [hl+], a
	ld a, [$cf68]
	ld [hl+], a
	ld a, [$cf69]
	ld [hl+], a
	ld a, [$cf6a]
	ld [hl+], a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	pop hl
	push de
	push hl
	ld a, $04
	ld hl, Func_04_4344
	call CallBankedHL
	pop hl
	pop de
	push hl
	ld a, $22
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ldh a, [$ffda]
	ld [hl+], a
	ldh a, [$ffdb]
	ld [hl+], a
	ldh a, [$ffdc]
	ld [hl+], a
	ldh a, [$ffdd]
	ld [hl+], a
	ldh a, [$ffde]
	ld [hl+], a
	ldh a, [$ffdf]
	ld [hl+], a
	ldh a, [$ffe0]
	ld [hl+], a
	ldh a, [$ffe1]
	ld [hl], a
	pop hl
	ld a, $01
	ret
	push af
	ld a, $28
	call PlaySoundTracked
	pop af
	ld a, $02
	ld [$c2e6], a
	ret
Func_03_462f:
	ld a, [$c807]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	ldh a, [$ffbe]
	add a, $08
	swap a
	and $0f
	cp b
	jr z, Func_03_464a
	inc a
	cp b
	jr nz, Func_03_465b
Func_03_464a:
	ld a, [$c805]
	ld b, a
	ldh a, [$ffbc]
	call OrderPair
	sub b
	cp $18
	jr nc, Func_03_465b
	ld a, $01
	ret
Func_03_465b:
	xor a
	ret
Func_03_465d:
	ld a, [$c807]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	ldh a, [$ffbe]
	add a, $08
	swap a
	and $0f
	cp b
	jr z, Func_03_4678
	inc a
	cp b
	jr nz, Func_03_4692
Func_03_4678:
	ld a, [$c805]
	ld b, a
	ldh a, [$ffbc]
	cp b
	jr c, Func_03_4689
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_468f
	jr Func_03_4692
Func_03_4689:
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_4692
Func_03_468f:
	ld a, $01
	ret
Func_03_4692:
	xor a
	ret
Func_03_4694:
	ld a, [$c807]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	ldh a, [$ffbe]
	add a, $08
	swap a
	and $0f
	cp b
	jr nz, Func_03_46da
	ld a, [$c805]
	ld b, a
	ldh a, [$ffbc]
	cp b
	jr c, Func_03_46bc
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_46c2
	jr Func_03_46da
Func_03_46bc:
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_46da
Func_03_46c2:
	ld a, [$c7ff]
	ld b, a
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_46d3
	bit 7, b
	jr nz, Func_03_46da
	ld a, $01
	ret
Func_03_46d3:
	bit 7, b
	jr z, Func_03_46da
	ld a, $01
	ret
Func_03_46da:
	xor a
	ret
OrderPair:
	cp b
	ret nc
	ld c, a
	ld a, b
	ld b, c
	ret
Func_03_46e2:
	ldh a, [$ffbc]
	ld c, a
	ld a, [$c805]
	cp c
	call Func_03_42fb
	ret
Func_03_46ed:
	ldh a, [$ff8b]
	bit 5, a
	jr nz, Func_03_46ff
	bit 4, a
	ret z
	ld c, $b6
	ldh a, [c]
	and $fc
	res 7, a
	ldh [c], a
	ret
Func_03_46ff:
	ld c, $b6
	ldh a, [c]
	and $fc
	or $01
	set 7, a
	ldh [c], a
	ret
	call Func_03_46ed
	call Func_03_48cb
	ldh a, [$ff8c]
	bit 6, a
	jp nz, Func_03_48b3
	ldh a, [$ff8b]
	bit 6, a
	jp z, Func_03_4726
	ld a, [$cf7f]
	bit 0, a
	jp nz, Func_03_48b3
Func_03_4726:
	call UpdateActionTimer
	bit 0, a
	jp nz, Func_03_48af
	ldh a, [$ffb5]
	and $03
	cp $01
	jp z, Func_03_488b
	cp $03
	jp z, Func_03_4897
	cp $02
	jp z, Func_03_48a3
	ldh a, [$ff8b]
	bit 7, a
	jp nz, Func_03_487f
	and $30
	jp nz, Func_03_4883
	ret
	call Func_03_46ed
	call Func_03_48cb
	ldh a, [$ff8c]
	bit 6, a
	jp nz, Func_03_48b3
	call UpdateActionTimer
	bit 0, a
	jp nz, Func_03_48af
	ldh a, [$ffb5]
	and $03
	cp $01
	jp z, Func_03_488f
	cp $03
	jp z, Func_03_489b
	cp $02
	jp z, Func_03_48a7
	ldh a, [$ff8b]
	bit 7, a
	jp z, Func_03_487b
	and $30
	jp nz, Func_03_4887
	ret
	call Func_03_46ed
	call Func_03_48cb
	ldh a, [$ff8c]
	bit 6, a
	jp nz, Func_03_48b3
	call UpdateActionTimer
	bit 0, a
	jp nz, Func_03_48af
	ldh a, [$ffb5]
	and $03
	cp $01
	jp z, Func_03_488b
	cp $03
	jp z, Func_03_4897
	cp $02
	jp z, Func_03_48a3
	ldh a, [$ff8b]
	bit 7, a
	jp nz, Func_03_487f
	and $30
	jp z, Func_03_487b
	ret
	call Func_03_46ed
	call Func_03_48cb
	ldh a, [$ff8c]
	bit 6, a
	jp nz, Func_03_48b3
	call UpdateActionTimer
	bit 0, a
	jp nz, Func_03_48af
	ldh a, [$ffb5]
	and $03
	cp $01
	jp z, Func_03_488f
	cp $03
	jp z, Func_03_489b
	cp $02
	jp z, Func_03_48a7
	ldh a, [$ff8b]
	bit 7, a
	jp z, Func_03_487b
	and $30
	jp z, Func_03_487f
	ret
	push af
	ld a, $25
	call PlaySound
	pop af
	call Func_03_48cb
	and $03
	cp $01
	jp z, Func_03_4893
	cp $03
	jp z, Func_03_489f
	cp $02
	jp z, Func_03_48ab
	ldh a, [$ff8b]
	and $30
	jp nz, Func_03_48bb
	ret
	call Func_03_46ed
	call Func_03_491c
	bit 0, a
	jp z, Func_03_48c3
	call Func_03_48cb
	and $03
	cp $01
	jr z, Func_03_4893
	cp $03
	jp z, Func_03_489f
	cp $02
	jp z, Func_03_48ab
	ldh a, [$ff8b]
	and $30
	jp nz, Func_03_48bb
	call UpdateActionTimer
	bit 0, a
	jp z, Func_03_48bf
	ret
	call Func_03_46ed
	call Func_03_491c
	bit 0, a
	jp z, Func_03_48c7
	call Func_03_48cb
	and $03
	cp $01
	jr z, Func_03_4893
	cp $03
	jr z, Func_03_489f
	cp $02
	jr z, Func_03_48ab
	ldh a, [$ff8b]
	and $30
	jr z, Func_03_48b7
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_48bf
	ret
	call Func_03_48cb
	ldh a, [$ff8b]
	bit 6, a
	jp nz, Func_03_487b
	ret
	ldh a, [$ff8b]
	bit 7, a
	jr z, Func_03_487b
	jr Func_03_487f
Func_03_487b:
	ld de, $72df
	ret
Func_03_487f:
	ld de, $72eb
	ret
Func_03_4883:
	ld de, $72f7
	ret
Func_03_4887:
	ld de, $7305
	ret
Func_03_488b:
	ld de, $73ba
	ret

SECTION "room_00c88f", ROMX[$488f], BANK[$03]

Func_03_488f:
	ld de, $73d1
	ret
Func_03_4893:
	ld de, $73e8
	ret

SECTION "room_00c897", ROMX[$4897], BANK[$03]

Func_03_4897:
	ld de, $7313
	ret
Func_03_489b:
	ld de, $7331
	ret
Func_03_489f:
	ld de, $734f
	ret
Func_03_48a3:
	ld de, $7370
	ret
Func_03_48a7:
	ld de, $7386
	ret
Func_03_48ab:
	ld de, $739c
	ret
Func_03_48af:
	ld de, $7420
	ret
Func_03_48b3:
	ld de, $7407
	ret
Func_03_48b7:
	ld de, $742a
	ret
Func_03_48bb:
	ld de, $7436
	ret
Func_03_48bf:
	ld de, $7444
	ret
Func_03_48c3:
	ld de, $7458
	ret
Func_03_48c7:
	ld de, $746d
	ret
Func_03_48cb:
	ld hl, $ffb5
	ld a, [hl]
	ld b, a
	and $03
	jr nz, Func_03_48e2
	ldh a, [$ff8c]
	bit 0, a
	jr nz, Func_03_48e4
	bit 1, a
	jr nz, Func_03_48eb
	bit 2, a
	jr nz, Func_03_48f2
Func_03_48e2:
	ld a, b
	ret
Func_03_48e4:
	ld a, b
	and $fc
	or $03
	ld [hl], a
	ret
Func_03_48eb:
	ld a, b
	and $fc
	or $02
	ld [hl], a
	ret
Func_03_48f2:
	ld a, b
	and $fc
	or $01
	ld [hl], a
	ret
	ldh a, [$ff8c]
	bit 6, a
	ret z
	ld hl, $cf7f
	set 0, [hl]
	ret
	ldh a, [$ff8b]
	bit 6, a
	ret z

SECTION "room_00c909", ROMX[$4909], BANK[$03]

Data_03_4909:
	db $21, $7f, $cf, $cb, $c6, $c9, $c9

SECTION "room_00c910", ROMX[$4910], BANK[$03]

Func_03_4910:
	xor a
	ld [$cf7f], a
	ret
	ldh a, [$ffb5]
	and $fc
	ldh [$ffb5], a
	ret
Func_03_491c:
	push de
	call Func_03_492e
	pop de
	or a
	jr z, Func_03_4928
	xor a
	ldh [$ffb7], a
	ret
Func_03_4928:
	xor a
	set 0, a
	ldh [$ffb7], a
	ret
Func_03_492e:
	ldh a, [$ffb4]
	bit 7, a
	jp z, Func_03_498c
	ldh a, [$ffc7]
	cp $15
	jr nc, Func_03_498c
	ld a, $ff
	ld [$cf65], a
	ld [$cf66], a
	ld [$cf67], a
	ldh a, [$ffbc]
	ld [$cf73], a
	ldh a, [$ffbe]
	ld [$cf74], a
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_4961
	call Func_03_498e
	or a
	jr nz, Func_03_496a
	call Func_03_49c0
	jr Func_03_496a
Func_03_4961:
	call Func_03_49c0
	or a
	jr nz, Func_03_496a
	call Func_03_498e
Func_03_496a:
	ld a, [$cf65]
	cp $ff
	jr nz, Func_03_4978
	ld a, [$cf66]
	cp $ff
	jr z, Func_03_498c
Func_03_4978:
	ld a, [$cf67]
	or a
	jr z, Func_03_4985
	push af
	ld a, $02
	call PlaySound
	pop af
Func_03_4985:
	ld a, $14
	ldh [$ffc7], a
	ld a, $01
	ret
Func_03_498c:
	xor a
	ret
Func_03_498e:
	ld a, [$cf74]
	sub $0d
	ld b, a
	ld a, [$cf73]
	sub $03
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_03_49bb
	call Func_03_49f2
	ld [$cf65], a
	or a
	jr nz, Func_03_49bd
Func_03_49bb:
	xor a
	ret
Func_03_49bd:
	ld a, $01
	ret
Func_03_49c0:
	ld a, [$cf74]
	sub $0d
	ld b, a
	ld a, [$cf73]
	add a, $02
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_03_49ed
	call Func_03_49f2
	ld [$cf66], a
	or a
	jr nz, Func_03_49ef
Func_03_49ed:
	xor a
	ret
Func_03_49ef:
	ld a, $01
	ret
Func_03_49f2:
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	ld a, b
	inc a
	swap a
	and $f0
	sub $08
	add a, $0d
	ldh [$ffbe], a
	xor a
	ldh [$ffbd], a
	push bc
	call BreakOrChainCrateCell
	pop bc
	or a
	jr z, Func_03_4a2c
	cp $01
	jr z, Func_03_4a24
	ld a, $01
	ld [$cf67], a
	xor a
	ret
Func_03_4a24:
	ld a, $01
	ld [$cf67], a
	ld a, $01
	ret
Func_03_4a2c:
	ld a, c
	swap a
	and $f0
	ld e, a
	ld a, b
	swap a
	and $f0
	ld d, a
	ld hl, $ffe5
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	ld a, $02
	call SpawnEntity
	ld a, $02
	ret
Func_03_4a46:
	ld hl, $ffb4
	set 7, [hl]
	xor a
	ldh [$ffc7], a
	ret

SECTION "room_00ca4f", ROMX[$4a4f], BANK[$03]

Data_03_4a4f:
	db $21, $b4, $ff, $cb, $be, $af, $e0, $c7, $c9

SECTION "room_00ca58", ROMX[$4a58], BANK[$03]

RequestFloorExit:
	ld hl, $c2d5
	set 7, [hl]
	ret
	ld hl, $ffb4
	res 1, [hl]
	ret
	ld hl, $ffb4
	set 1, [hl]
	ret
	push de
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_4a77
	ldh a, [$ffbc]
	sub $11
	jr Func_03_4a7b
Func_03_4a77:
	ldh a, [$ffbc]
	add a, $11
Func_03_4a7b:
	ld c, a
	ldh a, [$ffb3]
	cp $05
	jr z, Func_03_4a88
	ldh a, [$ffbe]
	sub $04
	jr Func_03_4a8c
Func_03_4a88:
	ldh a, [$ffbe]
	add a, $04
Func_03_4a8c:
	ld b, a
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	ld a, b
	ld [$cf72], a
	ld a, c
	ld [$cf71], a
	call Func_03_4b6e
	cp $ff
	jr z, Func_03_4ad8
	cp $01
	jr z, Func_03_4b03
	push bc
	call ReadFloorCell
	pop bc
	or a
	jr z, Func_03_4ac2
	cp $22
	jr z, Func_03_4ada
	cp $23
	jr z, Func_03_4ada
	jr Func_03_4af3
Func_03_4ac2:
	ldh a, [$ffac]
	and $40
	jr nz, Func_03_4b03
	call Func_03_4c0b
	jr z, Func_03_4ad8
	ld hl, $ffe5
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	ld a, $03
	call SpawnEntity
Func_03_4ad8:
	pop de
	ret
Func_03_4ada:
	ld a, c
	swap a
	and $f0
	ld e, a
	ld a, b
	swap a
	and $f0
	ld d, a
	ld hl, $ffe5
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	ld a, $04
	call SpawnEntity
	pop de
	ret
Func_03_4af3:
	ldh a, [$ffb3]
	cp $05
	jr z, Func_03_4afe
	call Func_03_4b08
	pop de
	ret
Func_03_4afe:
	call Func_03_4b3c
	pop de
	ret
Func_03_4b03:
	call Func_03_4b56
	pop de
	ret
Func_03_4b08:
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_4b18
	ld a, c
	swap a
	and $f0
	add a, $07
	ld e, a
	jr Func_03_4b20
Func_03_4b18:
	ld a, c
	swap a
	and $f0
	sub $08
	ld e, a
Func_03_4b20:
	ld a, b
	swap a
	and $f0
	ld d, a
	ld hl, $ffe5
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	ld a, $05
	call SpawnEntity
	ldh a, [$ffb6]
	bit 7, a
	ret z
	ld a, $06
	rst $00
	set 7, [hl]
	ret
Func_03_4b3c:
	ld a, c
	swap a
	and $f0
	ld e, a
	ld a, b
	swap a
	and $f0
	sub $08
	ld d, a
	ld hl, $ffe5
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	ld a, $06
	call SpawnEntity
	ret
Func_03_4b56:
	ld a, c
	swap a
	and $f0
	ld e, a
	ld a, b
	swap a
	and $f0
	ld d, a
	ld hl, $ffe5
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	ld a, $07
	call SpawnEntity
	ret
Func_03_4b6e:
	push bc
	ld hl, $ffda
	ld a, c
	swap a
	and $f0
	ld e, a
	sub $08
	ld [hl+], a
	ld a, b
	swap a
	and $f0
	ld d, a
	sub $08
	ld [hl+], a
	ld a, $10
	ld [hl+], a
	ld [hl], a
	call FindEntityHittingRect
	or a
	jr z, Func_03_4c04
	cp $3b
	jr z, Func_03_4ba1
	cp $3c
	jr z, Func_03_4bb8
	cp $41
	jr z, Func_03_4bcf
	cp $38
	jr z, Func_03_4bea
	jp Func_03_4c07
Func_03_4ba1:
	push hl
	ld de, $0003
	add hl, de
	ld a, [hl]
	pop hl
	or a
	jp nz, Func_03_4c07
	push af
	ld a, $21
	call PlaySound
	pop af
	call Func_03_63bf
	jr Func_03_4c00
Func_03_4bb8:
	push hl
	ld de, $0003
	add hl, de
	ld a, [hl]
	pop hl
	or a
	jp nz, Func_03_4c07
	push af
	ld a, $21
	call PlaySound
	pop af
	call Func_03_63d4
	jr Func_03_4c00

SECTION "room_00cbcf", ROMX[$4bcf], BANK[$03]

Func_03_4bcf:
	push hl
	ld de, $0003
	add hl, de
	ld a, [hl]
	pop hl
	cp $03
	jp z, Func_03_4bde
	jp Func_03_4c07
Func_03_4bde:
	push af
	ld a, $21
	call PlaySound
	pop af
	call Func_03_6704
	jr Func_03_4c00

SECTION "room_00cbea", ROMX[$4bea], BANK[$03]

Func_03_4bea:
	push hl
	ld de, $0003
	add hl, de
	ld a, [hl]
	pop hl
	cp $03
	jp nz, Func_03_4c07
	push af
	ld a, $21
	call PlaySound
	pop af
	call Func_03_66f6
Func_03_4c00:
	pop bc
	ld a, $ff
	ret
Func_03_4c04:
	pop bc
	xor a
	ret
Func_03_4c07:
	pop bc
	ld a, $01
	ret
Func_03_4c0b:
	ld a, [$c2c1]
	cp $02
	jr nz, Func_03_4c33
	ld a, [wActiveFloor]
	cp $02
	jr nz, Func_03_4c33
	ld a, [$cf71]
	ld c, a
	ld a, [$cf72]
	ld b, a
	ldh a, [$ffac]
	cp $30
	jr z, Func_03_4c39
	cp $32
	jr z, Func_03_4c4c
	cp $31
	jr z, Func_03_4c37
	cp $33
	jr z, Func_03_4c37
Func_03_4c33:
	ld a, $01
	or a
	ret

SECTION "room_00cc37", ROMX[$4c37], BANK[$03]

Func_03_4c37:
	xor a
	ret

SECTION "room_00cc39", ROMX[$4c39], BANK[$03]

Func_03_4c39:
	push de
	ld a, $01
	ld hl, Func_01_4ce1
	call CallBankedHL
	pop de
	push af
	ld a, $04
	call PlaySound
	pop af
	xor a
	ret
Func_03_4c4c:
	push de
	ld a, $01
	ld hl, Func_01_4cfe
	call CallBankedHL
	pop de
	push af
	ld a, $04
	call PlaySound
	pop af
	xor a
	ret
	ld hl, $c7fd
	res 2, [hl]
	ret
	ldh a, [$ffb4]
	bit 2, a
	ret nz
	ld a, [$c2cc]
	or a
	ret z
	push de
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_4c92
	ldh a, [$ffb3]
	cp $08
	jr z, Func_03_4c88
	ldh a, [$ffb4]
	bit 7, a
	jr nz, Func_03_4c8d
	call Func_03_4cbb
	jp Func_03_4cab
Func_03_4c88:
	call Func_03_4d19
	jr Func_03_4cab
Func_03_4c8d:
	call Func_03_4d83
	jr Func_03_4cab
Func_03_4c92:
	ldh a, [$ffb3]
	cp $08
	jr z, Func_03_4ca3
	ldh a, [$ffb4]
	bit 7, a
	jr nz, Func_03_4ca8
	call Func_03_4cea
	jr Func_03_4cab
Func_03_4ca3:
	call Func_03_4d4e
	jr Func_03_4cab
Func_03_4ca8:
	call Func_03_4db2
Func_03_4cab:
	ld hl, $ffb4
	set 2, [hl]
	ld hl, $c2cc
	dec [hl]
	ld hl, $c2cd
	srl [hl]
	pop de
	ret
Func_03_4cbb:
	ldh a, [$ffbe]
	add a, $08
	and $f0
	add a, $02
	ld d, a
	ldh a, [$ffbc]
	ld e, a
	ldh a, [$ffe5]
	ld c, a
	ldh a, [$ffe6]
	ld b, a
	ld a, [$c2cd]
	and $01
	add a, $16
	call SpawnEntity
	call Func_03_4de1
	call Func_03_4dee
	call Func_03_4e04
	call Func_03_4e1a
	call Func_03_4e21
	call Func_03_4e34
	ret
Func_03_4cea:
	ldh a, [$ffbe]
	add a, $08
	and $f0
	add a, $02
	ld d, a
	ldh a, [$ffbc]
	ld e, a
	ldh a, [$ffe5]
	ld c, a
	ldh a, [$ffe6]
	ld b, a
	ld a, [$c2cd]
	and $01
	add a, $10
	call SpawnEntity
	call Func_03_4de1
	call Func_03_4e11
	call Func_03_4df7
	call Func_03_4e1a
	call Func_03_4e21
	call Func_03_4e34
	ret
Func_03_4d19:
	ldh a, [$ffbe]
	add a, $08
	and $f0
	add a, $05
	ld d, a
	ldh a, [$ffbc]
	ld e, a
	ldh a, [$ffe5]
	ld c, a
	ldh a, [$ffe6]
	ld b, a
	ld a, [$c2cd]
	and $01
	add a, $18
	call SpawnEntity
	call Func_03_4de1
	call Func_03_4dee
	call Func_03_4e04
	call Func_03_4e1a
	call Func_03_4e21
	call Func_03_4e34
	ld de, $0006
	add hl, de
	set 3, [hl]
	ret
Func_03_4d4e:
	ldh a, [$ffbe]
	add a, $08
	and $f0
	add a, $05
	ld d, a
	ldh a, [$ffbc]
	ld e, a
	ldh a, [$ffe5]
	ld c, a
	ldh a, [$ffe6]
	ld b, a
	ld a, [$c2cd]
	and $01
	add a, $12
	call SpawnEntity
	call Func_03_4de1
	call Func_03_4e11
	call Func_03_4df7
	call Func_03_4e1a
	call Func_03_4e21
	call Func_03_4e34
	ld de, $0006
	add hl, de
	set 3, [hl]
	ret
Func_03_4d83:
	ldh a, [$ffbe]
	add a, $08
	and $f0
	sub $02
	ld d, a
	ldh a, [$ffbc]
	ld e, a
	ldh a, [$ffe5]
	ld c, a
	ldh a, [$ffe6]
	ld b, a
	ld a, [$c2cd]
	and $01
	add a, $1a
	call SpawnEntity
	call Func_03_4de1
	call Func_03_4e11
	call Func_03_4e04
	call Func_03_4e1a
	call Func_03_4e21
	call Func_03_4e34
	ret
Func_03_4db2:
	ldh a, [$ffbe]
	add a, $08
	and $f0
	sub $02
	ld d, a
	ldh a, [$ffbc]
	ld e, a
	ldh a, [$ffe5]
	ld c, a
	ldh a, [$ffe6]
	ld b, a
	ld a, [$c2cd]
	and $01
	add a, $14
	call SpawnEntity
	call Func_03_4de1
	call Func_03_4dee
	call Func_03_4df7
	call Func_03_4e1a
	call Func_03_4e21
	call Func_03_4e34
	ret
Func_03_4de1:
	push hl
	ld bc, $000f
	add hl, bc
	ld a, $00
	ld [hl+], a
	ld a, $02
	ld [hl], a
	pop hl
	ret
Func_03_4dee:
	push hl
	ld bc, $0006
	add hl, bc
	res 2, [hl]
	pop hl
	ret
Func_03_4df7:
	push hl
	ld bc, $0006
	add hl, bc
	ld a, [hl]
	and $fc
	or $00
	ld [hl], a
	pop hl
	ret
Func_03_4e04:
	push hl
	ld bc, $0006
	add hl, bc
	ld a, [hl]
	and $fc
	or $01
	ld [hl], a
	pop hl
	ret
Func_03_4e11:
	push hl
	ld bc, $0006
	add hl, bc
	set 2, [hl]
	pop hl
	ret
Func_03_4e1a:
	ld a, l
	ldh [$ffe7], a
	ld a, h
	ldh [$ffe8], a
	ret
Func_03_4e21:
	ld a, [$c2cd]
	bit 0, a
	ret z
	push hl
	ld a, $04
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	set 3, [hl]
	pop hl
	ret
Func_03_4e34:
	push hl
	ld a, $11
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [$c2ce]
	ld [hl+], a
	ld a, [$c2cf]
	ld [hl], a
	pop hl
	ret

SECTION "room_00ce47", ROMX[$4e47], BANK[$03]

Data_03_4e47:
	db $f5, $3e, $21, $cd, $85, $0a, $f1, $e5, $7e, $d6, $40, $87, $4f, $06, $00, $21
	db $70, $4e, $09, $2a, $56, $5f, $e1, $e5, $01, $18, $00, $09, $7b, $22, $72, $e1
	db $e5, $11, $16, $00, $19, $af, $77, $e1, $c9, $b4, $7a, $37, $7b, $c5, $7b, $08
	db $7c, $9e, $7c, $25, $7d, $25, $7d

SECTION "room_00ce7e", ROMX[$4e7e], BANK[$03]

FindEntityHittingRect:
	push bc
	push de
	ld hl, $c823
	ld c, $1b
Func_03_4e85:
	ld a, [hl]
	or a
	jr z, Func_03_4ee9
	push bc
	ld c, $de
	call Func_00_104f
	ldh a, [$ffe0]
	or a
	jr z, Func_03_4ee8
	ldh a, [$ffde]
	add a, c
	ldh [$ffde], a
	ldh a, [$ffdf]
	add a, b
	ldh [$ffdf], a
	ld a, [$cf71]
	ld b, a
	ldh a, [$ffde]
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	cp c
	jr c, Func_03_4ee8
	ldh a, [$ffde]
	ld c, a
	ldh a, [$ffe0]
	add a, c
	dec a
	add a, $08
	swap a
	and $0f
	inc a
	ld c, a
	ld a, b
	cp c
	jr nc, Func_03_4ee8
	ld a, [$cf72]
	ld b, a
	ldh a, [$ffdf]
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	cp c
	jr c, Func_03_4ee8
	ldh a, [$ffdf]
	ld c, a
	ldh a, [$ffe1]
	add a, c
	dec a
	add a, $08
	swap a
	and $0f
	inc a
	ld c, a
	ld a, b
	cp c
	jr nc, Func_03_4ee8
	jr Func_03_4ef4
Func_03_4ee8:
	pop bc
Func_03_4ee9:
	ld de, $002a
	add hl, de
	dec c
	jr nz, Func_03_4e85
	pop de
	pop bc
	xor a
	ret
Func_03_4ef4:
	pop bc
	pop de
	pop bc
	ld a, [hl]
	ret

SECTION "room_00cef9", ROMX[$4ef9], BANK[$03]

Data_03_4ef9:
	db $fa, $71, $cf, $b9, $20, $09, $fa, $72, $cf, $b8, $20, $03, $3e, $01, $c9, $af
	db $c9

SECTION "room_00cf0a", ROMX[$4f0a], BANK[$03]

Func_03_4f0a:
	ld hl, $ffb4
	bit 7, [hl]
	ret nz
	call UpdateActionTimer
	bit 0, a
	ret z
	ld hl, $ffb4
	set 7, [hl]
	ld a, $14
	ldh [$ffc7], a
	ret
	xor a
	ldh [$ffc1], a
	ld a, [$c2d5]
	bit 1, a
	jr z, Func_03_4f38
	ld a, [$c52e]
	ld [$cf6f], a
	ld a, [$c52f]
	ld [$cf70], a
	jr Func_03_4f44
Func_03_4f38:
	ld a, [$c530]
	ld [$cf6f], a
	ld a, [$c531]
	ld [$cf70], a
Func_03_4f44:
	ld a, [$cf6f]
	swap a
	and $f0
	sub $08
	add a, $08
	ld c, a
	ldh a, [$ffbc]
	sub c
	jr c, Func_03_4f7f
	ld b, a
	ld c, $00
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld a, c
	ldh [$ffbf], a
	ld a, b
	ldh [$ffc0], a
	ld c, $b6
	ldh a, [c]
	and $fc
	or $01
	ldh [c], a
	ret
Func_03_4f7f:
	cpl
	ld b, a
	ld c, $00
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld a, c
	ldh [$ffbf], a
	ld a, b
	ldh [$ffc0], a
	ld c, $b6
	ldh a, [c]
	and $fc
	or $00
	ldh [c], a
	ret
	xor a
	ldh [$ffc1], a
	ld a, [$c52e]
	swap a
	and $f0
	sub $08
	add a, $08
	ld c, a
	ldh a, [$ffbc]
	sub c
	jr c, Func_03_4fe8
	ld b, a
	ld c, $00
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld a, c
	ldh [$ffbf], a
	ld a, b
	ldh [$ffc0], a
	ld c, $b6
	ldh a, [c]
	and $fc
	or $01
	ldh [c], a
	ret
Func_03_4fe8:
	cpl
	ld b, a
	ld c, $00
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	ld a, c
	ldh [$ffbf], a
	ld a, b
	ldh [$ffc0], a
	ld c, $b6
	ldh a, [c]
	and $fc
	or $00
	ldh [c], a
	ret
	ldh a, [$ffbd]
	ld l, a
	ldh a, [$ffbe]
	ld h, a
	ld a, [$cf70]
	call Func_03_509f
	or a
	jr nz, Func_03_502a
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	jr Func_03_502b
Func_03_502a:
	add hl, bc
Func_03_502b:
	call Func_03_50c8
	ld a, l
	ldh [$ffbd], a
	ld a, h
	ldh [$ffbe], a
	ldh a, [$ffbc]
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, [$cf6f]
	cp c
	ret nz
	ldh a, [$ffbe]
	add a, $08
	swap a
	and $0f
	ld b, a
	ld a, [$cf70]
	cp b
	ret nz
	ld a, $03
	ld [$c2dd], a
	xor a
	ldh [$ffb0], a
	ret
	ldh a, [$ffbd]
	ld l, a
	ldh a, [$ffbe]
	ld h, a
	ld a, [$c52f]
	call Func_03_509f
	or a
	jr nz, Func_03_5070
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	jr Func_03_5071
Func_03_5070:
	add hl, bc
Func_03_5071:
	call Func_03_50c8
	ld a, l
	ldh [$ffbd], a
	ld a, h
	ldh [$ffbe], a
	ldh a, [$ffbc]
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, [$c52e]
	cp c
	ret nz
	ldh a, [$ffbe]
	add a, $08
	swap a
	and $0f
	ld b, a
	ld a, [$c52f]
	cp b
	ret nz
	ld a, $02
	ld [$c2dd], a
	xor a
	ldh [$ffb0], a
	ret
Func_03_509f:
	swap a
	and $f0
	sub $08
	ld b, a
	ldh a, [$ffbe]
	sub b
	jr c, Func_03_50af
	ld b, a
	xor a
	jr Func_03_50b3
Func_03_50af:
	cpl
	ld b, a
	ld a, $01
Func_03_50b3:
	push af
	ld c, $00
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	pop af
	ret
Func_03_50c8:
	ldh a, [$ffc1]
	cp $40
	ret z
	inc a
	ldh [$ffc1], a
	push hl
	add a, a
	ld c, a
	ld b, $00
	ld hl, $50df
	add hl, bc
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	pop hl
	add hl, bc
	ret

SECTION "room_00d0e1", ROMX[$50e1], BANK[$03]

Data_03_50e1:
	db $37, $ff, $38, $ff, $39, $ff, $3a, $ff, $3c, $ff, $3e, $ff, $41, $ff, $45, $ff
	db $48, $ff, $4d, $ff, $51, $ff, $56, $ff, $5c, $ff, $62, $ff, $68, $ff, $6e, $ff
	db $75, $ff, $7d, $ff, $84, $ff, $8c, $ff, $94, $ff, $9d, $ff, $a6, $ff, $ae, $ff
	db $b8, $ff, $c1, $ff, $ca, $ff, $d4, $ff, $dd, $ff, $e7, $ff, $f1, $ff, $fb, $ff
	db $05, $00, $0e, $00, $18, $00, $22, $00, $2c, $00, $35, $00, $3f, $00, $48, $00
	db $51, $00, $5a, $00, $63, $00, $6b, $00, $73, $00, $7b, $00, $83, $00, $8a, $00
	db $91, $00, $98, $00, $9e, $00, $a4, $00, $a9, $00, $af, $00, $b3, $00, $b7, $00
	db $bb, $00, $bf, $00, $c1, $00, $c4, $00, $c6, $00, $c7, $00, $c8, $00

SECTION "room_00d15f", ROMX[$515f], BANK[$03]

Data_03_515f:
	db $c9, $00

SECTION "room_00d161", ROMX[$5161], BANK[$03]

Func_03_5161:
	ld c, $b6
	ldh a, [c]
	and $fc
	or $00
	res 7, a
	ldh [c], a
	ret
Func_03_516c:
	ld c, $b6
	ldh a, [c]
	and $fc
	or $01
	set 7, a
	ldh [c], a
	ret
	call Func_03_516c
	call Func_03_5193
	ret
	call Func_03_5161
	call Func_03_5193
	ret
	call Func_03_516c
	call Func_03_51c4
	ret
	call Func_03_5161
	call Func_03_51c4
	ret
Func_03_5193:
	ldh a, [$ffbc]
	ld c, a
	ld a, [$c805]
	cp c
	jr c, Func_03_519f
	sub c
	jr Func_03_51a2
Func_03_519f:
	ld b, a
	ld a, c
	sub b
Func_03_51a2:
	ld b, $00
	ld c, a
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	ld a, b
	or a
	jr nz, Func_03_51ba
	ld a, c
	cp $c0
	jr c, Func_03_51bd
Func_03_51ba:
	ld bc, $00c0
Func_03_51bd:
	ld a, c
	ldh [$ffbf], a
	ld a, b
	ldh [$ffc0], a
	ret
Func_03_51c4:
	ldh a, [$ffbc]
	ld c, a
	ld a, [$c805]
	cp c
	jr c, Func_03_51d0
	sub c
	jr Func_03_51d3
Func_03_51d0:
	ld b, a
	ld a, c
	sub b
Func_03_51d3:
	ld b, $00
	ld c, a
	sla c
	rl b
	sla c
	rl b
	ld a, b
	or a
	jr nz, Func_03_51e6
	ld a, c
	or a
	jr c, Func_03_51e9
Func_03_51e6:
	ld bc, $0080
Func_03_51e9:
	ld a, c
	ldh [$ffbf], a
	ld a, b
	ldh [$ffc0], a
	ret

SECTION "room_00d1f0", ROMX[$51f0], BANK[$03]

Data_03_51f0:
	db $cd, $1f, $44, $cb, $47, $28, $05, $3e, $ff, $e0, $b8, $c9, $f0, $be, $47, $f0
	db $bc, $4f, $f0, $d2, $81, $4f, $f0, $b6, $cb, $7f, $20, $06, $f0, $d4, $81, $4f
	db $18, $01, $0d, $79, $c6, $08, $cb, $37, $e6, $0f, $4f, $78, $c6, $08, $cb, $37
	db $e6, $0f, $47, $c5, $cd, $1b, $10, $c1, $b7, $20, $1b, $f0, $be, $47, $f0, $d3
	db $80, $47, $f0, $d5, $80, $c6, $08, $cb, $37, $e6, $0f, $47, $cd, $1b, $10, $b7
	db $28, $04, $af, $e0, $b8, $c9, $3e, $03, $e0, $b8, $c9

SECTION "room_00d24b", ROMX[$524b], BANK[$03]

Func_03_524b:
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_5257
	ld a, $ff
	ldh [$ffb8], a
	ret
Func_03_5257:
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffbc]
	ld c, a
	ldh a, [$ffd2]
	add a, c
	ld c, a
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_526d
	ldh a, [$ffd4]
	add a, c
	ld c, a
	jr Func_03_526e
Func_03_526d:
	dec c
Func_03_526e:
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	jr nz, Func_03_5288
	xor a
	ldh [$ffb8], a
	ret
Func_03_5288:
	cp $22
	jr z, Func_03_5295
	cp $23
	jr z, Func_03_5295
	ld a, $03
	ldh [$ffb8], a
	ret
Func_03_5295:
	ld a, $02
	ldh [$ffb8], a
	ret
Func_03_529a:
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffbc]
	ld c, a
	ldh a, [$ffd2]
	add a, c
	ld c, a
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_52b0
	ldh a, [$ffd4]
	add a, c
	ld c, a
	jr Func_03_52b1
Func_03_52b0:
	dec c
Func_03_52b1:
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	jr nz, Func_03_52cb
	xor a
	ldh [$ffb8], a
	ret
Func_03_52cb:
	ld a, $03
	ldh [$ffb8], a
	ret
Func_03_52d0:
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffd3]
	add a, b
	ld b, a
	ldh a, [$ffb6]
	and $03
	cp $03
	jr z, Func_03_52e6
	cp $02
	jr nz, Func_03_5303
	dec b
	jr Func_03_52ea
Func_03_52e6:
	ldh a, [$ffd5]
	add a, b
	ld b, a
Func_03_52ea:
	ldh a, [$ffbc]
	ld c, a
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	jr nz, Func_03_5307
Func_03_5303:
	xor a
	ldh [$ffb8], a
	ret
Func_03_5307:
	ldh a, [$ffb6]
	and $03
	cp $03
	jr z, Func_03_5318
	cp $02
	jr nz, Func_03_531d
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_5318:
	ld a, $02
	ldh [$ffb8], a
	ret

SECTION "room_00d31d", ROMX[$531d], BANK[$03]

Func_03_531d:
	ld a, $03
	ldh [$ffb8], a
	ret

SECTION "room_00d322", ROMX[$5322], BANK[$03]

Func_03_5322:
	push de
	ldh a, [$ffbe]
	ld d, a
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_5352
	ldh a, [$ffbc]
	sub $10
	ld e, a
	ld a, c
	ld bc, $0000
	call SpawnEntity
	push hl
	ldh a, [$ffd0]
	and $03
	ld c, a
	ld de, $0020
	add hl, de
	ld a, [hl]
	and $fc
	or c
	ld [hl], a
	pop hl
	push hl
	ld de, $0006
	add hl, de
	set 7, [hl]
	pop hl
	pop de
	ret
Func_03_5352:
	ldh a, [$ffbc]
	add a, $10
	ld e, a
	ld a, c
	ld bc, $0000
	call SpawnEntity
	push hl
	ldh a, [$ffd0]
	and $03
	ld c, a
	ld de, $0020
	add hl, de
	ld a, [hl]
	and $fc
	or c
	ld [hl], a
	pop hl
	pop de
	ret

SECTION "room_00d370", ROMX[$5370], BANK[$03]

Data_03_5370:
	db $0e, $22, $cd, $22, $53, $c9

SECTION "room_00d376", ROMX[$5376], BANK[$03]

Func_03_5376:
	ld c, $20
	call Func_03_5322
	ret
	ld c, $23
	call Func_03_5322
	ret
	ld c, $24
	call Func_03_5322
	ret
	ld c, $25
	call Func_03_5322
	ret
	ld c, $21
	call Func_03_5322
	ret
Func_03_5394:
	push de
	push af
	ldh a, [$ffbe]
	add a, b
	ld d, a
	ldh a, [$ffbc]
	add a, c
	ld e, a
	pop af
	push af
	ld bc, $0000
	pop af
	call SpawnEntity
	push hl
	ldh a, [$ffd0]
	swap a
	and $07
	ld c, a
	ld de, $0021
	add hl, de
	ld a, [hl]
	and $f8
	or c
	ld [hl], a
	pop hl
	push hl
	ldh a, [$ffd0]
	and $03
	ld c, a
	ld de, $0020
	add hl, de
	ld a, [hl]
	and $fc
	or c
	ld [hl], a
	pop hl
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_53d7
	push hl
	ld de, $0006
	add hl, de
	set 7, [hl]
	pop hl
Func_03_53d7:
	pop de
	ret
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_53f6
	ld c, $f0
	ld a, $2a
	ld b, $00
	call Func_03_5394
	push hl
	ld bc, $0006
	add hl, bc
	ld a, [hl]
	and $fc
	or $01
	ld [hl], a
	pop hl
	jr Func_03_540b
Func_03_53f6:
	ld c, $10
	ld a, $2a
	ld b, $00
	call Func_03_5394
	push hl
	ld bc, $0006
	add hl, bc
	ld a, [hl]
	and $fc
	or $00
	ld [hl], a
	pop hl
Func_03_540b:
	call Func_03_5447
	ret

SECTION "room_00d40f", ROMX[$540f], BANK[$03]

Data_03_540f:
	db $f0, $b6, $cb, $7f, $20, $17, $06, $f0, $3e, $2b, $0e, $00, $cd, $94, $53, $e5
	db $01, $06, $00, $09, $7e, $e6, $fc, $f6, $02, $77, $e1, $18, $17, $06, $10, $3e
	db $2b, $0e, $00, $cd, $94, $53, $e5, $01, $06, $00, $09, $7e, $e6, $fc, $f6, $03
	db $cb, $ff, $77, $e1, $cd, $47, $54, $c9

SECTION "room_00d447", ROMX[$5447], BANK[$03]

Func_03_5447:
	push hl
	ldh a, [$ffd0]
	swap a
	and $07
	add a, a
	ld c, a
	ld b, $00
	ld hl, $545e
	add hl, bc
	ld a, [hl+]
	ldh [$ffc3], a
	ld a, [hl]
	ldh [$ffc4], a
	pop hl
	ret

SECTION "room_00d45e", ROMX[$545e], BANK[$03]

Data_03_545e:
	db $2c, $01, $f0, $00, $b4, $00, $78, $00, $3c, $00

SECTION "room_00d468", ROMX[$5468], BANK[$03]

Data_03_5468:
	db $3c, $00, $3c, $00, $f0, $b6, $cb, $7f, $28, $04, $0e, $f0, $18, $02, $0e, $10
	db $3e, $26, $06, $f8, $cd, $94, $53, $cd, $47, $54, $c9

SECTION "room_00d483", ROMX[$5483], BANK[$03]

Func_03_5483:
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_548d
	ld c, $f0
	jr Func_03_548f
Func_03_548d:
	ld c, $10
Func_03_548f:
	ld a, $27
	ld b, $f8
	call Func_03_5394
	call Func_03_5447
	ret
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_54a4
	ld c, $f0
	jr Func_03_54a6
Func_03_54a4:
	ld c, $10
Func_03_54a6:
	ld b, $18
	ld a, $29
	call Func_03_5394
	ret
	ld a, $29
	ld b, $18
	ld c, $00
	call Func_03_5394
	ret
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_54c2
	ld c, $10
	jr Func_03_54c4
Func_03_54c2:
	ld c, $f0
Func_03_54c4:
	ld b, $18
	ld a, $29
	call Func_03_5394
	ret
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_54d6
	ld c, $d8
	jr Func_03_54d8
Func_03_54d6:
	ld c, $28
Func_03_54d8:
	ld b, $08
	ld a, $28
	call Func_03_5394
	ret
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_54ea
	ld c, $e8
	jr Func_03_54ec
Func_03_54ea:
	ld c, $18
Func_03_54ec:
	ld b, $08
	ld a, $28
	call Func_03_5394
	ret
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_54fe
	ld c, $f8
	jr Func_03_5500
Func_03_54fe:
	ld c, $08
Func_03_5500:
	ld b, $08
	ld a, $28
	call Func_03_5394
	ret
Func_03_5508:
	ld a, [wActiveFloor]
	cp $05
	jr z, Func_03_5518
	ld a, $01
	ld hl, Func_01_4d0d
	call CallBankedHL
	ret
Func_03_5518:
	ld a, [$c530]
	swap a
	and $f0
	sub $08
	add a, $08
	ld e, a
	ld a, [$c531]
	swap a
	and $f0
	sub $08
	add a, $08
	ld d, a
	ld bc, $0000
	ld a, $3e
	call SpawnEntity
	ret
	push de
	ldh a, [$ffbc]
	add a, $08
	swap a
	and $0f
	ld [$c530], a
	swap a
	and $f0
	sub $08
	add a, $08
	ld e, a
	ldh a, [$ffbe]
	sub $08
	add a, $08
	swap a
	and $0f
	ld [$c531], a
	swap a
	and $f0
	sub $08
	add a, $08
	ld d, a
	ld bc, $0000
	ld a, $0e
	call SpawnEntity
	pop de
	ret
	push de
	ldh a, [$ffbc]
	add a, $08
	swap a
	and $0f
	ld [$c530], a
	swap a
	and $f0
	sub $08
	add a, $08
	ld e, a
	ldh a, [$ffbe]
	add a, $08
	swap a
	and $0f
	ld [$c531], a
	swap a
	and $f0
	sub $08
	add a, $08
	ld d, a
	ld bc, $0000
	ld a, $0e
	call SpawnEntity
	pop de
	ret
	push de
	ld a, $01
	call Func_03_55cf
	ld a, $02
	call Func_03_55cf
	ld a, $03
	call Func_03_55cf
	ld a, $04
	call Func_03_55cf
	ld a, $06
	call Func_03_55cf
	ld a, $07
	call Func_03_55cf
	ld a, $08
	call Func_03_55cf
	ld a, $09
	call Func_03_55cf
	call Func_03_5508
	pop de
	ret
Func_03_55cf:
	push af
	ldh a, [$ffbc]
	ld e, a
	ldh a, [$ffbe]
	ld d, a
	ld bc, $0000
	ld a, $0f
	call SpawnEntity
	pop af
	push hl
	ld bc, $0021
	add hl, bc
	ld [hl], a
	pop hl
	ret
	ldh a, [$ffb6]
	bit 6, a
	ret nz
	ldh a, [$ffd1]
	cp $01
	jp z, Func_03_5617
	cp $02
	jp z, Func_03_56df
	cp $03
	jp z, Func_03_5649
	cp $04
	jp z, Func_03_572a
	cp $06
	jp z, Func_03_5711
	cp $07
	jp z, Func_03_567b
	cp $08
	jp z, Func_03_56f8
	cp $09
	jp z, Func_03_56ad

SECTION "room_00d616", ROMX[$5616], BANK[$03]

Data_03_5616:
	db $c9

SECTION "room_00d617", ROMX[$5617], BANK[$03]

Func_03_5617:
	ldh a, [$ffbb]
	ld c, a
	ldh a, [$ffbc]
	ld b, a
	ld hl, $fe9a
	add hl, bc
	ld a, l
	ldh [$ffbb], a
	ld a, h
	ldh [$ffbc], a
	ld a, h
	cp b
	jr c, Func_03_5630
	ld hl, $ffb6
	set 6, [hl]
Func_03_5630:
	ldh a, [$ffbd]
	ld c, a
	ldh a, [$ffbe]
	ld b, a
	ld hl, $0166
	add hl, bc
	ld a, l
	ldh [$ffbd], a
	ld a, h
	ldh [$ffbe], a
	ld a, h
	cp b
	ret nc
	ld hl, $ffb6
	set 6, [hl]
	ret
Func_03_5649:
	ldh a, [$ffbb]
	ld c, a
	ldh a, [$ffbc]
	ld b, a
	ld hl, $0166
	add hl, bc
	ld a, l
	ldh [$ffbb], a
	ld a, h
	ldh [$ffbc], a
	ld a, h
	cp b
	jr nc, Func_03_5662
	ld hl, $ffb6
	set 6, [hl]
Func_03_5662:
	ldh a, [$ffbd]
	ld c, a
	ldh a, [$ffbe]
	ld b, a
	ld hl, $0166
	add hl, bc
	ld a, l
	ldh [$ffbd], a
	ld a, h
	ldh [$ffbe], a
	ld a, h
	cp b
	ret nc
	ld hl, $ffb6
	set 6, [hl]
	ret
Func_03_567b:
	ldh a, [$ffbb]
	ld c, a
	ldh a, [$ffbc]
	ld b, a
	ld hl, $fe9a
	add hl, bc
	ld a, l
	ldh [$ffbb], a
	ld a, h
	ldh [$ffbc], a
	ld a, h
	cp b
	jr c, Func_03_5694
	ld hl, $ffb6
	set 6, [hl]
Func_03_5694:
	ldh a, [$ffbd]
	ld c, a
	ldh a, [$ffbe]
	ld b, a
	ld hl, $fe9a
	add hl, bc
	ld a, l
	ldh [$ffbd], a
	ld a, h
	ldh [$ffbe], a
	ld a, h
	cp b
	ret c
	ld hl, $ffb6
	set 6, [hl]
	ret
Func_03_56ad:
	ldh a, [$ffbb]
	ld c, a
	ldh a, [$ffbc]
	ld b, a
	ld hl, $0166
	add hl, bc
	ld a, l
	ldh [$ffbb], a
	ld a, h
	ldh [$ffbc], a
	ld a, h
	cp b
	jr nc, Func_03_56c6
	ld hl, $ffb6
	set 6, [hl]
Func_03_56c6:
	ldh a, [$ffbd]
	ld c, a
	ldh a, [$ffbe]
	ld b, a
	ld hl, $fe9a
	add hl, bc
	ld a, l
	ldh [$ffbd], a
	ld a, h
	ldh [$ffbe], a
	ld a, h
	cp b
	ret c
	ld hl, $ffb6
	set 6, [hl]
	ret
Func_03_56df:
	ldh a, [$ffbd]
	ld c, a
	ldh a, [$ffbe]
	ld b, a
	ld hl, $0200
	add hl, bc
	ld a, l
	ldh [$ffbd], a
	ld a, h
	ldh [$ffbe], a
	ld a, h
	cp b
	ret nc
	ld hl, $ffb6
	set 6, [hl]
	ret
Func_03_56f8:
	ldh a, [$ffbd]
	ld c, a
	ldh a, [$ffbe]
	ld b, a
	ld hl, $fe00
	add hl, bc
	ld a, l
	ldh [$ffbd], a
	ld a, h
	ldh [$ffbe], a
	ld a, h
	cp b
	ret c
	ld hl, $ffb6
	set 6, [hl]
	ret
Func_03_5711:
	ldh a, [$ffbb]
	ld c, a
	ldh a, [$ffbc]
	ld b, a
	ld hl, $fe00
	add hl, bc
	ld a, l
	ldh [$ffbb], a
	ld a, h
	ldh [$ffbc], a
	ld a, h
	cp b
	ret c
	ld hl, $ffb6
	set 6, [hl]
	ret
Func_03_572a:
	ldh a, [$ffbb]
	ld c, a
	ldh a, [$ffbc]
	ld b, a
	ld hl, $0200
	add hl, bc
	ld a, l
	ldh [$ffbb], a
	ld a, h
	ldh [$ffbc], a
	ld a, h
	cp b
	ret nc
	ld hl, $ffb6
	set 6, [hl]
	ret
	ldh a, [$ffbb]
	ld l, a
	ldh a, [$ffbc]
	ld h, a
	ld bc, $0300
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	ld a, l
	ldh [$ffbb], a
	ld a, h
	ldh [$ffbc], a
	jr Func_03_5786
	ldh a, [$ffbb]
	ld l, a
	ldh a, [$ffbc]
	ld h, a
	ld bc, $0200
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	ld a, l
	ldh [$ffbb], a
	ld a, h
	ldh [$ffbc], a
	jr Func_03_5786
	ldh a, [$ffbb]
	ld l, a
	ldh a, [$ffbc]
	ld h, a
	ld bc, $0100
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	ld a, l
	ldh [$ffbb], a
	ld a, h
	ldh [$ffbc], a
Func_03_5786:
	ldh a, [$ffbd]
	ld l, a
	ldh a, [$ffbe]
	ld h, a
	ld bc, $0100
	add hl, bc
	ld a, l
	ldh [$ffbd], a
	ld a, h
	ldh [$ffbe], a
	ret
	ldh a, [$ffbd]
	ld l, a
	ldh a, [$ffbe]
	ld h, a
	ld bc, $0100
	add hl, bc
	ld a, l
	ldh [$ffbd], a
	ld a, h
	ldh [$ffbe], a
	cp $80
	jr nz, Func_03_57b0
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_57b0:
	xor a
	ldh [$ffb8], a
	ret
	ld a, $78
	ldh [$ffc3], a
	xor a
	ldh [$ffc4], a
	ret
Func_03_57bc:
	ldh a, [$ffc3]
	ld l, a
	ldh a, [$ffc4]
	ld h, a
	or l
	ret z
	dec hl
	ld a, l
	ldh [$ffc3], a
	ld a, h
	ldh [$ffc4], a
	ret
	ld hl, $ffc1
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	or b
	jr z, Func_03_57da
	dec bc
	ld a, b
	ld [hl-], a
	ld [hl], c
	ret
Func_03_57da:
	ldh a, [$ffb6]
	ld c, a
	push de
	ld a, $01
	ld hl, Func_01_42b3
	call CallBankedHL
	pop de
	ld a, c
	ldh [$ffc1], a
	ld a, b
	ldh [$ffc2], a
	ldh a, [$ffb5]
	cp $01
	jr z, Func_03_5809
	cp $02
	jr z, Func_03_5813
	cp $03
	jr z, Func_03_581b
	cp $04
	jr z, Func_03_5821
	cp $05
	jr z, Func_03_582b
	ldh a, [$ffd0]
	and $03
	jr Func_03_5831
Func_03_5809:
	ldh a, [$ffd0]
	and $0c
	sra a
	sra a
	jr Func_03_5831
Func_03_5813:
	ldh a, [$ffd0]
	and $30
	swap a
	jr Func_03_5831
Func_03_581b:
	ldh a, [$ffd1]
	and $03
	jr Func_03_5831
Func_03_5821:
	ldh a, [$ffd1]
	and $0c
	sra a
	sra a
	jr Func_03_5831
Func_03_582b:
	ldh a, [$ffd1]
	and $30
	swap a
Func_03_5831:
	call Func_03_5840
	ldh a, [$ffb5]
	inc a
	ldh [$ffb5], a
	cp $06
	ret nz
	xor a
	ldh [$ffb5], a
	ret
Func_03_5840:
	cp $03
	ret z
	push de
	push hl
	push af
	ld hl, $c4cd
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	add a, $30
	push af
	push af
	ldh a, [$ffbc]
	ld e, a
	ldh a, [$ffbe]
	ld d, a
	ldh a, [$ffe5]
	ld c, a
	ldh a, [$ffe6]
	ld b, a
	pop af
	call SpawnEntity
	pop af
	call Func_03_5878
	call Func_03_58af
	pop af
	call Func_03_5899
	call Func_03_58df
	call Func_03_58ef
	pop hl
	pop de
	ret
Func_03_5878:
	push hl
	sub $30
	add a, a
	ld hl, $5893
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	pop hl
	push hl
	ld de, $0018
	add hl, de
	ld a, c
	ld [hl+], a
	ld [hl], b
	pop hl
	ret

SECTION "room_00d893", ROMX[$5893], BANK[$03]

Data_03_5893:
	db $46, $75, $df, $75, $71, $76

SECTION "room_00d899", ROMX[$5899], BANK[$03]

Func_03_5899:
	push af
	ldh a, [$ffb6]
	and $e0
	sra a
	or $80
	ld b, a
	pop af
	and $03
	or b
	push hl
	ld de, $0020
	add hl, de
	ld [hl], a
	pop hl
	ret
Func_03_58af:
	push hl
	ldh a, [$ffb6]
	and $1c
	sra a
	sra a
	sla a
	ld c, a
	ld b, $00
	ld hl, $58cf
	add hl, bc
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	pop hl
	push hl
	ld de, $0011
	add hl, de
	ld a, c
	ld [hl+], a
	ld [hl], b
	pop hl
	ret

SECTION "room_00d8cf", ROMX[$58cf], BANK[$03]

Data_03_58cf:
	db $40, $01, $80, $02, $c0, $03, $00, $05

SECTION "room_00d8d7", ROMX[$58d7], BANK[$03]

Data_03_58d7:
	db $40, $06, $80, $07, $c0, $08, $00, $0a

SECTION "room_00d8df", ROMX[$58df], BANK[$03]

Func_03_58df:
	ldh a, [$ffb6]
	and $e0
	swap a
	sra a
	push hl
	ld de, $0021
	add hl, de
	ld [hl], a
	pop hl
	ret
Func_03_58ef:
	push hl
	ld de, $0006
	add hl, de
	ld b, [hl]
	ldh a, [$ffb6]
	and $03
	or a
	jr z, Func_03_590b
	cp $01
	jr z, Func_03_5907
	ldh a, [$ffb5]
	and $01
	or a
	jr z, Func_03_590b
Func_03_5907:
	set 7, b
	jr Func_03_590b
Func_03_590b:
	ld [hl], b
	pop hl
	ret
Func_03_590e:
	ld hl, $ffc1
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	or b
	jr z, Func_03_591c
	dec bc
	ld a, b
	ld [hl-], a
	ld [hl], c
	ret
Func_03_591c:
	ldh a, [$ffb0]
	sub $30
	add a, a
	ld c, a
	ld b, $00
	ld hl, $5932
	add hl, bc
	ld a, [hl+]
	ldh [$ffc8], a
	ld a, [hl]
	ldh [$ffc9], a
	xor a
	ldh [$ffc6], a
	ret

SECTION "room_00d932", ROMX[$5932], BANK[$03]

Data_03_5932:
	db $63, $75, $0c, $76, $9f, $76

SECTION "room_00d938", ROMX[$5938], BANK[$03]

Func_03_5938:
	call Func_03_59aa
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_594a
	cp $01
	jr z, Func_03_594e
	cp $02
	jr z, Func_03_5952
	ret
Func_03_594a:
	ld de, $75d1
	ret
Func_03_594e:
	ld de, $759b
	ret

SECTION "room_00d952", ROMX[$5952], BANK[$03]

Func_03_5952:
	ld de, $75b5
	ret

SECTION "room_00d956", ROMX[$5956], BANK[$03]

Func_03_5956:
	call Func_03_59aa
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_5970
	cp $01
	jr z, Func_03_5974
	cp $02
	jr z, Func_03_5978
	cp $03
	jr z, Func_03_597c
	cp $04
	jr z, Func_03_5980
	ret
Func_03_5970:
	ld de, $75d1
	ret
Func_03_5974:
	ld de, $759b
	ret
Func_03_5978:
	ld de, $75b5
	ret
Func_03_597c:
	ld de, $757c
	ret
Func_03_5980:
	ld de, $75fc
	ret
	call Func_03_59aa
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_599a
	cp $01
	jr z, Func_03_599e
	cp $02
	jr z, Func_03_59a2
	cp $03
	jr z, Func_03_59a6
	ret

SECTION "room_00d99a", ROMX[$599a], BANK[$03]

Func_03_599a:
	ld de, $75d1
	ret

SECTION "room_00d99e", ROMX[$599e], BANK[$03]

Func_03_599e:
	ld de, $759b
	ret
Func_03_59a2:
	ld de, $75b5
	ret
Func_03_59a6:
	ld de, $757c
	ret
Func_03_59aa:
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_59b6
	ld a, $ff
	ldh [$ffb8], a
	ret
Func_03_59b6:
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffbc]
	ld c, a
	ldh a, [$ffd2]
	add a, c
	ld c, a
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_59cc
	ldh a, [$ffd4]
	add a, c
	ld c, a
	jr Func_03_59cd
Func_03_59cc:
	dec c
Func_03_59cd:
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jr nz, Func_03_5a07
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffd5]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	jr z, Func_03_5a19
	call Func_03_5a1e
	or a
	jr nz, Func_03_5a02
	xor a
	ldh [$ffb8], a
	ret
Func_03_5a02:
	ld a, $04
	ldh [$ffb8], a
	ret
Func_03_5a07:
	cp $22
	jr z, Func_03_5a0f
	cp $23
	jr nz, Func_03_5a14
Func_03_5a0f:
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_5a14:
	ld a, $02
	ldh [$ffb8], a
	ret
Func_03_5a19:
	ld a, $03
	ldh [$ffb8], a
	ret
Func_03_5a1e:
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_5a2f
	ldh a, [$ffbc]
	ld c, a
	ld a, [$c805]
	cp c
	jr nc, Func_03_5a3a
	xor a
	ret
Func_03_5a2f:
	ldh a, [$ffbc]
	ld c, a
	ld a, [$c805]
	cp c
	jr c, Func_03_5a3a
	xor a
	ret
Func_03_5a3a:
	ld a, [$c807]
	ld b, a
	ldh a, [$ffbe]
	call OrderPair
	sub b
	cp $11
	jr c, Func_03_5a4a
	xor a
	ret
Func_03_5a4a:
	ld a, $01
	ret
	call Func_03_524b
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_5a5f
	cp $02
	jr z, Func_03_5a63
	cp $03
	jr z, Func_03_5a67
	ret
Func_03_5a5f:
	ld de, $7538
	ret
Func_03_5a63:
	ld de, $7522
	ret
Func_03_5a67:
	ld de, $7502
	ret
	call Func_03_5b38
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_5a81
	cp $01
	jr z, Func_03_5a85
	cp $02
	jr z, Func_03_5a89
	cp $03
	jr z, Func_03_5a8d
	ret
Func_03_5a81:
	ld de, $76ff
	ret
Func_03_5a85:
	ld de, $76d9
	ret
Func_03_5a89:
	ld de, $76d7
	ret

SECTION "room_00da8d", ROMX[$5a8d], BANK[$03]

Func_03_5a8d:
	ld de, $76b8
	ret

SECTION "room_00da91", ROMX[$5a91], BANK[$03]

Func_03_5a91:
	call Func_03_5abf
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_5aab
	cp $01
	jr z, Func_03_5aaf
	cp $02
	jr z, Func_03_5ab3
	cp $03
	jr z, Func_03_5ab7
	cp $04
	jr z, Func_03_5abb
	ret

SECTION "room_00daab", ROMX[$5aab], BANK[$03]

Func_03_5aab:
	ld de, $76ff
	ret

SECTION "room_00daaf", ROMX[$5aaf], BANK[$03]

Func_03_5aaf:
	ld de, $76d9
	ret
Func_03_5ab3:
	ld de, $76d7
	ret
Func_03_5ab7:
	ld de, $76b8
	ret
Func_03_5abb:
	ld de, $76a8
	ret
Func_03_5abf:
	call Func_03_5b38
	cp $ff
	ret z
	cp $02
	ret z
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffbc]
	ld c, a
	ldh a, [$ffd2]
	add a, c
	ld c, a
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_5ade
	ldh a, [$ffd4]
	add a, c
	ld c, a
	jr Func_03_5adf
Func_03_5ade:
	dec c
Func_03_5adf:
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jr nz, Func_03_5b15
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffd5]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	jr z, Func_03_5b22
	ldh a, [$ffc3]
	ld l, a
	ldh a, [$ffc4]
	or l
	ret z
	xor a
	ldh [$ffb8], a
	ret
Func_03_5b15:
	cp $22
	jr z, Func_03_5b1d
	cp $23
	jr nz, Func_03_5b22
Func_03_5b1d:
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_5b22:
	ldh a, [$ffb8]
	or a
	jr nz, Func_03_5b2c
	ld a, $03
	ldh [$ffb8], a
	ret
Func_03_5b2c:
	ldh a, [$ffc3]
	ld l, a
	ldh a, [$ffc4]
	or l
	ret z
	ld a, $04
	ldh [$ffb8], a
	ret
Func_03_5b38:
	call Func_03_57bc
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_5b47
	ld a, $ff
	ldh [$ffb8], a
	ret
Func_03_5b47:
	call Func_03_462f
	or a
	jr nz, Func_03_5b51
	xor a
	ldh [$ffb8], a
	ret
Func_03_5b51:
	call Func_03_46e2
	ld hl, $ffb6
	ldh a, [$ffb7]
	bit 1, a
	jr nz, Func_03_5b63
	bit 7, [hl]
	jr z, Func_03_5b6c
	jr Func_03_5b67
Func_03_5b63:
	bit 7, [hl]
	jr nz, Func_03_5b6c
Func_03_5b67:
	ld a, $02
	ldh [$ffb8], a
	ret
Func_03_5b6c:
	ld a, $01
	ldh [$ffb8], a
	ret
	call Func_03_5c42
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_5b87
	cp $01
	jr z, Func_03_5b8b
	cp $02
	jr z, Func_03_5b8f
	cp $03
	jr z, Func_03_5b93
	ret
Func_03_5b87:
	ld de, $7763
	ret
Func_03_5b8b:
	ld de, $7746
	ret

SECTION "room_00db8f", ROMX[$5b8f], BANK[$03]

Func_03_5b8f:
	ld de, $7723
	ret
Func_03_5b93:
	ld de, $7727
	ret

SECTION "room_00db97", ROMX[$5b97], BANK[$03]

Func_03_5b97:
	call Func_03_5c42
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_5bad
	cp $01
	jr z, Func_03_5bb1
	cp $02
	jr z, Func_03_5bb5
	cp $03
	jr z, Func_03_5bb9
	ret
Func_03_5bad:
	ld de, $7763
	ret
Func_03_5bb1:
	ld de, $7746
	ret

SECTION "room_00dbb5", ROMX[$5bb5], BANK[$03]

Func_03_5bb5:
	ld de, $7713
	ret
Func_03_5bb9:
	ld de, $7727
	ret

SECTION "room_00dbbd", ROMX[$5bbd], BANK[$03]

Func_03_5bbd:
	call Func_03_5be3
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_5bd3
	cp $01
	jr z, Func_03_5bd7
	cp $02
	jr z, Func_03_5bdb
	cp $03
	jr z, Func_03_5bdf
	ret

SECTION "room_00dbd3", ROMX[$5bd3], BANK[$03]

Func_03_5bd3:
	ld de, $7763
	ret

SECTION "room_00dbd7", ROMX[$5bd7], BANK[$03]

Func_03_5bd7:
	ld de, $7746
	ret
Func_03_5bdb:
	ld de, $7713
	ret
Func_03_5bdf:
	ld de, $7727
	ret
Func_03_5be3:
	call Func_03_5c42
	or a
	ret nz
	ld a, b
	ld [$cf65], a
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffbc]
	ld c, a
	ldh a, [$ffd2]
	add a, c
	ld c, a
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_5c02
	ldh a, [$ffd4]
	add a, c
	ld c, a
	jr Func_03_5c03
Func_03_5c02:
	dec c
Func_03_5c03:
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jr nz, Func_03_5c32
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffd5]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	jr z, Func_03_5c32
	xor a
	ldh [$ffb8], a
	ret
Func_03_5c32:
	ld a, [$cf65]
	or a
	jr z, Func_03_5c3d
	ld a, $02
	ldh [$ffb8], a
	ret
Func_03_5c3d:
	ld a, $03
	ldh [$ffb8], a
	ret
Func_03_5c42:
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_5c50
	ld a, $ff
	ldh [$ffb8], a
	ld b, $00
	ret
Func_03_5c50:
	call Func_03_465d
	or a
	jr nz, Func_03_5c5c
	xor a
	ldh [$ffb8], a
	ld b, $00
	ret
Func_03_5c5c:
	ld hl, $ffc3
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	or b
	jr z, Func_03_5c6f
	dec bc
	ld a, b
	ld [hl-], a
	ld [hl], c
	xor a
	ldh [$ffb8], a
	ld b, $01
	ret
Func_03_5c6f:
	ld a, $01
	ldh [$ffb8], a
	ld b, $01
	ret
Func_03_5c76:
	ldh a, [$ffbc]
	ld c, a
	ld hl, $ffb6
	ld a, [$c805]
	cp c
	jr c, Func_03_5c85
	res 7, [hl]
	ret
Func_03_5c85:
	set 7, [hl]
	ret
	call Func_03_52d0
	call Func_03_5c76
	ldh a, [$ffb8]
	cp $01
	jr z, Func_03_5c9d
	cp $02
	jr z, Func_03_5ca1
	cp $03
	jr z, Func_03_5ca5
	ret
Func_03_5c9d:
	ld de, $7824
	ret
Func_03_5ca1:
	ld de, $7837
	ret

SECTION "room_00dca5", ROMX[$5ca5], BANK[$03]

Func_03_5ca5:
	ld de, $7807
	ret

SECTION "room_00dca9", ROMX[$5ca9], BANK[$03]

Func_03_5ca9:
	call Func_03_529a
	ldh a, [$ffb8]
	cp $03
	ret nz
	ld de, $7793
	ret
	call Func_03_529a
	ldh a, [$ffb8]
	cp $03
	ret nz
	ld de, $77c2
	ret
	call Func_03_663c
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_5ccf
	cp $01
	jr z, Func_03_5cd3
	ret
Func_03_5ccf:
	ld de, $7897
	ret
Func_03_5cd3:
	ld de, $788b
	ret
	call Func_03_663c
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_5ce9
	cp $01
	jr z, Func_03_5ced
	cp $03
	jr z, Func_03_5cf1
	ret

SECTION "room_00dce9", ROMX[$5ce9], BANK[$03]

Func_03_5ce9:
	ld de, $7897
	ret

SECTION "room_00dced", ROMX[$5ced], BANK[$03]

Func_03_5ced:
	ld de, $788b
	ret
Func_03_5cf1:
	ld de, $786c
	ret
	call Func_03_663c
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_5d03
	cp $02
	jr z, Func_03_5d07
	ret
Func_03_5d03:
	ld de, $7897
	ret
Func_03_5d07:
	ld de, $785c
	ret
	call Func_03_6688
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_5d19
	cp $03
	jr z, Func_03_5d1d
	ret
Func_03_5d19:
	ld de, $78ba
	ret
Func_03_5d1d:
	ld de, $78b5
	ret
	ldh a, [$ffb6]
	bit 2, a
	jr z, Func_03_5d2b
	call Func_03_5d2f
	ret
Func_03_5d2b:
	call Func_03_5d4d
	ret
Func_03_5d2f:
	and $03
	cp $00
	jr z, Func_03_5d41
	cp $01
	jr z, Func_03_5d45
	cp $02
	jr z, Func_03_5d49
	ld de, $792c
	ret
Func_03_5d41:
	ld de, $78df
	ret
Func_03_5d45:
	ld de, $7900
	ret

SECTION "room_00dd49", ROMX[$5d49], BANK[$03]

Func_03_5d49:
	ld de, $790b
	ret

SECTION "room_00dd4d", ROMX[$5d4d], BANK[$03]

Func_03_5d4d:
	and $03
	cp $00
	jr z, Func_03_5d5f
	cp $01
	jr z, Func_03_5d63
	cp $02
	jr z, Func_03_5d67
	ld de, $7916
	ret
Func_03_5d5f:
	ld de, $78f5
	ret
Func_03_5d63:
	ld de, $78ea
	ret
Func_03_5d67:
	ld de, $7921
	ret
	ldh a, [$ffb6]
	bit 2, a
	jr nz, Func_03_5d7d
	bit 3, a
	jr z, Func_03_5d79
	call Func_03_5de3
	ret
Func_03_5d79:
	call Func_03_61bb
	ret
Func_03_5d7d:
	bit 3, a
	jr z, Func_03_5d85
	call Func_03_5e5e
	ret
Func_03_5d85:
	call Func_03_61e6
	ret
	ldh a, [$ffb6]
	bit 2, a
	jr nz, Func_03_5d9b
	bit 3, a
	jr z, Func_03_5d97
	call Func_03_5ed9
	ret
Func_03_5d97:
	call Func_03_6211
	ret
Func_03_5d9b:
	bit 3, a
	jr z, Func_03_5da3
	call Func_03_5f54
	ret
Func_03_5da3:
	call Func_03_623c
	ret
	ldh a, [$ffb6]
	bit 2, a
	jr nz, Func_03_5db9
	bit 3, a
	jr z, Func_03_5db5
	call Func_03_5fcf
	ret
Func_03_5db5:
	call Func_03_6267
	ret
Func_03_5db9:
	bit 3, a
	jr z, Func_03_5dc1
	call Func_03_604a
	ret
Func_03_5dc1:
	call Func_03_6292
	ret
	ldh a, [$ffb6]
	bit 2, a
	jr nz, Func_03_5dd7
	bit 3, a
	jr z, Func_03_5dd3
	call Func_03_60c5
	ret
Func_03_5dd3:
	call Func_03_62bd
	ret
Func_03_5dd7:
	bit 3, a
	jr z, Func_03_5ddf
	call Func_03_6140
	ret
Func_03_5ddf:
	call Func_03_62e8
	ret
Func_03_5de3:
	ldh a, [$ffbc]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_03_5e4e
	ldh a, [$ffbe]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [$ffbc]
	sub $08
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_03_5e48
	inc c
	inc c
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	or a
	ret nz
	ld de, $7921
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	ld [hl], a
	call Func_03_6313
	ret
Func_03_5e48:
	ld hl, $ffb6
	res 3, [hl]
	ret
Func_03_5e4e:
	ld de, $7916
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	ld [hl], a
	call Func_03_6329
	ret
Func_03_5e5e:
	ldh a, [$ffbc]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_03_5ec9
	ldh a, [$ffbe]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [$ffbc]
	sub $08
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_03_5ec3
	inc c
	inc c
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	or a
	ret nz
	ld de, $792c
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	ld [hl], a
	call Func_03_6313
	ret
Func_03_5ec3:
	ld hl, $ffb6
	res 3, [hl]
	ret
Func_03_5ec9:
	ld de, $790b
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	ld [hl], a
	call Func_03_6329
	ret
Func_03_5ed9:
	ldh a, [$ffbc]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_03_5f44
	ldh a, [$ffbe]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [$ffbc]
	add a, $07
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_03_5f3e
	dec c
	dec c
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	or a
	ret nz
	ld de, $7916
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	ld [hl], a
	call Func_03_6329
	ret
Func_03_5f3e:
	ld hl, $ffb6
	res 3, [hl]
	ret
Func_03_5f44:
	ld de, $7921
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	ld [hl], a
	call Func_03_6313
	ret
Func_03_5f54:
	ldh a, [$ffbc]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_03_5fbf
	ldh a, [$ffbe]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [$ffbc]
	add a, $07
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_03_5fb9
	dec c
	dec c
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	or a
	ret nz
	ld de, $790b
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	ld [hl], a
	call Func_03_6329
	ret
Func_03_5fb9:
	ld hl, $ffb6
	res 3, [hl]
	ret
Func_03_5fbf:
	ld de, $792c
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	ld [hl], a
	call Func_03_6313
	ret
Func_03_5fcf:
	ldh a, [$ffbc]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_03_603a
	ldh a, [$ffbc]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [$ffbe]
	add a, $07
	ld b, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_03_6034
	dec b
	dec b
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret nz
	ld de, $78ea
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	ld [hl], a
	call Func_03_6355
	ret
Func_03_6034:
	ld hl, $ffb6
	res 3, [hl]
	ret
Func_03_603a:
	ld de, $78f5
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	ld [hl], a
	call Func_03_633f
	ret
Func_03_604a:
	ldh a, [$ffbc]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_03_60b5
	ldh a, [$ffbc]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [$ffbe]
	add a, $07
	ld b, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_03_60af
	dec b
	dec b
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret nz
	ld de, $78df
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	ld [hl], a
	call Func_03_6355
	ret
Func_03_60af:
	ld hl, $ffb6
	res 3, [hl]
	ret
Func_03_60b5:
	ld de, $7900
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	ld [hl], a
	call Func_03_633f
	ret
Func_03_60c5:
	ldh a, [$ffbc]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_03_6130
	ldh a, [$ffbc]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [$ffbe]
	sub $08
	ld b, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_03_612a
	inc b
	inc b
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret nz
	ld de, $78f5
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	ld [hl], a
	call Func_03_633f
	ret
Func_03_612a:
	ld hl, $ffb6
	res 3, [hl]
	ret
Func_03_6130:
	ld de, $78ea
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	ld [hl], a
	call Func_03_6355
	ret
Func_03_6140:
	ldh a, [$ffbc]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_03_61ab
	ldh a, [$ffbc]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [$ffbe]
	sub $08
	ld b, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_03_61a5
	inc b
	inc b
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret nz
	ld de, $7900
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	ld [hl], a
	call Func_03_633f
	ret
Func_03_61a5:
	ld hl, $ffb6
	res 3, [hl]
	ret
Func_03_61ab:
	ld de, $78df
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	ld [hl], a
	call Func_03_6355
	ret
Func_03_61bb:
	ldh a, [$ffbc]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	ld de, $7916
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	set 3, a
	ld [hl], a
	call Func_03_6329
	ret
Func_03_61e6:
	ldh a, [$ffbc]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	ld de, $790b
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	set 3, a
	ld [hl], a
	call Func_03_6329
	ret
Func_03_6211:
	ldh a, [$ffbc]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	ld de, $7921
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	set 3, a
	ld [hl], a
	call Func_03_6313
	ret
Func_03_623c:
	ldh a, [$ffbc]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	ld de, $792c
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	set 3, a
	ld [hl], a
	call Func_03_6313
	ret
Func_03_6267:
	ldh a, [$ffbc]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	ld de, $78f5
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	set 3, a
	ld [hl], a
	call Func_03_633f
	ret
Func_03_6292:
	ldh a, [$ffbc]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	ld de, $7900
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	set 3, a
	ld [hl], a
	call Func_03_633f
	ret
Func_03_62bd:
	ldh a, [$ffbc]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	ld de, $78ea
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	set 3, a
	ld [hl], a
	call Func_03_6355
	ret
Func_03_62e8:
	ldh a, [$ffbc]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	ld de, $78df
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	set 3, a
	ld [hl], a
	call Func_03_6355
	ret
Func_03_6313:
	ldh a, [$ffbc]
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	sub $08
	add a, $07
	ldh [$ffbc], a
	xor a
	ldh [$ffbb], a
	ret
Func_03_6329:
	ldh a, [$ffbc]
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	sub $08
	add a, $09
	ldh [$ffbc], a
	xor a
	ldh [$ffbb], a
	ret
Func_03_633f:
	ldh a, [$ffbe]
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	sub $08
	add a, $07
	ldh [$ffbe], a
	xor a
	ldh [$ffbd], a
	ret
Func_03_6355:
	ldh a, [$ffbe]
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	sub $08
	add a, $09
	ldh [$ffbe], a
	xor a
	ldh [$ffbd], a
	ret
	ld hl, $ffc3
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	or b
	jr z, Func_03_637c
	dec bc
	ld a, b
	ld [hl-], a
	ld [hl], c
	xor a
	ldh [$ffb8], a
	ret
Func_03_637c:
	ld a, $01
	ldh [$ffb8], a
	ret
	ld hl, $ffb6
	ld a, [hl]
	and $03
	cp $02
	jr z, Func_03_639f
	cp $03
	jr z, Func_03_63a5
	cp $01
	jr z, Func_03_6399
	res 7, [hl]
	ld de, $7982
	ret
Func_03_6399:
	set 7, [hl]
	ld de, $7982
	ret

SECTION "room_00e39f", ROMX[$639f], BANK[$03]

Func_03_639f:
	res 7, [hl]
	ld de, $7995
	ret

SECTION "room_00e3a5", ROMX[$63a5], BANK[$03]

Func_03_63a5:
	set 7, [hl]
	ld de, $7995
	ret
	ldh a, [$ffb6]
	and $03
	cp $02
	jr z, Func_03_63bb
	cp $03
	jr z, Func_03_63bb
	ld de, $79cd
	ret
Func_03_63bb:
	ld de, $79d6
	ret
Func_03_63bf:
	push hl
	ld de, $0018
	add hl, de
	ld a, $ec
	ld [hl+], a
	ld a, $79
	ld [hl], a
	pop hl
	push hl
	ld de, $0016
	add hl, de
	xor a
	ld [hl], a
	pop hl
	ret
Func_03_63d4:
	push hl
	ld de, $0018
	add hl, de
	ld a, $2c
	ld [hl+], a
	ld a, $7a
	ld [hl], a
	pop hl
	push hl
	ld de, $0016
	add hl, de
	xor a
	ld [hl], a
	pop hl
	ret
	call Func_03_64a3
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_63ff
	cp $01
	jr z, Func_03_6403
	cp $02
	jr z, Func_03_6407
	cp $03
	jr z, Func_03_640b
	ret
Func_03_63ff:
	ld de, $7663
	ret
Func_03_6403:
	ld de, $7646
	ret
Func_03_6407:
	ld de, $7644
	ret

SECTION "room_00e40b", ROMX[$640b], BANK[$03]

Func_03_640b:
	ld de, $7625
	ret

SECTION "room_00e40f", ROMX[$640f], BANK[$03]

Func_03_640f:
	call Func_03_643d
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_6429
	cp $01
	jr z, Func_03_642d
	cp $02
	jr z, Func_03_6431
	cp $03
	jr z, Func_03_6435
	cp $04
	jr z, Func_03_6439
	ret
Func_03_6429:
	ld de, $7663
	ret
Func_03_642d:
	ld de, $7646
	ret
Func_03_6431:
	ld de, $7644
	ret
Func_03_6435:
	ld de, $7625
	ret
Func_03_6439:
	ld de, $7615
	ret
Func_03_643d:
	call Func_03_64a3
	cp $ff
	ret z
	cp $02
	ret z
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffbc]
	ld c, a
	ldh a, [$ffd2]
	add a, c
	ld c, a
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_645c
	ldh a, [$ffd4]
	add a, c
	ld c, a
	jr Func_03_645d
Func_03_645c:
	dec c
Func_03_645d:
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jr nz, Func_03_6480
	ldh a, [$ffc3]
	ld l, a
	ldh a, [$ffc4]
	or l
	ret z
	xor a
	ldh [$ffb8], a
	ret
Func_03_6480:
	cp $22
	jr z, Func_03_6488
	cp $23
	jr nz, Func_03_648d
Func_03_6488:
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_648d:
	ldh a, [$ffb8]
	or a
	jr nz, Func_03_6497
	ld a, $03
	ldh [$ffb8], a
	ret
Func_03_6497:
	ldh a, [$ffc3]
	ld l, a
	ldh a, [$ffc4]
	or l
	ret z
	ld a, $04
	ldh [$ffb8], a
	ret
Func_03_64a3:
	call Func_03_57bc
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_64b2
	ld a, $ff
	ldh [$ffb8], a
	ret
Func_03_64b2:
	call Func_03_462f
	or a
	jr nz, Func_03_64bc
	xor a
	ldh [$ffb8], a
	ret
Func_03_64bc:
	call Func_03_46e2
	ldh a, [$ffb7]
	bit 1, a
	jr nz, Func_03_64cd
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_64d8
	jr Func_03_64d3
Func_03_64cd:
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_64d8
Func_03_64d3:
	ld a, $02
	ldh [$ffb8], a
	ret
Func_03_64d8:
	ld a, $01
	ldh [$ffb8], a
	ret
	call Func_03_65ae
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_64f3
	cp $01
	jr z, Func_03_64f7
	cp $02
	jr z, Func_03_64fb
	cp $03
	jr z, Func_03_64ff
	ret

SECTION "room_00e4f3", ROMX[$64f3], BANK[$03]

Func_03_64f3:
	ld de, $7aa9
	ret
Func_03_64f7:
	ld de, $7a8c
	ret
Func_03_64fb:
	ld de, $7a69
	ret
Func_03_64ff:
	ld de, $7a6d
	ret

SECTION "room_00e503", ROMX[$6503], BANK[$03]

Func_03_6503:
	call Func_03_65ae
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_6519
	cp $01
	jr z, Func_03_651d
	cp $02
	jr z, Func_03_6521
	cp $03
	jr z, Func_03_6525
	ret

SECTION "room_00e519", ROMX[$6519], BANK[$03]

Func_03_6519:
	ld de, $7aa9
	ret
Func_03_651d:
	ld de, $7a8c
	ret
Func_03_6521:
	ld de, $7a59
	ret
Func_03_6525:
	ld de, $7a6d
	ret

SECTION "room_00e529", ROMX[$6529], BANK[$03]

Func_03_6529:
	call Func_03_654f
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_653f
	cp $01
	jr z, Func_03_6543
	cp $02
	jr z, Func_03_6547
	cp $03
	jr z, Func_03_654b
	ret

SECTION "room_00e53f", ROMX[$653f], BANK[$03]

Func_03_653f:
	ld de, $7aa9
	ret
Func_03_6543:
	ld de, $7a8c
	ret
Func_03_6547:
	ld de, $7a59
	ret

SECTION "room_00e54b", ROMX[$654b], BANK[$03]

Func_03_654b:
	ld de, $7a6d
	ret
Func_03_654f:
	call Func_03_65ae
	or a
	ret nz
	ld a, b
	ld [$cf65], a
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffbc]
	ld c, a
	ldh a, [$ffd2]
	add a, c
	ld c, a
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_656e
	ldh a, [$ffd4]
	add a, c
	ld c, a
	jr Func_03_656f
Func_03_656e:
	dec c
Func_03_656f:
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jr nz, Func_03_659e
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffd5]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	jr z, Func_03_659e
	xor a
	ldh [$ffb8], a
	ret
Func_03_659e:
	ld a, [$cf65]
	or a
	jr z, Func_03_65a9

SECTION "room_00e5a4", ROMX[$65a4], BANK[$03]

Data_03_65a4:
	db $3e, $02, $e0, $b8, $c9

SECTION "room_00e5a9", ROMX[$65a9], BANK[$03]

Func_03_65a9:
	ld a, $03
	ldh [$ffb8], a
	ret
Func_03_65ae:
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_65bc

SECTION "room_00e5b5", ROMX[$65b5], BANK[$03]

Data_03_65b5:
	db $3e, $ff, $e0, $b8, $06, $00, $c9

SECTION "room_00e5bc", ROMX[$65bc], BANK[$03]

Func_03_65bc:
	xor a
	ldh [$ffb8], a
	ld b, $00
	ret

SECTION "room_00e5c2", ROMX[$65c2], BANK[$03]

Data_03_65c2:
	db $21, $c3, $ff, $2a, $4f, $46, $b0, $28, $0a, $0b, $78, $32, $71, $af, $e0, $b8
	db $06, $01, $c9, $3e, $01, $e0, $b8, $06, $01, $c9

SECTION "room_00e5dc", ROMX[$65dc], BANK[$03]

Func_03_65dc:
	call Func_03_663c
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_65ea
	cp $01
	jr z, Func_03_65ee
	ret
Func_03_65ea:
	ld de, $7b00
	ret

SECTION "room_00e5ee", ROMX[$65ee], BANK[$03]

Func_03_65ee:
	ld de, $7af4
	ret

SECTION "room_00e5f2", ROMX[$65f2], BANK[$03]

Func_03_65f2:
	call Func_03_663c
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_6604
	cp $01
	jr z, Func_03_6608
	cp $03
	jr z, Func_03_660c
	ret

SECTION "room_00e604", ROMX[$6604], BANK[$03]

Func_03_6604:
	ld de, $7b00
	ret

SECTION "room_00e608", ROMX[$6608], BANK[$03]

Func_03_6608:
	ld de, $7af4
	ret
Func_03_660c:
	ld de, $7ad5
	ret
	call Func_03_663c
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_661e
	cp $02
	jr z, Func_03_6622
	ret

SECTION "room_00e61e", ROMX[$661e], BANK[$03]

Func_03_661e:
	ld de, $7b00
	ret
Func_03_6622:
	ld de, $7ac5
	ret
	call Func_03_6688
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_6634
	cp $03
	jr z, Func_03_6638
	ret
Func_03_6634:
	ld de, $7b23
	ret
Func_03_6638:
	ld de, $7b1e
	ret

SECTION "room_00e63c", ROMX[$663c], BANK[$03]

Func_03_663c:
	call Func_03_66c7
	cp $ff
	ret z
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffbc]
	ld c, a
	ldh a, [$ffd2]
	add a, c
	ld c, a
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_6658
	ldh a, [$ffd4]
	add a, c
	ld c, a
	jr Func_03_6659
Func_03_6658:
	dec c
Func_03_6659:
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jr nz, Func_03_6683
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffd5]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret nz
Func_03_6683:
	ld a, $03
	ldh [$ffb8], a
	ret
Func_03_6688:
	call Func_03_66c7
	cp $ff
	ret z
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffbc]
	ld c, a
	ldh a, [$ffd2]
	add a, c
	ld c, a
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_66a4
	ldh a, [$ffd4]
	add a, c
	ld c, a
	jr Func_03_66a5
Func_03_66a4:
	dec c
Func_03_66a5:
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret z
	cp $22
	ret z
	cp $23
	ret z
	ld a, $03
	ldh [$ffb8], a
	ret
Func_03_66c7:
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_66d6
	xor a
	ldh [$ffc3], a
	ld a, $ff
	ldh [$ffb8], a
	ret
Func_03_66d6:
	call Func_03_4694
	or a
	jr nz, Func_03_66ed
	ldh a, [$ffc3]
	or a
	jr z, Func_03_66e8
	dec a
	ldh [$ffc3], a
	xor a
	ldh [$ffb8], a
	ret
Func_03_66e8:
	ld a, $02
	ldh [$ffb8], a
	ret
Func_03_66ed:
	ld a, $3c
	ldh [$ffc3], a
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_66f6:
	push hl
	ld de, $0018
	add hl, de
	ld a, $a5
	ld [hl+], a
	ld a, $78
	ld [hl], a
	pop hl
	jr Func_03_6710

SECTION "room_00e704", ROMX[$6704], BANK[$03]

Func_03_6704:
	push hl
	ld de, $0018
	add hl, de
	ld a, $0e
	ld [hl+], a
	ld a, $7b
	ld [hl], a
	pop hl

SECTION "room_00e710", ROMX[$6710], BANK[$03]

Func_03_6710:
	push hl
	ld de, $0016
	add hl, de
	xor a
	ld [hl], a
	pop hl
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_6727
	push hl
	ld de, $0006
	add hl, de
	set 7, [hl]
	pop hl
	ret
Func_03_6727:
	push hl
	ld de, $0006
	add hl, de
	res 7, [hl]
	pop hl
	ret
	push de
	ldh a, [$ffbc]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [$ffbe]
	inc a
	add a, $08
	swap a
	and $0f
	ld b, a
	call BreakTileAtCell
	pop de
	ret
	call Func_03_6803
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_675f
	cp $01
	jr z, Func_03_6763
	cp $02
	jr z, Func_03_6767
	cp $03
	jr z, Func_03_676b
	ret

SECTION "room_00e75f", ROMX[$675f], BANK[$03]

Func_03_675f:
	ld de, $7d06
	ret
Func_03_6763:
	ld de, $7ce0
	ret
Func_03_6767:
	ld de, $7cde
	ret
Func_03_676b:
	ld de, $7cbf
	ret

SECTION "room_00e76f", ROMX[$676f], BANK[$03]

Func_03_676f:
	call Func_03_679d
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_6789
	cp $01
	jr z, Func_03_678d
	cp $02
	jr z, Func_03_6791
	cp $03
	jr z, Func_03_6795
	cp $04
	jr z, Func_03_6799
	ret

SECTION "room_00e789", ROMX[$6789], BANK[$03]

Func_03_6789:
	ld de, $7d06
	ret

SECTION "room_00e78d", ROMX[$678d], BANK[$03]

Func_03_678d:
	ld de, $7ce0
	ret

SECTION "room_00e791", ROMX[$6791], BANK[$03]

Func_03_6791:
	ld de, $7cde
	ret

SECTION "room_00e795", ROMX[$6795], BANK[$03]

Func_03_6795:
	ld de, $7cbf
	ret

SECTION "room_00e799", ROMX[$6799], BANK[$03]

Func_03_6799:
	ld de, $7caf
	ret

SECTION "room_00e79d", ROMX[$679d], BANK[$03]

Func_03_679d:
	call Func_03_6803
	cp $ff
	ret z
	cp $02
	ret z
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffbc]
	ld c, a
	ldh a, [$ffd2]
	add a, c
	ld c, a
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_67bc
	ldh a, [$ffd4]
	add a, c
	ld c, a
	jr Func_03_67bd
Func_03_67bc:
	dec c
Func_03_67bd:
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jr nz, Func_03_67e0
	ldh a, [$ffc3]
	ld l, a
	ldh a, [$ffc4]
	or l
	ret z
	xor a
	ldh [$ffb8], a
	ret
Func_03_67e0:
	cp $22
	jr z, Func_03_67e8
	cp $23
	jr nz, Func_03_67ed
Func_03_67e8:
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_67ed:
	ldh a, [$ffb8]
	or a
	jr nz, Func_03_67f7
	ld a, $03
	ldh [$ffb8], a
	ret

SECTION "room_00e7f7", ROMX[$67f7], BANK[$03]

Func_03_67f7:
	ldh a, [$ffc3]
	ld l, a
	ldh a, [$ffc4]
	or l
	ret z
	ld a, $04
	ldh [$ffb8], a
	ret

SECTION "room_00e803", ROMX[$6803], BANK[$03]

Func_03_6803:
	call Func_03_57bc
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_6812

SECTION "room_00e80d", ROMX[$680d], BANK[$03]

Data_03_680d:
	db $3e, $ff, $e0, $b8, $c9

SECTION "room_00e812", ROMX[$6812], BANK[$03]

Func_03_6812:
	xor a
	ldh [$ffb8], a
	ret

SECTION "room_00e816", ROMX[$6816], BANK[$03]

Data_03_6816:
	db $cd, $e2, $46, $f0, $b7, $cb, $4f, $20, $08, $f0, $b6, $cb, $7f, $28, $0d, $18
	db $06, $f0, $b6, $cb, $7f, $20, $05, $3e, $02, $e0, $b8, $c9, $3e, $01, $e0, $b8
	db $c9

SECTION "room_00e837", ROMX[$6837], BANK[$03]

Func_03_6837:
	call Func_03_59aa
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_6849
	cp $01
	jr z, Func_03_684d
	cp $02
	jr z, Func_03_6851
	ret

SECTION "room_00e849", ROMX[$6849], BANK[$03]

Func_03_6849:
	ld de, $7c80
	ret
Func_03_684d:
	ld de, $7c50
	ret
Func_03_6851:
	ld de, $7c67
	ret

SECTION "room_00e855", ROMX[$6855], BANK[$03]

Func_03_6855:
	call Func_03_59aa
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_686f
	cp $01
	jr z, Func_03_6873
	cp $02
	jr z, Func_03_6877
	cp $03
	jr z, Func_03_687b
	cp $04
	jr z, Func_03_687f
	ret

SECTION "room_00e86f", ROMX[$686f], BANK[$03]

Func_03_686f:
	ld de, $7c80
	ret
Func_03_6873:
	ld de, $7c50
	ret
Func_03_6877:
	ld de, $7c67
	ret

SECTION "room_00e87b", ROMX[$687b], BANK[$03]

Func_03_687b:
	ld de, $7c31
	ret
Func_03_687f:
	ld de, $7c8e
	ret
	call Func_03_59aa
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_6899
	cp $01
	jr z, Func_03_689d
	cp $02
	jr z, Func_03_68a1
	cp $03
	jr z, Func_03_68a5
	ret

SECTION "room_00e899", ROMX[$6899], BANK[$03]

Func_03_6899:
	ld de, $7c80
	ret
Func_03_689d:
	ld de, $7c50
	ret
Func_03_68a1:
	ld de, $7c67
	ret

SECTION "room_00e8a5", ROMX[$68a5], BANK[$03]

Func_03_68a5:
	ld de, $7c31
	ret
	call Func_03_59aa
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_68bb
	cp $01
	jr z, Func_03_68bf
	cp $02
	jr z, Func_03_68c3
	ret
Func_03_68bb:
	ld de, $7ba7
	ret

SECTION "room_00e8bf", ROMX[$68bf], BANK[$03]

Func_03_68bf:
	ld de, $7b77
	ret
Func_03_68c3:
	ld de, $7b8e
	ret

SECTION "room_00e8c7", ROMX[$68c7], BANK[$03]

Func_03_68c7:
	call Func_03_59aa
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_68e1
	cp $01
	jr z, Func_03_68e5
	cp $02
	jr z, Func_03_68e9
	cp $03
	jr z, Func_03_68ed
	cp $04
	jr z, Func_03_68f1
	ret

SECTION "room_00e8e1", ROMX[$68e1], BANK[$03]

Func_03_68e1:
	ld de, $7ba7
	ret

SECTION "room_00e8e5", ROMX[$68e5], BANK[$03]

Func_03_68e5:
	ld de, $7b77
	ret

SECTION "room_00e8e9", ROMX[$68e9], BANK[$03]

Func_03_68e9:
	ld de, $7b8e
	ret

SECTION "room_00e8ed", ROMX[$68ed], BANK[$03]

Func_03_68ed:
	ld de, $7b58
	ret
Func_03_68f1:
	ld de, $7bb5
	ret
	call Func_03_59aa
	ldh a, [$ffb8]
	cp $ff
	jr z, Func_03_690b
	cp $01
	jr z, Func_03_690f
	cp $02
	jr z, Func_03_6913
	cp $03
	jr z, Func_03_6917
	ret

SECTION "room_00e90b", ROMX[$690b], BANK[$03]

Func_03_690b:
	ld de, $7ba7
	ret
Func_03_690f:
	ld de, $7b77
	ret
Func_03_6913:
	ld de, $7b8e
	ret

SECTION "room_00e917", ROMX[$6917], BANK[$03]

Func_03_6917:
	ld de, $7b58
	ret
	call Func_03_524b
	ret
	push de
	ldh a, [$ffbc]
	ld c, a
	ldh a, [$ffbe]
	add a, $08
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call BreakTileAtCell
	pop bc
	ldh a, [$ffd2]
	add a, c
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call BreakTileAtCell
	pop bc
	ldh a, [$ffd4]
	add a, c
	dec a
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call BreakTileAtCell
	pop bc
	pop de
	ret
	xor a
	ld [$cf79], a
	ret
	ld a, $01
	ldh [$ffc1], a
	call Func_03_4a46
	ret
	xor a
	ldh [$ffc1], a
	call Func_03_4a46
	ret
	ldh a, [$ffc7]
	cp $3d
	jr z, Func_03_6983
	ld a, $11
	ldh [$ffbf], a
	ld a, $01
	ldh [$ffc0], a
	ret

SECTION "room_00e983", ROMX[$6983], BANK[$03]

Func_03_6983:
	ld a, $aa
	ldh [$ffbf], a
	ld a, $00
	ldh [$ffc0], a
	ret

SECTION "room_00e98c", ROMX[$698c], BANK[$03]

Func_03_698c:
	ldh a, [$ffc7]
	cp $3d
	jr z, Func_03_699b
	ld a, $aa
	ldh [$ffbf], a
	ld a, $00
	ldh [$ffc0], a
	ret
Func_03_699b:
	ld a, $22
	ldh [$ffbf], a
	ld a, $00
	ldh [$ffc0], a
	ret
	ld a, [$cf79]
	or a
	jr z, Func_03_69b3
	xor a
	ld [$cf79], a
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_69b3:
	ldh a, [$ffb6]
	bit 3, a
	jr nz, Func_03_69be
Func_03_69b9:
	ld a, $ff
	ldh [$ffb8], a
	ret
Func_03_69be:
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffbc]
	ld c, a
	ldh a, [$ffd2]
	add a, c
	ld c, a
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_69d4
	ldh a, [$ffd4]
	add a, c
	ld c, a
	jr Func_03_69d5
Func_03_69d4:
	dec c
Func_03_69d5:
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	cp $20
	jr z, Func_03_6a11
	ldh a, [$ffbe]
	ld b, a
	ldh a, [$ffd3]
	add a, b
	ld b, a
	ldh a, [$ffd5]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	jr z, Func_03_69b9
	cp $22
	jr z, Func_03_69b9
	cp $23
	jr z, Func_03_69b9
	xor a
	ldh [$ffb8], a
	ret
Func_03_6a11:
	ldh a, [$ffbe]
	cp $87
	jr z, Func_03_6a1c

SECTION "room_00ea17", ROMX[$6a17], BANK[$03]

Data_03_6a17:
	db $3e, $01, $e0, $b8, $c9

SECTION "room_00ea1c", ROMX[$6a1c], BANK[$03]

Func_03_6a1c:
	ld a, $02
	ldh [$ffb8], a
	ret
	push de
	ldh a, [$ffbc]
	ld c, a
	ldh a, [$ffd2]
	add a, c
	ld c, a
	ldh a, [$ffbe]
	add a, $08
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call BreakTileAtCell
	pop bc
	ld a, $10
	add a, c
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call BreakTileAtCell
	pop bc
	ldh a, [$ffbc]
	ld c, a
	ldh a, [$ffd2]
	add a, c
	ld c, a
	ldh a, [$ffd4]
	add a, c
	dec a
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call BreakTileAtCell
	pop bc
	ld a, c
	sub $10
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call BreakTileAtCell
	pop bc
	pop de
	ret
	ld a, [$cf77]
	cp $05
	jr z, Func_03_6a89
	xor a
	ldh [$ffb8], a
	ret
Func_03_6a89:
	ld a, $ff
	ldh [$ffb8], a
	ret
	ld a, $b4
	ld [$c2e5], a
	push af
	ld a, $15
	call PlaySound
	pop af
	ret
	ld bc, $0000
	ld a, $2d
	call Func_03_5394
	ld bc, $0000
	ld a, $2e
	call Func_03_5394
	ld bc, $0000
	ld a, $2f
	call Func_03_5394
	ret
	xor a
	ld [$cf77], a
	ret
	ld a, [$cf78]
	or a
	jr nz, Func_03_6ace
	ld a, [$cf77]
	or a
	jr nz, Func_03_6ac9
	xor a
	ldh [$ffb8], a
	ret
Func_03_6ac9:
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_6ace:
	ld a, $ff
	ldh [$ffb8], a
	ret
	ld a, $2c
	ldh [$ffc3], a
	ld a, $01
	ldh [$ffc4], a
	ret
	ld a, [$cf78]
	or a
	jr nz, Func_03_6af8
	ld hl, $ffc3
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	dec bc
	ld a, b
	ld [hl-], a
	ld [hl], c
	or c
	jr nz, Func_03_6af4
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_6af4:
	xor a
	ldh [$ffb8], a
	ret
Func_03_6af8:
	ld a, $ff
	ldh [$ffb8], a
	ret
	ldh a, [$ffbc]
	cpl
	add a, $90
	ld c, a
	ldh a, [$ffbe]
	cpl
	add a, $10
	ld b, a
	ld a, $2c
	call Func_03_5394
	ret
	ldh a, [$ffbc]
	cpl
	add a, $70
	ld c, a
	ldh a, [$ffbe]
	cpl
	add a, $10
	ld b, a
	ld a, $2c
	call Func_03_5394
	ret
	ldh a, [$ffbc]
	cpl
	add a, $50
	ld c, a
	ldh a, [$ffbe]
	cpl
	add a, $10
	ld b, a
	ld a, $2c
	call Func_03_5394
	ret
	ldh a, [$ffbc]
	cpl
	add a, $30
	ld c, a
	ldh a, [$ffbe]
	cpl
	add a, $10
	ld b, a
	ld a, $2c
	call Func_03_5394
	ret
	ldh a, [$ffbc]
	cpl
	add a, $10
	ld c, a
	ldh a, [$ffbe]
	cpl
	add a, $10
	ld b, a
	ld a, $2c
	call Func_03_5394
	ret
	xor a
	ld hl, $cf77
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ret
	ld hl, $ffbb
	xor a
	ld [hl+], a
	ld a, $80
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, $d0
	ld [hl], a
	ret
	ldh a, [$ffbe]
	inc a
	ldh [$ffbe], a
	cp $48
	jr nz, Func_03_6b89
	ld a, $48
	ldh [$ffbe], a
	ld a, $05
	ld [$c2dd], a
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_6b89:
	xor a
	ldh [$ffb8], a
	ret
	ld a, $01
	ld [$cf79], a
	ret
	ld a, [$cf79]
	or a
	jr z, Func_03_6ba2
	xor a
	ld [$cf79], a
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_6ba2:
	xor a
	ldh [$ffb8], a
	ret
	ld hl, $ffbb
	xor a
	ld [hl+], a
	ld a, $80
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, $48
	ld [hl], a
	ret
	ld a, [$cf79]
	or a
	jr z, Func_03_6bc8
	ld a, [$c2e2]
	cp $02
	jr z, Func_03_6be0
	xor a
	ld [$cf79], a
	ldh [$ffb8], a
	ret
Func_03_6bc8:
	ld a, [$c2e2]
	cp $02
	jr z, Func_03_6be4
	ld a, [$c2e4]
	cp $03
	jr nc, Func_03_6bdb
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_6bdb:
	ld a, $02
	ldh [$ffb8], a
	ret

SECTION "room_00ebe0", ROMX[$6be0], BANK[$03]

Func_03_6be0:
	xor a
	ldh [$ffb8], a
	ret

SECTION "room_00ebe4", ROMX[$6be4], BANK[$03]

Func_03_6be4:
	ld a, $ff
	ldh [$ffb8], a
	ret
	xor a
	ld [$cf7a], a
	ld a, [$c807]
	cp $48
	jr c, Func_03_6bfb
	ld a, $01
	ld [$cf7d], a
	jr Func_03_6bff
Func_03_6bfb:
	xor a
	ld [$cf7d], a
Func_03_6bff:
	xor a
	ld [$cf77], a
	call Func_03_6c07
	ret
Func_03_6c07:
	ld a, [$cf77]
	or a
	jr z, Func_03_6c1d
	cp $01
	jr z, Func_03_6c2b
	ld hl, $ffbb
	xor a
	ld [hl+], a
	ld a, $e8
	ld [hl], a
	call Func_03_6c37
	ret
Func_03_6c1d:
	ld hl, $ffbb
	xor a
	ld [hl+], a
	ld a, $80
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, $48
	ld [hl], a
	ret
Func_03_6c2b:
	ld hl, $ffbb
	xor a
	ld [hl+], a
	ld a, $18
	ld [hl], a
	call Func_03_6c37
	ret
Func_03_6c37:
	ld a, [$cf7d]
	or a
	jr z, Func_03_6c46
	ld hl, $ffbd
	xor a
	ld [hl+], a
	ld a, $70
	ld [hl], a
	ret
Func_03_6c46:
	ld hl, $ffbd
	xor a
	ld [hl+], a
	ld a, $20
	ld [hl], a
	ret
	ld a, [$cf7a]
	inc a
	ld [$cf7a], a
	bit 0, a
	ret z
	ld a, [$cf77]
	inc a
	cp $03
	jr nz, Func_03_6c62
	xor a
Func_03_6c62:
	ld [$cf77], a
	call Func_03_6c07
	ret
	ld a, [$c805]
	cp $80
	jr c, Func_03_6c83
	ld a, $02
	ld [$cf77], a
	ldh a, [$ffb6]
	and $fc
	or $01
	set 7, a
	ldh [$ffb6], a
	call Func_03_6c07
	ret
Func_03_6c83:
	ld a, $01
	ld [$cf77], a
	ldh a, [$ffb6]
	and $fc
	or $00
	res 7, a
	ldh [$ffb6], a
	call Func_03_6c07
	ret
	ld a, [$cf77]
	cp $01
	jr z, Func_03_6caf
	ldh a, [$ffbc]
	cp $19
	jr nc, Func_03_6cc1
	ld a, $18
	ldh [$ffbc], a
	xor a
	ldh [$ffbb], a
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_6caf:
	ldh a, [$ffbc]
	cp $e8
	jr c, Func_03_6cc1
	ld a, $e8
	ldh [$ffbc], a
	xor a
	ldh [$ffbb], a
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_6cc1:
	xor a
	ldh [$ffb8], a
	ret
Func_03_6cc5:
	ld a, [$c805]
	cp $80
	jr c, Func_03_6cd7
	ldh a, [$ffb6]
	and $fc
	or $00
	res 7, a
	ldh [$ffb6], a
	ret
Func_03_6cd7:
	ldh a, [$ffb6]
	and $fc
	or $01
	set 7, a
	ldh [$ffb6], a
	ret
	call Func_03_6cc5
	xor a
	ld [$cf7a], a
	ldh a, [$ffbc]
	ld [$cf8a], a
	ldh a, [$ffbe]
	ld [$cf8b], a
	ld a, [$c807]
	sub $18
	ld [$cf8d], a
	ldh a, [$ffb6]
	bit 7, a
	jr nz, Func_03_6d0a
	ld a, [$c805]
	sub $18
	ld [$cf8c], a
	ret
Func_03_6d0a:
	ld a, [$c805]
	add a, $18
	ld [$cf8c], a
	ret
	ld a, [$cf8a]
	ld b, a
	ld a, [$cf8c]
	sub b
	ld b, a
	ld c, $00
	sra b
	rr c
	sra b
	rr c
	sra b
	rr c
	sra b
	rr c
	sra b
	rr c
	ldh a, [$ffbb]
	ld l, a
	ldh a, [$ffbc]
	ld h, a
	add hl, bc
	ld a, l
	ldh [$ffbb], a
	ld a, h
	ldh [$ffbc], a
	ld a, [$cf8b]
	ld b, a
	ld a, [$cf8d]
	sub b
	ld b, a
	ld c, $00
	sra b
	rr c
	sra b
	rr c
	sra b
	rr c
	sra b
	rr c
	sra b
	rr c
	ldh a, [$ffbd]
	ld l, a
	ldh a, [$ffbe]
	ld h, a
	add hl, bc
	ld a, l
	ldh [$ffbd], a
	ld a, h
	ldh [$ffbe], a
	ld a, [$cf7a]
	inc a
	ld [$cf7a], a
	cp $20
	jr nz, Func_03_6d7b
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_6d7b:
	xor a
	ldh [$ffb8], a
	ret
	push de
	ldh a, [$ffbe]
	ld d, a
	ldh a, [$ffbc]
	ld e, a
	ld bc, $0000
	ld a, $3d
	call SpawnEntity
	push hl
	ld de, $0011
	add hl, de
	ldh a, [$ffbc]
	ld [hl+], a
	ldh a, [$ffbe]
	ld [hl], a
	pop hl
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_6da8
	push hl
	ld de, $0006
	add hl, de
	set 7, [hl]
	pop hl
Func_03_6da8:
	pop de
	ret
	ldh a, [$ffc1]
	ld c, a
	ldh a, [$ffc2]
	ld b, a
	ld a, b
	sub $18
	ldh [$ffbe], a
	xor a
	ldh [$ffbd], a
	ld a, c
	ldh [$ffbc], a
	ldh [$ffbb], a
	ret
	ldh a, [$ffc1]
	ld c, a
	ldh a, [$ffc2]
	ld b, a
	ld a, b
	sub $08
	ldh [$ffbe], a
	xor a
	ldh [$ffbd], a
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_6ddb
	ld a, c
	sub $10
	ldh [$ffbc], a
	xor a
	ldh [$ffbb], a
	ret
Func_03_6ddb:
	ld a, c
	add a, $10
	ldh [$ffbc], a
	xor a
	ldh [$ffbb], a
	ret
	ldh a, [$ffc1]
	ld c, a
	ldh a, [$ffc2]
	ld b, a
	ld a, b
	add a, $10
	ldh [$ffbe], a
	xor a
	ldh [$ffbd], a
	ldh a, [$ffb6]
	bit 7, a
	jr z, Func_03_6e01
	ld a, c
	sub $18
	ldh [$ffbc], a
	xor a
	ldh [$ffbb], a
	ret
Func_03_6e01:
	ld a, c
	add a, $18
	ldh [$ffbc], a
	xor a
	ldh [$ffbb], a
	ret
	xor a
	ld [$cf7b], a
	ld [$cf7a], a
	ret
Func_03_6e12:
	ld a, [$cf7b]
	ld c, a
	ld b, $00
	ld hl, $6ef5
	add hl, bc
	ld a, [hl]
	or a
	jr nz, Func_03_6e38
	ld a, c
	add a, a
	ld c, a
	ld hl, $6efb
	add hl, bc
	ld a, [hl+]
	ld b, [hl]
	ld c, a
	ldh a, [$ffbb]
	ld l, a
	ldh a, [$ffbc]
	ld h, a
	add hl, bc
	ld a, l
	ldh [$ffbb], a
	ld a, h
	ldh [$ffbc], a
	ret
Func_03_6e38:
	ld a, c
	add a, a
	ld c, a
	ld hl, $6efb
	add hl, bc
	ld a, [hl+]
	ld b, [hl]
	ld c, a
	ldh a, [$ffbb]
	ld l, a
	ldh a, [$ffbc]
	ld h, a
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	ld a, l
	ldh [$ffbb], a
	ld a, h
	ldh [$ffbc], a
	ret
Func_03_6e55:
	ld a, [$cf7b]
	ld c, a
	ld b, $00
	ld hl, $6f07
	add hl, bc
	ld a, [hl]
	or a
	jr nz, Func_03_6e7b
	ld a, c
	add a, a
	ld c, a
	ld hl, $6f0d
	add hl, bc
	ld a, [hl+]
	ld b, [hl]
	ld c, a
	ldh a, [$ffbd]
	ld l, a
	ldh a, [$ffbe]
	ld h, a
	add hl, bc
	ld a, l
	ldh [$ffbd], a
	ld a, h
	ldh [$ffbe], a
	ret
Func_03_6e7b:
	ld a, c
	add a, a
	ld c, a
	ld hl, $6f0d
	add hl, bc
	ld a, [hl+]
	ld b, [hl]
	ld c, a
	ldh a, [$ffbd]
	ld l, a
	ldh a, [$ffbe]
	ld h, a
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	ld a, l
	ldh [$ffbd], a
	ld a, h
	ldh [$ffbe], a
	ret
	ld a, [$cf78]
	or a
	jr nz, Func_03_6ec4
	call Func_03_6e12
	call Func_03_6e55
	ld a, [$cf7a]
	inc a
	ld [$cf7a], a
	cp $20
	jr nz, Func_03_6ee2
	xor a
	ld [$cf7a], a
	ld a, [$cf7b]
	cp $04
	jr z, Func_03_6ec9
	cp $05
	jr z, Func_03_6ee6
	inc a
	ld [$cf7b], a
	jr Func_03_6ee2
Func_03_6ec4:
	ld a, $ff
	ldh [$ffb8], a
	ret
Func_03_6ec9:
	ld a, [$c2e3]
	or a
	jr nz, Func_03_6ed6
	ld a, [$c2e2]
	cp $02
	jr z, Func_03_6edd
Func_03_6ed6:
	ld a, $05
	ld [$cf7b], a
	jr Func_03_6ee2
Func_03_6edd:
	ld a, $01
	ld [$cf7b], a
Func_03_6ee2:
	xor a
	ldh [$ffb8], a
	ret
Func_03_6ee6:
	ld a, $01
	ldh [$ffb8], a
	push de
	ld a, $01
	ld hl, Func_01_4cae
	call CallBankedHL
	pop de
	ret

SECTION "room_00eef5", ROMX[$6ef5], BANK[$03]

Data_03_6ef5:
	db $00, $01, $00, $00, $01, $00, $00, $00, $80, $01, $80, $01, $80, $01, $80, $01
	db $00, $00, $01, $00, $00, $01, $01, $00, $40, $01, $40, $01, $40, $01, $40, $01
	db $40, $01, $40, $01

SECTION "room_00ef19", ROMX[$6f19], BANK[$03]

Func_03_6f19:
	ld a, [$cf77]
	or a
	ret z
	ld de, $71f9
	ret
	ld a, [$cf78]
	or a
	ret z
	ld de, $7229
	ret
	ldh a, [$ffb6]
	and $fc
	or $02
	ldh [$ffb6], a
	xor a
	ldh [$ffc1], a
	ret
	ldh a, [$ffb6]
	and $fc
	or $03
	ldh [$ffb6], a
	xor a
	ldh [$ffc1], a
	ret
	ldh a, [$ffbe]
	cp $80
	jr nc, Func_03_6f53
	call Func_03_6fbb
	call Func_03_6f63
	xor a
	ldh [$ffb8], a
	ret
Func_03_6f53:
	ld a, $80
	ldh [$ffbe], a
	xor a
	ldh [$ffbd], a
	ldh [$ffbf], a
	ldh [$ffc0], a
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_6f63:
	ldh a, [$ffc1]
	cp $41
	jr c, Func_03_6f89
	ldh a, [$ffc0]
	cp $02
	jr nc, Func_03_6f80
	ldh a, [$ffbf]
	ld l, a
	ldh a, [$ffc0]
	ld h, a
	ld bc, $0040
	add hl, bc
	ld a, l
	ldh [$ffbf], a
	ld a, h
	ldh [$ffc0], a
	ret
Func_03_6f80:
	ld a, $00
	ldh [$ffbf], a
	ld a, $02
	ldh [$ffc0], a
	ret
Func_03_6f89:
	ld a, $40
	ldh [$ffbf], a
	ld a, $00
	ldh [$ffc0], a
	ret
	ldh a, [$ffbe]
	cp $11
	jr c, Func_03_6fa2
	call Func_03_6fbb
	call Func_03_6fb2
	xor a
	ldh [$ffb8], a
	ret
Func_03_6fa2:
	ld a, $10
	ldh [$ffbe], a
	xor a
	ldh [$ffbd], a
	ldh [$ffbf], a
	ldh [$ffc0], a
	ld a, $01
	ldh [$ffb8], a
	ret
Func_03_6fb2:
	ld a, $80
	ldh [$ffbf], a
	ld a, $00
	ldh [$ffc0], a
	ret
Func_03_6fbb:
	ldh a, [$ffc1]
	cp $41
	ret z
	inc a
	ldh [$ffc1], a
	ret

SECTION "room_00efc4", ROMX[$6fc4], BANK[$03]

Data_03_6fc4:
	db $00, $01, $00, $01

SECTION "room_00efc8", ROMX[$6fc8], BANK[$03]

Data_03_6fc8:
	db $00, $01

SECTION "room_00efca", ROMX[$6fca], BANK[$03]

Data_03_6fca:
	db $00, $01, $00, $02, $55, $00, $55, $00

SECTION "room_00efd2", ROMX[$6fd2], BANK[$03]

Data_03_6fd2:
	db $55, $00

SECTION "room_00efd4", ROMX[$6fd4], BANK[$03]

Data_03_6fd4:
	db $55, $00, $aa, $00, $9c, $00, $9c, $00

SECTION "room_00efdc", ROMX[$6fdc], BANK[$03]

Data_03_6fdc:
	db $9c, $00

SECTION "room_00efde", ROMX[$6fde], BANK[$03]

Data_03_6fde:
	db $9c, $00, $9c, $00, $80, $00, $c0, $00, $00, $01, $80, $01, $00, $02, $2a, $00
	db $3f, $00

SECTION "room_00eff0", ROMX[$6ff0], BANK[$03]

Data_03_6ff0:
	db $55, $00

SECTION "room_00eff2", ROMX[$6ff2], BANK[$03]

Data_03_6ff2:
	db $7f, $00, $aa, $00, $55, $00, $7f, $00

SECTION "room_00effa", ROMX[$6ffa], BANK[$03]

Data_03_6ffa:
	db $aa, $00

SECTION "room_00effc", ROMX[$6ffc], BANK[$03]

Data_03_6ffc:
	db $ff, $00, $54, $01

SECTION "room_00f000", ROMX[$7000], BANK[$03]

Data_03_7000:
	db $40, $00, $60, $00, $80, $00, $c0, $00, $00, $01, $60, $00, $90, $00, $c0, $00
	db $20, $01

SECTION "room_00f012", ROMX[$7012], BANK[$03]

Data_03_7012:
	db $80, $01, $50, $00, $78, $00, $a0, $00, $f0, $00, $40, $01

SECTION "room_00f01e", ROMX[$701e], BANK[$03]

Data_03_701e:
	db $40, $00, $60, $00, $80, $00, $00, $01, $80, $01

SECTION "room_00f028", ROMX[$7028], BANK[$03]

Data_03_7028:
	db $20, $00, $30, $00

SECTION "room_00f02c", ROMX[$702c], BANK[$03]

Data_03_702c:
	db $40, $00

SECTION "room_00f02e", ROMX[$702e], BANK[$03]

Data_03_702e:
	db $60, $00, $80, $00, $60, $00, $90, $00

SECTION "room_00f036", ROMX[$7036], BANK[$03]

Data_03_7036:
	db $c0, $00

SECTION "room_00f038", ROMX[$7038], BANK[$03]

Data_03_7038:
	db $20, $01, $80, $01, $00, $01, $80, $01

SECTION "room_00f040", ROMX[$7040], BANK[$03]

Data_03_7040:
	db $00, $02

SECTION "room_00f042", ROMX[$7042], BANK[$03]

Data_03_7042:
	db $70, $00, $70, $01

SECTION "room_00f046", ROMX[$7046], BANK[$03]

Data_03_7046:
	db $02, $07, $01, $08, $04, $0b, $00, $02, $07, $02, $08, $0a, $0b, $00, $02, $07
	db $03, $08, $0a, $0b, $00, $02, $07, $04, $08, $07, $0b, $00, $02, $07, $05, $08
	db $07, $0b, $00, $02, $07, $06, $08, $07, $0b, $00, $02, $07, $07, $08, $07, $0b
	db $00, $07, $0a, $08, $18, $0b, $16, $aa, $4f, $16, $59, $50, $0c, $20, $7f, $70
	db $07, $09, $16, $20, $4f, $16, $13, $50, $0c, $20, $8b, $70, $07, $2a, $16, $64
	db $6b, $16, $72, $6b, $27, $01, $a2, $70, $0c, $20, $97, $70, $07, $2b, $08, $3c
	db $0b, $16, $8d, $6b, $08, $01, $0b, $00, $02, $07, $0c, $08, $0f, $0b, $00, $02
	db $07, $19, $08, $15, $0b, $16, $5f, $4c, $00, $02, $07, $10, $08, $1f, $0b, $16
	db $5f, $4c, $00, $06, $00, $07, $11, $1d

SECTION "room_00f0ce", ROMX[$70ce], BANK[$03]

Data_03_70ce:
	db $20, $bf, $70

SECTION "room_00f0d1", ROMX[$70d1], BANK[$03]

Data_03_70d1:
	db $06, $00, $07, $12, $1d, $20, $bf, $70, $06, $01, $07, $13, $1d

SECTION "room_00f0de", ROMX[$70de], BANK[$03]

Data_03_70de:
	db $20, $bf, $70

SECTION "room_00f0e1", ROMX[$70e1], BANK[$03]

Data_03_70e1:
	db $06, $01, $07, $14, $1d, $20, $bf, $70

SECTION "room_00f0e9", ROMX[$70e9], BANK[$03]

Data_03_70e9:
	db $06, $02, $07, $15, $1d, $20, $bf, $70

SECTION "room_00f0f1", ROMX[$70f1], BANK[$03]

Data_03_70f1:
	db $06, $02, $07, $16, $1d, $20, $bf, $70

SECTION "room_00f0f9", ROMX[$70f9], BANK[$03]

Data_03_70f9:
	db $06, $03, $07, $17, $1d, $20, $bf, $70

SECTION "room_00f101", ROMX[$7101], BANK[$03]

Data_03_7101:
	db $06, $03, $07, $18, $1d

SECTION "room_00f106", ROMX[$7106], BANK[$03]

Data_03_7106:
	db $20, $bf, $70

SECTION "room_00f109", ROMX[$7109], BANK[$03]

Data_03_7109:
	db $06, $00, $07, $1a, $1d, $20, $b5, $70, $06, $00, $07, $1b, $1d, $20, $b5, $70
	db $06, $01, $07, $1c, $1d, $20, $b5, $70, $06, $01, $07, $1d, $1d

SECTION "room_00f126", ROMX[$7126], BANK[$03]

Data_03_7126:
	db $20, $b5, $70, $06, $02, $07, $1e, $1d, $20, $b5, $70

SECTION "room_00f131", ROMX[$7131], BANK[$03]

Data_03_7131:
	db $06, $02, $07, $1f, $1d, $20, $b5, $70

SECTION "room_00f139", ROMX[$7139], BANK[$03]

Data_03_7139:
	db $06, $03, $07, $20, $1d, $20, $b5, $70

SECTION "room_00f141", ROMX[$7141], BANK[$03]

Data_03_7141:
	db $06, $03, $07, $21, $1d, $20, $b5, $70, $02, $07, $30, $08, $28, $0b, $00, $02
	db $07, $31, $08, $28, $0b, $00

SECTION "room_00f157", ROMX[$7157], BANK[$03]

Data_03_7157:
	db $02, $07, $32, $08, $2a, $0b, $00

SECTION "room_00f15e", ROMX[$715e], BANK[$03]

Data_03_715e:
	db $02, $07, $33, $08, $09, $0b, $00, $02, $07, $34, $08, $06, $0b, $00, $02, $07
	db $35, $08, $10, $0b, $00

SECTION "room_00f173", ROMX[$7173], BANK[$03]

Data_03_7173:
	db $06, $fe, $03, $00, $02, $07, $36, $0c, $20, $7a, $71

SECTION "room_00f17e", ROMX[$717e], BANK[$03]

Data_03_717e:
	db $06, $fe, $03, $00, $02, $07, $37, $0c, $20, $85, $71, $03, $00, $02, $07, $3a
	db $0c, $20, $8e, $71

SECTION "room_00f192", ROMX[$7192], BANK[$03]

Data_03_7192:
	db $03, $00, $02, $07, $3b, $0c, $20, $97, $71

SECTION "room_00f19b", ROMX[$719b], BANK[$03]

Data_03_719b:
	db $06, $03, $03, $00, $02, $07, $3c, $0c, $20, $a2, $71, $02, $07, $3d, $08, $15
	db $0b, $00, $06, $02, $03, $80, $00, $07, $08, $08, $20, $0b, $00, $02, $07, $0b
	db $08, $0a, $0b, $00, $02, $07, $0f, $08, $3c, $0b, $16, $a1, $55, $00, $02, $07
	db $09, $08, $5a, $16, $e7, $55, $0a, $ce, $71, $00, $02, $07, $29, $08, $3c, $0b
	db $16, $97, $57, $27, $01, $e6, $71, $0c, $20, $db, $71, $17, $01, $1b, $4d
Func_03_71ea:
	db $00

SECTION "room_00fd25", ROMX[$7d25], BANK[$03]

Func_03_7d25:
	ld bc, $02ff
	rlca
	add hl, bc
	ld [Data_00_10f0], sp
	ld hl, $7d06
	ld a, [bc]
	inc l
	ld a, l
	jr nz, Func_03_7d46
	ld a, l

SECTION "room_00fd36", ROMX[$7d36], BANK[$03]

Data_03_7d36:
	db $05, $01, $01, $00, $02, $07, $01, $08, $3c, $10, $21

SECTION "room_00fd41", ROMX[$7d41], BANK[$03]

Data_03_7d41:
	db $93, $7d

SECTION "room_00fd43", ROMX[$7d43], BANK[$03]

Data_03_7d43:
	db $0a, $3f, $7d
Func_03_7d46:
	db $20, $67, $7d, $05, $ff, $06, $fe, $01, $01, $04, $28, $70, $07, $02, $08, $5a
	db $16, $1b, $69, $27, $ff, $93, $7d, $27, $03, $49, $7d, $0a, $56, $7d, $20, $38
	db $7d, $01, $02, $02, $07, $03, $08, $14, $10, $21

SECTION "room_00fd70", ROMX[$7d70], BANK[$03]

Data_03_7d70:
	db $93, $7d

SECTION "room_00fd72", ROMX[$7d72], BANK[$03]

Data_03_7d72:
	db $0a, $6e, $7d, $16, $9a, $54, $08, $0a, $10, $21

SECTION "room_00fd7c", ROMX[$7d7c], BANK[$03]

Data_03_7d7c:
	db $93, $7d

SECTION "room_00fd7e", ROMX[$7d7e], BANK[$03]

Data_03_7d7e:
	db $0a, $7a, $7d, $16, $ae, $54, $08, $0a, $10, $21

SECTION "room_00fd88", ROMX[$7d88], BANK[$03]

Data_03_7d88:
	db $93, $7d

SECTION "room_00fd8a", ROMX[$7d8a], BANK[$03]

Data_03_7d8a:
	db $0a, $86, $7d, $16, $b8, $54, $20, $4b, $7d, $16, $22, $46, $01, $04, $02, $07
	db $04, $08, $54, $0b, $0f, $16, $1f, $69, $10, $0c, $21, $9f, $7d, $01, $ff, $02
	db $07, $09, $08, $3c, $0b, $16, $39, $55, $00, $16, $60, $69, $20, $bb, $7d, $05
	db $ff, $06, $fe, $01, $01, $04, $32, $70, $07, $02, $16, $a4, $69, $27, $ff, $f9
	db $7d, $27, $01, $b9, $7d, $27, $02, $d7, $7d, $0c, $20, $c4, $7d, $05, $ff, $06
	db $fe, $01, $01, $02, $07, $03, $08, $14, $0b, $16, $65, $69, $16, $74, $69, $16
	db $40, $44, $0c, $21, $e6, $7d, $02, $07, $04, $08, $28, $0b, $20, $bb, $7d, $01
	db $01, $02, $07, $05, $08, $28, $0b, $16, $6d, $69, $16, $8c, $69, $16, $40, $44
	db $0c, $21, $04, $7e, $02, $07, $06, $08, $14, $0b, $20, $b9, $7d, $16, $22, $46
	db $01, $ff, $02, $07, $09, $08, $3c, $0b, $16, $39, $55, $00, $05, $ff, $01, $01
	db $02, $07, $01, $08, $b4, $16, $7e, $6a, $27, $ff, $53, $7e, $0a, $2f, $7e, $01
	db $01, $02, $07, $03, $08, $28, $0b, $16, $cc, $54, $08, $0a, $0b, $16, $e0, $54
	db $08, $0a, $0b, $16, $f4, $54, $20, $26, $7e, $16, $22, $46, $01, $04, $02, $07
	db $04, $08, $28, $0b, $0f, $16, $21, $6a, $10, $0c, $21, $5f, $7e, $01, $ff, $02
	db $07, $09, $08, $3c, $0b, $16, $39, $55, $00, $16, $b4, $6a, $01, $01, $02, $07
	db $01, $16, $b9, $6a, $27, $ff, $ef, $7e, $27, $01, $8a, $7e, $0c, $20, $7b, $7e
	db $01, $02, $02, $07, $06, $08, $58, $0b, $08, $14, $0b, $16, $9b, $6a, $08, $14
	db $0b, $20, $73, $7e, $16, $d3, $6a, $01, $11, $02, $07, $02, $16, $dc, $6a, $27
	db $ff, $04, $7f, $27, $01, $b5, $7e, $0c, $20, $a6, $7e, $01, $12, $07, $07, $06
	db $02, $03, $40, $00, $08, $20, $0b, $02, $08, $78, $0b, $06, $03, $03, $00, $01
	db $08, $08, $0b, $02, $16, $8e, $6a, $16, $fd, $6a, $08, $0a, $0b, $16, $0f, $6b
	db $08, $0f, $0b, $16, $21, $6b, $08, $14, $0b, $16, $33, $6b, $08, $19, $0b, $16
	db $45, $6b, $20, $9e, $7e, $16, $22, $46, $01, $ff, $02, $07, $03, $08, $3c, $0b
	db $07, $05, $17, $04, $0a, $42, $16, $6e, $55, $00, $01, $ff, $02, $07, $04, $08
	db $3c, $0b, $07, $05, $00, $16, $57, $6b, $01, $01, $02, $07, $00, $16, $93, $6b
	db $27, $01, $22, $7f, $0c, $20, $17, $7f, $16, $a6, $6b, $01, $02, $02, $07, $03
	db $08, $b4, $0b, $16, $b4, $6b, $27, $ff, $b6, $7f, $27, $01, $40, $7f, $27, $02
	db $81, $7f, $0c, $20, $2d, $7f, $01, $03, $02, $07, $02, $08, $1e, $0b, $16, $e9
	db $6b, $07, $0a, $08, $78, $16, $4f, $6c, $0a, $4f, $7f, $16, $69, $6c, $07, $04
	db $08, $1e, $0b, $04, $3c, $70, $16, $96, $6c, $27, $01, $6b, $7f, $0c, $20, $60
	db $7f, $02, $07, $05, $08, $64, $0b, $07, $02, $08, $10, $0b, $16, $a6, $6b, $07
	db $02, $08, $10, $0b, $20, $22, $7f, $01, $04, $02, $07, $04, $16, $c5, $6c, $08
	db $1e, $0b, $16, $e2, $6c, $16, $13, $6d, $27, $01, $9a, $7f, $0c, $20, $8f, $7f
	db $02, $07, $06, $08, $1e, $0b, $16, $7f, $6d, $08, $50, $0b, $07, $02, $08, $10
	db $0b, $16, $a6, $6b, $07, $02, $08, $10, $0b, $20, $22, $7f, $01, $05, $02, $07
	db $07, $08, $05, $0b, $07, $01, $08, $05, $0b, $16, $0a, $6e, $16, $98, $6e, $27
	db $ff, $dd, $7f, $27, $01, $d5, $7f, $0c, $20, $c6, $7f, $07, $08, $08, $0a, $0b
	db $20, $22, $7f, $16, $22, $46, $01, $ff, $02, $07, $09, $08, $78, $0b, $16, $6e
	db $55, $00

SECTION "room_00ffff", ROMX[$7fff], BANK[$03]

Data_03_7fff:
	db $03
