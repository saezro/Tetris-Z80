
printtext:   
                ; FIRST EXAMPLE - Print a text
                ;--------------------------------------------------
                ld b, 10        ; Row in register B
                ld c, 0         ; Column in register C
                ;ld a, %01001101 ; Color in register A (Full 8-bit attributes: Flash, Brightness, Paper(3), Ink (3))
                  ; Text, ending with 0, pointed to by IX
                call PRINTAT    ; Function to print text

                ; SECOND EXAMPLE - Print a row of a character
                ;--------------------------------------------------
                ld b, 12        ; Row in register B
                ld c, 0         ; Initial column in register C
                ld a, %00010000 ; Color in register A (Full 8-bit attributes: Flash, Brightness, Paper(3), Ink (3))
                call PREP_PRT   ; Initialize text variables
                ld b, 32        ; Prepare a loop of 32 iterations
                ld a, 128       ; Define the character to print. 128 is "brick", the first one right after the "text.asm" include

PrintRow:       push af         ; Print char routine does not push/pop register, so we save them here
                push bc
                call PRINTCHNUM ; Print a char and update cursor variables, moving it one to the right
                pop bc          ; Restore register B (loop) and register C, although C is not used here
                pop af          ; Restore A, containing the char to print
                djnz PrintRow   ; For loop 
                ret

end:            jr end          ; end of program infinite loop
    
    include "text.asm"         ; Library for text printing
                               ; Including the pixelwise definition for all characters (96 ASCII chars, from 32 (space) onwards)
                               ; Right after this include, you may add custom chars as per the two shown below.
                               ; Use the attached excel file to define these bytes easily 
brick:          defb $FF, $01, $01, $81, $FF, $10, $10, $18; Brick pixel definition, defined as the next char: char 128
smiley:         defb $3C, $42, $A5, $81, $A5, $99, $42, $3C; Smiley pixel definition, defined as the next char: char 129
nosmiley:         defb $3C, $42, $A5, $81, $99,$A5, $42, $3C
                ; How to make a custom char: Shown, for readabilty sake, as a "." representing a 0, and a "@" representing a 1
                ; Smiley Example
                ; $3C --> 00111100  --> ..@@@@..
                ; $42 --> 01000010  --> .@....@.
                ; $A5 --> 10100101  --> @.@..@.@
                ; $81 --> 10000001  --> @......@
                ; $A5 --> 10100101  --> @.@..@.@
                ; $99 --> 10011001  --> @..@@..@
                ; $42 --> 01000010  --> .@....@.
                ; $3C --> 00111100  --> ..@@@@..


Endgametext:         defm "  ", 130, "        End game           ",130," ",0
Welcometext:         defm "  ", 129, " Welcome to TETRIS by: ",129,"      Rodrigo, Claudia and Cristina      ",0
Tetristext:         defm "Tetris",0
TutorialText:           defm "Tutorial:",0    
tutText:           defm "'Q'          ->rotate left      'E'          ->rotate right     'W''A''S''D' ->move             'Spacebar'   ->drop",0
pressText:              defm "Press spacebar to continue.  ",0  
pressText2:              defm "Press spacebar to continue.. ",0 
pressText3:              defm "Press spacebar to continue...",0   
ingameTutText1:           defm "Q  W  E",0 
ingameTutText2:           defm "A  S  D",0 
ingameTutText3:           defm "Spacebar",0 