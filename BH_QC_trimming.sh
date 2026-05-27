#!/bin/bash -l

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
# 申请充裕的时间来跑 3 个样本 (fastp 速度更快，实际上可能用不到 6 小时)
#SBATCH -t 06:00:00
#SBATCH -J rnaseq_qc_fastp_bh
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out

# 加载 fastp 模块
module load fastp/1.0.1-GCC-13.3.0

# 定义输入数据基础路径
BASE_DIR="/crex/proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017/transcriptomics_data"
BH_DIR="${BASE_DIR}/RNA-Seq_BH"

# 修改为大容量的项目工作目录
# 请确保先创建这个 tozh3226 文件夹
OUT_BASE="/proj/uppmax2026-1-61/nobackup/work/tozh3226/Phase1_RNA"

# 创建输出子目录以保持结构清晰
mkdir -p ${OUT_BASE}/Trimmed_reads
mkdir -p ${OUT_BASE}/fastp_reports

# 定义样本前缀 (仅限 Serum)
BH_SAMPLES=("ERR1797972" "ERR1797973" "ERR1797974")

echo "Starting fastp pipeline for bh samples..."

# ---------------------------------------------------------
# 处理 Serum 样本
# ---------------------------------------------------------
for SAMPLE in "${BH_SAMPLES[@]}"; do
    echo "Processing $SAMPLE..."
    
    # 原始文件路径
    RAW_R1="${BH_DIR}/raw/${SAMPLE}_1.fastq.gz"
    RAW_R2="${BH_DIR}/raw/${SAMPLE}_2.fastq.gz"
    
    # Trimmed 文件的输出路径 (fastp 默认不保留 unpaired reads，因此只需定义 paired)
    TRIM_R1_P="${OUT_BASE}/Trimmed_reads/${SAMPLE}_1.paired.fastq.gz"
    TRIM_R2_P="${OUT_BASE}/Trimmed_reads/${SAMPLE}_2.paired.fastq.gz"
    
    # 报告输出路径
    HTML_REPORT="${OUT_BASE}/fastp_reports/${SAMPLE}_fastp.html"
    JSON_REPORT="${OUT_BASE}/fastp_reports/${SAMPLE}_fastp.json"

    # 使用 fastp 进行质控与裁剪
    # 参数对照原本的 Trimmomatic:
    # --cut_front 和 --cut_tail 对应 LEADING:20 和 TRAILING:20
    # --cut_window_size 4 和 --cut_mean_quality 20 对应 SLIDINGWINDOW:4:20
    # --length_required 50 对应 MINLEN:50
    # --detect_adapter_for_pe 自动检测双端测序接头
    
    fastp --thread 2 \
        -i $RAW_R1 -I $RAW_R2 \
        -o $TRIM_R1_P -O $TRIM_R2_P \
        --detect_adapter_for_pe \
        --cut_front --cut_tail \
        --cut_window_size 4 \
        --cut_mean_quality 20 \
        --length_required 50 \
        -h $HTML_REPORT \
        -j $JSON_REPORT

done

echo "Pipeline complete for bh samples!"