; Editor-placeable monster entity scripts (bank $03): the Tacopi..Suezo roster,
; each a Stand/Chase/Windup/Hurt/... state machine, plus the shared velocity
; tables they read via ent_vel_x_indexed. See docs/entity_scripts.md.

SECTION "scripts_vel", ROMX[$6fc4], BANK[$03]

; --- entity horizontal-velocity tables: 16-bit values (db lo/hi pairs) read by
;     ent_vel_x_indexed in the scripts below. Not referenced from room/engine.asm. ---

PlayerWalkVelR:
	db $00, $01, $00, $01

Data_03_6fc8:
	db $00, $01

Data_03_6fca:
	db $00, $01, $00, $02
PlayerWalkVelL:
	db $55, $00, $55, $00

Data_03_6fd2:
	db $55, $00

Data_03_6fd4:
	db $55, $00, $aa, $00
PlayerCarryWalkVel:
	db $9c, $00, $9c, $00

Data_03_6fdc:
	db $9c, $00

Data_03_6fde:
	db $9c, $00, $9c, $00, $80, $00, $c0, $00, $00, $01, $80, $01, $00, $02
GolemWalkVel:
	db $2a, $00, $3f, $00

Data_03_6ff0:
	db $55, $00

Data_03_6ff2:
	db $7f, $00, $aa, $00
GolemChargeVel:
	db $55, $00, $7f, $00

Data_03_6ffa:
	db $aa, $00

Data_03_6ffc:
	db $ff, $00, $54, $01

MonsterWalkVel:
	db $40, $00, $60, $00, $80, $00, $c0, $00, $00, $01
MonsterChargeVel:
	db $60, $00, $90, $00, $c0, $00, $20, $01

Data_03_7012:
	db $80, $01, $50, $00, $78, $00, $a0, $00, $f0, $00, $40, $01

PsyloraWalkVel:
	db $40, $00, $60, $00, $80, $00, $00, $01, $80, $01

Data_03_7028:
	db $20, $00, $30, $00

Data_03_702c:
	db $40, $00

Data_03_702e:
	db $60, $00, $80, $00, $60, $00, $90, $00

Data_03_7036:
	db $c0, $00

Data_03_7038:
	db $20, $01, $80, $01, $00, $01, $80, $01

Data_03_7040:
	db $00, $02

Data_03_7042:
	db $70, $00, $70, $01

SECTION "scripts_monster", ROMX[$74f1], BANK[$03]

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

Naga_Fire:
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
    ent_jr_hit Naga_FaceLeft
    ent_set_facing $00
    ent_set_xflip $00
    ent_jump Naga_Chase

Naga_FaceLeft:
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

Dino_Fire:
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

Plant_IdleR:
    ent_call Plant_Think
    ent_loop_timer Plant_IdleR
    ent_jump Plant_Chase

Plant_IdleRWait:
    ent_yield
    ent_jump Plant_IdleR

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

Henger_WindupFlip:
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

Puncho_ChargeL:
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

Psylora_MoveDownA:
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

Ducken_DieHorizontal:
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
    ent_jr_busy FlameRed_Hit
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

FlameRed_Hit:
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
    ent_jr_busy FlameBlue_Emerge
    ent_yield
    ent_jump .l7a24

FlameBlue_Surface:
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $02
    ent_set_timer $f0
.l7a33
    ent_update_action
    ent_jr_busy FlameBlue_Hit
    ent_loop_timer .l7a33
    ent_jump FlameBlue_Hidden

FlameBlue_Emerge:
    ent_set_type $02
    ent_vel_x_zero
    ent_gfx $01
    ent_begin_action
.l7a43
    ent_update_action
    ent_yield
    ent_jr_busy .l7a43
    ent_jump FlameBlue_Hidden

FlameBlue_Hit:
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

Tiger_IdleR:
    ent_call $64dd
    ent_loop_timer Tiger_IdleR
    ent_jump Tiger_Chase

Tiger_IdleRWait:
    ent_yield
    ent_jump Tiger_IdleR

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

Mocchi_ChargeL:
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
    ent_jump Hare_Stun

Hare_Charge:
    ent_set_type $06
    ent_vel_x_indexed MonsterChargeVel
    ent_set_facing $fe
    ent_gfx $02
.l7bbe
    ent_call Hare_ThinkB
    ent_yield
    ent_jump .l7bbe

Hare_Stun:
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
    ent_jump Golem_Stun

Golem_Charge:
    ent_set_type $06
    ent_vel_x_indexed GolemChargeVel
    ent_set_facing $fe
    ent_gfx $02
.l7c97
    ent_call Golem_ThinkB
    ent_yield
    ent_jump .l7c97

Golem_Stun:
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

Suezo_Fire:
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
    ent_jr_hit Suezo_FaceLeft
    ent_set_facing $00
    ent_set_xflip $00
    ent_jump Suezo_Chase

Suezo_FaceLeft:
    ent_set_facing $01
    ent_set_xflip $01
    ent_jump Suezo_Chase

; --- Suezo's long-stun state ($7d25): re-enters Suezo's hurt handler
;     ($7d06/$7d11, kept as raw addrs). Entered via a bank-3 table at $5751..
;     (still mis-disassembled), hence no internal referrer. ---

Suezo_Stun:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $f0
.l7d2c
    ent_update_action
    ent_jr_busy $7d06
    ent_loop_timer .l7d2c
    ent_jump $7d11
