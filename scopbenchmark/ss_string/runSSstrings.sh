#!/bin/bash

dbname=$(basename "$1" .fasta)
seed_sub_mat=${2:-mat_1.out}
sub_mat=${3:-mat_1.out}

dir_base=./alignResults/rawoutput/
dir_log=./alignResults/logs/
dir_rocx=./alignResults/rocx/
mkdir -p "$dir_base"
mkdir -p "$dir_log"
mkdir -p "$dir_rocx"

alignment_name="$dbname"_$(basename "$seed_sub_mat" .out)_$(basename "$sub_mat" .out)
output="$dir_base""$alignment_name".m8
log="$dir_log""$alignment_name".log
rocx="$dir_rocx""$alignment_name".rocx

set -x
## start timing
date
## mmseqs search module
mmseqs easy-search "$1" "$1"  "$output" tmp  \
  --threads 32 -s 7.5 -e 10000 --max-seqs 2000  --sub-mat "$sub_mat" --seed-sub-mat "$seed_sub_mat" > "$log"
## end timing
date
set +x

## generate ROCX file
./bench.awk scop_lookup.tsv <(cat "$output") > "$rocx"
## calculate auc
 awk '{ famsum+=$3; supfamsum+=$4; foldsum+=$5}END{print famsum/NR,supfamsum/NR,foldsum/NR}' "$rocx"