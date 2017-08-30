#!/usr/bin/perl 
use strict;
use warnings;

##Invoking subroutines


my %seq = HashSequences();
SpecifySeqLengths();


## Open file. Hash sequences. Make the sequence IDs the keys to their
## respective (hashed) sequences.


sub HashSequences{

	open F, "test.fa", or die $!;

	my $id = '';
	my %seq = ();
	

	while (<F>){
		chomp;
		if ($_ =~ /^(>.+)/){
			$id = $1;
		}else{
			$seq{$id} .= $_;
		}
	}
	close F;
	return %seq;
	}

## Request sequence length desired. Sieve sequences of given length into
## arrays. Create file containing desired sequences.

sub SpecifySeqLengths{

	print "Enter Max sequence length: \n";
	my $maxlength = <STDIN>;
	chomp $maxlength;

	print "Enter Min sequence length: \n";
	my $minlength = <STDIN>;
	chomp $minlength;

	my @seqarray;

	foreach my $id (keys %seq){
		if ((length$seq{$id} <= $maxlength) && (length$seq{$id} >= $minlength)){
			push @seqarray, $id;
		}
	}

	for my $id (@seqarray){
		if (-f $id){print $id, " already exists. It is about to be overwritten"};
		open new_F, '>>', "seqlength_$minlength-$maxlength.fa", or die$!;
		print new_F ($id."\n".$seq{$id}."\n");
		close new_F;
	}

}




