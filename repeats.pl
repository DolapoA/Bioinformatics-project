#!/usr/bin/perl 
use strict;
use warnings;

#Grab files with specific suffix and shove into an array
my @pal_files = glob("*palindromes.csv");

my @pal_lengths;
my @repeat_lengths;
my @spacer_lengths;

#Cycle via array and collect info on repeat, spacer and total hairpin length
foreach my $file (@pal_files){

	open my $IN, '<', $file or die "$file: $!\n";

	while (my $line = <$IN>){
		if ($line =~ /"\d+-\d+-\d+","\d+","(\d+)","(\d+)","\d+","\w+","\w+","\w+"/){
			push @repeat_lengths, $1;
			push @spacer_lengths, $2;
			push @pal_lengths, $1 + $2;
		}
	}
close $IN;
}

#Create files containing the figures.
foreach my $length (@pal_lengths){
	open NEW_F, '>>', "tot_repeats", or die$!;
	print NEW_F ($length. " ");
	close NEW_F;
	}

foreach my $length (@repeat_lengths){
	open NEW_F, '>>', "repeats", or die$!;
	print NEW_F ($length. " ");
	close NEW_F;
	}

foreach my $length (@spacer_lengths){
	open NEW_F, '>>', "spacers", or die$!;
	print NEW_F ($length. " ");
	close NEW_F;
	}

