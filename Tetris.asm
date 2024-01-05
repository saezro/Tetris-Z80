   
; Rodrigo SÃ¡ez, Cristina FernÃ¡ndez, Claudia MartÃ­nez

  DEVICE ZXSPECTRUM48
	SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    org $8000               ; Program is located from memory address $8000 = 32768
    
begin:          
    di              ; Disable Interrupts
    ld sp, 0         ; Set stack pointer to top of ram (RAMTOP)
        
;-------------------------------------------------------------------------------------------------
; Student Code

Acceptkey: db 1
Key: db 0
aux: db 0

keyW equ 1
keyS equ 2
keyD equ 3
keyA equ 4
keyE equ 5
keyQ equ 6
keySp equ 7

;------------------------------------------------------------------
GameStatusStruct:
;------------------------------------------------------------------
GameX: db 0 ; X position of current tetromino
GameY: db 0 ; Y position of current tetromino
TetroPtr: dw 0 ; Pointer to current tetromino
NewTetroPtr: dw 0 ; Pointer to current tetromino


start:                  
    ld ix, Welcometext ;	aims to the string
    ld a, %01001101		 ;	color
    call printtext     ;	prints the first screen
    ld b, 16					 ; Y of where is going to be printed
    ld c, 2						 ; X of where is going to be printed
    ld a, %0000101
    ld ix, pressText
    call PRINTAT        ; Print a string in a position and attributes as per registers (MATERIAL FROM CANVAS)
    call waitKey				; waits for a key to be pressed (The spacebar)
    call CLEARSCR				; The screen is cleared

Tutorialtexts:						;prints the second screen (TUTORIAL OF THE KEYS)
    ld ix, TutorialText   ; aims to the string
    ld a, %0000111 		    ; color
    ld b, 4               ; Y    
    ld c, 2	              ; X 
    call PRINTAT          ; Print the string
    ld b, 8			  			  ; the rest of the code of this function is the same
    ld c, 2
    ld a, %0000111
    ld ix, tutText
    call PRINTAT
    ld b, 16
    ld c, 2
    ld a, %0000101
    ld ix, pressText ; 
    call PRINTAT
    call waitKey
    call CLEARSCR
restart:
    call hrBKG					; fills the full screen with a char pattern (blockgraph)(MATERIAL FROM CANVAS)
    call gameboard 			; prints the gameboard
    ld b, 2
    ld c, 22
    ld a, %11101011     ;%11101011 pink-blue. The color blinks and changes.
    ld ix, Tetristext   ; The word "TETRIS" is painten on screen
    call PRINTAT
    jp main							; jumps to the main 
			
loop: 
    jp Readkey 

gameboard:                  ; prints the gameboard with all ther parts (blueframe, blackframe, title)
frame:
    ld a, 1
    out ($fe), a    ; blue border
    ld a, 1         ;color
    ld b, 23        ; y
looptetrisblueframe:
    ld c, 0         ;x
    ld d, 31        ;long
    call line 
    djnz looptetrisblueframe
    ld b, 0
    ld c, 0
    ld d, 31
    call line
    ;************
    ld b, 22
    ld a, 0
looptetrisblackframe:
    ld c, 2
    ld d, 15 
    call line
    djnz looptetrisblackframe
    ld b, 2
    ld a, %11101011         ;%11101011 pink-blue blinking
title:
    ld c, 22
    ld d, 5
    call lineHD             ;line without multipliying the color
    call WindowTuto         
    ret

main:
    call Random  ;creates a new random tetromino to be used in the next turn
    ld a, 0
    push af
    jp firstTetro

waitKey:                ;loop that ends when a key is pressed
    ld b, 16
    ld c, 2
    ld a, %0000101      ; color cyan
    ld ix, pressText3   ;prints the presstext 3 times to create the animation of the 3 dots
    call PRINTAT
    ld b, 16
    ld c, 2
    ld a, %0000101
    ld ix, pressText2
    call PRINTAT
    ld bc, $7FFE ; spacebar
    in a, (c) 
    and $1F
    cp $1F
    jr nz, endwait
    ld b, 16
    ld c, 2
    ld a, %0000101
    ld ix, pressText
    call PRINTAT
    jr waitKey
endwait:
    ret
;------------------------------------------------------------------------------------
;                                       KEYBOARD
;------------------------------------------------------------------------------------
Readkey:
    push af
    ld a, (Acceptkey)      ; Load the value of Acceptkey into register a
    cp 0                   ; Compare with 0
    jr nz, iniRead         ; if it's not 0 it will go to iniRead
    push bc
    ld bc, $FBFE ; QWE 
    in a, (c) 
    and $1F
    cp $1F
    jr nz, endtec          
    ld bc, $FDFE ; ASD
    in a, (c) 
    and $1F
    cp $1F
    jr nz, endtec
    ld bc, $7FFE ; spacebar
    in a, (c) 
    and $1F
    cp $1F
    jr nz, endtec
    ld a, 1
    ld (Acceptkey), a 
    out ($fe), a

endtec:
    pop bc
endRead:
    pop af
    jp loop

iniRead:                ;identify the key pressed
    call savePos
    ld a, 0                ; Load value zero into register a
    ld (Key), A            ; Store that zero in the variable Key
    ld a, $FB              
    in a, ($FE)            ; input the key fromn that port
    bit 1, A               ; with 'bit' we check that is the key w
    jp z, isW              ; if it returns a 0, it jumps to isW 
    bit 0, a               
    jp z, isQ              ; checks the bit 
    bit 2, a
    jp z, isE
    ld a, $FD
    in a, ($FE)
    bit 1, A
    jp z, isS
    bit 2, A
    jp z, isD
    bit 0, A
    jp z, isA
    ld a, $7F
    in a, ($FE)
    bit 0, A
    jp z, isSp
    jp endRead

isSp:                       
    ld a, 7 
    ld (Key), A          ;loads 7 into key to do a loop in isS
    ld a, 0
    jp isS               ;like pressing S makes the tetromino go down

isW:
    call savePos        ; the position is saved
    ld a, keyW          ; Load variable keyW in register a
    push af
    call DeleteTetromino    ;first deletes the tetromino to make sure doesnt collides with himself
    dec b
    call hasCollision       ; detects if collides with something, register A has the color of the colision, if is 0 then theres no colision
    cp 0
    jp nz, Undo         ; if colides goes to undo to restore the position
    pop af
    jp saveKey          ; jumps to saveKey to save that key

isD:
    call savePos
    ld a, keyD
    push af
    call DeleteTetromino
    inc c
    call hasCollision
    cp 0
    jp nz, Undo
    pop af
    jp isS
    jp saveKey

isS:
    call savePos
    ld a, keyS
    push af
    call DeleteTetromino
    inc b
    call hasCollision
    cp 0
    jp nz, endTurn          ; if colides means it cant move anymore so the turn ends
    call DeleteTetromino
    inc b
    call hasCollision   ;checks the collision with y-1 again to make sure it doesnt move more next move, so if collides now doesnt
    cp 0                ;need a step of "confirmation" to end the turn
    jp nz, endTurn
    dec b
    push ix
    ld ix, Key          ; if the key pressed was "Spacebar" (7), means it needs to go down until collides
    ld a, (ix)
    cp 7
    jp z, repS          
    pop ix
    pop af
    jp saveKey

repS:
    pop ix
    pop af
    jr isS

isA: 
    call savePos
    ld a, keyA
    push af
    call DeleteTetromino
    dec c
    call hasCollision
    cp 0
    jp nz, Undo
    pop af
    jp isS
    jp saveKey

isE: 
    call savePos
    ld a, keyE
    push af
    push bc
    push ix
    call DeleteTetromino    ;to rotate we need also to delete it first 
    ld bc, ptrOffsetRR      ;we change the ptr to the offset to the right
    ld ix, hl 
    add ix, bc
    ld hl, (ix)
    pop ix 
    pop bc
    call hasCollision       
    cp 0
    jp nz, Undo             ; if now collides goes back 
    pop af
    jp saveKey

isQ: 
    call savePos
    ld a, keyQ
    push af
    push bc
    push ix
    call DeleteTetromino
    ld bc, ptrOffsetRL
    ld ix, hl 
    add ix, bc
    ld hl, (ix)
    pop ix 
    pop bc
    call hasCollision
    cp 0
    jp nz, Undo
    pop af
    jp saveKey

saveKey:
    ld (Key), A          ; We store what we have in register a in the variable Key
    ld a, 0              ; Load 0 in register a
    ld (Acceptkey), a    ; Store 0 in the variable Acceptkey
    call DrawTetromino
    jp endRead

endTurn:                
    dec b 
    call DrawTetromino  ;if the turn ends it draw it again
    call Checklines       ; if a new tetromino is pressed we need to check if a line is completed
firstTetro:
    push ix
    ld ix, NewTetroPtr  
    ld hl,(ix)              ; loads hl with the new ptr that was shown in the screen
    pop ix
    call Random             ; creates a new tetromino randomly
    ld b, 2
    ld c, 8
    pop af
    call hasCollision       
    cp 0
    jp nz, endgame           ; if collides at the start means that the game ends
    inc b
    call hasCollision           ; like with the isS, checks the colision with y-1 because if has something below it ends the game
    dec b
    cp 0
    jp nz, endgame2    
    call savePos
    jp saveKey
endgame2:
    call DrawTetromino      ;if has something below can print the last tetromino (just to be shown)
endgame:
    ld a, 2
    out ($fe), a
    ld ix, Endgametext  
    ld a, %10010111
    ld b, 10
    ld c, 0
    call PRINTAT            ;show the end text
pressloop:                  ;this waits until you release the key to make sure you can see the end screen
    ld bc, $FBFE ; QWE 
    in a, (c) 
    and $1F
    cp $1F
    jr nz, pressloop
    ld bc, $FDFE ; ASD
    in a, (c) 
    and $1F
    cp $1F
    jr nz, pressloop
    ld bc, $7FFE                ; Spacebar
    in a, (c) 
    and $1F
    cp $1F
    jr nz, pressloop
    call waitKey        ;shows the press to continue text and waits until you press a key
    ld a, 1
    out ($fe), a
    call CLEARSCR       
    jp restart            ; clears the screen and starts again

;------------------------------------------------------------------------------------
;                               RANDOM TETROMINO
;------------------------------------------------------------------------------------
Random:
    push hl
loopRandom: ; Javier Chocano. (First 4 lines of code given are uploaded in canvas for the student use)
    ld a, r ; r is the “Refresh Register” for DRAM
    and 7 ; Keep only the three less significant bits
    cp 7 ; Make sure the result is not 7 (we want 0..6)
    jr z, loopRandom ; Read r again if we got a 7
    cp 6                ;depending on the number aims to the ptr
    jr z, is6
    cp 5
    jr z, is5
    cp 4
    jr z, is4
    cp 3
    jr z, is3
    cp 2
    jr z, is2
    cp 1
    jr z, is1
    cp 0
    jr z, is0
    jr loopRandom
is0:
    ld hl, OB0       ; figure loaded in hl
    jr endRandom
is1:
    ld hl, IB0 
    jr endRandom
is2:
    ld hl, ZB0 
    jr endRandom  
is3:
    ld hl, SB0  
    jr endRandom
is4:
    ld hl, LB0  
    jr endRandom
is5:
    ld hl, JB0 
    jr endRandom
is6:
    ld hl, TB0 
    jr endRandom
endRandom:
    push ix
    ld ix, NewTetroPtr
    ld (ix), hl
    call NextWindowTetro    ;prints all black where is going to be printed
    ld b, 7
    ld c, 20
    call DrawTetromino      
    pop ix  
    pop hl
    ret 
;------------------------------------------------------------------------------------
;                               WINDOW WITH THE NEXT TETRO
;------------------------------------------------------------------------------------
NextWindowTetro:    ;prints with black the section of the next tetromino
    push af
    push bc
    ld a, 0
    ld b, 6
    ld c, 19
    ld d, 5
    call line
    inc b
    ld c, 19
    ld d, 5
    call line
    inc b
    ld c, 19
    ld d, 5
    call line
    inc b
    ld c, 19
    ld d, 5
    call line
    inc b
    ld c, 19
    ld d, 5
    pop bc
    pop af
    ret
;------------------------------------------------------------------------------------
;                             WINDOW WITH THE KEYS
;------------------------------------------------------------------------------------
WindowTuto:     ;prints the keys in the down left corner
    push af
    push bc
    ld a, 0         ; color black loaded in a
    ld b, 15        
    ld c, 19
    ld d, 10
    call line       ; the line is printed on screen
    inc b
    ld c, 19
    ld d, 10
    call line
    inc b           ; the position of b increases
    ld c, 19
    ld d, 10
    call line
    inc b
    ld c, 19
    ld d, 10
    call line
    inc b
    ld c, 19
    ld d, 10
    call line
    inc b
    ld c, 19
    ld d, 10
    call line
    inc b
    ld c, 19
    ld d, 10
    call line
    ld ix, ingameTutText1       ;prints the letters of the keys
    ld a, %0000110
    ld b, 16
    ld c, 20
    call PRINTAT
    ld b, 18
    ld c, 20
    ld a, %0000110
    ld ix, ingameTutText2
    call PRINTAT
    ld b, 20
    ld c, 20
    ld a, %0000110
    ld ix, ingameTutText3
    call PRINTAT
    pop bc
    pop af
    ret
;------------------------------------------------------------------------------------
;                                       CHECK LINES
;------------------------------------------------------------------------------------
Checklines:             ;checks if the lines are complete
    push hl
    push bc
    push af
    ld b, 22
    ld c, 2
loopChecklines:
    call isBlack
    cp 0
    jp z, noline        ;if just one its black goes to next line
    inc c
    ld a, c
    cp 18
    jp z, isline        ;if all are color deletes the line
    jr loopChecklines
noline:                 ;if 1 is black first checks if theres more lines to check
    ld c, 2
    dec b
    ld a, b
    cp 2
    jp z, endCheckLine
    jr loopChecklines   ;goes to next line
newline:
    dec b
    ld a, b
    cp 2
    jp z, endCheckLine
isline:                 
    ld a, 7
    out ($fe), a
    ld a, 0 
    ld c, 2
    ld d, 15
    call line ; we paint the row in black
    ld c, 2
    
moveLines:          ; chakes the color of the pixel and goes 1 down to paste the same color, moving all down 1 line
    dec b
    call isBlack
    inc b
    call posMem
    ld (hl), a
    inc c
    ld a, c
    cp 18
    jp z, newline
    jr moveLines

endCheckLine:
    pop af
    pop bc
    pop hl
    ret
;------------------------------------------------------------------------------------
;                               POSITION OF HL
;------------------------------------------------------------------------------------
posMem:                     ;gives the memory position of the pixel       
    ; HL=$5800 + 32*Y + X
    ; y (0-23) , x (0-31), 
    ; y = b, x = c, 
    push af
    push de
    push bc
    ;   First part : 32*Y
    ld h, 0
    ld l, b
    add hl, hl  ; 2^5
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ;   Second part: 32*Y + X
    ld d, 0
    ld e, c 
    add hl, de
    ;   Third part: $5800 + 32*Y + X
    ld de, $5800
    add hl, de
    pop bc
    pop de
    pop af
    ret
;------------------------------------------------------------------------------------
;                               UNDO
;------------------------------------------------------------------------------------

Undo:               ;loads the gamepositions before the move
    push ix
    ld ix, GameX
    ld c, (ix)
    ld ix, GameY
    ld b, (ix)
    ld ix,TetroPtr
    ld hl, (ix)
    pop ix
    push af
    ld a, 2
    out ($fe), a
    pop af
    jp isS
    jp saveKey
;------------------------------------------------------------------------------------
;                               DRAW TETROMINO
;------------------------------------------------------------------------------------
DrawTetromino:          ;prints the tetromino
    push bc
    push ix
    push hl
    push af
    push de
    push bc
    ld a, (hl) ; a = color 
    inc hl
    ld e, (hl) ; e = yfigura
    inc hl
    ld d, (hl) ; d = xfigura
    ld ix, aux ; we save the value to restart it before
    ld (ix), d
    ld bc, ZB0Data - ZB0
    dec hl
    dec hl
    add hl, bc ; first position tetrominoData
    pop bc

VectorXData:
    push af   
    ld a, d  ; a = xfigura
    cp 0     
    jp z, finfila ; if x = 0 ends vector
    ld a, (hl)
    cp 0
    jp nz, draw             ;if was color in the array means it needs to be printed
    dec d ; xfigura--
    inc c ; x in pantalla++
    pop af
    inc hl
    jp VectorXData

draw:
    pop af
    call DOTYXC             ;prints the color
    dec d
    inc c
    inc hl
    jp VectorXData
    
finfila: 
    ld a, e ; a = yfigura
    cp 1
    jp z, endtetromino  ; if theres no more lines se termina el tetromino
    ld a, c
    sub (ix)
    ld c, a
    ld d, (ix) ; restart x
    dec e  ; 
    inc b  ; next position in screen
    pop af
    jp VectorXData

endtetromino:
    pop af
    pop de
    pop af
    pop hl
    pop ix
    pop bc
    ret

;------------------------------------------------------------------------------------
;                               DELETE TETROMINO
;------------------------------------------------------------------------------------

DeleteTetromino:        ;same as draw but paints in black
    push bc
    push ix
    push hl
    push af
    push de
    push bc
    ld a, (hl)   
    inc hl
    ld e, (hl)  
    inc hl
    ld d, (hl)  
    ld ix, aux 
    ld (ix), d
    ld bc, ZB0Data - ZB0
    dec hl
    dec hl
    add hl, bc 
    pop bc
    

VectorXData2:
    push af   
    ld a, d  
    cp 0     
    jp z, finfila2 
    ld a, (hl)
    cp 0
    jp nz, draw2
    dec d 
    inc c 
    pop af
    inc hl
    jp VectorXData2

draw2:
    pop af
    ld a, 0             ; Paints the tetromino in black, erasing it.
    call DOTYXC
    dec d
    inc c
    inc hl
    jp VectorXData2
    
finfila2: 
    ld a, e ; a = yfigura
    cp 1
    jp z, endtetromino2  ;  if there aren't more rows, the tetromino ends
    ld a, c
    sub (ix)
    ld c, a
    ld d, (ix) ; we reset the value of x
    dec e  ;  yfigura is decreased 
    inc b  ; the next position on screen is increased
    pop af
    jp VectorXData2

endtetromino2:
    pop af
    pop de
    pop af
    pop hl
    pop ix
    pop bc
    ret
;------------------------------------------------------------------------------------
;                               PIXEL ON SCREEN
;------------------------------------------------------------------------------------

DOTYXC:             ; draw a pixel in the screen depending on the parameters introduced
    ; HL=$5800 + 32*Y + X
    ; y (0-23) , x (0-31), color (0-15)
    ; y = b, x = c, color = a
    push af
    push de
    push bc
    push hl
    ;   First part : 32*Y
    ld h, 0
    ld l, b
    add hl, hl  ; 2^5
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ;   Second part: 32*Y + X
    ld d, 0
    ld e, c 
    add hl, de
    ;   Third part: $5800 + 32*Y + X
    ld de, $5800
    add hl, de
    ;   Forth part: Moves the color to the correct attribute positions 
    ;   A=A*8
    ld e, b
    ld b, 3  ; although 2^3 = 8, b only worked with 2
colorx3:
    add a
    djnz colorx3
    ld b,e
    ld (hl), a ; we paint the position of hl
    pop hl
    pop bc
    pop de
    pop af
    ret
;------------------------------------------------------------------------------------
;                             PIXEL ON SCREEN (not changing the color)
;------------------------------------------------------------------------------------
DOTYXCHD:             ; draw a pixel in the screen depending on the parameters introduced
    ; HL=$5800 + 32*Y + X
    ; y (0-23) , x (0-31), color (0-15)
    ; y = b, x = c, color = a
    push af
    push de
    push bc
    push hl
    ;   First part : 32*Y
    ld h, 0
    ld l, b
    add hl, hl  ; 2^5
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ;   Second part: 32*Y + X
    ld d, 0
    ld e, c 
    add hl, de
    ;   Third part: $5800 + 32*Y + X
    ld de, $5800
    add hl, de
    ld (hl), a ; we paint the position of hl
    pop hl
    pop bc
    pop de
    pop af
    ret

savePos:            ;saves the actual values of the tetromino
    push ix
    ld ix, GameX
    ld (ix), c
    ld ix, GameY
    ld (ix), b
    ld ix,TetroPtr
    ld (ix), hl
    pop ix
    ret
;-------------------------------------------------------------------------------------------------------
;                                                COLLISIONS
;-------------------------------------------------------------------------------------------------------
hasCollision:       ;checks colisions with the screen
    push bc
    push ix
    push hl
    push de
    push bc
    inc hl
    ld e, (hl) 
    inc hl
    ld d, (hl) 
    ld ix, aux 
    ld (ix), d
    ld bc, ZB0Data - ZB0
    dec hl
    dec hl
    add hl, bc 
    pop bc

VectorXDataColi:        ;same structure as the drawtetromino
    ld a, d  
    cp 0     
    jp z, finfilaColi
    ld a, (hl)
    cp 0
    jp nz, drawColi     ;if the position of the array has a one checks the screen
    dec d 
    inc c 
    inc hl
    jp VectorXDataColi

drawColi:   
    call isBlack        ;if theres a color in the pixel means it collides
    cp 0
    jp nz, endColi
    dec d
    inc c
    inc hl
    jp VectorXDataColi
    
finfilaColi:            ; looks if it is the end of the rows that has collisions
    ld a, e 
    cp 1                ;checks if it is the last one
    jp z, endtetrominoColi 
    ld a, c
    sub (ix)            ; x is restored
    ld c, a
    ld d, (ix) 
    dec e  
    inc b  
    jp VectorXDataColi

endtetrominoColi:       ; the value of a is restored
    ld a, 0
endColi:
    pop de
    pop hl
    pop ix
    pop bc
    ret

isBlack:                    ;returns
    ; HL=$5800 + 32*Y + X
    ; y (0-23) , x (0-31), 
    ; y = b, x = c, 
    push hl
    push af
    push de
    push bc
    ;   First part : 32*Y
    ld h, 0
    ld l, b
    add hl, hl  ; 2^5
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ;   Second part: 32*Y + X
    ld d, 0
    ld e, c 
    add hl, de
    ;   Third part: $5800 + 32*Y + X
    ld de, $5800
    add hl, de
    pop bc
    pop de
    pop af
    ld a, (hl) ; save color
    pop hl
    ret

lineHD:
    call DOTYXCHD
    push af             ; to use the register a without any changing
    ld a, d
    cp 0                ; compares the value of a (d) with 0
    jp z, endlineHD       ; if they are the same z is activated
    inc c               ; x is increased
    dec d               ; d is decreased
    pop af
    jp lineHD
endlineHD: 
    pop af
    ret

line:
    call DOTYXC
    push af             ; to use the register a without any changing
    ld a, d
    cp 0                ; compares the value of a (d) with 0
    jp z, endline       ; if they are the same z is activated
    inc c               ; x is increased
    dec d               ; d is decreased
    pop af
    jp line
endline: 
    pop af
    ret
endofcode: jr endofcode
    include 'tetromino_blocks.asm'
    include 'highResBackground.asm'
    include 'TextDemo.asm'
    

