.data
    buffer: .space 1024        # Buffer to read lines
    writestring: .space 100000        # Buffer to read lines
    result_string: .space 8
    line: .space 8
    
    filenameread: .asciiz "/home/noahg/Documents/A3/jet_64_in_ascii_lf.ppm"
    filenamewrite: .asciiz "/home/noahg/Documents/A3/jet_greyscale.ppm"
    
    avecurrent: .asciiz "Average pixel value of the original image:\n"
    avenew: .asciiz "Average pixel value of new image:\n"
    readerror: .asciiz "File I/O error\nError Code:\n"
    filesuccess: .asciiz "Greyscale File Successfully Created\n"
    separator: .asciiz "\n----------------------\n"
    newline: .asciiz "\n"
    
    numcharstowrite: .word 0

.text
.globl main

main:
    #this call creates the file for later writing
    li   $v0, 13       # system call for open file
    la   $a0, filenamewrite     # output file name
    li   $a1, 'W'        # Open for writing to create file
    syscall

    move $t0, $v0   #store file descriptor

    #show error if there's an error creating the file
    ble $v0, $zero, error

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
    
    li $t6, 0 #line counter
    li $s1, 0 #char counter
    li $s0, 10 #newline char
    li $s4, 48 #char to int conversation
    li $s6, 0 #char counter (WHOLE PROGRAM)

    li $t5, 0 #counter for knowing when to divide by 3 for greyscale 
    li $t8, 8 #number stored for resetting space loop
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
    li $a2, 1                # number of bytes to read
    syscall

    # Check if EOF (end of file)
    beq $v0, $zero, donereading     # If $v0 is 0, we have reached the end of the file

    lb $t1, 0($a1) #get the value of the byte being read from the buffer 

    sb $t1, line($s1) #add this byte to the end of the line
    addi $s1, $s1, 1 #add 1 to the value of the loop to know which value to get
    beq $t1, $s0, processing #if a newline character is found, start processing that line

    j read_loop #run this loop again to add onto the line string

#CHECK IF THIS VERSION IS VIABLE BEFORE COMMENTING
processing:
    addi $t6, $t6, 1 #add 1 to the line counter
    
    move $s7, $s6 # $s7 = char position to write from
    add $s6, $s6, $s1 # s6 = number of chars total, $t1 = number of chars to write
    sw $s1, numcharstowrite

    li $s1, 0
    li $s2, 0
    li $s3, 0

    ble $t6, 4, storefirstfour

    j linetoint

P3toP2:
    addi $s7, $s7, -2 #go back 2 bytes from the newline character to the number after P
    li $t2, '2'
    sb $t2, writestring($s7) #store the number 2 in that space instead of the 3
    j rs #reset the line space

storenewdescription:
    addi $s7, $s7, -2 #go back 2 bytes and get the last char of the line
    lb $t1, writestring($s7) 

    li $t2, '2'
    sb $t2, writestring($s7) #store a number 2 in that place

    addi $s7, $s7, -1 #go back 1 more byte
    sb $t1, writestring($s7) #set that byte to the same byte as the one that the char at the end initially was
    #ie: hse become he2, jet become jt2, or tre becomes te2
    
    j rs #jump to resetting the 'space' variables

setstart:
    move $t3, $s6 #sets $t3 to the place where the program needs to start adding to the writestring from, ie, after the decription lines
    addi $t3, $t3, -1 #go back one value so that it getss written right up to the newline vairable
    j rs #jump to resetting the 'space' variables

#loops through each line of the description strings and writes them to the writing string
storefirstfour:
    lb $t2, line($s2)
    sb $t2, writestring($s7)

    beq $s7, $s6, resetspaces #if all chars have been written, reset the 'space' variables
    addi $s7, $s7, 1
    addi $s2, $s2, 1
    j storefirstfour

#converting lines (as strings) to integers for calculations
linetoint:
    lb  $t1, line($s3) #get the variable of the char

    addi $s3, $s3, 1 #add 1 to the loop for the next char

    beq $t1, $s0, addforgrey #if at end of line, jump to the next step, adding up to calculate the average

    sub $t1, $t1, $s4 #get the int value by subbing the char value of '0', which equals 48
    #ALT VERSION
    #sub $t1, $t1, '0'
    mul $s2, $s2, $s0 #timsing $s2 by 10
    add $s2, $s2, $t1 #adding the value of the integer to the end of $s2

    j linetoint #restarting the loop

#adds up the values of the 3 pixels
addforgrey:
    addi $t5, $t5, 1 #add 1 to the counter to check when it's time to calculate the average of the pixels
    add $s8, $s8, $s2 #add the new number to $s8 
    beq $t5, 3, converttogrey 

    j resetspaces #jumps back to the read loop to calculate the new numbers (wrong i think)

#gets the average pixel value
converttogrey:
    #divides the value of the 3 pixels added up by 3 to get the average
    div $s8, $t5 #divides the total value of the 3 pixels by 3
    mflo $s2 #stores the average of the 3 pixels in $s2

    li $t5, 0 #reset the average counter
    li $s8, 0 #reset the average number storage
    j numtonewstr

#setting up variables to get the length of the new number
numtonewstr:  
    li $t2, 0 #set incrementer to 0
    move $s5, $s2 #store number in $s5 for calculating down in a loop without losing $s2
    j getnumlen

#getting length of new number (the average pixel value)
getnumlen:
    div $s5, $s0 #dividing by 10 till the value of the division is 0
    mflo $s5

    addi $t2, $t2, 1 #new length stored in $t2
    beq $s5, $zero, assignnl #jumps to assign new length function
    j getnumlen

assignnl:
    addi $t2, $t2, 1 #increment counter by 1 for storing newline char
    move $t4, $t3 #store countdown value into $t4
    add $t3, $t2, $t3 #increment $t3 by the number calculated as $t2, which is the number length
    move $t2, $t3 #store the new number to count down from in $t2 so $t3 remains the main counter, and we count down from $t4 to $t2
    sb $s0, writestring($t2) #store the newline character at the end of where the string will go
    j newnumtostr

newnumtostr:
    addi $t2, $t2, -1 #loop down
    beq $t2, $t4, resetspaces #if at the end of the looping down, reset the spaces
    
    div $s2, $s0 #get the char to bet put in by dividing by 10
    mflo $s2 #store the number in $s2
    mfhi $t1 #store the number to be added as a string in $t1

    add $t1, $t1, $s4 #add 48 to get the string value
    sb $t1, writestring($t2) #store that char value in the writestring

    j newnumtostr #loop back down and repeat till all chars from the number are added to the writestring

#this resets the values stored in the 'line' variable to 0
rs:
    sb $zero, line($t7)
    addi $t7, $t7, 1
    beq $t7, $t8, read_loop

    j rs

resetspaces:
    li $t7, 0 #reset incrementor to reset all values of line variable
    beq $t6, 1, P3toP2 #change P3 to P2 so that the ppm file knows this is greyscale, but only do it if were on the first line
    beq $t6, 2, storenewdescription #update the file description so that one can see it is a changed image
    beq $t6, 4, setstart #set the position of where to start adding onto the writing string once all decription lines have been written
    j rs #start resetting the line variable

#close the text file being read from
donereading:
    # Close the file
    li $v0, 16               # Syscall code for close file
    move $a0, $t0            # File descriptor to close
    syscall
    
    j openforwriting

#open the file being written to
openforwriting:
    li   $v0, 13       # system call for opening file
    la   $a0, filenamewrite     # output file name
    li   $a1, 0x41        # Open for writing to file
    syscall

    move $t0, $v0            # Store the file descriptor in $t0

    blt $v0, $zero, error #show error if there's an error writing to file

    j writing

writing:
    li $v0, 15 #load writing command
    move $a0, $t0 #load file to be written to into descriptor
    la $a1, writestring #load string to be written into a1
    move $a2, $t3 #load length of string to be written into a2
    syscall #write string to file

    j donewriting 

donewriting:
    li $v0, 16               # Syscall code for close file
    move $a0, $t0            # File descriptor to close
    syscall

    li $t1, 0

    li $v0, 4               # Syscall code printing string
    la $a0, filesuccess            # show that writing new information to file was be a success
    syscall
    #j tempprint #this prints all lines in writelines vairable to console for debugging

    j exit 

#print all lines for debugging
tempprint:
    la $t0, writestring
    li $v0, 4
    move $a0, $t0
    syscall

    j exit

#show error message if there's a problem
error:
    move $t8, $v0
    li $v0, 4                # Syscall code for print string
    la $a0, readerror           # Load error message
    syscall

    li $v0, 1                # Syscall code for print string
    move $a0, $t8           # load the error code
    syscall

    j exit

exit:
    # Exit the program
    li $v0, 10               # Syscall code for exit
    syscall