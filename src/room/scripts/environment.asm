; World / object entity scripts (bank $03): stairs, doors, warps, sparkle,
; explosion, items, shards, the Zan exit flame, and the vestigial Spawn3F.
; See docs/entity_scripts.md.

SECTION "scripts_spawn3f", ROMX[$7092], BANK[$03]

Spawn3F_Sweep:
    ent_gfx $2a
    ent_call SpawnFx15_InitPos
.l7097
    ent_call SpawnFx15_RiseToY48
    ent_jr_b8_eq $01, Spawn3F_Sweep2
    ent_yield
    ent_jump .l7097

Spawn3F_Sweep2:
    ent_gfx $2b
    ent_set_timer $3c
    ent_wait_timer
    ent_call SpawnFx15_SetDoneFlag
    ent_set_timer $01
    ent_wait_timer
    ent_despawn

SECTION "scripts_environment", ROMX[$71d5], BANK[$03]

; Zan's exit flame (engine type $3e, MonsterSpawnScriptTable slot 18). Zan (boss
; index 5) is the only boss whose exit gets this animated flame; SpawnFloorFlameOrFX
; spawns it via Func_03_5518 when wActiveFloor == $05 (the boss-floor remap sets
; wActiveFloor to the boss index 1-5, NOT the displayed floor -- this is the Zan
; boss floor after floor 60, not floor 5). It drops to the boss kill cell
; ($c530/$c531) and stamps the exit tile; the other four bosses just get stairs.
ZanExitFlame_Drop:
    ent_vel_x_zero
    ent_gfx $29
    ent_set_timer $3c
    ent_wait_timer
.l71db
    ent_call SlideDownToY80
    ent_jr_b8_eq $01, ZanExitFlame_Land
    ent_yield
    ent_jump .l71db

ZanExitFlame_Land:
    ent_call_bank0 $01, DrawTileAtSpawnCoord
    ent_despawn

Stairs_AppearDown:
    ent_vel_x_zero
    ent_gfx $0e
    ent_call_bank0 $01, DrawStairTileClosedL
.l71f2
    ent_call Stairs_PollOpenDown
    ent_yield
    ent_jump .l71f2

Stairs_OpenDown:
    ent_vel_x_zero
    ent_gfx $0d
    ent_call Stairs_FaceUp
.l71ff
    ent_call Stairs_AnimDescend
    ent_jr_b8_eq $01, Stairs_OpenDownReturn
    ent_yield
    ent_jump .l71ff

Stairs_OpenDownReturn:
    ent_vel_x_zero
    ent_gfx $0e
    ent_call Stairs_FaceDown
.l7210
    ent_call Stairs_AnimAscend
    ent_jr_b8_eq $01, Stairs_AppearDown
    ent_yield
    ent_jump .l7210

Stairs_AppearUp:
    ent_vel_x_zero
    ent_gfx $0e
    ent_call_bank0 $01, DrawStairTileOpenR
.l7222
    ent_call Stairs_PollOpenUp
    ent_yield
    ent_jump .l7222

Stairs_OpenUp:
    ent_vel_x_zero
    ent_gfx $0d
    ent_call Stairs_FaceUp
.l722f
    ent_call Stairs_AnimDescend
    ent_jr_b8_eq $01, Stairs_OpenUpReturn
    ent_yield
    ent_jump .l722f

Stairs_OpenUpReturn:
    ent_vel_x_zero
    ent_gfx $0e
    ent_call Stairs_FaceDown
.l7240
    ent_call Stairs_AnimAscend
    ent_jr_b8_eq $01, Stairs_AppearUp
    ent_yield
    ent_jump .l7240

Warp_FlyRight:
    ent_set_facing $03
    ent_set_vel_x $0200
    ent_gfx $2e
.l7252
    ent_yield
    ent_jump .l7252

Warp_Land:
    ent_vel_x_zero
    ent_gfx $2f
    ent_set_timer $05
    ent_wait_timer
    ent_call_bank0 $01, ReadTileAtEntityCell
    ent_set_timer $05
    ent_wait_timer
    ent_despawn

Warp_FlyRightAlt:
    ent_set_facing $03
    ent_set_vel_x $0200
    ent_gfx $2c
.l726b
    ent_yield
    ent_jump .l726b

Warp_LandAlt:
    ent_vel_x_zero
    ent_gfx $2d
    ent_set_timer $05
    ent_wait_timer
    ent_call_bank0 $01, ReadTileAtEntityCell
    ent_set_timer $05
    ent_wait_timer
    ent_despawn

Door_OpenA:
    ent_vel_x_zero
    ent_gfx $38
.l7280
    ent_call Door_SlideInFast
    ent_yield
    ent_jump .l7280

Door_OpenB:
    ent_vel_x_zero
    ent_gfx $38
.l728a
    ent_call Door_SlideInMed
    ent_yield
    ent_jump .l728a

Door_OpenC:
    ent_vel_x_zero
    ent_gfx $38
.l7294
    ent_call Door_SlideInSlow
    ent_yield
    ent_jump .l7294

Sparkle_Idle:
    ent_vel_x_zero
    ent_gfx $22
.l729e
    ent_yield
    ent_jump .l729e

Sparkle_Ring:
    ent_call_bank0 $01, AnimSparkleRing
    ent_vel_x_zero
    ent_gfx $23
.l72a9
    ent_yield
    ent_jump .l72a9

Sparkle_Burst:
    ent_vel_x_zero
    ent_gfx $24
.l72b0
    ent_yield
    ent_jump .l72b0

Explosion_Anim:
    ent_vel_x_zero
    ent_gfx $28
    ent_call Explosion_FrameA
    ent_set_timer $02
    ent_wait_timer
    ent_call Explosion_FrameB
    ent_set_timer $02
    ent_wait_timer
    ent_call Explosion_FrameC
    ent_set_timer $02
    ent_wait_timer
    ent_call Explosion_FrameB
    ent_set_timer $02
    ent_wait_timer
    ent_call Explosion_FrameA
    ent_set_timer $02
    ent_wait_timer
    ent_despawn

SECTION "scripts_objects", ROMX[$74b5], BANK[$03]

Shard_Tumble:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $28
    ent_wait_timer
    ent_set_type $01
    ent_gfx $02

Shard_Home:
    ent_call FacePlayerX
    ent_jr_hit Shard_TumbleAlt
    ent_call $517e
    ent_set_timer $3c
    ent_wait_timer
    ent_call $5185
    ent_set_timer $1e
    ent_wait_timer
    ent_jump Shard_Home

Shard_TumbleAlt:
    ent_call Shard_HomeFaceRight
    ent_set_timer $3c
    ent_wait_timer
    ent_call Shard_HomeFaceLeft
    ent_set_timer $1e
    ent_wait_timer
    ent_jump Shard_Home

Generic_Despawn:
    ent_despawn

Item_Idle:
    ent_set_type $00
    ent_gfx $00
.l74ea
    ent_call DecYCounter
    ent_yield
    ent_jump .l74ea
