use strict;

#WARNINGS :
#paired end mapping : you will get both end of the fragment ! for the TSS, get the R1 (small RNA) or R2 (RNA seq) only.
#

# INPUT :
#bam file X.bam (preferably generated through local alignment such as Bowtie --local)
#OUTPUT :
# X_start.bam and X_start.bam.bai

my $bamfile = $ARGV[0];

my $generic = $bamfile;
$generic =~ s/\.bam//;
my $genome = "/mnt/home/laurence/projects/ira_cap/genome/ecoli_genome_and_controls_new.fasta.fai";

print STDERR "Generating the bam files - be patient it may take a while - \n";


my $file_tmp = "bamtmp";my $bed = "bedtmp";my $newbam = $generic."_start";

my $command = "bedtools bamtobed -cigar  -i $bamfile > $file_tmp"; 
print STDERR "$command\n";
system($command);
parse_bed($file_tmp, $bed);

my $command2 = "bedtools bedtobam -i $bed -g $genome | samtools sort - $newbam";
my $newbam_withbam = $newbam.".bam";
my $command3 = "samtools index $newbam_withbam";
system($command2);
system($command3);
 
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

