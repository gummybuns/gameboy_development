INCLUDE "hardware.inc"
INCLUDE "vars.asm"
INCLUDE "helpers/utils.asm"
INCLUDE "helpers/load_sprite.asm"
INCLUDE "helpers/setup.asm"
INCLUDE "helpers/dma.asm"
INCLUDE "helpers/joypad.asm"
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
SECTION "JoypadData", WRAM0[$C000]

joypad_down: DB
joypad_pressed: DB

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
    call UPDATE_HERO
    call RUN_DMA
    jr .mainLoop

UPDATE_HERO:
    ; d represents our Tile number for the left half of the sprite
    ; c represents how much to add to get to get the tile number of the second
    ;   half. (so for the right side c will actually be negative)
    ; e represents our Flags
    ; This will check each button and set the OAM appropriately. The order of
    ; these checks does matter. We increment b after each check because this
    ; reflects the tile numbers for each direction the hero should face:
    ;   Tile 0-3: down
    ;   Tile 4-7: up
    ;   Tile 8-11: left
    ;   Tile 8-11: right (with the flag set to flip on vertical axis)
    ;
    ; It is also important to remember that we need to multiple these values
    ; because our hero is actually composed of 4 sprites
.check_right
    ; wow the right side really sucks. i forgot that the xflip will flip each
    ; individual sprite. so not only do u have to flip, but u have to render
    ; them in the opposite order
    ld d, 8
    ld c, -2
    ld e, OAMF_XFLIP
    ld a, [joypad_down]
    call JOY_RIGHT
    cp a, 0
    jp nz, .configureSprite
.check_left
    ld d, 10
    ld c, 2
    ld e, 0
    ld a, [joypad_down]
    call JOY_LEFT
    cp a, 0
    jp nz, .configureSprite
.check_up
    ld d, 6
    ld a, [joypad_down]
    call JOY_UP
    cp a, 0
    jp nz, .configureSprite
.check_down
    ld d, 2
    ld a, [joypad_down]
    call JOY_DOWN
    cp a, 0
    jp nz, .configureSprite
.done
    ret ; no buttons pressed, we are done
.configureSprite
    ; dont need to update anything if the sprite is already set
    ld hl, vOAM_START + 6
    ld a, d
    cp a, [hl]
    jp z, .done
.configureSpriteRight
    ; load the right side first
    ld hl, vOAM_START + 6
    ld [hl], d
    inc l
    ld [hl], e
.configureSpriteLeft
    ; update d
    ld a, d
    sub a, c
    ld d, a
    ; load the right side
    ld hl, vOAM_START + 2
    ld [hl], d
    inc l
    ld [hl], e
    ret
