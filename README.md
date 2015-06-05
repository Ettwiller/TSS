# TSS

This sets of programs were developped in conjuction with Cappable-seq (Manuscript :
 A novel strategy for investigating transcriptomes by capturing primary RNA transcripts in submission).The folder contains 4 programs :
 
 [1] bam2firstbasebam.pl
 [2] bam2firstbasegtf.pl
 [3] filter_tss.pl
 [4] cluster_tss.pl
 
 [1] bam2firstbasebam.pl : the program takes 2 arguments (minimum), --bam the mapped bam file and --genome the genome file (fasta format) used to map the reads. The optional agument is the library type (--lib_type default F) that defines the type of library used : FR, RF or F. With FR being R1 Forward/ R2 Reverse, RF being R1 Reverse/ R2 Forward and F being single read forward. Single read reverse will not provide TSS information. The program output a bam and bai file containing onlt the first position of the mapped read corresponding to the TSS. The output can be directly fed to genome visualization tools such as IGV. 
 
 [2] bam2firstbasegtf.pl : the program takes 1 argument (minimum), --bam the mapped bam file. Additional optional arguments are --cutoff (default 0) and --lib_type library type (default F) see description above. This program identifies the reads to the position of the most 5'end position of the mapped read (R1 for FR and F and R2 for RF), counts the number of reads for each position in the genome and orientation and normalized the number of reads (relative read score, RRS) to the total number of mapped reads in the file according to the following equation :  RRSio = (nio/N)/1000000 with RRSio being the relative read score at position i and orientation o (+ or -), nio : number of reads at position i in orientation o and N being the total number of mapped reads. The cutoff filter out positions which RRS are below the defined cutoff (default 0).
 
 [3] filter_tss.pl : The program takes 2 arguments (minimum),--control  the control gtf file (output from bam2firstbasegtf.pl using the control library) and --tss, the gtf file (output of bam2firstbasegtf.pl using the Cappable-seq library). Optional aguments are --cutoff (default 0) and --Rformat output format (default 0) 
 
