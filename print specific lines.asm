.data
    buffer: .space 1024        # Buffer to read lines
    filename: .asciiz "/Users/noahgonsenhauser/Library/CloudStorage/Dropbox/UCT/CSC2002S/A3/house_64_in_ascii_lf.ppm"
    readerror: .asciiz "File input error"
    newline: .asciiz "\n"

.text
.globl main

# Open file, read lines, and print them
main:
    # Open the file for reading
    li $v0, 13               # Syscall code for open file
    la $a0, filename         # Load the address of the filename
    li $a1, 0                # Open for reading
    li $a2, 0                # Mode (ignored for reading)
    syscall

    ble $v0, $zero, error

    move $t0, $v0            # Store the file descriptor in $t0

    li $t8, 6 #last line to print
    li $t6, -1 #first line to print (-1)
    
    li $t7, 0 #line counter
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
    beq $t7, $t8, done

    lb $t1, 0($a1)

    bgt $t7, $t6, printchar 
    beq $t1, $s0, addlinecounter     # If it's a newline, we have reached the end of the line

    j read_loop              # Continue reading lines

printchar:
    # Print the line
    li $v0, 11               # Syscall code for print character
    move $a0, $t1            # Load the character to print
    syscall 

    beq $t1, $s0, addlinecounter     # If it's a newline, we have reached the end of the line

    j read_loop

addlinecounter:
    addi $t7, $t7, 1
    j read_loop

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