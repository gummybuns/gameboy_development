; This is a list of all of my custom variables
; they all begin with a 'v' to ensure a clean namespace

; OAM Variables
; OAM $C100 -> $C1A0
vOAM_DMA_ADDR   EQU $C1
vOAM_START      EQU $C100
vOAM_END        EQU $C1A0

; DMA Variables
; The address in HRAM of our DMA operation
vRUN_DMA         EQU $FF80
