.data
    buffer: .space 1024        # Buffer to read lines
    writestring: .space 100000        # Buffer to read lines
    result_string: .space 8
    line: .space 8

    filenameread: .asciiz "/home/noahg/Documents/A3/jet_64_in_ascii_lf.ppm"
    filenamewrite: .asciiz "/home/noahg/Documents/A3/jet_brighter.ppm"
    
    avecurrent: .asciiz "Average pixel value of the original image:\n"
    avenew: .asciiz "Average pixel value of new image:\n"
    readerror: .asciiz "File I/O error\nError Code:\n"
    separator: .asciiz "\n----------------------\n"
    newline: .asciiz "\n"
    
    numcharstowrite: .word 0

.text
.globl main

#Create new file, then open read file and save descriptor
main:
    li   $v0, 13       # system call for open file
    la   $a0, filenamewrite     # output file name
    li   $a1, 'W'        # Open for writing (flags are 0: read, W/A: write)
    syscall

    #show error if there's an error creating the file
    ble $v0, $zero, error

    move $t0, $v0 #store file descriptor

    li $v0, 16               # Syscall code for close file
    move $a0, $t0            # File descriptor to close
    syscall

    # Open the file for reading
    li $v0, 13               # Syscall code for open file
    la $a0, filenameread         # Load the address of the filename
    li $a1, 0                # Open for reading
    syscall

    #show error if there's an error reading
    ble $v0, $zero, error

    move $t0, $v0            # Store the file descriptor in $t0
    
    li $t6, 0 #lines counter
    li $t8, 8 #loop counter for space resetting
    li $s1, 0 #char counter
    li $s0, 10 #newline char, and value for int to string conversion
    li $s4, 48 #char to int conversation
    li $t3, 0 #stores initial brightness vals for average
    li $t4, 0 #stores new brightness vals for average
    li $s6, 0 #char counter for whole program (for writing string)

    #reserved variables
    #s0, 10, stores newline char
    #s1: char counter to print letter by letter
    #s4, 48, for string to int conversion
    #t3: stores all brightness vals added for current image
    #t6: lines counter

#reading in the line (adding the chars to the line variable until a newline char is reached)
read_loop:
    # Read a line from the file
    li $v0, 14               # Syscall code for read from file
    move $a0, $t0            # File descriptor
    la $a1, buffer           # Buffer to store the line
    li $a2, 1                # Maximum number of bytes to read
    syscall

    # Check if EOF (end of file)
    beq $v0, $zero, donereading     # If $v0 is 0, we have reached the end of the file

    lb $t1, 0($a1) #get the value of the byte being read from the buffer 

    sb $t1, line($s1) #add this byte to the end of the line
    addi $s1, $s1, 1 #add 1 to the value of the loop to know which value to get
    beq $t1, $s0, processing #if a newline character is found, start processing that line

    j read_loop #run this loop again to add onto the line string

#processing counter variables and checking if still storing description
processing:
    addi $t6, $t6, 1 #add 1 to the line counter
    
    move $s7, $s6 # $s7 = char position to write from
    add $s6, $s6, $s1 # s6 = number of chars total, $t1 = number of chars to write
    sw $s1, numcharstowrite

    li $s1, 0
    li $s2, 0
    li $s3, 0

    ble $t6, 4, storefirstfour #if still processing the first 4 lines, just add them directly to the writestring without processing

    j linetoint #convert line to be processed to an int

#change description from '# tre' to '# teb', or '# jet' to '# jtb' as in 'brighter'
storenewdescription:
    addi $s7, $s7, -2 #go back 2 bytes and get the last char of the line
    lb $t1, writestring($s7) 

    li $t2, 'b'
    sb $t2, writestring($s7) #store a number 2 in that place

    addi $s7, $s7, -1 #go back 1 more byte
    sb $t1, writestring($s7) #set that byte to the same byte as the one that the char at the end initially was
    #ie: hse become he2, jet become jt2, or tre becomes te2
    
    j rs #jump to resetting the 'space' variables

#store the values of the first 4 strings from the file (descriptions) in the writing string
storefirstfour:
    lb $t2, line($s2) #load the bytes into $t2 from the line
    sb $t2, writestring($s7) #store the btes from $t2 at the end of the writing string

    beq $s7, $s6, resetspaces #if all chars have been written, reset the 'space' variables
    addi $s7, $s7, 1 #increment the writing string counter
    addi $s2, $s2, 1 #increment the line counter
    j storefirstfour

#extract integer value from string in line
linetoint:
    lb  $t1, line($s3) #get the variable of the char

    addi $s3, $s3, 1 #add 1 to the loop for the next char

    beq $t1, $s0, brighten #if at end of line, jump to the next step, adding 10 to the value

    sub $t1, $t1, $s4 #get the int value by subbing the char value of '0', which equals 48
    mul $s2, $s2, $s0 #timsing $s2 by 10
    add $s2, $s2, $t1 #adding the value of the integer to the end of $s2

    j linetoint #restarting the loop

#add 10 to the value extracted
brighten:
    add $t3, $t3, $s2 #add value extracted to total for average calculation
    
    addi $s2, $s2, 10 #add 10 to that value

    bgt $s2, 255, toobright #if the value exceeds 255, set it to only 255

    j numtonewstr #convert the new number back to a string

#reset back to 255 if the number is too bright
toobright:
    li $s2, 255 #if the value exceeds 255, set it to only 255

    j numtonewstr #convert the new number back to a string

#setting up variables to get the length of the new number
numtonewstr:  
    add $t4, $t4, $s2  #add new value extracted to total for average calculation
    li $t2, 0 #set incrementer to 0
    move $s5, $s2 #store number in $s5 for calculating down in a loop without losing $s2
    j getnumlen

#getting length of new number (brightened number)
getnumlen:
    div $s5, $s0 #dividing by 10 till the value of the division is 0
    mflo $s5

    addi $t2, $t2, 1 #new length stored in $t2
    beq $s5, $zero, assignnl #jumps to assign new length function
    j getnumlen

#figure out if the number of chars is now greater than it was before 10 was added
assignnl:
    lw $t1, numcharstowrite #get the number of chars that needed to be manipulated
    addi $t1, $t1, -1

    blt $t1, $t2, incbytes #if the numbers are different, increment the byte counter by 1 to write the correct amount
    beq $t1, $t2, dontincbytes #if the numbers are the same, just start writing in the correct place
    j donereading #skip to end if neither are true as there must be an issue

#dont increment the $s76 counter (ie, counter of all numbers)
dontincbytes:
    add $t2, $s7, $t2 #set $t2 to the number of bytes to start writing from
    sb $s0, writestring($t2) #set newline char at the end

    j newnumtostr #set newline char at the end

#increment the $s6 counter (ie, counter of all numbers)
incbytes:
    addi $s6, $s6, 1 #increment char counter to allign number of bytes to be written
    add $t2, $s7, $t2 #set $t2 to the number of bytes to start writing from
    sb $s0, writestring($t2) #set newline char at the end

    j newnumtostr #set newline char at the end

#convert new number back to a string and add to writing string
newnumtostr:
    addi $t2, $t2, -1 #decrement $t2
    div $s2, $s0 #divide our new number by 10
    mflo $s2 
    mfhi $t1

    add $t1, $t1, $s4 #add new number to 48 to get the char value
    sb $t1, writestring($t2) #store char value in the correct place in the writestring

    beq $s2, $zero, resetspaces #if the resulting number after dividing by 10 is 0, then reset the space variables

    j newnumtostr #loop back

#setup for resetting values of the line variable
resetspaces:
    li $t7, 0 #reset space loop counter
    beq $t6, 2, storenewdescription #if on line 2, set the new description to be '2nd' version
    j rs #jump to reset loop

#reset values of the line variable
rs:
    sb $zero, line($t7) #set the value of each char in 'line' to 0
    addi $t7, $t7, 1
    beq $t7, $t8, read_loop #if looped through all values, jump back to the reading loop

    j rs

#completed reading from file, close file
donereading:
    # Close the file
    li $v0, 16               # Syscall code for close file
    move $a0, $t0            # File descriptor to close
    syscall

    li.d $f0, 255.0 #load address $f0, and $f1 for double precision with value 255 (max rgb value)
    li.d $f2, 12288.0 #load address $f2, and $f3 for double precision with value 12288 (amount of pixels)
    mtc1 $t3, $f4 #store value of sum of initial rbg values in $f4 and $f5
    cvt.d.w $f4, $f4 #convert that value to a float
    div.d $f6, $f4, $f2 #divide the rgb values by 12288 to get the average pixel value out of 255
    div.d $f12, $f6, $f0 #divide the rgb values by 255 to get the average pixel value out of 1

    li $v0, 4              # Syscall code for print string
    la $a0, avecurrent           # Load the address of the buffer
    syscall

    li $v0, 3              # Syscall code for print double which prints whatever is in $f12
    syscall

    li $v0, 4              # Syscall code for print string
    la $a0, separator           # Load the address of the buffer
    syscall

    
    mtc1 $t4, $f4 #store value of sum of updated rbg values in $f4 and $f5
    cvt.d.w $f4, $f4 #convert that value to a float
    div.d $f6, $f4, $f2 #divide the rgb values by 12288 to get the average pixel value out of 255
    div.d $f12, $f6, $f0 #divide the rgb values by 255 to get the average pixel value out of 1

    li $v0, 4              # Syscall code for print string
    la $a0, avenew           # Load the address of the buffer
    syscall

    li $v0, 3              # Syscall code for print double which prints whatever is in $f12
    syscall

    li $t0, 0
    
    j filewriting

#open the file that needs to be written into
filewriting:
    li   $v0, 13       # system call for open file
    la   $a0, filenamewrite     # output file name
    li   $a1, 0x41        # Open for writing (flags are 0: read, W/A: write)
    syscall

    move $t0, $v0            # Store the file descriptor in $t0

    blt $v0, $zero, error #show error if there's an error reading

    j writing #start writing to file

#write all new lines to file
writing:
    li $v0, 15 #load file writing service
    move $a0, $t0 #move the file descriptor into the argument register
    la $a1, writestring #move the string to be written into the second argument register
    addi $s6, $s6, -1 #minus 1 from the $s6 register
    move $a2, $s6 #move the value of the $s6 value into the third argument register, so that the program knows how many bytes to write
    syscall

    j donewriting #close the file

#close file after writing
donewriting:
    li $v0, 16               # Syscall code for close file
    move $a0, $t0            # File descriptor to close
    syscall

    j exit

#error with file I/O
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