#!/bin/bash -l
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 01:00:00
#SBATCH -J prokka_annotation
#SBATCH --output=%x.%j.out

# 加载模块 [cite: 308, 807]
module load prokka/1.14.5-gompi-2024a


# 定义路径
# 你的 Canu 组装结果文件
ASSEMBLY="/gorilla/home/tozh3226/E745_analysis_results/bacteria_canu_out/bacteria.contigs.fasta"
# 刚才下载的参考基因组（作为注释参考）
REFERENCE="/gorilla/home/tozh3226/wiki/Pacbio/reference/Aus0004/Aus0004_reference.fasta"
# 输出目录
OUTDIR="prokka_annotation_E745"

# 运行 Prokka [cite: 685, 687]
# 注意：针对粪肠球菌，我们指定 genus 和 species 以提高准确性
prokka --outdir $OUTDIR \
       --prefix E745_ann \
       --kingdom Bacteria \
       --genus Enterococcus \
       --species faecium \
       --proteins $REFERENCE \
       $ASSEMBLY

echo "Annotation complete! Output file: $OUTDIR/E745_ann.gff"