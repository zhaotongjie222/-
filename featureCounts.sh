#!/bin/bash -l
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 01:00:00
#SBATCH -J featureCounts
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out

# Load the required modules
module load R-bundle-Bioconductor/3.20-foss-2024a-R-4.4.2
module load Subread/2.1.1-GCC-13.3.0

# Define your working directory
WORKDIR="/crex/proj/uppmax2026-1-61/nobackup/work/tozh3226/Phase1_RNA/Mapping"
cd $WORKDIR

# Define your annotation file (Make sure it has NO fasta sequences at the end!)
ANNOTATION="/gorilla/home/tozh3226/wiki/Pacbio/prokka_annotation_E745/E745_ann_rmovedd.gff"

# Run featureCounts on all your sorted BAM files at once
# Note: Added $ANNOTATION for the path and -T 2 to utilize your requested cores
featureCounts -T 2 -p -t CDS -g locus_tag -a $ANNOTATION -o read_counts_matrix.txt ERR1797969.sorted.bam ERR1797970.sorted.bam ERR1797971.sorted.bam ERR1797972.sorted.bam ERR1797973.sorted.bam ERR1797974.sorted.bam