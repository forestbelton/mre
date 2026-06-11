IF !DEF(GAME_INC)
DEF GAME_INC EQU 1

INCLUDE "enum.inc"

enum TOAMUNA_STATE
    case INITIAL
    case GREETING
    case PASHUTE
    case VERDE
    case EVERYONE
end_enum

ENDC
