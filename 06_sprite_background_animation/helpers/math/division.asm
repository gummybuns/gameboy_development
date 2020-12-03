SECTION "MATH_HELPERS", ROM0

DIVIDE_DE:
	; Divide d by e
    ; puts the quotient in d
    ; puts the remainder in a
    ; @param {d} the base number
    ; @param {e} the number to divide by
    ;
    ; @return {b} the quotient
    ; @return {a} the remainder
    ld b, 0
    ld a, d
.divideLoop
    ; subtract e from a
    sbc a, e
    ; if a is less than zero, done
    jp c, .calculateRemainder
    ; increase quotient b/c there is no remainder yet
    inc b
    ; if a is zero, done
    cp a, 0
    jp z, .done
    jp .divideLoop
.calculateRemainder
    add a, e
.done
    ret
