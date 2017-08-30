#!/usr/bin/perl 
use strict;
use warnings;

###########################################
### For use on fasta files              ###
###########################################

open F, "human_hg19_circRNAs_putative_spliced_sequence.fa", or die $!;

my %seq = ();
my $id = '';

while (<F>){
	chomp;
	if ($_ =~ /^>(.+)/){
		$id = $1;
	}else{
		$seq{$id} .= $_;
	}
}


my @seqarray;

foreach $id (keys %seq){
		push @seqarray, $id;
	}

for $id (@seqarray){
	if (-f $id){print $id, " already exists. It i sabout to be overwritten"};
	open new_F, '>>', "counts2", or die$!;
	print new_F ((length$seq{$id})." ");
	close new_F;
}


close F;

