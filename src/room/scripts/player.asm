; Player-avatar entity scripts (bank $03): walk / push / pull / grab / carry /
; throw / kick state machine. See docs/entity_scripts.md.

SECTION "scripts_player", ROMX[$72d6], BANK[$03]

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

Player_KickRightRecover:
    ent_call Player_CarryStandThink
    ent_yield
    ent_jump Player_KickRightRecover

Player_CarryWalk:
    ent_set_type $10
    ent_vel_x_indexed PlayerCarryWalkVel
    ent_gfx $0b

Player_KickCarryRecover:
    ent_call Player_CarryWalkThink
    ent_yield
    ent_jump Player_KickCarryRecover

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
    ent_jump Player_KickRightRecover

Player_KickCarry:
    ent_set_type $13
    ent_call EntSetAttackActive
    ent_gfx $0b
    ent_set_timer $0a
.l7476
    ent_call Player_UpdateFacing
    ent_loop_timer .l7476
    ent_call EntClearAttackActive
    ent_jump Player_KickCarryRecover

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
