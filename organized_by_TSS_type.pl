#!/usr/bin/perl
use strict;
use Getopt::Long qw(GetOptions);

my $error_sentence = "USAGE : perl $0 --tss tss_file (bed or ftg) --genome genome_file (fasta) OPTIONAL : --detail 0 or 1 (default 0)";
my $TSS;
my $genome;
my $detail = 0; #0 or 1

GetOptions ("tss=s" => \$TSS, 
    "genome=s" => \$genome,
    "detail=s" => \$detail
    ) or die "$error_sentence";

if (!$TSS || !$genome) {die "$error_sentence\n";}


#my $TSS = "/mnt/home/ettwiller/laurence/projects/ira_cap/FINAL_PAPER/TSS/TSS_enriched_cluster_5.gtf";
#my $genome = "/mnt/home/ettwiller/laurence/projects/ira_cap/3_ecoli_RNase_inhibitors/genome/ecoli_genome_and_controls_new.fasta";

#create an index file if the file does not exist. Do nothing if exist. 
my $fai = $genome.".fai";
if (-e $fai) {
    print STDERR "$fai exist\n";
}

else {
    my $fai_command = "samtools faidx $genome";
    system($fai_command);
}
if ($detail==1)
{
    print "-1+1\tscore(RRS)\tenrichment\n";
}


my $tmp = "tmp";
my $tmp1 = "tmp1";


my $out = $TSS;
$out =~ s/.*\///g;
$out =~ s/\.gtf//;
$out = "tmp_".$out.".fasta";
#my $c = "bedtools intersect -u  -a $TSS -b ecoli_genome.bed > $tmp";
#print "$c\n";
#system($c);

my $command = " bedtools slop -i $TSS -g $fai  -s -l 1 -r 0 | bedtools getfasta  -s -fi $genome -bed - -fo $out";

#print "$command\n";
system($command);
my $out2 = $out;

my $command1 = "grep -v \">\" $out > $tmp1";
#print "$command1\n";
system($command1);

my $command2 = "paste tmp tmp1 > $out2";
#print "$command2\n";
system($command2);
my %final;
my $total =0;
open (FILE, $out2);
foreach my $line (<FILE>)
{
    chomp $line;
    my @tmp = split /\t/, $line;
    my $id = $tmp[8];
    my @tmp2 = split /\_/, $id;
    my $enrichment = $tmp2[-1];
    my $score = $tmp[5];
    my $nt = $tmp[9];
    if ($detail ==1)
    {
	print "$nt\t$score\t$enrichment\n";
    }
    $total ++;
    $final{$nt}++;

}
if ($detail == 0)
{
    foreach my $nt (sort {$final{$b}<=>$final{$a}} keys %final)
    {
	my $percent = ($final{$nt}*100)/$total;
	my $rounded = sprintf "%.2f", $percent;
	print "$nt\t$rounded \%\n";
    }
}



unlink($tmp);
unlink($tmp1);
unlink($out2);
