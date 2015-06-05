#!/usr/bin/perl

use strict;

use Getopt::Long qw(GetOptions);


my $error_sentence = "USAGE : perl $0 --tss tss_file --control control_file\n OPTIONAL : --cutoff log2(ratio) --Rformat 1";



my $tssfile;
my $controlfile;
my $CUTOFF = 0;
my $Rformat =0;

GetOptions ("tss=s" => \$tssfile,    # numeric
	    "control=s" => \$controlfile,
	    "cutoff=s" => \$CUTOFF,
	    "Rformat=s" => \$Rformat
    ) or die "$error_sentence";

if (!$tssfile || !$controlfile) {die "$error_sentence\n";}



my ($tss, $total_tss) = parse($tssfile);
my ($control, $total_control) = parse($controlfile);

foreach my $chr(keys %$tss)
{
    my $pos = $$tss{$chr};
    foreach my $position (sort {$a<=>$b} keys %$pos)
    {
	my $dir = $$pos{$position};
	foreach my $direction (keys %$dir)
	{
	    my $enrichement_score="NaN"; my $score_control="NaN"; my $score_tss = "NaN";
	    if ($$control{$chr}{$position}{$direction})
	    {
		$score_control = $$control{$chr}{$position}{$direction}{"score"};
		$score_tss = $$tss{$chr}{$position}{$direction}{"score"};
		$enrichement_score = log($score_tss/$score_control)/log(2);

	    }
	    else {
		#no read for the control at this position -we add a pseudocount
		$score_control = sprintf('%.3f',(1/$total_control)*1000000);
		$score_tss = $$tss{$chr}{$position}{$direction}{"score"};
		$enrichement_score = log($score_tss/$score_control)/log(2);
		
	    }
	    if ($enrichement_score >= $CUTOFF)
	    {
		my $line = $$tss{$chr}{$position}{$direction}{"line"};
		if ($Rformat ==0)
		{
		    my @tmp = split /\t/, $line;
		    my $id= $tmp[2];
		    $id = $id.$enrichement_score;
		    $tmp[2]= $id;
		    my $new_line = join("\t", @tmp);
		    $new_line = $new_line.";enrichment_score=$enrichement_score;score_control=$score_control";
		    print "$new_line\n";
		}
		if ($Rformat ==1)
		{
		    print "$score_tss\t$score_control\t$enrichement_score\n";
		}
	    }

	}
    }
    
}


sub parse {
    my ($file) =@_;
    my $total_reads=0;
    my %result;
    open (FILE, $file) or die "can't open $file\n";
    foreach my $line (<FILE>)
    {
	chomp $line;
	my @tmp = split /\t/, $line;
	my $chr = $tmp[0];
	my $pos = $tmp[3];
	my $score = $tmp[5];
	my $info = $tmp[8];
	my $sens = $tmp[6];
	$info =~/number_of_read=(\d+);total_number_of_read=(\d+)/;
	my $read = $1;
	$total_reads = $2;

	$result{$chr}{$pos}{$sens}{"line"}=$line;
	$result{$chr}{$pos}{$sens}{"score"}=$score;
	$result{$chr}{$pos}{$sens}{"read"}=$read;
    }
   
    close FILE;
    return(\%result, $total_reads);
}
