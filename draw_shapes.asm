######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       4
# - Unit height in pixels:      4
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################


.data 0x10010000
THE_COLOUR:
    .word	0x885A89    # an initial colour


.text
main:
    # load a colour to draw
    lui $t0, 0x88
    ori $t0, $0, 0x5A89
    # paint the first unit with the colour
    sw $t0, 0($gp)

    # TODO
    addi $a0 $0 0
    addi $a1 $0 0
    addi $a2 $0 0
    addi $a3 $0 20
    jal draw_line
    addi $a0 $0 0
    addi $a1 $0 0
    addi $a2 $0 30
    addi $a3 $0 0
    jal draw_line
    addi $a0 $0 5
    addi $a1 $0 30
    addi $a2 $0 30
    addi $a3 $0 5
    jal draw_line
exit:
	addi $v0, $0, 10
	syscall

# abs_val(x) -> x
# Returns the absolute value of x
abs_val:
    # PROLOGUE
    addi $sp $sp -8
    sw $ra, 4($sp)
    sw $t0, 0($sp)
    # BODY
    slt $t0 $a0 $0 # sets to 0 if 0 <= a0 (positive)
    addi $v0 $a0 0 # sets v0 to default a0
    beq $t0 $0 skip
    sub $v0 $0 $a0 # saves absolute val to v0
    skip:
    # EPLIGOUE
    lw $t0, 0($sp)
    lw $ra, 4($sp)
    addi $sp $sp 8
    jr $ra


# draw_line(x0, y0, x1, y1) -> void
#  Draw astraight line from location (x0, y0) to location (x1, y1)
draw_line:
    # PROLOGUE
    addi $sp $sp, -48
    sw $t0, 44($sp)
    sw $t1, 40($sp)
    sw $t2, 36($sp)
    sw $t3, 32($sp)
    sw $t4, 28($sp)
    sw $t5, 24($sp)
    sw $t6, 20($sp)
    sw $t7, 16($sp)
    sw $t8, 12($sp)
    sw $t9, 8($sp)
    sw $s0, 4($sp)
    sw $ra, 0($sp)

    # BODY
    # store all x and y vals in t regs
    addi $t0 $a0 0 #x0
    addi $t1 $a1 0 #y0
    addi $t2 $a2 0 #x1
    addi $t3 $a3 0 #y1
    # finding DeltaX
    sub $t4 $t2 $t0 # t4 = DeltaX
    addi $a0 $t4 0 # set arg0
    jal abs_val # call abs_val
    addi $t4 $v0 0 # store Delta X in t4
    # finding DeltaY
    sub $t5 $t3 $t1 # t5 = DeltaY
    addi $a0 $t5 0 # set arg0
    jal abs_val
    addi $t5 $v0 1 # store Delta Y in t5
    sub $t5 $0 $t5 # take negative
    # Finding Error
    add $t6 $t4 $t5 # store Error in t6
    # Setting SlopeX and SlopeY
    slt $t7 $t0 $t2 # set t7 to 1 if x0<x1
    addi $t8 $0 1 # set t8 to 1 to check next line
    beq $t7 $t8 skip2 # if t7 is 1 skip otherwise set to -1
    addi $t7 $0 -1 # otherwise set to -1
    skip2:
    slt $t8 $t1 $t3 # set t8 to 1 if y0<y1
    addi $t9 $0 1 # set t9 to 1 to check next line
    beq $t8 $t9 skip3 # if t8 is 1 skip otherwise set to -1
    addi $t8 $0 -1 # otherwise set to -1
    skip3:
    # loop
    looping:
    # set args for fill_unit
    addi $a0 $t0 0
    addi $a1 $t1 0
    lw $a2, THE_COLOUR
    jal fill_unit # call fill_unit
    sll $t9 $t6 1 # multiply Error by 2 to get Error2 into t9 reg
    # first if condition
    slt $s0 $t9 $t5 # s0 is 1 when t5(DeltaY) > t9(Error2)
    beq $t0 $t2 skip4 # skips if body if x0=x1
    bne $s0 $0 skip4 # skips past if body when s0=1
    add $t6 $t6 $t5 # update error
    add $t0 $t0 $t7 #update x0
    skip4:
    # second if condition
    slt $s0 $t4 $t9 # s0 is 1 when t4(DeltaX) < t9(Error2)
    beq $t1 $t3 skip5 # skips if body if x0=x1
    bne $s0 $0 skip5 # skips past if body when s0=1
    add $t6 $t6 $t4 # update error
    add $t1 $t1 $t8 #update y0
    # stops loop if both x0=x1 and y0=y1
    skip5:
    beq $t0 $t2 exit1
    j looping
    exit1:
    beq $t1, $t3 exit2
    j looping
    exit2:
    # EPLIGOUE
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $t9, 8($sp)
    lw $t8, 12($sp)
    lw $t7, 16($sp)
    lw $t6, 20($sp)
    lw $t5, 24($sp)
    lw $t4, 28($sp)
    lw $t3, 32($sp)
    lw $t2, 36($sp)
    lw $t1, 40($sp)
    lw $t0, 44($sp)
    addi $sp $sp, 48
    jr $ra

# fill_unit(x, y, colour) -> void
#   Draw a unit with the given colour at location (x, y).
fill_unit:
    # PROLOGUE
    addi $sp $sp -4
    sw $ra, 0($sp)

    # BODY
    sll $a0 $a0 2
    sll $a1 $a1 8
    add $a0 $a0 $a1
    add $a0, $gp, $a0
    sw $a2, ($a0)

    # EPILOGUE
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra


# draw_horizontal_line(x, y, size) -> void
#   Draw a straight line that starts at (x, y) and ends at (x + width, y)
#   using the colour found at THE_COLOUR.
draw_horizontal_line:
    # PROLOGUE
    addi $sp $sp, -16
    sw $t0, 12($sp)
    sw $t1, 8($sp)
    sw $t2, 4($sp)
    sw $ra, 0($sp)

    # BODY
    add $t0 $a0 $a2  # set endpoint
    addi $t1 $a0 0 # store a0(x)
    addi $t2 $a1 0 # store a1(y)
    lw $a2, THE_COLOUR # store color in a2
    loop:
        addi $a0 $t1 0 # set a0 to t1 (x)
        addi $a1 $t2 0 # ensure a1 is y
        beq $t1, $t0 end_loop# check if reached endpoint
        jal fill_unit # calls fill_unit
        addi $t1, $t1 1 # increments x by 1
        j loop #loops back
    end_loop:

    # EPILOGUE
    lw $ra, 0($sp)
    lw $t2, 4($sp)
    lw $t1, 8($sp)
    lw $t0, 12($sp)
    addi $sp, $sp, 16
    jr $ra


# draw_vertical_line(x, y, size) -> void
#   Draw a straight line that starts at (x, y) and ends at (x, y + size)
#   using the colour found at THE_COLOUR.
draw_vertical_line:
    # PROLOGUE
    addi $sp $sp, -16
    sw $t0, 12($sp)
    sw $t1, 8($sp)
    sw $t2, 4($sp)
    sw $ra, 0($sp)

    # BODY
    add $t0 $a1 $a2  # set endpoint
    addi $t1 $a0 0 # store a0(x)
    addi $t2 $a1 0 # store a1(y)
    lw $a2, THE_COLOUR # store color in a2
    loop2:
        addi $a0 $t1 0 # ensure a0 is x
        addi $a1 $t2 0 # set a1 to t2 (updates y)
        beq $t2, $t0 end_loop2 # check if reached endpoint
        jal fill_unit # calls fill_unit
        addi $t2, $t2 1 # increments y by 1
        j loop2 #loops back
    end_loop2:

    # EPILOGUE
    lw $ra, 0($sp)
    lw $t2, 4($sp)
    lw $t1, 8($sp)
    lw $t0, 12($sp)
    addi $sp, $sp, 16
    jr $ra


# draw_rectangle(x, y, width, height) -> void
#   Draw the outline of a rectangle whose top-left corner is at (x, y)
#   and bottom-right corner is at (x + width, y + height) using the
#   colour found at THE_COLOUR.
draw_rectangle:
    # PROLOGUE
    addi $sp $sp, -16
    sw $t0, 12($sp)
    sw $t1, 8($sp)
    sw $t2, 4($sp)
    sw $ra, 0($sp)

    # BODY
    add $t0 $a1 $a3  # set endpoint (y endpoint)
    addi $t1 $a0 0 # store a0(x)
    addi $t2 $a1 0 # store a1(y)
    addi $t3 $a2 0 # store width
    loop3:
        addi $a0 $t1 0 # ensure a0 is x
        addi $a1 $t2 0 # set a0 to t1 (updates y)
        addi $a2 $t3 0 # stores width in a2
        beq $t2, $t0 end_loop3 # check if reached endpoint
        jal draw_horizontal_line # calls fill_unit
        addi $t2, $t2 1 # increments y by 1
        j loop3 #loops back
    end_loop3:

        

    # EPILOGUE
    lw $ra, 0($sp)
    lw $t2, 4($sp)
    lw $t1, 8($sp)
    lw $t0, 12($sp)
    addi $sp, $sp, 16
    jr $ra
