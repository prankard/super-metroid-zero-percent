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

; equipment
org $8488F6
   EOR $0000,y 
org $8488FF
   EOR $0000,y
org $848905
   JMP collect_equipment

; grapple (need to remove from tilemap)
org $84891D
   EOR $0000,y 
org $848926
   EOR $0000,y
org $84892C
   JMP collect_grapple

; xray (need to remove from tilemap)
org $848944
   EOR $0000,y 
org $848926
   EOR $0000,y
org $848953
   JMP collect_xray

; Minus Health
org $848968
   JMP decrease_health

; energy reserve
org $848986 
   JMP decrease_reserve

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

; skip gravity animation
org $91D5BA 
   RTL
org $91D4E4 
   RTL

; force 0% credits
org $8BE634 
   JMP $E67D


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




   JSL clear_energy_hud

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
   LDA #$0001 ; x-ray selected index
   JSR deselect_if_current_item
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
   LDA #$0002 ; x-ray selected index
   JSR deselect_if_current_item
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
   LDA #$0003 ; x-ray selected index
   JSR deselect_if_current_item
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
   JMP check_all_success ; test success
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

collect_equipment:
   JSR check_all_items
   LDA #$0168 ; load music track
   JMP $8908

collect_grapple:
   JSL clear_graple_hud
   JSR check_all_items
   LDA #$0004 ; grapple selected index
   JSR deselect_if_current_item
   JMP $8930

collect_xray:
   JSL clear_xray_hud
   JSR check_all_items
   LDA #$0005 ; x-ray selected index
   JSR deselect_if_current_item
   JMP $8957

;;; $9A3E: Add x-ray to HUD tilemap ;;;
{
   ; Called by:
   ;     $9A79: Initialise HUD
   ;     $84:8941: Instruction - pick up equipment [[Y]], add x-ray to HUD and display x-ray message box
   ;     $91:E355: Debug. Give ammo, all items and switch to next beam configuration if newly pressed B
   PHP
   PHX
   PHY
   PHB
   PHK                ;\
   PLB                ;} DB = $80
   REP #$30           
   LDY #$99C7         ; Y = x-ray HUD tilemap source address
   LDX #$002E         ; X = x-ray HUD tilemap destination offset
}

clear_energy_hud:
{
   PHP
   PHX
   PHY
   PHB
   PHK                ;\
   PLB                ;} DB = $80
   REP #$30           
   LDA #$2C0F
   
   STA $7EC64A;[$7E:C666];/
   STA $7EC64C;[$7E:C666];/
   STA $7EC64E;[$7E:C666];/
   STA $7EC650;[$7E:C666];/
   STA $7EC652;[$7E:C666];/
   STA $7EC654;[$7E:C666];/
   STA $7EC656;[$7E:C666];/

   STA $7EC60A;[$7E:C666];/
   STA $7EC60C;[$7E:C666];/
   STA $7EC60E;[$7E:C666];/
   STA $7EC610;[$7E:C666];/
   STA $7EC612;[$7E:C666];/
   STA $7EC614;[$7E:C666];/
   STA $7EC616;[$7E:C666];/

   PLB
   PLY
   PLX
   PLP
   RTL
}

;;; $9A2E: Add grapple to HUD tilemap ;;;
clear_graple_hud:
{
; Called by:
;     $9A79: Initialise HUD
;     $84:891A: Instruction - pick up equipment [[Y]], add grapple to HUD and display grapple message box
;     $91:E355: Debug. Give ammo, all items and switch to next beam configuration if newly pressed B
   PHP
   PHX
   PHY
   PHB
   PHK                ;\
   PLB                ;} DB = $80
   REP #$30           
   LDX #$0028         ; X = grapple HUD tilemap destination offset
   BRA clear_2x2_tile    ;[$9A4C] ; Write 2x2 tile icon to HUD tilemap
}


;;; $9A3E: Add x-ray to HUD tilemap ;;;
clear_xray_hud:
{
   ; Called by:
   ;     $9A79: Initialise HUD
   ;     $84:8941: Instruction - pick up equipment [[Y]], add x-ray to HUD and display x-ray message box
   ;     $91:E355: Debug. Give ammo, all items and switch to next beam configuration if newly pressed B
   PHP
   PHX
   PHY
   PHB
   PHK                ;\
   PLB                ;} DB = $80
   REP #$30           
   LDX #$002E         ; X = x-ray HUD tilemap destination offset
}


;;; $9A4C: Write 2x2 tile icon to HUD tilemap ;;;
clear_2x2_tile:
{
   ;; Parameters:
   ;;     X: HUD tilemap index

   ; Called by:
   ;     $9A0E with X = 1Ch, Y = $99AF: Add super missiles to HUD tilemap
   ;     $9A1E with X = 22h, Y = $99B7: Add power bombs to HUD tilemap
   ;     $9A2E with X = 28h, Y = $99BF: Add grapple to HUD tilemap
   ;     $9A3E with X = 2Eh, Y = $99C7: Add x-ray to HUD tilemap
   LDA #$2C0F
   STA $7EC608,x;[$7E:C624];|
   STA $7EC60A,x;[$7E:C626];/
   STA $7EC648,x;[$7E:C664];|
   STA $7EC64A,x;[$7E:C666];/

   PLB
   PLY
   PLX
   PLP
   RTL
}

decrease_reserve:
;;; $8986: Instruction - collect [[Y]] health reserve tank ;;;
{
LDA $09D4  ;[$7E:09D4]  ;\
SEC                    ;|
SBC $0000,y;[$84:E909]  ;} Samus' reserve energy += [[Y]]
STA $09D4  ;[$7E:09D4]  ;/
SEC
SBC $09D6
BPL after_max_reserve  ;} reserve too low
LDA $09D4              ;\ 
STA $09D6              ;} Save reseve as max
after_max_reserve:
LDA #$0168             ;\
JSL $82E118;[$82:E118]  ;} Play room music track after 6 seconds
LDA #$0019             ;\
JSL $858080;[$85:8080]  ;} Display reserve tank message box
JSR check_all_items
INY                    ;\
INY                    ;} Y += 2
RTS
}

deselect_if_current_item:
;;; Instruction - check if selected item [[X]] then deselect if it is ;;;
{
   CMP $7E09D2
   BNE not_same_item ; if not goto after
   STZ $09D2    ; clear selected item
   not_same_item:
   RTS
}

