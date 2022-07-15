#!/bin/bash
align() {
  dbname=$(basename "$1" .fasta)

  ## start timing
  date

  ## mmseqs search module
  mmseqs easy-search "$1" "$1" ./alignResults/rawoutput/"$dbname".m8 tmp  \
    -a --threads 32 -s 7.5 -e 10000 --max-seqs 2000  --sub-mat SSAlign_large_negative.out --seed-sub-mat SSAlign_large_negative.out > ./alignResults/logs/"$dbname".log

  ## end timing
  date

  ## generate ROCX file
  ./bench.awk scop_lookup.tsv <(cat ./alignResults/rawoutput/"$dbname".m8) > ./alignResults/rocx/"$dbname".rocx

  ## calculate auc
   awk '{ famsum+=$3; supfamsum+=$4; foldsum+=$5}END{print famsum/NR,supfamsum/NR,foldsum/NR}' ./alignResults/rocx/"$dbname".rocx
}

align ss_strings_dssp.fasta
align ss_strings_dssp_nc.fasta

