SECTION "UPDATE_WALK_STATE", ROM0

UPDATE_WALK_STATE:
    ; if walking is not zero, decrease the count
    ; otherwise we read the joypad and set the direction / walking to reflect
    ; the input
ld a, [walking]
cp a, 0
jp nz, .updateWalking
.checkDown
    ld a, [joypad_down]
    call JOY_DOWN
    ld b, 0
    cp a, 0
    jp nz, .setDirection
.checkUp
    ld a, [joypad_down]
    call JOY_UP
    ld b, 1
    cp a, 0
    jp nz, .setDirection
.checkLeft
    ld a, [joypad_down]
    call JOY_LEFT
    ld b, 2
    cp a, 0
    jp nz, .setDirection
.checkRight
    ld a, [joypad_down]
    call JOY_RIGHT
    ld b, 3
    cp a, 0
    jp nz, .setDirection
.nothingPressed
    ld a, 0
    ld [flipSprites], a
    ld [backgroundCount], a
    ret
.setDirection
    ; if the new direction is the same as the current
    ; toggle flipSprites
    ld a, [direction]
    cp a, b
    jp nz, .actuallySetDirection
    ld a, [flipSprites]
    xor a, 1
    ld [flipSprites], a
.actuallySetDirection
    ld a, b
    ld [direction], a
    ld a, vWALK_START
    ld [walking], a
    ret
.updateWalking
    ld a, [walking]
    dec a
    ld [walking], a
    ret
