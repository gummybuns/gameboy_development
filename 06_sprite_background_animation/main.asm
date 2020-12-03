INCLUDE "hardware.inc"
INCLUDE "vars.asm"

INCLUDE "helpers/system/dma.asm"
INCLUDE "helpers/system/wait_vblank.asm"
INCLUDE "helpers/system/joypad.asm"

INCLUDE "helpers/math/division.asm"

INCLUDE "helpers/sprites/load_sprite.asm"
INCLUDE "helpers/sprites/set_sprite_data.asm"
INCLUDE "helpers/sprites/hero/update_hero.asm"
INCLUDE "helpers/sprites/hero/update_walk_state.asm"

INCLUDE "helpers/background/update_background.asm"

INCLUDE "helpers/setup.asm"

INCLUDE "gfx/sprites/hero.z80"
INCLUDE "gfx/background/background.z80"


; This is a refactor of 01_hello_world_sprite
; The goal is to try and stop hard coding everything and make some
; callable functions.
SECTION "Header", ROM0[$100]
    ; Our code here
EntryPoint: ; This is where execution begins
    di ; Disable interrupts. That way we can avoid dealing with them, especially since we didn't talk about them yet :p
    jp Start ; Leave this tiny space

REPT $150 - $104
    db 0
ENDR

SECTION "Game code", ROM0
Start:
    call WAIT_VBLANK
    call MOVE_DMA_TO_HRAM
    call CLEAR_RAM
.disableLCD
    ld a, LCDCF_OFF
    ld [rLCDC], a
.loadTiles
    call INITIALIZE_BACKGROUND
    call INITIALIZE_SPRITE
.finish
    call FINISH_SETUP
.mainLoop
    call WAIT_VBLANK
    call READ_JOYPAD
    call UPDATE_WALK_STATE
    call UPDATE_HERO_SPRITE
    call UPDATE_BACKGROUND
    call RUN_DMA
    jr .mainLoop
