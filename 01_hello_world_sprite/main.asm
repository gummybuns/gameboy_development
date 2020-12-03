INCLUDE "hardware.inc"
INCLUDE "hello_world.z80"


SECTION "Header", ROM0[$100]
    ; Our code here
EntryPoint: ; This is where execution begins
    di ; Disable interrupts. That way we can avoid dealing with them, especially since we didn't talk about them yet :p
    jp Start ; Leave this tiny space

REPT $150 - $104
    db 0
ENDR

SECTION "Game code", ROM0
Start:
    ; Turn off the LCD
    ; In order to draw Hello World, we need to wait for VBLANK
    ; VBLANK is when the LCD has finished drawing every pixel and is back at pixel 0,0
    ; We have defined rLY in hardware.inc to be address $FF44. This special address
    ; represents the scanline of LCD. If the value at that address is between 144 and 153
    ; it is considered VBLANK
.waitVBlank
    ld a, [rLY]
    cp 144 ; Check if the LCD is past VBlank
    jr c, .waitVBlank
.disableLCD
    ; Now that we are in VBlank, we do a bunch of magic
    ; We need to turn off the LCD so we have complete control over the VRAM
    ; rLCDC is special address $FF40 describes the state of the LCD screen
    ld a, LCDCF_OFF
    ld [rLCDC], a ; We will have to write to LCDC again later, so it's not a bother, really.
.beginLoadSprite
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
.clearOAM
    ld hl, $C100
    ld b, 160
.clearLoop
    ld a, 0
    ld [hli], a
    dec b
    jr nz, .clearLoop
.configureSprite
    ; OAM is 160 byte long chunk of memory;
    ; Each sprite requires 4 bytes (therefore 40 sprites are allowed at once)
    ; Here is what the 4 bytes represent
    ; 0. Y Location
    ; 1. X Location
    ; 2. Tile number
    ; 3. Flags (not important for now)
    ld hl, $C100
    ld a, 50
    ld [hli], a
    ld a, 40
    ld [hli], a
    ld a, 0
    ld [hli], a
.dmaSprite
    ; C1 is the start adddress of our OAM data. The DMA sequence, which is
    ; invoked by placing data at address $FF46 (rDMA) only allows for a single
    ; 8bit value. It will define the dma address by adding $00 to the end of
    ; what is entered.
    ld a, $C1
    ldh [rDMA], a 
    ld a, $28
.waitForDMA
    dec a
    jr nz, .waitForDMA
.finish
    ; Init display registers
    ; this affects how the display colors look
    ld a, %11100101
    ld [rBGP], a

    ; Set the scroll position to 0,0
    xor a ; ld a, 0
    ld [rSCY], a
    ld [rSCX], a

    ; Shut sound down
    ld [rNR52], a

    ; Turn screen on, display background
    ld a, LCDCF_ON
    or a, LCDCF_OBJON
    ld [rLCDC], a

    ; Lock up
.lockup
    jr .lockup
