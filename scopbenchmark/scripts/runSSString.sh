#!/bin/bash

## start timing
#date

## foldseek easy-search (combination of all convert2db + prefilter + align)
#./foldseek/build/src/foldseek easy-search ./benchmark/data/scop-pdb/ ./benchmark/data/scop-pdb/ ./benchmark/alignResults/rawoutput/foldseekaln ./benchmark/alignResults/tmp/ --threads 64 -s 9.5 --max-seqs 2000 -e 10

## end timing
#date

## generate ROCX file
./bench.awk ../scop_lookup.fix.tsv <(cat ../ss_string/mmseq_dssp_no_consecutive_7.5_ex_1_10000.m8) > ../ss_string/mmseq_ss.rocx

## calculate auc
 awk '{ famsum+=$3; supfamsum+=$4; foldsum+=$5}END{print famsum/NR,supfamsum/NR,foldsum/NR}' ../ss_string/mmseq_ss.rocx


