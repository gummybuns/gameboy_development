SECTION "UPDATE_HERO_SPRITE", ROM0

UPDATE_HERO_SPRITE:
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
ld a, [walking]
cp a, vWALK_MID
jp nc, .useWalkingSprites
.check_right
    ; wow the right side really sucks. i forgot that the xflip will flip each
    ; individual sprite. so not only do u have to flip, but u have to render
    ; them in the opposite order
    ld d, 8
    ld c, -2
    ld e, OAMF_XFLIP
    ld a, [direction]
    cp a, vDIRECTION_RIGHT
    jp z, .configureSprite
.check_left
    ld d, 10
    ld c, 2
    ld e, 0
    ld a, [direction]
    cp a, vDIRECTION_LEFT
    jp z, .configureSprite
.check_up
    ld d, 6
    ld a, [direction]
    cp a, vDIRECTION_UP
    jp z, .configureSprite
.check_down
    ld d, 2
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
.useWalkingSprites
    ld a, [direction]
    ld e, 0
.checkWalkLeft
    ld d, 26
    ld c, 2
    cp a, vDIRECTION_LEFT
    jp z, .configureSprite
.checkWalkRight
    ld e, OAMF_XFLIP
    ld d, 24
    ld c, -2
    cp a, vDIRECTION_RIGHT
    jp z, .configureSprite
.checkWalkDown
    ld e, 0
    ld a, [flipSprites]
    cp a, 0
    jp nz, .useDefaultDown
    ld d, 18
    ld c, 2
    jp .checkDownDirection
.useDefaultDown
    ld d, 14
    ld c, 2
.checkDownDirection
    ld a, [direction]
    cp a, 0
    jp z, .configureSprite
.checkWalkUp
    ld a, [flipSprites]
    cp a, 0
    jp nz, .useDefaultUp
    ld e, OAMF_XFLIP
    ld c, -2
    ld d, 20
    jp .configureSprite
.useDefaultUp
    ld d, 22
    ld c, 2
    jp .configureSprite
.done
    ret ; no buttons pressed, we are done


