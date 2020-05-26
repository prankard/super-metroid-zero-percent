arch snes.cpu
lorom

;;; **************
;;; Macros
;;; **************

macro plm_chozo(gfx, collect_code, draw_code)
{
   ?plm_chozo:
   ;;; $E8D7: Instruction list - PLM $EF7B (reserve tank, chozo orb) ;;;
   {
      <gfx>                                          ; Load item PLM GFX
      dw $887C,?plm_chozo_collected                 ; Go to $E90B if the room argument item is set
      dw $8A2E,$DFAF                                       ; Call $DFAF (item orb)
      dw $8A2E,$DFC7                                       ; Call $DFC7 (item orb burst)
      dw $8A24,?plm_chozo_collide                   ; Link instruction = plm_reserve_chozo_collide
      dw $86C1,$DF89                                       ; Pre-instruction = go to link instruction if triggered
      dw $874E : db $16                                    ; Timer = 16h
   ?plm_chozo_draw:
      ;dw $E04F                               ; Draw item frame 0
      ;dw $E067                               ; Draw item frame 1
      dw $0104,$A31B  ; draw old empty block
      dw $8724,?plm_chozo_draw        ; Go to plm_reserve_chozo_draw
   ?plm_chozo_collide:
      dw $8899                               ; Set the room argument item
      ;dw $E04F                               ; Draw item frame 0
      <draw_code>
      dw $8BDD : db $02                      ; Clear music queue and queue item fanfare music track
      <collect_code>
   ?plm_chozo_collected:
      dw $8724,draw_orb                      ; goto draw orb
      ;dw $0001,$A2B5                        ; draw blank frame (or frame in memory)
      ;dw $86BC                               ; Delete
   }
}
endmacro

macro plm_shot(frame, collect_code)
{
   ?plm_shot:
   {
      dw $8A2E,$E007  ; Call $E007 (item shot block)
      dw $887C,?plm_shot_collected  ; Go to $E979 if the room argument item is set
      dw $8A24,?plm_shot_collide  ; Link instruction = $E970
      dw $86C1,$DF89  ; Pre-instruction = go to link instruction if triggered
      dw $874E : db $16    ; Timer = 16h
   ?plm_shot_draw:
      dw $0004,$A31B  ; draw old empty block
      ;dw $0004,$A2EB ; old draw code frame 1
      ;dw $0004,$A2F1 ; old draw code frame 2
      dw $873F,?plm_shot_draw  ; Decrement timer and go to $E95C if non-zero
      dw $8A2E,$E020  ; Call $E020 (item shot block reconcealing)
      dw $8724,?plm_shot  ; Go to $E949
   ?plm_shot_collide:
      dw $8899       ; Set the room argument item
      dw $8BDD : db $02    ; Clear music queue and queue item fanfare music track
      <collect_code>
   ?plm_shot_collected:
      dw $000F,<frame> ; draw first frame of real item
      dw $8A2E,$E020  ; Call $E020 (item shot block reconcealing)
      ;dw $8A2E,$E032  ; Call $E032 (empty item shot block reconcealing)
      dw $8724,?plm_shot  ; Go to $E949 
   }
}
endmacro

;;; **************
;;; Defines
;;; **************

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


;;; **************
;;; Bank 84
;;; **************

;; Stop missile hud from doing nothing at zero
;org $8099DF
;   JMP $8099E1

;;; **************
;;; Unequip/Minus when collected
;;; **************

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

; grapple
org $84891D
   EOR $0000,y 
org $848926
   EOR $0000,y
org $84892C
   JMP collect_grapple

; xray 
org $848944
   EOR $0000,y 
org $84894D
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

   
;;; **************
;;; Unequip/Minus when collected
;;; **************

   ;test e tank graphics

; [-] not tested
; [o] part done
; [x] done 
   
;     Item        	NormalHiddenChozo
; [-] Morph Ball	   Yes	No	   No
; [x] Bomb	         No	   No	   Yes <- we can't modify bomb
; [x] Charge Beam	   No	   No	   Yes
; [x] Spazer         No	   No	   Yes
; [-] Varia Suit	   No	   No	   Yes
; [x] Hi-Jump Boots	No	   No	   Yes
; [x] Speed Booster	No	   No	   Yes
; [x] Wave Beam	   No	   No	   Yes
; [-] Grapple Beam	No	   No	   Yes
; [-] Gravity Suit	No	   No	   Yes
; [-] Space Jump	   No	   No	   Yes
; [-] Spring Ball	   No	   No	   Yes
; [-] Plasma Beam	   No	   No	   Yes
; [-] Ice Beam	      No	   No	   Yes
; [x] Screw Attack	No	   No	   Yes
; [-] X-Ray Scope 	No	   No	   Yes
; [x] Missile	      #Yes	#Yes	#Yes
; [-] Super Missile	#Yes	#Yes	#Yes
; [x] Power Bomb	   Yes	No	   Yes
; [-] Energy Tank	   #Yes	#Yes	No
; [x] Reserve Tank	No 	No    Yes


macro plm(gfx, collect_code, draw_code)
{
?plm:
   <gfx>
   dw $887C,?plm_collected;,$E0BA  ; Go to $E0BA if the room argument item is set
   dw $8A24,?plm_collide  ; Link instruction = plm_etank_collide
   dw $86C1,$DF89  ; Pre-instruction = go to link instruction if triggered
?plm_draw:
   ;dw $0008,$A2B5   ; draw empty block
   dw $0104,$A31B  ; draw old empty block
   dw $8724,?plm_draw ; goto plm_etank_draw
?plm_collide:
   dw $8899       ; Set the room argument item
   dw $8BDD : db $02    ; Clear music queue and queue item fanfare music track
   <collect_code>
?plm_collected:
   <draw_code>
}
endmacro

   
org $84E099
;;; $E099: Instruction list - PLM $EED7 (energy tank) ;;;
%plm("", "dw $8968,$0064", "dw $8724,draw_etank")

org $84E0BE
;;; $E0BE: Instruction list - PLM $EEDB (missile tank) ;;;
%plm("", "dw $89A9,$0005", "dw $8724,draw_missile")

org $84E0E3 
;;; $E0E3: Instruction list - PLM $EEDF (super missile tank) ;;;
%plm("", "dw $89D2,$0005", "dw $8724,draw_supers")

org $84E108
;;; $E108: Instruction list - PLM $EEE3 (power bomb tank) ;;;
%plm("", "dw $89FB,$0005", "dw $8724,draw_pb")

org $84E3EF
;;; $E3EF: Instruction list - PLM $EF23 (morph ball) ;;;
%plm("dw $8764,$8700 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$0004 : db $09", "dw $8724,draw_plm_sprites")

; this speed booster not needed
;org $84E1E5
;;; $E1E5: Instruction list - PLM $EEF7 (speed booster) ;;;
;%plm("dw $8764,$8A00 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$2000 : db $0D", "dw $8724,draw_plm_sprites")

;; orbs to go here


org $84E47C
;;; $E47C: Instruction list - PLM $EF2F (missile tank, chozo orb) ;;;
%plm_chozo("", "dw $89A9,$0005", "dw $0004,$A2EB")

org $84E4AE
;;; $E4AE: Instruction list - PLM $EF33 (super missile tank, chozo orb) ;;;
%plm_chozo("", "dw $89D2,$0005", "dw $0004,$A2F7")

org $84E4E0
;;; $E4E0: Instruction list - PLM $EF37 (power bomb tank, chozo orb) ;;;
%plm_chozo("", "dw $89FB,$0005", "dw $0004,$A303")

org $84E54D
;;; $E54D: Instruction list - PLM $EF3F (charge beam, chozo orb) ;;;
%plm_chozo("dw $8764,$8B00 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88B0,$1000 : db $0E", "dw $E04F")

org $84E588
;; $E588: Instruction list - PLM $EF43 (ice beam, chozo orb) ;;;
%plm_chozo("dw $8764,$8C00 : db $00,$03,$00,$00,$00,$03,$00,$00", "dw $88B0,$0002 : db $0F", "dw $E04F")

org $84E5C3
;;; $E5C3: Instruction list - PLM $EF47 (hi-jump, chozo orb) ;;;
%plm_chozo("dw $8764,$8400 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$0100 : db $0B", "dw $E04F")

org $84E5FE
;;; $E5FE: Instruction list - PLM $EF4B (speed booster, chozo orb) ;;;
%plm_chozo("dw $8764,$8A00 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$2000 : db $0D", "dw $E04F")

org $84E642
;;; $E642: Instruction list - PLM $EF4F (wave beam, chozo orb) ;;;
%plm_chozo("dw $8764,$8D00 : db $00,$02,$00,$00,$00,$02,$00,$00", "dw $88B0,$0001 : db $10", "dw $E04F")

org $84E67D
;;; $E67D: Instruction list - PLM $EF53 (spazer beam, chozo orb) ;;;
%plm_chozo("dw $8764,$8F00 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88B0,$0004 : db $11", "dw $E04F")

org $84E6B8
;;; $E6B8: Instruction list - PLM $EF57 (spring ball, chozo orb) ;;;
%plm_chozo("dw $8764,$8200 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$0002 : db $08", "dw $E04F")

org $84E6F3
;;; $E6F3: Instruction list - PLM $EF5B (varia suit, chozo orb) ;;;
%plm_chozo("dw $8764,$8300 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$0001 : db $07", "dw $E04F")

org $84E735
;;; $E735: Instruction list - PLM $EF5F (gravity suit, chozo orb) ;;;
%plm_chozo("dw $8764,$8100 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$0020 : db $1A", "dw $E04F")

org $84E777                        
;;; $E777: Instruction list - PLM $EF63 (x-ray scope, chozo orb) ;;;
%plm_chozo("dw $8764,$8900 : db $01,$01,$00,$00,$03,$03,$00,$00", "dw $8941,$8000", "dw $E04F")

org $84E7B1                        
;;; $E7B1: Instruction list - PLM $EF67 (plasma beam, chozo orb) ;;;
%plm_chozo("dw $8764,$8E00 : db $00,$01,$00,$00,$00,$01,$00,$00", "dw $88B0,$0008 : db $12", "dw $E04F")

org $84E7EC                        
;;; $E7EC: Instruction list - PLM $EF6B (grapple beam, chozo orb) ;;;
%plm_chozo("dw $8764,$8800 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $891A,$4000", "dw $E04F")

org $84E826
;;; $E826: Instruction list - PLM $EF6F (space jump, chozo orb) ;;;
%plm_chozo("dw $8764,$8600 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$0200 : db $0C", "dw $E04F")
         
org $84E861               
;;; $E861: Instruction list - PLM $EF73 (screw attack, chozo orb) ;;;
%plm_chozo("dw $8764,$8500 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$0008 : db $0A", "dw $E04F")
                        
org $84E8D7
;;; $E8D7: Instruction list - PLM $EF7B (reserve tank, chozo orb) ;;;
%plm_chozo("dw $8764,$9000 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $8986,$0064", "dw $E04F")


;;; Shot Blocks

org $84E911
;;; $E911: Instruction list - PLM $EF7F (energy tank, shot block) ;;;
%plm_shot($A2DF, "dw $8968,$0064")

org $84E949
;;; $E949: Instruction list - PLM $EF83 (missile tank, shot block) ;;;
%plm_shot($A2EB, "dw $89A9,$0005")

org $84E981
;;; $E981: Instruction list - PLM $EF87 (super missile tank, shot block) ;;;
%plm_shot($A2F7, "dw $89D2,$0005")

   ; sprite locations
;etank:
;a2df = 41695
;a2e5 = 41701
;missile:
;a2eb = 41707
;a2f1 = 41713
;super:
;a2f7 = 41719
;a2fd = 41725
;pb:
;a303 = 41731
;a309 = 41737

; empty sprite
;A2B5

;   dw $8724,$DFA9  ; Go to $DFA9 - delete


;;; **************
;;; Free Space Functions/Jumps
;;; **************
; Free space bank 84:EFD3-FFFF

org $84EFD3 
draw_plm_sprites:
   dw $E04F                               ; Draw item frame 0
   dw $E067                               ; Draw item frame 1
   dw $8724,draw_plm_sprites              ; Go to draw_plm_graphic

draw_orb:
   dw $0014,$A2C7
   dw $000A,$A2CD
   dw $0014,$A2D3
   dw $000A,$A2CD
   dw $8724,draw_orb   ; Go to draw_orb

draw_etank:
   ;dw $8724,test_draw_plm_sprites ; temp jump to draw sprites
   dw $0004,$A2DF  ; draw frame 1
   dw $0004,$A2E5  ; draw frame 1
   dw $8724,draw_etank;,$E0BA  ; Go to plm_etank_collected

draw_missile:
   dw $0004,$A2EB
   dw $0004,$A2F1
   dw $8724,draw_missile  ; Go to draw_missile

draw_supers:
   dw $0004,$A2F7
   dw $0004,$A2FD
   dw $8724,draw_supers  ; Go to draw_super_missile

draw_pb:
   dw $0004,$A303
   dw $0004,$A309
   dw $8724,draw_pb  ; Go to draw_pb

test_draw_plm_sprites:
   dw $001F,$A2D9   ; draw x
   dw $001F,$A2D3   ; draw x
   dw $001F,$A2CD   ; draw x
   dw $001F,$A2C7   ; draw x
   dw $001F,$A2C1   ; draw x
   dw $001F,$A2BB   ; draw x
   dw $001F,$A2B5   ; draw x
   
   dw $001F,$A2D9   ; draw x
   dw $001F,$A2DF   ; draw x
   dw $001F,$A2E5   ; draw x
   dw $001F,$A2EB   ; draw x
   dw $001F,$A2F1   ; draw x
   dw $001F,$A2F7   ; draw x
   dw $001F,$A2FD   ; draw x
   dw $001F,$A303   ; draw x
   dw $001F,$A309   ; draw x

      dw $001F,$A30F   ; draw x
   dw $001F,$A315   ; draw x
   dw $001F,$A31B   ; draw x
   dw $001F,$A321   ; draw x
   dw $001F,$A327   ; draw x
   dw $001F,$A32D   ; draw x
   dw $001F,$A333   ; draw x
   dw $001F,$A339   ; draw x
   dw $001F,$A33F   ; draw x
   dw $001F,$A345   ; draw x
   
   dw $001F,$A34B   ; draw x
   dw $001F,$A351   ; draw x
   dw $001F,$A357   ; draw x
   dw $001F,$A35D   ; draw x
   dw $001F,$A363   ; draw x
   dw $001F,$A369   ; draw x
   dw $001F,$A36F   ; draw x
   dw $001F,$A375   ; draw x
   dw $001F,$A37B   ; draw x
   dw $001F,$A381   ; draw x
   dw $001F,$A387   ; draw x
   dw $001F,$A38D   ; draw x
   dw $001F,$A393   ; draw x
   dw $001F,$A399   ; draw x
   dw $001F,$A39F   ; draw x
   dw $001F,$A3A5   ; draw x
   dw $001F,$A3AB   ; draw x
   dw $001F,$A3B1   ; draw x
   dw $001F,$A3B7   ; draw x
   dw $001F,$A3BD   ; draw x

;   dw $001F,$A2AF   ; draw x
;   dw $001F,$A2A9   ; draw x
;   dw $001F,$A2A3   ; draw x
;   dw $001F,$A29D   ; draw x
;   dw $001F,$A297   ; draw x
;   dw $001F,$A291   ; draw x
;   dw $001F,$A28B   ; draw x
;   dw $001F,$A285   ; draw x
;   dw $001F,$A27F   ; draw x
;                        dw $E04F                               ; Draw item frame 0
;                        dw $E067                               ; Draw item frame 1
                        dw $8724,test_draw_plm_sprites                          ; Go to $DFA97

decrease_health:
   LDA $09C4 ;  [$7E:09C4]  ;\
   SEC                    ;|
   SBC $0000,y ; [$84:E93F]  ;} Samus' max health += [[Y]]
   STA $09C4   ; [$7E:09C4]  ;/
   SBC $09C2
   BPL dont_decrease_current_health
   LDA $09C4
   STA $09C2
dont_decrease_current_health:

;   STA $09C2  ; [$7E:09C2]  ; Samus' health = [Samus' max health]
   JSR check_all_items
   LDA #$0168             ;\
   JSL $82E118 ; [$82:E118]  ;} Play room music track after 6 seconds
   LDA #$0001             ;\
   JSL $858080 ; [$85:8080]  ;} Display energy tank message box
   ;JSL $809A79 ; init hud again for health ;; this almost works



   JSL clear_energy_hud
   STZ $0A06 ; force previous health to be 0, to force redraw

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
   ;JMP check_all_success ; test success
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

clear_auto_reserve:
{
   PHP
   PHX
   PHY
   PHB
   PHK                ;\
   PLB                ;} DB = $80
   REP #$30           
   LDA #$2C0F
   
   STA $7EC618;[$7E:C666];/ 8308248
   STA $7EC61A;[$7E:C666];/

   STA $7EC658;[$7E:C666];/ 8308312
   STA $7EC65A;[$7E:C666];/
   
   STA $7EC698;[$7E:C666];/ 8308376
   STA $7EC69A;[$7E:C666];/

   PLB
   PLY
   PLX
   PLP
   RTS
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
   LDA $09D6
;   CMP #$0000
   BNE not_last_reserve
   STZ $09C0               ; set to manual reserve
   JSR clear_auto_reserve  ; clear the auto-reserve arrow
   not_last_reserve:
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

;;; **************
;;; Misc Hacks
;;; **************

; skip gravity animation
org $91D5BA 
   RTL
org $91D4E4 
   RTL

; force 0% credits
org $8BE634 
   JMP $E67D