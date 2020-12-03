SECTION "SETUP", ROM0

CLEAR_RAM:
    ; Clear our Sprite Workspace
    ; There is a chance that there is crud left over in ram from a previous
    ; game / boot. We want to make sure that our dma transfers do not send
    ; anything that we do not want in OAM
.clearRAM
    ld  hl,$C100
    ld  bc,$A0
.clearRAMLoop
    ld  a,$0
    ld  [hli],a
    dec bc
    ld  a,b
    or  c
    jr  nz, .clearRAMLoop
    ret

FINISH_SETUP:
    ; Finish setting up the game by setting up the LDC variables
    ; sets up the color palettes for the background
    ld a, %11100101
    ld [rBGP], a

    ; sets up the color palettes for the objects
    ld a, %11100100
    ld [rOBP0], a

    ; Set the scroll position to 0,0
    ld a, 0
    ld [rSCY], a
    ld [rSCX], a

    ; Shut sound down
    ld [rNR52], a

    ; Turn screen on, display background
    ld a, LCDCF_ON|LCDCF_BGON|LCDCF_OBJON|LCDCF_OBJ16
    ld [rLCDC], a
    ret
