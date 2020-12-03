INCLUDE "hardware.inc"
INCLUDE "vars.asm"
INCLUDE "helpers/utils.asm"
INCLUDE "helpers/load_sprite.asm"
INCLUDE "helpers/setup.asm"
INCLUDE "helpers/dma.asm"
INCLUDE "helpers/joypad.asm"
INCLUDE "gfx/sprites/hero.z80"


SECTION "TIMER_INTERRUPT", ROM0[$0050]
TIMER_HANDLER:
    call HANDLE_TIMER_INTERRUPT
    ret

SECTION "Header", ROM0[$100]
EntryPoint:
    di
    jp Start

REPT $150 - $104
    db 0
ENDR

SECTION "Game code", ROM0
Start:
    call CONFIGURE_TIMER
    call CONFIGURE_INTERRUPTS
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
.mainLoop
    call WAIT_VBLANK
    call READ_JOYPAD
    call ANIMATE_HERO
    call RUN_DMA
    jr .mainLoop

HANDLE_TIMER_INTERRUPT:
    push hl
    push af
    ld hl, animate_counter
    ld a, [hl]
    inc a
    cp a, $8
    jr nz, .done
.toggleFlag
    ; toggle the flag
    ld hl, animate_state
    ld a, [hl]
    xor a, %00000001
    ld [hl], a

    ; reset the counter to 0
    ld hl, animate_counter
    ld a, 0
.done
    ; update the counter
    ld [hl], a
    pop af
    pop hl
    reti

ANIMATE_HERO:
    ld d, 2
    ld c, 2
    ld e, 0
    ld a, [joypad_down]
    call JOY_DOWN
    cp a, 0
    jp z, .configureSpriteRight1
.animateSprite
    ; when it is walking use tile 15
    ld d, 15
    ; get the animate flag
    ld hl, animate_state
    ld a, [hl]
    cp a, 0
    jp nz, .updateTiles
.configureSpriteRight1
    ; load the right side first
    ld hl, vOAM_START + 6
    ld [hl], d
    inc l
    ld [hl], e
.configureSpriteLeft1
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
.updateTiles
    ld e, OAMF_XFLIP
    ld c, -2
    ld d, 13
    jp .configureSpriteRight1

UPDATE_HERO:
    ; d represents our Tile number for the left half of the sprite
    ; c represents how much to add to get to get the tile number of the second
    ;   half. (so for the right side c will actually be negative)
    ; e represents our Flags
    ; This will check each button and set the OAM appropriately. The order of
    ; these checks does matter. We increment b after each check because this
    ; reflects the tile numbers for each direction the hero should face:
    ; STATIONARY
    ;   Tile 0-3 OR TILE 13-15 down 
    ;   Tile 4-7: up
    ;   Tile 8-11: left
    ;   Tile 8-11: right (with the flag set to flip on vertical axis)
    ; MOVING
    ;   Tile 12-15: down (then we can toggle the flag to flip on the axis
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
