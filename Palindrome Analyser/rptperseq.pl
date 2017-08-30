#!/usr/bin/perl 
use strict;
use warnings;

#This script calculates the number of repeats per sequence
#First: Grabs relevant files with specific suffix and stores in an array
my @pal_files = glob("*palindromes.csv");

my @rpt_count;

foreach my $file (@pal_files){
## Minus 1 (-1) is used to account for the first line of the results file containing the headers

	my $lc = -1;
##Count the number of lines in the file to determine the number of repeats for that sequence
	open my $IN, '<', $file or die "$file: $!\n";
	$lc++ while <$IN>;
	close $IN;;
	push @rpt_count, $lc;
}
##Create file containing all repeats per sequence.
foreach my $count (@rpt_count){
	open NEW_F, '>>', "repeats_per_seq", or die$!;
	print NEW_F ($count. " ");
	close NEW_F;
	}
