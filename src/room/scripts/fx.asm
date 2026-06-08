; FX / animation library (bank $03 entity scripts): self-contained visual
; effects dispatched by id from the bank-1 pointer tables -- Popup_*, Glide_*,
; Burst*, Vanish_*, Fly_*, Shatter_*. See docs/entity_scripts.md.

INCLUDE "entity_script.inc"

SECTION "scripts_fx_lo", ROMX[$7046], BANK[$03]

; --- FX/animation library, part 1 ($7046): single-frame timed popups
;     (Popup_*) and two coordinate-easing glide movers (Glide_ToTarget*).
;     Dispatched by id from bank-1 pointer tables, not owned by any entity. ---
Popup_Frame01:
    ent_vel_x_zero
    ent_gfx $01
    ent_set_timer $04
    ent_wait_timer
    ent_despawn

Popup_Frame02:
    ent_vel_x_zero
    ent_gfx $02
    ent_set_timer $0a
    ent_wait_timer
    ent_despawn

Popup_Frame03:
    ent_vel_x_zero
    ent_gfx $03
    ent_set_timer $0a
    ent_wait_timer
    ent_despawn

Popup_Frame04:
    ent_vel_x_zero
    ent_gfx $04
    ent_set_timer $07
    ent_wait_timer
    ent_despawn

Popup_Frame05:
    ent_vel_x_zero
    ent_gfx $05
    ent_set_timer $07
    ent_wait_timer
    ent_despawn

Popup_Frame06:
    ent_vel_x_zero
    ent_gfx $06
    ent_set_timer $07
    ent_wait_timer
    ent_despawn

Popup_Frame07:
    ent_vel_x_zero
    ent_gfx $07
    ent_set_timer $07
    ent_wait_timer
    ent_despawn

Glide_ToTargetX:
    ent_gfx $0a
    ent_set_timer $18
    ent_wait_timer
    ent_call $4faa
.l707f
    ent_call $5059
    ent_yield
    ent_jump .l707f

Glide_ToTargetY:
    ent_gfx $09
    ent_call $4f20
.l708b
    ent_call $5013
    ent_yield
    ent_jump .l708b

SECTION "scripts_fx_hi", ROMX[$70ae], BANK[$03]

; --- FX/animation library, part 2 ($70ae-$71d5): two 8-direction burst fans
;     that scatter child sprites (Burst10_*/Burst19_*), a sequential vanish
;     series (Vanish_*), horizontal "fly" sprites (Fly_*), and a shatter pair
;     (Shatter_*). Dispatched by id from bank-1 pointer tables. ---

Popup_Frame0C:
    ent_vel_x_zero
    ent_gfx $0c
    ent_set_timer $0f
    ent_wait_timer
    ent_despawn

Burst19_Scatter:
    ent_vel_x_zero
    ent_gfx $19
    ent_set_timer $15
    ent_wait_timer
    ent_call $4c5f
    ent_despawn

Burst10_Scatter:
    ent_vel_x_zero
    ent_gfx $10
    ent_set_timer $1f
    ent_wait_timer
    ent_call $4c5f
    ent_despawn

Burst10_Dir0a:
    ent_set_facing $00
    ent_gfx $11
    ent_wait_counter
    ent_jump Burst10_Scatter

Burst10_Dir0b:
    ent_set_facing $00
    ent_gfx $12
    ent_wait_counter
    ent_jump Burst10_Scatter

Burst10_Dir1a:
    ent_set_facing $01
    ent_gfx $13
    ent_wait_counter
    ent_jump Burst10_Scatter

Burst10_Dir1b:
    ent_set_facing $01
    ent_gfx $14
    ent_wait_counter
    ent_jump Burst10_Scatter

Burst10_Dir2a:
    ent_set_facing $02
    ent_gfx $15
    ent_wait_counter
    ent_jump Burst10_Scatter

Burst10_Dir2b:
    ent_set_facing $02
    ent_gfx $16
    ent_wait_counter
    ent_jump Burst10_Scatter

Burst10_Dir3a:
    ent_set_facing $03
    ent_gfx $17
    ent_wait_counter
    ent_jump Burst10_Scatter

Burst10_Dir3b:
    ent_set_facing $03
    ent_gfx $18
    ent_wait_counter
    ent_jump Burst10_Scatter

Burst19_Dir0a:
    ent_set_facing $00
    ent_gfx $1a
    ent_wait_counter
    ent_jump Burst19_Scatter

Burst19_Dir0b:
    ent_set_facing $00
    ent_gfx $1b
    ent_wait_counter
    ent_jump Burst19_Scatter

Burst19_Dir1a:
    ent_set_facing $01
    ent_gfx $1c
    ent_wait_counter
    ent_jump Burst19_Scatter

Burst19_Dir1b:
    ent_set_facing $01
    ent_gfx $1d
    ent_wait_counter
    ent_jump Burst19_Scatter

Burst19_Dir2a:
    ent_set_facing $02
    ent_gfx $1e
    ent_wait_counter
    ent_jump Burst19_Scatter

Burst19_Dir2b:
    ent_set_facing $02
    ent_gfx $1f
    ent_wait_counter
    ent_jump Burst19_Scatter

Burst19_Dir3a:
    ent_set_facing $03
    ent_gfx $20
    ent_wait_counter
    ent_jump Burst19_Scatter

Burst19_Dir3b:
    ent_set_facing $03
    ent_gfx $21
    ent_wait_counter
    ent_jump Burst19_Scatter

Vanish_Frame30:
    ent_vel_x_zero
    ent_gfx $30
    ent_set_timer $28
    ent_wait_timer
    ent_despawn

Vanish_Frame31:
    ent_vel_x_zero
    ent_gfx $31
    ent_set_timer $28
    ent_wait_timer
    ent_despawn

Vanish_Frame32:
    ent_vel_x_zero
    ent_gfx $32
    ent_set_timer $2a
    ent_wait_timer
    ent_despawn

Vanish_Frame33:
    ent_vel_x_zero
    ent_gfx $33
    ent_set_timer $09
    ent_wait_timer
    ent_despawn

Vanish_Frame34:
    ent_vel_x_zero
    ent_gfx $34
    ent_set_timer $06
    ent_wait_timer
    ent_despawn

Vanish_Frame35:
    ent_vel_x_zero
    ent_gfx $35
    ent_set_timer $10
    ent_wait_timer
    ent_despawn

Fly_Frame36L:
    ent_set_facing $fe
    ent_set_vel_x $0200
    ent_gfx $36
.l717a
    ent_yield
    ent_jump .l717a

Fly_Frame37L:
    ent_set_facing $fe
    ent_set_vel_x $0200
    ent_gfx $37
.l7185
    ent_yield
    ent_jump .l7185

Fly_Frame3A:
    ent_set_vel_x $0200
    ent_gfx $3a
.l718e
    ent_yield
    ent_jump .l718e

Fly_Frame3B:
    ent_set_vel_x $0200
    ent_gfx $3b
.l7197
    ent_yield
    ent_jump .l7197

Fly_Frame3CR:
    ent_set_facing $03
    ent_set_vel_x $0200
    ent_gfx $3c
.l71a2
    ent_yield
    ent_jump .l71a2

Popup_Frame3D:
    ent_vel_x_zero
    ent_gfx $3d
    ent_set_timer $15
    ent_wait_timer
    ent_despawn

Fly_Frame08:
    ent_set_facing $02
    ent_set_vel_x $0080
    ent_gfx $08
    ent_set_timer $20
    ent_wait_timer
    ent_despawn

Popup_Frame0B:
    ent_vel_x_zero
    ent_gfx $0b
    ent_set_timer $0a
    ent_wait_timer
    ent_despawn

Shatter_Spawn8:
    ent_vel_x_zero
    ent_gfx $0f
    ent_set_timer $3c
    ent_wait_timer
    ent_call $55a1
    ent_despawn

Shatter_DriveFragments:
    ent_vel_x_zero
    ent_gfx $09
    ent_set_timer $5a
.l71ce
    ent_call $55e7
    ent_loop_timer .l71ce
    ent_despawn
