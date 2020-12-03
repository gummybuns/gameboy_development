SECTION "Utils", ROM0

WAIT_VBLANK:
    ; wait for the VBLANK
.waitVBlank
    ld a, [rLY]
    cp 144
    jr c, .waitVBlank
    ret
