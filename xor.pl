#!/usr/bin/perl
# Simple xor decoder
# Written because I could not find one on the Intertubes
# Email me with problems at Tony.Lee-at-Foundstone.com

# Detection to make sure there are two arguments supplied (an input file and output file) 
if (@ARGV < 2) {
	die "Simple xor script\n  Usage: $0 <Input File> <Output File>\n\nTony.Lee-at-Foundstone.com\n";
}

# Open input file as read only to avoid accidentally modifying the file
open INPUT, "<$ARGV[0]" or die "Input file \"$ARGV[0]\" does not exist\n";

# Open the output file to write to it
open OUTPUT, ">$ARGV[1]" or die "Cannot open file \"$ARGV[1]\"";

# Loop until all bytes in the file are read
while (($n = read INPUT, $byte, 1) != 0) 
{ 
	$decode = $byte ^ 'j';		# xor byte against ASCII 'j' = Hex 0x6A = Dec 106 
	print OUTPUT $decode;		# write the decoded output to a file
}

close INPUT;
close OUTPUT;
