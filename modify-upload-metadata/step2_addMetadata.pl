#!/usr/bin/perl -w
use strict;

### Author: Haoxuan Jin (jinh2@email.chop.edu)
# This script is used to generate new file metadata according to the input metadata, 
# which is the output of last step (step1).
#
# Usage: perl step2_addMetadata.pl <input.refMetadata.tsv> <input.file.csv> <output.fileMetadata.csv>
###

die "\nThis script is used to generate new file metadata according to the input metadata,\nwhich is the output of last step (step1).\n\nUsage: perl $0 <input.refMetadata.tsv> <input.file.csv> <output.fileMetadata.csv>\n\n" if @ARGV != 3;

# open IN, "<ori-manifest.tsv";
# open IN, "<1519753644215-manifest.tsv";
open IN, "<$ARGV[0]";

my $inhead = <IN>;
chomp $inhead;
my @inhead = split(/\t/, $inhead);
my %sample_DNA;
my %sample_RNA;
while(my $info = <IN>){
    chomp $info;
    my @info = split(/\t/, $info);
    $info[5] =~/^(\d+\-\d+)\-(\S)$/;
    my $patient = $1;
    my $stat = $2; # T or N
    next if ($stat eq 'N');
    print "$stat\n";
    if ($info =~/RNA-Seq/i){
        for(my $i=0; $i<@info; $i++){
            $sample_RNA{$patient}{$inhead[$i]} = $info[$i] if ((!exists $sample_RNA{$patient}{$inhead[$i]}) or ($sample_RNA{$patient}{$inhead[$i]} eq ''));
        }
    }else{
        for(my $i=0; $i<@info; $i++){
            $sample_DNA{$patient}{$inhead[$i]} = $info[$i] if ((!exists $sample_DNA{$patient}{$inhead[$i]}) or ($sample_DNA{$patient}{$inhead[$i]} eq ''));
        }
    }
    
}

open PD, "<$ARGV[1]";
open PROB, ">problem_sample.txt";
open OUT, ">$ARGV[2]";
my $pdhead = <PD>;
chomp $pdhead;
my @pdhead = split(/\,/, $pdhead);
my %pro_metadata;
my $allprint = 0;
my $headcheck = 1;
my @print_feature;
if(!$allprint){
    my $print_feature = "id,name,project,race,gender,vital_status,ethnicity,disease_type,sample_id,sample_type,platform,primary_site,age_at_diagnosis,case_id,Sequencing Center,reference_genome,days_to_death,experimental_strategy,quality_scale";
    @print_feature = split(/\,/, $print_feature);
    print OUT "$print_feature\n";
}
while(my $info = <PD>){
    chomp $info;
    my @info = split(/\,/, $info);
    $info[1] =~/^(\d+\-\d+)[\.\-]/;
    my $patient = $1;
    my $file_name = $info[1];
    for(my $i=0; $i<@info; $i++){
        $pro_metadata{$file_name}{$pdhead[$i]} = $info[$i] if ($info[$i]);
    }

    if($info=~/RNA-seq/i){
        if(exists $sample_RNA{$patient}){
            foreach my $feature (keys %{$sample_RNA{$patient}}){
                $pro_metadata{$file_name}{$feature} = $sample_RNA{$patient}{$feature} if (!exists $pro_metadata{$file_name}{$feature});
            }
        }else{
            foreach my $feature (@inhead){
                $pro_metadata{$file_name}{$feature} = '' if (!exists $pro_metadata{$file_name}{$feature});
            }
            print PROB "$info[0]\t$info[1]\n";
            next; ### jump ? 
        }
    }else{
        if(exists $sample_DNA{$patient}){
            foreach my $feature (keys %{$sample_DNA{$patient}}){
                $pro_metadata{$file_name}{$feature} = $sample_DNA{$patient}{$feature} if (!exists $pro_metadata{$file_name}{$feature});
            }
        }else{
            foreach my $feature (@inhead){
                $pro_metadata{$file_name}{$feature} = '' if (!exists $pro_metadata{$file_name}{$feature});
            }
            print PROB "$info[0]\t$info[1]\n";
            next; ### jump ? 
        }
    }

    if($allprint and $headcheck){
        my $outhead = '';
        foreach my $feature (sort keys %{$pro_metadata{$file_name}}){
            $outhead .= ",$feature";
        }
        print OUT "$outhead\n";
        $headcheck = 0;
    }
    if($allprint){
        foreach my $feature (sort keys %{$pro_metadata{$file_name}}){
            print OUT ",$pro_metadata{$file_name}{$feature}";
        }
    }else{
        my $out = '';
        foreach my $feature (@print_feature){
            $out .= ",$pro_metadata{$file_name}{$feature}";
        }
        $out =~s/^,//;
        print OUT "$out\n";
    }
}