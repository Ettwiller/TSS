#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long qw(GetOptions);


#this program is primary used for visualizing the TSS on IGV or other genome browser with the read being narrow down to 1 bp resolution. 
# INPUT :
#bam file X.bam (preferably generated through local alignment such as Bowtie --local)
#OUTPUT :
# X_start.bam and X_start.bam.bai

my $bamfile;
my $genome;
my $lib_type = "F";
my $out;

my $error_message = "USAGE : perl $0 --bam bamfile --genome genome.fai --lib_type FR --out bam_start.bam \n";




GetOptions ("bam=s" => \$bamfile,    # numeric
	    "genome=s"   => \$genome,
	    "lib_type=s" => \$lib_type,
	    "out=s" => \$out
    ) or die $error_message;

if (!$bamfile || !$genome || !$out ) {die "USAGE : perl $0 --bam bamfile --genome genome.fai --out outfile.bam \n";}
if ($lib_type ne "FR" && $lib_type ne "RF" && $lib_type ne "F"){ die $error_message;
}

my $resulting_bam;
if ($lib_type eq "F") #single read library with R1 being the most 5' end of the transcripts. 
{
    $resulting_bam = $bamfile;
}
elsif ($lib_type eq "FR")
{
    my $tmp = "R1";
    #extract R1 from bam
    my $library_command = "samtools view -f64 -b $bamfile | samtools sort - $tmp";
    $resulting_bam = $tmp.".bam";
    system($library_command);
}
elsif ($lib_type eq "RF")
{
    my $tmp = "R2";
    #extract R1 from bam                                                                                                                                                      
    my $library_command = "samtools view -f128 -b $bamfile | samtools sort - $tmp";
    $resulting_bam = $tmp.".bam";
    system($library_command);
}






my $generic = $bamfile;
$generic =~ s/\.bam//;
$generic =~ s/.*\///g;

print STDERR "Generating the bam files - be patient it may take a while - \n";


my $file_tmp = "bamtmp";my $bed = "bedtmp";my $newbam = $out;
$newbam =~ s/\.bam//;
#first convert your bam to bed. 
my $command = "bedtools bamtobed -cigar  -i $resulting_bam > $file_tmp"; 

print STDERR "$command\n";
system($command);
parse_bed($file_tmp, $bed);

#then go back to bam again - sort it at the same time. 
my $command2 = "bedtools bedtobam -i $bed -g $genome | samtools sort - $newbam";
my $newbam_withbam = $newbam.".bam";
my $command3 = "samtools index $newbam_withbam";

#excecute the commands

system($command2);
system($command3);

#removing tmp files that are not necessary anymore. 
unlink($file_tmp);
unlink($bed);

 
sub parse_bed {
    my ($file, $bed)=@_;
    #read the tmp file
    open (FILE, $file) or die;
    #write the first mapped postion into a bed new bed file 
    open (OUT, ">$bed") or die; 
    
    foreach my $line (<FILE>)
    {
	chomp $line;
	my $start;
	my @tmp = split /\t/, $line;
	my $chr = $tmp[0];
	my $orientation = $tmp[5];
	#if the orientation is + take the start of the read
	if ($orientation eq "+")
	{
	    $start = $tmp[1];
	    $tmp[2] = $start+1;
	}
	#if the orientation is - , take the end of the read
	else{
	    $start = $tmp[2];
	    $tmp[1] = $start-1;
	}
	#fixe up some other issues. 
	$tmp[4] =1;
	$tmp[6] ="1M";
	
	my $new_line = join("\t", @tmp);
	print OUT "$new_line\n";
    }
    close FILE;
    close OUT;
}
