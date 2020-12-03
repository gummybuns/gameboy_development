SECTION "SETUP", ROM0

CLEAR_RAM:
    ; Clear our Sprite Workspace
    ; There is a chance that there is crud left over in ram from a previous
    ; game / boot. We want to make sure that our dma transfers do not send
    ; anything that we do not want in OAM
.clearRAM
    ld  hl,$C000
    ld  bc,$FF
.clearRAMLoop
    ld  a,$0
    ld  [hli],a
    dec bc
    ld  a,b
    or  c
    jr  nz, .clearRAMLoop
.clearRAM2
    ld  hl,$C100
    ld  bc,$FF
.clearRAMLoop2
    ld  a,$0
    ld  [hli],a
    dec bc
    ld  a,b
    or  c
    jr  nz, .clearRAMLoop2
    ret

INITIALIZE_BACKGROUND:
.loadBackground
    ; by default it reads from tile data starting at address $8800
    ; we load our one and only background tile into address $8800
    ld hl, _VRAM8800
    ld de, BGTilesStart
    ld bc, BGTilesEnd - BGTilesStart
    call LOAD_SPRITE
.configureBackground
    ; we are using the default _SCRN0 ($9800) to render the background. Each
    ; address starting at $9800 needs to hold the tile number that should be
    ; used for that specific 8x8 position.
    ;
    ; The screen data is from $9800 -> $9BFF, altough our screen is much smaller
    ; of a space than that. The screen is 20blocks x 18blocks wide.
    ; The first row is address $9800-$9813
    ; The second row is $9820-$9833
    ; ...
    ; The last row is $9A20-$9A33
    ;
    ; You can see that we are skipping a lot of addresses. What happens to
    ; address $9814-981F? These are background tiles that we can fill with info
    ; but they are off the screen, so whatever is put in there is just not shown
    ;
    ; How do they ever get used? The rSCY and rSCX values store the Y,X position
    ; of the start of our visible window. If we were to change these values, the
    ; tiles that are off screen would move into view. But were not gonna worry
    ; about that now, were just gonna load the exact tiles we need
    ld hl, _SCRN0
    ld b, 18
.loadRow
    ld c, 20
.loadColumn
    ; where does $80 come from??
    ; _All_ tile data starts at address $8000 (this is where our sprite data is)
    ; Our tile data is at $8800. There are 128 tiles between $8000 - $8800, which
    ; is why we use $80 (128)
    ld a, $80
    ld [hli], a
    dec c
    ld a, c
    cp a, 0
    jp nz, .loadColumn
    ; we are done with a whole row
    ; we need to update the $hl to be the beginning of the next row
    ; Each row is 32blocks wide, the screen is 20blocks wide, so to get to the
    ; beginning of the next row, we just need to add 12bytes to the current addr
    ld de, $000C
    add hl, de
    ; decrease the row count
    dec b
    ld a, b
    cp a, 0
    jp nz, .loadRow
    ret

INITIALIZE_SPRITE:
.loadSprite
    ld hl, _VRAM8000
    ld de, HeroTilesStart
    ld bc, HeroTilesEnd - HeroTilesStart
    call LOAD_SPRITE
.configureSpriteLeft
    ld hl, vOAM_START
    ld b, 80
    ld c, 80
    ld d, 0
    ld e, 0
    call SET_SPRITE_DATA
.configureSpriteRight
    ld hl, vOAM_START + 4
    ld b, 80
    ld c, 88
    ld d, 2
    ld e, 0
    call SET_SPRITE_DATA
.dmaBothSprites
    call RUN_DMA
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
