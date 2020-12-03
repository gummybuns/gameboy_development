SECTION "SETUP", ROM0

CLEAR_RAM:
    ; Clear our Sprite Workspace
    ; There is a chance that there is crud left over in ram from a previous
    ; game / boot. We want to make sure that our dma transfers do not send
    ; anything that we do not want in OAM
.clearRAM0
    ld  hl,$C000
    ld  bc,$FF
.clearRAMLoop0
    ld  a,$0
    ld  [hli],a
    dec bc
    ld  a,b
    or  c
    jr  nz, .clearRAMLoop0
.clearRAM1
    ld  hl,$C100
    ld  bc,$A0
.clearRAMLoop1
    ld  a,$0
    ld  [hli],a
    dec bc
    ld  a,b
    or  c
    jr  nz, .clearRAMLoop1
    ret

CONFIGURE_TIMER:
    ; The timer speed can be adjusted by configuring $FF07 (rTAC)
    ; BITS 0-1
    ; 00 - CPU CLOCK / 1024 4096Hz
    ; 01 - CPU CLOCK / 16   262144Hz
    ; 10 - CPU CLOCK / 64   65536Hz
    ; 11 - CPU CLOCK / 256  16384Hz

    ; BIT 2 - enable/disable
    ; We will make sure the timer is set to %0100, which should be the slowest
    ld hl, rTAC
    ld a, %0100
    ld [hl], a
    ret

CONFIGURE_INTERRUPTS:
    ; The IME Flag is the master control of interrupts. It is toggled using the
    ; di (disable) and ei (enable) flags

    ; There are 4 interrupts that are configurable at addr $FFFF (rIE)
    ; Address $FF0F (rIF) shows the state of each interrupt. A bit will be high
    ; when the interrupt is triggered
    ;
    ; bit 0: V-Blank
    ; bit 1: LCD STAT
    ; bit 2: Timer
    ; bit 3: Serial
    ; bit 4: Joypad
    ;
    ; * how are there 5 bits at address FFFF?
    ; * from what I have read, the Joypad interrupt is pretty much never used
    ;
    ; When an interrupt gets executed, the corresponding bit in $FF0F is unset
    ; AND the IME flag, so no interrupts can be triggered while handling one.
    ; Typically the handler will use `reti` instead of `ret` to return and
    ; reenable interrupts
    ei
    ld hl, rIE
    ld a, %0100
    ld [hl], a
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
