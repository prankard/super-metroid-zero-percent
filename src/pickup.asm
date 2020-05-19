arch snes.cpu
lorom

; defines
!max_missiles = $09C8
!missiles = $09C6
!max_supers = $09CC
!supers = $09CA
!max_power_bombs = $09D0 
!power_bombs = $09CE
!power_bombs = $09CE

!items = $09A2  
!selected_items = $09A4
!beams = $09A8
!selected_beams = $09A6
!max_health = $09C4
!health = $09C2



;; Code in bank 84

;; flip plm enable disabled
;org $84861A
;   JSR $8DAA ; draw
   ;JMP $861D ; jmp to end ;


;; Stop missile hud from doing nothing at zero
;org $8099DF
;   JMP $8099E1

; beams
org $8488B3
   EOR $09A8
org $8488BC
   EOR $09A6

org $8488B0
   JMP pickup_beam_set_spazer_plasma

; temp stop plasma/spazer swap when equip
org $8488C2
   JMP $88D6

; equiptment
org $8488F6
   EOR $0000,y 
org $8488FF
   EOR $0000,y

; grapple (need to remove from tilemap)
org $84891D
   EOR $0000,y 
org $848926
   EOR $0000,y

; xray (need to remove from tilemap)
org $848944
   EOR $0000,y 
org $848926
   EOR $0000,y

; Minus Health
org $848968
   JMP $EFD3

; energy reserve
org $848989
   SEC
   SBC $0000,y

; missile minus max
org $8489AC
   SEC
   SBC $0000,y

; check missile not above max
org $8489B3
   JMP check_missiles

; super
org $8489D5
   SEC
   SBC $0000,y

; check supers not above max
org $8489DC
   JMP check_supers

; power bombs
org $8489FE
   SEC
   SBC $0000,y

; check missile not above max
org $848A05
   JMP check_power_bombs


; Free space bank 84:EFD3-FFFF
org $84EFD3 
decrease_health:
   LDA $09C4 ;  [$7E:09C4]  ;\
   SEC                    ;|
   SBC $0000,y ; [$84:E93F]  ;} Samus' max health += [[Y]]
   STA $09C4   ; [$7E:09C4]  ;/
   STA $09C2  ; [$7E:09C2]  ; Samus' health = [Samus' max health]
   JSR check_all_items
   LDA #$0168             ;\
   JSL $82E118 ; [$82:E118]  ;} Play room music track after 6 seconds
   LDA #$0001             ;\
   JSL $858080 ; [$85:8080]  ;} Display energy tank message box
   ;JSL $809A79 ; init hud again for health ;; this almost works
   INY                    ;\
   INY                    ;} Y += 2
   RTS

check_missiles:
   SEC
   SBC !missiles ; minus missiles from max missiles
   BPL load_missiles_and_return ; jump if positive back
   LDA !max_missiles ; load max missiles
   STA !missiles ; set max to missiles 
load_missiles_and_return:
   JSR check_all_items
   LDA !missiles ; load max missiles
   JMP $89BD ; go back

check_supers:
   SEC
   SBC !supers ; minus supers from max supers
   BPL load_supers_and_return ; jump if positive back
   LDA !max_supers ; load max supers
   STA !supers ; set max 
load_supers_and_return:
   JSR check_all_items
   LDA !supers ; load supers
   JMP $89E6 ; go back

check_power_bombs:
   SEC
   SBC !power_bombs ; minus supers from max supers
   BPL load_power_bombs_and_return ; jump if positive back
   LDA !max_power_bombs ; load max supers
   STA !power_bombs ; set max 
load_power_bombs_and_return:
   JSR check_all_items
   LDA !power_bombs ; load supers
   JMP $8A0F ; go back

pickup_beam_set_spazer_plasma:
   LDA $0000,y; [$84:E57F]  ;\
   EOR $09A8  ;[$7E:09A8]  ;} Collected beams ^= [[Y]]
   STA $09A8  ;[$7E:09A8]  ;/
   AND $09A6  ;[$7E:09A6]  ;} Equipped beams ^= [[Y]]
   STA $09A6  ;[$7E:09A6]  ;/
   JSR check_all_items
   JMP $88D6                ; jump back
   ; todo, toggle plazma when unquip spazer
   ; todo, toggle spazer when unquipt plasma

check_all_items:
   ;JMP check_all_success
   LDA !max_missiles
   BNE check_all_failed
   LDA !max_supers
   BNE check_all_failed
   LDA !max_power_bombs
   BNE check_all_failed
   LDA !items
   BNE check_all_failed
   LDA !beams
   BNE check_all_failed
   LDA !max_health
   CMP #$0063
   BNE check_all_failed
check_all_success:
   LDA $7ED820
   ORA #$4000  ; set zebes exploding
   STA $7ED820
check_all_failed:
   RTS

   