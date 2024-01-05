; -----------------------------------------
; Tetris Block Definitions (JMS, DL 2023)
; Using doubly-linked circular list
; Simplified representation
; -----------------------------------------

NumBlocks      EQU 7               ; Different Tetrominos
offsetColor    EQU 0               ; offset from Block start to Color
offsetBY       EQU 1               ; offset from Block start to Y size of block
offsetBX       EQU 2               ; offset from Block start to X size of block
ptrOffsetRL    EQU 3               ; offset from Block start to Rotate Left pointer
ptrOffsetRR    EQU 5               ; offset from Block start to Rotate Right pointer
offsetData     EQU 7               ; offset from Block start to Block Data
BlockXSize     EQU 4               ; Max X size
BlockYSize     EQU 4               ; Max Y Size

TETRISBLOCKS: DW OB0, IB0, ZB0, SB0, LB0, JB0, TB0     ; all blocks

; O block   All four rotations are the same
OC:       EQU 6                    ; dark YELLOW
OB0:      DB OC, 2, 2              ; Color, Ysize, Xsize
OB0Ptr:   DW OB0, OB0              ; Pointer to left rotation, pointer to right rotation
OB0Data:  DB 1, 1                  
          DB 1, 1           


; I block   Vertical and horizontal rotations are the same among them
IC:       EQU 13                   ; bright CYAN
IB0:      DB IC, 1, 4              ; Color, Ysize, Xsize
IB0Ptr:   DW IB1, IB1              ; Pointer to left rotation, pointer to right rotation
IB0Data:  DB 1,1,1,1              

IB1:      DB IC, 4, 1              ; Color, Ysize, Xsize
IB1Ptr:   DW IB0, IB0              ; Pointer to left rotation, pointer to right rotation
IB1Data:  DB 1
          DB 1
          DB 1
          DB 1


; Z block  Vertical and horizontal rotations are the same among them
ZC:       EQU 10                   ; bright RED
ZB0:      DB ZC, 2, 3              ; Color, Ysize, Xsize
ZB0Ptr:   DW ZB1, ZB1              ; Pointer to left rotation, pointer to right rotation
ZB0Data:  DB 1,1,0
          DB 0,1,1               

ZB1:      DB ZC, 3, 2              ; Color, Ysize, Xsize
ZB1Ptr:   DW ZB0, ZB0              ; Pointer to left rotation, pointer to right rotation
ZB1Data:  DB 0,1
          DB 1,1
          DB 1,0


; S block  Vertical and horizontal rotations are the same among them
SC:       EQU 4                    ; dark GREEN
SB0:      DB SC, 2, 3              ; Color, Ysize, Xsize
SB0Ptr:   DW SB1, SB1              ; Pointer to left rotation, pointer to right rotation
SB0Data:  DB 0,1,1
          DB 1,1,0               

SB1:      DB SC, 3, 2              ; Color, Ysize, Xsize
SB1Ptr:   DW SB0, SB0              ; Pointer to left rotation, pointer to right rotation
SB1Data:  DB 1,0
          DB 1,1
          DB 0,1

; L block   four rotations
LC:       EQU 2                    ; dark RED
LB0:      DB LC, 2, 3              ; Color, Ysize, Xsize
LB0Ptr:   DW LB3, LB1              ; Pointer to left rotation, pointer to right rotation
LB0Data:  DB 0,0,1
          DB 1,1,1   

LB1:      DB LC, 3, 2              ; Color, Ysize, Xsize
LB1Ptr:   DW LB0, LB2              ; Pointer to left rotation, pointer to right rotation
LB1Data:  DB 1,0
          DB 1,0
          DB 1,1

LB2:      DB LC, 2, 3              ; Color, Ysize, Xsize
LB2Ptr:   DW LB1, LB3              ; Pointer to left rotation, pointer to right rotation
LB2Data:  DB 1,1,1
          DB 1,0,0   

LB3:      DB LC, 3, 2              ; Color, Ysize, Xsize
LB3Ptr:   DW LB2, LB0              ; Pointer to left rotation, pointer to right rotation
LB3Data:  DB 1,1
          DB 0,1
          DB 0,1             
    
; J block   four rotations
JC:       EQU 7                    ; bright BLUE
JB0:      DB JC, 2, 3              ; Color, Ysize, Xsize
JB0Ptr:   DW JB3, JB1              ; Pointer to left rotation, pointer to right rotation
JB0Data:  DB 1,0,0
          DB 1,1,1   

JB1:      DB JC, 3, 2              ; Color, Ysize, Xsize
JB1Ptr:   DW JB0, JB2              ; Pointer to left rotation, pointer to right rotation
JB1Data:  DB 1,1
          DB 1,0
          DB 1,0

JB2:      DB JC, 2, 3              ; Color, Ysize, Xsize
JB2Ptr:   DW JB1, JB3              ; Pointer to left rotation, pointer to right rotation
JB2Data:  DB 1,1,1
          DB 0,0,1   

JB3:      DB JC, 3, 2              ; Color, Ysize, Xsize
JB3Ptr:   DW JB2, JB0              ; Pointer to left rotation, pointer to right rotation
JB3Data:  DB 0,1
          DB 0,1
          DB 1,1             

; T block   four rotations
TC:       EQU 3                    ; dark MAGENTA
TB0:      DB TC, 2, 3              ; Color, Ysize, Xsize
TB0Ptr:   DW TB3, TB1              ; Pointer to left rotation, pointer to right rotation
TB0Data:  DB 0,1,0
          DB 1,1,1   

TB1:      DB TC, 3, 2              ; Color, Ysize, Xsize
TB1Ptr:   DW TB0, TB2              ; Pointer to left rotation, pointer to right rotation
TB1Data:  DB 1,0
          DB 1,1
          DB 1,0

TB2:      DB TC, 2, 3              ; Color, Ysize, Xsize
TB2Ptr:   DW TB1, TB3              ; Pointer to left rotation, pointer to right rotation
TB2Data:  DB 1,1,1
          DB 0,1,0   

TB3:      DB TC, 3, 2              ; Color, Ysize, Xsize
TB3Ptr:   DW TB2, TB0              ; Pointer to left rotation, pointer to right rotation
TB3Data:  DB 0,1
          DB 1,1
          DB 0,1      

