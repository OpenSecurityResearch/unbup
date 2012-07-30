#!/usr/bin/perl
# UnBup
# Tony Lee and Travis Rosiek
# Tony.Lee-at-Foundstone.com
# Travis_Rosiek-at-McAfee.com
# Bup Extraction tool - Reverse a McAfee Quarantined Bup file with Bash
# Input:  Bup File
# Output: Details.txt file and original binary (optional)
# Note:  This does not put the file back to the original location (output is to current directory)


# Detect the absence of command line parameters.  If the user did not specify any, print usage statement 
if (@ARGV == 0) { Usage(); exit(); }


##### Function Usage #####
# Prints usage statement
##########################
sub Usage
{
print "UnBup v1.0
Usage:  UnBup.pl [option] <file.bup>

  -d = details file only (no executable)
  -h = help menu
  -s = safe executable (extension is .ex)

Please report bugs to Tony.Lee-at-Foundstone.com and Travis_Rosiek-at-McAfee.com\n"
}


##### Function XorLoop #####
# Loop through files to perform bitwise xor with key write binary to file
# Input arguments input filename and output filename
# example:  XorLoop(Details, Details.txt)
############################
sub XorLoop
{
	# Open input file as read only to avoid accidentally modifying the file
	open INPUT, "<$_[0]" or die "Input file \"$_[0]\" does not exist\n";

	# Open the output file to write to it
	open OUTPUT, ">$_[1]" or die "Cannot open file \"$_[1]\"";

	# Loop until all bytes in the file are read
	while (($n = read INPUT, $byte, 1) != 0) 
	{ 
		$decode = $byte ^ 'j';		# xor byte against ASCII 'j' = Hex 0x6A = Dec 106 
		print OUTPUT $decode;		# write the decoded output to a file
	}

	close INPUT;
	close OUTPUT;
}

##### Function CreateDetails #####
# Create the Details.txt file with metadata on bup'd file
##################################
sub CreateDetails
{
	$BupName=$_[0];
	# Check to see if the text file exists, if not let the user know
	unless(-e "$BupName") { print "\nError:  The file \"$BupName\" does not exist\n"; Usage; exit 0; }
	print "Extracting encoded files from Bup\n";
	`7z e $BupName`;			# Extract the xor encoded files (Details and File_0)
	print "Creating the Details.txt file\n";
	XorLoop("Details", "Details.txt");	# Call XorLoop function with variables set
}

##### Function ExtractBinary #####
# Extracts the original binary from the bup file
##################################
sub ExtractBinary
{
	$Field=`grep OriginalName Details.txt | awk -F '\\' '{ print NF }'`;	# Find the binary name field
	$OUTNAME=`grep OriginalName Details.txt | cut -d '\\' -f $Field`;	# Find the binary name
	$INPUT=File_0;
	print "Extracting the binary\n";
	XorLoop("$INPUT", "$OUTNAME");						# Call xor function again
}



if ($ARGV[0] eq "-d"){		# Print details file only
	CreateDetails($ARGV[1]);
	`rm Details File_0`;	# Clean up original files
}
elsif ($ARGV[0] eq "-h"){	# Print usage statement
		Usage();
}
elsif ($ARGV[0] eq "-s"){	# Create "safe" binary
		CreateDetails($ARGV[1]);
		ExtractBinary();
		chop($OUTNAME);
		$OLD=$OUTNAME;			# Store original name in $OLD variable
		chop($OUTNAME);
		chop($OUTNAME);
		`mv $OLD $OUTNAME`;		# Rename the binary to remove that last E
		`rm Details File_0`;		# Clean up original files
}
else {
	CreateDetails($ARGV[0]);	# Extract details file and binary
	ExtractBinary();
	`rm Details File_0`;		# Clean up original files
}
