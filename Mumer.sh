#!/bin/bash -l

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 14:00:00
#SBATCH -J E745_eggNOG_MUMmer
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out

# Load modules
module load eggnog-mapper/2.1.12-foss-2024a
module load MUMmer/4.0.1-GCCcore-13.3.0

# ---------------------------------------------------------
# 1. 设置文件路径变量
# ---------------------------------------------------------
# Prokka 结果目录和组装文件 (来自你的输入)
PROKKA_DIR="/gorilla/home/tozh3226/wiki/Pacbio/prokka_annotation_E745"
ASSEMBLY="/gorilla/home/tozh3226/E745_analysis_results/bacteria_canu_out/bacteria.contigs.fasta"

# 自动寻找 Prokka 生成的蛋白质序列文件 (.faa)
PROTEIN_FASTA=$(ls ${PROKKA_DIR}/*.faa | head -n 1)

# 【需要你手动修改】指定 Clade A-1 参考基因组的路径
REF_GENOME="/gorilla/home/tozh3226/wiki/Pacbio/reference/E745/E745_official_reference.fasta"

# 输出目录设置 (建议输出到当前工作目录)
OUT_DIR=$(pwd)

# ---------------------------------------------------------
# 2. 运行 eggNOG-mapper 进行功能富集注释
# ---------------------------------------------------------
echo "Starting eggNOG-mapper analysis..."
emapper.py -i ${PROTEIN_FASTA} \
           --output E745_eggNOG \
           --output_dir ${OUT_DIR} \
           --cpu 2 \
           --itype proteins
echo "eggNOG-mapper finished."

# ---------------------------------------------------------
# 3. 运行 MUMmer 进行共线性分析
# ---------------------------------------------------------
echo "Starting MUMmer synteny analysis..."

# 使用 nucmer 进行全基因组比对
nucmer --prefix=${OUT_DIR}/E745_vs_ref ${REF_GENOME} ${ASSEMBLY}

# 生成坐标表 (方便后续查看具体的比对位置)
show-coords -r -c -l ${OUT_DIR}/E745_vs_ref.delta > ${OUT_DIR}/E745_vs_ref.coords

# 按照手册要求使用 -R 和 -Q 生成 mummerplot
mummerplot -R ${REF_GENOME} -Q ${ASSEMBLY} \
           --prefix=${OUT_DIR}/E745_vs_ref \
           --png \
           ${OUT_DIR}/E745_vs_ref.delta
echo "MUMmer analysis finished."