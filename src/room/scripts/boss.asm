; Tower-boss entity scripts (bank $03): the five bosses fought on the unnumbered
; boss floors after 10/20/40/50/60 -- Selketo/Ferious/Punisher/Dragon(+body)/Zan
; (engine types $50-$55), spawned via Data_01_4335. See docs/entity_scripts.md.

SECTION "scripts_boss", ROMX[$7d36], BANK[$03]

; --- The five tower bosses, engine types $50-$55 ($7d36-$7fec). Fought on the
;     unnumbered boss floors entered after exiting floors 10/20/40/50/60:
;       $50 Selketo (after 10)   $51 Ferious (after 20)   $52 Punisher (after 40)
;       $53 Dragon + $54 DragonBody (after 50)   $55 Zan (after 60, final)
;     The Dragon is a two-part boss: $53 is the head (its death writes the kill
;     cell $c530/$c531 that drops the floor exit, gating progress), $54 the
;     body/beam. Spawned by Data_01_4335 (bank $01), indexed by the boss-floor
;     remap Func_01_48af that maps wActiveFloor 10/20/40/50/60 -> index 1-5. Own
;     sprite/init group $30-$35, parallel to the friendly breeds at $40-$45.
;     See docs/entity_scripts.md. ---
Selketo_Init:
    ent_set_xflip $01

Selketo_Idle:
    ent_set_type $00
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $3c
.l7d3f
    ent_update_action
    ent_jr_busy Selketo_Hurt
    ent_loop_timer .l7d3f
    ent_jump Selketo_Attack

Selketo_Dig:
    ent_set_xflip $ff

Selketo_DigLoop:
    ent_set_facing $fe
    ent_set_type $01
    ent_vel_x_indexed $7028
    ent_gfx $02
    ent_set_timer $5a
.l7d56
    ent_call $691b
    ent_jr_b8_eq $ff, Selketo_Hurt
    ent_jr_b8_eq $03, Selketo_Dig
    ent_loop_timer .l7d56
    ent_jump Selketo_Idle

Selketo_Attack:
    ent_set_type $02
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $14
.l7d6e
    ent_update_action
    ent_jr_busy Selketo_Hurt
    ent_loop_timer .l7d6e
    ent_call $549a
    ent_set_timer $0a
.l7d7a
    ent_update_action
    ent_jr_busy Selketo_Hurt
    ent_loop_timer .l7d7a
    ent_call $54ae
    ent_set_timer $0a
.l7d86
    ent_update_action
    ent_jr_busy Selketo_Hurt
    ent_loop_timer .l7d86
    ent_call $54b8
    ent_jump Selketo_DigLoop

Selketo_Hurt:
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

Ferious_Init:
    ent_call $6960
    ent_jump Ferious_SeekLoop

Ferious_Seek:
    ent_set_xflip $ff

Ferious_SeekLoop:
    ent_set_facing $fe
    ent_set_type $01
    ent_vel_x_indexed $7032
    ent_gfx $02
.l7dc4
    ent_call $69a4
    ent_jr_b8_eq $ff, Ferious_AttackB
    ent_jr_b8_eq $01, Ferious_Seek
    ent_jr_b8_eq $02, Ferious_AttackA
    ent_yield
    ent_jump .l7dc4

Ferious_AttackA:
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
    ent_jump Ferious_SeekLoop

Ferious_AttackB:
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
    ent_jump Ferious_Seek

Punisher_Die:
    ent_call $4622
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $3c
    ent_wait_timer
    ent_call $5539
    ent_despawn

Punisher_Main:
    ent_set_xflip $ff
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $b4
.l7e2f
    ent_call $6a7e
    ent_jr_b8_eq $ff, Punisher_Hurt
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
    ent_jump Punisher_Main

Punisher_Hurt:
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

Dragon_Main:
    ent_call $6ab4
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $01
.l7e7b
    ent_call $6ab9
    ent_jr_b8_eq $ff, Dragon_Die
    ent_jr_b8_eq $01, Dragon_Attack
    ent_yield
    ent_jump .l7e7b

Dragon_Attack:
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
    ent_jump Dragon_Main

DragonBody_Main:
    ent_call $6ad3
    ent_set_type $11
    ent_vel_x_zero
    ent_gfx $02
.l7ea6
    ent_call $6adc
    ent_jr_b8_eq $ff, DragonBody_Die
    ent_jr_b8_eq $01, DragonBody_BeamSpread
    ent_yield
    ent_jump .l7ea6

DragonBody_BeamSpread:
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
    ent_jump DragonBody_Main

Dragon_Die:
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

DragonBody_Die:
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $04
    ent_set_timer $3c
    ent_wait_timer
    ent_gfx $05
    ent_despawn

Zan_Init:
    ent_call $6b57
    ent_set_type $01
    ent_vel_x_zero
    ent_gfx $00
.l7f17
    ent_call $6b93
    ent_jr_b8_eq $01, Zan_Decide
    ent_yield
    ent_jump .l7f17

Zan_Decide:
    ent_call $6ba6
    ent_set_type $02
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $b4
    ent_wait_timer
.l7f2d
    ent_call $6bb4
    ent_jr_b8_eq $ff, Zan_Special
    ent_jr_b8_eq $01, Zan_ChargeA
    ent_jr_b8_eq $02, Zan_ChargeB
    ent_yield
    ent_jump .l7f2d

Zan_ChargeA:
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
    ent_jr_b8_eq $01, Zan_ChargeAEnd
    ent_yield
    ent_jump .l7f60

Zan_ChargeAEnd:
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
    ent_jump Zan_Decide

Zan_ChargeB:
    ent_set_type $04
    ent_vel_x_zero
    ent_gfx $04
    ent_call $6cc5
    ent_set_timer $1e
    ent_wait_timer
    ent_call $6ce2
.l7f8f
    ent_call $6d13
    ent_jr_b8_eq $01, Zan_SpawnChild
    ent_yield
    ent_jump .l7f8f

Zan_SpawnChild:
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
    ent_jump Zan_Decide

Zan_Special:
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
    ent_jr_b8_eq $ff, Zan_Die
    ent_jr_b8_eq $01, Zan_SpecialEnd
    ent_yield
    ent_jump .l7fc6

Zan_SpecialEnd:
    ent_gfx $08
    ent_set_timer $0a
    ent_wait_timer
    ent_jump Zan_Decide

Zan_Die:
    ent_call $4622
    ent_set_type $ff
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $78
    ent_wait_timer
    ent_call $556e
    ent_despawn
