.data
    buffer: .space 1024        # Buffer to read lines
    result_string: .space 8
    filenameread: .asciiz "/home/noahg/Documents/A3/house_64_in_ascii_lf.ppm"
    filenamewrite: .asciiz "/home/noahg/Documents/A3/house_test.ppm"
    readerror: .asciiz "File I/O error"
    separator: .asciiz "----------------------\n"
    newline: .asciiz "\n"
    line: .space 8

.text
.globl main

# Open file, read lines, and print them
main:
    # Open the file for reading
    li $v0, 13               # Syscall code for open file
    la $a0, filenameread         # Load the address of the filename
    li $a1, 0                # Open for reading
    syscall
    li $a0, 0

    ble $v0, $zero, error

    move $t0, $v0            # Store the file descriptor in $t0
    
    li $t6, 0 #line counter
    li $t5, 3 #line where rgb starts
    li $s1, 0 #char counter
    li $s0, 10 #newline char
    li $s4, 48 #char to int conversation
    li $s8, 255 #max rgb value
    li $t3, 0 #stores initial brightness vals
    li $t4, 0 #stores new brightness vals

    #reserved variables
    #s0, 10, stores newline char
    #s1: char counter to print letter by letter
    #s4, 48, for string to int conversion
    #s8, 255, max rgb value
    #t3: stores all brightness vals added for current image
    #t4: stores new brighness vals 
    #t5: 3, stores where rgb starts
    #t6: lines counter
    #t7: byte counter for resetting line (ONLY WHEN RESETTING LINE)
    #t8: stores the number 8 for resetting line (ONLY WHEN RESETTING LINE)

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

    ble $t6, $t5, resetspaces

    li $s2, 0
    li $s3, 0

    j linetoint


linetoint:
    lb  $t1, line($s3)

    addi $s3, $s3, 1

    beq $t1, $s0, brighten

    sub $t1, $t1, $s4
    mul $s2, $s2, $s0
    add $s2, $s2, $t1

    j linetoint

brighten:
    add $t3, $t3, $s2

    addi $s2, $s2, 10

    bgt $s2, 255, toobright

    j numtonewstr

toobright:
    li $s2, 255

    j numtonewstr

numtonewstr:
    add $t4, $t4, $s2   
    li $t2, 0
    move $s5, $s2
    j getnumlen

getnumlen:
    div $s5, $s0
    mflo $s5

    beq $s5, $zero, assignnl
    addi $t2, $t2, 1
    j getnumlen

assignnl:
    addi $t2, $t2, 1
    sb $s0, result_string($t2)
    j newnumtostr


newnumtostr:
    addi $t2, $t2, -1
    div $s2, $s0
    mflo $s2
    mfhi $t1

    add $t1, $t1, $s4
    sb $t1, result_string($t2)
    beq $s2, $zero, printnewnum

    j newnumtostr
    

printnewnum:
    li $v0, 4                # Syscall code for print string
    la $a0, result_string           # Load the address of the buffer
    syscall

    j resetspaces


resetspaces:
    sb $zero, line($t7)
    sb $zero, result_string($t7)
    addi $t7, $t7, 1
    beq $t7, $t8, read_loop

    j resetspaces


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