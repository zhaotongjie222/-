#!/bin/bash -l
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH -t 05:00:00
#SBATCH -J pacbio_assembly_polishing
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out

# ==========================================
# 步骤 0: 加载必要的运行环境 (Modules)
# ==========================================
module load canu/2.3-GCCcore-13.3.0-Java-17
module load minimap2/2.30-GCCcore-13.3.0
module load SAMtools/1.22.1-GCC-13.3.0
module load BCFtools/1.22.1-GCC-13.3.0

# ==========================================
# 路径与环境变量设置
# ==========================================
INPUT_DIR="/crex/proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017/genomics_data/PacBio"
OUTPUT_DIR="/gorilla/home/tozh3226/E745_analysis_results"

mkdir -p ${OUTPUT_DIR}
cd ${OUTPUT_DIR}

GENOME_SIZE="5m"  # 【请修改】此处需替换为你所分析细菌的准确基因组大小
THREADS=4         # 根据手册要求，Canu 使用 4 个核心
PREFIX="bacteria"
INPUT_READS="${INPUT_DIR}/*.subreads.fastq.gz"

# ==========================================
# 步骤 1: Genome Assembly (使用 Canu)
# ==========================================
echo "Starting Canu Assembly..."

# 根据手册要求添加 useGrid=false 和 maxThreads=4
canu \
    -p ${PREFIX} \
    -d ${OUTPUT_DIR}/${PREFIX}_canu_out \
    genomeSize=${GENOME_SIZE} \
    useGrid=false \
    maxThreads=${THREADS} \
    -pacbio ${INPUT_READS}

echo "Canu Assembly phase finished."

DRAFT_FASTA="${OUTPUT_DIR}/${PREFIX}_canu_out/${PREFIX}.contigs.fasta"
if [ ! -f "$DRAFT_FASTA" ]; then
    echo "Error: Draft assembly not found at ${DRAFT_FASTA}. Exiting."
    exit 1
fi

# ==========================================
# 步骤 2: Polishing (使用 Minimap2 + Samtools + BCFtools)
# ==========================================
echo "Starting Polishing steps..."

# 2.1 比对
echo "Mapping reads to draft assembly using minimap2..."
minimap2 -ax map-pb -t ${THREADS} ${DRAFT_FASTA} ${INPUT_READS} > draft_alignment.sam

# 2.2 转换与排序 (合并命令以减少中间大文件生成，符合手册优化建议)
echo "Sorting and indexing BAM file..."
samtools view -S -b -@ ${THREADS} draft_alignment.sam | samtools sort -@ ${THREADS} -o draft_alignment.sorted.bam
samtools index draft_alignment.sorted.bam

# 2.3 变异检测
echo "Calling variants using BCFtools..."
bcftools mpileup -Ou -f ${DRAFT_FASTA} draft_alignment.sorted.bam | \
bcftools call -mv -Oz -o variants_calls.vcf.gz
bcftools index variants_calls.vcf.gz

# 2.4 生成终版一致性序列 (Consensus)
echo "Applying corrections to generate final polished assembly..."
bcftools consensus -f ${DRAFT_FASTA} variants_calls.vcf.gz > ${OUTPUT_DIR}/${PREFIX}_polished_assembly.fasta

# ==========================================
# 清理中间大文件
# ==========================================
echo "Cleaning up intermediate sam file..."
rm draft_alignment.sam

echo "Phase 2 Pipeline successfully completed!"