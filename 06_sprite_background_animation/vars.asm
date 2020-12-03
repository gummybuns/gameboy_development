;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CONSTANTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;----------------------------
; OAM Variables
;----------------------------
; OAM $C100 -> $C1A0
vOAM_DMA_ADDR   EQU $C1
vOAM_START      EQU $C100
vOAM_END        EQU $C1A0

;----------------------------
; DMA Variables
;----------------------------
; The address in HRAM of our DMA operation
vRUN_DMA         EQU $FF80

;----------------------------
; HERO Variables
;----------------------------
; The start value for the walking counter
vWALK_START     EQU $40
vWALK_MID       EQU $20
;
; Direction variables
vDIRECTION_DOWN     EQU 0
vDIRECTION_UP       EQU 1
vDIRECTION_LEFT     EQU 2
vDIRECTION_RIGHT    EQU 3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MEMORY MAP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SECTION "Runtime Flags", WRAM0[$C000]

; This section stores information about our joypad state
; each loop, the system will read from $FF00 and update these variables, to
; distinguish if a particular button is down, and if it has been pressed.
; Each bit represents a specific button:
;   bit 0: A
;   bit 1: B
;   bit 2: SELECT
;   bit 3: START
;   bit 4: RIGHT
;   bit 5: LEFT
;   bit 6: UP
;   bit 7: DOWN
joypad_down: DB
joypad_pressed: DB

; This section stores information about our main character
;
; This is a counter, that when zero tells us that the sprite has stopped
; walking. If the value is not zero, we do not process any joypad input
; The character cannot perform any action until it has stopped walking
;
; This prevents issues like a character turning halfway through a step,
; or any action similar
walking: DB
backgroundCount: DB

; This stores which direction the character is facing, and when used with the
; walking state allows us to move which ever way we need to
; 00 - down
; 01 - up
; 10 - left
; 11 - right
direction: DB

; This stores if the sprites should flip to animate the character
; this is only needed for walking up / down
flipSprites: DB
