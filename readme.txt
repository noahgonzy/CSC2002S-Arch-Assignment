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