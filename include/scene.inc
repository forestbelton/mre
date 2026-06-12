IF !DEF(SCENE_INC)
DEF SCENE_INC EQU 1

INCLUDE "enum.inc"

enum SCENE
    case TITLE
    case LOGO
    case INTRO
    skip
    case TOWN
    ; the five town-location scenes (TOWN confirm sets 5+location)
    case NAJI       ; the tower spot
    case BODKA
    case PASHUTE
    case TOAMUNA
    case VERDE
    REPT 6
        skip ; unused
    ENDR
    case NEXT_ROOM
    case ROOM_START
    case ROOM
    case ROOM_CLEAR
    case TOWER
end_enum

ENDC