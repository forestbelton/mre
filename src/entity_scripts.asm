; Entity behaviour scripts (bank $03, $71eb-$7d25) -- the per-entity bytecode
; interpreted by RunEntityScript in src/room.asm. One line per VM instruction
; via the macros in include/entity_script.inc; see docs/entity_scripts.md.
;
; Names: the player avatar is fully identified; monster groups (MobN) have
; high-confidence roles (Stand/Chase/Windup/Hurt/Charge/Die) but their species
; is not derivable from this bank (it lives in the bank-$01/$04 spawn tables),
; so they are numbered. Generated, then byte-exact-verified by make verify.

INCLUDE "entity_script.inc"

SECTION "entity_scripts", ROMX[$71eb], BANK[$03]

Stairs_AppearDown:
    ent_vel_x_zero
    ent_gfx $0e
    ent_call_bank0 $01, $4cd3
.l71f2
    ent_call $6f19
    ent_yield
    ent_jump .l71f2

Stairs_OpenDown:
    ent_vel_x_zero
    ent_gfx $0d
    ent_call $6f37
.l71ff
    ent_call $6f43
    ent_jr_b8_eq $01, EScript_720a
    ent_yield
    ent_jump .l71ff

EScript_720a:
    ent_vel_x_zero
    ent_gfx $0e
    ent_call $6f2b
.l7210
    ent_call $6f92
    ent_jr_b8_eq $01, Stairs_AppearDown
    ent_yield
    ent_jump .l7210

EScript_721b:
    ent_vel_x_zero
    ent_gfx $0e
    ent_call_bank0 $01, $4cf0
.l7222
    ent_call $6f22
    ent_yield
    ent_jump .l7222

Stairs_OpenUp:
    ent_vel_x_zero
    ent_gfx $0d
    ent_call $6f37
.l722f
    ent_call $6f43
    ent_jr_b8_eq $01, EScript_723a
    ent_yield
    ent_jump .l722f

EScript_723a:
    ent_vel_x_zero
    ent_gfx $0e
    ent_call $6f2b
.l7240
    ent_call $6f92
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
    ent_call_bank0 $01, $4d33
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
    ent_call_bank0 $01, $4d33
    ent_set_timer $05
    ent_wait_timer
    ent_despawn

Door_OpenA:
    ent_vel_x_zero
    ent_gfx $38
.l7280
    ent_call $5743
    ent_yield
    ent_jump .l7280

Door_OpenB:
    ent_vel_x_zero
    ent_gfx $38
.l728a
    ent_call $575a
    ent_yield
    ent_jump .l728a

Door_OpenC:
    ent_vel_x_zero
    ent_gfx $38
.l7294
    ent_call $5771
    ent_yield
    ent_jump .l7294

Sparkle_Idle:
    ent_vel_x_zero
    ent_gfx $22
.l729e
    ent_yield
    ent_jump .l729e

Sparkle_Ring:
    ent_call_bank0 $01, $4d4b
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
    ent_call $6daa
    ent_set_timer $02
    ent_wait_timer
    ent_call $6dbe
    ent_set_timer $02
    ent_wait_timer
    ent_call $6de4
    ent_set_timer $02
    ent_wait_timer
    ent_call $6dbe
    ent_set_timer $02
    ent_wait_timer
    ent_call $6daa
    ent_set_timer $02
    ent_wait_timer
    ent_despawn

Player_SpawnIntro:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_call $4904
    ent_yield

Player_StandDown:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
.l72e4
    ent_call $470a
    ent_yield
    ent_jump .l72e4

Player_StandUp:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $02
.l72f0
    ent_call $474e
    ent_yield
    ent_jump .l72f0

Player_WalkRight:
    ent_set_type $02
    ent_vel_x_indexed $6fc4
    ent_gfx $03
.l72fe
    ent_call $4783
    ent_yield
    ent_jump .l72fe

Player_WalkLeft:
    ent_set_type $03
    ent_vel_x_indexed $6fce
    ent_gfx $04
.l730c
    ent_call $47b8
    ent_yield
    ent_jump .l730c

Player_PushDown:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $07
    ent_set_timer $0a
.l731a
    ent_call $48f9
    ent_loop_timer .l731a
    ent_call $4a6a
    ent_set_timer $0c
.l7325
    ent_call $48f9
    ent_loop_timer .l7325
    ent_call $4915
    ent_jump Player_StandDown

Player_PushUp:
    ent_set_type $05
    ent_vel_x_zero
    ent_gfx $08
    ent_set_timer $0a
.l7338
    ent_call $48f9
    ent_loop_timer .l7338
    ent_call $4a6a
    ent_set_timer $0c
.l7343
    ent_call $48f9
    ent_loop_timer .l7343
    ent_call $4915
    ent_jump Player_StandUp

Player_PushRight:
    ent_set_type $06
    ent_call $4a64
    ent_gfx $07
    ent_set_timer $0a
    ent_wait_timer
    ent_call $4a6a
    ent_set_timer $0c
    ent_wait_timer
    ent_call $4a5e
    ent_call $4915
    ent_load_b8 $ff8b
    ent_test_b8 $30
    ent_jr_free Player_CarryWalk
    ent_jump Player_CarryStand

Player_PullDown:
    ent_set_type $07
    ent_vel_x_zero
    ent_gfx $05
    ent_call $4c65
    ent_set_timer $0e
.l737a
    ent_call $48f9
    ent_loop_timer .l737a
    ent_call $4915
    ent_jump Player_StandDown

Player_PullUp:
    ent_set_type $08
    ent_vel_x_zero
    ent_gfx $06
    ent_call $4c65
    ent_set_timer $0e
.l7390
    ent_call $48f9
    ent_loop_timer .l7390
    ent_call $4915
    ent_jump Player_StandUp

Player_PullRight:
    ent_set_type $09
    ent_call $4a64
    ent_gfx $05
    ent_call $4c65
    ent_set_timer $0e
    ent_wait_timer
    ent_call $4a5e
    ent_call $4915
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
    ent_call $48f9
    ent_loop_timer .l73c1
    ent_call_bank0 $01, $5dae
    ent_call $4915
    ent_jump Player_StandDown

Player_GrabUp:
    ent_set_type $0b
    ent_vel_x_zero
    ent_gfx $06
    ent_set_timer $0e
.l73d8
    ent_call $48f9
    ent_loop_timer .l73d8
    ent_call_bank0 $01, $5dae
    ent_call $4915
    ent_jump Player_StandUp

Player_GrabRight:
    ent_set_type $0c
    ent_call $4a64
    ent_gfx $05
    ent_set_timer $0e
    ent_wait_timer
    ent_call $4a5e
    ent_call_bank0 $01, $5dae
    ent_call $4915
    ent_load_b8 $ff8b
    ent_test_b8 $30
    ent_jr_free Player_CarryWalk
    ent_jump Player_CarryStand

Player_LiftCarry:
    ent_set_type $0d
    ent_vel_x_zero
    ent_gfx $09
    ent_call $4910
    ent_set_timer $07
.l7411
    ent_call $48cb
    ent_loop_timer .l7411
    ent_call $4a46
    ent_call $47ed
    ent_jump Player_CarryStand

Player_ThrowWindup:
    ent_set_type $0e
    ent_vel_x_zero
    ent_call $4910
    ent_begin_action
    ent_call $47f4

Player_CarryStand:
    ent_set_type $0f
    ent_vel_x_zero
    ent_gfx $0a

EScript_742f:
    ent_call $4810
    ent_yield
    ent_jump EScript_742f

Player_CarryWalk:
    ent_set_type $10
    ent_vel_x_indexed $6fd8
    ent_gfx $0b

EScript_743d:
    ent_call $483e
    ent_yield
    ent_jump EScript_743d

Player_ThrowRelease:
    ent_set_type $11
    ent_vel_x_zero
    ent_gfx $0c
    ent_call $48cb
    ent_yield
    ent_set_timer $04
.l744f
    ent_call $4868
    ent_loop_timer .l744f
    ent_call $4873

Player_KickRight:
    ent_set_type $12
    ent_call $4a64
    ent_gfx $0a
    ent_set_timer $0a
.l7461
    ent_call $48cb
    ent_loop_timer .l7461
    ent_call $4a5e
    ent_jump EScript_742f

Player_KickCarry:
    ent_set_type $13
    ent_call $4a64
    ent_gfx $0b
    ent_set_timer $0a
.l7476
    ent_call $48cb
    ent_loop_timer .l7476
    ent_call $4a5e
    ent_jump EScript_743d

PlayerHit_Slash:
    ent_set_type $14
    ent_vel_x_zero
    ent_gfx $10
    ent_set_timer $a8
.l7489
    ent_call $4f0a
    ent_loop_timer .l7489
    ent_call $4a58
.l7492
    ent_yield
    ent_jump .l7492

PlayerHit_Charge:
    ent_set_type $15
    ent_vel_x_zero
    ent_call $4a5e
    ent_begin_action
    ent_gfx $11
.l749f
    ent_yield
    ent_update_action
    ent_jr_busy .l749f
    ent_gfx $12
    ent_set_timer $90
.l74a8
    ent_call $4f0a
    ent_loop_timer .l74a8
    ent_call $4a58
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
    ent_call $46e2
    ent_jr_hit Shard_TumbleAlt
    ent_call $517e
    ent_set_timer $3c
    ent_wait_timer
    ent_call $5185
    ent_set_timer $1e
    ent_wait_timer
    ent_jump EScript_74c1

Shard_TumbleAlt:
    ent_call $5177
    ent_set_timer $3c
    ent_wait_timer
    ent_call $518c
    ent_set_timer $1e
    ent_wait_timer
    ent_jump EScript_74c1

Generic_Despawn:
    ent_despawn

Item_Idle:
    ent_set_type $00
    ent_gfx $00
.l74ea
    ent_call $57cc
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
    ent_vel_x_indexed $7000
    ent_set_facing $fe
    ent_gfx $02
.l751b
    ent_call $5a4d
    ent_yield
    ent_jump .l751b

Tacopi_Windup:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $02
    ent_call $4461
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
    ent_call $4a64
    ent_set_timer $0f
    ent_wait_timer
    ent_call $4a5e
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
    ent_call $5956
    ent_loop_timer .l7573
    ent_jump Jell_Chase

Jell_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7583
    ent_call $5938
    ent_loop_timer .l7583
    ent_set_xflip $ff

Jell_Chase:
    ent_set_type $02
    ent_vel_x_indexed $7000
    ent_set_facing $fe
    ent_gfx $02
.l7594
    ent_call $5956
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
    ent_call $4461
    ent_vel_x_indexed $700a
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
    ent_call $4461
    ent_vel_x_indexed $700a
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
    ent_call $4a64
    ent_set_timer $0f
    ent_wait_timer
    ent_call $4a5e
    ent_gfx $04
    ent_begin_action
.l75f4
    ent_update_action
    ent_yield
    ent_jr_busy .l75f4
    ent_jump Jell_Chase

Jell_Charge:
    ent_set_type $06
    ent_vel_x_indexed $700a
    ent_set_facing $fe
    ent_gfx $02
.l7605
    ent_call $5984
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
    ent_call $63e9
    ent_loop_timer .l761c
    ent_jump Naga_Chase

Naga_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l762c
    ent_call $63e9
    ent_loop_timer .l762c
    ent_set_xflip $ff

Naga_Chase:
    ent_set_type $02
    ent_vel_x_indexed $7000
    ent_set_facing $fe
    ent_gfx $02
.l763d
    ent_call $640f
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
    ent_call $5382
    ent_set_timer $09
    ent_wait_timer
    ent_call $4461
    ent_call $57b4
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
    ent_call $4a64
    ent_set_timer $0f
    ent_wait_timer
    ent_call $4a5e
    ent_gfx $04
    ent_begin_action
.l7686
    ent_update_action
    ent_yield
    ent_jr_busy .l7686

Naga_FaceFlip:
    ent_call $46e2
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
    ent_call $5a6b
    ent_loop_timer .l76af
    ent_jump Dino_Chase

Dino_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l76bf
    ent_call $5a6b
    ent_loop_timer .l76bf
    ent_set_xflip $ff

Dino_Chase:
    ent_set_type $02
    ent_vel_x_indexed $7000
    ent_set_facing $fe
    ent_gfx $02
.l76d0
    ent_call $5a91
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
    ent_call $5376
    ent_call $4461
    ent_set_timer $28
    ent_wait_timer
    ent_set_timer $05
.l76f2
    ent_update_action
    ent_jr_busy Dino_Hurt
    ent_loop_timer .l76f2
    ent_call $57b4
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
    ent_call $5b71
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
    ent_call $5b97
    ent_loop_timer .l772e
    ent_set_xflip $ff

Plant_Chase:
    ent_set_type $02
    ent_vel_x_indexed $7000
    ent_set_facing $fe
    ent_gfx $02
.l773f
    ent_call $5bbd
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
    ent_call $5483
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
    ent_call $5370
    ent_set_timer $21
    ent_wait_timer
    ent_call $4461
    ent_set_timer $09
    ent_wait_timer

EScript_7793:
    ent_set_xflip $ff

Henger_Chase:
    ent_set_type $02
    ent_vel_x_indexed $7000
    ent_set_facing $fe
    ent_gfx $02
.l779e
    ent_call $5ca9
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
    ent_call $537c
    ent_set_timer $09
    ent_wait_timer
    ent_call $4461
    ent_set_xflip $ff

Joker_Chase:
    ent_set_type $02
    ent_vel_x_indexed $7000
    ent_set_facing $fe
    ent_gfx $02
.l77de
    ent_call $5cb5
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
    ent_call $5c76
    ent_loop_timer .l77fe
    ent_jump Ghost_Chase

Ghost_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l780e
    ent_call $5c76
    ent_loop_timer .l780e
    ent_set_xflip $ff

Ghost_Chase:
    ent_set_type $02
    ent_vel_x_indexed $7000
    ent_gfx $02
.l781d
    ent_call $5c88
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
    ent_call $5cc1
    ent_loop_timer .l7863
    ent_jump Puncho_Chase

Puncho_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7873
    ent_call $5cc1
    ent_loop_timer .l7873
    ent_set_xflip $ff

Puncho_Chase:
    ent_set_type $02
    ent_vel_x_indexed $7000
    ent_set_facing $fe
    ent_gfx $02
.l7884
    ent_call $5cd7
    ent_yield
    ent_jump .l7884

Puncho_Attack:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
.l7890
    ent_call $5cf5
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
    ent_vel_x_indexed $700a
    ent_set_facing $fe
    ent_gfx $05
.l78ae
    ent_call $5d0b
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
    ent_call $6730
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
    ent_vel_x_indexed $701e
    ent_call $5d21

EScript_78df:
    ent_set_facing $00
    ent_gfx $11
.l78e3
    ent_call $5d6b
    ent_yield
    ent_jump .l78e3

Psylora_WalkDownB:
    ent_set_facing $01
    ent_gfx $12
.l78ee
    ent_call $5d89
    ent_yield
    ent_jump .l78ee

Psylora_WalkUpA:
    ent_set_facing $00
    ent_gfx $13
.l78f9
    ent_call $5d6b
    ent_yield
    ent_jump .l78f9

Psylora_WalkUpB:
    ent_set_facing $01
    ent_gfx $14
.l7904
    ent_call $5d89
    ent_yield
    ent_jump .l7904

Psylora_WalkRightA:
    ent_set_facing $02
    ent_gfx $15
.l790f
    ent_call $5da7
    ent_yield
    ent_jump .l790f

Psylora_WalkLeftA:
    ent_set_facing $03
    ent_gfx $16
.l791a
    ent_call $5dc5
    ent_yield
    ent_jump .l791a

Psylora_WalkRightB:
    ent_set_facing $02
    ent_gfx $17
.l7925
    ent_call $5da7
    ent_yield
    ent_jump .l7925

Psylora_WalkLeftB:
    ent_set_facing $03
    ent_gfx $18
.l7930
    ent_call $5dc5
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
    ent_call $6381

Ducken_AimR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_call $5447
.l798a
    ent_call $636b
    ent_jr_b8_eq $01, Ducken_FireR
    ent_yield
    ent_jump .l798a

Ducken_AimL:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $02
    ent_call $5447
.l799d
    ent_call $636b
    ent_jr_b8_eq $01, Ducken_FireL
    ent_yield
    ent_jump .l799d

Ducken_FireR:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
    ent_wait_timer
    ent_call $53d9
    ent_set_timer $03
    ent_wait_timer
    ent_jump Ducken_AimR

Ducken_FireL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $04
    ent_set_timer $1e
    ent_wait_timer
    ent_call $540f
    ent_set_timer $03
    ent_wait_timer
    ent_jump Ducken_AimL

Ducken_Die:
    ent_call $63ab

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

Mob12_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c

EScript_7a60:
    ent_call $64dd
    ent_loop_timer EScript_7a60
    ent_jump Mob12_Chase

EScript_7a69:
    ent_yield
    ent_jump EScript_7a60

Mob12_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7a74
    ent_call $6503
    ent_loop_timer .l7a74
    ent_set_xflip $ff

Mob12_Chase:
    ent_set_type $02
    ent_vel_x_indexed $7000
    ent_set_facing $fe
    ent_gfx $02
.l7a85
    ent_call $6529
    ent_yield
    ent_jump .l7a85

Mob12_Windup:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l7a93
    ent_update_action
    ent_jr_busy Mob12_Hurt
    ent_loop_timer .l7a93
    ent_call $546c
    ent_set_timer $05
.l7a9f
    ent_update_action
    ent_jr_busy Mob12_Hurt
    ent_loop_timer .l7a9f
    ent_jump Mob12_Chase

Mob12_Hurt:
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
    ent_jr_busy Mob12_Hurt
    ent_loop_timer .l7abb
    ent_jump Mob12_StandR

Mob13_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7acc
    ent_call $65dc
    ent_loop_timer .l7acc
    ent_jump Mob13_Chase

Mob13_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7adc
    ent_call $65dc
    ent_loop_timer .l7adc
    ent_set_xflip $ff

Mob13_Chase:
    ent_set_type $02
    ent_vel_x_indexed $7000
    ent_set_facing $fe
    ent_gfx $02
.l7aed
    ent_call $65f2
    ent_yield
    ent_jump .l7aed

Mob13_Attack:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
.l7af9
    ent_call $6610
    ent_yield
    ent_jump .l7af9

Mob13_Hurt:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l7b06
    ent_update_action
    ent_yield
    ent_jr_busy .l7b06
    ent_jump Mob13_StandR

Mob13_Charge:
    ent_set_type $05
    ent_vel_x_indexed $700a
    ent_set_facing $fe
    ent_gfx $05
.l7b17
    ent_call $6626
    ent_yield
    ent_jump .l7b17

EScript_7b1e:
    ent_set_xflip $ff
    ent_jump Mob13_Charge

Mob13_Special:
    ent_set_type $06
    ent_vel_x_zero
    ent_gfx $05
    ent_begin_action
.l7b29
    ent_update_action
    ent_yield
    ent_jr_busy .l7b29
    ent_call $6730
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
    ent_jr_busy Mob13_Hurt
    ent_loop_timer .l7b3e
    ent_jump Mob13_StandR

Mob14_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7b4f
    ent_call $68c7
    ent_loop_timer .l7b4f
    ent_jump Mob14_Chase

Mob14_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7b5f
    ent_call $68a9
    ent_loop_timer .l7b5f
    ent_set_xflip $ff

Mob14_Chase:
    ent_set_type $02
    ent_vel_x_indexed $7000
    ent_set_facing $fe
    ent_gfx $02
.l7b70
    ent_call $68c7
    ent_yield
    ent_jump .l7b70

Mob14_WindupR:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l7b7e
    ent_update_action
    ent_jr_busy Mob14_Hurt
    ent_loop_timer .l7b7e
    ent_call $4461
    ent_set_timer $05
    ent_wait_timer
    ent_jump Mob14_Chase

Mob14_WindupL:
    ent_set_type $07
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l7b95
    ent_update_action
    ent_jr_busy Mob14_Hurt
    ent_loop_timer .l7b95
    ent_call $4461
    ent_set_timer $05
    ent_wait_timer
    ent_set_xflip $ff
    ent_jump Mob14_Chase

Mob14_Hurt:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l7bad
    ent_update_action
    ent_yield
    ent_jr_busy .l7bad
    ent_jump EScript_7bc5

Mob14_Charge:
    ent_set_type $06
    ent_vel_x_indexed $700a
    ent_set_facing $fe
    ent_gfx $02
.l7bbe
    ent_call $68f5
    ent_yield
    ent_jump .l7bbe

EScript_7bc5:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $f0
.l7bcc
    ent_update_action
    ent_jr_busy Mob14_Hurt
    ent_loop_timer .l7bcc
    ent_jump Mob14_StandR

Mob15_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
    ent_wait_timer
    ent_jump Mob15_Chase

Mob15_Windup:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $03
    ent_call $5388
    ent_set_timer $09
    ent_wait_timer
    ent_call $4461
    ent_set_timer $0f
    ent_wait_timer
    ent_set_xflip $ff

Mob15_Chase:
    ent_set_type $02
    ent_vel_x_indexed $7000
    ent_set_facing $fe
    ent_gfx $02
.l7bfd
    ent_call $529a
    ent_jr_b8_eq $03, Mob15_Windup
    ent_yield
    ent_jump .l7bfd

Mob15_Die:
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
    ent_jr_busy Mob15_Die
    ent_loop_timer .l7c17
    ent_jump Mob15_StandR

Mob16_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7c28
    ent_call $6855
    ent_loop_timer .l7c28
    ent_jump Mob16_Chase

Mob16_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7c38
    ent_call $6837
    ent_loop_timer .l7c38
    ent_set_xflip $ff

Mob16_Chase:
    ent_set_type $02
    ent_vel_x_indexed $6fec
    ent_set_facing $fe
    ent_gfx $02
.l7c49
    ent_call $6855
    ent_yield
    ent_jump .l7c49

Mob16_WindupR:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l7c57
    ent_update_action
    ent_jr_busy Mob16_Hurt
    ent_loop_timer .l7c57
    ent_call $4461
    ent_set_timer $08
    ent_wait_timer
    ent_jump Mob16_Chase

Mob16_WindupL:
    ent_set_type $07
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l7c6e
    ent_update_action
    ent_jr_busy Mob16_Hurt
    ent_loop_timer .l7c6e
    ent_call $4461
    ent_set_timer $08
    ent_wait_timer
    ent_set_xflip $ff
    ent_jump Mob16_Chase

Mob16_Hurt:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_begin_action
.l7c86
    ent_update_action
    ent_yield
    ent_jr_busy .l7c86
    ent_jump EScript_7c9e

Mob16_Charge:
    ent_set_type $06
    ent_vel_x_indexed $6ff6
    ent_set_facing $fe
    ent_gfx $02
.l7c97
    ent_call $6883
    ent_yield
    ent_jump .l7c97

EScript_7c9e:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $f0
.l7ca5
    ent_update_action
    ent_jr_busy Mob16_Hurt
    ent_loop_timer .l7ca5
    ent_jump Mob16_StandR

Mob17_StandR:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7cb6
    ent_call $6749
    ent_loop_timer .l7cb6
    ent_jump Mob17_Chase

Mob17_StandL:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7cc6
    ent_call $6749
    ent_loop_timer .l7cc6
    ent_set_xflip $ff

Mob17_Chase:
    ent_set_type $02
    ent_vel_x_indexed $7000
    ent_set_facing $fe
    ent_gfx $02
.l7cd7
    ent_call $676f
    ent_yield
    ent_jump .l7cd7

Mob17_Windup:
    ent_set_xflip $ff

EScript_7ce0:
    ent_set_type $03
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $1e
.l7ce7
    ent_update_action
    ent_jr_busy Mob17_HurtFlip
    ent_loop_timer .l7ce7
    ent_call $538e
    ent_call $4461
    ent_set_timer $28
    ent_wait_timer
    ent_set_timer $05
.l7cf9
    ent_update_action
    ent_jr_busy Mob17_HurtFlip
    ent_loop_timer .l7cf9
    ent_call $57b4
    ent_jump Mob17_Chase

Mob17_HurtFlip:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $01
    ent_begin_action
.l7d0c
    ent_update_action
    ent_yield
    ent_jr_busy .l7d0c
    ent_call $46e2
    ent_jr_hit EScript_7d1e
    ent_set_facing $00
    ent_set_xflip $00
    ent_jump Mob17_Chase

EScript_7d1e:
    ent_set_facing $01
    ent_set_xflip $01
    ent_jump Mob17_Chase
