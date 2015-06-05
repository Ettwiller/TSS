#!/usr/bin/perl

use strict;
use Getopt::Long qw(GetOptions);


my $error_sentence = "USAGE : perl $0 --tss tss_file --cutoff 3 (DEFAULT 0 bp merging)";
my $tssfile;
my $CUTOFF = 5;


GetOptions ("tss=s" => \$tssfile,    # numeric
	        "cutoff=s" => \$CUTOFF,
    ) or die "$error_sentence";

if (!$tssfile) {die "$error_sentence\n";}

my $generic = $tssfile;
$generic =~ s/.*\///g;
$generic = $generic.".tmp";
my $command = "bedtools merge -s -scores collapse -d $CUTOFF -nms -i $tssfile > $generic";
system($command);
parse_merged($generic);

#unlink $generic;

sub parse_merged{
    my ($file)=@_;
    open (FILE, $file) or die;
    foreach my $line (<FILE>)
    {
        chomp $line;
        my @tmp = split /\t/, $line;

        my @positions = split /\;/, $tmp[3];
        my $merge_size = @positions;
        my @result=[];
        for (my $i=0; $i<$merge_size; $i++)
        {
            my $pos = $positions[$i];
            my @coords = split/\_/, $pos;
            my $score = $coords[2];
            #print "$score - ";
            $result[$i][0]=$score;
            $result[$i][1]=$pos;
        }           
        my @sorted = sort { $b->[0] <=> $a->[0] } @result;
        my $highest_pos = $sorted[0][1];
        my @col = split /\_/, $highest_pos;
# bed format
	#print "$col[0]\t$col[1]\t$col[1]\t$highest_pos\t$col[2]\t$col[3]\n";
        #gtf format :
	print "$col[0]\tCAPPABLE_SEQ\tTSS\t$col[1]\t$col[1]\t$col[2]\t$col[3]\t.\t$highest_pos\n";



    }
    close FILE;


}
