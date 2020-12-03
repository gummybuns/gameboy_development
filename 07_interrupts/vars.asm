;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CONSTANTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OAM Variables
; OAM $C100 -> $C1A0
vOAM_DMA_ADDR   EQU $C1
vOAM_START      EQU $C100
vOAM_END        EQU $C1A0

; DMA Variables
; The address in HRAM of our DMA operation
vRUN_DMA         EQU $FF80


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

; This stores a series of flags used to animate our sprites.
; bit 0: Timer Flag - The timer interrupt is configured to toggle this bit
;   to determine which walking sprite should be shown
animate_state: DB
; This is a counter that gets incremented with each timer interrupt. It is used
; to count to a certain value, which when reached, will toggle the animate state
animate_counter: DB

