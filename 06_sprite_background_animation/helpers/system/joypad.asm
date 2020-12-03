SECTION "JOYPAD", ROM0

READ_JOYPAD:
    ;select dpad
    ld  a, %00100000

    ;takes a few cycles to get accurate reading
    ld  [rP1], a
    ld  a, [rP1]
    ld  a, [rP1]
    ld  a, [rP1]
    ld  a, [rP1]

    ;complement a
    cpl

    ;select dpad buttons
    and %00001111
    swap a
    ld  b, a

    ;select other buttons
    ld  a, %00010000

    ;a few cycles later..
    ld  [rP1], a  
    ld  a, [rP1]
    ld  a, [rP1]
    ld  a, [rP1]
    ld  a, [rP1]
    cpl
    and %00001111
    or  b

    ;you get the idea
    ld  b, a
    ld  a, [joypad_down]
    cpl
    and b
    ld  [joypad_pressed], a
    ld  a,b
    ld  [joypad_down], a
    ret

JOY_RIGHT:
    and %00010000
    cp  %00010000
    jp  nz, JOY_FALSE
    ld  a,$1
    ret
JOY_LEFT:
    and %00100000
    cp  %00100000
    jp  nz, JOY_FALSE
    ld  a, $1
    ret
JOY_UP:
    and %01000000
    cp  %01000000
    jp  nz, JOY_FALSE
    ld  a, $1
    ret
JOY_DOWN:
    and %10000000
    cp  %10000000
    jp  nz, JOY_FALSE
    ld  a, $1
    ret
JOY_A:
    and %00000001
    cp  %00000001
    jp  nz, JOY_FALSE
    ld  a, $1
    ret
JOY_B:
    and %00000010
    cp  %00000010
    jp  nz, JOY_FALSE
    ld  a, $1
    ret
JOY_SELECT:
    and %00000100
    cp  %00000100
    jp  nz, JOY_FALSE
    ld  a, $1
    ret
JOY_START:
    and %00001000
    cp  %00001000
    jp  nz, JOY_FALSE
    ld  a, $1
    ret
JOY_FALSE:
    ld  a, $0
    ret

