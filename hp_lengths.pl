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
						 (\w+)\s*			  # spacer
						 [\w+|-]?\s*
/x;
open my $file, '<', "no_rvs_results.hairpin", or die $!;

##Calculate hairpin lengths and fill array
my @lengths;
while (<$file>){
	if (my ($energy, $start, $end, $spacer) = /$HairpinData/){
		my $hp_length = $end - $start;
		push @lengths, $hp_length;
	}
}

#print Dumper(\@lengths);
##Print calculated hairpin lengths to new file
foreach my $element (@lengths){
	open my $new_file, '>>', "hp_lengths.txt", or die $!;
		print $new_file $element." ";
		close $new_file;
}
close $file;
