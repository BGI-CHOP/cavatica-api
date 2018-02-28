#!/usr/bin/perl -w
use strict;

### Author: Haoxuan Jin (jinh2@email.chop.edu)
# This perl script is use to change csv metadata file into tsv.
# Dealing the wrong format of 'Legacy Aliquot' feature.
#
# Usage: perl step1_csv2tab.pl <metaData.csv> <output.tsv>
###

die "\nThis perl script is use to change csv metadata file into tsv.\nDealing the wrong format of 'Legacy Aliquot' feature.\n\nUsage: perl $0 <metaData.csv> <output.tsv>\n\n" if @ARGV != 2;

open IN, "<$ARGV[0]"; ## metaData.csv
open OUT, ">$ARGV[0]"; ## output.tsv
while(my $info = <IN>){
    my @info;
    if($info =~/\[/){
        $info =~s/\[(\d+),(\d+)\]/[$1-$2]/;
        @info = split(/\,/, $info);
        $info[15] =~s/\-/,/;
        # print $info;
    }else{
        @info = split(/\,/, $info);
    }
    my $out = join("\t", @info);
    # $info =~s/\,/\t/g;
    print OUT $out;
}
