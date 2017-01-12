*-----------------------------------------------------------
* Program    : Snake graphics
* Written by : Jacob Heard
* Date       : 2016-01-05
* Description: Graphics drawing subroutines
*-----------------------------------------------------------

* Size of screen buffer in pixels.
SB_W	EQU	640
SB_H	EQU 480
WIDTH   EQU SB_W/$20
HEIGHT  EQU SB_H/$20

* Define some color constants (BGR color)
WHITE   EQU $00FFFFFF
BLUE    EQU $00FF0000
GREEN   EQU $0000FF00
RED     EQU $000000FF
BLACK   EQU $00000000


*-----------------------------------------------------------
* Clear the screen buffer. Set every pixel to an arbitrary color.
* Parameters:
*    D1.L: screen buffer color (unchanged)
*-----------------------------------------------------------
SC_CLR MOVEM.L D0/D2-D4, -(SP)  ; Move D0-D4/A0 to stack
    MOVE.L      #80, D0
    TRAP        #15         ; Set pen color
    MOVE.L      #81, D0
    TRAP        #15         ; Set fill color

    MOVE.L      #00, D1     ; Set (x1, y1) to (0, 0)
    MOVE.L      #00, D2
    MOVE.L      #SB_W, D3   ; Set (x2, y2) to (width, height)
    MOVE.L      #SB_H, D4
    MOVE.L      #87, D0     ; Set trap task ##
    TRAP        #15         ; Fill screen

    MOVEM.L (SP)+,D0/D2-D4  ; Restore registers
    RTS                     ; Return

*-----------------------------------------------------------
* Draws rectangle on the screen.
* Parameters:
*   D1.L: screen buffer color (unchanged)
*   D2.W: (upper) x position of rect (unchanged)
*   D2.W: (lower) y position of rect (unchanged)
*   D3.W: (upper) width of rect (unchanged)
*   D3.W: (lower) height of rect (unchanged)
*-----------------------------------------------------------
SC_DRAWRECT MOVEM.L D0-D4, -(SP)
    MOVE.L      #80, D0
    TRAP        #15     ; Set pen color
    MOVE.L      #81, D0
    TRAP        #15     ; Set fill color
    
    SWAP        D2
    MOVE.W      D2, D1  ; MV  x->D1
    MOVE.W      #00, D2 ; Clear lower word
    SWAP        D2      ; SET y->D2
    
    MOVE.W      D3, D4  ; MV  h->D4
    MOVE.W      #00, D3 ; Clear lower word
    SWAP        D3      ; SET w->D3
    
    * Adjust values
    MULU.W      D3, D1
    MULU.W      D4, D2
    ADD.L       D1, D3 
    ADD.L       D2, D4
    
    MOVE.L      #87, D0 ; Set trap task
    TRAP        #15     ; Fill rect
    
    MOVEM.L  (SP)+, D0-D4 ; Restore registers
    RTS                 ; Return

*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~8~






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
