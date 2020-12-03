SECTION "LOAD_SPRITE", ROM0

LOAD_SPRITE:
    ; Load a sprite into memory
    ; There are no arguments to this function currently, it makes the following
    ; assumptions about the setup of the registers:
    ;
    ; @register {hl} The address in VRAM where the first byte is written
    ;   for now VRAM is defined as $8000-9FFF
    ; @register {de} The address where the first byte of the sprite is located
    ;   likely to be ROM data
    ; @register {bc} The size of the sprite in bytes. This loop runs until this
    ;   value is zero
    ;
    ; @example
    ; ld hl _VRAM
    ; ld de, SpriteBegin
    ; ld bc, SpriteEnd - SpriteBegin
    ; CALL LOAD_SPRITE
    ld hl, _VRAM8000
    ld de, HelloWorldLabel
    ld bc, HelloWorldLabelEnd - HelloWorldLabel
.loadSprite
    ; copy each byte over one at a time
    ld a, [de]
    ld [hli], a
    inc de
    dec bc

    ; once bc is all zero's it has finished loading
    ld a, b
    or a, c
    jr nz, .loadSprite
    ret
