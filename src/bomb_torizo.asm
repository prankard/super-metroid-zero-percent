; stop the door from closing until you don't have bombs
org $84BA75
    BNE $03

; stop bt from waking until you don't have bombs
org $84D341
    BNE $13