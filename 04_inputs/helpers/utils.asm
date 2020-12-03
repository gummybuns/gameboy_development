SECTION "Utils", ROM0

WAIT_VBLANK:
    ; wait for the VBLANK
.waitVBlank
    ld a, [rLY]
    cp 144
    jr c, .waitVBlank
    ret

SET_SPRITE_DATA:
    ; Sprite requires 4 consecutive bytes in memory. These bytes correspond to the
    ; following:
    ;
    ; BYTE 0: Y-coordinate
    ; BYTE 1: X-coordinate
    ; BYTE 2: The tile number. Remember that each tile is 8 bytes. But i am
    ;   pretty sure this is an integer index. (The second tile should have be 1)
    ; BYTE 3: Flags - colors, flip bits, etc. (we are ignoring these for now)
    ;
    ; @register {hl} the address to set the sprite data to
    ; @register {b} the Y coordinate
    ; @register {c} the X coordinate
    ; @register {d} the tile number (0 - 160)
    ; @register {e} flags
    ld a, b
    ld [hli], a
    ld a, c
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a
    ret
