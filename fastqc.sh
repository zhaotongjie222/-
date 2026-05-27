#!/bin/bash -l
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 00:30:00
#SBATCH -J fastqc_check
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out

# 加载 UPPMAX 的生物信息学工具和 FastQC 模块
module load FastQC/0.12.1-Java-17

# 定义你的工作目录
WORKDIR="/crex/proj/uppmax2026-1-61/nobackup/work/tozh3226/Phase1_RNA/Trimmed_reads"
cd $WORKDIR

# 运行 FastQC
# -t 2 表示使用你申请的 2 个核心加速运行
# -o . 表示将结果输出到当前工作目录
fastqc -t 2 -o . ERR1797970_2.paired.fastq.gz