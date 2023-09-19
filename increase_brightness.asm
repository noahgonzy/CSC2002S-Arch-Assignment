.data
    buffer: .space 1024        # Buffer to read lines
    filenameread: .asciiz "/home/noahg/Documents/A3/house_64_in_ascii_lf.ppm"
    filenamewrite: .asciiz "/home/noahg/Documents/A3/house_test.ppm"
    readerror: .asciiz "File I/O error"
    newline: .asciiz "\n"
    line: .space 8
    linereset: .space 8

.text
.globl main

# Open file, read lines, and print them
main:
    # Open the file for reading
    li $v0, 13               # Syscall code for open file
    la $a0, filenameread         # Load the address of the filename
    li $a1, 0                # Open for reading
    syscall

    ble $v0, $zero, error

    move $t0, $v0            # Store the file descriptor in $t0

    li $v0, 13               # Syscall code for open file
    la $a0, filenamewrite         # Load the address of the filename
    li $a1, 'A'                # Open for writing
    syscall

    ble $v0, $zero, error

    move $s8, $v0
    
    li $t6, 0 #line counter
    li $t5, 3 #line where rgb starts
    li $s1, 0 #char counter
    li $s0, 10 #newline char

read_loop:
    # Read a line from the file
    li $v0, 14               # Syscall code for read from file
    move $a0, $t0            # File descriptor
    la $a1, buffer           # Buffer to store the line
    li $a2, 1                # Maximum number of bytes to read
    syscall

    # Check if EOF (end of file)
    beq $v0, $zero, done     # If $v0 is 0, we have reached the end of the file

    lb $t1, 0($a1)

    sb $t1, line($s1)
    addi $s1, $s1, 1
    beq $t1, $s0, resetcounter

    j read_loop

resetcounter:
    addi $t6, $t6, 1
    li $s1, 0

    li $t7, 0
    li $t8, 8

    ble $t6, $t5, resetspace

    li $v0, 4
    la $a0, line
    syscall

    j resetspace

resetspace:
    sb $zero, line($t7)
    addi $t7, $t7, 1
    beq $t7, $t8, read_loop

    j resetspace

done:
    # Close the file
    li $v0, 16               # Syscall code for close file
    move $a0, $t0            # File descriptor to close
    syscall

    li $v0, 16               # Syscall code for close file
    move $a0, $t0            # File descriptor to close
    syscall
    
    j exit

error:
    li $v0, 4                # Syscall code for print string
    la $a0, readerror           # Load the address of the buffer
    syscall

    j exit

exit:
    # Exit the program
    li $v0, 10               # Syscall code for exit
    syscall