INCLUDE "hardware.inc"
INCLUDE "vars.asm"
INCLUDE "helpers/utils.asm"
INCLUDE "helpers/load_sprite.asm"
INCLUDE "helpers/setup.asm"
INCLUDE "helpers/dma.asm"
INCLUDE "gfx/sprites/hello_world.z80"

SECTION "Header", ROM0[$100]
EntryPoint:
    di
    jp Start

REPT $150 - $104
    db 0
ENDR

SECTION "Game code", ROM0
Start:
.setup
    call WAIT_VBLANK
    call MOVE_DMA_TO_HRAM
    call CLEAR_RAM
.disableLCD
    ld a, LCDCF_OFF
    ld [rLCDC], a
.beginLoadSprite
    call LOAD_SPRITE
.configureSprite
    ; put the data into our character data
    ld hl, vOAM_START
    ld a, 50
    ld [hli], a
    ld a, 40
    ld [hli], a
    ld a, 0
    ld [hli], a

    call RUN_DMA
.finishSetup
    call FINISH_SETUP
.lockup
    ld de, $1234
    ld hl, $4567
    jr .lockup
