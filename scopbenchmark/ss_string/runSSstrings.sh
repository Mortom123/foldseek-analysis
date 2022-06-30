#!/bin/bash
align() {
  dbname=$(basename "$1" .fasta)

  ## start timing
  date

  ## mmseqs search module
  mmseqs easy-search "$1" "$1" ./alignResults/rawoutput/no_matrix/"$dbname".m8 tmp  \
    -a --threads 24 -s 7.5 -e 10000 --max-seqs 2000  --sub-mat SSAlign_large_negative.out --seed-sub-mat SSAlign_large_negative.out

  ## end timing
  date

  ## generate ROCX file
  ./bench.awk scop_lookup.tsv <(cat ./alignResults/rawoutput/no_matrix/"$dbname".m8) > ./alignResults/rocx/no_matrix/"$dbname".rocx

  ## calculate auc
   awk '{ famsum+=$3; supfamsum+=$4; foldsum+=$5}END{print famsum/NR,supfamsum/NR,foldsum/NR}' ./alignResults/rocx/no_matrix/"$dbname".rocx
}

align_ex() {
  dbname=$(basename "$1" .fasta)_ex

  ## start timing
  date

  ## mmseqs search module
  mmseqs easy-search "$1" "$1" ./alignResults/rawoutput/no_matrix/"$dbname".m8 tmp  \
    -a --threads 24 -s 7.5 -e 10000 --max-seqs 2000  --sub-mat SSAlign_large_negative.out --seed-sub-mat SSAlign_large_negative.out \
    --exhaustive-search

  ## end timing
  date

  ## generate ROCX file
  ./bench.awk scop_lookup.tsv <(cat ./alignResults/rawoutput/no_matrix/"$dbname".m8) > ./alignResults/rocx/no_matrix/"$dbname".rocx

  ## calculate auc
   awk '{ famsum+=$3; supfamsum+=$4; foldsum+=$5}END{print famsum/NR,supfamsum/NR,foldsum/NR}' ./alignResults/rocx/no_matrix/"$dbname".rocx
}

align ss_strings_dssp.fasta
align ss_strings_dssp_nc.fasta

align_ex ss_strings_dssp.fasta
align_ex ss_strings_dssp_nc.fasta


