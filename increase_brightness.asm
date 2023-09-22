.data
    buffer: .space 1024        # Buffer to read lines
    writestring: .space 100000        # Buffer to read lines
    result_string: .space 8
    filenameread: .asciiz "/Users/noahgonsenhauser/Library/CloudStorage/Dropbox/UCT/CSC2002S/A3/jet_64_in_ascii_lf.ppm"
    filenamewrite: .asciiz "/home/noahg/Documents/A3/jet_test.ppm"
    avecurrent: .asciiz "Average pixel value of the original image:\n"
    avenew: .asciiz "Average pixel value of new image:\n"
    predec: .asciiz "0."
    readerror: .asciiz "File I/O error"
    separator: .asciiz "\n----------------------\n"
    newline: .asciiz "\n"
    line: .space 8
    numcharstowrite: .word 0
    conversionword: .word 0

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
    li $t5, 4 #line where rgb starts
    li $s1, 0 #char counter
    li $s0, 10 #newline char
    li $s4, 48 #char to int conversation
    li $t3, 0 #stores initial brightness vals
    li $t4, 0 #stores new brightness vals
    li $s6, 0 #char counter (WHOLE PROGRAM)

    #reserved variables
    #s0, 10, stores newline char
    #s1: char counter to print letter by letter
    #s4, 48, for string to int conversion
    #s8, 255, max rgb value
    #t3: stores all brightness vals added for current image
    #t4: stores new brighness vals 
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

    beq $t6, 2, storenewdescription
    ble $t6, $t5, storefirstthree

    j linetoint

#FIX THIS
storenewdescription:
    lb $t2, line($s2)
    sb $t2, writestring($s7)

    beq $s7, $s6, resetspaces
    addi $s7, $s7, 1
    addi $s2, $s2, 1
    j storenewdescription

storefirstthree:
    lb $t2, line($s2)
    sb $t2, writestring($s7)

    beq $s7, $s6, resetspaces
    addi $s7, $s7, 1
    addi $s2, $s2, 1
    j storefirstthree

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

    addi $t2, $t2, 1
    beq $s5, $zero, assignnl
    j getnumlen

# FIX HERE
assignnl:
    lw $t1, numcharstowrite
    addi $t1, $t1, -1

    blt $t1, $t2, incbytes
    beq $t1, $t2, dontincbytes
    j donereading


dontincbytes:
    add $t2, $s7, $t2
    sb $s0, writestring($t2)
    j newnumtostr

incbytes:
    addi $s6, $s6, 1
    add $t2, $s7, $t2
    sb $s0, writestring($t2)

    j newnumtostr

newnumtostr:
    addi $t2, $t2, -1
    div $s2, $s0
    mflo $s2
    mfhi $t1

    add $t1, $t1, $s4
    sb $t1, writestring($t2)

    beq $s2, $zero, resetspaces

    j newnumtostr


resetspaces:
    li $t7, 0
    li $t8, 8
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

    li.d $f0, 255.0
    li.d $f2, 12288.0
    mtc1 $t3, $f4
    cvt.d.w $f4, $f4
    div.d $f6, $f4, $f2
    div.d $f12, $f6, $f0

    li $v0, 4              # Syscall code for print float
    la $a0, avecurrent           # Load the address of the buffer
    syscall

    li $v0, 3              # Syscall code for print double
    syscall

    li $v0, 4              # Syscall code for print float
    la $a0, separator           # Load the address of the buffer
    syscall

    
    mtc1 $t4, $f4
    cvt.d.w $f4, $f4
    div.d $f6, $f4, $f2
    div.d $f12, $f6, $f0

    li $v0, 4              # Syscall code for print float
    la $a0, avenew           # Load the address of the buffer
    syscall

    li $v0, 3              # Syscall code for print float
    syscall

    li $t0, 0
    
    j createnewfile

createnewfile:
    li   $v0, 13       # system call for open file
    la   $a0, filenamewrite     # output file name
    li   $a1, 0x41        # Open for writing (flags are 0: read, W/A: write)
    syscall

    move $t0, $v0            # Store the file descriptor in $t0

    blt $v0, $zero, error

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