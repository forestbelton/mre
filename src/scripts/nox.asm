; Nox flashback dialogues (bank 19).
;
; The player watches a series of flashback / memory scenes featuring
; Nox and his childhood friend Alf. The four SCRIPT_END sub-scripts
; in this region run independently — each dispatched by the engine
; when the corresponding story trigger fires:
;
;   NoxScript        $4C449  Nox/Alf flashback ("Wow, you were cool
;                            back then... It's a promise between
;                            men!"). Two-speaker scene using
;                            renderers $4284 / $429C alternately for
;                            left vs right bubble positions.
;   nox_46d5         $46D5   Nox reminiscing solo ("Whew! I forgot
;                            just how much fun it was...").
;   nox_473d         $473D   Nox "I'll go see old friends".
;   nox_47c3         $47C3   Nox "Wait, I forgot" — short.
;
; The flashbacks use textbox tilemap position $9C22 (vs the standard
; $9982 used by overworld NPCs), placing the dialog in a different
; on-screen region appropriate for a flashback/memory view.
;
; See docs/text_engine.md for the bytecode reference.

INCLUDE "script.inc"

SECTION "nox_04c449", ROMX[$4449], BANK[$13]


NoxScript:
    SCRIPT_OPEN_TEXTBOX .Pos=$9c22, .Width=$10, .Height=$04
    SCRIPT_RENDERER .Addr=$4284, .Bank=$13
    db "Wow, you were"
    SCRIPT_NEWLINE
    db "cool back then."
    SCRIPT_WAIT
    db "You don't look"
    SCRIPT_NEWLINE
    db "so cool now."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$429c, .Bank=$13
    db "Ugh..."
    SCRIPT_NEWLINE
    db "That's harsh."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$4284, .Bank=$13
    db "Cool! I want"
    SCRIPT_NEWLINE
    db "adventure like"
    SCRIPT_WAIT
    db "that! Is that"
    SCRIPT_NEWLINE
    db "tower there now?"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$429c, .Bank=$13
    db "Of course, Alf."
    SCRIPT_WAIT
    db "You should go"
    SCRIPT_NEWLINE
    db "there someday."
    SCRIPT_WAIT
    db "You'd have"
    SCRIPT_NEWLINE
    db "a great time."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$4284, .Bank=$13
    db "Hmmm..."
    SCRIPT_NEWLINE
    db "After I grow up?"
    SCRIPT_WAIT
    db "Oh no! I want"
    SCRIPT_NEWLINE
    db "to go there now!"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$429c, .Bank=$13
    db "Whoa whoa whoa!"
    SCRIPT_NEWLINE
    db "It's dangerous."
    SCRIPT_WAIT
    db "What happens if"
    SCRIPT_NEWLINE
    db "you get lost?"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$4284, .Bank=$13
    db "Gimme a break!"
    SCRIPT_WAIT
    db "You're the"
    SCRIPT_NEWLINE
    db "one who's lost!"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$429c, .Bank=$13
    db "Ugh..."
    SCRIPT_NEWLINE
    db "Alf..."
    SCRIPT_WAIT
    db "You're harsh..."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$4284, .Bank=$13
    db "Will you take me"
    SCRIPT_NEWLINE
    db "when I'm grown?"
    SCRIPT_WAIT
    db "A promise 'tween"
    SCRIPT_WAIT
    db "men, okay? I'll"
    SCRIPT_NEWLINE
    db "wait till then!"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$429c, .Bank=$13
    db "Okay."
    SCRIPT_NEWLINE
    db "I promise."
    SCRIPT_WAIT
    db "It's a promise"
    SCRIPT_NEWLINE
    db "between men!"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$4284, .Bank=$13
    db "Okay! Now I'll"
    SCRIPT_NEWLINE
    db "practice and"
    SCRIPT_WAIT
    db "become a"
    SCRIPT_NEWLINE
    db "Battle Card"
    SCRIPT_WAIT
    db "Master! I'll"
    SCRIPT_NEWLINE
    db "see you later!"
    SCRIPT_WAIT
    SCRIPT_END
    SCRIPT_RENDERER .Addr=$42b4, .Bank=$13
    db "Whew! I forgot"
    SCRIPT_NEWLINE
    db "just how much"
    SCRIPT_WAIT
    db "fun it was then."
    SCRIPT_NEWLINE
    db "Ah, memories!"
    SCRIPT_WAIT
    db "Thanks, Alf."
    SCRIPT_WAIT
    db "I wonder how"
    SCRIPT_NEWLINE
    db "everyone is."
    SCRIPT_WAIT
    SCRIPT_END
    SCRIPT_RENDERER .Addr=$42cc, .Bank=$13
    db "I know!"
    SCRIPT_WAIT
    db "I'll go see"
    SCRIPT_NEWLINE
    db "old friends!"
    SCRIPT_WAIT
    db "I have to"
    SCRIPT_NEWLINE
    db "refresh myself"
    SCRIPT_WAIT
    db "for Alf, anyway."
    SCRIPT_WAIT
    db "He'll get"
    SCRIPT_NEWLINE
    db "mad if I don't"
    SCRIPT_WAIT
    db "know my way."
    SCRIPT_NEWLINE
    db "Okay, off I go!"
    SCRIPT_WAIT
    SCRIPT_END
    SCRIPT_RENDERER .Addr=$42e4, .Bank=$13
    db "Wait, I forgot."
    SCRIPT_NEWLINE
    db "Withouta note,"
    SCRIPT_WAIT
    db "Nox will get"
    SCRIPT_NEWLINE
    db "mad again."
    SCRIPT_WAIT
    SCRIPT_END
