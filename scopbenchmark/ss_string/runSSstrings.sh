#!/bin/bash

## start timing
date 

## mmseqs search module
mmseqs easy-search ss_strings_dssp_nc.fasta ss_strings_dssp_nc.fasta ./alignResults/rawoutput/no_matrix/ss_strings_dssp_nc.m8 tmp  \
  -a --threads 24 -s 7.5 -e 10000 --max-seqs 2000  --sub-mat SSAlign_large_negative.out --seed-sub-mat SSAlign_large_negative.out

## end timing
date


## generate ROCX file
./bench.awk scop_lookup.tsv <(cat ./alignResults/rawoutput/no_matrix/ss_strings_dssp_nc.m8) > ./alignResults/rocx/no_matrix/ss_strings_dssp_nc.m8

## calculate auc
 awk '{ famsum+=$3; supfamsum+=$4; foldsum+=$5}END{print famsum/NR,supfamsum/NR,foldsum/NR}' ./alignResults/rocx/no_matrix/ss_strings_dssp_nc.m8
