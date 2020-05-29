arch snes.cpu
lorom

;;; **************
;;; Defines
;;; **************

!max_missiles = $09C8
!missiles = $09C6
!max_supers = $09CC
!supers = $09CA
!max_power_bombs = $09D0 
!power_bombs = $09CE

!items = $09A2  
!selected_items = $09A4
!beams = $09A8
!selected_beams = $09A6
!max_health = $09C4
!health = $09C2
!music_wait = #$001E ; wait for 0.5 second, not 6 seconds

;;; **************
;;; Macros
;;; **************

macro plm(gfx, collect_code, uncollect_code, draw_code)
{
?plm:
   <gfx>
   dw $8A24,?plm_collide  ; Link instruction = plm_etank_collide
   dw $86C1,$DF89  ; Pre-instruction = go to link instruction if triggered
   dw $887C,?plm_draw_full;,$E0BA  ; Go to $E0BA if the room argument item is set
?plm_draw_empty:
   dw $0104,$A31B  ; draw old empty block
   dw $8724,?plm_draw_empty ; goto plm_etank_draw
?plm_draw_full:
   <draw_code>
   dw $8724,?plm_draw_full ; goto plm_etank_draw
?plm_collide:
   dw $887C,?plm_check_pressed;,$E0BA  ; Go to $E0BA if the room argument item is set
?plm_collect:
   dw $8899       ; Set the room argument item
   <collect_code>
   dw $8724,?plm_draw_full ; goto plm_etank_draw
   ;dw $8BDD : db $02    ; Clear music queue and queue item fanfare music track
?plm_check_pressed:
   dw if_select_not_held, ?plm_draw_full
?plm_uncollect:
   dw unset_room_item
   <uncollect_code>
   dw $8724,?plm_draw_empty ; goto plm_etank_draw
}
endmacro

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
      ;dw $8BDD : db $02                      ; Clear music queue and queue item fanfare music track
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
      ; dw $8BDD : db $02    ; Clear music queue and queue item fanfare music track
      <collect_code>
   ?plm_shot_collected:
      dw $000F,<frame> ; draw first frame of real item
      dw $8A2E,$E020  ; Call $E020 (item shot block reconcealing)
      ;dw $8A2E,$E032  ; Call $E032 (empty item shot block reconcealing)
      dw $8724,?plm_shot  ; Go to $E949 
   }
}
endmacro

macro add_ammo(ammo, max_ammo, add_hud_code, message_id)
{
   LDA <max_ammo>  ;[$7E:09C8]  ;\
   CLC                     ;|
   ADC $0000,y;[$84:E4A6]  ;} Samus' max missiles += [[Y]]
   STA <max_ammo>  ;[$7E:09C8]  ;/
   LDA <ammo>  ;[$7E:09C6]  ;\
   ;CLC                     ;|
   ;ADC $0000,y;[$84:E4A6]  ;} Samus' missiles += [[Y]]
   ;STA $09C6  ;[$7E:09C6]  ;/
   <add_hud_code>           ; JSL $8099CF ;  Add missiles to HUD tilemap
   ;LDA #$0168              ;\
   ;JSL $82E118[$82:E118]  ;} Play room music track after 6 seconds
   LDA <message_id>              ;\
   JSL $858080;[$85:8080]  ;} Display missile tank message box
   INY                     ;\
   INY                     ;} Y += 2
   RTS
}
endmacro

macro remove_ammo(ammo, max_ammo, add_hud_code, check_function, message_id)
{
   LDA <max_ammo>  ;[$7E:09C8]  ;\
   SEC                     ;|
   SBC $0000,y;[$84:E4A6]  ;} Samus' max missiles += [[Y]]
   STA <max_ammo>  ;[$7E:09C8]  ;/
   JSR <check_function>
   LDA <ammo>  ;[$7E:09C6]  ;\
   ;CLC                     ;|
   ;ADC $0000,y;[$84:E4A6]  ;} Samus' missiles += [[Y]]
   ;STA $09C6  ;[$7E:09C6]  ;/
   <add_hud_code>           ; JSL $8099CF   ; Add missiles to HUD tilemap
   ;LDA #$0168              ;\
   ;JSL $82E118[$82:E118]  ;} Play room music track after 6 seconds
   LDA <message_id>              ;\
   JSL $858080;[$85:8080]  ;} Display missile tank message box
   INY                     ;\
   INY                     ;} Y += 2
   RTS
}
endmacro

macro max_limit_ammo(ammo, max_ammo, hud_index)
{
   SEC
   SBC <ammo>
   BPL ?done
   LDA <max_ammo>
   STA <ammo>
   ?done:
   JSR check_all_items
   LDA <hud_index>
   JSR deselect_if_current_item
   RTS
}
endmacro


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
   
; Etank
org $848968
;;; $8968: Instruction - collect [[Y]] health energy tank ;;;
add_etank:
{
   LDA $09C4    ;\
   CLC                    ;|
   ADC $0000,y  ;} Samus' max health += [[Y]]
   STA $09C4    ;/
   STA $09C2    ; Samus' health = [Samus' max health]
   ;LDA #$0168             ;\
   ;JSL $82E118  ;} Play room music track after 6 seconds
   LDA #$0001             ;\
   JSL $858080  ;} Display energy tank message box
   INY                    ;\
   INY                    ;} Y += 2
   RTS
}

add_reserve_tank:
;;; $8986: Instruction - collect [[Y]] health reserve tank ;;;
{
   LDA $09D4              ;\
   CLC                    ;|
   ADC $0000,y            ;} Samus' reserve energy += [[Y]]
   STA $09D4              ;/
   LDA $09C0              ;\
   BNE .not_first         ;} If first reserve tank:
   INC $09C0              ; Reserve health mode = auto
.not_first:
   ;LDA #$0168            ;\
   ;JSL $82E118           ;} Play room music track after 6 seconds
   LDA #$0019             ;\
   JSL $858080            ;} Display reserve tank message box
   INY                    ;\
   INY                    ;} Y += 2
   RTS
}

add_missile:
;;; $89A9: Instruction - collect [[Y]] ammo missile tank ;;;
%add_ammo(!missiles, !max_missiles, "JSL $8099CF", #$0002)

add_supers:
print "add supers: ", pc 
;;; $89A9: Instruction - collect [[Y]] ammo missile tank ;;;
%add_ammo(!supers, !max_supers, "JSL $809A0E", #$0003)

add_pbs:
print "add pbs: ", pc 
;;; $89A9: Instruction - collect [[Y]] ammo missile tank ;;;
%add_ammo(!power_bombs, !max_power_bombs, "JSL $809A1E", #$0004)

; Minus Health
;org $848968
;   JMP decrease_health

; energy reserve
;org $848986 
;   JMP decrease_reserve

; missile minus max
;org $8489AC
;   SEC
;   SBC $0000,y

; check missile not above max
;org $8489B3
;   JMP check_missiles

; super
;org $8489D5
;   SEC
;   SBC $0000,y

; check supers not above max
;org $8489DC
;   JMP check_supers

; power bombs
;org $8489FE
;   SEC
;   SBC $0000,y

; check missile not above max
;org $848A05
;   JMP check_power_bombs

   
;;; **************
;;; Unequip/Minus when collected
;;; **************

   ;test e tank graphics

; [-] not tested
; [o] part done
; [x] done 


;;; *************
;;; PLM entries ;;;
;;; *************

org $84EED3
{
   dw $EEAB,$AAE3 ; Shot/bombed/grappled reaction, shootable, BTS 45h / collision reaction, special, BTS 45h. Item collision detection
   dw $EE4D,plm_etank ; Energy tank
   dw $EE52,plm_missile ; Missile tank
   dw $EE57,plm_super ; Super missile tank
   dw $EE5C,plm_pb ; Power bomb tank
   dw $EE64,plm_bombs_chozo ; Bombs                            - unused
   dw $EE64,plm_charge ; Charge beam                           - unused
   dw $EE64,plm_ice ; Ice beam                                 - unused
   dw $EE64,plm_hijump ; Hi-jump                               - unused
   dw $EE64,plm_speed ; Speed booster                          - unused
   dw $EE64,plm_wave ; Wave beam                               - unused
   dw $EE64,plm_spazer ; Spazer beam                           - unused
   dw $EE64,plm_spring ; Spring ball                           - unused
   dw $EE64,plm_varia ; Varia suit                             - unused
   dw $EE64,plm_gravity ; Gravity suit                         - unused
   dw $EE64,plm_xray ; X-ray scope                             - unused
   dw $EE64,plm_plasma ; Plasma beam                           - unused
   dw $EE64,plm_grapple ; Grapple beam                         - unused
   dw $EE64,plm_space ; Space jump                             - unused
   dw $EE64,plm_screw ; Screw attack                           - unused
   dw $EE64,plm_morph ; Morph ball                             - unused
   dw $EE64,$E41D ; Reserve tank                               - unused
   dw $EE4D,$E44A ; Energy tank, chozo orb                     - unused
   dw $EE52,plm_missile_chozo ; Missile tank, chozo orb
   dw $EE57,plm_super_chozo ; Super missile tank, chozo orb
   dw $EE5C,plm_pb_chozo ; Power bomb tank, chozo orb
   dw $EE64,plm_bombs_chozo ; Bombs, chozo orb
   dw $EE64,plm_charge ; Charge beam, chozo orb
   dw $EE64,plm_ice ; Ice beam, chozo orb
   dw $EE64,plm_hijump ; Hi-jump, chozo orb
   dw $EE64,plm_speed ; Speed booster, chozo orb
   dw $EE64,plm_wave ; Wave beam, chozo orb
   dw $EE64,plm_spazer ; Spazer beam, chozo orb
   dw $EE64,plm_spring ; Spring ball, chozo orb
   dw $EE64,plm_varia ; Varia suit, chozo orb
   dw $EE64,plm_gravity ; Gravity suit, chozo orb
   dw $EE64,plm_xray ; X-ray scope, chozo orb
   dw $EE64,plm_plasma ; Plasma beam, chozo orb
   dw $EE64,plm_grapple ; Grapple beam, chozo orb
   dw $EE64,plm_space ; Space jump, chozo orb
   dw $EE64,plm_screw ; Screw attack, chozo orb
   dw $EE64,plm_morph ; Morph ball, chozo orb
   dw $EE64,plm_reserve ; Reserve tank, chozo orb
   dw $EE77,plm_etank_shot ; Energy tank, shot block
   dw $EE7C,plm_missile_shot ; Missile tank, shot block
   dw $EE81,plm_super_shot ; Super missile tank, shot block
   dw $EE86,$E9B9 ; Power bomb tank, shot block                - unused
   dw $EE8E,$E9F1 ; Bombs, shot block                          - unused
   dw $EE8E,$EA32 ; Charge beam, shot block                    - unused
   dw $EE8E,$EA73 ; Ice beam, shot block                       - unused
   dw $EE8E,$EAB4 ; Hi-jump, shot block                        - unused
   dw $EE8E,$EAF5 ; Speed booster, shot block                  - unused
   dw $EE8E,$EB36 ; Wave beam, shot block                      - unused
   dw $EE8E,$EB77 ; Spazer beam, shot block                    - unused
   dw $EE8E,$EBB8 ; Spring ball, shot block                    - unused
   dw $EE8E,$EBF9 ; Varia suit, shot block                     - unused
   dw $EE8E,$EC41 ; Gravity suit, shot block                   - unused
   dw $EE8E,$EC89 ; X-ray scope, shot block                    - unused
   dw $EE8E,$ECC9 ; Plasma beam, shot block                    - unused
   dw $EE8E,$ED0A ; Grapple beam, shot block                   - unused
   dw $EE8E,$ED4A ; Space jump, shot block                     - unused
   dw $EE8E,$ED8B ; Screw attack, shot block                   - unused
   dw $EE8E,$EDCC ; Morph ball, shot block                     - unused
   dw $EE8E,$EE0D ; Reserve tank, shot block                   - unused
}

;;; *************
org $84E099 ; Room for 12 PLM default definitions
;;; *************

;;; $E099: Instruction list - PLM $EED7 (energy tank) ;;;
plm_etank:
%plm("", "dw remove_etank,$0064", "dw add_etank,$0064", "dw $0004,$A2DF,$0004,$A2E5")
;%plm("", "dw $8968,$0064", "dw $8724,draw_etank")

plm_missile:
;;; $E0BE: Instruction list - PLM $EEDB (missile tank) ;;;
%plm("", "dw remove_missile,$0005", "dw add_missile,$0005", "dw $0004,$A2EB,$0004,$A2F1")

plm_super:
;;; $E0E3: Instruction list - PLM $EEDF (super missile tank) ;;;
%plm("", "dw remove_supers,$0005", "dw add_supers,$0005", "dw $0004,$A2F7,$0004,$A2FD")

plm_pb:
;;; $E108: Instruction list - PLM $EEE3 (power bomb tank) ;;;
%plm("", "dw remove_pbs,$0005", "dw add_pbs,$0005", "dw $0004,$A303,$0004,$A309")

plm_morph:
;;; $E3EF: Instruction list - PLM $EF23 (morph ball) ;;;
%plm("dw $8764,$8700 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$0004 : db $09", "dw $88F3,$0004 : db $09", "dw $E04F,$E067")

;;; *************
;;; Chozo PLMs
;;; *************

plm_missile_chozo:
;;; $E47C: Instruction list - PLM $EF2F (missile tank, chozo orb) ;;;
%plm_chozo("", "dw remove_missile,$0005", "dw $0004,$A2EB")


;;; *************
org $84E2A1 ; Room for 18 PLM default definitions
;;; *************

plm_super_chozo:
;;; $E4AE: Instruction list - PLM $EF33 (super missile tank, chozo orb) ;;;
%plm_chozo("", "dw $89D2,$0005", "dw $0004,$A2F7")

plm_pb_chozo:
;;; $E4E0: Instruction list - PLM $EF37 (power bomb tank, chozo orb) ;;;
%plm_chozo("", "dw $89FB,$0005", "dw $0004,$A303")


plm_bombs_chozo:
;;; $E512: Instruction list - PLM $EF3B (bombs, chozo orb) ;;;
{
      dw $8764,$8000 : db $00,$00,$00,$00,$00,$00,$00,$00  ; Load item PLM GFX
      dw $887C,plm_bombs_chozo_collected      ; Go to $E547 if the room argument item is set
      dw $8A2E,$DFAF                          ; Call $DFAF (item orb)
      dw $8A2E,$DFC7                          ; Call $DFC7 (item orb burst)
      dw $8A24,plm_bombs_chozo_collide        ; Link instruction = $E53D
      dw $86C1,$DF89                          ; Pre-instruction = go to link instruction if triggered
      dw $874E : db $16                       ; Timer = 16h
   plm_bombs_chozo_draw:
      dw $0004,$A31B  ; draw old empty block
;      dw $E04F                               ; Draw item frame 0
;      dw $E067                               ; Draw item frame 1
      dw $8724,plm_bombs_chozo_draw                          ; Go to $E535
   plm_bombs_chozo_collide:
      dw $E04F                                ; Draw item frame 0
      dw $E067                                ; Draw item frame 1
      dw $8899                                ; Set the room argument item
      ;dw $8BDD : db $02                       ; Clear music queue and queue item fanfare music track
      dw $88F3,$1000 : db $13                 ; Pick up equipment 1000h and display message box 13h
   plm_bombs_chozo_collected:
      dw $0003,$A2B5,$0003,$A2D9,$0003,$A2B5                ; orb reverse burst
      dw $0014,$A2C7,$000A,$A2CD,$0014,$A2D3,$000A,$A2CD    ; draw orb loop
      dw $8A2E,$DFC7                          ; item orb burst
      dw $0001,$A2B5                          ; draw blank frame
      dw $86BC                                ; Delete
}


%plm_chozo("dw $8764,$8000 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$1000 : db $13", "dw $E04F")

plm_charge:
;;; $E54D: Instruction list - PLM $EF3F (charge beam, chozo orb) ;;;
%plm_chozo("dw $8764,$8B00 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88B0,$1000 : db $0E", "dw $E04F")

plm_ice:
;; $E588: Instruction list - PLM $EF43 (ice beam, chozo orb) ;;;
%plm_chozo("dw $8764,$8C00 : db $00,$03,$00,$00,$00,$03,$00,$00", "dw $88B0,$0002 : db $0F", "dw $E04F")

plm_hijump:
;;; $E5C3: Instruction list - PLM $EF47 (hi-jump, chozo orb) ;;;
%plm_chozo("dw $8764,$8400 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$0100 : db $0B", "dw $E04F")

plm_speed:
;;; $E5FE: Instruction list - PLM $EF4B (speed booster, chozo orb) ;;;
%plm_chozo("dw $8764,$8A00 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$2000 : db $0D", "dw $E04F")

plm_wave:
;;; $E642: Instruction list - PLM $EF4F (wave beam, chozo orb) ;;;
%plm_chozo("dw $8764,$8D00 : db $00,$02,$00,$00,$00,$02,$00,$00", "dw $88B0,$0001 : db $10", "dw $E04F")

plm_spazer:
;;; $E67D: Instruction list - PLM $EF53 (spazer beam, chozo orb) ;;;
%plm_chozo("dw $8764,$8F00 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88B0,$0004 : db $11", "dw $E04F")

plm_spring:
;;; $E6B8: Instruction list - PLM $EF57 (spring ball, chozo orb) ;;;
%plm_chozo("dw $8764,$8200 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$0002 : db $08", "dw $E04F")


;;; *************
org $84E642 ; Room for 33 PLM default definitions
;;; *************

plm_varia:
;;; $E6F3: Instruction list - PLM $EF5B (varia suit, chozo orb) ;;;
%plm_chozo("dw $8764,$8300 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$0001 : db $07", "dw $E04F")

plm_gravity:
;;; $E735: Instruction list - PLM $EF5F (gravity suit, chozo orb) ;;;
%plm_chozo("dw $8764,$8100 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$0020 : db $1A", "dw $E04F")

plm_xray:
;;; $E777: Instruction list - PLM $EF63 (x-ray scope, chozo orb) ;;;
%plm_chozo("dw $8764,$8900 : db $01,$01,$00,$00,$03,$03,$00,$00", "dw $8941,$8000", "dw $E04F")

plm_plasma:
;;; $E7B1: Instruction list - PLM $EF67 (plasma beam, chozo orb) ;;;
%plm_chozo("dw $8764,$8E00 : db $00,$01,$00,$00,$00,$01,$00,$00", "dw $88B0,$0008 : db $12", "dw $E04F")

plm_grapple:
;;; $E7EC: Instruction list - PLM $EF6B (grapple beam, chozo orb) ;;;
%plm_chozo("dw $8764,$8800 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $891A,$4000", "dw $E04F")

plm_space:
;;; $E826: Instruction list - PLM $EF6F (space jump, chozo orb) ;;;
%plm_chozo("dw $8764,$8600 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$0200 : db $0C", "dw $E04F")
         
plm_screw:
;;; $E861: Instruction list - PLM $EF73 (screw attack, chozo orb) ;;;
%plm_chozo("dw $8764,$8500 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw $88F3,$0008 : db $0A", "dw $E04F")

plm_reserve:
;;; $E8D7: Instruction list - PLM $EF7B (reserve tank, chozo orb) ;;;
%plm_chozo("dw $8764,$9000 : db $00,$00,$00,$00,$00,$00,$00,$00", "dw add_reserve_tank,$0064", "dw $E04F")

;;; *************
;;; Shot Blocks
;;; *************

plm_etank_shot:
;;; $E911: Instruction list - PLM $EF7F (energy tank, shot block) ;;;
%plm_shot($A2DF, "dw $8968,$0064")

plm_missile_shot:
;;; $E949: Instruction list - PLM $EF83 (missile tank, shot block) ;;;
%plm_shot($A2EB, "dw $89A9,$0005")

plm_super_shot:
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

   
if_select_not_held:
;;; $8968: Instruction - go to [[Y]] if the select button is held ;;;
{
   ; code check
   LDA $7E008B     ;\
   BIT $2000   ;| If pressing select
   BNE not_pressing_select     ;/
   
   ; is pressing, goto [[Y]]
   JMP $8724

   not_pressing_select:
   INY
   INY
   RTS
}

;;; **************
;;; Remove Health/Equipment/Ammo/Beams
;;; **************

remove_etank:
{
   LDA $09C4 ;  [$7E:09C4]  ;\
   SEC                    ;|
   SBC $0000,y ; [$84:E93F]  ;} Samus' max health -= [[Y]]
   STA $09C4   ; [$7E:09C4]  ;/
   SBC $09C2
   BPL .dont_decrease
   LDA $09C4
   STA $09C2
.dont_decrease:
;   STA $09C2  ; [$7E:09C2]  ; Samus' health = [Samus' max health]
   JSR check_all_items
   ;LDA #$0168             ;\
   LDA #$001E             ;\
   ;JSL $82E118 ; [$82:E118]  ;} Play room music track after 6 seconds
   LDA #$0001             ;\
   JSL $858080 ; [$85:8080]  ;} Display energy tank message box
   ;JSL $809A79 ; init hud again for health ;; this almost works



   JSL clear_energy_hud
   STZ $0A06 ; force previous health to be 0, to force redraw

   INY                    ;\
   INY                    ;} Y += 2
   RTS
}

remove_missile:
%remove_ammo(!missiles, !max_missiles, "JSL $8099CF", check_missiles, #$0002)

remove_supers:
%remove_ammo(!supers, !max_supers, "JSL $809A0E", check_supers, #$0003)

remove_pbs:
%remove_ammo(!power_bombs, !max_power_bombs, "JSL $809A1E", check_power_bombs, #$0004)


check_missiles:
%max_limit_ammo(!missiles, !max_missiles, #$0001)

check_supers:
%max_limit_ammo(!supers, !max_supers, #$0002)

check_power_bombs:
%max_limit_ammo(!power_bombs, !max_power_bombs, #$0003)

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
;   JMP check_all_success ; test success
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
   LDA !music_wait
   nop #4
   ;LDA #$0168 ; load music track
   JMP $890C

collect_grapple:
   JSL clear_graple_hud
   JSR check_all_items
   LDA #$0004 ; grapple selected index
   JSR deselect_if_current_item
   LDA !music_wait
   JMP $8933

collect_xray:
{  
   JSL clear_xray_hud
   JSR check_all_items
   LDA #$0005 ; x-ray selected index
   JSR deselect_if_current_item
   LDA !music_wait
   JMP $895A
}


print "'unset_room_item' at location: ", pc
unset_room_item:
;;; $8899: Instruction - unset the room argument item ;;;
{
   ; Positibe room argument => item is not set
   PHX
   LDA $1DC7,x;[$7E:1E0B]
   BMI .done
   JSL $80818E
   LDA $7ED870,x;[$7E:D873]
   EOR $05E7  ;[$7E:05E7]
   STA $7ED870,x;[$7E:D873]
   .done:
   PLX
   RTS
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

remove_reserve_tank:
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
   ;LDA #$0168
   LDA !music_wait             ;\
   ;JSL $82E118;[$82:E118]  ;} Play room music track after 6 seconds
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

;;; **************
;;; Shorten music / Message box
;;; **************
org $858490 ; shorten message box time
   LDX !music_wait
org $858497
   nop #4 ; stop music queue
;   JMP $849F

; shorten music wait

org $848930 ; grapple music
   LDA !music_wait
   nop #4
;org $8489C1 ; missile music
;   LDA !music_wait
;   nop #4
;org $8489EA ; super music
;   LDA !music_wait
;   nop #4
;org $848A13 ; pb music
;   LDA !music_wait
;   nop #4
org $8488DE ; beam music
   LDA !music_wait
   nop #4