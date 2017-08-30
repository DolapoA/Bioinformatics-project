#!/usr/bin/perl -w
use strict;
use Regexp::Common qw /number/;
use List::Util qw (reduce);
use Data::Dumper; 



## Captures the sequence ID
my $id = qr/ 
        ^>( 
            \w+\d+ \| 
            \w+\w+ : \d+ \- \d+[-|+] \| 
            \w+ \| 
            \w+\s+\w+ 
        )$ 
    /x;  
##Capture data
my $data = qr/^\s*($RE{num}{real})\s+  # energy
                         ($RE{num}{int})\s+ # start
                         \.\.\s+
                         ($RE{num}{int})\s+ # end
                         \w+\s+
                         [\w*|-]?\s
                         \w+\s+(\w+)      # spacer
                         [\+|-]?\s*
/x;

    open my $file, '<', "test.hairpin", or die $!;

    my %hashOfArray;
my $activeKey;


## Assign data to named variables
## And push data into a hash of array of hashes.
while (<$file>){
    chomp;
    if (/$id/){  
        $activeKey = $1;  
    } 
    elsif (my ($energy, $seqStart, $seqEnd, $seqSpacer) = /$data/) { 
        die "value seen before header: '$_'" unless defined $activeKey;  
        push @{ $hashOfArray{$activeKey}},   
            { energy=>$energy, start=>$seqStart, end=>$seqEnd, spacer=>$seqSpacer};  
    }  
    else { die "cannot parse: '$_'" }  
}

print Dumper(\%hashOfArray);


## Detect identical spacers and saving those with least energy score
for my $key (keys %hashOfArray) {
    my ($spacerValue, $special) = Partitioner($hashOfArray{$key});
    next if not $spacerValue;

    # Get min energy hashref per group then add to arrayref
    # $special, ultimately replaces the key's arrayref

    foreach my $seqSpacer (keys %$spacerValue) {
        my $minHashref = reduce { 
            $a->{energy} < $b->{energy} ? $a : $b 
        } @{$spacerValue->{$seqSpacer}};
        push @$special, $minHashref;
    }
    # each group now has new hairpins that are distinct and have least energy score
    $hashOfArray{$key} = $special  if keys %$spacerValue;
}    
print Dumper(\%hashOfArray);


# Compare neighbouring elements (hashrefs) in the sorted array 
sub Partitioner {
    my $input = shift;
    my @sortedRefs = sort { $a->{spacer} cmp $b->{spacer} } @$input;

    # %spacerValue:    spacer value => [ hashrefs with it ], ...
    # @special: holds the hasrefs bearing distinct spacers   
    my (%spacerValue, @special);

    # Process first and last separately (so not to test for them)
    ($sortedRefs[0]{spacer} eq $sortedRefs[1]{spacer})
        ? push @{$spacerValue{$sortedRefs[0]{spacer}}}, $sortedRefs[0]
        : push @special, $sortedRefs[0];
    for my $i (1..$#sortedRefs-1) {
        if ($sortedRefs[$i]{spacer} eq $sortedRefs[$i-1]{spacer}  or 
            $sortedRefs[$i]{spacer} eq $sortedRefs[$i+1]{spacer}) 
        {
            push @{$spacerValue{$sortedRefs[$i]{spacer}}}, $sortedRefs[$i]
        }
        else { push @special, $sortedRefs[$i] }
    }
    ($sortedRefs[-1]{spacer} eq $sortedRefs[-2]{spacer})
        ? push @{$spacerValue{$sortedRefs[-1]{spacer}}}, $sortedRefs[-1]
        : push @special, $sortedRefs[-1];

    return if not keys %spacerValue;
    return \%spacerValue, \@special;
}
