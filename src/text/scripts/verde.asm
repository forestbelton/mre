; Verde - monster checkroom.
;
; Verde is one of the townspeople who returned from the tower
; (Toamuna's D0DC=3 greeting: "Verde returned. Great! Thank you").
; She introduces herself as "the owner of the checkroom" — monster
; boarding for inactiv
;
;   VerdeEntry       $0614F5  D0E4 cascade; first-time intro is
;                             the long "I am Verde..." monologue
;                             referencing Naji as the referrer.
;
; The tail of the empty-state script ($6251A onward, "What do you
; want to do?" menu) is shared infrastructure also reachable from
; the Verde-present script.
;
; See docs/text_engine.md for the bytecode reference.

INCLUDE "text.inc"

SECTION "Verde script", ROMX

VerdeEntry:
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    SCRIPT_IF_EQ .Addr=wVerdeState, .Value=$04, .Target=VerdeGreetCleared
    SCRIPT_IF_EQ .Addr=wVerdeState, .Value=$03, .Target=VerdeGreetSeen
    SCRIPT_IF_EQ .Addr=wVerdeState, .Value=$01, .Target=VerdeGreet
    SCRIPT_FAR_CALL .Addr=Verde_BuildIntroScene, .Bank=$18
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Oh?"
    SCRIPT_NEWLINE
    db "Never seen you."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Verde_RenderPortraitSurprised, .Bank=$18
    db "What?"
    SCRIPT_NEWLINE
    db "Came to help?"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Hmm... I see."
    SCRIPT_NEWLINE
    db "Naji did, huh?"
    SCRIPT_WAIT
    db "Now, I get it."
    SCRIPT_NEWLINE
    db "You surprised me"
    SCRIPT_WAIT
    db "I am Verde, a"
    SCRIPT_NEWLINE
    db "monster breeder"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Verde_RenderPortraitCalm, .Bank=$18
    db "I am the owner"
    SCRIPT_NEWLINE
    db "of the checkroom"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "I'm here just"
    SCRIPT_NEWLINE
    db "like the others"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Verde_RenderPortraitCalm, .Bank=$18
    db "Made it up here"
    SCRIPT_NEWLINE
    db "with my energy"
    SCRIPT_WAIT
    db "it gets harder"
    SCRIPT_NEWLINE
    db "as I climb up."
    SCRIPT_WAIT
    db "If this goes on"
    SCRIPT_NEWLINE
    db "to the top,"
    SCRIPT_WAIT
    db "I'd be too tired"
    SCRIPT_NEWLINE
    db "for anything."
    SCRIPT_WAIT
    db "So I thought"
    SCRIPT_NEWLINE
    db "of what to do."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "You're amazing,"
    SCRIPT_NEWLINE
    db "here in a flash."
    SCRIPT_WAIT
    db "No wonder Naji"
    SCRIPT_NEWLINE
    db "trusts you."
    SCRIPT_WAIT
    db "So, I say, let's"
    SCRIPT_NEWLINE
    db "help each other"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Verde_RenderPortraitCalm, .Bank=$18
    db "from here on."
    SCRIPT_NEWLINE
    db "But I'd be"
    SCRIPT_WAIT
    db "more trouble"
    SCRIPT_NEWLINE
    db "than help."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Instead, I'll be"
    SCRIPT_NEWLINE
    db "a supporter."
    SCRIPT_WAIT
    db "I'll be cheering"
    SCRIPT_NEWLINE
    db "you on!"
    SCRIPT_WAIT
    db "When you decide"
    SCRIPT_NEWLINE
    db "to come down,"
    SCRIPT_WAIT
    db "come to the"
    SCRIPT_NEWLINE
    db "checkroom."
    SCRIPT_WAIT
    db "I'm sure I can"
    SCRIPT_NEWLINE
    db "help you then."
    SCRIPT_WAIT
    db "Well then,"
    SCRIPT_NEWLINE
    db "Good luck!"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$d0e1, .Value=$01
    SCRIPT_WRITE_WRAM .Addr=wRanchProgress, .Value=$03
    SCRIPT_WRITE_WRAM .Addr=wNajiState, .Value=$02
    SCRIPT_WRITE_WRAM .Addr=wPashuteState, .Value=$02
    SCRIPT_WRITE_WRAM .Addr=wVerdeState, .Value=$01
    SCRIPT_END

VerdeGreet:
    SCRIPT_FAR_CALL .Addr=Verde_BuildPortraitScene, .Bank=$18
    SCRIPT_CYCLE .Count=4
    SCRIPT_JUMP_TABLE wCycleCounter, VerdeGreetA, VerdeGreetB, VerdeGreetC, VerdeGreetD

VerdeGreetA:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Oh, hi!"
    SCRIPT_NEWLINE
    db "How's it going?"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenu

VerdeGreetB:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Hello!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenu

VerdeGreetC:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Welcome!"
    SCRIPT_NEWLINE
    db "I'm glad"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenu

VerdeGreetD:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Welcome!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenu

VerdeGreetSeen:
    SCRIPT_FAR_CALL .Addr=Verde_BuildPortraitScene, .Bank=$18
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "You're here."
    SCRIPT_NEWLINE
    db "I thank you."
    SCRIPT_WAIT
    db "Thanks for"
    SCRIPT_NEWLINE
    db "helping us!"
    SCRIPT_WAIT
    db "This place is"
    SCRIPT_NEWLINE
    db "getting busy!"
    SCRIPT_WAIT
    db "Oh, by the way,"
    SCRIPT_NEWLINE
    db "I hear that, the"
    SCRIPT_WAIT
    db "Stage Studio"
    SCRIPT_NEWLINE
    db "behind the tower"
    SCRIPT_WAIT
    db "is open again."
    SCRIPT_WAIT
    db "You can link or"
    SCRIPT_NEWLINE
    db "exchange with"
    SCRIPT_WAIT
    db "your pals there."
    SCRIPT_WAIT
    db "It'll be fun."
    SCRIPT_NEWLINE
    db "Go try it out!"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wVerdeState, .Value=$01
    SCRIPT_GOTO .Target=VerdeMenu

VerdeGreetCleared:
    SCRIPT_FAR_CALL .Addr=Verde_BuildPortraitScene, .Bank=$18
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Oh!"
    SCRIPT_NEWLINE
    db "You're here!"
    SCRIPT_WAIT
    db "Naji told me"
    SCRIPT_NEWLINE
    db "everything."
    SCRIPT_WAIT
    db "I'm excited"
    SCRIPT_NEWLINE
    db "to take care of"
    SCRIPT_WAIT
    db "Phenix!"
    SCRIPT_WAIT
    db "I'm excited"
    SCRIPT_NEWLINE
    db "as a breeder."
    SCRIPT_WAIT
    db "I'll take good"
    SCRIPT_NEWLINE
    db "care of them,"
    SCRIPT_WAIT
    db "so bring"
    SCRIPT_NEWLINE
    db "more of them."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wVerdeState, .Value=$01
    SCRIPT_GOTO .Target=VerdeMenu

VerdeMenu:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Let's see."
    SCRIPT_NEWLINE
    db "What can I"
    SCRIPT_WAIT
    db "do for you?"
    SCRIPT_FAR_CALL .Addr=Verde_ShowMainMenu, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Verde_LoadBgMap, .Bank=$18
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wMainMenuResult, VerdeRaise, VerdeRelease, VerdeSwitch, VerdeExplain, VerdeLeave

VerdeMenuLoop:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Do you want"
    SCRIPT_NEWLINE
    db "something else?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=ShowYesNoMenu, .Bank=$1f
    SCRIPT_JUMP_TABLE wYNResult, VerdeMenu, VerdeLeave

VerdeRaise:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "OK!"
    SCRIPT_NEWLINE
    db "I'll take care"
    SCRIPT_WAIT
    db "of it!"
    SCRIPT_WAIT
    SCRIPT_IF_EQ .Addr=wDisplayMonster, .Value=$ff, .Target=VerdeRaiseFull
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "OK! It's "
    SCRIPT_INDEXED_STR .Addr=wDisplayMonster
    db "."
    SCRIPT_NEWLINE
    db "I got it."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wDisplayMonster, .Value=$ff
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeRaiseFull:
    db "Hm? Looks like"
    SCRIPT_NEWLINE
    db "no monsters here"
    SCRIPT_WAIT
    db "You have to"
    SCRIPT_NEWLINE
    db "have a monster,"
    SCRIPT_WAIT
    db "to leave at"
    SCRIPT_NEWLINE
    db "the checkroom."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeRelease:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "OK!"
    SCRIPT_NEWLINE
    db "You'll take"
    SCRIPT_WAIT
    db "a monster!"
    SCRIPT_WAIT
    db "Wait a minute."
    SCRIPT_NEWLINE
    db "Your monster is?"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=CountCheckedInMonsters, .Bank=$18
    SCRIPT_IF_NEQ .Addr=wYNResult, .Value=$00, .Target=VerdeReleaseYes
    SCRIPT_RENDERER .Addr=Verde_RenderPortraitCalm, .Bank=$18
    db "Oh yes,"
    SCRIPT_NEWLINE
    db "I have it here."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeReleaseYes:
    SCRIPT_IF_NEQ .Addr=wYNResult, .Value=$01, .Target=VerdeReleasePick
    db "Yes! It's "
    SCRIPT_INDEXED_STR .Addr=$cfbb
    db "."
    SCRIPT_NEWLINE
    db "I have it here."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeReleaseThis

VerdeReleasePick:
    db "Oh yes,"
    SCRIPT_NEWLINE
    db "I have it here."
    SCRIPT_WAIT
    db "So, which one"
    SCRIPT_NEWLINE
    db "are you taking?"
    SCRIPT_FAR_CALL .Addr=Verde_ShowReleaseMonsterSelect, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Verde_LoadBgMap, .Bank=$18
    SCRIPT_ANCHOR
    SCRIPT_IF_EQ .Addr=$cfbb, .Value=$07, .Target=VerdeMenuLoop

VerdeReleaseThis:
    db "This one, right?"
    SCRIPT_NEWLINE
    db "It's healthy!"
    SCRIPT_WAIT
    db "Take good care"
    SCRIPT_NEWLINE
    db "of it, okay?"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=Pashute_SetReplaceTargetActive, .Bank=$18
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeSwitch:
    SCRIPT_FAR_CALL .Addr=CountCheckedInMonsters, .Bank=$18
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=VerdeSwitchDone
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "OK! Switch of"
    SCRIPT_NEWLINE
    db "monsters, right?"
    SCRIPT_WAIT
    db "Okay, choose the"
    SCRIPT_NEWLINE
    db "next monster"
    SCRIPT_FAR_CALL .Addr=Verde_ShowReleaseMonsterSelect, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Verde_LoadBgMap, .Bank=$18
    SCRIPT_ANCHOR
    SCRIPT_IF_EQ .Addr=$cfbb, .Value=$07, .Target=VerdeMenuLoop
    SCRIPT_GOTO .Target=VerdeReleaseThis

VerdeSwitchDone:
    SCRIPT_RENDERER .Addr=Verde_RenderPortraitCalm, .Bank=$18
    db "Well."
    SCRIPT_NEWLINE
    db "What?"
    SCRIPT_WAIT
    db "I can't exchange"
    SCRIPT_NEWLINE
    db "monsters if you"
    SCRIPT_WAIT
    db "don't have one"
    SCRIPT_NEWLINE
    db "checked in."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeExplain:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Let me explain."
    SCRIPT_WAIT
    db "This checkroom"
    SCRIPT_NEWLINE
    db "is a great place"
    SCRIPT_WAIT
    db "to hold monsters"
    SCRIPT_NEWLINE
    db "regenerated from"
    SCRIPT_WAIT
    db "a saucer stone!"
    SCRIPT_WAIT
    db "If you want to"
    SCRIPT_NEWLINE
    db "carry more than"
    SCRIPT_WAIT
    db "one monster,"
    SCRIPT_NEWLINE
    db "this will help"
    SCRIPT_WAIT
    db "you a lot!"
    SCRIPT_WAIT
    db "I'll keep"
    SCRIPT_NEWLINE
    db "the monsters"
    SCRIPT_WAIT
    db "in good shape"
    SCRIPT_NEWLINE
    db "because I'm a"
    SCRIPT_WAIT
    db "top breeder!"
    SCRIPT_WAIT
    db "That's all."
    SCRIPT_NEWLINE
    db "It's simple."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeLeave:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "OK!"
    SCRIPT_NEWLINE
    db "That's it."
    SCRIPT_WAIT
    db "I'll take care"
    SCRIPT_NEWLINE
    db "of the monsters."
    SCRIPT_WAIT
    db "Good luck!"
    SCRIPT_WAIT
    SCRIPT_END
