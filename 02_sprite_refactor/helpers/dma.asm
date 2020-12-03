SECTION "DMA_OPERATION", ROM0
    ; This section is the process of moving the DMA operation into HRAM
    ; You will see this everywhere, the DMA takes exactly 140 microseconds.
    ; You will also see resources recommending you put it into hram, but not
    ; really explaining how.
    ;
    ; Every single instruction can be written as hexadecimal (ld -> $3E)
    ; so the DMA_CODE section is executable code that performs the dma operation
    ;
    ; So all you have to do is run `call _HRAM` and the CPU will execute whatever
    ; data is in the address starting at $FF80
    ;
    ; @note - our DMA transfer always begins at $C100
MOVE_DMA_TO_HRAM:
    ld hl, vRUN_DMA
    ld de, DMA_CODE
    ld bc, DMA_CODE_END - DMA_CODE
.loadDMA
    ; load each byte one a time
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ; check if finished
    ld a, b
    or a, c
    jr nz, .loadDMA
    ret
    
DMA_CODE:
    ; This sequence of bytes represents the following
    ; Remember the DMA takes exactly 140 micro seconds, and this loop, including
    ; the decrements, jr nz, and ret, total up to the number of instructions to
    ; exactly equal 140 microseconds.
    ;
    ; The DMA sequence MUST be run in HRAM, because HRAM is the only accessible
    ; source of data as soon as the DMA sequence begins. If you have this logic
    ; outside of HRAM, it will begin the DMA, and the program counter will
    ; increase while dma is executing, and when finished will bring you somewhere
    ; further down in your code, different than the immediate next step
    ;
    ;.dmaSprite
    ;   ld a, $C1
    ;   ldh [rDMA], a 
    ;   ld a, $28
    ;.waitForDMA
    ;   dec a
    ;   jr nz, .waitForDMA
    ;   ret
DB $F3, $3E, $C1, $E0, $46, $3E
DB $28, $3D, $20, $FD, $FB, $C9
DMA_CODE_END:

RUN_DMA:
    ; Perform the actual dma operation by loading the the start address into
    ; register A and calling the sequence in HRAM
    ld a, vOAM_DMA_ADDR
    call vRUN_DMA
    ret
