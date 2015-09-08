#!/usr/bin/perl
use strict;
use Getopt::Long qw(GetOptions);
use File::Temp qw(tempfile);

my $error_sentence = "USAGE : perl $0 --tss tss_file.gtf (from filter_tss.pl or from bam2firstbasegtf.pl) --out output file name\nOPTIONAL : --cutoff 3 (in bp DEFAULT 5 bp merging)";
my $tssfile;
my $CUTOFF = 5;
my $OUT;

#================================
#getting the options :
GetOptions ("tss=s" => \$tssfile,    # file from  filter_tss.pl 
	    "cutoff=s" => \$CUTOFF, #in bp
	    "out=s" => \$OUT #output file
    ) or die "$error_sentence";



#================================
#checking if everything is fine :
if (!$tssfile || !$OUT) {die "$error_sentence\n";}
if(-e $OUT) { die "File $OUT Exists, please remove old file or rename output file (--out)"};
#=================================                                                                                                                         

#my $generic = new File::Temp( UNLINK => 0 );
my $generic = "tmp_cluster.tmp";
my $command = "bedtools merge -s -c 3 -delim \";\" -o collapse -d $CUTOFF -i $tssfile > $generic";
system($command);
parse_merged($generic);

#unlink $generic;

sub parse_merged{
    my ($file)=@_;
    open (OUT, ">$OUT") or die "can't save the output to $OUT\n";
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
	print OUT "$col[0]\tCAPPABLE_SEQ\tTSS\t$col[1]\t$col[1]\t$col[2]\t$col[3]\t.\t$highest_pos\n";



    }
    close FILE;
    close OUT;

}
