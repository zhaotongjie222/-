#!/bin/bash -l

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH -t 04:00:00
#SBATCH -J bwamem2_rna_mapping
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out

# 加载你指定的新版模块 [cite: 306, 308]
module load bwa-mem2/2.3-GCC-13.3.0
module load SAMtools/1.22.1-GCC-13.3.0

# 定义路径
TRIM_DIR="/crex/proj/uppmax2026-1-61/nobackup/work/tozh3226/Phase1_RNA/Trimmed_reads"
OUT_DIR="/crex/proj/uppmax2026-1-61/nobackup/work/tozh3226/Phase1_RNA/Mapping"

# ====================================================================
# 【重要】这是你的 E745 DNA 组装结果作为参考基因组
# ====================================================================
REFERENCE="/gorilla/home/tozh3226/E745_analysis_results/bacteria_canu_out/bacteria.contigs.fasta"

# 创建输出目录 [cite: 176]
mkdir -p ${OUT_DIR}

echo "Starting bwa-mem2 Mapping Pipeline..."

# 1. 使用 bwa-mem2 对参考基因组建索引
echo "Indexing reference genome..."
bwa-mem2 index ${REFERENCE}

# 定义所有样本的前缀数组
SAMPLES=("ERR1797969" "ERR1797970" "ERR1797971" "ERR1797972" "ERR1797973" "ERR1797974")

# 2. 循环处理每一个样本
for SAMPLE in "${SAMPLES[@]}"; do
    echo "Processing sample: ${SAMPLE}..."
    
    # 我们只使用成对的 (paired) reads 进行比对
    R1="${TRIM_DIR}/${SAMPLE}_1.paired.fastq.gz"
    R2="${TRIM_DIR}/${SAMPLE}_2.paired.fastq.gz"
    BAM_OUT="${OUT_DIR}/${SAMPLE}.sorted.bam"
    
    # 核心步骤：bwa-mem2 比对，并通过管道 (|) 交给 samtools 转换并排序 
    # SAMtools 提供了处理 SAM 格式比对的各种实用程序，包括排序和生成位置格式 [cite: 726]
    bwa-mem2 mem -t 2 ${REFERENCE} ${R1} ${R2} | samtools sort -@ 2 -o ${BAM_OUT} -
    
    # 对生成的 BAM 文件建立索引 (.bai)
    samtools index ${BAM_OUT}
    
    echo "Finished mapping for ${SAMPLE}. Output: ${BAM_OUT}"
done

echo "All mapping jobs completed successfully!"