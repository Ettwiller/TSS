# TSS workflow for Cappable-seq


REQUIREMENT : Prior to running the TSS workflow for cappable-seq please download and install the following programs :

BEDTOOLS (http://bedtools.readthedocs.org/en/latest/content/installation.html)
SAMTOOLS (http://samtools.sourceforge.net/)



This sets of programs were developed in conjuction with Cappable-seq (Manuscript :
 A novel strategy for investigating transcriptomes by capturing primary RNA transcripts in submission).The folder contains 4 basic programs :
 
 [1] bam2firstbasebam.pl
 [2] bam2firstbasegtf.pl
 [3] filter_tss.pl
 [4] cluster_tss.pl

It contains also analysis program for a specific task such as :
  [5] organized_by_TSS_type.pl

 
 [1] bam2firstbasebam.pl : the program takes 2 arguments (minimum), --bam the mapped bam file and --genome the genome file (fasta format) used to map the reads. The optional argument is the library type (--lib_type default F) that defines the type of library used : FR, RF or F. With FR being R1 Forward/ R2 Reverse, RF being R1 Reverse/ R2 Forward and F being single read forward. Single read reverse will not provide TSS information. The program output a bam and bai file containing only the first position of the mapped read corresponding to the TSS. The output can be directly fed to genome visualization tools such as IGV. 
 
 [2] bam2firstbasegtf.pl : the program takes 1 argument (minimum), --bam the mapped bam file. Additional optional arguments are --cutoff (default 0) and --lib_type library type (default F, see description above). This program identifies the reads to the position of the most 5'end position of the mapped read (R1 for FR and F and R2 for RF), counts the number of reads for each position in the genome, orientation and normalized number of reads (relative read score, RRS) to the total number of mapped reads in the file according to the following equation :  RRSio = (nio/N)/1000000 with RRSio being the relative read score at position i and orientation o (+ or -), nio : number of reads at position i in orientation o and N being the total number of mapped reads. The cutoff filter out positions which RRS are below the defined cutoff (default 0).
 
 [3] filter_tss.pl : The program takes 2 arguments (minimum),--control  the control gtf file (output from bam2firstbasegtf.pl using the control library) and --tss, the gtf file (output of bam2firstbasegtf.pl using the Cappable-seq library). Optional aguments are --cutoff (default 0) and --Rformat output format (default 0). The cutoff filters out positions for which enrichment score are below the defined cutoff (default 0). 

 [4] cluster_tss.pl : The program takes 1 argument (minimum) --tss the .gtf file (output of filter_tss.pl with Rformat 0). Optional argument is --cutoff (default 5) that defines the size of the upstream and downstream region for clustering consideration. 


 [5] organized_by_TSS_type.pl  --tss ../../TSS/TSS_enriched_cluster_5.gtf --genome /mnt/home/ettwiller/laurence/projects/ira_cap/3_ecoli_RNase_inhibitors/genome/ecoli_genome_and_controls_new.fasta --detail : 0 or 1 : 0 gives an overview of the percentage of TSS have a defined -1+1 combinations while 1 gives you for each TSS, the -1+1 combination, its strength (RSS) and enrichement (in cappable-seq) 


The commands used for the Cappable-seq analysis are the following :
bam2firstbasegtf.pl  --bam Replicate1_control_R1_001.bam --cutoff 0 > control.gtf
bam2firstbasegtf.pl  --bam Replicate1_enriched_R1_001.bam --cutoff 1.5 > enriched.gtf
filter_tss.pl --tss enriched.gtf --control control.gtf --cutoff 0 > TSS_enriched.gtf
cluster_tss.pl  --tss TSS_enriched.gtf --cutoff  5 >  TSS_enriched_cluster_5.gtf

Figure3 :
organized_by_TSS_type.pl  --tss TSS_enriched_cluster_5.gtf --genome reference_genome.fasta --detail 1 or 0

