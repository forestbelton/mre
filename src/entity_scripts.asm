; Entity behaviour scripts (bank $03) -- the per-entity bytecode interpreted by
; RunEntityScript in src/room.asm. One line per VM instruction via the macros in
; include/entity_script.inc; see docs/entity_scripts.md.
;
; Names: the player avatar and the 13 editor-placeable monsters (Tacopi..Flame)
; are resolved; non-editor spawn types keep numbered/address names. The two
; sub-$71eb runs ($7092, $71d5) are spawn types 15 and 14 -- non-editor, the
; only scripts reached solely through MonsterSpawnScriptTable. Generated, then
; byte-exact-verified by make verify.

INCLUDE "entity_script.inc"

SECTION "entity_scripts_7092", ROMX[$7092], BANK[$03]

EScript_7092:
    ent_gfx $2a
    ent_call SpawnFx15_InitPos
.l7097
    ent_call SpawnFx15_RiseToY48
    ent_jr_b8_eq $01, EScript_70a2
    ent_yield
    ent_jump .l7097

EScript_70a2:
    ent_gfx $2b
    ent_set_timer $3c
    ent_wait_timer
    ent_call SpawnFx15_SetDoneFlag
    ent_set_timer $01
    ent_wait_timer
    ent_despawn

SECTION "entity_scripts_71d5", ROMX[$71d5], BANK[$03]

EScript_71d5:
    ent_vel_x_zero
    ent_gfx $29
    ent_set_timer $3c
    ent_wait_timer
.l71db
    ent_call SlideDownToY80
    ent_jr_b8_eq $01, EScript_71e6
    ent_yield
    ent_jump .l71db

EScript_71e6:
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
    ent_jr_b8_eq $01, EScript_720a
    ent_yield
    ent_jump .l71ff

EScript_720a:
    ent_vel_x_zero
    ent_gfx $0e
    ent_call Stairs_FaceDown
.l7210
    ent_call Stairs_AnimAscend
    ent_jr_b8_eq $01, Stairs_AppearDown
    ent_yield
    ent_jump .l7210

EScript_721b:
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
    ent_jr_b8_eq $01, EScript_723a
    ent_yield
    ent_jump .l722f

EScript_723a:
    ent_vel_x_zero
    ent_gfx $0e
    ent_call Stairs_FaceDown
.l7240
    ent_call Stairs_AnimAscend
    ent_jr_b8_eq $01, EScript_721b
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

Player_SpawnIntro:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_call Player_LatchActionPressed
    ent_yield

Player_StandDown:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
.l72e4
    ent_call Player_StandThinkDown
    ent_yield
    ent_jump .l72e4

Player_StandUp:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $02
.l72f0
    ent_call Player_StandThinkUp
    ent_yield
    ent_jump .l72f0

Player_WalkRight:
    ent_set_type $02
    ent_vel_x_indexed PlayerWalkVelR
    ent_gfx $03
.l72fe
    ent_call Player_WalkThinkRight
    ent_yield
    ent_jump .l72fe

Player_WalkLeft:
    ent_set_type $03
    ent_vel_x_indexed PlayerWalkVelL
    ent_gfx $04
.l730c
    ent_call Player_WalkThinkLeft
    ent_yield
    ent_jump .l730c

Player_PushDown:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $07
    ent_set_timer $0a
.l731a
    ent_call Player_LatchActionHeld
    ent_loop_timer .l731a
    ent_call Player_SpawnAttackFront
    ent_set_timer $0c
.l7325
    ent_call Player_LatchActionHeld
    ent_loop_timer .l7325
    ent_call Player_ClearMoveSub
    ent_jump Player_StandDown

Player_PushUp:
    ent_set_type $05
    ent_vel_x_zero
    ent_gfx $08
    ent_set_timer $0a
.l7338
    ent_call Player_LatchActionHeld
    ent_loop_timer .l7338
    ent_call Player_SpawnAttackFront
    ent_set_timer $0c
.l7343
    ent_call Player_LatchActionHeld
    ent_loop_timer .l7343
    ent_call Player_ClearMoveSub
    ent_jump Player_StandUp

Player_PushRight:
    ent_set_type $06
    ent_call EntSetAttackActive
    ent_gfx $07
    ent_set_timer $0a
    ent_wait_timer
    ent_call Player_SpawnAttackFront
    ent_set_timer $0c
    ent_wait_timer
    ent_call EntClearAttackActive
    ent_call Player_ClearMoveSub
    ent_load_b8 $ff8b
    ent_test_b8 $30
    ent_jr_free Player_CarryWalk
    ent_jump Player_CarryStand

Player_PullDown:
    ent_set_type $07
    ent_vel_x_zero
    ent_gfx $05
    ent_call Player_FireShot
    ent_set_timer $0e
.l737a
    ent_call Player_LatchActionHeld
    ent_loop_timer .l737a
    ent_call Player_ClearMoveSub
    ent_jump Player_StandDown

Player_PullUp:
    ent_set_type $08
    ent_vel_x_zero
    ent_gfx $06
    ent_call Player_FireShot
    ent_set_timer $0e
.l7390
    ent_call Player_LatchActionHeld
    ent_loop_timer .l7390
    ent_call Player_ClearMoveSub
    ent_jump Player_StandUp

Player_PullRight:
    ent_set_type $09
    ent_call EntSetAttackActive
    ent_gfx $05
    ent_call Player_FireShot
    ent_set_timer $0e
    ent_wait_timer
    ent_call EntClearAttackActive
    ent_call Player_ClearMoveSub
    ent_load_b8 $ff8b
    ent_test_b8 $30
    ent_jr_free Player_CarryWalk
    ent_jump Player_CarryStand

Player_GrabDown:
    ent_set_type $0a
    ent_vel_x_zero
    ent_gfx $05
    ent_set_timer $0e
.l73c1
    ent_call Player_LatchActionHeld
    ent_loop_timer .l73c1
    ent_call_bank0 $01, Player_SummonMonster
    ent_call Player_ClearMoveSub
    ent_jump Player_StandDown

Player_GrabUp:
    ent_set_type $0b
    ent_vel_x_zero
    ent_gfx $06
    ent_set_timer $0e
.l73d8
    ent_call Player_LatchActionHeld
    ent_loop_timer .l73d8
    ent_call_bank0 $01, Player_SummonMonster
    ent_call Player_ClearMoveSub
    ent_jump Player_StandUp

Player_GrabRight:
    ent_set_type $0c
    ent_call EntSetAttackActive
    ent_gfx $05
    ent_set_timer $0e
    ent_wait_timer
    ent_call EntClearAttackActive
    ent_call_bank0 $01, Player_SummonMonster
    ent_call Player_ClearMoveSub
    ent_load_b8 $ff8b
    ent_test_b8 $30
    ent_jr_free Player_CarryWalk
    ent_jump Player_CarryStand

Player_LiftCarry:
    ent_set_type $0d
    ent_vel_x_zero
    ent_gfx $09
    ent_call Player_ClearActionFlag
    ent_set_timer $07
.l7411
    ent_call Player_UpdateFacing
    ent_loop_timer .l7411
    ent_call Player_BeginAction
    ent_call Player_LiftThink
    ent_jump Player_CarryStand

Player_ThrowWindup:
    ent_set_type $0e
    ent_vel_x_zero
    ent_call Player_ClearActionFlag
    ent_begin_action
    ent_call Player_ThrowWindupThink

Player_CarryStand:
    ent_set_type $0f
    ent_vel_x_zero
    ent_gfx $0a

EScript_742f:
    ent_call Player_CarryStandThink
    ent_yield
    ent_jump EScript_742f

Player_CarryWalk:
    ent_set_type $10
    ent_vel_x_indexed PlayerCarryWalkVel
    ent_gfx $0b

EScript_743d:
    ent_call Player_CarryWalkThink
    ent_yield
    ent_jump EScript_743d

Player_ThrowRelease:
    ent_set_type $11
    ent_vel_x_zero
    ent_gfx $0c
    ent_call Player_UpdateFacing
    ent_yield
    ent_set_timer $04
.l744f
    ent_call Player_ThrowReleaseThink
    ent_loop_timer .l744f
    ent_call Player_PostThrowSelect

Player_KickRight:
    ent_set_type $12
    ent_call EntSetAttackActive
    ent_gfx $0a
    ent_set_timer $0a
.l7461
    ent_call Player_UpdateFacing
    ent_loop_timer .l7461
    ent_call EntClearAttackActive
    ent_jump EScript_742f

Player_KickCarry:
    ent_set_type $13
    ent_call EntSetAttackActive
    ent_gfx $0b
    ent_set_timer $0a
.l7476
    ent_call Player_UpdateFacing
    ent_loop_timer .l7476
    ent_call EntClearAttackActive
    ent_jump EScript_743d

PlayerHit_Slash:
    ent_set_type $14
    ent_vel_x_zero
    ent_gfx $10
    ent_set_timer $a8
.l7489
    ent_call PlayerHit_BeginStun
    ent_loop_timer .l7489
    ent_call RequestFloorExit
.l7492
    ent_yield
    ent_jump .l7492

PlayerHit_Charge:
    ent_set_type $15
    ent_vel_x_zero
    ent_call EntClearAttackActive
    ent_begin_action
    ent_gfx $11
.l749f
    ent_yield
    ent_update_action
    ent_jr_busy .l749f
    ent_gfx $12
    ent_set_timer $90
.l74a8
    ent_call PlayerHit_BeginStun
    ent_loop_timer .l74a8
    ent_call RequestFloorExit
.l74b1
    ent_yield
    ent_jump .l74b1

Shard_Tumble:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $28
    ent_wait_timer
    ent_set_type $01
    ent_gfx $02

EScript_74c1:
    ent_call FacePlayerX
    ent_jr_hit Shard_TumbleAlt
    ent_call $517e
    ent_set_timer $3c
    ent_wait_timer
    ent_call $5185
    ent_set_timer $1e
    ent_wait_timer
    ent_jump EScript_74c1

Shard_TumbleAlt:
    ent_call Shard_HomeFaceRight
    ent_set_timer $3c
    ent_wait_timer
    ent_call Shard_HomeFaceLeft
    ent_set_timer $1e
    ent_wait_timer
    ent_jump EScript_74c1

Generic_Despawn:
    ent_despawn

Item_Idle:
    ent_set_type $00
    ent_gfx $00
.l74ea
    ent_call DecYCounter
    ent_yield
    ent_jump .l74ea

Tacopi_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $02
    ent_set_timer $3c
.l74f8
    ent_update_action
    ent_jr_busy Tacopi_Hurt
    ent_loop_timer .l74f8
    ent_jump Tacopi_Chase

Tacopi_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $02
    ent_set_timer $3c
.l7509
    ent_update_action
    ent_jr_busy Tacopi_Hurt
    ent_loop_timer .l7509
    ent_set_xflip $ff

Tacopi_Chase:
    ent_set_type $02
    ent_vel_x_indexed MonsterWalkVel
    ent_set_facing $fe
    ent_gfx $02
.l751b
    ent_call Tacopi_Think
    ent_yield
    ent_jump .l751b

Tacopi_Windup:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $02
    ent_call MonsterBreakTileInFront
    ent_set_timer $1e
.l752c
    ent_update_action
    ent_jr_busy Tacopi_Hurt
    ent_loop_timer .l752c
    ent_set_xflip $ff
    ent_jump Tacopi_Chase

Tacopi_Hurt:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l753e
    ent_update_action
    ent_yield
    ent_jr_busy .l753e
    ent_jump Tacopi_Chase

Tacopi_Spawn:
    ent_set_type $05
    ent_vel_x_zero
    ent_gfx $00
    ent_spawn_rel $00, $f8, $09
    ent_call EntSetAttackActive
    ent_set_timer $0f
    ent_wait_timer
    ent_call EntClearAttackActive
    ent_gfx $04
    ent_begin_action
.l755b
    ent_update_action
    ent_yield
    ent_jr_busy .l755b
    ent_jump Tacopi_Chase

Tacopi_Die:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

Jell_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7573
    ent_call Jell_Think5
    ent_loop_timer .l7573
    ent_jump Jell_Chase

Jell_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7583
    ent_call Jell_Think3
    ent_loop_timer .l7583
    ent_set_xflip $ff

Jell_Chase:
    ent_set_type $02
    ent_vel_x_indexed MonsterWalkVel
    ent_set_facing $fe
    ent_gfx $02
.l7594
    ent_call Jell_Think5
    ent_yield
    ent_jump .l7594

Jell_AttackR:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l75a2
    ent_update_action
    ent_jr_busy Jell_Recover
    ent_loop_timer .l75a2
    ent_call MonsterBreakTileInFront
    ent_vel_x_indexed MonsterChargeVel
    ent_set_timer $0a
    ent_wait_timer
    ent_jump Jell_Chase

Jell_AttackL:
    ent_set_type $07
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l75bc
    ent_update_action
    ent_jr_busy Jell_Recover
    ent_loop_timer .l75bc
    ent_call MonsterBreakTileInFront
    ent_vel_x_indexed MonsterChargeVel
    ent_set_timer $0a
    ent_wait_timer
    ent_set_xflip $ff
    ent_jump Jell_Chase

Jell_Recover:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l75d7
    ent_update_action
    ent_yield
    ent_jr_busy .l75d7
    ent_jump Jell_Die

Jell_Spawn:
    ent_set_type $05
    ent_vel_x_zero
    ent_gfx $00
    ent_spawn_rel $00, $f8, $09
    ent_call EntSetAttackActive
    ent_set_timer $0f
    ent_wait_timer
    ent_call EntClearAttackActive
    ent_gfx $04
    ent_begin_action
.l75f4
    ent_update_action
    ent_yield
    ent_jr_busy .l75f4
    ent_jump Jell_Chase

Jell_Charge:
    ent_set_type $06
    ent_vel_x_indexed MonsterChargeVel
    ent_set_facing $fe
    ent_gfx $02
.l7605
    ent_call Jell_Think4
    ent_yield
    ent_jump .l7605

Jell_Die:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

Naga_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l761c
    ent_call Naga_Think4
    ent_loop_timer .l761c
    ent_jump Naga_Chase

Naga_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l762c
    ent_call Naga_Think4
    ent_loop_timer .l762c
    ent_set_xflip $ff

Naga_Chase:
    ent_set_type $02
    ent_vel_x_indexed MonsterWalkVel
    ent_set_facing $fe
    ent_gfx $02
.l763d
    ent_call Naga_Think5
    ent_yield
    ent_jump .l763d

Naga_Windup:
    ent_set_xflip $ff

EScript_7646:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l764d
    ent_update_action
    ent_jr_busy Naga_Hurt
    ent_loop_timer .l764d
    ent_call SpawnProjectile24
    ent_set_timer $09
    ent_wait_timer
    ent_call MonsterBreakTileInFront
    ent_call SetTimer120
    ent_jump Naga_Chase

Naga_Hurt:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l7669
    ent_update_action
    ent_yield
    ent_jr_busy .l7669
    ent_jump Naga_FaceFlip

Naga_Spawn:
    ent_set_type $05
    ent_vel_x_zero
    ent_gfx $00
    ent_spawn_rel $00, $f8, $09
    ent_call EntSetAttackActive
    ent_set_timer $0f
    ent_wait_timer
    ent_call EntClearAttackActive
    ent_gfx $04
    ent_begin_action
.l7686
    ent_update_action
    ent_yield
    ent_jr_busy .l7686

Naga_FaceFlip:
    ent_call FacePlayerX
    ent_jr_hit EScript_7698
    ent_set_facing $00
    ent_set_xflip $00
    ent_jump Naga_Chase

EScript_7698:
    ent_set_facing $01
    ent_set_xflip $01
    ent_jump Naga_Chase

Naga_Die:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

Dino_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l76af
    ent_call Dino_Think4
    ent_loop_timer .l76af
    ent_jump Dino_Chase

Dino_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l76bf
    ent_call Dino_Think4
    ent_loop_timer .l76bf
    ent_set_xflip $ff

Dino_Chase:
    ent_set_type $02
    ent_vel_x_indexed MonsterWalkVel
    ent_set_facing $fe
    ent_gfx $02
.l76d0
    ent_call Dino_Think5
    ent_yield
    ent_jump .l76d0

Dino_Windup:
    ent_set_xflip $ff

EScript_76d9:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l76e0
    ent_update_action
    ent_jr_busy Dino_Hurt
    ent_loop_timer .l76e0
    ent_call SpawnProjectile20
    ent_call MonsterBreakTileInFront
    ent_set_timer $28
    ent_wait_timer
    ent_set_timer $05
.l76f2
    ent_update_action
    ent_jr_busy Dino_Hurt
    ent_loop_timer .l76f2
    ent_call SetTimer120
    ent_jump Dino_Chase

Dino_Hurt:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l7705
    ent_update_action
    ent_yield
    ent_jr_busy .l7705
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

Plant_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c

EScript_771a:
    ent_call Plant_Think
    ent_loop_timer EScript_771a
    ent_jump Plant_Chase

EScript_7723:
    ent_yield
    ent_jump EScript_771a

Plant_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l772e
    ent_call Plant_ThinkB
    ent_loop_timer .l772e
    ent_set_xflip $ff

Plant_Chase:
    ent_set_type $02
    ent_vel_x_indexed MonsterWalkVel
    ent_set_facing $fe
    ent_gfx $02
.l773f
    ent_call Plant_ThinkC
    ent_yield
    ent_jump .l773f

Plant_Windup:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $3c
.l774d
    ent_update_action
    ent_jr_busy Plant_Hurt
    ent_loop_timer .l774d
    ent_call Plant_FireMissile
    ent_set_timer $05
.l7759
    ent_update_action
    ent_jr_busy Plant_Hurt
    ent_loop_timer .l7759
    ent_jump Plant_Chase

Plant_Hurt:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l7769
    ent_update_action
    ent_yield
    ent_jr_busy .l7769
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

Henger_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
    ent_wait_timer
    ent_jump Henger_Chase

Henger_Windup:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $03
    ent_call Henger_FireShot
    ent_set_timer $21
    ent_wait_timer
    ent_call MonsterBreakTileInFront
    ent_set_timer $09
    ent_wait_timer

EScript_7793:
    ent_set_xflip $ff

Henger_Chase:
    ent_set_type $02
    ent_vel_x_indexed MonsterWalkVel
    ent_set_facing $fe
    ent_gfx $02
.l779e
    ent_call Henger_Think
    ent_yield
    ent_jump .l779e

Henger_Die:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l77ab
    ent_update_action
    ent_yield
    ent_jr_busy .l77ab
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

Joker_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
    ent_wait_timer
    ent_jump Joker_Chase

Joker_Windup:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $03
    ent_wait_timer
    ent_call Joker_FireShot
    ent_set_timer $09
    ent_wait_timer
    ent_call MonsterBreakTileInFront
    ent_set_xflip $ff

Joker_Chase:
    ent_set_type $02
    ent_vel_x_indexed MonsterWalkVel
    ent_set_facing $fe
    ent_gfx $02
.l77de
    ent_call Joker_Think
    ent_yield
    ent_jump .l77de

Joker_Die:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l77eb
    ent_update_action
    ent_yield
    ent_jr_busy .l77eb
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

Ghost_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l77fe
    ent_call Ghost_ThinkB
    ent_loop_timer .l77fe
    ent_jump Ghost_Chase

Ghost_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l780e
    ent_call Ghost_ThinkB
    ent_loop_timer .l780e
    ent_set_xflip $ff

Ghost_Chase:
    ent_set_type $02
    ent_vel_x_indexed MonsterWalkVel
    ent_gfx $02
.l781d
    ent_call Ghost_Think
    ent_yield
    ent_jump .l781d

Ghost_AttackA:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $09
    ent_wait_timer
    ent_call $4487
    ent_set_timer $03
    ent_wait_timer
    ent_set_facing $ff
    ent_jump Ghost_Chase

Ghost_AttackB:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $05
    ent_set_timer $09
    ent_wait_timer
    ent_call $44a1
    ent_set_timer $03
    ent_wait_timer
    ent_set_facing $ff
    ent_jump Ghost_Chase

Ghost_Die:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l7850
    ent_update_action
    ent_yield
    ent_jr_busy .l7850
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

Puncho_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7863
    ent_call Puncho_Think
    ent_loop_timer .l7863
    ent_jump Puncho_Chase

Puncho_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7873
    ent_call Puncho_Think
    ent_loop_timer .l7873
    ent_set_xflip $ff

Puncho_Chase:
    ent_set_type $02
    ent_vel_x_indexed MonsterWalkVel
    ent_set_facing $fe
    ent_gfx $02
.l7884
    ent_call Puncho_ThinkB
    ent_yield
    ent_jump .l7884

Puncho_Attack:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
.l7890
    ent_call Puncho_ThinkC
    ent_yield
    ent_jump .l7890

Puncho_Hurt:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l789d
    ent_update_action
    ent_yield
    ent_jr_busy .l789d
    ent_jump Puncho_StandR

Puncho_Charge:
    ent_set_type $05
    ent_vel_x_indexed MonsterChargeVel
    ent_set_facing $fe
    ent_gfx $05
.l78ae
    ent_call Puncho_ThinkD
    ent_yield
    ent_jump .l78ae

EScript_78b5:
    ent_set_xflip $ff
    ent_jump Puncho_Charge

Puncho_Special:
    ent_set_type $06
    ent_vel_x_zero
    ent_gfx $05
    ent_begin_action
.l78c0
    ent_update_action
    ent_yield
    ent_jr_busy .l78c0
    ent_call MonsterBreakTileUnder
    ent_begin_action
.l78c9
    ent_update_action
    ent_yield
    ent_jr_busy .l78c9
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

Psylora_WalkDownA:
    ent_set_type $01
    ent_vel_x_indexed PsyloraWalkVel
    ent_call Psylora_SelectMoveScript

EScript_78df:
    ent_set_facing $00
    ent_gfx $11
.l78e3
    ent_call Psylora_MoveDirA
    ent_yield
    ent_jump .l78e3

Psylora_WalkDownB:
    ent_set_facing $01
    ent_gfx $12
.l78ee
    ent_call Psylora_MoveDirB
    ent_yield
    ent_jump .l78ee

Psylora_WalkUpA:
    ent_set_facing $00
    ent_gfx $13
.l78f9
    ent_call Psylora_MoveDirA
    ent_yield
    ent_jump .l78f9

Psylora_WalkUpB:
    ent_set_facing $01
    ent_gfx $14
.l7904
    ent_call Psylora_MoveDirB
    ent_yield
    ent_jump .l7904

Psylora_WalkRightA:
    ent_set_facing $02
    ent_gfx $15
.l790f
    ent_call Psylora_MoveDirC
    ent_yield
    ent_jump .l790f

Psylora_WalkLeftA:
    ent_set_facing $03
    ent_gfx $16
.l791a
    ent_call Psylora_MoveDirD
    ent_yield
    ent_jump .l791a

Psylora_WalkRightB:
    ent_set_facing $02
    ent_gfx $17
.l7925
    ent_call Psylora_MoveDirC
    ent_yield
    ent_jump .l7925

Psylora_WalkLeftB:
    ent_set_facing $03
    ent_gfx $18
.l7930
    ent_call Psylora_MoveDirD
    ent_yield
    ent_jump .l7930

FX_Despawn_Gfx1:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

FX_Despawn_Gfx2:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $02
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

FX_Despawn_Gfx3:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

FX_Despawn_Gfx4:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $04
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

FX_Despawn_Gfx5:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $05
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

FX_Despawn_Gfx6:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $06
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

FX_Despawn_Gfx7:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $07
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

FX_Despawn_Gfx8:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $08
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

Ducken_Init:
    ent_call Ducken_AimVertical

Ducken_AimR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_call SetProjectileSpeed
.l798a
    ent_call Ducken_FireTimerProbe
    ent_jr_b8_eq $01, Ducken_FireR
    ent_yield
    ent_jump .l798a

Ducken_AimL:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $02
    ent_call SetProjectileSpeed
.l799d
    ent_call Ducken_FireTimerProbe
    ent_jr_b8_eq $01, Ducken_FireL
    ent_yield
    ent_jump .l799d

Ducken_FireR:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
    ent_wait_timer
    ent_call Ducken_FireMissileA
    ent_set_timer $03
    ent_wait_timer
    ent_jump Ducken_AimR

Ducken_FireL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $04
    ent_set_timer $1e
    ent_wait_timer
    ent_call Ducken_FireMissileB
    ent_set_timer $03
    ent_wait_timer
    ent_jump Ducken_AimL

Ducken_Die:
    ent_call Ducken_AimHorizontal

EScript_79cd:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $08
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

Ducken_DieAlt:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

FlameRed_Hidden:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
.l79e4
    ent_update_action
    ent_jr_busy FlameRed_Emerge
    ent_yield
    ent_jump .l79e4

FlameRed_Surface:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $02
    ent_set_timer $f0
.l79f3
    ent_update_action
    ent_jr_busy EScript_7a0b
    ent_loop_timer .l79f3
    ent_jump FlameRed_Hidden

FlameRed_Emerge:
    ent_set_type $02
    ent_vel_x_zero
    ent_gfx $01
    ent_begin_action
.l7a03
    ent_update_action
    ent_yield
    ent_jr_busy .l7a03
    ent_jump FlameRed_Die

EScript_7a0b:
    ent_set_type $02
    ent_vel_x_zero
    ent_gfx $02
    ent_begin_action
.l7a11
    ent_update_action
    ent_yield
    ent_jr_busy .l7a11

FlameRed_Die:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $3c
    ent_wait_timer
    ent_despawn

FlameBlue_Hidden:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
.l7a24
    ent_update_action
    ent_jr_busy EScript_7a3d
    ent_yield
    ent_jump .l7a24

EScript_7a2c:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $02
    ent_set_timer $f0
.l7a33
    ent_update_action
    ent_jr_busy EScript_7a4b
    ent_loop_timer .l7a33
    ent_jump FlameBlue_Hidden

EScript_7a3d:
    ent_set_type $02
    ent_vel_x_zero
    ent_gfx $01
    ent_begin_action
.l7a43
    ent_update_action
    ent_yield
    ent_jr_busy .l7a43
    ent_jump FlameBlue_Hidden

EScript_7a4b:
    ent_set_type $02
    ent_vel_x_zero
    ent_gfx $02
    ent_begin_action
.l7a51
    ent_update_action
    ent_yield
    ent_jr_busy .l7a51
    ent_jump FlameBlue_Hidden

Tiger_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c

EScript_7a60:
    ent_call $64dd
    ent_loop_timer EScript_7a60
    ent_jump Tiger_Chase

EScript_7a69:
    ent_yield
    ent_jump EScript_7a60

Tiger_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7a74
    ent_call Tiger_Think
    ent_loop_timer .l7a74
    ent_set_xflip $ff

Tiger_Chase:
    ent_set_type $02
    ent_vel_x_indexed MonsterWalkVel
    ent_set_facing $fe
    ent_gfx $02
.l7a85
    ent_call Tiger_ThinkProbe
    ent_yield
    ent_jump .l7a85

Tiger_Windup:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l7a93
    ent_update_action
    ent_jr_busy Tiger_Hurt
    ent_loop_timer .l7a93
    ent_call Tiger_FireMissile
    ent_set_timer $05
.l7a9f
    ent_update_action
    ent_jr_busy Tiger_Hurt
    ent_loop_timer .l7a9f
    ent_jump Tiger_Chase

Tiger_Hurt:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l7aaf
    ent_update_action
    ent_yield
    ent_jr_busy .l7aaf
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $f0
.l7abb
    ent_update_action
    ent_jr_busy Tiger_Hurt
    ent_loop_timer .l7abb
    ent_jump Tiger_StandR

Mocchi_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7acc
    ent_call Mocchi_Think
    ent_loop_timer .l7acc
    ent_jump Mocchi_Chase

Mocchi_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7adc
    ent_call Mocchi_Think
    ent_loop_timer .l7adc
    ent_set_xflip $ff

Mocchi_Chase:
    ent_set_type $02
    ent_vel_x_indexed MonsterWalkVel
    ent_set_facing $fe
    ent_gfx $02
.l7aed
    ent_call Mocchi_ThinkB
    ent_yield
    ent_jump .l7aed

Mocchi_Attack:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
.l7af9
    ent_call Mocchi_ThinkC
    ent_yield
    ent_jump .l7af9

Mocchi_Hurt:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l7b06
    ent_update_action
    ent_yield
    ent_jr_busy .l7b06
    ent_jump Mocchi_StandR

Mocchi_Charge:
    ent_set_type $05
    ent_vel_x_indexed MonsterChargeVel
    ent_set_facing $fe
    ent_gfx $05
.l7b17
    ent_call Mocchi_ThinkD
    ent_yield
    ent_jump .l7b17

EScript_7b1e:
    ent_set_xflip $ff
    ent_jump Mocchi_Charge

Mocchi_Special:
    ent_set_type $06
    ent_vel_x_zero
    ent_gfx $05
    ent_begin_action
.l7b29
    ent_update_action
    ent_yield
    ent_jr_busy .l7b29
    ent_call MonsterBreakTileUnder
    ent_begin_action
.l7b32
    ent_update_action
    ent_yield
    ent_jr_busy .l7b32
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $f0
.l7b3e
    ent_update_action
    ent_jr_busy Mocchi_Hurt
    ent_loop_timer .l7b3e
    ent_jump Mocchi_StandR

Hare_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7b4f
    ent_call Hare_Think5
    ent_loop_timer .l7b4f
    ent_jump Hare_Chase

Hare_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7b5f
    ent_call Hare_Think3
    ent_loop_timer .l7b5f
    ent_set_xflip $ff

Hare_Chase:
    ent_set_type $02
    ent_vel_x_indexed MonsterWalkVel
    ent_set_facing $fe
    ent_gfx $02
.l7b70
    ent_call Hare_Think5
    ent_yield
    ent_jump .l7b70

Hare_WindupR:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l7b7e
    ent_update_action
    ent_jr_busy Hare_Hurt
    ent_loop_timer .l7b7e
    ent_call MonsterBreakTileInFront
    ent_set_timer $05
    ent_wait_timer
    ent_jump Hare_Chase

Hare_WindupL:
    ent_set_type $07
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l7b95
    ent_update_action
    ent_jr_busy Hare_Hurt
    ent_loop_timer .l7b95
    ent_call MonsterBreakTileInFront
    ent_set_timer $05
    ent_wait_timer
    ent_set_xflip $ff
    ent_jump Hare_Chase

Hare_Hurt:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l7bad
    ent_update_action
    ent_yield
    ent_jr_busy .l7bad
    ent_jump EScript_7bc5

Hare_Charge:
    ent_set_type $06
    ent_vel_x_indexed MonsterChargeVel
    ent_set_facing $fe
    ent_gfx $02
.l7bbe
    ent_call Hare_ThinkB
    ent_yield
    ent_jump .l7bbe

EScript_7bc5:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $f0
.l7bcc
    ent_update_action
    ent_jr_busy Hare_Hurt
    ent_loop_timer .l7bcc
    ent_jump Hare_StandR

Gali_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
    ent_wait_timer
    ent_jump Gali_Chase

Gali_Windup:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $03
    ent_call Gali_FireShot
    ent_set_timer $09
    ent_wait_timer
    ent_call MonsterBreakTileInFront
    ent_set_timer $0f
    ent_wait_timer
    ent_set_xflip $ff

Gali_Chase:
    ent_set_type $02
    ent_vel_x_indexed MonsterWalkVel
    ent_set_facing $fe
    ent_gfx $02
.l7bfd
    ent_call ProbeFrontTile
    ent_jr_b8_eq $03, Gali_Windup
    ent_yield
    ent_jump .l7bfd

Gali_Die:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l7c0e
    ent_update_action
    ent_yield
    ent_jr_busy .l7c0e
    ent_gfx $09
    ent_set_timer $f0
.l7c17
    ent_update_action
    ent_jr_busy Gali_Die
    ent_loop_timer .l7c17
    ent_jump Gali_StandR

Golem_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7c28
    ent_call Golem_Think5
    ent_loop_timer .l7c28
    ent_jump Golem_Chase

Golem_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7c38
    ent_call Golem_Think3
    ent_loop_timer .l7c38
    ent_set_xflip $ff

Golem_Chase:
    ent_set_type $02
    ent_vel_x_indexed GolemWalkVel
    ent_set_facing $fe
    ent_gfx $02
.l7c49
    ent_call Golem_Think5
    ent_yield
    ent_jump .l7c49

Golem_WindupR:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l7c57
    ent_update_action
    ent_jr_busy Golem_Hurt
    ent_loop_timer .l7c57
    ent_call MonsterBreakTileInFront
    ent_set_timer $08
    ent_wait_timer
    ent_jump Golem_Chase

Golem_WindupL:
    ent_set_type $07
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l7c6e
    ent_update_action
    ent_jr_busy Golem_Hurt
    ent_loop_timer .l7c6e
    ent_call MonsterBreakTileInFront
    ent_set_timer $08
    ent_wait_timer
    ent_set_xflip $ff
    ent_jump Golem_Chase

Golem_Hurt:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l7c86
    ent_update_action
    ent_yield
    ent_jr_busy .l7c86
    ent_jump EScript_7c9e

Golem_Charge:
    ent_set_type $06
    ent_vel_x_indexed GolemChargeVel
    ent_set_facing $fe
    ent_gfx $02
.l7c97
    ent_call Golem_ThinkB
    ent_yield
    ent_jump .l7c97

EScript_7c9e:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $f0
.l7ca5
    ent_update_action
    ent_jr_busy Golem_Hurt
    ent_loop_timer .l7ca5
    ent_jump Golem_StandR

Suezo_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7cb6
    ent_call Suezo_Think4
    ent_loop_timer .l7cb6
    ent_jump Suezo_Chase

Suezo_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7cc6
    ent_call Suezo_Think4
    ent_loop_timer .l7cc6
    ent_set_xflip $ff

Suezo_Chase:
    ent_set_type $02
    ent_vel_x_indexed MonsterWalkVel
    ent_set_facing $fe
    ent_gfx $02
.l7cd7
    ent_call Suezo_Think5
    ent_yield
    ent_jump .l7cd7

Suezo_Windup:
    ent_set_xflip $ff

EScript_7ce0:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l7ce7
    ent_update_action
    ent_jr_busy Suezo_HurtFlip
    ent_loop_timer .l7ce7
    ent_call SpawnProjectile21
    ent_call MonsterBreakTileInFront
    ent_set_timer $28
    ent_wait_timer
    ent_set_timer $05
.l7cf9
    ent_update_action
    ent_jr_busy Suezo_HurtFlip
    ent_loop_timer .l7cf9
    ent_call SetTimer120
    ent_jump Suezo_Chase

Suezo_HurtFlip:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $01
    ent_begin_action
.l7d0c
    ent_update_action
    ent_yield
    ent_jr_busy .l7d0c
    ent_call FacePlayerX
    ent_jr_hit EScript_7d1e
    ent_set_facing $00
    ent_set_xflip $00
    ent_jump Suezo_Chase

EScript_7d1e:
    ent_set_facing $01
    ent_set_xflip $01
    ent_jump Suezo_Chase

; --- recovered after the initial carve: more scripts at $7d25-$7fec that
;     branch back into Suezo's hurt handler ($7d06/$7d11, kept as raw addrs).
;     Live (entered via a bank-3 table at $5751.. still mis-disassembled);
;     generic EScript_ labels pending a species/role pass.

EScript_7d25:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $f0
.l7d2c
    ent_update_action
    ent_jr_busy $7d06
    ent_loop_timer .l7d2c
    ent_jump $7d11

EScript_7d36:
    ent_set_xflip $01

EScript_7d38:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7d3f
    ent_update_action
    ent_jr_busy EScript_7d93
    ent_loop_timer .l7d3f
    ent_jump EScript_7d67

EScript_7d49:
    ent_set_xflip $ff

EScript_7d4b:
    ent_set_facing $fe
    ent_set_type $01
    ent_vel_x_indexed $7028
    ent_gfx $02
    ent_set_timer $5a
.l7d56
    ent_call $691b
    ent_jr_b8_eq $ff, EScript_7d93
    ent_jr_b8_eq $03, EScript_7d49
    ent_loop_timer .l7d56
    ent_jump EScript_7d38

EScript_7d67:
    ent_set_type $02
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $14
.l7d6e
    ent_update_action
    ent_jr_busy EScript_7d93
    ent_loop_timer .l7d6e
    ent_call $549a
    ent_set_timer $0a
.l7d7a
    ent_update_action
    ent_jr_busy EScript_7d93
    ent_loop_timer .l7d7a
    ent_call $54ae
    ent_set_timer $0a
.l7d86
    ent_update_action
    ent_jr_busy EScript_7d93
    ent_loop_timer .l7d86
    ent_call $54b8
    ent_jump EScript_7d4b

EScript_7d93:
    ent_call $4622
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_set_timer $54
    ent_wait_timer
    ent_begin_action
.l7d9f
    ent_call $691f
    ent_update_action
    ent_yield
    ent_jr_busy .l7d9f
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $3c
    ent_wait_timer
    ent_call $5539
    ent_despawn

EScript_7db3:
    ent_call $6960
    ent_jump EScript_7dbb

EScript_7db9:
    ent_set_xflip $ff

EScript_7dbb:
    ent_set_facing $fe
    ent_set_type $01
    ent_vel_x_indexed $7032
    ent_gfx $02
.l7dc4
    ent_call $69a4
    ent_jr_b8_eq $ff, EScript_7df9
    ent_jr_b8_eq $01, EScript_7db9
    ent_jr_b8_eq $02, EScript_7dd7
    ent_yield
    ent_jump .l7dc4

EScript_7dd7:
    ent_set_xflip $ff
    ent_set_facing $fe
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $14
    ent_wait_timer
    ent_call $6965
.l7de6
    ent_call $6974
    ent_call $4440
    ent_yield
    ent_jr_busy .l7de6
    ent_vel_x_zero
    ent_gfx $04
    ent_set_timer $28
    ent_wait_timer
    ent_jump EScript_7dbb

EScript_7df9:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $05
    ent_set_timer $28
    ent_wait_timer
    ent_call $696d
.l7e04
    ent_call $698c
    ent_call $4440
    ent_yield
    ent_jr_busy .l7e04
    ent_vel_x_zero
    ent_gfx $06
    ent_set_timer $14
    ent_wait_timer
    ent_jump EScript_7db9

EScript_7e17:
    ent_call $4622
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $3c
    ent_wait_timer
    ent_call $5539
    ent_despawn

EScript_7e26:
    ent_set_xflip $ff
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $b4
.l7e2f
    ent_call $6a7e
    ent_jr_b8_eq $ff, EScript_7e53
    ent_loop_timer .l7e2f
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $28
    ent_wait_timer
    ent_call $54cc
    ent_set_timer $0a
    ent_wait_timer
    ent_call $54e0
    ent_set_timer $0a
    ent_wait_timer
    ent_call $54f4
    ent_jump EScript_7e26

EScript_7e53:
    ent_call $4622
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_set_timer $28
    ent_wait_timer
    ent_begin_action
.l7e5f
    ent_call $6a21
    ent_update_action
    ent_yield
    ent_jr_busy .l7e5f
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $3c
    ent_wait_timer
    ent_call $5539
    ent_despawn

EScript_7e73:
    ent_call $6ab4
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
.l7e7b
    ent_call $6ab9
    ent_jr_b8_eq $ff, EScript_7eef
    ent_jr_b8_eq $01, EScript_7e8a
    ent_yield
    ent_jump .l7e7b

EScript_7e8a:
    ent_set_type $02
    ent_vel_x_zero
    ent_gfx $06
    ent_set_timer $58
    ent_wait_timer
    ent_set_timer $14
    ent_wait_timer
    ent_call $6a9b
    ent_set_timer $14
    ent_wait_timer
    ent_jump EScript_7e73

EScript_7e9e:
    ent_call $6ad3
    ent_set_type $11
    ent_vel_x_zero
    ent_gfx $02
.l7ea6
    ent_call $6adc
    ent_jr_b8_eq $ff, EScript_7f04
    ent_jr_b8_eq $01, EScript_7eb5
    ent_yield
    ent_jump .l7ea6

EScript_7eb5:
    ent_set_type $12
    ent_gfx $07
    ent_set_facing $02
    ent_set_vel_x $0040
    ent_set_timer $20
    ent_wait_timer
    ent_vel_x_zero
    ent_set_timer $78
    ent_wait_timer
    ent_set_facing $03
    ent_set_vel_x $0100
    ent_set_timer $08
    ent_wait_timer
    ent_vel_x_zero
    ent_call $6a8e
    ent_call $6afd
    ent_set_timer $0a
    ent_wait_timer
    ent_call $6b0f
    ent_set_timer $0f
    ent_wait_timer
    ent_call $6b21
    ent_set_timer $14
    ent_wait_timer
    ent_call $6b33
    ent_set_timer $19
    ent_wait_timer
    ent_call $6b45
    ent_jump EScript_7e9e

EScript_7eef:
    ent_call $4622
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $3c
    ent_wait_timer
    ent_gfx $05
    ent_call_bank0 $04, $420a
    ent_call $556e
    ent_despawn

EScript_7f04:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $04
    ent_set_timer $3c
    ent_wait_timer
    ent_gfx $05
    ent_despawn

EScript_7f0f:
    ent_call $6b57
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $00
.l7f17
    ent_call $6b93
    ent_jr_b8_eq $01, EScript_7f22
    ent_yield
    ent_jump .l7f17

EScript_7f22:
    ent_call $6ba6
    ent_set_type $02
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $b4
    ent_wait_timer
.l7f2d
    ent_call $6bb4
    ent_jr_b8_eq $ff, EScript_7fb6
    ent_jr_b8_eq $01, EScript_7f40
    ent_jr_b8_eq $02, EScript_7f81
    ent_yield
    ent_jump .l7f2d

EScript_7f40:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $02
    ent_set_timer $1e
    ent_wait_timer
    ent_call $6be9
    ent_gfx $0a
    ent_set_timer $78
.l7f4f
    ent_call $6c4f
    ent_loop_timer .l7f4f
    ent_call $6c69
    ent_gfx $04
    ent_set_timer $1e
    ent_wait_timer
    ent_vel_x_indexed $703c
.l7f60
    ent_call $6c96
    ent_jr_b8_eq $01, EScript_7f6b
    ent_yield
    ent_jump .l7f60

EScript_7f6b:
    ent_vel_x_zero
    ent_gfx $05
    ent_set_timer $64
    ent_wait_timer
    ent_gfx $02
    ent_set_timer $10
    ent_wait_timer
    ent_call $6ba6
    ent_gfx $02
    ent_set_timer $10
    ent_wait_timer
    ent_jump EScript_7f22

EScript_7f81:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_call $6cc5
    ent_set_timer $1e
    ent_wait_timer
    ent_call $6ce2
.l7f8f
    ent_call $6d13
    ent_jr_b8_eq $01, EScript_7f9a
    ent_yield
    ent_jump .l7f8f

EScript_7f9a:
    ent_vel_x_zero
    ent_gfx $06
    ent_set_timer $1e
    ent_wait_timer
    ent_call $6d7f
    ent_set_timer $50
    ent_wait_timer
    ent_gfx $02
    ent_set_timer $10
    ent_wait_timer
    ent_call $6ba6
    ent_gfx $02
    ent_set_timer $10
    ent_wait_timer
    ent_jump EScript_7f22

EScript_7fb6:
    ent_set_type $05
    ent_vel_x_zero
    ent_gfx $07
    ent_set_timer $05
    ent_wait_timer
    ent_gfx $01
    ent_set_timer $05
    ent_wait_timer
    ent_call $6e0a
.l7fc6
    ent_call $6e98
    ent_jr_b8_eq $ff, EScript_7fdd
    ent_jr_b8_eq $01, EScript_7fd5
    ent_yield
    ent_jump .l7fc6

EScript_7fd5:
    ent_gfx $08
    ent_set_timer $0a
    ent_wait_timer
    ent_jump EScript_7f22

EScript_7fdd:
    ent_call $4622
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $78
    ent_wait_timer
    ent_call $556e
    ent_despawn
