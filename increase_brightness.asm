.data
    buffer: .space 128        # Buffer to read lines
    filename: .asciiz "/Users/noahgonsenhauser/Library/CloudStorage/Dropbox/UCT/CSC2002S/A3/house_64_in_ascii_cr.ppm"

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
    move $t0, $v0            # Store the file descriptor in $t0

read_loop:
    # Read a line from the file
    li $v0, 14               # Syscall code for read from file
    move $a0, $t0            # File descriptor
    la $a1, buffer           # Buffer to store the line
    li $a2, 128              # Maximum number of bytes to read
    syscall

    # Check if EOF (end of file)
    beq $v0, $zero, done     # If $v0 is 0, we have reached the end of the file

    # Print the line
    li $v0, 4                # Syscall code for print string
    move $a0, $a1            # Load the address of the buffer
    syscall

    j read_loop              # Continue reading lines

done:
    # Close the file
    li $v0, 16               # Syscall code for close file
    move $a0, $t0            # File descriptor to close
    syscall

exit:
    # Exit the program
    li $v0, 10               # Syscall code for exit
    syscall