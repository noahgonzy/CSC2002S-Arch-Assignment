Greyscale and Increase Brightness of .ppm files
By: Noah Gonsenhauser, GNSNOA001

Usage:
Open the .asm which you want to use

direct the 'filenameread' variable to the file which you want to either brighten or greyscale
eg: "/home/noahg/Documents/A3/jet_64_in_ascii_lf.ppm"

nb. The file must be 64 x 64 pixels, have a file size of less than 100kb, and be 'LF' terminated

nb. if converting from normal photo to greyscale, a 'P3' file must be used

direct the 'filenamewrite' variable to the directory which you want your new file to be created along with the file name of the new file
eg: "/home/$(USER)/Documents/jet_greyscale.ppm"

Run the .asm file you have chosen using QTspim

If you have used the Greyscale file, you will be shown that either the file was sucessfully created or that there was some file I/O error along with an error code

If you have used the Increase Brightness file, you will either be shown the initial average brightness and then new average brightness, or an I/O error along with an error code

How it works:

Essentially, the file to be manipulated is read char by char and processed line by line.
Once a whole line is read, it is either directly written to an output string or processed.
if it is a number to be processed (and not a description which is only ever minorly altered) then it is converted to an integer for processing
if using the greyscale function, it adds all the numbers together for a pixel and averages them, if using the increase_brightness function, it just adds 10 to the value for a max of 255.
each number is then written onto the end of the writestring.
once the end of the file is reached, the writestring is written to the newly created file.
if there is a reading or writing error, an error message is displayed.