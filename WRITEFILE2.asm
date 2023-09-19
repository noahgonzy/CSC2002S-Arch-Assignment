.data
    fout:   .asciiz "/home/noahg/Documents/A3/test.txt"      # filename for output

.text
.globl main

# Open file, read lines, and print them
main:
    li   $v0, 13       # system call for open file
    la   $a0, fout     # output file name
    li   $a1, 1        # Open for writing (flags are 0: read, 1: write)
    li   $a2, 0        # mode is ignored
    syscall            # open a file (file descriptor returned in $v0)
    move $t0, $v0      # Store the file descriptor in $t0

done:
    # Close the file
    li $v0, 16               # Syscall code for close file
    move $a0, $t0            # File descriptor to close
    syscall

exit:
    # Exit the program
    li $v0, 10               # Syscall code for exit
    syscall