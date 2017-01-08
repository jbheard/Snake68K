*-----------------------------------------------------------
* Title      : Snake subroutines
* Written by : Jacob Heard
* Date       : 1/06/2017
* Description: The subroutines to make the snake game work
*-----------------------------------------------------------

* The snake in memory, can take up to 400 long words
snake   DS.L    400
* Time between frames, in 10ms groups
FPS     EQU     15

*-----------------------------------------------------------
* Initializes the snake game (sets apple, places snake, etc)
*-----------------------------------------------------------
INIT
    MOVE.L  #08, D0
    TRAP    #15
    MOVE.L  D1, D6      ; Set timer

    MOVE.L  #WHITE, D1
    JSR     SC_CLR      ; Clear screen
    MOVE.L  #$00200020, D3 ; Set width/height to $20
    
    MOVE.L  #02, D5     ; Use D5 for length of snake
    LEA snake, A0       ; Load address of snake
    MOVE.L  #$000A000D, (A0)+ ; Load snake head
    MOVE.L  #$000A000E, (A0)+ ; Load snake tail
    
    MOVE.L  #%1000, D4  ; Set initial direction up
    
    JSR     SET_APPLE   ; Set the first apple
    RTS                 ; Return

*-----------------------------------------------------------
* Main loop for snake game
*-----------------------------------------------------------
MAIN
    MOVEM.L D0-D3/A0, -(SP) ; Store registers
    JSR     READ_INPUT  ; Read data from keyboard
    JSR     MOVE_SNAKE  ; Move the snake for the next iteration
    JSR     CHK_GO

    MOVE.L  #WHITE, D1
    JSR     SC_CLR      ; Clear the screen
    
    MOVE.L  #RED, D1    ; Set apple color
    MOVE.L  D7, D2      ; Set apple position
    JSR     SC_DRAWRECT ; Draw the apple
    
    LEA snake, A0       ; Load snake into A0
    MOVE.L  D5,D0       ; Set counter
    MOVE.L  #BLACK, D1
MAINLOOP:   ; Draw the snake
    MOVE.L  (A0)+, D2   ; Set position of block
    JSR     SC_DRAWRECT ; Draw block
    SUBI.L  #1, D0      ; Decrement counter
    BGT     MAINLOOP    ; Continue iff not done
    
    MOVE.L  #08, D0     ; Set trap task
TICK:   ; Delay between frames so that a human can play
    TRAP    #15         ; Get time
    SUB.L   D6, D1      ; Subtract last time from current time
    SUBI.L  #FPS, D1     ; Subtract another 250 milliseconds
    BLE     TICK        ; loop if not enough time has passed
    
    TRAP #15            ; Get time
    MOVE.L  D1, D6      ; Store time for next iteration
    
    MOVEM.L (SP)+, D0-D3/A0 ; Restore registers
    RTS                 ; Return

*-----------------------------------------------------------
* Returns the modulo of D0 and D1 (D0 % D1) in D1.L
*-----------------------------------------------------------
MOD
    MOVEM.L D0/D2,-(SP)
    MOVE.L  D1,D2

    CMP.L   D0,D1
    BCS     MODLOOP1
MODLOOP1:
    ASL.L   #1,D1     ; D1 << 1
    CMP.L   D0,D1
    BCS     MODLOOP1    ; D1 < D0, continue

MODLOOP2:
    CMP.L   D1,D0
    BCC     MODSUB
    CMP.L   D2,D1
    BLS     MODEND
    BRA     MODSHIFT
MODSUB:
    SUB.L   D1,D0
    CMP.L   D2,D1
    BEQ     MODEND
MODSHIFT:
    LSR.L   #1,D1       ; D1 >> 1
    BRA     MODLOOP2    ; D0 < D1

MODEND:
    MOVE.L  D0,D1   ; Move result
    MOVEM.L (SP)+,D0/D2 ; Restore registers
    RTS

*-----------------------------------------------------------
* Places an apple at a pseudo-random position on the grid
*-----------------------------------------------------------
SET_APPLE
    MOVEM.L D0/D1, -(SP)
    
    MOVE.L  #08, D0
    TRAP    #15     ; Get the time for randomness
    MOVE.L  D1,D0

    EOR.L   #$AC8337, D0 ; Randomize the number
    AND.L   #$0FFFFFFF,D0
    MOVE.L  #WIDTH-1, D1
    JSR     MOD
    MOVE.W  D1, D7
    SWAP    D7      ; Put in the correct spot

    * Rinse and repeat
    SWAP    D0
    EOR.L   #$FFABC3, D0 ; Sorta randomize the number
    AND.L   #$0FFFFFFF,D0
    MOVE.L  #HEIGHT-1,D1 ; Map to height
    JSR     MOD
    MOVE.W  D1, D7  ; Put in the correct spot
   
    MOVEM.L (SP)+, D0/D1 ; Restore registers
    RTS

*-----------------------------------------------------------
* Reads keyboard input and sets corresponding 
*   direction (WASD -> ULDR)
*-----------------------------------------------------------
READ_INPUT  MOVEM.L D0/D1,-(SP)
    MOVE.L  #07, D0 ; Set trap code
    TRAP    #15     ; Check for pending input
    CMP.B   #1,D1
    BNE READEND     ; Exit if no pending data
    
    MOVE.L  #05,D0  ; Set trap code
    TRAP    #15     ; Read character

    CMP.B #$41,D1 ; A (ucase)
    BEQ APRESS
    CMP.B #$61,D1 ; a (lcase)
    BEQ APRESS
    
    CMP.B #$53,D1 ; S (ucase)
    BEQ SPRESS
    CMP.B #$73,D1 ; s (lcase)
    BEQ SPRESS
    
    CMP.B #$44,D1 ; D (ucase)
    BEQ DPRESS
    CMP.B #$64,D1 ; d (lcase)
    BEQ DPRESS
    
    CMP.B #$57,D1 ; W (ucase)
    BEQ WPRESS
    CMP.B #$77,D1 ; w (lcase)
    BEQ WPRESS
    
    BRA READEND ; No match
    
APRESS:     ; LEFT 
    MOVE.L  #%0010, D4
    BRA READEND
SPRESS:     ; DOWN
    MOVE.L  #%0100, D4
    BRA READEND
DPRESS:     ; RIGHT
    MOVE.L  #%0001, D4
    BRA READEND
WPRESS:     ; UP
    MOVE.L  #%1000, D4
    BRA READEND

READEND:
    MOVEM.L (SP)+,D0/D1
    RTS

*-----------------------------------------------------------
* Checks for game over
*-----------------------------------------------------------
CHK_GO  MOVEM.L D0-D2/A0,-(SP)
    LEA snake,A0
    MOVE.L  (A0),D1

    CMP.W   #HEIGHT,D1
    BEQ     GAMEOVER
    CMP.W   #00,D1
    BLT     GAMEOVER
    
    SWAP    D1
    CMP.W   #WIDTH,D1
    BEQ     GAMEOVER
    CMP.W   #00,D1
    BLT     GAMEOVER    
    SWAP    D1
    
    LEA     snake, A0
    MOVE.L  (A0),D1
    
    MOVE.L  #01,D0  ; Set counter
    ADD.L   #4,A0   ; Start at snake[1]
CHK_GOLOOP:
    MOVE.L  (A0)+,D2
    CMP.L   D1,D2   ; Do comparison
    BEQ     GAMEOVER ; Run into own tail
    ADDQ.L  #1,D0   ; Increment counter
    CMP.L   D0,D5   ; Test counter
    BNE CHK_GOLOOP
    
    BRA CHK_GOEND   ; All good

GAMEOVER:
        JSR INIT    ; Reset everything
CHK_GOEND:
        MOVEM.L (SP)+,D0-D2/A0 ; Restore registers
        RTS

*-----------------------------------------------------------
* Moves the snake in the given direction
*-----------------------------------------------------------
MOVE_SNAKE  MOVEM.L D0/D1/A0-A2,-(SP)
    LEA     snake, A0
    LEA     snake, A1
    MOVE.L  (A0),D1 ; Store snake head in D1 for now
    MOVE.L  D5, D0  ; Load length into D0
    MULU.W  #4, D0  ; Calculate number of bytes in snakes
    ADD.L   D0, A0  ; Increment snake counter to tail
    ADD.L   D0, A1
    SUB.L   #4, A0
    MOVE.L  D5, D0  ; Set counter
    SUBI.L  #1, D0  ; Go to length-1
    
    LEA     snake,A2
    CMP.L   (A2),D7
    BNE     MOVELOOP    ; Continue if we didn't collect an apple
    * If we got an apple
    ADDI.L  #2,D5   ; increment length
    ADDI.L  #2,D0   ; increment counter
    MOVE    (A0),(A1)+ ; Add tail joint
    MOVE    (A0)+,(A1)
    ADD.L   #4,A0   ; Adjust address 0
    ADD.L   #4,A1   ; Adjust address 1
    JSR     SET_APPLE   ; Create new apple

MOVELOOP:
    MOVE.L  -(A0),-(A1)
    SUBI.L  #1, D0      ; Decrement the counter
    BGT MOVELOOP

    * Switch-case in assembly
    CMP.B #%1000, D4    ; UP %1000
    BEQ UP
    CMP.B #%0100, D4    ; DOWN %0100
    BEQ DOWN
    CMP.B #%0010, D4    ; LEFT %0010
    BEQ LEFT
    CMP.B #%0001, D4    ; RIGHT %0001
    BEQ RIGHT
    
    BRA MOVEEND     ; Pause or error

UP:
    SUBI.W  #1, D1
    BRA MOVEEND
DOWN:
    ADDI.W  #1, D1
    BRA MOVEEND
LEFT:
    SWAP    D1
    SUBI.W  #1, D1
    SWAP    D1
    BRA MOVEEND
RIGHT:
    SWAP    D1
    ADDI.W  #1, D1
    SWAP    D1

MOVEEND:
    LEA     snake,A0
    MOVE.L  D1,(A0)
    MOVEM.L (SP)+, D0/D1/A0-A2 ; Restore registers
    RTS







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
