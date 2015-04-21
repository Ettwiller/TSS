#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long qw(GetOptions);


my $error_sentence = "USAGE : perl $0 --bam bamfile \nOPTIONAL : --lib_type FR (default F) --CUTOFF 1 (default 0)\n";

=comment
Paired reads:

RF: first read (/1) of fragment pair is sequenced as anti-sense (reverse(R)), and second read (/2) is in the sense strand (forward(F)); typical of the dUTP/UDG sequencing method.

FR: first read (/1) of fragment pair is sequenced as sense (forward), and second read (/2) is in the antisense strand (reverse)

Unpaired (single) reads:

F: the single read is in the sense (forward) orientation

R: will not work!
=cut


# INPUT :
#bam file X.bam (preferably generated through local alignment such as Bowtie --local)
#OUTPUT :
#




my $bamfile;
my $lib_type = "F";
my $CUTOFF = 0;

GetOptions ("bam=s" => \$bamfile,    # numeric
	    "lib_type=s" => \$lib_type,
	    "cutoff=s" => \$CUTOFF
    ) or die "USAGE : perl $0 $error_sentence";

if (!$bamfile) {die "$error_sentence"};
if ($lib_type ne "FR" && $lib_type ne "RF" && $lib_type ne "F"){ die "
--lib_type should be either FR (forward/reverse) or RF (reverse / forward) for paired end reads or F (single read).";
}

my $generic =  clean_name($bamfile);

my $resulting_bam;
if ($lib_type eq "F") #single read library with R1 being the most 5' end of the transcripts. 
{
    $resulting_bam = $bamfile;
}
elsif ($lib_type eq "FR")
{
    my $tmp = $generic."_R1";
    #extract R1 from bam
    my $library_command = "samtools view -f64 -b $bamfile | samtools sort - $tmp";
    $resulting_bam = $tmp.".bam";
    system($library_command);
}
elsif ($lib_type eq "RF")
{
    my $tmp = $generic."R2";
    #extract R2 from bam                                                                                                                                     
    my $library_command = "samtools view -f128 -b $bamfile | samtools sort - $tmp";
    $resulting_bam = $tmp.".bam";
    system($library_command);
}

#get the total number of reads that map to the genome.
my $count_mapped_read = `samtools view -F4 $resulting_bam -c`;
print STDERR "number of reads mapping to e.coli = $count_mapped_read\n";
chomp $count_mapped_read;
my $file_tmp = $generic."_tmp.bed";
my $command = "bedtools bamtobed -cigar  -i $resulting_bam > $file_tmp"; 
print STDERR "$command\n";

system($command);
my $result = parse_bed($file_tmp);
unlink($file_tmp);
my $total_count = 0;


foreach my $chr (sort keys %$result)
{
    my $tmp = $$result{$chr};
    foreach my $keys (sort {$a<=>$b} keys %$tmp)
    {
	if ($$result{$chr}{$keys}{"+"}{"count"})
	{
	    my $pos = sprintf('%.3f',($$result{$chr}{$keys}{"+"}{"count"}/$count_mapped_read)*1000000);
	    my $abs_pos = $$result{$chr}{$keys}{"+"}{"count"};
	    if ($pos >= $CUTOFF)
	    {
		my $start = $keys +1;
		$total_count ++;
		my @tmp = @{$$result{$chr}{$keys}{"+"}{"read"}};
		my $id = "TSS_".$start;
		print "$chr\t$generic\t$id\t$start\t$start\t$pos\t+\t.\tnumber_of_read=$abs_pos;total_number_of_read=$count_mapped_read\n";
	    }
	}
	if ($$result{$chr}{$keys}{"-"}{"count"})
	{
	    my $neg = sprintf('%.3f',($$result{$chr}{$keys}{"-"}{"count"}/$count_mapped_read)*1000000);
	    my $abs_neg = $$result{$chr}{$keys}{"-"}{"count"};
	    if ($neg >= $CUTOFF)
	    {
		my $start = $keys;
		$total_count ++;
		my $id = "TSS_".$start;
		my @tmp = @{$$result{$chr}{$keys}{"-"}{"read"}};
		print "$chr\t$generic\t$id\t$start\t$start\t$neg\t-\t.\tnumber_of_read=$abs_neg;total_number_of_read=$count_mapped_read\n";
	    }
       
	}
    }
}

sub clean_name {
    my ($file)=@_;
    my $generic = $file;
    $generic =~ s/\.tss//;
    $generic =~ s/.*\///g;
    return $generic;
} 
sub parse_bed {
    my ($file)=@_;
    open (FILE, $file) or die;
    my %result;
    foreach my $line (<FILE>)
    {
	chomp $line;
	my $start;
	my @tmp = split /\t/, $line;
	my $chr = $tmp[0];
	my $orientation = $tmp[5];
	if ($orientation eq "+")
	{
	    $start = $tmp[1];
	}
	else{
	    $start = $tmp[2];
	}
	$result{$chr}{$start}{$orientation}{"count"}++;
	push @{$result{$chr}{$start}{$orientation}{"read"}}, $line;
    
    }
    

    return \%result;
}

