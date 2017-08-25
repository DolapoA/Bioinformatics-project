#!/usr/bin/perl 
use strict;
use warnings;

#Since Palindrome analyser is unable to analyse a fasta file with multiple sequences
#this script was written to extract sequences from a multi-fasta file into separate files
#for analysis
open my $fh, '<',"test.fa",or die $!;

my %id2seq;
my $id = '';
    while(<$fh>){
        chomp;
        if($_ =~ /^>(hsa_circ_\d+)/){
            $id = $1;
        }else{
            $id2seq{$id} .= $_;
        }
    }

 

    foreach $id (keys %id2seq){
        open  my $out_fh, '>>', "$id.fa" or die $!; 
        print $out_fh ">".$id."\n",$id2seq{$id}, "\n";
        close $out_fh;
    }


close $fh;



