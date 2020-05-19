arch snes.cpu
lorom

;; Code in bank 81 newgame
org $81B2CD
   JMP $EF1A

org $81EF1A
new_heath:
   LDA #$05DB             ;\
   STA $09C4 ; [$7E:09C4]  ;} Health
   STA $09C2  ; [$7E:09C2]  ;/
   LDA #$00E6             ;\  00E6   =  230  000A = 10
   STA $09C8 ; [$7E:09C8]  ;} Missiles
   STA $09C6 ; [$7E:09C6]  ;/
   LDA #$0032             ;\
   STA $09CC ; [$7E:09CC]  ;} Super missiles
   STA $09CA ; [$7E:09CA]  ;/
   LDA #$0032             ;\
   STA $09D0 ; [$7E:09D0]  ;} Power bombs
   STA $09CE ; [$7E:09CE]  ;/
   STZ $09D2 ; [$7E:09D2]  ; Currently selected HUD item
   LDA #$100F ; 1000000001111
   STA $09A8 ; set beams
   LDA #$100B ; 1000000001011 - not spazer
   STA $09A6 ; set beams
   LDA #$F32F ; collected items ; 1111001100101111
   STA $09A4 ; set items
   LDA #$F32F ; equited items
   STA $09A2 ; set items
   LDA #$0190
   STA $09D4 ; set reserve
   STA $09D6 ; set reserve
   ; toggle zebes awake
   LDA $7ED820    ;
   ORA #$0001   ;
   STA $7ED820    ;
   JMP $B30C ; back to new save file after ammo


; Free space in 81:EF1A -> 81:FF00
; Free space in 81:FF60 -> 81:FFFF