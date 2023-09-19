.data
    buffer: .space 1024        # Buffer to read lines
    filename: .asciiz "/home/noahg/Documents/A3/testhouse.ppm"
    testline: "line1\nline2\nline3"
    readerror: .asciiz "File input error"
    newline: .asciiz "\n"
    line: .space 8
    linereset: .space 8

.text
.globl main

# Open file, read lines, and print them
main:
    # Open the file for reading
    li $v0, 13               # Syscall code for open file
    la $a0, filename         # Load the address of the filename
    li $a1, 1                # Open for reading
    li $a2, 0                # Mode (ignored for reading)
    syscall

    ble $v0, $zero, error

    move $t0, $v0            # Store the file descriptor in $t0
    
    li $s1, 0 #char counter
    li $s0, 10 #newline char


writeline:
    move $a0, $t0
    la $v0, 15
    la $a1, testline
    syscall
    j done

done:
    # Close the file
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