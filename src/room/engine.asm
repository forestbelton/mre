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
;     interpret is carved as readable source under src/room/scripts/ -- see
;     docs/entity_scripts.md. The selectors below load a script with
;     `ld de, $7xxx` (the matching label is under src/room/scripts/).
;   * SpawnEntity ($4593: A=type, D=Ypx, E=Xpx, BC=param) allocates a free slot
;     (FindFreeEntitySlot) and initialises it. The bulk of the bank is the AI:
;     per-species think/probe selectors (<Species>_Think, *Probe*), the
;     8-direction WallFollow_* / WallTurn_* locomotion, SpawnProjectileRel and
;     the per-species fire routines -- all reached from the scripts' ent_call.
;
; Public API (called cross-bank via CallBankedHL):
;   UpdateEntities ($4000), BreakTileAtPixel ($44bb) / BreakTileAtCell ($44cb)
;   -- destroy a breakable crate cell and spawn its shard -- and RequestFloorExit
;   ($4a58), which sets the wProgressFlags bit-7 floor-exit flag the main loop polls.
;
; Routines whose purpose is confidently identified carry curated names (in
; map.json labels[]); the rest keep auto-generated Func_03_xxxx / Data_03_xxxx
; names and are honest about being undecoded. This file is hand-editable: extract
; only appends map.json sections not already covered by a SECTION here.

INCLUDE "util.inc"
INCLUDE "sound/id.inc"

SECTION "Room engine", ROMX[$4000], BANK[$03]

UpdateEntities:
	ld a, [$c2db]
	ld [$c2dc], a
	ld c, $1c
	ld hl, $cc67
Func_03_400b:
	ld a, [hl]
	or a
	jr z, Func_03_4030
	call ClassifyEntityType
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
	rst SubAFromHL
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
	ldh a, [hEntityState]
	or a
	jr z, Func_03_408c
	ld a, [$c2db]
	or a
	jr nz, Func_03_4071
	ldh a, [$ffd0]
	bit 7, a
	jr z, Func_03_4077
	ldh a, [hEntityType]
	cp $ff
	jr z, Func_03_4077
	call DecFreezeTimerElseReset
	jr Func_03_4077
Func_03_4071:
	ldh a, [$ffe4]
	bit 5, a
	jr z, Func_03_407f
Func_03_4077:
	FAR_CALL Func_01_6d48
Func_03_407f:
	ldh a, [hEntityUpdate2]
	or a
	jr z, Func_03_408c
	FAR_CALL EntityAnim_Run
Func_03_408c:
	ldh a, [hEntityPtrLo]
	ld l, a
	ldh a, [hEntityPtrHi]
	ld h, a
	call SaveEntityRegs
	pop hl
	pop bc
	ret

EntityOpcodeTable:
	dw EntityOp_Despawn
	dw EntityOp_SetType
	dw EntityOp_VelXZero
	dw EntityOp_SetVelX
	dw EntityOp_VelXIndexed
	dw EntityOp_SetXFlip
	dw EntityOp_SetFacing
	dw EntityOp_Gfx
	dw EntityOp_SetTimer
	dw EntityOp_TimerTick
	dw EntityOp_LoopTimer
	dw EntityOp_WaitTimer
	dw EntityOp_Yield
	dw EntityOp_SpawnRel
	dw EntityOp_SetFlag2
	dw EntityOp_BeginAction
	dw EntityOp_UpdateAction
	dw $0000, $0000, $0000, $0000, $0000
	dw EntityOp_Call
	dw EntityOp_CallBank0
	dw EntityOp_LoadB8
	dw EntityOp_AndB8
	dw EntityOp_TestB8
	dw EntityOp_CmpB8
	dw EntityOp_SetVelY
	dw EntityOp_WaitCounter
	dw $0000, $0000
	dw EntityOp_Jump
	dw EntityOp_JrBusy
	dw EntityOp_JrFree
	dw EntityOp_JrHit
	dw EntityOp_JrNoHit
	dw EntityOp_JrTimer0
	dw EntityOp_JrTimerNz
	dw EntityOp_JrB8Eq
	dw EntityOp_JrB8Ne

EntityOp_Despawn:
	ld a, $00
	ldh [hEntityState], a
	jp EndEntityFrame

EntityOp_SetType:
	inc de
	ld a, [de]
	ldh [hEntityType], a
	inc de
	jp RunEntityScript

EntityOp_VelXZero:
	inc de
	xor a
	ldh [hEntityVelXLo], a
	ldh [hEntityVelXHi], a
	jp RunEntityScript

EntityOp_SetVelX:
	inc de
	ld a, [de]
	ldh [hEntityVelXLo], a
	inc de
	ld a, [de]
	ldh [hEntityVelXHi], a
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
	ldh a, [hEntityAnimSel]
	and $07
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hl+]
	ldh [hEntityVelXLo], a
	ld a, [hl]
	ldh [hEntityVelXHi], a
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
	cp $00
	jr z, Func_03_4178
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
	FAR_CALL EntityAnim_SetAnimation
	pop de
	inc de
	jp RunEntityScript

EntityOp_SetTimer:
	inc de
	ld a, [de]
	ldh [hEntityTimer], a
	inc de
	jp RunEntityScript

EntityOp_TimerTick:
	inc de
	ld c, $c6
	ldh a, [c]
	or a
	jp z, RunEntityScript
	dec a
	ldh [c], a
	jp EndEntityFrame

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

EntityOp_SetVelY:
	inc de
	ld a, [de]
	ldh [hEntityVelYLo], a
	inc de
	ld a, [de]
	ldh [hEntityVelYHi], a
	inc de
	jp RunEntityScript

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
	ldh [hEntityResult], a
	jp RunEntityScript

EntityOp_AndB8:
	inc de
	ld c, $b8
	ld a, [de]
	ld b, a
	ldh a, [c]
	and b
	ldh [c], a
	call PackCmpFlagsToMoveResult
	inc de
	jp RunEntityScript

EntityOp_TestB8:
	inc de
	ld a, [de]
	ld b, a
	ldh a, [hEntityResult]
	and b
	call PackCmpFlagsToMoveResult
	inc de
	jp RunEntityScript

EntityOp_CmpB8:
	inc de
	ld a, [de]
	ld b, a
	ldh a, [hEntityResult]
	cp b
	call PackCmpFlagsToMoveResult
	inc de
	jp RunEntityScript

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

EntityOp_BeginAction:
	inc de
	ld hl, $ffb4
	set 7, [hl]
	ld a, $14
	ldh [hEntityActionTimer], a
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
	ldh a, [hEntityMoveResult]
	bit 0, a
	jr nz, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript

EntityOp_JrFree:
	ldh a, [hEntityMoveResult]
	bit 0, a
	jr z, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript

EntityOp_JrHit:
	ldh a, [hEntityMoveResult]
	bit 1, a
	jr nz, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript

EntityOp_JrNoHit:
	ldh a, [hEntityMoveResult]
	bit 1, a
	jr z, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript

EntityOp_JrTimer0:
	ldh a, [hEntityTimer]
	or a
	jr z, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript

EntityOp_JrTimerNz:
	ldh a, [hEntityTimer]
	or a
	jr nz, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript

EntityOp_JrB8Eq:
	inc de
	ldh a, [hEntityResult]
	ld b, a
	ld a, [de]
	cp b
	jr z, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript

EntityOp_JrB8Ne:
	inc de
	ldh a, [hEntityResult]
	ld b, a
	ld a, [de]
	cp b
	jr nz, EntityOp_Jump
	inc de
	inc de
	inc de
	jp RunEntityScript

PackCmpFlagsToMoveResult:
	ld a, $00
	jr nc, Func_03_4301
	set 1, a
Func_03_4301:
	jr nz, Func_03_4305
	set 0, a
Func_03_4305:
	ldh [hEntityMoveResult], a
	ret

LoadEntityRegs:
	ld a, l
	ldh [hEntityPtrLo], a
	ld a, h
	ldh [hEntityPtrHi], a
	FOR ADDR, $ffb0, $ffda, 1
		ld a, [hl+]
		ldh [ADDR], a
	ENDR
	ret

SaveEntityRegs:
	FOR ADDR, $ffb0, $ffda, 1
		ldh a, [ADDR]
		ld [hl+], a
	ENDR
	ret

SpawnEntityRelative:
	push de
	push af
	ldh a, [hEntityX]
	add a, c
	ld e, a
	ldh a, [hEntityY]
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
	ldh a, [hEntityActionTimer]
	cp $15
	jr c, Func_03_443a
Func_03_442c:
	ldh a, [hEntityFacing]
	bit 3, a
	jr z, Func_03_443a
	res 7, [hl]
	xor a
	ldh [hEntityActionTimer], a
	ldh [hEntityMoveResult], a
	ret
Func_03_443a:
	xor a
	set 0, a
	ldh [hEntityMoveResult], a
	ret
	ld hl, $ffb4
	bit 7, [hl]
	jr z, Func_03_444d
	ldh a, [hEntityActionTimer]
	cp $1f
	jr c, Func_03_445b
Func_03_444d:
	ldh a, [hEntityFacing]
	bit 3, a
	jr z, Func_03_445b
	res 7, [hl]
	xor a
	ldh [hEntityActionTimer], a
	ldh [hEntityMoveResult], a
	ret
Func_03_445b:
	xor a
	set 0, a
	ldh [hEntityMoveResult], a
	ret

MonsterBreakTileInFront:
	push de
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	ld b, a
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_03_4477
	ldh a, [hEntityX]
	sub $10
	jr Func_03_447b
Func_03_4477:
	ldh a, [hEntityX]
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
	ldh a, [hEntityY]
	sub $10
	add a, $08
	swap a
	and $0f
	ld b, a
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	call BreakTileAtCell
	pop de
	ret
	push de
	ldh a, [hEntityY]
	add a, $10
	add a, $08
	swap a
	and $0f
	ld b, a
	ldh a, [hEntityX]
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
	call GetCollisionCell
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
	call GetFloorGridCell
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
	pop de
	pop bc
	ld hl, $0000
	xor a
	ret
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
	pop af
	ld hl, $0000
	xor a
	ret
Func_03_45a0:
	pop af
	push hl
	ld [hl+], a
	push af
	xor a
	REPT 8
		ld [hl+], a
	ENDR
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
	REPT 9
		ld [hl+], a
	ENDR
	pop af
	ld c, a
	ld b, $00
	push de
	push hl
	FAR_CALL Func_01_7b24
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
	FAR_CALL Func_04_4344
	pop hl
	pop de
	push hl
	ld a, $22
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ldh a, [hHitbox1X]
	ld [hl+], a
	ldh a, [hHitbox1Y]
	ld [hl+], a
	ldh a, [hHitbox1W]
	ld [hl+], a
	ldh a, [hHitbox1H]
	ld [hl+], a
	ldh a, [hHitbox2X]
	ld [hl+], a
	ldh a, [hHitbox2Y]
	ld [hl+], a
	ldh a, [hHitbox2W]
	ld [hl+], a
	ldh a, [hHitbox2H]
	ld [hl], a
	pop hl
	ld a, $01
	ret
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	ld a, $02
	ld [$c2e6], a
	ret

PlayerSameRowInRange:
	ld a, [wPlayerY]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	cp b
	jr z, Func_03_464a
	inc a
	cp b
	jr nz, Func_03_465b
Func_03_464a:
	ld a, [wPlayerX]
	ld b, a
	ldh a, [hEntityX]
	call OrderPair
	sub b
	cp $18
	jr nc, Func_03_465b
	ld a, $01
	ret
Func_03_465b:
	xor a
	ret

PlayerAheadSameRow:
	ld a, [wPlayerY]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	cp b
	jr z, Func_03_4678
	inc a
	cp b
	jr nz, Func_03_4692
Func_03_4678:
	ld a, [wPlayerX]
	ld b, a
	ldh a, [hEntityX]
	cp b
	jr c, Func_03_4689
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_468f
	jr Func_03_4692
Func_03_4689:
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_4692
Func_03_468f:
	ld a, $01
	ret
Func_03_4692:
	xor a
	ret

PlayerAheadAndFacingUs:
	ld a, [wPlayerY]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	cp b
	jr nz, Func_03_46da
	ld a, [wPlayerX]
	ld b, a
	ldh a, [hEntityX]
	cp b
	jr c, Func_03_46bc
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_46c2
	jr Func_03_46da
Func_03_46bc:
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_46da
Func_03_46c2:
	ld a, [wPlayerFacing]
	ld b, a
	ldh a, [hEntityFacing]
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

FacePlayerX:
	ldh a, [hEntityX]
	ld c, a
	ld a, [wPlayerX]
	cp c
	call PackCmpFlagsToMoveResult
	ret

ApplyPlayerInputFacingX:
	ldh a, [hJoyHeld]
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

Player_StandThinkDown:
	call ApplyPlayerInputFacingX
	call Player_UpdateFacing
	ldh a, [hJoyPressed]
	bit 6, a
	jp nz, Func_03_48b3
	ldh a, [hJoyHeld]
	bit 6, a
	jp z, Func_03_4726
	ld a, [$cf7f]
	bit 0, a
	jp nz, Func_03_48b3
Func_03_4726:
	call UpdateActionTimer
	bit 0, a
	jp nz, Func_03_48af
	ldh a, [hEntityAnimState]
	and $03
	cp $01
	jp z, Func_03_488b
	cp $03
	jp z, Func_03_4897
	cp $02
	jp z, Func_03_48a3
	ldh a, [hJoyHeld]
	bit 7, a
	jp nz, Func_03_487f
	and $30
	jp nz, Func_03_4883
	ret
Player_StandThinkUp:
	call ApplyPlayerInputFacingX
	call Player_UpdateFacing
	ldh a, [hJoyPressed]
	bit 6, a
	jp nz, Func_03_48b3
	call UpdateActionTimer
	bit 0, a
	jp nz, Func_03_48af
	ldh a, [hEntityAnimState]
	and $03
	cp $01
	jp z, Func_03_488f
	cp $03
	jp z, Func_03_489b
	cp $02
	jp z, Func_03_48a7
	ldh a, [hJoyHeld]
	bit 7, a
	jp z, Func_03_487b
	and $30
	jp nz, Func_03_4887
	ret
Player_WalkThinkRight:
	call ApplyPlayerInputFacingX
	call Player_UpdateFacing
	ldh a, [hJoyPressed]
	bit 6, a
	jp nz, Func_03_48b3
	call UpdateActionTimer
	bit 0, a
	jp nz, Func_03_48af
	ldh a, [hEntityAnimState]
	and $03
	cp $01
	jp z, Func_03_488b
	cp $03
	jp z, Func_03_4897
	cp $02
	jp z, Func_03_48a3
	ldh a, [hJoyHeld]
	bit 7, a
	jp nz, Func_03_487f
	and $30
	jp z, Func_03_487b
	ret
Player_WalkThinkLeft:
	call ApplyPlayerInputFacingX
	call Player_UpdateFacing
	ldh a, [hJoyPressed]
	bit 6, a
	jp nz, Func_03_48b3
	call UpdateActionTimer
	bit 0, a
	jp nz, Func_03_48af
	ldh a, [hEntityAnimState]
	and $03
	cp $01
	jp z, Func_03_488f
	cp $03
	jp z, Func_03_489b
	cp $02
	jp z, Func_03_48a7
	ldh a, [hJoyHeld]
	bit 7, a
	jp z, Func_03_487b
	and $30
	jp z, Func_03_487f
	ret
Player_LiftThink:
	push af
	ld a, SOUND_SFX_Lift
	call PlaySound
	pop af
Player_ThrowWindupThink:
	call Player_UpdateFacing
	and $03
	cp $01
	jp z, Func_03_4893
	cp $03
	jp z, Func_03_489f
	cp $02
	jp z, Func_03_48ab
	ldh a, [hJoyHeld]
	and $30
	jp nz, Func_03_48bb
	ret
Player_CarryStandThink:
	call ApplyPlayerInputFacingX
	call Player_TryGrab
	bit 0, a
	jp z, Func_03_48c3
	call Player_UpdateFacing
	and $03
	cp $01
	jr z, Func_03_4893
	cp $03
	jp z, Func_03_489f
	cp $02
	jp z, Func_03_48ab
	ldh a, [hJoyHeld]
	and $30
	jp nz, Func_03_48bb
	call UpdateActionTimer
	bit 0, a
	jp z, Func_03_48bf
	ret
Player_CarryWalkThink:
	call ApplyPlayerInputFacingX
	call Player_TryGrab
	bit 0, a
	jp z, Func_03_48c7
	call Player_UpdateFacing
	and $03
	cp $01
	jr z, Func_03_4893
	cp $03
	jr z, Func_03_489f
	cp $02
	jr z, Func_03_48ab
	ldh a, [hJoyHeld]
	and $30
	jr z, Func_03_48b7
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_48bf
	ret
Player_ThrowReleaseThink:
	call Player_UpdateFacing
	ldh a, [hJoyHeld]
	bit 6, a
	jp nz, Func_03_487b
	ret
Player_PostThrowSelect:
	ldh a, [hJoyHeld]
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
Func_03_488f:
	ld de, $73d1
	ret
Func_03_4893:
	ld de, $73e8
	ret
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
Player_UpdateFacing:
	ld hl, $ffb5
	ld a, [hl]
	ld b, a
	and $03
	jr nz, Func_03_48e2
	ldh a, [hJoyPressed]
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
Player_LatchActionHeld:
	ldh a, [hJoyPressed]
	bit 6, a
	ret z
	ld hl, $cf7f
	set 0, [hl]
	ret
Player_LatchActionPressed:
	ldh a, [hJoyHeld]
	bit 6, a
	ret z
Data_03_4909:
	ld hl, $cf7f
	set 0, [hl]
	ret
	ret
Player_ClearActionFlag:
	xor a
	ld [$cf7f], a
	ret
Player_ClearMoveSub:
	ldh a, [hEntityAnimState]
	and $fc
	ldh [hEntityAnimState], a
	ret
Player_TryGrab:
	push de
	call Player_ScanGrabTargets
	pop de
	or a
	jr z, Func_03_4928
	xor a
	ldh [hEntityMoveResult], a
	ret
Func_03_4928:
	xor a
	set 0, a
	ldh [hEntityMoveResult], a
	ret
Player_ScanGrabTargets:
	ldh a, [hEntityStatus]
	bit 7, a
	jp z, Func_03_498c
	ldh a, [hEntityActionTimer]
	cp $15
	jr nc, Func_03_498c
	ld a, $ff
	ld [$cf65], a
	ld [$cf66], a
	ld [$cf67], a
	ldh a, [hEntityX]
	ld [$cf73], a
	ldh a, [hEntityY]
	ld [$cf74], a
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_03_4961
	call Player_ProbeGrabCellL
	or a
	jr nz, Func_03_496a
	call Player_ProbeGrabCellR
	jr Func_03_496a
Func_03_4961:
	call Player_ProbeGrabCellR
	or a
	jr nz, Func_03_496a
	call Player_ProbeGrabCellL
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
	ld a, SOUND_SFX_02
	call PlaySound
	pop af
Func_03_4985:
	ld a, $14
	ldh [hEntityActionTimer], a
	ld a, $01
	ret
Func_03_498c:
	xor a
	ret
Player_ProbeGrabCellL:
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
	call GetCollisionCell
	pop bc
	or a
	jr z, Func_03_49bb
	call Player_GrabOrBreakCell
	ld [$cf65], a
	or a
	jr nz, Func_03_49bd
Func_03_49bb:
	xor a
	ret
Func_03_49bd:
	ld a, $01
	ret
Player_ProbeGrabCellR:
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
	call GetCollisionCell
	pop bc
	or a
	jr z, Func_03_49ed
	call Player_GrabOrBreakCell
	ld [$cf66], a
	or a
	jr nz, Func_03_49ef
Func_03_49ed:
	xor a
	ret
Func_03_49ef:
	ld a, $01
	ret
Player_GrabOrBreakCell:
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
	ldh [hEntityY], a
	xor a
	ldh [hEntityYSub], a
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
Player_BeginAction:
	ld hl, $ffb4
	set 7, [hl]
	xor a
	ldh [hEntityActionTimer], a
	ret

; TODO: Disassemble
Data_03_4a4f:
	db $21, $b4, $ff, $cb, $be, $af, $e0, $c7, $c9

RequestFloorExit:
	ld hl, wProgressFlags
	set 7, [hl]
	ret
EntClearAttackActive:
	ld hl, $ffb4
	res 1, [hl]
	ret
EntSetAttackActive:
	ld hl, $ffb4
	set 1, [hl]
	ret
Player_SpawnAttackFront:
	push de
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_03_4a77
	ldh a, [hEntityX]
	sub $11
	jr Func_03_4a7b
Func_03_4a77:
	ldh a, [hEntityX]
	add a, $11
Func_03_4a7b:
	ld c, a
	ldh a, [hEntityType]
	cp $05
	jr z, Func_03_4a88
	ldh a, [hEntityY]
	sub $04
	jr Func_03_4a8c
Func_03_4a88:
	ldh a, [hEntityY]
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
	call CheckCellHitsEntity
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
	ldh a, [hEntityType]
	cp $05
	jr z, Func_03_4afe
	call CellXAheadByFacing
	pop de
	ret
Func_03_4afe:
	call SpawnPushSprite6
	pop de
	ret
Func_03_4b03:
	call SpawnPushSprite7
	pop de
	ret
CellXAheadByFacing:
	ldh a, [hEntityFacing]
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
	ldh a, [hEntityFacing]
	bit 7, a
	ret z
	ld a, $06
	rst AddAToHL
	set 7, [hl]
	ret
SpawnPushSprite6:
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
SpawnPushSprite7:
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
CheckCellHitsEntity:
	push bc
	ld hl, hHitbox1X
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
	ld a, SOUND_SFX_21
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
	ld a, SOUND_SFX_21
	call PlaySound
	pop af
	call Func_03_63d4
	jr Func_03_4c00

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
	ld a, SOUND_SFX_21
	call PlaySound
	pop af
	call Func_03_6704
	jr Func_03_4c00

Func_03_4bea:
	push hl
	ld de, $0003
	add hl, de
	ld a, [hl]
	pop hl
	cp $03
	jp nz, Func_03_4c07
	push af
	ld a, SOUND_SFX_21
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
	ld a, [wRoomType]
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
Func_03_4c37:
	xor a
	ret
Func_03_4c39:
	push de
	FAR_CALL Func_01_4ce1
	pop de
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	xor a
	ret
Func_03_4c4c:
	push de
	FAR_CALL Func_01_4cfe
	pop de
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	xor a
	ret
	ld hl, wPlayerStatus
	res 2, [hl]
	ret
Player_FireShot:
	ldh a, [hEntityStatus]
	bit 2, a
	ret nz
	ld a, [wBombCount]
	or a
	ret z
	push de
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_03_4c92
	ldh a, [hEntityType]
	cp $08
	jr z, Func_03_4c88
	ldh a, [hEntityStatus]
	bit 7, a
	jr nz, Func_03_4c8d
	call Player_SpawnShot16
	jp Func_03_4cab
Func_03_4c88:
	call Player_SpawnShot18
	jr Func_03_4cab
Func_03_4c8d:
	call Player_SpawnShot1a
	jr Func_03_4cab
Func_03_4c92:
	ldh a, [hEntityType]
	cp $08
	jr z, Func_03_4ca3
	ldh a, [hEntityStatus]
	bit 7, a
	jr nz, Func_03_4ca8
	call Player_SpawnShot10
	jr Func_03_4cab
Func_03_4ca3:
	call Player_SpawnShot12
	jr Func_03_4cab
Func_03_4ca8:
	call Player_SpawnShot14
Func_03_4cab:
	ld hl, $ffb4
	set 2, [hl]
	ld hl, wBombCount
	dec [hl]
	ld hl, wBombLargeFlags
	srl [hl]
	pop de
	ret
Player_SpawnShot16:
	ldh a, [hEntityY]
	add a, $08
	and $f0
	add a, $02
	ld d, a
	ldh a, [hEntityX]
	ld e, a
	ldh a, [hEntityPtrLo]
	ld c, a
	ldh a, [hEntityPtrHi]
	ld b, a
	ld a, [wBombLargeFlags]
	and $01
	add a, $16
	call SpawnEntity
	call AttackChild_SetVelLow
	call AttackChild_ClearFlag2
	call AttackChild_SetDir1
	call AttackChild_StashPtr
	call AttackChild_CopyAlignFlag
	call AttackChild_CopyAttackPos
	ret
Player_SpawnShot10:
	ldh a, [hEntityY]
	add a, $08
	and $f0
	add a, $02
	ld d, a
	ldh a, [hEntityX]
	ld e, a
	ldh a, [hEntityPtrLo]
	ld c, a
	ldh a, [hEntityPtrHi]
	ld b, a
	ld a, [wBombLargeFlags]
	and $01
	add a, $10
	call SpawnEntity
	call AttackChild_SetVelLow
	call AttackChild_SetFlag2
	call AttackChild_SetDir0
	call AttackChild_StashPtr
	call AttackChild_CopyAlignFlag
	call AttackChild_CopyAttackPos
	ret
Player_SpawnShot18:
	ldh a, [hEntityY]
	add a, $08
	and $f0
	add a, $05
	ld d, a
	ldh a, [hEntityX]
	ld e, a
	ldh a, [hEntityPtrLo]
	ld c, a
	ldh a, [hEntityPtrHi]
	ld b, a
	ld a, [wBombLargeFlags]
	and $01
	add a, $18
	call SpawnEntity
	call AttackChild_SetVelLow
	call AttackChild_ClearFlag2
	call AttackChild_SetDir1
	call AttackChild_StashPtr
	call AttackChild_CopyAlignFlag
	call AttackChild_CopyAttackPos
	ld de, $0006
	add hl, de
	set 3, [hl]
	ret
Player_SpawnShot12:
	ldh a, [hEntityY]
	add a, $08
	and $f0
	add a, $05
	ld d, a
	ldh a, [hEntityX]
	ld e, a
	ldh a, [hEntityPtrLo]
	ld c, a
	ldh a, [hEntityPtrHi]
	ld b, a
	ld a, [wBombLargeFlags]
	and $01
	add a, $12
	call SpawnEntity
	call AttackChild_SetVelLow
	call AttackChild_SetFlag2
	call AttackChild_SetDir0
	call AttackChild_StashPtr
	call AttackChild_CopyAlignFlag
	call AttackChild_CopyAttackPos
	ld de, $0006
	add hl, de
	set 3, [hl]
	ret
Player_SpawnShot1a:
	ldh a, [hEntityY]
	add a, $08
	and $f0
	sub $02
	ld d, a
	ldh a, [hEntityX]
	ld e, a
	ldh a, [hEntityPtrLo]
	ld c, a
	ldh a, [hEntityPtrHi]
	ld b, a
	ld a, [wBombLargeFlags]
	and $01
	add a, $1a
	call SpawnEntity
	call AttackChild_SetVelLow
	call AttackChild_SetFlag2
	call AttackChild_SetDir1
	call AttackChild_StashPtr
	call AttackChild_CopyAlignFlag
	call AttackChild_CopyAttackPos
	ret
Player_SpawnShot14:
	ldh a, [hEntityY]
	add a, $08
	and $f0
	sub $02
	ld d, a
	ldh a, [hEntityX]
	ld e, a
	ldh a, [hEntityPtrLo]
	ld c, a
	ldh a, [hEntityPtrHi]
	ld b, a
	ld a, [wBombLargeFlags]
	and $01
	add a, $14
	call SpawnEntity
	call AttackChild_SetVelLow
	call AttackChild_ClearFlag2
	call AttackChild_SetDir0
	call AttackChild_StashPtr
	call AttackChild_CopyAlignFlag
	call AttackChild_CopyAttackPos
	ret
AttackChild_SetVelLow:
	push hl
	ld bc, $000f
	add hl, bc
	ld a, $00
	ld [hl+], a
	ld a, $02
	ld [hl], a
	pop hl
	ret
AttackChild_ClearFlag2:
	push hl
	ld bc, $0006
	add hl, bc
	res 2, [hl]
	pop hl
	ret
AttackChild_SetDir0:
	push hl
	ld bc, $0006
	add hl, bc
	ld a, [hl]
	and $fc
	or $00
	ld [hl], a
	pop hl
	ret
AttackChild_SetDir1:
	push hl
	ld bc, $0006
	add hl, bc
	ld a, [hl]
	and $fc
	or $01
	ld [hl], a
	pop hl
	ret
AttackChild_SetFlag2:
	push hl
	ld bc, $0006
	add hl, bc
	set 2, [hl]
	pop hl
	ret
AttackChild_StashPtr:
	ld a, l
	ldh [$ffe7], a
	ld a, h
	ldh [$ffe8], a
	ret
AttackChild_CopyAlignFlag:
	ld a, [wBombLargeFlags]
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
AttackChild_CopyAttackPos:
	push hl
	ld a, $11
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [wCrystalCount]
	ld [hl+], a
	ld a, [$c2cf]
	ld [hl], a
	pop hl
	ret

Data_03_4e47:
	db $f5, $3e, $21, $cd, $85, $0a, $f1, $e5, $7e, $d6, $40, $87, $4f, $06, $00, $21
	db $70, $4e, $09, $2a, $56, $5f, $e1, $e5, $01, $18, $00, $09, $7b, $22, $72, $e1
	db $e5, $11, $16, $00, $19, $af, $77, $e1, $c9, $b4, $7a, $37, $7b, $c5, $7b, $08
	db $7c, $9e, $7c, $25, $7d, $25, $7d

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
	ldh a, [hHitbox2W]
	or a
	jr z, Func_03_4ee8
	ldh a, [hHitbox2X]
	add a, c
	ldh [hHitbox2X], a
	ldh a, [hHitbox2Y]
	add a, b
	ldh [hHitbox2Y], a
	ld a, [$cf71]
	ld b, a
	ldh a, [hHitbox2X]
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	cp c
	jr c, Func_03_4ee8
	ldh a, [hHitbox2X]
	ld c, a
	ldh a, [hHitbox2W]
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
	ldh a, [hHitbox2Y]
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	cp c
	jr c, Func_03_4ee8
	ldh a, [hHitbox2Y]
	ld c, a
	ldh a, [hHitbox2H]
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

Data_03_4ef9:
	db $fa, $71, $cf, $b9, $20, $09, $fa, $72, $cf, $b8, $20, $03, $3e, $01, $c9, $af
	db $c9

PlayerHit_BeginStun:
	ld hl, $ffb4
	bit 7, [hl]
	ret nz
	call UpdateActionTimer
	bit 0, a
	ret z
	ld hl, $ffb4
	set 7, [hl]
	ld a, $14
	ldh [hEntityActionTimer], a
	ret
	xor a
	ldh [hEntityVelYLo], a
	ld a, [wProgressFlags]
	bit 1, a
	jr z, Func_03_4f38
	ld a, [wSpawnCellX]
	ld [$cf6f], a
	ld a, [wSpawnCellY]
	ld [$cf70], a
	jr Func_03_4f44
Func_03_4f38:
	ld a, [wExitCellX]
	ld [$cf6f], a
	ld a, [wExitCellY]
	ld [$cf70], a
Func_03_4f44:
	ld a, [$cf6f]
	swap a
	and $f0
	sub $08
	add a, $08
	ld c, a
	ldh a, [hEntityX]
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
	ldh [hEntityVelXLo], a
	ld a, b
	ldh [hEntityVelXHi], a
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
	ldh [hEntityVelXLo], a
	ld a, b
	ldh [hEntityVelXHi], a
	ld c, $b6
	ldh a, [c]
	and $fc
	or $00
	ldh [c], a
	ret
	xor a
	ldh [hEntityVelYLo], a
	ld a, [wSpawnCellX]
	swap a
	and $f0
	sub $08
	add a, $08
	ld c, a
	ldh a, [hEntityX]
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
	ldh [hEntityVelXLo], a
	ld a, b
	ldh [hEntityVelXHi], a
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
	ldh [hEntityVelXLo], a
	ld a, b
	ldh [hEntityVelXHi], a
	ld c, $b6
	ldh a, [c]
	and $fc
	or $00
	ldh [c], a
	ret
	ldh a, [hEntityYSub]
	ld l, a
	ldh a, [hEntityY]
	ld h, a
	ld a, [$cf70]
	call PlayerYDeltaScaled
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
	call ApplyArcYOffset
	ld a, l
	ldh [hEntityYSub], a
	ld a, h
	ldh [hEntityY], a
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, [$cf6f]
	cp c
	ret nz
	ldh a, [hEntityY]
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
	ldh [hEntityState], a
	ret
	ldh a, [hEntityYSub]
	ld l, a
	ldh a, [hEntityY]
	ld h, a
	ld a, [wSpawnCellY]
	call PlayerYDeltaScaled
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
	call ApplyArcYOffset
	ld a, l
	ldh [hEntityYSub], a
	ld a, h
	ldh [hEntityY], a
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, [wSpawnCellX]
	cp c
	ret nz
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	ld b, a
	ld a, [wSpawnCellY]
	cp b
	ret nz
	ld a, $02
	ld [$c2dd], a
	xor a
	ldh [hEntityState], a
	ret
PlayerYDeltaScaled:
	swap a
	and $f0
	sub $08
	ld b, a
	ldh a, [hEntityY]
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
ApplyArcYOffset:
	ldh a, [hEntityVelYLo]
	cp $40
	ret z
	inc a
	ldh [hEntityVelYLo], a
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

Data_03_515f:
	db $c9, $00

FaceDir0Right:
	ld c, $b6
	ldh a, [c]
	and $fc
	or $00
	res 7, a
	ldh [c], a
	ret
FaceDir1Left:
	ld c, $b6
	ldh a, [c]
	and $fc
	or $01
	set 7, a
	ldh [c], a
	ret
Shard_HomeFaceRight:
	call FaceDir1Left
	call ShardHomeVelX_Fast
	ret
	call FaceDir0Right
	call ShardHomeVelX_Fast
	ret
	call FaceDir1Left
	call ShardHomeVelX_Slow
	ret
Shard_HomeFaceLeft:
	call FaceDir0Right
	call ShardHomeVelX_Slow
	ret
ShardHomeVelX_Fast:
	ldh a, [hEntityX]
	ld c, a
	ld a, [wPlayerX]
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
	ldh [hEntityVelXLo], a
	ld a, b
	ldh [hEntityVelXHi], a
	ret
ShardHomeVelX_Slow:
	ldh a, [hEntityX]
	ld c, a
	ld a, [wPlayerX]
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
	ldh [hEntityVelXLo], a
	ld a, b
	ldh [hEntityVelXHi], a
	ret

Data_03_51f0:
	db $cd, $1f, $44, $cb, $47, $28, $05, $3e, $ff, $e0, $b8, $c9, $f0, $be, $47, $f0
	db $bc, $4f, $f0, $d2, $81, $4f, $f0, $b6, $cb, $7f, $20, $06, $f0, $d4, $81, $4f
	db $18, $01, $0d, $79, $c6, $08, $cb, $37, $e6, $0f, $4f, $78, $c6, $08, $cb, $37
	db $e6, $0f, $47, $c5, $cd, $1b, $10, $c1, $b7, $20, $1b, $f0, $be, $47, $f0, $d3
	db $80, $47, $f0, $d5, $80, $c6, $08, $cb, $37, $e6, $0f, $47, $cd, $1b, $10, $b7
	db $28, $04, $af, $e0, $b8, $c9, $3e, $03, $e0, $b8, $c9

Tacopi_ProbeFrontTile:
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_5257
	ld a, $ff
	ldh [hEntityResult], a
	ret
Func_03_5257:
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_526d
	ldh a, [hEntityProbeW]
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
	call GetCollisionCell
	or a
	jr nz, Func_03_5288
	xor a
	ldh [hEntityResult], a
	ret
Func_03_5288:
	cp $22
	jr z, Func_03_5295
	cp $23
	jr z, Func_03_5295
	ld a, $03
	ldh [hEntityResult], a
	ret
Func_03_5295:
	ld a, $02
	ldh [hEntityResult], a
	ret
ProbeFrontTile:
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_52b0
	ldh a, [hEntityProbeW]
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
	call GetCollisionCell
	or a
	jr nz, Func_03_52cb
	xor a
	ldh [hEntityResult], a
	ret
Func_03_52cb:
	ld a, $03
	ldh [hEntityResult], a
	ret
Ghost_ProbeFrontTileDir:
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	ld b, a
	ldh a, [hEntityFacing]
	and $03
	cp $03
	jr z, Func_03_52e6
	cp $02
	jr nz, Func_03_5303
	dec b
	jr Func_03_52ea
Func_03_52e6:
	ldh a, [hEntityProbeH]
	add a, b
	ld b, a
Func_03_52ea:
	ldh a, [hEntityX]
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
	call GetCollisionCell
	or a
	jr nz, Func_03_5307
Func_03_5303:
	xor a
	ldh [hEntityResult], a
	ret
Func_03_5307:
	ldh a, [hEntityFacing]
	and $03
	cp $03
	jr z, Func_03_5318
	cp $02
	jr nz, Func_03_531d
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_5318:
	ld a, $02
	ldh [hEntityResult], a
	ret

Func_03_531d:
	ld a, $03
	ldh [hEntityResult], a
	ret

SpawnProjectileInFront:
	push de
	ldh a, [hEntityY]
	ld d, a
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_03_5352
	ldh a, [hEntityX]
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
	ldh a, [hEntityX]
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

Henger_FireShot:
	db $0e, $22, $cd, $22, $53, $c9

SpawnProjectile20:
	ld c, $20
	call SpawnProjectileInFront
	ret
Joker_FireShot:
	ld c, $23
	call SpawnProjectileInFront
	ret
SpawnProjectile24:
	ld c, $24
	call SpawnProjectileInFront
	ret
Gali_FireShot:
	ld c, $25
	call SpawnProjectileInFront
	ret
SpawnProjectile21:
	ld c, $21
	call SpawnProjectileInFront
	ret
SpawnProjectileRel:
	push de
	push af
	ldh a, [hEntityY]
	add a, b
	ld d, a
	ldh a, [hEntityX]
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
	ldh a, [hEntityFacing]
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
Ducken_FireMissileA:
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_03_53f6
	ld c, $f0
	ld a, $2a
	ld b, $00
	call SpawnProjectileRel
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
	call SpawnProjectileRel
	push hl
	ld bc, $0006
	add hl, bc
	ld a, [hl]
	and $fc
	or $00
	ld [hl], a
	pop hl
Func_03_540b:
	call SetProjectileSpeed
	ret

Ducken_FireMissileB:
	db $f0, $b6, $cb, $7f, $20, $17, $06, $f0, $3e, $2b, $0e, $00, $cd, $94, $53, $e5
	db $01, $06, $00, $09, $7e, $e6, $fc, $f6, $02, $77, $e1, $18, $17, $06, $10, $3e
	db $2b, $0e, $00, $cd, $94, $53, $e5, $01, $06, $00, $09, $7e, $e6, $fc, $f6, $03
	db $cb, $ff, $77, $e1, $cd, $47, $54, $c9

SetProjectileSpeed:
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

Data_03_545e:
	db $2c, $01, $f0, $00, $b4, $00, $78, $00, $3c, $00

Data_03_5468:
	db $3c, $00, $3c, $00
Tiger_FireMissile:
	db $f0, $b6, $cb, $7f, $28, $04, $0e, $f0, $18, $02, $0e, $10, $3e, $26, $06, $f8
	db $cd, $94, $53, $cd, $47, $54, $c9

Plant_FireMissile:
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_03_548d
	ld c, $f0
	jr Func_03_548f
Func_03_548d:
	ld c, $10
Func_03_548f:
	ld a, $27
	ld b, $f8
	call SpawnProjectileRel
	call SetProjectileSpeed
	ret
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_03_54a4
	ld c, $f0
	jr Func_03_54a6
Func_03_54a4:
	ld c, $10
Func_03_54a6:
	ld b, $18
	ld a, $29
	call SpawnProjectileRel
	ret
	ld a, $29
	ld b, $18
	ld c, $00
	call SpawnProjectileRel
	ret
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_03_54c2
	ld c, $10
	jr Func_03_54c4
Func_03_54c2:
	ld c, $f0
Func_03_54c4:
	ld b, $18
	ld a, $29
	call SpawnProjectileRel
	ret
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_03_54d6
	ld c, $d8
	jr Func_03_54d8
Func_03_54d6:
	ld c, $28
Func_03_54d8:
	ld b, $08
	ld a, $28
	call SpawnProjectileRel
	ret
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_03_54ea
	ld c, $e8
	jr Func_03_54ec
Func_03_54ea:
	ld c, $18
Func_03_54ec:
	ld b, $08
	ld a, $28
	call SpawnProjectileRel
	ret
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_03_54fe
	ld c, $f8
	jr Func_03_5500
Func_03_54fe:
	ld c, $08
Func_03_5500:
	ld b, $08
	ld a, $28
	call SpawnProjectileRel
	ret
SpawnFloorFlameOrFX:
	ld a, [wActiveFloor]
	cp $05
	jr z, Func_03_5518
	FAR_CALL Func_01_4d0d
	ret
Func_03_5518:
	ld a, [wExitCellX]
	swap a
	and $f0
	sub $08
	add a, $08
	ld e, a
	ld a, [wExitCellY]
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
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld [wExitCellX], a
	swap a
	and $f0
	sub $08
	add a, $08
	ld e, a
	ldh a, [hEntityY]
	sub $08
	add a, $08
	swap a
	and $0f
	ld [wExitCellY], a
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
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld [wExitCellX], a
	swap a
	and $f0
	sub $08
	add a, $08
	ld e, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	ld [wExitCellY], a
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
	call SpawnBossSegment
	ld a, $02
	call SpawnBossSegment
	ld a, $03
	call SpawnBossSegment
	ld a, $04
	call SpawnBossSegment
	ld a, $06
	call SpawnBossSegment
	ld a, $07
	call SpawnBossSegment
	ld a, $08
	call SpawnBossSegment
	ld a, $09
	call SpawnBossSegment
	call SpawnFloorFlameOrFX
	pop de
	ret
SpawnBossSegment:
	push af
	ldh a, [hEntityX]
	ld e, a
	ldh a, [hEntityY]
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
	ldh a, [hEntityFacing]
	bit 6, a
	ret nz
	ldh a, [hEntityAnimSel]
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

Data_03_5616:
	ret

Func_03_5617:
	ldh a, [hEntityXSub]
	ld c, a
	ldh a, [hEntityX]
	ld b, a
	ld hl, $fe9a
	add hl, bc
	ld a, l
	ldh [hEntityXSub], a
	ld a, h
	ldh [hEntityX], a
	ld a, h
	cp b
	jr c, Func_03_5630
	ld hl, $ffb6
	set 6, [hl]
Func_03_5630:
	ldh a, [hEntityYSub]
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ld hl, $0166
	add hl, bc
	ld a, l
	ldh [hEntityYSub], a
	ld a, h
	ldh [hEntityY], a
	ld a, h
	cp b
	ret nc
	ld hl, $ffb6
	set 6, [hl]
	ret
Func_03_5649:
	ldh a, [hEntityXSub]
	ld c, a
	ldh a, [hEntityX]
	ld b, a
	ld hl, $0166
	add hl, bc
	ld a, l
	ldh [hEntityXSub], a
	ld a, h
	ldh [hEntityX], a
	ld a, h
	cp b
	jr nc, Func_03_5662
	ld hl, $ffb6
	set 6, [hl]
Func_03_5662:
	ldh a, [hEntityYSub]
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ld hl, $0166
	add hl, bc
	ld a, l
	ldh [hEntityYSub], a
	ld a, h
	ldh [hEntityY], a
	ld a, h
	cp b
	ret nc
	ld hl, $ffb6
	set 6, [hl]
	ret
Func_03_567b:
	ldh a, [hEntityXSub]
	ld c, a
	ldh a, [hEntityX]
	ld b, a
	ld hl, $fe9a
	add hl, bc
	ld a, l
	ldh [hEntityXSub], a
	ld a, h
	ldh [hEntityX], a
	ld a, h
	cp b
	jr c, Func_03_5694
	ld hl, $ffb6
	set 6, [hl]
Func_03_5694:
	ldh a, [hEntityYSub]
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ld hl, $fe9a
	add hl, bc
	ld a, l
	ldh [hEntityYSub], a
	ld a, h
	ldh [hEntityY], a
	ld a, h
	cp b
	ret c
	ld hl, $ffb6
	set 6, [hl]
	ret
Func_03_56ad:
	ldh a, [hEntityXSub]
	ld c, a
	ldh a, [hEntityX]
	ld b, a
	ld hl, $0166
	add hl, bc
	ld a, l
	ldh [hEntityXSub], a
	ld a, h
	ldh [hEntityX], a
	ld a, h
	cp b
	jr nc, Func_03_56c6
	ld hl, $ffb6
	set 6, [hl]
Func_03_56c6:
	ldh a, [hEntityYSub]
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ld hl, $fe9a
	add hl, bc
	ld a, l
	ldh [hEntityYSub], a
	ld a, h
	ldh [hEntityY], a
	ld a, h
	cp b
	ret c
	ld hl, $ffb6
	set 6, [hl]
	ret
Func_03_56df:
	ldh a, [hEntityYSub]
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ld hl, $0200
	add hl, bc
	ld a, l
	ldh [hEntityYSub], a
	ld a, h
	ldh [hEntityY], a
	ld a, h
	cp b
	ret nc
	ld hl, $ffb6
	set 6, [hl]
	ret
Func_03_56f8:
	ldh a, [hEntityYSub]
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ld hl, $fe00
	add hl, bc
	ld a, l
	ldh [hEntityYSub], a
	ld a, h
	ldh [hEntityY], a
	ld a, h
	cp b
	ret c
	ld hl, $ffb6
	set 6, [hl]
	ret
Func_03_5711:
	ldh a, [hEntityXSub]
	ld c, a
	ldh a, [hEntityX]
	ld b, a
	ld hl, $fe00
	add hl, bc
	ld a, l
	ldh [hEntityXSub], a
	ld a, h
	ldh [hEntityX], a
	ld a, h
	cp b
	ret c
	ld hl, $ffb6
	set 6, [hl]
	ret
Func_03_572a:
	ldh a, [hEntityXSub]
	ld c, a
	ldh a, [hEntityX]
	ld b, a
	ld hl, $0200
	add hl, bc
	ld a, l
	ldh [hEntityXSub], a
	ld a, h
	ldh [hEntityX], a
	ld a, h
	cp b
	ret nc
	ld hl, $ffb6
	set 6, [hl]
	ret
Door_SlideInFast:
	ldh a, [hEntityXSub]
	ld l, a
	ldh a, [hEntityX]
	ld h, a
	ld bc, $0300
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	ld a, l
	ldh [hEntityXSub], a
	ld a, h
	ldh [hEntityX], a
	jr Func_03_5786
Door_SlideInMed:
	ldh a, [hEntityXSub]
	ld l, a
	ldh a, [hEntityX]
	ld h, a
	ld bc, $0200
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	ld a, l
	ldh [hEntityXSub], a
	ld a, h
	ldh [hEntityX], a
	jr Func_03_5786
Door_SlideInSlow:
	ldh a, [hEntityXSub]
	ld l, a
	ldh a, [hEntityX]
	ld h, a
	ld bc, $0100
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	ld a, l
	ldh [hEntityXSub], a
	ld a, h
	ldh [hEntityX], a
Func_03_5786:
	ldh a, [hEntityYSub]
	ld l, a
	ldh a, [hEntityY]
	ld h, a
	ld bc, $0100
	add hl, bc
	ld a, l
	ldh [hEntityYSub], a
	ld a, h
	ldh [hEntityY], a
	ret
SlideDownToY80:
	ldh a, [hEntityYSub]
	ld l, a
	ldh a, [hEntityY]
	ld h, a
	ld bc, $0100
	add hl, bc
	ld a, l
	ldh [hEntityYSub], a
	ld a, h
	ldh [hEntityY], a
	cp $80
	jr nz, Func_03_57b0
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_57b0:
	xor a
	ldh [hEntityResult], a
	ret
SetTimer120:
	ld a, $78
	ldh [$ffc3], a
	xor a
	ldh [$ffc4], a
	ret
DecGenTimer16:
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
DecYCounter:
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
	ldh a, [hEntityFacing]
	ld c, a
	push de
	FAR_CALL Func_01_42b3
	pop de
	ld a, c
	ldh [hEntityVelYLo], a
	ld a, b
	ldh [hEntityVelYHi], a
	ldh a, [hEntityAnimState]
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
	ldh a, [hEntityAnimSel]
	and $03
	jr Func_03_5831
Func_03_5821:
	ldh a, [hEntityAnimSel]
	and $0c
	sra a
	sra a
	jr Func_03_5831
Func_03_582b:
	ldh a, [hEntityAnimSel]
	and $30
	swap a
Func_03_5831:
	call Func_03_5840
	ldh a, [hEntityAnimState]
	inc a
	ldh [hEntityAnimState], a
	cp $06
	ret nz
	xor a
	ldh [hEntityAnimState], a
	ret
Func_03_5840:
	cp $03
	ret z
	push de
	push hl
	push af
	ld hl, wFloorMonsterSpecies
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	add a, $30
	push af
	push af
	ldh a, [hEntityX]
	ld e, a
	ldh a, [hEntityY]
	ld d, a
	ldh a, [hEntityPtrLo]
	ld c, a
	ldh a, [hEntityPtrHi]
	ld b, a
	pop af
	call SpawnEntity
	pop af
	call SetSpawnScriptBySpecies
	call SetSpriteTileByFacing
	pop af
	call SetOamAttrByFacing
	call SetAnimSelByFacing
	call UpdateFacingField
	pop hl
	pop de
	ret
SetSpawnScriptBySpecies:
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

Data_03_5893:
	db $46, $75, $df, $75, $71, $76

SetOamAttrByFacing:
	push af
	ldh a, [hEntityFacing]
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
SetSpriteTileByFacing:
	push hl
	ldh a, [hEntityFacing]
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

Data_03_58cf:
	db $40, $01, $80, $02, $c0, $03, $00, $05

Data_03_58d7:
	db $40, $06, $80, $07, $c0, $08, $00, $0a

SetAnimSelByFacing:
	ldh a, [hEntityFacing]
	and $e0
	swap a
	sra a
	push hl
	ld de, $0021
	add hl, de
	ld [hl], a
	pop hl
	ret
UpdateFacingField:
	push hl
	ld de, $0006
	add hl, de
	ld b, [hl]
	ldh a, [hEntityFacing]
	and $03
	or a
	jr z, Func_03_590b
	cp $01
	jr z, Func_03_5907
	ldh a, [hEntityAnimState]
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
DecFreezeTimerElseReset:
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
	ldh a, [hEntityState]
	sub $30
	add a, a
	ld c, a
	ld b, $00
	ld hl, $5932
	add hl, bc
	ld a, [hl+]
	ldh [hEntityScriptPtrLo], a
	ld a, [hl]
	ldh [hEntityScriptPtrHi], a
	xor a
	ldh [hEntityTimer], a
	ret

Data_03_5932:
	db $63, $75, $0c, $76, $9f, $76

Jell_Think3:
	call MonsterProbeWalkAhead
	ldh a, [hEntityResult]
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

Func_03_5952:
	ld de, $75b5
	ret

Jell_Think5:
	call MonsterProbeWalkAhead
	ldh a, [hEntityResult]
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
Jell_Think4:
	call MonsterProbeWalkAhead
	ldh a, [hEntityResult]
	cp $ff
	jr z, Func_03_599a
	cp $01
	jr z, Func_03_599e
	cp $02
	jr z, Func_03_59a2
	cp $03
	jr z, Func_03_59a6
	ret

Func_03_599a:
	ld de, $75d1
	ret

Func_03_599e:
	ld de, $759b
	ret
Func_03_59a2:
	ld de, $75b5
	ret
Func_03_59a6:
	ld de, $757c
	ret
MonsterProbeWalkAhead:
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_59b6
	ld a, $ff
	ldh [hEntityResult], a
	ret
Func_03_59b6:
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_59cc
	ldh a, [hEntityProbeW]
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
	call GetCollisionCell
	pop bc
	or a
	jr nz, Func_03_5a07
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeH]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
	or a
	jr z, Func_03_5a19
	call PlayerInFrontInRange
	or a
	jr nz, Func_03_5a02
	xor a
	ldh [hEntityResult], a
	ret
Func_03_5a02:
	ld a, $04
	ldh [hEntityResult], a
	ret
Func_03_5a07:
	cp $22
	jr z, Func_03_5a0f
	cp $23
	jr nz, Func_03_5a14
Func_03_5a0f:
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_5a14:
	ld a, $02
	ldh [hEntityResult], a
	ret
Func_03_5a19:
	ld a, $03
	ldh [hEntityResult], a
	ret
PlayerInFrontInRange:
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_5a2f
	ldh a, [hEntityX]
	ld c, a
	ld a, [wPlayerX]
	cp c
	jr nc, Func_03_5a3a
	xor a
	ret
Func_03_5a2f:
	ldh a, [hEntityX]
	ld c, a
	ld a, [wPlayerX]
	cp c
	jr c, Func_03_5a3a
	xor a
	ret
Func_03_5a3a:
	ld a, [wPlayerY]
	ld b, a
	ldh a, [hEntityY]
	call OrderPair
	sub b
	cp $11
	jr c, Func_03_5a4a
	xor a
	ret
Func_03_5a4a:
	ld a, $01
	ret
Tacopi_Think:
	call Tacopi_ProbeFrontTile
	ldh a, [hEntityResult]
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
Dino_Think4:
	call MonsterProbeChargeAlign
	ldh a, [hEntityResult]
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

Func_03_5a8d:
	ld de, $76b8
	ret

Dino_Think5:
	call Dino_ProbeChargeOrWall
	ldh a, [hEntityResult]
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

Func_03_5aab:
	ld de, $76ff
	ret

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
Dino_ProbeChargeOrWall:
	call MonsterProbeChargeAlign
	cp $ff
	ret z
	cp $02
	ret z
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_5ade
	ldh a, [hEntityProbeW]
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
	call GetCollisionCell
	pop bc
	or a
	jr nz, Func_03_5b15
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeH]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
	or a
	jr z, Func_03_5b22
	ldh a, [$ffc3]
	ld l, a
	ldh a, [$ffc4]
	or l
	ret z
	xor a
	ldh [hEntityResult], a
	ret
Func_03_5b15:
	cp $22
	jr z, Func_03_5b1d
	cp $23
	jr nz, Func_03_5b22
Func_03_5b1d:
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_5b22:
	ldh a, [hEntityResult]
	or a
	jr nz, Func_03_5b2c
	ld a, $03
	ldh [hEntityResult], a
	ret
Func_03_5b2c:
	ldh a, [$ffc3]
	ld l, a
	ldh a, [$ffc4]
	or l
	ret z
	ld a, $04
	ldh [hEntityResult], a
	ret
MonsterProbeChargeAlign:
	call DecGenTimer16
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_5b47
	ld a, $ff
	ldh [hEntityResult], a
	ret
Func_03_5b47:
	call PlayerSameRowInRange
	or a
	jr nz, Func_03_5b51
	xor a
	ldh [hEntityResult], a
	ret
Func_03_5b51:
	call FacePlayerX
	ld hl, $ffb6
	ldh a, [hEntityMoveResult]
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
	ldh [hEntityResult], a
	ret
Func_03_5b6c:
	ld a, $01
	ldh [hEntityResult], a
	ret
Plant_Think:
	call Plant_ProbeFireWindow
	ldh a, [hEntityResult]
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

Func_03_5b8f:
	ld de, $7723
	ret
Func_03_5b93:
	ld de, $7727
	ret

Plant_ThinkB:
	call Plant_ProbeFireWindow
	ldh a, [hEntityResult]
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

Func_03_5bb5:
	ld de, $7713
	ret
Func_03_5bb9:
	ld de, $7727
	ret

Plant_ThinkC:
	call Plant_ProbeFireOrTurn
	ldh a, [hEntityResult]
	cp $ff
	jr z, Func_03_5bd3
	cp $01
	jr z, Func_03_5bd7
	cp $02
	jr z, Func_03_5bdb
	cp $03
	jr z, Func_03_5bdf
	ret

Func_03_5bd3:
	ld de, $7763
	ret

Func_03_5bd7:
	ld de, $7746
	ret
Func_03_5bdb:
	ld de, $7713
	ret
Func_03_5bdf:
	ld de, $7727
	ret
Plant_ProbeFireOrTurn:
	call Plant_ProbeFireWindow
	or a
	ret nz
	ld a, b
	ld [$cf65], a
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_5c02
	ldh a, [hEntityProbeW]
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
	call GetCollisionCell
	pop bc
	or a
	jr nz, Func_03_5c32
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeH]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
	or a
	jr z, Func_03_5c32
	xor a
	ldh [hEntityResult], a
	ret
Func_03_5c32:
	ld a, [$cf65]
	or a
	jr z, Func_03_5c3d
	ld a, $02
	ldh [hEntityResult], a
	ret
Func_03_5c3d:
	ld a, $03
	ldh [hEntityResult], a
	ret
Plant_ProbeFireWindow:
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_5c50
	ld a, $ff
	ldh [hEntityResult], a
	ld b, $00
	ret
Func_03_5c50:
	call PlayerAheadSameRow
	or a
	jr nz, Func_03_5c5c
	xor a
	ldh [hEntityResult], a
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
	ldh [hEntityResult], a
	ld b, $01
	ret
Func_03_5c6f:
	ld a, $01
	ldh [hEntityResult], a
	ld b, $01
	ret
Ghost_ThinkB:
	ldh a, [hEntityX]
	ld c, a
	ld hl, $ffb6
	ld a, [wPlayerX]
	cp c
	jr c, Func_03_5c85
	res 7, [hl]
	ret
Func_03_5c85:
	set 7, [hl]
	ret
Ghost_Think:
	call Ghost_ProbeFrontTileDir
	call Ghost_ThinkB
	ldh a, [hEntityResult]
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

Func_03_5ca5:
	ld de, $7807
	ret

Henger_Think:
	call ProbeFrontTile
	ldh a, [hEntityResult]
	cp $03
	ret nz
	ld de, $7793
	ret
Joker_Think:
	call ProbeFrontTile
	ldh a, [hEntityResult]
	cp $03
	ret nz
	ld de, $77c2
	ret
Puncho_Think:
	call ProbeAimedOrLedge
	ldh a, [hEntityResult]
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
Puncho_ThinkB:
	call ProbeAimedOrLedge
	ldh a, [hEntityResult]
	cp $ff
	jr z, Func_03_5ce9
	cp $01
	jr z, Func_03_5ced
	cp $03
	jr z, Func_03_5cf1
	ret

Func_03_5ce9:
	ld de, $7897
	ret

Func_03_5ced:
	ld de, $788b
	ret
Func_03_5cf1:
	ld de, $786c
	ret
Puncho_ThinkC:
	call ProbeAimedOrLedge
	ldh a, [hEntityResult]
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
Puncho_ThinkD:
	call ProbeAimedOrCrate
	ldh a, [hEntityResult]
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
Psylora_SelectMoveScript:
	ldh a, [hEntityFacing]
	bit 2, a
	jr z, Func_03_5d2b
	call Psylora_DispatchMoveA
	ret
Func_03_5d2b:
	call Psylora_DispatchMoveB
	ret
Psylora_DispatchMoveA:
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

Func_03_5d49:
	ld de, $790b
	ret

Psylora_DispatchMoveB:
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
Psylora_MoveDirA:
	ldh a, [hEntityFacing]
	bit 2, a
	jr nz, Func_03_5d7d
	bit 3, a
	jr z, Func_03_5d79
	call WallFollow_DownRight
	ret
Func_03_5d79:
	call WallTurn_DownToLeft
	ret
Func_03_5d7d:
	bit 3, a
	jr z, Func_03_5d85
	call WallFollow_DownLeft
	ret
Func_03_5d85:
	call WallTurn_DownToRight
	ret
Psylora_MoveDirB:
	ldh a, [hEntityFacing]
	bit 2, a
	jr nz, Func_03_5d9b
	bit 3, a
	jr z, Func_03_5d97
	call WallFollow_UpLeft
	ret
Func_03_5d97:
	call WallTurn_UpToLeft
	ret
Func_03_5d9b:
	bit 3, a
	jr z, Func_03_5da3
	call WallFollow_UpRight
	ret
Func_03_5da3:
	call WallTurn_UpToRight
	ret
Psylora_MoveDirC:
	ldh a, [hEntityFacing]
	bit 2, a
	jr nz, Func_03_5db9
	bit 3, a
	jr z, Func_03_5db5
	call WallFollow_RightUp
	ret
Func_03_5db5:
	call WallTurn_RightToDown
	ret
Func_03_5db9:
	bit 3, a
	jr z, Func_03_5dc1
	call WallFollow_RightDown
	ret
Func_03_5dc1:
	call WallTurn_RightToUp
	ret
Psylora_MoveDirD:
	ldh a, [hEntityFacing]
	bit 2, a
	jr nz, Func_03_5dd7
	bit 3, a
	jr z, Func_03_5dd3
	call WallFollow_LeftUp
	ret
Func_03_5dd3:
	call WallTurn_LeftToDown
	ret
Func_03_5dd7:
	bit 3, a
	jr z, Func_03_5ddf
	call WallFollow_LeftDown
	ret
Func_03_5ddf:
	call WallTurn_LeftToUp
	ret
WallFollow_DownRight:
	ldh a, [hEntityX]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	jp nz, Func_03_5e4e
	ldh a, [hEntityY]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	ret nz
	ldh a, [hEntityX]
	sub $08
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call GetCollisionCell
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
	call GetCollisionCell
	or a
	ret nz
	ld de, $7921
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	ld [hl], a
	call SnapXToCellLow
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
	call SnapXToCellHigh
	ret
WallFollow_DownLeft:
	ldh a, [hEntityX]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	jp nz, Func_03_5ec9
	ldh a, [hEntityY]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	ret nz
	ldh a, [hEntityX]
	sub $08
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call GetCollisionCell
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
	call GetCollisionCell
	or a
	ret nz
	ld de, $792c
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	ld [hl], a
	call SnapXToCellLow
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
	call SnapXToCellHigh
	ret
WallFollow_UpLeft:
	ldh a, [hEntityX]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	jp nz, Func_03_5f44
	ldh a, [hEntityY]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	ret nz
	ldh a, [hEntityX]
	add a, $07
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call GetCollisionCell
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
	call GetCollisionCell
	or a
	ret nz
	ld de, $7916
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	ld [hl], a
	call SnapXToCellHigh
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
	call SnapXToCellLow
	ret
WallFollow_UpRight:
	ldh a, [hEntityX]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	jp nz, Func_03_5fbf
	ldh a, [hEntityY]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	ret nz
	ldh a, [hEntityX]
	add a, $07
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call GetCollisionCell
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
	call GetCollisionCell
	or a
	ret nz
	ld de, $790b
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	ld [hl], a
	call SnapXToCellHigh
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
	call SnapXToCellLow
	ret
WallFollow_RightUp:
	ldh a, [hEntityX]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	jp nz, Func_03_603a
	ldh a, [hEntityX]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	ret nz
	ldh a, [hEntityY]
	add a, $07
	ld b, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
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
	call GetCollisionCell
	or a
	ret nz
	ld de, $78ea
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	ld [hl], a
	call SnapYToCellHigh
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
	call SnapYToCellLow
	ret
WallFollow_RightDown:
	ldh a, [hEntityX]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	jp nz, Func_03_60b5
	ldh a, [hEntityX]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	ret nz
	ldh a, [hEntityY]
	add a, $07
	ld b, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
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
	call GetCollisionCell
	or a
	ret nz
	ld de, $78df
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	ld [hl], a
	call SnapYToCellHigh
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
	call SnapYToCellLow
	ret
WallFollow_LeftUp:
	ldh a, [hEntityX]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	jp nz, Func_03_6130
	ldh a, [hEntityX]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	ret nz
	ldh a, [hEntityY]
	sub $08
	ld b, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
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
	call GetCollisionCell
	or a
	ret nz
	ld de, $78f5
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	ld [hl], a
	call SnapYToCellLow
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
	call SnapYToCellHigh
	ret
WallFollow_LeftDown:
	ldh a, [hEntityX]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	jp nz, Func_03_61ab
	ldh a, [hEntityX]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	push bc
	call GetCollisionCell
	pop bc
	or a
	ret nz
	ldh a, [hEntityY]
	sub $08
	ld b, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
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
	call GetCollisionCell
	or a
	ret nz
	ld de, $7900
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	ld [hl], a
	call SnapYToCellLow
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
	call SnapYToCellHigh
	ret
WallTurn_DownToLeft:
	ldh a, [hEntityX]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
	or a
	ret z
	ld de, $7916
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	set 3, a
	ld [hl], a
	call SnapXToCellHigh
	ret
WallTurn_DownToRight:
	ldh a, [hEntityX]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
	or a
	ret z
	ld de, $790b
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	set 3, a
	ld [hl], a
	call SnapXToCellHigh
	ret
WallTurn_UpToLeft:
	ldh a, [hEntityX]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
	or a
	ret z
	ld de, $7921
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	set 3, a
	ld [hl], a
	call SnapXToCellLow
	ret
WallTurn_UpToRight:
	ldh a, [hEntityX]
	sub $08
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
	or a
	ret z
	ld de, $792c
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	set 3, a
	ld [hl], a
	call SnapXToCellLow
	ret
WallTurn_RightToDown:
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
	or a
	ret z
	ld de, $78f5
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	set 3, a
	ld [hl], a
	call SnapYToCellLow
	ret
WallTurn_RightToUp:
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	sub $08
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
	or a
	ret z
	ld de, $7900
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	set 3, a
	ld [hl], a
	call SnapYToCellLow
	ret
WallTurn_LeftToDown:
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
	or a
	ret z
	ld de, $78ea
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	set 3, a
	ld [hl], a
	call SnapYToCellHigh
	ret
WallTurn_LeftToUp:
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $07
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
	or a
	ret z
	ld de, $78df
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	set 3, a
	ld [hl], a
	call SnapYToCellHigh
	ret
SnapXToCellLow:
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	sub $08
	add a, $07
	ldh [hEntityX], a
	xor a
	ldh [hEntityXSub], a
	ret
SnapXToCellHigh:
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	sub $08
	add a, $09
	ldh [hEntityX], a
	xor a
	ldh [hEntityXSub], a
	ret
SnapYToCellLow:
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	sub $08
	add a, $07
	ldh [hEntityY], a
	xor a
	ldh [hEntityYSub], a
	ret
SnapYToCellHigh:
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	sub $08
	add a, $09
	ldh [hEntityY], a
	xor a
	ldh [hEntityYSub], a
	ret
Ducken_FireTimerProbe:
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
	ldh [hEntityResult], a
	ret
Func_03_637c:
	ld a, $01
	ldh [hEntityResult], a
	ret
Ducken_AimVertical:
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

Func_03_639f:
	res 7, [hl]
	ld de, $7995
	ret

Func_03_63a5:
	set 7, [hl]
	ld de, $7995
	ret
Ducken_AimHorizontal:
	ldh a, [hEntityFacing]
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
Naga_Think4:
	call Naga_ProbeChargeAlign
	ldh a, [hEntityResult]
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

Func_03_640b:
	ld de, $7625
	ret

Naga_Think5:
	call Naga_ProbeChargeOrWall
	ldh a, [hEntityResult]
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
Naga_ProbeChargeOrWall:
	call Naga_ProbeChargeAlign
	cp $ff
	ret z
	cp $02
	ret z
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_645c
	ldh a, [hEntityProbeW]
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
	call GetCollisionCell
	pop bc
	or a
	jr nz, Func_03_6480
	ldh a, [$ffc3]
	ld l, a
	ldh a, [$ffc4]
	or l
	ret z
	xor a
	ldh [hEntityResult], a
	ret
Func_03_6480:
	cp $22
	jr z, Func_03_6488
	cp $23
	jr nz, Func_03_648d
Func_03_6488:
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_648d:
	ldh a, [hEntityResult]
	or a
	jr nz, Func_03_6497
	ld a, $03
	ldh [hEntityResult], a
	ret
Func_03_6497:
	ldh a, [$ffc3]
	ld l, a
	ldh a, [$ffc4]
	or l
	ret z
	ld a, $04
	ldh [hEntityResult], a
	ret
Naga_ProbeChargeAlign:
	call DecGenTimer16
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_64b2
	ld a, $ff
	ldh [hEntityResult], a
	ret
Func_03_64b2:
	call PlayerSameRowInRange
	or a
	jr nz, Func_03_64bc
	xor a
	ldh [hEntityResult], a
	ret
Func_03_64bc:
	call FacePlayerX
	ldh a, [hEntityMoveResult]
	bit 1, a
	jr nz, Func_03_64cd
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_03_64d8
	jr Func_03_64d3
Func_03_64cd:
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_64d8
Func_03_64d3:
	ld a, $02
	ldh [hEntityResult], a
	ret
Func_03_64d8:
	ld a, $01
	ldh [hEntityResult], a
	ret
	call Tiger_ProbeFireWindow
	ldh a, [hEntityResult]
	cp $ff
	jr z, Func_03_64f3
	cp $01
	jr z, Func_03_64f7
	cp $02
	jr z, Func_03_64fb
	cp $03
	jr z, Func_03_64ff
	ret

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

Tiger_Think:
	call Tiger_ProbeFireWindow
	ldh a, [hEntityResult]
	cp $ff
	jr z, Func_03_6519
	cp $01
	jr z, Func_03_651d
	cp $02
	jr z, Func_03_6521
	cp $03
	jr z, Func_03_6525
	ret

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

Tiger_ThinkProbe:
	call Tiger_ProbeFireOrTurn
	ldh a, [hEntityResult]
	cp $ff
	jr z, Func_03_653f
	cp $01
	jr z, Func_03_6543
	cp $02
	jr z, Func_03_6547
	cp $03
	jr z, Func_03_654b
	ret

Func_03_653f:
	ld de, $7aa9
	ret
Func_03_6543:
	ld de, $7a8c
	ret
Func_03_6547:
	ld de, $7a59
	ret

Func_03_654b:
	ld de, $7a6d
	ret
Tiger_ProbeFireOrTurn:
	call Tiger_ProbeFireWindow
	or a
	ret nz
	ld a, b
	ld [$cf65], a
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_656e
	ldh a, [hEntityProbeW]
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
	call GetCollisionCell
	pop bc
	or a
	jr nz, Func_03_659e
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeH]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
	or a
	jr z, Func_03_659e
	xor a
	ldh [hEntityResult], a
	ret
Func_03_659e:
	ld a, [$cf65]
	or a
	jr z, Func_03_65a9

Data_03_65a4:
	ld a, $02
	ldh [hEntityResult], a
	ret

Func_03_65a9:
	ld a, $03
	ldh [hEntityResult], a
	ret

Tiger_ProbeFireWindow:
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_65bc
Data_03_65b5:
	ld a, $ff
	ldh [hEntityResult], a
	ld b, $00
	ret

Func_03_65bc:
	xor a
	ldh [hEntityResult], a
	ld b, $00
	ret

Data_03_65c2:
	db $21, $c3, $ff, $2a, $4f, $46, $b0, $28, $0a, $0b, $78, $32, $71, $af, $e0, $b8
	db $06, $01, $c9, $3e, $01, $e0, $b8, $06, $01, $c9

Mocchi_Think:
	call ProbeAimedOrLedge
	ldh a, [hEntityResult]
	cp $ff
	jr z, Func_03_65ea
	cp $01
	jr z, Func_03_65ee
	ret
Func_03_65ea:
	ld de, $7b00
	ret

Func_03_65ee:
	ld de, $7af4
	ret

Mocchi_ThinkB:
	call ProbeAimedOrLedge
	ldh a, [hEntityResult]
	cp $ff
	jr z, Func_03_6604
	cp $01
	jr z, Func_03_6608
	cp $03
	jr z, Func_03_660c
	ret

Func_03_6604:
	ld de, $7b00
	ret

Func_03_6608:
	ld de, $7af4
	ret
Func_03_660c:
	ld de, $7ad5
	ret
Mocchi_ThinkC:
	call ProbeAimedOrLedge
	ldh a, [hEntityResult]
	cp $ff
	jr z, Func_03_661e
	cp $02
	jr z, Func_03_6622
	ret

Func_03_661e:
	ld de, $7b00
	ret
Func_03_6622:
	ld de, $7ac5
	ret
Mocchi_ThinkD:
	call ProbeAimedOrCrate
	ldh a, [hEntityResult]
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

ProbeAimedOrLedge:
	call ProbeAimedRetreat
	cp $ff
	ret z
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_6658
	ldh a, [hEntityProbeW]
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
	call GetCollisionCell
	pop bc
	or a
	jr nz, Func_03_6683
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeH]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
	or a
	ret nz
Func_03_6683:
	ld a, $03
	ldh [hEntityResult], a
	ret
ProbeAimedOrCrate:
	call ProbeAimedRetreat
	cp $ff
	ret z
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_66a4
	ldh a, [hEntityProbeW]
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
	call GetCollisionCell
	pop bc
	or a
	ret z
	cp $22
	ret z
	cp $23
	ret z
	ld a, $03
	ldh [hEntityResult], a
	ret
ProbeAimedRetreat:
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_66d6
	xor a
	ldh [$ffc3], a
	ld a, $ff
	ldh [hEntityResult], a
	ret
Func_03_66d6:
	call PlayerAheadAndFacingUs
	or a
	jr nz, Func_03_66ed
	ldh a, [$ffc3]
	or a
	jr z, Func_03_66e8
	dec a
	ldh [$ffc3], a
	xor a
	ldh [hEntityResult], a
	ret
Func_03_66e8:
	ld a, $02
	ldh [hEntityResult], a
	ret
Func_03_66ed:
	ld a, $3c
	ldh [$ffc3], a
	ld a, $01
	ldh [hEntityResult], a
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

Func_03_6704:
	push hl
	ld de, $0018
	add hl, de
	ld a, $0e
	ld [hl+], a
	ld a, $7b
	ld [hl], a
	pop hl

Func_03_6710:
	push hl
	ld de, $0016
	add hl, de
	xor a
	ld [hl], a
	pop hl
	ldh a, [hEntityFacing]
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
MonsterBreakTileUnder:
	push de
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	inc a
	add a, $08
	swap a
	and $0f
	ld b, a
	call BreakTileAtCell
	pop de
	ret
Suezo_Think4:
	call Suezo_ProbeChargeAlign
	ldh a, [hEntityResult]
	cp $ff
	jr z, Func_03_675f
	cp $01
	jr z, Func_03_6763
	cp $02
	jr z, Func_03_6767
	cp $03
	jr z, Func_03_676b
	ret

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

Suezo_Think5:
	call Suezo_ProbeChargeOrWall
	ldh a, [hEntityResult]
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

Func_03_6789:
	ld de, $7d06
	ret

Func_03_678d:
	ld de, $7ce0
	ret

Func_03_6791:
	ld de, $7cde
	ret

Func_03_6795:
	ld de, $7cbf
	ret

Func_03_6799:
	ld de, $7caf
	ret

Suezo_ProbeChargeOrWall:
	call Suezo_ProbeChargeAlign
	cp $ff
	ret z
	cp $02
	ret z
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_67bc
	ldh a, [hEntityProbeW]
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
	call GetCollisionCell
	pop bc
	or a
	jr nz, Func_03_67e0
	ldh a, [$ffc3]
	ld l, a
	ldh a, [$ffc4]
	or l
	ret z
	xor a
	ldh [hEntityResult], a
	ret
Func_03_67e0:
	cp $22
	jr z, Func_03_67e8
	cp $23
	jr nz, Func_03_67ed
Func_03_67e8:
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_67ed:
	ldh a, [hEntityResult]
	or a
	jr nz, Func_03_67f7
	ld a, $03
	ldh [hEntityResult], a
	ret

Func_03_67f7:
	ldh a, [$ffc3]
	ld l, a
	ldh a, [$ffc4]
	or l
	ret z
	ld a, $04
	ldh [hEntityResult], a
	ret

Suezo_ProbeChargeAlign:
	call DecGenTimer16
	call UpdateActionTimer
	bit 0, a
	jr z, Func_03_6812

Data_03_680d:
	ld a, $ff
	ldh [hEntityResult], a
	ret

Func_03_6812:
	xor a
	ldh [hEntityResult], a
	ret

Data_03_6816:
	db $cd, $e2, $46, $f0, $b7, $cb, $4f, $20, $08, $f0, $b6, $cb, $7f, $28, $0d, $18
	db $06, $f0, $b6, $cb, $7f, $20, $05, $3e, $02, $e0, $b8, $c9, $3e, $01, $e0, $b8
	db $c9

Golem_Think3:
	call MonsterProbeWalkAhead
	ldh a, [hEntityResult]
	cp $ff
	jr z, Func_03_6849
	cp $01
	jr z, Func_03_684d
	cp $02
	jr z, Func_03_6851
	ret

Func_03_6849:
	ld de, $7c80
	ret
Func_03_684d:
	ld de, $7c50
	ret
Func_03_6851:
	ld de, $7c67
	ret

Golem_Think5:
	call MonsterProbeWalkAhead
	ldh a, [hEntityResult]
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

Func_03_686f:
	ld de, $7c80
	ret
Func_03_6873:
	ld de, $7c50
	ret
Func_03_6877:
	ld de, $7c67
	ret

Func_03_687b:
	ld de, $7c31
	ret
Func_03_687f:
	ld de, $7c8e
	ret
Golem_ThinkB:
	call MonsterProbeWalkAhead
	ldh a, [hEntityResult]
	cp $ff
	jr z, Func_03_6899
	cp $01
	jr z, Func_03_689d
	cp $02
	jr z, Func_03_68a1
	cp $03
	jr z, Func_03_68a5
	ret

Func_03_6899:
	ld de, $7c80
	ret
Func_03_689d:
	ld de, $7c50
	ret
Func_03_68a1:
	ld de, $7c67
	ret

Func_03_68a5:
	ld de, $7c31
	ret
Hare_Think3:
	call MonsterProbeWalkAhead
	ldh a, [hEntityResult]
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

Func_03_68bf:
	ld de, $7b77
	ret
Func_03_68c3:
	ld de, $7b8e
	ret

Hare_Think5:
	call MonsterProbeWalkAhead
	ldh a, [hEntityResult]
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

Func_03_68e1:
	ld de, $7ba7
	ret

Func_03_68e5:
	ld de, $7b77
	ret

Func_03_68e9:
	ld de, $7b8e
	ret

Func_03_68ed:
	ld de, $7b58
	ret
Func_03_68f1:
	ld de, $7bb5
	ret
Hare_ThinkB:
	call MonsterProbeWalkAhead
	ldh a, [hEntityResult]
	cp $ff
	jr z, Func_03_690b
	cp $01
	jr z, Func_03_690f
	cp $02
	jr z, Func_03_6913
	cp $03
	jr z, Func_03_6917
	ret

Func_03_690b:
	ld de, $7ba7
	ret
Func_03_690f:
	ld de, $7b77
	ret
Func_03_6913:
	ld de, $7b8e
	ret

Func_03_6917:
	ld de, $7b58
	ret
	call Tacopi_ProbeFrontTile
	ret
	push de
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityY]
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
	ldh a, [hEntityProbeX]
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
	ldh a, [hEntityProbeW]
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
	ldh [hEntityVelYLo], a
	call Player_BeginAction
	ret
	xor a
	ldh [hEntityVelYLo], a
	call Player_BeginAction
	ret
	ldh a, [hEntityActionTimer]
	cp $3d
	jr z, Func_03_6983
	ld a, $11
	ldh [hEntityVelXLo], a
	ld a, $01
	ldh [hEntityVelXHi], a
	ret

Func_03_6983:
	ld a, $aa
	ldh [hEntityVelXLo], a
	ld a, $00
	ldh [hEntityVelXHi], a
	ret

Func_03_698c:
	ldh a, [hEntityActionTimer]
	cp $3d
	jr z, Func_03_699b
	ld a, $aa
	ldh [hEntityVelXLo], a
	ld a, $00
	ldh [hEntityVelXHi], a
	ret
Func_03_699b:
	ld a, $22
	ldh [hEntityVelXLo], a
	ld a, $00
	ldh [hEntityVelXHi], a
	ret
	ld a, [$cf79]
	or a
	jr z, Func_03_69b3
	xor a
	ld [$cf79], a
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_69b3:
	ldh a, [hEntityFacing]
	bit 3, a
	jr nz, Func_03_69be
Func_03_69b9:
	ld a, $ff
	ldh [hEntityResult], a
	ret
Func_03_69be:
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_69d4
	ldh a, [hEntityProbeW]
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
	call GetCollisionCell
	pop bc
	cp $20
	jr z, Func_03_6a11
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	ld b, a
	ldh a, [hEntityProbeH]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call GetCollisionCell
	or a
	jr z, Func_03_69b9
	cp $22
	jr z, Func_03_69b9
	cp $23
	jr z, Func_03_69b9
	xor a
	ldh [hEntityResult], a
	ret
Func_03_6a11:
	ldh a, [hEntityY]
	cp $87
	jr z, Func_03_6a1c

Data_03_6a17:
	ld a, $01
	ldh [hEntityResult], a
	ret

Func_03_6a1c:
	ld a, $02
	ldh [hEntityResult], a
	ret
	push de
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityY]
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
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityProbeW]
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
	ldh [hEntityResult], a
	ret
Func_03_6a89:
	ld a, $ff
	ldh [hEntityResult], a
	ret
	ld a, $b4
	ld [$c2e5], a
	push af
	ld a, SOUND_SFX_15
	call PlaySound
	pop af
	ret
	ld bc, $0000
	ld a, $2d
	call SpawnProjectileRel
	ld bc, $0000
	ld a, $2e
	call SpawnProjectileRel
	ld bc, $0000
	ld a, $2f
	call SpawnProjectileRel
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
	ldh [hEntityResult], a
	ret
Func_03_6ac9:
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_6ace:
	ld a, $ff
	ldh [hEntityResult], a
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
	ldh [hEntityResult], a
	ret
Func_03_6af4:
	xor a
	ldh [hEntityResult], a
	ret
Func_03_6af8:
	ld a, $ff
	ldh [hEntityResult], a
	ret
	ldh a, [hEntityX]
	cpl
	add a, $90
	ld c, a
	ldh a, [hEntityY]
	cpl
	add a, $10
	ld b, a
	ld a, $2c
	call SpawnProjectileRel
	ret
	ldh a, [hEntityX]
	cpl
	add a, $70
	ld c, a
	ldh a, [hEntityY]
	cpl
	add a, $10
	ld b, a
	ld a, $2c
	call SpawnProjectileRel
	ret
	ldh a, [hEntityX]
	cpl
	add a, $50
	ld c, a
	ldh a, [hEntityY]
	cpl
	add a, $10
	ld b, a
	ld a, $2c
	call SpawnProjectileRel
	ret
	ldh a, [hEntityX]
	cpl
	add a, $30
	ld c, a
	ldh a, [hEntityY]
	cpl
	add a, $10
	ld b, a
	ld a, $2c
	call SpawnProjectileRel
	ret
	ldh a, [hEntityX]
	cpl
	add a, $10
	ld c, a
	ldh a, [hEntityY]
	cpl
	add a, $10
	ld b, a
	ld a, $2c
	call SpawnProjectileRel
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
SpawnFx15_InitPos:
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
SpawnFx15_RiseToY48:
	ldh a, [hEntityY]
	inc a
	ldh [hEntityY], a
	cp $48
	jr nz, Func_03_6b89
	ld a, $48
	ldh [hEntityY], a
	ld a, $05
	ld [$c2dd], a
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_6b89:
	xor a
	ldh [hEntityResult], a
	ret
SpawnFx15_SetDoneFlag:
	ld a, $01
	ld [$cf79], a
	ret
	ld a, [$cf79]
	or a
	jr z, Func_03_6ba2
	xor a
	ld [$cf79], a
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_6ba2:
	xor a
	ldh [hEntityResult], a
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
	ldh [hEntityResult], a
	ret
Func_03_6bc8:
	ld a, [$c2e2]
	cp $02
	jr z, Func_03_6be4
	ld a, [$c2e4]
	cp $03
	jr nc, Func_03_6bdb
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_6bdb:
	ld a, $02
	ldh [hEntityResult], a
	ret

Func_03_6be0:
	xor a
	ldh [hEntityResult], a
	ret

Func_03_6be4:
	ld a, $ff
	ldh [hEntityResult], a
	ret
	xor a
	ld [$cf7a], a
	ld a, [wPlayerY]
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
	call PlaceBossEntryX
	ret
PlaceBossEntryX:
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
	call PlaceBossEntryY
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
	call PlaceBossEntryY
	ret
PlaceBossEntryY:
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
	call PlaceBossEntryX
	ret
	ld a, [wPlayerX]
	cp $80
	jr c, Func_03_6c83
	ld a, $02
	ld [$cf77], a
	ldh a, [hEntityFacing]
	and $fc
	or $01
	set 7, a
	ldh [hEntityFacing], a
	call PlaceBossEntryX
	ret
Func_03_6c83:
	ld a, $01
	ld [$cf77], a
	ldh a, [hEntityFacing]
	and $fc
	or $00
	res 7, a
	ldh [hEntityFacing], a
	call PlaceBossEntryX
	ret
	ld a, [$cf77]
	cp $01
	jr z, Func_03_6caf
	ldh a, [hEntityX]
	cp $19
	jr nc, Func_03_6cc1
	ld a, $18
	ldh [hEntityX], a
	xor a
	ldh [hEntityXSub], a
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_6caf:
	ldh a, [hEntityX]
	cp $e8
	jr c, Func_03_6cc1
	ld a, $e8
	ldh [hEntityX], a
	xor a
	ldh [hEntityXSub], a
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_6cc1:
	xor a
	ldh [hEntityResult], a
	ret
Func_03_6cc5:
	ld a, [wPlayerX]
	cp $80
	jr c, Func_03_6cd7
	ldh a, [hEntityFacing]
	and $fc
	or $00
	res 7, a
	ldh [hEntityFacing], a
	ret
Func_03_6cd7:
	ldh a, [hEntityFacing]
	and $fc
	or $01
	set 7, a
	ldh [hEntityFacing], a
	ret
	call Func_03_6cc5
	xor a
	ld [$cf7a], a
	ldh a, [hEntityX]
	ld [$cf8a], a
	ldh a, [hEntityY]
	ld [$cf8b], a
	ld a, [wPlayerY]
	sub $18
	ld [$cf8d], a
	ldh a, [hEntityFacing]
	bit 7, a
	jr nz, Func_03_6d0a
	ld a, [wPlayerX]
	sub $18
	ld [$cf8c], a
	ret
Func_03_6d0a:
	ld a, [wPlayerX]
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
	ldh a, [hEntityXSub]
	ld l, a
	ldh a, [hEntityX]
	ld h, a
	add hl, bc
	ld a, l
	ldh [hEntityXSub], a
	ld a, h
	ldh [hEntityX], a
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
	ldh a, [hEntityYSub]
	ld l, a
	ldh a, [hEntityY]
	ld h, a
	add hl, bc
	ld a, l
	ldh [hEntityYSub], a
	ld a, h
	ldh [hEntityY], a
	ld a, [$cf7a]
	inc a
	ld [$cf7a], a
	cp $20
	jr nz, Func_03_6d7b
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_6d7b:
	xor a
	ldh [hEntityResult], a
	ret
	push de
	ldh a, [hEntityY]
	ld d, a
	ldh a, [hEntityX]
	ld e, a
	ld bc, $0000
	ld a, $3d
	call SpawnEntity
	push hl
	ld de, $0011
	add hl, de
	ldh a, [hEntityX]
	ld [hl+], a
	ldh a, [hEntityY]
	ld [hl], a
	pop hl
	ldh a, [hEntityFacing]
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
Explosion_FrameA:
	ldh a, [hEntityVelYLo]
	ld c, a
	ldh a, [hEntityVelYHi]
	ld b, a
	ld a, b
	sub $18
	ldh [hEntityY], a
	xor a
	ldh [hEntityYSub], a
	ld a, c
	ldh [hEntityX], a
	ldh [hEntityXSub], a
	ret
Explosion_FrameB:
	ldh a, [hEntityVelYLo]
	ld c, a
	ldh a, [hEntityVelYHi]
	ld b, a
	ld a, b
	sub $08
	ldh [hEntityY], a
	xor a
	ldh [hEntityYSub], a
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_03_6ddb
	ld a, c
	sub $10
	ldh [hEntityX], a
	xor a
	ldh [hEntityXSub], a
	ret
Func_03_6ddb:
	ld a, c
	add a, $10
	ldh [hEntityX], a
	xor a
	ldh [hEntityXSub], a
	ret
Explosion_FrameC:
	ldh a, [hEntityVelYLo]
	ld c, a
	ldh a, [hEntityVelYHi]
	ld b, a
	ld a, b
	add a, $10
	ldh [hEntityY], a
	xor a
	ldh [hEntityYSub], a
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_03_6e01
	ld a, c
	sub $18
	ldh [hEntityX], a
	xor a
	ldh [hEntityXSub], a
	ret
Func_03_6e01:
	ld a, c
	add a, $18
	ldh [hEntityX], a
	xor a
	ldh [hEntityXSub], a
	ret
	xor a
	ld [$cf7b], a
	ld [$cf7a], a
	ret
ApplyKnockbackX:
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
	ldh a, [hEntityXSub]
	ld l, a
	ldh a, [hEntityX]
	ld h, a
	add hl, bc
	ld a, l
	ldh [hEntityXSub], a
	ld a, h
	ldh [hEntityX], a
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
	ldh a, [hEntityXSub]
	ld l, a
	ldh a, [hEntityX]
	ld h, a
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	ld a, l
	ldh [hEntityXSub], a
	ld a, h
	ldh [hEntityX], a
	ret
ApplyKnockbackY:
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
	ldh a, [hEntityYSub]
	ld l, a
	ldh a, [hEntityY]
	ld h, a
	add hl, bc
	ld a, l
	ldh [hEntityYSub], a
	ld a, h
	ldh [hEntityY], a
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
	ldh a, [hEntityYSub]
	ld l, a
	ldh a, [hEntityY]
	ld h, a
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	ld a, l
	ldh [hEntityYSub], a
	ld a, h
	ldh [hEntityY], a
	ret
	ld a, [$cf78]
	or a
	jr nz, Func_03_6ec4
	call ApplyKnockbackX
	call ApplyKnockbackY
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
	ldh [hEntityResult], a
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
	ldh [hEntityResult], a
	ret
Func_03_6ee6:
	ld a, $01
	ldh [hEntityResult], a
	push de
	FAR_CALL Func_01_4cae
	pop de
	ret

Data_03_6ef5:
	db $00, $01, $00, $00, $01, $00, $00, $00, $80, $01, $80, $01, $80, $01, $80, $01
	db $00, $00, $01, $00, $00, $01, $01, $00, $40, $01, $40, $01, $40, $01, $40, $01
	db $40, $01, $40, $01

Stairs_PollOpenDown:
	ld a, [$cf77]
	or a
	ret z
	ld de, $71f9
	ret
Stairs_PollOpenUp:
	ld a, [$cf78]
	or a
	ret z
	ld de, $7229
	ret
Stairs_FaceDown:
	ldh a, [hEntityFacing]
	and $fc
	or $02
	ldh [hEntityFacing], a
	xor a
	ldh [hEntityVelYLo], a
	ret
Stairs_FaceUp:
	ldh a, [hEntityFacing]
	and $fc
	or $03
	ldh [hEntityFacing], a
	xor a
	ldh [hEntityVelYLo], a
	ret
Stairs_AnimDescend:
	ldh a, [hEntityY]
	cp $80
	jr nc, Func_03_6f53
	call AdvanceArcPhase
	call Func_03_6f63
	xor a
	ldh [hEntityResult], a
	ret
Func_03_6f53:
	ld a, $80
	ldh [hEntityY], a
	xor a
	ldh [hEntityYSub], a
	ldh [hEntityVelXLo], a
	ldh [hEntityVelXHi], a
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_6f63:
	ldh a, [hEntityVelYLo]
	cp $41
	jr c, Func_03_6f89
	ldh a, [hEntityVelXHi]
	cp $02
	jr nc, Func_03_6f80
	ldh a, [hEntityVelXLo]
	ld l, a
	ldh a, [hEntityVelXHi]
	ld h, a
	ld bc, $0040
	add hl, bc
	ld a, l
	ldh [hEntityVelXLo], a
	ld a, h
	ldh [hEntityVelXHi], a
	ret
Func_03_6f80:
	ld a, $00
	ldh [hEntityVelXLo], a
	ld a, $02
	ldh [hEntityVelXHi], a
	ret
Func_03_6f89:
	ld a, $40
	ldh [hEntityVelXLo], a
	ld a, $00
	ldh [hEntityVelXHi], a
	ret
Stairs_AnimAscend:
	ldh a, [hEntityY]
	cp $11
	jr c, Func_03_6fa2
	call AdvanceArcPhase
	call Func_03_6fb2
	xor a
	ldh [hEntityResult], a
	ret
Func_03_6fa2:
	ld a, $10
	ldh [hEntityY], a
	xor a
	ldh [hEntityYSub], a
	ldh [hEntityVelXLo], a
	ldh [hEntityVelXHi], a
	ld a, $01
	ldh [hEntityResult], a
	ret
Func_03_6fb2:
	ld a, $80
	ldh [hEntityVelXLo], a
	ld a, $00
	ldh [hEntityVelXHi], a
	ret
AdvanceArcPhase:
	ldh a, [hEntityVelYLo]
	cp $41
	ret z
	inc a
	ldh [hEntityVelYLo], a
	ret
