.data 0x10000000
    array: .half 175 483 23 854 39 5 347 273 57 38
.text
    addi $a0, $0, 0x10000000  # load base adress of array
    addi $a1, $0, 0  # set couter for negative values to 0
    addi $a2, $0, 0 # set loop counter to 0
    addi $t4, $0, 0
    addi $t1, $0, 1 # set register t1 to 1
    addi $t2, $0, 10 # set register t1 to 10
    loop:
        addi $a2, $a2, 1 # adds 1 to loop counter
        lh $a3, 0($a0) # loads value in array into a3 register
        slt $t0, $a3, $0 # set t0 to 1 if a3 is negative
        addi $a0, $a0, 2
        beq $t0, $t1, negative # branches to negative if t0=1
        
        beq $a2, $t2, end # goes to end if loop counter is 10
#        addi $a3, $a3, 2 # adds 2 to address
        
        j loop
    negative:
        addi $a1, $a1, 1 # increments negative value counter by 1
        beq $a2, $t2, end # goes to end if loop counter is 10
        addi $a3, $a3, 2 # adds 2 to address
        j loop
    end:
        add $v0, $a1, 0