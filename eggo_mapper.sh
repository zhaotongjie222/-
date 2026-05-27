#!/bin/bash

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -n 2
#SBATCH -t 14:00:00
#SBATCH -J E745_eggNOG
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module purge
module load eggnog-mapper/2.1.12-foss-2024a

# 输入文件
PROKKA_DIR="/home/tozh3226/wiki/Pacbio/prokka_annotation_E745"
PROTEIN_FASTA="${PROKKA_DIR}/E745_ann.faa"

# 输出目录
OUT_DIR="${PWD}/eggnog_output"
mkdir -p "${OUT_DIR}"

OUT_PREFIX="E745_eggNOG"

# 正确数据库目录
EGGNOG_DATA_DIR="/gorilla/dataset/eggNOG_data/5.0.0/rackham"

echo "Checking database..."

if [ ! -f "${EGGNOG_DATA_DIR}/eggnog_proteins.dmnd" ]; then
    echo "ERROR: eggnog_proteins.dmnd not found"
    exit 1
fi

echo "Start eggNOG-mapper..."

emapper.py \
    -i "${PROTEIN_FASTA}" \
    -m diamond \
    --itype proteins \
    --data_dir "${EGGNOG_DATA_DIR}" \
    --output "${OUT_PREFIX}" \
    --output_dir "${OUT_DIR}" \
    --cpu 2 \
    --tax_scope bacteria \
    --go_evidence non-electronic \
    --override

echo "eggNOG-mapper finished"