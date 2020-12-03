SECTION "UPDATE_BACKGROUND", ROM0

UPDATE_BACKGROUND:
    ; we want the background to move exactly 8px any time a user takes one step
    ; in order to do that, we need to decide on the number of cycles it takes
    ; to perform a single step animation. vWALK_START is 64. Any time a user takes
    ; a step, the counter will decrease until zero, signifying the step is done
    ;
    ; This means there are 64 loops that happen before the user takes another step
    ; and by the end of the 64 loops, the background should move 8px. Therefore
    ; 64 / 8 = 8 (the background move animation should be 1/8 the speed of the
    ; walking animation)
    ;
    ; So whenever the walk count is divisible by 8, we should move the background
    ; one pixel
    ;
    ; Does it makes sense why the walking speed is 64? We need a number that is
    ; divisible by 8. I chose 64 because it seems like a decent speed of all of
    ; the animation together
    ;
    ; register d - during the loop stores the current walking value
    ; register e - store 8, to divide register d
    ; register b - stores the quotient of d / e
    ; register c - stores the value to change the background by (+/- 1)
    ; register hl - store rSCY or rSX depending on the direction that should
    ;   change
    ld a, [walking]
    cp a, 0
    jp z, .done
    ld a, [direction]
.checkRight
    ld hl, rSCX
    ld c, 1
    cp a, vDIRECTION_RIGHT
    jp z, .updateBackground
.checkLeft
    ld c, -1
    cp a, vDIRECTION_LEFT
    jp z, .updateBackground
.checkUp
    ld hl, rSCY
    cp a, vDIRECTION_UP
    jp z, .updateBackground
.elseDown
    ld c, 1
.updateBackground
    ld a, [walking]
    ld d, a
    ld e, 8
    call DIVIDE_DE
    ; only update the coordinate if the number is divisble by 8
    cp a, 0
    jp nz, .done
    ld a, [hl]
    add a, c
    ld [hl], a
.done
    ret
