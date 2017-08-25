#!/usr/bin/perl 
use strict;
use warnings;
use Data::Dumper;
use Regexp::Common qw /number/;

#####################################################
### For use on 2ndScore Hairpin files             ###
#####################################################


##Capture desired data
my $HairpinData = qr/^\s*($RE{num}{real})\s+  # energy
						 ($RE{num}{int})\s+ # start
						 \.\.\s+
						 ($RE{num}{int})\s+ # end
						 \w+\s*
						 [\w+|-]?\s+
						 (\w+)\s*	 # spacer
						 [\w+|-]?\s*
/x;
open my $file, '<', "filter_test.hairpin", or die $!;

##Fill array with energy scores
my @scores;
while (<$file>){
	if (my ($energy, $start, $end, $spacer) = /$HairpinData/){
		push @scores, $energy;
	}
}

#print Dumper(\@lengths);

##Print energy scores to new file
foreach my $element (@scores){
	open my $new_file, '>>', "test_count.txt", or die $!;
		print $new_file $element." ";
		close $new_file;
}
close $file;

