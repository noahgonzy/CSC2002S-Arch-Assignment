.data
    buffer: .space 1024        # Buffer to read lines
    writestring: .space 100000        # Buffer to read lines
    result_string: .space 8
    line: .space 8
    
    filenameread: .asciiz "/home/noahg/Documents/A3/tree_64_in_ascii_lf.ppm"
    filenamewrite: .asciiz "/home/noahg/Documents/A3/tree_test.ppm"
    
    avecurrent: .asciiz "Average pixel value of the original image:\n"
    avenew: .asciiz "Average pixel value of new image:\n"
    readerror: .asciiz "File I/O error\nError Code:\n"
    filesuccess: .asciiz "Greyscale File Successfully Created\n"
    separator: .asciiz "\n----------------------\n"
    newline: .asciiz "\n"
    
    numcharstowrite: .word 0

.text
.globl main

# Open file, read lines, and print them
main:
    li   $v0, 13       # system call for open file
    la   $a0, filenamewrite     # output file name
    li   $a1, 'W'        # Open for writing (flags are 0: read, W/A: write)
    syscall

    move $t0, $v0 

    li $v0, 16               # Syscall code for close file
    move $a0, $t0            # File descriptor to close
    syscall

    # Open the file for reading
    li $v0, 13               # Syscall code for open file
    la $a0, filenameread         # Load the address of the filename
    li $a1, 0                # Open for reading
    syscall
    li $a0, 0

    ble $v0, $zero, error

    move $t0, $v0            # Store the file descriptor in $t0
    
    li $t6, 0 #line counter
    li $s1, 0 #char counter
    li $s0, 10 #newline char
    li $s4, 48 #char to int conversation
    li $s6, 0 #char counter (WHOLE PROGRAM)

    li $t5, 0 #counter for knowing when to divide by 3 for greyscale 
    li $s8, 0 #number to divide by 3 to calculate greyscale value

    #reserved variables
    #s0, 10, stores newline char
    #s1: char counter to print letter by letter
    #s4, 48, for string to int conversion
    #s8, 255, max rgb value 
    #t5: 3, stores where rgb starts
    #t6: lines counter

read_loop:
    # Read a line from the file
    li $v0, 14               # Syscall code for read from file
    move $a0, $t0            # File descriptor
    la $a1, buffer           # Buffer to store the line
    li $a2, 1                # Maximum number of bytes to read
    syscall

    # Check if EOF (end of file)
    beq $v0, $zero, donereading     # If $v0 is 0, we have reached the end of the file

    lb $t1, 0($a1)

    sb $t1, line($s1)
    addi $s1, $s1, 1
    beq $t1, $s0, processing

    j read_loop

processing:
    addi $t6, $t6, 1
    move $t1, $s1
    li $s1, 0

    move $s7, $s6 # $s7 = char position to write from
    add $s6, $s6, $t1 # s6 = number of chars total, $t1 = number of chars to write
    sw $t1, numcharstowrite

    li $s2, 0
    li $s3, 0

    ble $t6, 4, storefirstfour

    j linetoint

P3toP2:
    addi $s7, $s7, -2
    li $t2, '2'
    sb $t2, writestring($s7)
    j rs

storenewdescription:
    addi $s7, $s7, -2
    lb $t2, writestring($s7)
    addi $s7, $s7, -1
    sb $t2, writestring($s7)
    li $t2, '2'
    addi $s7, $s7, 1
    sb $t2, writestring($s7)
    j rs

setstart:
    move $t3, $s6
    addi $t3, $t3, -1
    j rs

storefirstfour:
    lb $t2, line($s2)
    sb $t2, writestring($s7)

    beq $s7, $s6, resetspaces
    addi $s7, $s7, 1
    addi $s2, $s2, 1
    j storefirstfour

linetoint:
    lb  $t1, line($s3)

    addi $s3, $s3, 1

    beq $t1, $s0, addforgrey

    sub $t1, $t1, $s4
    mul $s2, $s2, $s0
    add $s2, $s2, $t1

    j linetoint

addforgrey:
    addi $t5, $t5, 1
    add $s8, $s8, $s2
    beq $t5, 3, converttogrey
    j read_loop

converttogrey:
    div $s8, $t5
    mflo $s2

    li $t5, 0
    li $s8, 0
    j numtonewstr

numtonewstr:  
    li $t2, 0
    move $s5, $s2
    j getnumlen

getnumlen:
    div $s5, $s0
    mflo $s5

    addi $t2, $t2, 1 #new length stored in $t2
    beq $s5, $zero, assignnl
    j getnumlen

assignnl:
    addi $t2, $t2, 1
    move $t4, $t3
    add $t3, $t2, $t3
    move $t2, $t3
    sb $s0, writestring($t2)
    j newnumtostr

newnumtostr:
    addi $t2, $t2, -1
    beq $t2, $t4, resetspaces
    
    div $s2, $s0
    mflo $s2
    mfhi $t1

    add $t1, $t1, $s4
    sb $t1, writestring($t2)

    j newnumtostr


resetspaces:
    li $t7, 0
    li $t8, 8
    beq $t6, 1, P3toP2
    beq $t6, 2, storenewdescription
    beq $t6, 4, setstart
    j rs

rs:
    sb $zero, line($t7)
    addi $t7, $t7, 1
    beq $t7, $t8, read_loop

    j rs

donereading:
    # Close the file
    li $v0, 16               # Syscall code for close file
    move $a0, $t0            # File descriptor to close
    syscall
    
    j createnewfile

createnewfile:
    li   $v0, 13       # system call for open file
    la   $a0, filenamewrite     # output file name
    li   $a1, 0x41        # Open for writing (flags are 0: read, W/A: write)
    syscall

    move $t0, $v0            # Store the file descriptor in $t0

    blt $v0, $zero, error

    li $v0, 4               # Syscall code for close file
    la $a0, filesuccess            # File descriptor to close
    syscall

    j writing

writing:
    li $v0, 15
    move $a0, $t0
    la $a1, writestring
    move $a2, $s6
    syscall

    j donewriting

donewriting:
    li $v0, 16               # Syscall code for close file
    move $a0, $t0            # File descriptor to close
    syscall

    li $t1, 0
    j tempprint

    j exit

tempprint:
    la $t0, writestring
    li $v0, 4
    move $a0, $t0
    syscall

    j exit

error:
    move $t8, $v0
    li $v0, 4                # Syscall code for print string
    la $a0, readerror           # Load the address of the buffer
    syscall

    li $v0, 1                # Syscall code for print string
    move $a0, $t8           # Load the address of the buffer
    syscall

    j exit

exit:
    # Exit the program
    li $v0, 10               # Syscall code for exit
    syscall