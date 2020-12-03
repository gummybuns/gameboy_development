INCLUDE "hardware.inc"
INCLUDE "vars.asm"
INCLUDE "helpers/utils.asm"
INCLUDE "helpers/load_sprite.asm"
INCLUDE "helpers/setup.asm"
INCLUDE "helpers/dma.asm"
INCLUDE "gfx/sprites/hero.z80"


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

; This example loads a 16x16 sprite
; By default, gameboy renders tiles 8x8. So we have to actually have multiple
; sprites that are placed directly next to each other to make it look like one.
;
; This would mean we need 4 sprites.
; But the LCD has a flag to instead render tiles 8x16. So if we set that flag,
; we only need two sprites.
;
; We also have to figure out how to perform a DMA for multiple sprites. Recall
; that OAM (Object Attribute Memory) is where all sprite data is stored. The
; address space of OAM is 160 bytes long, and each sprite requires 4 bytes, so
; we can have 40 sprites at once.
;
; The DMA sequence requires a start address, and will then copy 160 bytes over
; from that start address to OAM. Therefore, we need an address space of 8 bytes
; to render both halves of our 16x16 sprite
;
; The first 4 bytes ($C000) will correspond to the left side. The next 4 bytes
; ($C004) will correspond to the right side.
SECTION "Game code", ROM0
Start:
    call WAIT_VBLANK
    call MOVE_DMA_TO_HRAM
    call CLEAR_RAM
.disableLCD
    ld a, LCDCF_OFF
    ld [rLCDC], a
.loadSprite
    ld hl, _VRAM8000
    ld de, HeroTilesStart
    ld bc, HeroTilesEnd - HeroTilesStart
    call LOAD_SPRITE
.configureSpriteLeft
    ld hl, vOAM_START
    ld b, 40
    ld c, 30
    ld d, 0
    ld e, 0
    call SET_SPRITE_DATA
.configureSpriteRight
    ld hl, vOAM_START + 4
    ld b, 40
    ld c, 38
    ld d, 2
    ld e, 0
    call SET_SPRITE_DATA
.dmaBothSprites
    call RUN_DMA
.finish
    call FINISH_SETUP
.lockup
    jr .lockup
