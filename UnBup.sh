#!/bin/bash
# UnBup
# Tony Lee and Travis Rosiek
# Tony.Lee-at-Foundstone.com
# Travis_Rosiek-at-McAfee.com
# Bup Extraction tool - Reverse a McAfee Quarantined Bup file with Bash
# Input:  Bup File
# Output: Details.txt file and original binary (optional)
# Note:  This does not put the file back to the original location (output is to current directory)
# Requirements - 7z (7zip), xxd (hexdumper), awk, cut, grep

##### Function Usage #####
# Prints usage statement
##########################
Usage()
{
echo "UnBup v1.0
Usage:  UnBup.sh [option] <file.bup>

  -d = details file only (no executable)
  -h = help menu
  -s = safe executable (extension is .ex)

Please report bugs to Tony.Lee-at-Foundstone.com and Travis_Rosiek-at-McAfee.com"
}

# Detect the absence of command line parameters.  If the user did not specify any, print usage statement 
[[ -n "$1" ]] || { Usage; exit 0; }


##### Function XorLoop #####
# Loop through files to perform bitwise xor with key write binary to file
############################
XorLoop()
{
for byte in `xxd -c 1 -p $INPUT`; do	  # For loop converts binary to hex 1 byte per line
        #echo "$byte"
        decimal=`echo $((0x$byte ^ 0x6A))`	# xor with 6A and convert to decimal
        #echo "decimal = $decimal"
        hex=`echo "obase=16; $decimal" | bc`	# Convert decimal to hex
        #echo "hex = $hex"
        echo -ne "\x$hex" >> $OUTPUT;		# Write raw hex to output file
done
}


##### Function CreateDetails #####
# Create the Details.txt file with metadata on bup'd file
##################################
CreateDetails()
{
# Check to see if the text file exists, if not let the user know
	[[ -e "$BupName" ]] || { echo -e "\nError:  The file $BupName does not exist\n"; Usage; exit 0; }
	echo "Extracting encoded files from Bup";
	7z e $BupName > /dev/null;		# Extract the xor encoded files (Details and File_0)
	INPUT=Details;				# Set INPUT variable to the Details file to get the details and filename
	OUTPUT=Details.txt;			# Set OUTPUT variable to Details.txt filename
	echo "Creating the Details.txt file";
	XorLoop;				# Call XorLoop function with variables set
}


##### Function ExtractBinary #####
# Extracts the original binary from the bup file
##################################
ExtractBinary()
{
	Field=`grep OriginalName Details.txt | awk -F '\' '{ print NF }'`;	# Find the binary name field
	OUTNAME=`grep OriginalName Details.txt | cut -d '\' -f $Field`;
	OUTPUT=`echo "${OUTNAME%?}"`;						# Get rid of trailing /r
	INPUT=File_0;
	echo "Extracting the binary";
	XorLoop;								# Call xor function again
}

# Parse the command line options
case $1 in
	-d) BupName=$2; CreateDetails;;
	-h) Usage; exit 0;;							# Details.txt file only
	-s) BupName=$2; CreateDetails; ExtractBinary; mv $OUTPUT `echo "${OUTPUT%?}"`;;	# Safe binary
	*) BupName=$1; CreateDetails; ExtractBinary;;						# Full process of the bup
esac

rm Details File_0;						# Clean up xor'd files

