INCLUDE "hardware.inc"


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
    or a, LCDCF_BGON
    ld [rLCDC], a

    ; Lock up
.lockup
    jr .lockup

SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr"
FontTilesEnd:

SECTION "Hello World string", ROM0

HelloWorldStr:
    db "Hello World!", 0
