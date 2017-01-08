*-----------------------------------------------------------
* Title      : Snake game
* Written by : Jacob Heard
* Date       : 1/3/2017
* Description: A simple snake game written in 68000 assembly
*
* NOTES:
*   D4 stores the direction of the snake
*   D5 stores the length of the snake
*   D6 is the game timer (100ths of a second, from TRAP)
*   D7 is the apple position ($00xx $00yy)
*
* TODO
*   - Running into last link of tail does not kill snake
*   - Tail pieces not adding in correct position, appear as 
*       black boxes for a single frame somewhere on screen
*   - Add score?
*   - Optimize?
*-----------------------------------------------------------
    ORG    $1000

****************************
* Beginning of the program *
****************************
START:          ; First instruction of program
    JSR INIT    ; Init the program
SLOOP:
    JSR MAIN    ; Call main loop
    BRA SLOOP
    
    SIMHALT     ; Halt simulator
    
    * Include graphics library
    INCLUDE 'graphics.X68'
    * Include snake subroutines
    INCLUDE 'snake_h.X68'
    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
