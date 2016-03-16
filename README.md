 # TSS workflow for Cappable-seq
 Laurence Ettwiller (New England Biolabs)


##REQUIREMENT : 
Prior to running the TSS workflow for Cappable-seq please download and install the following programs :

**BEDTOOLS** (http://bedtools.readthedocs.org/en/latest/content/installation.html). Please use the latest version of bedtools (2.25.0). 

**SAMTOOLS** (http://samtools.sourceforge.net/)

Optional : 

**IGV** (http://www.broadinstitute.org/igv/)


##OVERVIEW
This sets of programs were developed in conjuction with the development of [Cappable-seq][Cappable-seq] (Manuscript :
A novel strategy for investigating transcriptomes by capturing primary RNA transcripts in submission).The folder contains 3 basic programs :
 
 1. ```bam2firstbasegtf.pl``` 
 2. ```filter_tss.pl``` OPTIONAL if a control library has been added.  
 3. ```cluster_tss.pl```

It contains also related programs for a specific task such as :
   
  4. ```bam2firstbasebam.pl```
  5. ```organized_by_TSS_type.pl``` 

[Cappable-seq]: http://bmcgenomics.biomedcentral.com/articles/10.1186/s12864-016-2539-z

##CONSIDERATIONS :
The TSS suit of program assumes that you have mapped your reads to the reference genome using a mapping algorithm of your choice. How the algorithm considered unmatched 5'end of reads is important for the correct identification of TSS using this suit of programs. We strongly recommend using Bowtie2 local to perform the mapping. Bowtie2 local soft mask a mismatched 5'end of a read and thus, bam2firstbasegtf.pl or bam2firstbasebam.pl will identify the TSS as the position of the most 5' nucleotide matching the reference genome. 

##DETAILS OF THE MAIN PROGRAMS :

###[1] bam2firstbasegtf.pl :

EXAMPLE :
```
bam2firstbasegtf.pl  --bam Cappable-seq_example.bam --cutoff 1.5 --lib_type F --out cappable-seq_TSS.gtf
```

DESCRIPTION :

```bam2firstbasegtf.pl``` identifies TSS at one base resolution. 

This program takes mapped reads (First in pair read for --lib_type FR and second in pair read for --lib_type RF) and trimmed them to 1 nucleotide long read (corresponding to the most 5' nucleotide mapping to the reference genome). For each position in the genome, the alorithm counts the number of reads in each orientation (+/-) and reads are normalized to the total number of mapped reads in the file according to the following equation:  RRSio = (nio/N)*1000000 with RRSio being the relative read score at position i and orientation o (+ or -), nio : number of reads at position i in orientation o and N being the total number of mapped reads. The optional ```-cutoff``` filter out positions which RRSio are below the defined cutoff (default 0, no filtering). The behavior of -cutoff is altered by the option --absolute. If --absolute is 1, the nio is used as a cutoff instead. 

OPTIONS :
The program takes 2 REQUIRED arguments, ```--bam``` and ```out```. OPTIONAL arguments are ```--cutoff``` (default 0) and ```--lib_type``` (default F) and ```--absolute ```(default 0)

* ```--bam``` : path to the bam file of aligned reads (recommended alignment algorithm is bowtie2 --local).

* ```-out``` : name of the  gtf file correponding to TSS genomic position.

* ```--cutoff``` : positive number (int) corresponding to the RRSio (filtering TSS according to the relative read score).

* ```--lib_type``` : F, RF or FR defines the type of library used. With FR being R1 Forward/ R2 Reverse (relaive to the transcript orientation), RF being R1 Reverse/ R2 Forward and F being single read forward. Single read reverse (R) will not provide TSS information and is not supported.

* ```--absolute ``` : 0 will use the RRSio as cutoff 1 will use the absolute number of reads nio.

OUTPUT : gtf file correponding to TSS genomic position. 
 


###[2] filter_tss.pl : 

EXAMPLE : 
```
filter_tss.pl --tss enriched.gtf --control control.gtf --cutoff 0 --out TSS_enriched.gtf
```

DESRCIPTION :
This program require that a control library has been performed together with Cappable-seq. The programs takes two files : [1] a control gtf file (from the control library) and  [2] a cappable-seq gtf file (from the cappable-seq library). Both gtf are the result of the bam2firstbasegtf.pl. 

    
OPTIONS :
```filter_tss.pl``` takes 3 REQUIRED arguments :
* ```--control```  the control gtf file (output from ```bam2firstbasegtf.pl``` using the control library without enrichment)
* ```--tss```, the gtf file (output of bam2firstbasegtf.pl using the Cappable-seq library)
* ```--out``` the name of the output file (gtf format). 
Optional aguments are 
* ```--cutoff``` (default 0) :  The cutoff filters out positions for which enrichment score are below the defined cutoff. It only keeps positions for which log2 (RRStss / RRScontrol) > cutoff.
* ```--Rformat``` output format (default 0).

 
###[3] cluster_tss.pl : 

EXAMPLE : 
```
cluster_tss.pl  --tss TSS_enriched.gtf --cutoff  5 --out TSS_enriched_cluster_5.gtf
```

DESCRIPTION : Number of	TSS have an imprecise start. This program clusters the nearby TSSs into	one single position per	cluster corresponding to the position with the highest RRSio. Only TSS on the same orientation are clustered together. Nearby is defined by the	```-cutoff``` parameter.

OPTIONS : 
The program takes 2 REQUIRED arguments 
* ```--tss``` the .gtf file (output of ```filter_tss.pl``` with Rformat 0 OR output of ```bam2firstbasegtf.pl``` directly if no control library has been made) and 
* ```--out``` the name of the output file (in gtf format). 

Optional argument is 
* ```--cutoff``` (default 5) that defines the size (in bp) of the upstream and downstream region for clustering consideration. 

OUTPUT :
gtf file containing the cluster positions. 

##DETAILS OF THE RELATED PROGRAMS :


###[4] bam2firstbasebam.pl :

EXAMPLE
```
bam2firstbasebam.pl  --bam cappable-seq.bam --genome ecoli_genome.fai
```

DESCRIPTION : This program is intended for visualization purpose only (using IGV). The read will only be 1 bp long (the most 5' mapped position) and for paired-end read, only the relevant read (the transcript most 5' end) will be shown. 

OPTIONS :
```bam2firstbasebam.pl``` takes a minimum of 2 arguments, ```--bam``` the mapped bam file (REQUIRED) and ```--genome``` the index of the genome file (fai format, REQUIRED) used to map the reads. The optional argument is the library type (```--lib_type``` default F) that defines the type of library used : FR, RF or F. With FR being R1 Forward/ R2 Reverse, RF being R1 Reverse/ R2 Forward and F being single read forward. Single read reverse (R) will not provide TSS information and is not supported. the .fai file correspond to the index of the genome file (can be obtained using samtools faidx command such as ```samtools faidx genome.fasta``` to obtain a genome.fasta.fai file). 

OUTPUT :
The program output a .bam and .bai files containing only the first position of the mapped read corresponding to the TSS. The output can be directly fed to genome visualization tools such as IGV.



###[5] organized_by_TSS_type.pl :
DESCRIPTION :

OPTION : --tss ../../TSS/TSS_enriched_cluster_5.gtf --genome /mnt/home/ettwiller/laurence/projects/ira_cap/3_ecoli_RNase_inhibitors/genome/ecoli_genome_and_controls_new.fasta --detail : 0 or 1 : 0 gives an overview of the percentage of TSS have a defined -1+1 combinations while 1 gives you for each TSS, the -1+1 combination, its strength (RSS) and enrichement (in cappable-seq) 


##The commands used for the Cappable-seq analysis are the following :
```
bam2firstbasegtf.pl  --bam Replicate1_control_R1_001.bam --cutoff 0 --out control.gtf
bam2firstbasegtf.pl  --bam Replicate1_enriched_R1_001.bam --cutoff 1.5 --out enriched.gtf
filter_tss.pl --tss enriched.gtf --control control.gtf --cutoff 0 --out TSS_enriched.gtf
cluster_tss.pl  --tss TSS_enriched.gtf --cutoff  5 --out TSS_enriched_cluster_5.gtf
```
Figure3 :
```
organized_by_TSS_type.pl  --tss TSS_enriched_cluster_5.gtf --genome reference_genome.fasta --detail 1 or 0
```
##REFERENCE :
If you are using this suite of program for publication please reference : 

A novel enrichment strategy reveals unprecedented number of novel transcription start sites at single base resolution in a model prokaryote and the gut microbiome Laurence Ettwiller, John Buswell, Erbay Yigit and Ira Schildkraut. BMC Genomics201617:199.


