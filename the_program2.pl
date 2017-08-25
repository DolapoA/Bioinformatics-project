#!/usr/bin/perl 
use strict;
use warnings;
use Data::Dumper;
use Regexp::Common qw /number/;

use List::Util qw (notall reduce);
use feature 'say';

#####################################################
### For use on 2ndScore Hairpin files             ###
#####################################################


## Captures the Header of the circRNA sequence
my $SeqName = qr/ 
        ^>( 
            \w+\d+ \| 
            \w+\w+ : \d+ \- \d+[-|+] \| 
            \w+ \| 
            \w+\s+\w+ 
        )$ 
    /x;  
##Capture desired data
my $HairpinData = qr/^\s*($RE{num}{real})\s+  # energy
						 ($RE{num}{int})\s+ # start
						 \.\.\s+
						 ($RE{num}{int})\s+ # end
						 \w+\s*
						 [\w+|-]?\s+
						 (\w+)\s*	  # spacer
						 [\w+|-]?\s*
/x;

    open my $hairpin_file, '<', "new_xt_spacer_results.hairpin", or die $!;

    my %HoA_sequences;
my $curkey;


## Assigning captured data to respectively named variables
## And pushing such info into a hash of array of hashes.
while (<$hairpin_file>){
	chomp;
	if (/$SeqName/){  
        $curkey = $1;  
    } 
    elsif (my ($energy, $start, $end, $spacer) = /$HairpinData/) { 
        die "value seen before header: '$_'" unless defined $curkey;  
        push @{ $HoA_sequences{$curkey}},   
            { energy=>$energy, start=>$start, end=>$end, spacer=>$spacer};  
    }  
    else { die "don't know how to parse: '$_'" }  
}


## Detecting identical spacers of hairpins & keeping the hairpin with 
## the lowest energy score
for my $key (keys %HoA_sequences) {
    my ($spv, $unique) = partition_equal($HoA_sequences{$key});
    next if not $spv;
    # Extract minimum-energy hashref from each group and add to arrayref
    # $unique, so that it can eventually overwrite this key's arrayref
    foreach my $spacer (keys %$spv) {
        my $hr_min = reduce { 
            $a->{energy} < $b->{energy} ? $a : $b 
        } @{$spv->{$spacer}};
        push @$unique, $hr_min;
    }
    # new: unique + lowest-energy ones for each equal-spacer group   
    $HoA_sequences{$key} = $unique  if keys %$spv;
}    
#print Dumper(\%HoA_sequences);

# Compare neighbouring elements (hashrefs) in the sorted array 
sub partition_equal {
    my $ra = shift;
    my @sr = sort { $a->{spacer} cmp $b->{spacer} } @$ra;

    # %spv:    spacer value => [ hashrefs with it ], ...
    # @unique: hasrefs with unique spacer values    
    my (%spv, @unique);

    # Process first and last separately (so not to test for them)
    ($sr[0]{spacer} eq $sr[1]{spacer})
        ? push @{$spv{$sr[0]{spacer}}}, $sr[0]
        : push @unique, $sr[0];
    for my $i (1..$#sr-1) {
        if ($sr[$i]{spacer} eq $sr[$i-1]{spacer}  or 
            $sr[$i]{spacer} eq $sr[$i+1]{spacer}) 
        {
            push @{$spv{$sr[$i]{spacer}}}, $sr[$i]
        }
        else { push @unique, $sr[$i] }
    }
    ($sr[-1]{spacer} eq $sr[-2]{spacer})
        ? push @{$spv{$sr[-1]{spacer}}}, $sr[-1]
        : push @unique, $sr[-1];

    return if not keys %spv;
    return \%spv, \@unique;
}
