IF !DEF(MONSTER_INC)
DEF MONSTER_INC EQU 1

INCLUDE "enum.inc"

; monster species (arr1 / sprite-set ids referenced by a monster slot's GfxIndex)
enum MONSTER
    case TACOPI  ; aka Octopee
    case JELL
    case NAGA
    case DINO
    case PLANT
    case HENGER
    case JOKER
    case GHOST
    case PUNCHO
    case PSYLORA ; aka Psiroller
    case DUCKEN  ; aka Dakkung
    case FLAME_RED
    case FLAME_BLUE

    case UNUSED

    ; Friendly monsters available on bonus stages
    case TIGER  ; Floor 56
    case MOCCHI ; Floor 58
    case HARE   ; Floor 06
    case GALI   ; Floor 18
    case GOLEM  ; Floor 22
    case SUEZO  ; Floor 44
end_enum

enum SUMMON
    case TIGER
    case MOCCHI
    case HARE
    case GALI
    case GOLEM
    case SUEZO
    case PHOENIX
end_enum

ENDC