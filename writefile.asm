.data
    filename: .asciiz "/home/noahg/Documents/A3/house_test.ppm"      # filename for output
    testline: .asciiz "line1\nline2\nline3\n"
    readerror: .asciiz "File output error\nError Code: "
    success: .asciiz "File Successfully Created and Written to"
    newline: .asciiz "\n"
    line: .space 8
    linereset: .space 8

.text
.globl main

# Open file, read lines, and print them
main:
    li   $v0, 13       # system call for open file
    la   $a0, filename     # output file name
    li   $a1, 'A'        # Open for writing (flags are 0: read, W/A: write)
    syscall            # open a file (file descriptor returned in $v0)

    move $t0, $v0            # Store the file descriptor in $t0

    li $v0, 16               # Syscall code for close file
    move $a0, $t0            # File descriptor to close
    syscall



    li   $v0, 13       # system call for open file
    la   $a0, filename     # output file name
    li   $a1, '1'        # Open for writing (flags are 0: read, W/A: write)
    syscall  

    move $t0, $v0            # Store the file descriptor in $t0

    blt $v0, $zero, error

writeline:
    move $a0, $t0
    li $v0, 15
    la $a1, testline
    li $a2, 18
    syscall
    j file_created

done:
    # Close the file
    li $v0, 16               # Syscall code for close file
    move $a0, $t0            # File descriptor to close
    syscall
    
    j exit

error:
    move $t0, $v0

    li $v0, 4                # Syscall code for print string
    la $a0, readerror           # Load the address of the buffer
    syscall

    li $v0, 1                # Syscall code for print integer
    move $a0, $t0           # Load the address of the buffer
    syscall

    j exit

file_created:
    li $v0, 4                # Syscall code for print string
    la $a0, success           # Load the address of the buffer
    syscall

    j done

exit:
    # Exit the program
    li $v0, 10               # Syscall code for exit
    syscall