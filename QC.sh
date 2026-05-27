#!/bin/bash -l
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 02:00:00
#SBATCH -J eval_canu_assembly
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out

# 加载指定的软件模块
module load QUAST/5.3.0-gfbf-2024a
module load MUMmer/4.0.1-GCCcore-13.3.0
module load BUSCO/5.8.2-gfbf-2024a

# 切换到分析工作目录
cd /gorilla/home/tozh3226/E745_analysis_results/

# 你的 Canu 组装结果文件
CANU_DIR="/gorilla/home/tozh3226/E745_analysis_results/bacteria_canu_out"
ASSEMBLY_FILE="/gorilla/home/tozh3226/E745_analysis_results/bacteria_canu_out/bacteria.contigs.fasta" # ?? 记得修改为你的实际前缀

# 核心修改：定义双参考基因组
# 1. 用于准确计算组装错误率的 E745 官方基因组
REFERENCE_QUAST="/gorilla/home/tozh3226/wiki/Pacbio/reference/E745/E745_official_reference.fasta"
# 2. 用于共线性与进化变异比较的 Aus0004 近缘基因组
REFERENCE_MUMMER="/gorilla/home/tozh3226/wiki/Pacbio/reference/Aus0004/Aus0004_reference.fasta"

# ==========================================
# 1. QUAST 评估 (使用 E745 官方参考验证组装准确度)
# ==========================================
quast.py $ASSEMBLY_FILE -r $REFERENCE_QUAST -o quast_results -t 2

# ==========================================
# 2. BUSCO 评估
# ==========================================
busco -i $ASSEMBLY_FILE -l bacteria_odb10 -o busco_results -m genome -c 2

# ==========================================
# 3. MUMmerplot 评估 (使用 Aus0004 参考进行共线性比较)
# ==========================================
nucmer --prefix=mummer_aln $REFERENCE_MUMMER $ASSEMBLY_FILE
mummerplot --png -R $REFERENCE_MUMMER -Q $ASSEMBLY_FILE --prefix=mummer_plot mummer_aln.delta