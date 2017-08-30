#!/usr/bin/perl 
use strict;
use warnings;
use Regexp::Common qw /number/;

##Ask user for maximum energy score
print "Enter limit: ";
chomp( my $limit = <STDIN> );


open my $IN, '<', "test.hairpin" or die $!;
open my $SIFTED, '>', "filter_test.hairpin" or die $!;
#Skip all energy scores that are higher than the energy score chosen by the user
while (<$IN>){
    next if /^None/;
    next if /^\s*($RE{num}{real})/ && $1 > $limit;
    print $SIFTED $_;
}

close $IN;
close $SIFTED;
