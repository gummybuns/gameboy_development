DMA_SPRITE:
    ; Perform a DMA transfer of sprite data
    ; DMA requires 4 consecutive bytes in memory. These bytes correspond to the
    ; following:
    ;
    ; BYTE 0: Y-coordinate
    ; BYTE 1: X-coordinate
    ; BYTE 2: The tile number. Remember that each tile is 8 bytes. But i am
    ;   pretty sure this is an integer index. (The second tile should have be 1)
    ; BYTE 3: Flags - colors, flip bits, etc. (we are ignoring these for now)
    ;
    ; It is important to
    ; note that the dma transfer addresses always end in $00. So you can only
    ; specify the first half of an address. (ie $C100, $C200, $C300). Because
    ; of that constraint, we are gonna assume that $C000-$C004 will always be
    ; used for the DMA transfer. Writing directly to that address space will be
    ; a bad time. We hard code the start address to $C0, the first byte of
    ; working ram
    ;  
    ; DMA specifies a start address ($C0 for us), but what is the destination?
    ; OAM is $FE00->$FF9F (160 bytes. Remember each sprite is 4 byes so 40
    ; total). From my understanding, DMA will automatically transfer the next
    ; 160 byes starting from the specific start. So if we want to load multiple
    ; sprites, they must all be within the same 160byte address space.
    ;
    ; Lastly, this is still very inefficent, because we are now doing a DMA for
    ; every single sprite. When we should really be updating the 160 byte space
    ; once for all of our sprites, and _then_ performing the DMA
    ; @register {b} the Y coordinate
    ; @register {c} the X coordinate
    ; @register {d} the tile number (0 - 160)
    ; @register {e} flags
.prepare
    ld a, b
    ld [hli], a
    ld a, c
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a
.dmaSprite
    ld hl, sprites
    ld a, h
    ldh [rDMA], a 
    ld a, $28
.waitForDMA
    dec a
    jr nz, .waitForDMA
    ret

