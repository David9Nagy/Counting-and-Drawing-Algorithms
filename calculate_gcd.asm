.text
    # Assume that the values for a and b can be found in
    # $a0 and $a1, respectively
    addi $a0, $0, 12
    addi $a1, $1, 9
beginning:
    beq $a0, $a1, equal_to
    slt $a2, $a1, $a0
    beq $a2, $0, less_than
    sub $a0, $a0, $a1
   j beginning
less_than:
    sub $a1, $a1, $a0
    j beginning
equal_to:
    add $v0, $0, $a0

    # TODO: Implement the algorithm using only:
    #   add, sub, slt, beq, j
    
    